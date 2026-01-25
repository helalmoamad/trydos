import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geodesy/geodesy.dart' as geod;
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_package;
import 'package:shimmer/shimmer.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart'
    as country_model;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late GoogleMapController _mapController;
  late HomeBloc _homeBloc;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final geod.Geodesy _geodesy = geod.Geodesy();

  List<geod.LatLng> _countryBorders = [];
  List<LatLng> _mapBorders = [];
  Set<Polygon> _polygons = {};
  List<Marker> _markers = [];
  LatLng? _selectedLocation;
  bool _isLoading = true;
  bool _isLoadingLocation = false;

  late CameraPosition _initialCameraPosition;
  LatLngBounds? _bounds;

  country_model.Country? _country;
  List<country_model.Country>? _allowedCountries;
  String? _chosenCountry;

  final List<LatLng> _worldRect = [
    const LatLng(20, 20),
    const LatLng(50, 20),
    const LatLng(50, 50),
    const LatLng(20, 50),
    const LatLng(20, 20),
  ];

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _initializeData();
  }

  void _initializeData() {
    // Get country borders from state
    _countryBorders = _homeBloc.state.countryCoordinatesBorders;
    _allowedCountries =
        _homeBloc.state.getAllowedCountriesModel?.data?.countries;

    _chosenCountry = _prefsRepository.userCountryIsAvailable == 1
        ? _prefsRepository.userChoosedCountryIso
        : _prefsRepository.countryIso;

    _country = _allowedCountries?.firstWhere(
      (element) => '${_chosenCountry?.toLowerCase()}'.startsWith(
        element.iso!.toLowerCase(),
      ),
      orElse: () => _allowedCountries?.first ?? _allowedCountries![0],
    );

    // Setup initial camera position
    final defaultLat = double.tryParse(_country?.latitude ?? "0") ?? 33.5138;
    final defaultLng = double.tryParse(_country?.longitude ?? "0") ?? 36.2765;

    _initialCameraPosition = CameraPosition(
      target: LatLng(defaultLat, defaultLng),
      zoom: 10,
    );

    // Setup borders and polygons
    if (_countryBorders.isNotEmpty) {
      _mapBorders = _countryBorders
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      _polygons = {
        Polygon(
          polygonId: const PolygonId('mask'),
          points: _worldRect,
          holes: [_mapBorders],
          // ignore: deprecated_member_use
          fillColor: Colors.black.withOpacity(0.3),
          strokeWidth: 0,
        ),
        Polygon(
          polygonId: const PolygonId('border'),
          points: _mapBorders,
          fillColor: Colors.transparent,
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      };

      // Calculate bounds
      if (_mapBorders.isNotEmpty) {
        double minLat = _mapBorders[0].latitude;
        double maxLat = _mapBorders[0].latitude;
        double minLng = _mapBorders[0].longitude;
        double maxLng = _mapBorders[0].longitude;

        for (var point in _mapBorders) {
          minLat = minLat < point.latitude ? minLat : point.latitude;
          maxLat = maxLat > point.latitude ? maxLat : point.latitude;
          minLng = minLng < point.longitude ? minLng : point.longitude;
          maxLng = maxLng > point.longitude ? maxLng : point.longitude;
        }

        _bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );
      }
    }

    // Fetch country boundaries if not available
    if (_countryBorders.isEmpty) {
      _homeBloc.add(const GetCoutryBoundaryByIsoEvent());
    } else {
      _isLoading = false;
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      location_package.Location location = location_package.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      location_package.PermissionStatus permissionGranted = await location
          .hasPermission();
      if (permissionGranted == location_package.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != location_package.PermissionStatus.granted) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      location_package.LocationData currentLocation = await location
          .getLocation()
          .timeout(const Duration(seconds: 15));

      final locationLatLng = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      // Check if location is within country borders
      if (_countryBorders.isNotEmpty) {
        bool inside = _geodesy.isGeoPointInPolygon(
          geod.LatLng(locationLatLng.latitude, locationLatLng.longitude),
          _countryBorders,
        );

        if (!inside) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.outside_available_area.tr()),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Add marker
      setState(() {
        _markers = [
          Marker(
            markerId: const MarkerId('current_location'),
            position: locationLatLng,
            infoWindow: const InfoWindow(title: 'Your Current Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        ];
        _selectedLocation = locationLatLng;
      });

      // Move camera
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: locationLatLng, zoom: 16),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _onMapTap(LatLng position) {
    // Check if location is within country borders
    if (_countryBorders.isNotEmpty) {
      bool inside = _geodesy.isGeoPointInPolygon(
        geod.LatLng(position.latitude, position.longitude),
        _countryBorders,
      );

      if (!inside) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.outside_available_area.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      _markers = [
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      ];
      _selectedLocation = position;
    });
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.please_select_a_location.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Allow back navigation only when not interacting with map
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.select_location.tr(),
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_isLoadingLocation)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.my_location, color: Colors.blue),
                onPressed: _goToCurrentLocation,
              ),
          ],
        ),
        body: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.getCountryBoundaryByIsoStatus != null &&
                state.getCountryBoundaryByIsoStatus ==
                    GetCountryBoundaryByIsoStatus.success) {
              _countryBorders = state.countryCoordinatesBorders;
              if (_countryBorders.isNotEmpty) {
                _mapBorders = _countryBorders
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList();

                _polygons = {
                  Polygon(
                    polygonId: const PolygonId('mask'),
                    points: _worldRect,
                    holes: [_mapBorders],
                    // ignore: deprecated_member_use
                    fillColor: Colors.black.withOpacity(0.3),
                    strokeWidth: 0,
                  ),
                  Polygon(
                    polygonId: const PolygonId('border'),
                    points: _mapBorders,
                    fillColor: Colors.transparent,
                    strokeColor: Colors.red,
                    strokeWidth: 2,
                  ),
                };

                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          child: Stack(
            children: [
              if (_isLoading)
                _buildShimmerLoader()
              else
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: _initialCameraPosition,
                  onTap: _onMapTap,
                  markers: _markers.toSet(),
                  polygons: _polygons,
                  mapToolbarEnabled: false,
                  cameraTargetBounds: _bounds != null
                      ? CameraTargetBounds(_bounds!)
                      : CameraTargetBounds(
                          LatLngBounds(
                            southwest: const LatLng(-90, -180),
                            northeast: const LatLng(90, 180),
                          ),
                        ),
                  minMaxZoomPreference: const MinMaxZoomPreference(5, 24),
                  onCameraMove: (CameraPosition position) {
                    // Camera moved
                  },
                  myLocationButtonEnabled: false,
                ),
              // Bottom button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null
                            ? _confirmSelection
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.confirm_location.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
            ),
            Container(
              height: 100.h,
              margin: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
