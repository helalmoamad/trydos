import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'dart:math';
import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as translate;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart'
    as counttry;
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart'
    as address;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_event.dart';
import '../../manager/orderBloc/order_state.dart';
import 'package:geodesy/geodesy.dart' as geod;
import 'package:trydos/core/utils/last_pages_tracker.dart';

class AddShippingAdress extends StatefulWidget {
  const AddShippingAdress({
    super.key,
    this.addressInfoClassToEdid,
    this.fromEdid = false,
  });
  final address.CustomerAddressesInfo? addressInfoClassToEdid;
  final bool? fromEdid;
  @override
  State<AddShippingAdress> createState() => _AddShippingAdressState();
}

class _AddShippingAdressState extends State<AddShippingAdress>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> visiblePrefix = ValueNotifier(false);
  final ValueNotifier<bool> visiblePrefixOptional = ValueNotifier(false);
  final ValueNotifier<bool> validateBox = ValueNotifier(false);
  final ValueNotifier<bool> loadingToGoCurrentLoacation = ValueNotifier(false);
  final ValueNotifier<bool> showFulMap = ValueNotifier(false);
  final ValueNotifier<int> maxLengthForNumber = ValueNotifier(25);
  final ValueNotifier<int> maxLengthForOptionalNumber = ValueNotifier(25);
  final ValueNotifier<bool> fillAllContainers = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  final ValueNotifier<List<String>> listOfAddressTilteSeletedByUser =
      ValueNotifier([]);

  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController detailsAddressController =
      TextEditingController();
  List<String> addressTilte = [];

  List<address.RegionDetails> filterResultSearch = [];
  List<LatLng> filterLatLngSearch = [];
  List<address.RegionDetails> finishSelectedByUser = [];
  List<String> finishSelectedByUserToAppear = [];
  final TextEditingController addressTitleController = TextEditingController();
  final PanelController panelController = PanelController();
  final TextEditingController reciptionNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  late AnimationController animationController;
  late HomeBloc homeBloc;
  late OrderBloc orderBloc;
  final TextEditingController alternativePhoneController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late GoogleMapController mapController;
  double currentZoom = 14;
  late CameraPosition _kinitialPosition;
  bool removeMyLocation = false;
  counttry.Country? country;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  String? choosedCountry;
  List<counttry.Country>? alowCountries;
  LatLng? _currentLocation;
  LatLng? _locationFromSearch;
  List<Marker> _markers = [];
  List<Marker> _markersInSmallMap = [];
  geod.Geodesy geodesy = geod.Geodesy();
  bool? fromEditeTodenychangeDetailAddress;
  Future<void> _goToCurrentLocation({required LatLng? latlng}) async {
    Location location = new Location();
    LocationData currentLocation;

    loadingToGoCurrentLoacation.value = true;
    try {
      if (latlng?.latitude != null && latlng?.longitude != null) {
        _currentLocation = latlng!;
      } else {
        currentLocation = await location.getLocation().timeout(
          const Duration(seconds: 15),
        );
        _currentLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      }
      if (countryBorders.isNotEmpty) {
        bool inside = geodesy.isGeoPointInPolygon(
          geod.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          countryBorders,
        );
        if (!inside) {
          // عرض رسالة
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('${LocaleKeys.outside_available_area.tr()}'),
            ),
          );
          _currentLocation = null;
          loadingToGoCurrentLoacation.value = false;
          return;
        }
      }

      await Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: _currentLocation!,
              infoWindow: const InfoWindow(title: 'موقعي الحالي'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ), // علامة حمراء
            ),
          );
        });
      });
      // إضافة علامة حمراء في الموقع الحالي
      if (latlng?.latitude != null && latlng?.longitude != null) {
        mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
      } else {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation!, zoom: 16),
          ),
        );
      }
      // تحريك الكاميرا إلى الموقع الحالي

      loadingToGoCurrentLoacation.value = false;
    } catch (e) {
      loadingToGoCurrentLoacation.value = false;
      if (kDebugMode) print('خطأ في الحصول على الموقع: $e');
    }
  }

  List<geod.LatLng> countryBorders = [];

  final List<LatLng> worldRect = [
    const LatLng(20, 20),
    const LatLng(50, 20),
    const LatLng(50, 50),
    const LatLng(20, 50),
    const LatLng(20, 20),
  ];
  Set<Polygon> polygons = {};

  LatLng convertToLatLng(geod.LatLng point) {
    return LatLng(point.latitude, point.longitude);
  }

  LatLngBounds? bounds = LatLngBounds(
    southwest: const LatLng(30, 30),
    northeast: const LatLng(40, 40),
  );
  List<LatLng> mapSyriaBorders = [];
  @override
  void initState() {
    LastPagesTracker.push("AddShippingAdress Page");
    homeBloc = BlocProvider.of<HomeBloc>(context);
    countryBorders = homeBloc.state.countryCoordinatesBorders;

    if (countryBorders.isNotEmpty) {
      mapSyriaBorders = countryBorders.map((p) => convertToLatLng(p)).toList();
      polygons = {
        Polygon(
          polygonId: const PolygonId('mask'),
          points: worldRect,
          holes: [mapSyriaBorders],
          // ignore: deprecated_member_use
          fillColor: Colors.black.withOpacity(0.3), // تظليل أسود مع شفافية
          strokeWidth: 0,
        ),
        Polygon(
          polygonId: const PolygonId('border'),
          points: mapSyriaBorders,

          fillColor: Colors.transparent,
          strokeColor: Colors.red, // لون الحدود
          strokeWidth: 2,
        ),
      };
    }

    fromEditeTodenychangeDetailAddress = widget.fromEdid ?? false;
    homeBloc = BlocProvider.of<HomeBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    addressTilte = orderBloc.state.provincesByIso ?? [];
    alowCountries = homeBloc.state.getAllowedCountriesModel?.data?.countries;

    choosedCountry = GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
        ? GetIt.I<PrefsRepository>().userChoosedCountryIso
        : GetIt.I<PrefsRepository>().countryIso;
    if (widget.fromEdid ?? false) {
      choosedCountry = widget.addressInfoClassToEdid?.iso;
    }
    country = alowCountries?.firstWhere(
      (element) => '${choosedCountry?.toLowerCase()}'.startsWith(
        element.iso!.toLowerCase(),
      ),
      orElse: () => alowCountries![0],
    );

    _markersInSmallMap = [
      Marker(
        markerId: const MarkerId("initial"),
        position: LatLng(
          double.tryParse(country?.latitude ?? "0") ?? 0,
          double.tryParse(country?.longitude ?? "0") ?? 0,
        ),
      ),
    ];
    //_currentLocation = LatLng(double.tryParse(country?.latitude ?? "0") ?? 0,
    //    double.tryParse(country?.longitude ?? "0") ?? 0);

    if (widget.fromEdid ?? false) {
      if (widget.addressInfoClassToEdid?.location?.latitude != null &&
          widget.addressInfoClassToEdid?.location?.latitude != "") {
        _currentLocation = LatLng(
          double.tryParse(widget.addressInfoClassToEdid!.location!.latitude!)!,
          double.tryParse(widget.addressInfoClassToEdid!.location!.longitude!)!,
        );
        _kinitialPosition = CameraPosition(target: _currentLocation!, zoom: 14);
        _goToCurrentLocation(latlng: _currentLocation);
      } else {
        _kinitialPosition = CameraPosition(
          target: LatLng(
            double.tryParse(country?.latitude ?? "0") ?? 0,
            double.tryParse(country?.longitude ?? "0") ?? 0,
          ),
          zoom: 14,
        );
      }

      if ((widget.addressInfoClassToEdid?.location?.latitude != null &&
          widget.addressInfoClassToEdid?.location?.latitude != "")) {
        _locationFromSearch = LatLng(
          double.tryParse(widget.addressInfoClassToEdid!.location!.latitude!)!,
          double.tryParse(widget.addressInfoClassToEdid!.location!.longitude!)!,
        );
      }

      contactPhoneController.text =
          widget.addressInfoClassToEdid?.contactInfo?.phone ?? "";

      detailsAddressController.text =
          widget.addressInfoClassToEdid?.addressDetail ?? "";

      addressTitleController.text =
          widget.addressInfoClassToEdid?.address ?? "";
      if (widget.addressInfoClassToEdid?.contactInfo?.alternativePhone !=
              null &&
          widget.addressInfoClassToEdid?.contactInfo?.alternativePhone != "") {
        alternativePhoneController.text =
            widget.addressInfoClassToEdid?.contactInfo?.alternativePhone ?? "";
      }

      reciptionNameController.text =
          widget.addressInfoClassToEdid?.contactInfo?.name ?? "";
      finishSelectedByUser = [
        address.RegionDetails(
          building:
              widget.addressInfoClassToEdid?.regionDetails?.building
                      .toString() ==
                  "null"
              ? ""
              : widget.addressInfoClassToEdid?.regionDetails?.building ?? "",
          city:
              widget.addressInfoClassToEdid?.regionDetails?.building
                      .toString() ==
                  "null"
              ? ""
              : widget.addressInfoClassToEdid?.regionDetails?.city ?? "",
          country: "",
          province:
              widget.addressInfoClassToEdid?.regionDetails?.province
                      .toString() ==
                  "null"
              ? ""
              : widget.addressInfoClassToEdid?.regionDetails?.province ?? "",
          street:
              widget.addressInfoClassToEdid?.regionDetails?.street.toString() ==
                  "null"
              ? ""
              : widget.addressInfoClassToEdid?.regionDetails?.street ?? "",
          town:
              widget.addressInfoClassToEdid?.regionDetails?.town.toString() ==
                  "null"
              ? ""
              : widget.addressInfoClassToEdid?.regionDetails?.town ?? "",
          zip:
              widget.addressInfoClassToEdid?.regionDetails?.zip.toString() ==
                  "null"
              ? ""
              : widget.addressInfoClassToEdid?.regionDetails?.zip ?? "",
        ),
      ];
      if (alternativePhoneController.text.length > 0) {
        visiblePrefixOptional.value = true;
      }
      if (contactPhoneController.text.length > 0 &&
          contactPhoneController.text.toString() != "null") {
        visiblePrefix.value = true;
      }
    } else {
      if (orderBloc.state.lastAdressInfoClassToSave?.location?.latitude !=
              null &&
          orderBloc.state.lastAdressInfoClassToSave?.location?.latitude != "") {
        _currentLocation = LatLng(
          double.tryParse(
            orderBloc.state.lastAdressInfoClassToSave!.location!.latitude!,
          )!,
          double.tryParse(
            orderBloc.state.lastAdressInfoClassToSave!.location!.longitude!,
          )!,
        );
        _kinitialPosition = CameraPosition(target: _currentLocation!, zoom: 14);
        _goToCurrentLocation(latlng: _currentLocation);
      } else {
        _kinitialPosition = CameraPosition(
          target: LatLng(
            double.tryParse(country?.latitude ?? "0") ?? 0,
            double.tryParse(country?.longitude ?? "0") ?? 0,
          ),
          zoom: 14,
        );
      }

      if ((orderBloc.state.lastAdressInfoClassToSave?.location?.latitude !=
              null &&
          orderBloc.state.lastAdressInfoClassToSave?.location?.latitude !=
              "")) {
        _locationFromSearch = LatLng(
          double.tryParse(
            orderBloc.state.lastAdressInfoClassToSave!.location!.latitude!,
          )!,
          double.tryParse(
            orderBloc.state.lastAdressInfoClassToSave!.location!.longitude!,
          )!,
        );
      }

      contactPhoneController.text =
          orderBloc.state.lastAdressInfoClassToSave?.contactInfo?.phone ?? "";

      detailsAddressController.text =
          orderBloc.state.lastAdressInfoClassToSave?.addressDetail ?? "";

      addressTitleController.text =
          orderBloc.state.lastAdressInfoClassToSave?.address ?? "";
      if (orderBloc
                  .state
                  .lastAdressInfoClassToSave
                  ?.contactInfo
                  ?.alternativePhone !=
              null &&
          orderBloc
                  .state
                  .lastAdressInfoClassToSave
                  ?.contactInfo
                  ?.alternativePhone !=
              "") {
        alternativePhoneController.text =
            orderBloc
                .state
                .lastAdressInfoClassToSave
                ?.contactInfo
                ?.alternativePhone ??
            "";
      }

      reciptionNameController.text =
          orderBloc.state.lastAdressInfoClassToSave?.contactInfo?.name ?? "";
      finishSelectedByUser = [
        address.RegionDetails(
          building:
              orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.building
                      .toString() ==
                  "null"
              ? ""
              : orderBloc
                        .state
                        .lastAdressInfoClassToSave
                        ?.regionDetails
                        ?.building ??
                    "",
          city:
              orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.building
                      .toString() ==
                  "null"
              ? ""
              : orderBloc
                        .state
                        .lastAdressInfoClassToSave
                        ?.regionDetails
                        ?.city ??
                    "",
          country: "",
          province:
              orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.province
                      .toString() ==
                  "null"
              ? ""
              : orderBloc
                        .state
                        .lastAdressInfoClassToSave
                        ?.regionDetails
                        ?.province ??
                    "",
          street:
              orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.street
                      .toString() ==
                  "null"
              ? ""
              : orderBloc
                        .state
                        .lastAdressInfoClassToSave
                        ?.regionDetails
                        ?.street ??
                    "",
          town:
              orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.town
                      .toString() ==
                  "null"
              ? ""
              : orderBloc
                        .state
                        .lastAdressInfoClassToSave
                        ?.regionDetails
                        ?.town ??
                    "",
          zip:
              orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.zip
                      .toString() ==
                  "null"
              ? ""
              : orderBloc.state.lastAdressInfoClassToSave?.regionDetails?.zip ??
                    "",
        ),
      ];
      if (alternativePhoneController.text.length > 0) {
        visiblePrefixOptional.value = true;
      }
      if (contactPhoneController.text.length > 0 &&
          contactPhoneController.text.toString() != "null") {
        visiblePrefix.value = true;
      }

      //   _goToCurrentLocation(latlng: _currentLocation);
    }
    // appBloc = BlocProvider.of<AppBloc>(context);

    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    // FirebaseAnalyticsService.logScreen(
    //   screen: AnalyticsScreensConst.cartScreen,
    // );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _formatNumber(String input, String countryCode) {
      // إزالة الفراغات

      String inputWithoutCode = input.split("${countryCode}").toList()[1];
      String digitsOnly = inputWithoutCode
          .replaceAll(' ', '')
          .replaceAll(RegExp(r'[^0-9]'), '');

      // إضافة فراغات بين كل 3 أرقام
      StringBuffer formatted = StringBuffer();
      for (int i = 0; i < digitsOnly.length; i++) {
        if (i > 0 && i % 3 == 0) {
          formatted.write(' '); // إضافة فراغ
        }
        formatted.write(digitsOnly[i]);
      }

      return "${countryCode}${(digitsOnly.length == 0) ? formatted.toString() : (" " + formatted.toString())}";
    }

    Widget AddressInfoWidget({
      required String title,
      required String title2,
      required String hint,
      required String hint2,
      required bool isPhone,
      required TextEditingController controller,
      required bool isComplate,
      required int height,
      required BuildContext context,
    }) {
      return ValueListenableBuilder<bool>(
        valueListenable: validateBox,
        builder: (context, isValidateBox, _) {
          if (isValidateBox && controller.text.isNullOrEmpty) {
            animationController.forward();
            Future.delayed(
              const Duration(seconds: 2),
              () => animationController.reset(),
            );
          }
          return ValueListenableBuilder<bool>(
            valueListenable: visiblePrefix,
            builder: (context, isVisiblePrefix, _) {
              return AnimatedBuilder(
                animation: animationController,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    !controller.text.isNullOrEmpty
                        ? 0
                        : sin(3 * 2 * pi * animationController.value) * 5,
                    0,
                  ),
                  child: Container(
                    height: height.h,
                    width: 1.sw,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: (isValidateBox && controller.text.isNullOrEmpty)
                            ? Colors.red
                            : const Color(0xffD3D3D3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 5.h,
                            left: 8.w,
                            right: 8.w,
                          ),
                          height: 18.h,
                          child: Row(
                            children: [
                              Text(
                                title,
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 12.sp,
                                      height:
                                          LanguageService.languageCode == "ar"
                                          ? 0.5
                                          : 0.8,
                                    ),
                              ),
                              title2 == ""
                                  ? const SizedBox.shrink()
                                  : Text(
                                      " (${LocaleKeys.optional.tr()})",
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            color: const Color(0xffD3D3D3),
                                            letterSpacing: 0.18,
                                            fontSize: 12.sp,
                                            height: 0.8,
                                          ),
                                    ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: isPhone
                              ? Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: maxLengthForNumber,
                                    builder: (context, _maxLengthForNumber, _) {
                                      return AppTextField(
                                        controller: controller,
                                        prefix: isVisiblePrefix
                                            ? Text(
                                                "+",
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.mq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff1D1D1D,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      fontSize: 16.sp,
                                                      height: 0.8,
                                                    ),
                                              )
                                            : const SizedBox.shrink(),
                                        textInputType: TextInputType.phone,
                                        bordersColor: Colors.white,
                                        isErrorBorder: false,
                                        maxLength: _maxLengthForNumber,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9\s]'),
                                          ),
                                        ],
                                        textInputAction: TextInputAction.done,
                                        onChange: (val) {
                                          if ((val.length) > 3) {
                                            if (val.startsWith("00")) {
                                              controller.text = val.replaceAll(
                                                "00",
                                                '',
                                              );
                                            } else {
                                              controller.text = val
                                                  .replaceFirst(
                                                    RegExp(r'0'),
                                                    '',
                                                  );
                                            }
                                          }
                                          fillAllContainers.value =
                                              !fillAllContainers.value;
                                          if (controller.text.length > 0 &&
                                              isPhone) {
                                            visiblePrefix.value = true;
                                          } else if (controller.text.length ==
                                                  0 &&
                                              isPhone) {
                                            visiblePrefix.value = false;
                                          }

                                          Country
                                          newCountry = countries.firstWhere(
                                            (element) =>
                                                '+${controller.text.toLowerCase()}'
                                                    .startsWith(
                                                      element.dialCode
                                                          .toLowerCase(),
                                                    ),
                                            orElse: () => const Country(
                                              name: '',
                                              flag: '',
                                              code: '',
                                              dialCode: '',
                                              minLength: 0,
                                              maxLength: 0,
                                            ),
                                          );
                                          if (newCountry.code != "") {
                                            String formattedText =
                                                _formatNumber(
                                                  controller.text,
                                                  newCountry.dialCode
                                                      .split("+")
                                                      .toList()[1],
                                                );
                                            controller.value = TextEditingValue(
                                              text: formattedText,
                                            );
                                          }
                                          if (newCountry.code != "") {
                                            int spaces =
                                                ((newCountry.maxLength) / 3)
                                                    .floor();
                                            if (newCountry.maxLength % 3 == 0) {
                                              spaces--;
                                            }
                                            maxLengthForNumber.value =
                                                newCountry.maxLength +
                                                newCountry.dialCode.length +
                                                spaces;
                                          }
                                        },
                                        onTap: () {},
                                        validator: (value) {
                                          if (value.isNullOrEmpty) {
                                            return LocaleKeys
                                                .the_field_must_not_be_empty
                                                .tr();
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (val) {
                                          FocusScope.of(context).unfocus();
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        hintText:
                                            '${hint}' +
                                            "${hint2 == "" ? "" : "\n${hint2}"}",
                                        contentPadding:
                                            HWEdgeInsetsDirectional.only(
                                              start:
                                                  (LanguageService
                                                          .languageCode !=
                                                      "ar")
                                                  ? 8
                                                  : 8,
                                              end: 1,
                                              bottom: 1,
                                              top: 1,
                                            ),
                                        maxLines: hint2 == "" ? 1 : 2,
                                        minLines: 1,
                                        textStyle: context
                                            .textTheme
                                            .bodyMedium
                                            ?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: 1.1,
                                            ),
                                        hintTextStyle: context
                                            .textTheme
                                            .bodyMedium
                                            ?.rq
                                            .copyWith(
                                              color: const Color(0xffD3D3D3),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: hint2 == "" ? 1 : 1.3,
                                            ),
                                      );
                                    },
                                  ),
                                )
                              : AppTextField(
                                  controller: controller,
                                  textInputType: TextInputType.text,
                                  bordersColor: Colors.white,
                                  isErrorBorder: false,
                                  inputFormatters: !isPhone
                                      ? null
                                      : [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9\s]'),
                                          ),
                                        ],
                                  textInputAction: TextInputAction.done,
                                  onChange: (val) {
                                    fillAllContainers.value =
                                        !fillAllContainers.value;
                                    if (val.length > 0 && isPhone) {
                                      visiblePrefix.value = true;
                                    } else if (val.length == 0 && isPhone) {
                                      visiblePrefix.value = false;
                                    }
                                  },
                                  onTap: () {},
                                  validator: (value) {
                                    if (value.isNullOrEmpty) {
                                      return LocaleKeys
                                          .the_field_must_not_be_empty
                                          .tr();
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  hintText:
                                      '${hint}' +
                                      "${hint2 == "" ? "" : "\n${hint2}"}",
                                  contentPadding: HWEdgeInsetsDirectional.only(
                                    start: 8.w,
                                    end: 1,
                                    bottom: 1,
                                    top: 1,
                                  ),
                                  maxLines: hint2 == "" ? 1 : 2,
                                  minLines: 1,
                                  textStyle: context.textTheme.bodyMedium?.mq
                                      .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 14.sp,
                                        height: 1.1,
                                      ),
                                  hintTextStyle: context
                                      .textTheme
                                      .bodyMedium
                                      ?.rq
                                      .copyWith(
                                        color: const Color(0xffD3D3D3),
                                        letterSpacing: 0.18,
                                        fontSize: 14.sp,
                                        height: hint2 == "" ? 1 : 1.3,
                                      ),
                                ),
                        ),
                      ],
                      /**Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                        Text(
                          title,
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff505050),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 0.8),
                        ),
                        hint2 == ""
                            ? SizedBox(
                                height: 6.h,
                              )
                            : SizedBox.shrink(),
                        Container(
                          height: 20,
                          child: AppTextField(
                            titleField: "ffffffff",
                            hintText: hint,
                            hintTextStyle: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xffD3D3D3),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 0.8),
                          ),
                        ),
                        hint2 == ""
                            ? SizedBox.shrink()
                            : Text(
                                hint2,
                                style: context.textTheme.bodyMedium?.rr.copyWith(
                                    color: const Color(0xffD3D3D3),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 0.8),
                              ),
                                        ],
                                      ),*/
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    Widget AddressInfoWidgetOptional({
      required String title,
      required String title2,
      required String hint,
      required String hint2,
      required bool isPhone,
      required TextEditingController controller,
      required bool isComplate,
      required int height,
      required BuildContext context,
    }) {
      return ValueListenableBuilder<bool>(
        valueListenable: validateBox,
        builder: (context, isValidateBox, _) {
          if (isValidateBox && controller.text.isNullOrEmpty) {
            animationController.forward();
            Future.delayed(
              const Duration(seconds: 2),
              () => animationController.reset(),
            );
          }
          return ValueListenableBuilder<bool>(
            valueListenable: visiblePrefixOptional,
            builder: (context, isVisiblePrefixOptional, _) {
              return Container(
                height: height.h,
                width: 1.sw,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: const Color(0xffD3D3D3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 5.h, left: 8.w, right: 8.w),
                      height: 18.h,
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff505050),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: LanguageService.languageCode == "ar"
                                  ? 0.5
                                  : 0.8,
                            ),
                          ),
                          title2 == ""
                              ? const SizedBox.shrink()
                              : Text(
                                  " (${LocaleKeys.optional.tr()})",
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        color: const Color(0xffD3D3D3),
                                        letterSpacing: 0.18,
                                        fontSize: 12.sp,
                                        height: 0.8,
                                      ),
                                ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: ValueListenableBuilder<int>(
                          valueListenable: maxLengthForOptionalNumber,
                          builder: (context, _maxLengthForOptionalNumber, _) {
                            return AppTextField(
                              controller: controller,
                              prefix: isPhone && isVisiblePrefixOptional
                                  ? Text(
                                      "+",
                                      style: context.textTheme.bodyMedium?.mq
                                          .copyWith(
                                            color: const Color(0xff1D1D1D),
                                            letterSpacing: 0.18,
                                            fontSize: 16.sp,
                                            height: 0.8,
                                          ),
                                    )
                                  : const SizedBox.shrink(),
                              textInputType: isPhone
                                  ? const TextInputType.numberWithOptions()
                                  : TextInputType.text,
                              bordersColor: Colors.white,
                              isErrorBorder: false,
                              maxLength: _maxLengthForOptionalNumber,
                              inputFormatters: !isPhone
                                  ? null
                                  : [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // يسمح بالأرقام فقط
                                      LengthLimitingTextInputFormatter(
                                        15,
                                      ), // يمكنك تحديد الحد الأقصى لعدد الأرقام
                                    ],
                              textInputAction: TextInputAction.done,
                              onChange: (val) {
                                if ((val.length) > 3) {
                                  if (val.startsWith("00")) {
                                    controller.text = val.replaceAll("00", '');
                                  } else {
                                    controller.text = val.replaceFirst(
                                      RegExp(r'0'),
                                      '',
                                    );
                                  }
                                }
                                /* if (val.isNotEmpty) {
                                        /*  displayCountryCode =
                                            val!.replaceAll(' ', '').length >=
                                                    (newCountry.minLength +
                                                        newCountry.dialCode.length -
                                                        1) &&
                                                val.replaceAll(' ', '').length <=
                                                    (newCountry.maxLength +
                                                        newCountry.dialCode.length -
                                                        1);*/
                                      }*/
                                Country newCountry = countries.firstWhere(
                                  (element) =>
                                      '+${controller.text.toLowerCase()}'
                                          .startsWith(
                                            element.dialCode.toLowerCase(),
                                          ),
                                  orElse: () => const Country(
                                    name: '',
                                    flag: '',
                                    code: '',
                                    dialCode: '',
                                    minLength: 0,
                                    maxLength: 0,
                                  ),
                                );
                                if (newCountry.code != "") {
                                  String formattedText = _formatNumber(
                                    controller.text,
                                    newCountry.dialCode.split("+").toList()[1],
                                  );
                                  controller.value = TextEditingValue(
                                    text: formattedText,
                                  );
                                }
                                if (newCountry.code != "") {
                                  int spaces = ((newCountry.maxLength) / 3)
                                      .floor();
                                  if (newCountry.maxLength % 3 == 0) {
                                    spaces--;
                                  }
                                  maxLengthForOptionalNumber.value =
                                      newCountry.maxLength +
                                      newCountry.dialCode.length +
                                      spaces;
                                }
                                fillAllContainers.value =
                                    !fillAllContainers.value;
                                if (controller.text.length > 0 && isPhone) {
                                  visiblePrefixOptional.value = true;
                                } else if (controller.text.length == 0 &&
                                    isPhone) {
                                  visiblePrefixOptional.value = false;
                                }
                              },
                              onTap: () {},
                              onFieldSubmitted: (val) {
                                FocusScope.of(context).unfocus();
                              },
                              textAlignVertical: TextAlignVertical.center,
                              hintText:
                                  '${hint}' +
                                  "${hint2 == "" ? "" : "\n${hint2}"}",
                              contentPadding: HWEdgeInsetsDirectional.only(
                                start: 8.w,
                                end: 1,
                                bottom: 1,
                                top: 1,
                              ),
                              maxLines: hint2 == "" ? 1 : 2,
                              minLines: 1,
                              textStyle: context.textTheme.bodyMedium?.mq
                                  .copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14.sp,
                                    height: 1.1,
                                  ),
                              hintTextStyle: context.textTheme.bodyMedium?.rq
                                  .copyWith(
                                    color: const Color(0xffD3D3D3),
                                    letterSpacing: 0.18,
                                    fontSize: 14.sp,
                                    height: hint2 == "" ? 1 : 1.3,
                                  ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  /**Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                        Text(
                          title,
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff505050),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 0.8),
                        ),
                        hint2 == ""
                            ? SizedBox(
                                height: 6.h,
                              )
                            : SizedBox.shrink(),
                        Container(
                          height: 20,
                          child: AppTextField(
                            titleField: "ffffffff",
                            hintText: hint,
                            hintTextStyle: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xffD3D3D3),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 0.8),
                          ),
                        ),
                        hint2 == ""
                            ? SizedBox.shrink()
                            : Text(
                                hint2,
                                style: context.textTheme.bodyMedium?.rr.copyWith(
                                    color: const Color(0xffD3D3D3),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 0.8),
                              ),
                                        ],
                                      ),*/
                ),
              );
            },
          );
        },
      );
    }

    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        // didCallOnWillPop = true;
        if (showFulMap.value == true) {
          showFulMap.value = false;
          loadingToGoCurrentLoacation.value = false;
          return false;
        }
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusManager.instance.primaryFocus?.unfocus();
          return false;
        }
        if (panelController.isPanelOpen) {
          panelController.close();
          showPanel.value = false;
          return false;
        }
        if (Navigator.canPop(context)) {
          if (Navigator.of(context).canPop()) {
            orderBloc.add(
              SaveLastAddress(
                lastAddress: address.CustomerAddressesInfo(
                  addressDetail: detailsAddressController.text,
                  contactInfo: address.ContactInfo(
                    alternativePhone: alternativePhoneController.text,
                    name: reciptionNameController.text,
                    phone: contactPhoneController.text,
                  ),
                  address: addressTitleController.text,
                  location: address.Location(
                    latitude: _currentLocation?.latitude.toString() ?? "",
                    longitude: _currentLocation?.longitude.toString() ?? "",
                  ),
                  regionDetails: address.RegionDetails(
                    zip: finishSelectedByUser.length > 0
                        ? finishSelectedByUser[0].zip
                        : "",
                    building: finishSelectedByUser.length > 0
                        ? finishSelectedByUser[0].building
                        : "",
                    city: finishSelectedByUser.length > 0
                        ? finishSelectedByUser[0].city
                        : "",
                    country: "${country?.name}",
                    province: finishSelectedByUser[0].province,
                    street: finishSelectedByUser.length > 0
                        ? finishSelectedByUser[0].street
                        : "",
                    town: finishSelectedByUser.length > 0
                        ? finishSelectedByUser[0].town
                        : "",
                  ),
                ),
              ),
            );
            Navigator.of(context).pop();

            return false;
            // منع الإغلاق بعد تنفيذ pop
          }

          // يسمح بالإغلاق إذا لم تنطبق أي من الشروط
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return ValueListenableBuilder<bool>(
              valueListenable: showPanel,
              builder: (context, _showPanel, _) {
                return Form(
                  key: formKey,
                  child: BlocBuilder<OrderBloc, OrderState>(
                    buildWhen: (previous, current) =>
                        previous.getAddressByCoordinatesStatus !=
                        current.getAddressByCoordinatesStatus,
                    builder: (context, state) {
                      if (state.getAddressByCoordinatesStatus ==
                              GetAddressByCoordinatesStatus.success &&
                          !((fromEditeTodenychangeDetailAddress ?? false)) &&
                          state.getAddressByCoordinatesModel?.data?.province !=
                              null) {
                        finishSelectedByUser = [
                          address.RegionDetails(
                            building:
                                state
                                    .getAddressByCoordinatesModel
                                    ?.data
                                    ?.building ??
                                "",
                            city:
                                state
                                    .getAddressByCoordinatesModel
                                    ?.data
                                    ?.city ??
                                "",
                            country: "",
                            province:
                                state
                                    .getAddressByCoordinatesModel
                                    ?.data
                                    ?.province ??
                                "",
                            street:
                                state
                                    .getAddressByCoordinatesModel
                                    ?.data
                                    ?.street ??
                                "",
                            town:
                                state
                                    .getAddressByCoordinatesModel
                                    ?.data
                                    ?.town ??
                                "",
                          ),
                        ];
                        finishSelectedByUser.removeWhere(
                          (element) => element == "",
                        );
                      }

                      fromEditeTodenychangeDetailAddress = false;
                      return Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 60.h),
                                width: 1.sw,
                                height: 50.h,
                                child: Container(
                                  height: 50.h,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (showFulMap.value == true) {
                                            loadingToGoCurrentLoacation.value =
                                                false;
                                            showFulMap.value = false;
                                            return;
                                          }
                                          // didCallOnWillPop = true;
                                          if (Navigator.canPop(context)) {
                                            orderBloc.add(
                                              SaveLastAddress(
                                                lastAddress: address.CustomerAddressesInfo(
                                                  addressDetail:
                                                      detailsAddressController
                                                          .text,
                                                  contactInfo: address.ContactInfo(
                                                    alternativePhone:
                                                        alternativePhoneController
                                                            .text,
                                                    name:
                                                        reciptionNameController
                                                            .text,
                                                    phone:
                                                        contactPhoneController
                                                            .text,
                                                  ),
                                                  address:
                                                      addressTitleController
                                                          .text,
                                                  location: address.Location(
                                                    latitude:
                                                        _currentLocation
                                                            ?.latitude
                                                            .toString() ??
                                                        "",
                                                    longitude:
                                                        _currentLocation
                                                            ?.longitude
                                                            .toString() ??
                                                        "",
                                                  ),
                                                  regionDetails: address.RegionDetails(
                                                    zip:
                                                        finishSelectedByUser
                                                                .length >
                                                            0
                                                        ? finishSelectedByUser[0]
                                                              .zip
                                                        : "",
                                                    building:
                                                        finishSelectedByUser
                                                                .length >
                                                            0
                                                        ? finishSelectedByUser[0]
                                                              .building
                                                        : "",
                                                    city:
                                                        finishSelectedByUser
                                                                .length >
                                                            0
                                                        ? finishSelectedByUser[0]
                                                              .city
                                                        : "",
                                                    country: "${country?.name}",
                                                    province:
                                                        finishSelectedByUser[0]
                                                            .province,
                                                    street:
                                                        finishSelectedByUser
                                                                .length >
                                                            0
                                                        ? finishSelectedByUser[0]
                                                              .street
                                                        : "",
                                                    town:
                                                        finishSelectedByUser
                                                                .length >
                                                            0
                                                        ? finishSelectedByUser[0]
                                                              .town
                                                        : "",
                                                  ),
                                                ),
                                              ),
                                            );
                                            if (Navigator.of(
                                              context,
                                            ).canPop()) {
                                              Navigator.of(context).pop();
                                              return;
                                              // منع الإغلاق بعد تنفيذ pop
                                            }

                                            // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                            return;
                                          } else {}
                                        },
                                        child: Container(
                                          width: 40.w,
                                          child: Transform.rotate(
                                            angle:
                                                LanguageService.languageCode ==
                                                    "ar"
                                                ? pi
                                                : 0,
                                            child: SvgPicture.asset(
                                              AppAssets.backIconArrowSvg,
                                              height: 20.h,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              height: 18.h,
                                              AppAssets.addShippingAddressSvg,
                                            ),
                                            Positioned(
                                              height: 18.h,
                                              top: -2,
                                              child: SvgPicture.asset(
                                                AppAssets
                                                    .addShippingAddressWhiteSvg,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        "${LocaleKeys.add_shipping_address.tr()} ",
                                        style: context.textTheme.bodyMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.2,
                                              fontSize: 14.sp,
                                              height: 1.33,
                                            ),
                                      ),
                                      SizedBox(width: 120.w),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: showFulMap,
                                  builder: (context, isShowFulMap, _) {
                                    return Scaffold(
                                      resizeToAvoidBottomInset: false,
                                      body: SingleChildScrollView(
                                        physics: isShowFulMap
                                            ? const NeverScrollableScrollPhysics()
                                            : const ClampingScrollPhysics(),
                                        child: Container(
                                          alignment: Alignment.topCenter,
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xffF8F8F8,
                                                    ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xffD3D3D3,
                                                      ),
                                                    ),
                                                  ),
                                                  height: 50.h,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 20.w),
                                                      SvgPicture.asset(
                                                        AppAssets.enterInfoSvg,
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Container(
                                                        width: 370.w,
                                                        height: 32.h,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              "${LocaleKeys.entering_the_information_below_clearly.tr()} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff8D8D8D,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        11.sp,
                                                                    height: 0.8,
                                                                  ),
                                                            ),
                                                            Text(
                                                              "${LocaleKeys.your_order_arrives_without_problems.tr()} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff8D8D8D,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        11.sp,
                                                                    height: 0.8,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                isShowFulMap
                                                    ? const SizedBox.shrink()
                                                    : SizedBox(height: 10.h),
                                                isShowFulMap
                                                    ? Stack(
                                                        children: [
                                                          Container(
                                                            width: 1.sw,
                                                            height: 1.sh / 1.7,
                                                            margin:
                                                                EdgeInsets.only(
                                                                  left: 15.w,
                                                                  right: 15.w,
                                                                  top: 15.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    15.r,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    const Color(
                                                                      0xffD3D3D3,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Container(
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              width: 1.sw,
                                                              height:
                                                                  1.sh / 1.7,
                                                              margin:
                                                                  EdgeInsets.all(
                                                                    10.w,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      15.r,
                                                                    ),
                                                                border: Border.all(
                                                                  color: const Color(
                                                                    0xffD3D3D3,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: GoogleMap(
                                                                onCameraMove:
                                                                    (position) {
                                                                      currentZoom =
                                                                          position
                                                                              .zoom;
                                                                    },
                                                                cameraTargetBounds:
                                                                    CameraTargetBounds(
                                                                      bounds,
                                                                    ),
                                                                minMaxZoomPreference:
                                                                    const MinMaxZoomPreference(
                                                                      5,
                                                                      24,
                                                                    ),
                                                                polygons:
                                                                    polygons,
                                                                initialCameraPosition:
                                                                    _kinitialPosition,
                                                                markers: _markers
                                                                    .toSet(),
                                                                onTap: (argument) {
                                                                  _markers = [];

                                                                  if (countryBorders
                                                                      .isNotEmpty) {
                                                                    bool
                                                                    inside = geodesy.isGeoPointInPolygon(
                                                                      geod.LatLng(
                                                                        argument
                                                                            .latitude,
                                                                        argument
                                                                            .longitude,
                                                                      ),
                                                                      countryBorders,
                                                                    );
                                                                    if (!inside) {
                                                                      // عرض رسالة
                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      ).showSnackBar(
                                                                        SnackBar(
                                                                          duration: const Duration(
                                                                            seconds:
                                                                                2,
                                                                          ),
                                                                          content: Text(
                                                                            "${LocaleKeys.outside_available_area.tr()}",
                                                                          ),
                                                                        ),
                                                                      );
                                                                      return;
                                                                    }
                                                                  }
                                                                  if (currentZoom <
                                                                      14) {
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      SnackBar(
                                                                        duration: const Duration(
                                                                          seconds:
                                                                              2,
                                                                        ),
                                                                        content:
                                                                            Text(
                                                                              "${LocaleKeys.you_must_zoom_on_map_dd_location.tr()}",
                                                                            ),
                                                                      ),
                                                                    );
                                                                    return;
                                                                  }

                                                                  _markers.add(
                                                                    Marker(
                                                                      markerId:
                                                                          const MarkerId(
                                                                            'current_location',
                                                                          ),
                                                                      position: LatLng(
                                                                        argument
                                                                            .latitude,
                                                                        argument
                                                                            .longitude,
                                                                      ),
                                                                    ),
                                                                  );
                                                                  _currentLocation = LatLng(
                                                                    argument
                                                                        .latitude,
                                                                    argument
                                                                        .longitude,
                                                                  );
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                },
                                                                onMapCreated:
                                                                    (
                                                                      GoogleMapController
                                                                      controller,
                                                                    ) {
                                                                      mapController =
                                                                          controller;

                                                                      //    controller.animateCamera(CameraUpdate.newLatLng(LatLng()))
                                                                    },
                                                              ),
                                                            ),
                                                          ),
                                                          ValueListenableBuilder<
                                                            bool
                                                          >(
                                                            valueListenable:
                                                                loadingToGoCurrentLoacation,
                                                            builder:
                                                                (
                                                                  context,
                                                                  _loadingToGoCurrentLoacation,
                                                                  _,
                                                                ) {
                                                                  return Positioned(
                                                                    bottom:
                                                                        120.h,
                                                                    right: 35.w,
                                                                    child:
                                                                        _loadingToGoCurrentLoacation
                                                                        ? Container(
                                                                            width:
                                                                                50.w,
                                                                            height:
                                                                                50.h,
                                                                            color: const Color(
                                                                              0xffFFFFFF,
                                                                            ),
                                                                            child: TrydosLoader(
                                                                              color: const Color(
                                                                                0xff1D1D1D,
                                                                              ),
                                                                              size: 15.h,
                                                                            ),
                                                                          )
                                                                        : InkWell(
                                                                            onTap: () async {
                                                                              var status = await Permission.location.status;

                                                                              if (!status.isGranted) {
                                                                                // إذا لم يكن الإذن ممنوحًا، اطلبه
                                                                                if (await Permission.location.request().isGranted) {
                                                                                  // إذا تم منح الإذن، تابع الحصول على الموقع
                                                                                  _goToCurrentLocation(
                                                                                    latlng: null,
                                                                                  );
                                                                                } else {
                                                                                  // إذا تم رفض الإذن، يمكنك إظهار رسالة للمستخدم
                                                                                  if (kDebugMode) print(
                                                                                    'إذن الموقع مرفوض.',
                                                                                  );
                                                                                }
                                                                              } else {
                                                                                // إذا كان الإذن ممنوحًا، تابع الحصول على الموقع
                                                                                _goToCurrentLocation(
                                                                                  latlng: null,
                                                                                );
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              color: Colors.black12,
                                                                              alignment: Alignment.center,
                                                                              width: 50.w,
                                                                              height: 50.h,
                                                                              child: const Icon(
                                                                                Icons.my_location,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  );
                                                                },
                                                          ),
                                                        ],
                                                      )
                                                    : ValueListenableBuilder<
                                                        bool
                                                      >(
                                                        valueListenable:
                                                            validateBox,
                                                        builder: (context, isValidateBox, _) {
                                                          return Container(
                                                            width: 1.sw,
                                                            margin:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      15.w,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    15.r,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    const Color(
                                                                      0xffD3D3D3,
                                                                    ),
                                                              ),
                                                            ),
                                                            height: 118.h,
                                                            child: Column(
                                                              children: [
                                                                Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      height:
                                                                          80.h,
                                                                      margin:
                                                                          EdgeInsets.all(
                                                                            10.w,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              15.r,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: const Color(
                                                                            0xffD3D3D3,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child: IgnorePointer(
                                                                        child: GoogleMap(
                                                                          zoomControlsEnabled:
                                                                              false,
                                                                          compassEnabled:
                                                                              false,
                                                                          markers:
                                                                              _markersInSmallMap.toSet(),
                                                                          zoomGesturesEnabled:
                                                                              false,
                                                                          initialCameraPosition:
                                                                              _kinitialPosition,
                                                                          onMapCreated:
                                                                              (
                                                                                GoogleMapController
                                                                                controller,
                                                                              ) {
                                                                                mapController = controller;
                                                                              },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        if ((_locationFromSearch?.latitude !=
                                                                                null &&
                                                                            _locationFromSearch?.longitude !=
                                                                                null)) {
                                                                          _goToCurrentLocation(
                                                                            latlng:
                                                                                _locationFromSearch,
                                                                          );
                                                                        }

                                                                        showFulMap.value =
                                                                            true;
                                                                      },
                                                                      child: Container(
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Text(
                                                                              "${LocaleKeys.locate_your_location_on_map.tr()} ",
                                                                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                color: const Color(
                                                                                  0xffF4F4F4,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 12.sp,
                                                                                height: 0.8,
                                                                              ),
                                                                            ),
                                                                            SvgPicture.asset(
                                                                              AppAssets.navigationSvg,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        height:
                                                                            35.h,
                                                                        width:
                                                                            210.w,
                                                                        margin:
                                                                            EdgeInsets.all(
                                                                              10.w,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          color: const Color.fromRGBO(
                                                                            43,
                                                                            44,
                                                                            44,
                                                                            0.7,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(
                                                                            15.r,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  "${LocaleKeys.location_is_accurate_making_it_easy_to_receive_shipments.tr()} ",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mq
                                                                      .copyWith(
                                                                        color: const Color(
                                                                          0xff505050,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        fontSize:
                                                                            12.sp,
                                                                        height:
                                                                            0.8,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                isShowFulMap
                                                    ? SizedBox.fromSize()
                                                    : SizedBox(height: 20.h),
                                                isShowFulMap
                                                    ? SizedBox.fromSize()
                                                    : Container(
                                                        height: 300.h,
                                                        width: 1.sw,
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 15.w,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 15.h,
                                                              width: 120.w,
                                                              margin:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.w,
                                                                  ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    AppAssets
                                                                        .addressInfoSvg,
                                                                  ),
                                                                  Text(
                                                                    "${LocaleKeys.address_info.tr()} ",
                                                                    style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                      color: const Color(
                                                                        0xff404040,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          12.sp,
                                                                      height:
                                                                          LanguageService.languageCode ==
                                                                              "ar"
                                                                          ? 0.8
                                                                          : 1.2,
                                                                    ),
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    AppAssets
                                                                        .chatWithQuestionSvg,
                                                                    // ignore: deprecated_member_use
                                                                    color: const Color(
                                                                      0xffD3D3D3,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10.h,
                                                            ),
                                                            Container(
                                                              height: 50.h,
                                                              width: 1.sw,
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      15.r,
                                                                    ),
                                                                border: Border.all(
                                                                  color: const Color(
                                                                    0xffD3D3D3,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8.w,
                                                                    ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      LocaleKeys
                                                                          .countr_region
                                                                          .tr(),
                                                                      style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                        color: const Color(
                                                                          0xff505050,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        fontSize:
                                                                            12.sp,
                                                                        height:
                                                                            0.8,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          250.w,
                                                                      child: Row(
                                                                        children: [
                                                                          country?.iso?.toUpperCase() ==
                                                                                  "SY"
                                                                              ? SvgPicture.asset(
                                                                                  AppAssets.syriaFlagSvg,
                                                                                  width: 18.w,
                                                                                  height: 18.h,
                                                                                )
                                                                              : Container(
                                                                                  width: 18.w,
                                                                                  height: 18.h,
                                                                                  child: CountryFlag.fromCountryCode(
                                                                                    "${country?.iso}",
                                                                                    height: 18.h,
                                                                                    width: 18.w,
                                                                                    borderRadius: 4.r,
                                                                                  ),
                                                                                ),
                                                                          SizedBox(
                                                                            width:
                                                                                8.w,
                                                                          ),
                                                                          Text(
                                                                            "${country?.name}",
                                                                            style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                              color: const Color(
                                                                                0xff1D1D1D,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              fontSize: 14.sp,
                                                                              height: 1.2,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            ValueListenableBuilder<
                                                              bool
                                                            >(
                                                              valueListenable:
                                                                  validateBox,
                                                              builder:
                                                                  (
                                                                    context,
                                                                    isValidateBox,
                                                                    _,
                                                                  ) {
                                                                    if (isValidateBox &&
                                                                        (finishSelectedByUserToAppear.length ==
                                                                            0)) {
                                                                      animationController
                                                                          .forward();
                                                                      Future.delayed(
                                                                        const Duration(
                                                                          seconds:
                                                                              2,
                                                                        ),
                                                                        () => animationController
                                                                            .reset(),
                                                                      );
                                                                    }
                                                                    return ValueListenableBuilder<
                                                                      bool
                                                                    >(
                                                                      valueListenable:
                                                                          showPanel,
                                                                      builder:
                                                                          (
                                                                            context,
                                                                            _showPanel,
                                                                            _,
                                                                          ) {
                                                                            if (finishSelectedByUser.length >
                                                                                0) {
                                                                              finishSelectedByUserToAppear = [
                                                                                finishSelectedByUser[0].province ??
                                                                                    "",
                                                                                finishSelectedByUser[0].city ??
                                                                                    "",
                                                                                finishSelectedByUser[0].town ??
                                                                                    "",
                                                                                finishSelectedByUser[0].street ??
                                                                                    "",
                                                                                finishSelectedByUser[0].building ??
                                                                                    "",
                                                                              ];
                                                                              finishSelectedByUserToAppear.removeWhere(
                                                                                (
                                                                                  element,
                                                                                ) =>
                                                                                    element ==
                                                                                    "",
                                                                              );
                                                                            }
                                                                            return InkWell(
                                                                              highlightColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              splashColor: Colors.transparent,
                                                                              onTap: () {
                                                                                showShadowForPanel.value = true;
                                                                                showPanel.value = true;
                                                                                panelController.open();
                                                                              },
                                                                              child: AnimatedBuilder(
                                                                                animation: animationController,
                                                                                builder:
                                                                                    (
                                                                                      context,
                                                                                      child,
                                                                                    ) => Transform.translate(
                                                                                      offset: Offset(
                                                                                        !(finishSelectedByUserToAppear.length ==
                                                                                                0)
                                                                                            ? 0
                                                                                            : sin(
                                                                                                    3 *
                                                                                                        2 *
                                                                                                        pi *
                                                                                                        animationController.value,
                                                                                                  ) *
                                                                                                  5,
                                                                                        0,
                                                                                      ),
                                                                                      child:
                                                                                          state.getAddressByCoordinatesStatus ==
                                                                                              GetAddressByCoordinatesStatus.loading
                                                                                          ? Shimmer.fromColors(
                                                                                              baseColor: Colors.grey[500]!,
                                                                                              highlightColor: Colors.grey[200]!,
                                                                                              child: Container(
                                                                                                margin: EdgeInsets.symmetric(
                                                                                                  vertical: 10.h,
                                                                                                ),
                                                                                                width: 1.sw,
                                                                                                height: 58.h,
                                                                                                decoration: BoxDecoration(
                                                                                                  borderRadius: BorderRadius.circular(
                                                                                                    15.r,
                                                                                                  ),
                                                                                                  border: Border.all(
                                                                                                    color:
                                                                                                        (isValidateBox &&
                                                                                                            (finishSelectedByUserToAppear.length ==
                                                                                                                0))
                                                                                                        ? Colors.red
                                                                                                        : const Color(
                                                                                                            0xffD3D3D3,
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                                child: const Padding(
                                                                                                  padding: EdgeInsets.all(
                                                                                                    8.0,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : Container(
                                                                                              margin: EdgeInsets.symmetric(
                                                                                                vertical: 10.h,
                                                                                              ),
                                                                                              width: 1.sw,
                                                                                              height: 60.h,
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(
                                                                                                  15.r,
                                                                                                ),
                                                                                                border: Border.all(
                                                                                                  color:
                                                                                                      (isValidateBox &&
                                                                                                          (finishSelectedByUserToAppear.length ==
                                                                                                              0))
                                                                                                      ? Colors.red
                                                                                                      : const Color(
                                                                                                          0xffD3D3D3,
                                                                                                        ),
                                                                                                ),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.all(
                                                                                                  8.0,
                                                                                                ),
                                                                                                child: Column(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      finishSelectedByUserToAppear.length >
                                                                                                              0
                                                                                                          ? LocaleKeys.change_from_list.tr()
                                                                                                          : LocaleKeys.select_from_list.tr(),
                                                                                                      style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                                        color: const Color(
                                                                                                          0xff505050,
                                                                                                        ),
                                                                                                        letterSpacing: 0.18,
                                                                                                        fontSize: 12.sp,
                                                                                                        height:
                                                                                                            LanguageService.languageCode ==
                                                                                                                "ar"
                                                                                                            ? 0.6
                                                                                                            : 0.5,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Container(
                                                                                                      width: 350.w,
                                                                                                      padding: EdgeInsets.only(
                                                                                                        top: 5.h,
                                                                                                      ),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          SvgPicture.asset(
                                                                                                            AppAssets.detectedSvg,
                                                                                                            // ignore: deprecated_member_use
                                                                                                            color:
                                                                                                                finishSelectedByUserToAppear.length >
                                                                                                                    0
                                                                                                                ? const Color(
                                                                                                                    0xff1D1D1D,
                                                                                                                  )
                                                                                                                : const Color(
                                                                                                                    0xffD3D3D3,
                                                                                                                  ),
                                                                                                            height: 16.h,
                                                                                                          ),
                                                                                                          SizedBox(
                                                                                                            width: 5.w,
                                                                                                          ),
                                                                                                          finishSelectedByUserToAppear.length >
                                                                                                                  0
                                                                                                              ? Container(
                                                                                                                  width: 300.w,
                                                                                                                  height: 20.h,
                                                                                                                  child: ListView.builder(
                                                                                                                    scrollDirection: Axis.horizontal,
                                                                                                                    itemCount: finishSelectedByUserToAppear.length,
                                                                                                                    itemBuilder:
                                                                                                                        (
                                                                                                                          context,
                                                                                                                          index,
                                                                                                                        ) => Text(
                                                                                                                          index ==
                                                                                                                                  finishSelectedByUserToAppear.length -
                                                                                                                                      1
                                                                                                                              ? "${finishSelectedByUserToAppear[index]}."
                                                                                                                              : "${finishSelectedByUserToAppear[index]} | ",
                                                                                                                          style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                                                            color: const Color(
                                                                                                                              0xff1D1D1D,
                                                                                                                            ),
                                                                                                                            letterSpacing: 0.18,
                                                                                                                            fontSize: 14.sp,
                                                                                                                            height: 1.3,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                  ),
                                                                                                                )
                                                                                                              : Text(
                                                                                                                  LocaleKeys.province_district_town_street.tr(),
                                                                                                                  style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                                                    color: const Color(
                                                                                                                      0xffD3D3D3,
                                                                                                                    ),
                                                                                                                    letterSpacing: 0.18,
                                                                                                                    fontSize: 14.sp,
                                                                                                                    height: 0.8,
                                                                                                                  ),
                                                                                                                ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                    ),
                                                                              ),
                                                                            );
                                                                          },
                                                                    );
                                                                  },
                                                            ),
                                                            AddressInfoWidget(
                                                              controller:
                                                                  detailsAddressController,
                                                              context: context,
                                                              isPhone: false,
                                                              isComplate: false,
                                                              height: 73,
                                                              title2: "",
                                                              hint2:
                                                                  '${LocaleKeys.street_address_building_flat_door_unit.tr()}.',
                                                              title: LocaleKeys
                                                                  .detailed_address_note
                                                                  .tr(),
                                                              hint:
                                                                  '${LocaleKeys.write_the_address_clearly_including.tr()}',
                                                            ),
                                                            SizedBox(
                                                              height: 10.h,
                                                            ),
                                                            AddressInfoWidget(
                                                              controller:
                                                                  addressTitleController,
                                                              context: context,
                                                              isPhone: false,
                                                              isComplate: false,
                                                              height: 54,
                                                              title2: "",
                                                              hint2: "",
                                                              title: LocaleKeys
                                                                  .address_title
                                                                  .tr(),
                                                              hint:
                                                                  '${LocaleKeys.ex_home.tr()}',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                isShowFulMap
                                                    ? SizedBox.fromSize()
                                                    : SizedBox(height: 15.h),
                                                isShowFulMap
                                                    ? SizedBox.fromSize()
                                                    : Container(
                                                        height: 300.h,
                                                        width: 1.sw,
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 15.w,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 15.h,
                                                              width: 120.w,
                                                              margin:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.w,
                                                                  ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    AppAssets
                                                                        .personSvg,
                                                                  ),
                                                                  Text(
                                                                    "${LocaleKeys.contact_info.tr()} ",
                                                                    style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                      color: const Color(
                                                                        0xff404040,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          12.sp,
                                                                      height:
                                                                          LanguageService.languageCode ==
                                                                              "ar"
                                                                          ? 1
                                                                          : 1.2,
                                                                    ),
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    AppAssets
                                                                        .chatWithQuestionSvg,
                                                                    // ignore: deprecated_member_use
                                                                    color: const Color(
                                                                      0xffD3D3D3,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10.h,
                                                            ),
                                                            AddressInfoWidget(
                                                              controller:
                                                                  reciptionNameController,
                                                              isPhone: false,
                                                              title2: "",
                                                              context: context,
                                                              isComplate: false,
                                                              height: 54,
                                                              hint2: "",
                                                              title: LocaleKeys
                                                                  .recipient_name
                                                                  .tr(),
                                                              hint:
                                                                  '${LocaleKeys.enter_ful_recipient_name.tr()}',
                                                            ),
                                                            SizedBox(
                                                              height: 10.h,
                                                            ),
                                                            AddressInfoWidget(
                                                              controller:
                                                                  contactPhoneController,
                                                              isPhone: true,
                                                              context: context,
                                                              isComplate: false,
                                                              title2: "",
                                                              height: 54,
                                                              hint2: "",
                                                              title: LocaleKeys
                                                                  .contact_phone
                                                                  .tr(),
                                                              hint:
                                                                  "${LocaleKeys.county_code.tr()} + " +
                                                                  '${LocaleKeys.enter_recipient_phone.tr()}',
                                                            ),
                                                            SizedBox(
                                                              height: 10.h,
                                                            ),
                                                            AddressInfoWidgetOptional(
                                                              height: 54,
                                                              context: context,
                                                              isPhone: true,
                                                              isComplate: false,
                                                              controller:
                                                                  alternativePhoneController,
                                                              hint2: "",
                                                              hint:
                                                                  "${LocaleKeys.county_code.tr()} + " +
                                                                  LocaleKeys
                                                                      .enter_alternative_recipient_phone
                                                                      .tr(),
                                                              title: LocaleKeys
                                                                  .alternative_phone
                                                                  .tr(),
                                                              title2: LocaleKeys
                                                                  .optional
                                                                  .tr(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                SizedBox(height: 20.h),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _showPanel
                                  ? SizedBox.fromSize()
                                  : ValueListenableBuilder<bool>(
                                      valueListenable: showFulMap,
                                      builder: (context, isShowFulMap, _) {
                                        return Container(
                                          height: 100.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(
                                                255,
                                                255,
                                                255,
                                                1,
                                              ),
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 10,
                                                blurStyle: BlurStyle.solid,
                                                color: Color(0xffF1F1F1),
                                              ),
                                            ],
                                            color: const Color.fromRGBO(
                                              255,
                                              255,
                                              255,
                                              1,
                                            ),
                                          ),
                                          width: 1.sw,
                                          child: InkWell(
                                            onTap: () {
                                              validateBox.value = true;
                                              formKey.currentState!.validate();
                                              FocusScope.of(context).unfocus();
                                              Future.delayed(
                                                const Duration(seconds: 2),
                                                () => validateBox.value = false,
                                              );
                                            },
                                            child: isShowFulMap
                                                ? Container(
                                                    height: 70.h,
                                                    width: 1.sw,
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            loadingToGoCurrentLoacation
                                                                    .value =
                                                                false;
                                                            showFulMap.value =
                                                                false;
                                                            _markers = [];
                                                            fromEditeTodenychangeDetailAddress =
                                                                false;
                                                            orderBloc.add(
                                                              GetAddressByCoordinatesEvent(
                                                                latitude:
                                                                    _currentLocation
                                                                        ?.latitude ??
                                                                    0,
                                                                longitude:
                                                                    _currentLocation
                                                                        ?.longitude ??
                                                                    0,
                                                              ),
                                                            );
                                                            /* await getAddressFromCoordinates(
                                                                                                  preLocation!
                                                                                                      .latitude,
                                                                                                  preLocation!
                                                                                                      .longitude)
                                                                                              .then(
                                                                                            (value) {
                                                                                              showFulMap.value =
                                                                                                  false;
                                                                                                 },
                                                                                          ).onError(
                                                                                            (error,
                                                                                                stackTrace) {
                                                                                               },
                                                                                          );*/
                                                          },
                                                          child: Container(
                                                            height: 70.h,
                                                            width: 280.w,
                                                            margin:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      20.w,
                                                                  vertical:
                                                                      10.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20.r,
                                                                  ),
                                                              color:
                                                                  const Color(
                                                                    0xff346BFF,
                                                                  ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                LocaleKeys
                                                                    .select
                                                                    .tr(),
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.mq
                                                                    .copyWith(
                                                                      color: const Color(
                                                                        0xffFEFEFE,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          18.sp,
                                                                      height:
                                                                          0.8,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 20.w),
                                                        InkWell(
                                                          onTap: () {
                                                            showFulMap.value =
                                                                false;
                                                            _currentLocation =
                                                                null;

                                                            _markers = [];
                                                          },
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 50.h,
                                                            width: 70.w,
                                                            child: Text(
                                                              "${LocaleKeys.cansel.tr()} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.mq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        18.sp,
                                                                    height: 1.2,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : ValueListenableBuilder<bool>(
                                                    valueListenable:
                                                        fillAllContainers,
                                                    builder:
                                                        (
                                                          context,
                                                          isFillAllContainers,
                                                          _,
                                                        ) {
                                                          return InkWell(
                                                            onTap: () {
                                                              validateBox
                                                                      .value =
                                                                  true;
                                                              formKey
                                                                  .currentState!
                                                                  .validate();
                                                              FocusScope.of(
                                                                context,
                                                              ).unfocus();
                                                              Future.delayed(
                                                                const Duration(
                                                                  seconds: 2,
                                                                ),
                                                                () =>
                                                                    validateBox
                                                                            .value =
                                                                        false,
                                                              );
                                                              if ((reciptionNameController
                                                                          .text
                                                                          .length >
                                                                      0 &&
                                                                  (finishSelectedByUserToAppear
                                                                          .length) >
                                                                      0 &&
                                                                  addressTitleController
                                                                          .text
                                                                          .length >
                                                                      0 &&
                                                                  detailsAddressController
                                                                          .text
                                                                          .length >
                                                                      0 &&
                                                                  contactPhoneController
                                                                          .text
                                                                          .length >
                                                                      0)) {
                                                                if (!(widget
                                                                        .fromEdid ??
                                                                    false)) {
                                                                  //////////////////////////////////////////

                                                                  List<
                                                                    Map<
                                                                      String,
                                                                      String
                                                                    >
                                                                  >
                                                                  analyticsCartList =
                                                                      [];
                                                                  if (homeBloc
                                                                          .state
                                                                          .cartCollection !=
                                                                      null) {
                                                                    homeBloc.state.cartCollection!.forEach((
                                                                      element,
                                                                    ) {
                                                                      Map<
                                                                        String,
                                                                        String
                                                                      >
                                                                      item = {
                                                                        'item_id': element
                                                                            .productId
                                                                            .toString(),
                                                                        'item_name': element
                                                                            .name
                                                                            .toString(),
                                                                        'quantity': element
                                                                            .quantity
                                                                            .toString(),
                                                                      };

                                                                      analyticsCartList
                                                                          .add(
                                                                            item,
                                                                          );
                                                                    });
                                                                  }
                                                                  /////////////////////////////////
                                                                  /*  Future
                                                                        .delayed(
                                                                      Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      () {
                                                                        FirebaseAnalyticsService
                                                                            .logEventForSession(
                                                                              executedEventName: AnalyticsButtonsEventNameConst.ADDRESS
                                                                              ,
                                                                          eventName:
                                                                              AnalyticsEventsConst.addShippingInfo,
                                                                          extraParams: {
                                                                            'shipping_tier':
                                                                                '',
                                                                            'items':
                                                                                analyticsCartList.toString(),
                                                                          },
                                                                        );
                                                                      },
                                                                    );*/
                                                                  //////////////////////////////////////////
                                                                  orderBloc.add(
                                                                    AddAddressInfoClassEvent(
                                                                      addressInfoClassToSave: address.CustomerAddressesInfo(
                                                                        addressDetail:
                                                                            detailsAddressController.text,
                                                                        contactInfo: address.ContactInfo(
                                                                          alternativePhone:
                                                                              alternativePhoneController.text,
                                                                          name:
                                                                              reciptionNameController.text,
                                                                          phone:
                                                                              contactPhoneController.text,
                                                                        ),
                                                                        address:
                                                                            addressTitleController.text,
                                                                        location: address.Location(
                                                                          latitude:
                                                                              ((_currentLocation?.latitude ??
                                                                                          _locationFromSearch?.latitude) ??
                                                                                      "")
                                                                                  .toString(),
                                                                          longitude:
                                                                              ((_currentLocation?.longitude ??
                                                                                          _locationFromSearch?.longitude) ??
                                                                                      "")
                                                                                  .toString(),
                                                                        ),
                                                                        regionDetails: address.RegionDetails(
                                                                          zip:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].zip
                                                                              : "",
                                                                          building:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].building
                                                                              : "",
                                                                          city:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].city
                                                                              : "",
                                                                          country:
                                                                              "${country?.name}",
                                                                          province:
                                                                              finishSelectedByUser[0].province,
                                                                          street:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].street
                                                                              : "",
                                                                          town:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].town
                                                                              : "",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                } else {
                                                                  orderBloc.add(
                                                                    EditAdressInfoClassEvent(
                                                                      preIdToEdit:
                                                                          widget
                                                                              .addressInfoClassToEdid!
                                                                              .id ??
                                                                          0,
                                                                      addressInfoClassToSave: address.CustomerAddressesInfo(
                                                                        regionDetails: address.RegionDetails(
                                                                          building:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].building
                                                                              : "",
                                                                          zip:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].zip
                                                                              : "",
                                                                          city:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].city
                                                                              : "",
                                                                          country:
                                                                              "${country?.name}",
                                                                          province:
                                                                              finishSelectedByUser[0].province,
                                                                          street:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].street
                                                                              : "",
                                                                          town:
                                                                              finishSelectedByUser.length >
                                                                                  0
                                                                              ? finishSelectedByUser[0].town
                                                                              : "",
                                                                        ),
                                                                        addressDetail:
                                                                            detailsAddressController.text,
                                                                        contactInfo: address.ContactInfo(
                                                                          alternativePhone:
                                                                              alternativePhoneController.text,
                                                                          name:
                                                                              reciptionNameController.text,
                                                                          phone:
                                                                              contactPhoneController.text,
                                                                        ),
                                                                        address:
                                                                            addressTitleController.text,
                                                                        location: address.Location(
                                                                          latitude:
                                                                              _currentLocation?.latitude.toString() ??
                                                                              "",
                                                                          longitude:
                                                                              _currentLocation?.longitude.toString() ??
                                                                              "",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );

                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 54.h,
                                                              margin:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        20.w,
                                                                    vertical:
                                                                        10.h,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20.r,
                                                                    ),
                                                                color:
                                                                    (reciptionNameController.text.length >
                                                                            0 &&
                                                                        (finishSelectedByUserToAppear.length) >
                                                                            0 &&
                                                                        addressTitleController.text.length >
                                                                            0 &&
                                                                        detailsAddressController.text.length >
                                                                            0 &&
                                                                        contactPhoneController.text.length >
                                                                            0)
                                                                    ? const Color(
                                                                        0xff346BFF,
                                                                      )
                                                                    : const Color(
                                                                        0xffC4C2C2,
                                                                      ),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  (widget.fromEdid ??
                                                                          false)
                                                                      ? LocaleKeys
                                                                            .save
                                                                            .tr()
                                                                      : LocaleKeys
                                                                            .add_save
                                                                            .tr(),
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mq
                                                                      .copyWith(
                                                                        color: const Color(
                                                                          0xffFEFEFE,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        fontSize:
                                                                            18.sp,
                                                                        height:
                                                                            0.8,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: showShadowForPanel,
                            builder: (context, isShowShadowForPanel, _) {
                              return !isShowShadowForPanel
                                  ? const SizedBox.shrink()
                                  : InkWell(
                                      onTap: () {
                                        showShadowForPanel.value = false;
                                        Future.delayed(
                                          const Duration(microseconds: 300),
                                          () {
                                            panelController.close();
                                            showShadowForPanel.value = false;
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 1.sh,
                                        width: 1.sw,
                                        color: const Color.fromRGBO(
                                          29,
                                          29,
                                          29,
                                          0.6,
                                        ),
                                      ),
                                    );
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: showPanel,
                            builder: (context, isShowPanel, _) {
                              return BlocBuilder<OrderBloc, OrderState>(
                                buildWhen: (p, c) =>
                                    p.getAddressByTextStatus !=
                                    c.getAddressByTextStatus,
                                builder: (context, orderState) {
                                  filterResultSearch = [];
                                  filterLatLngSearch = [];
                                  orderState.resultSearch?.forEach((element) {
                                    filterResultSearch.add(
                                      address.RegionDetails(
                                        zip: element.zip ?? "",
                                        building: element.building,
                                        city: element.city,
                                        country: "",
                                        province: element.province,
                                        street: element.street,
                                        town: element.town,
                                      ),
                                    );
                                    filterLatLngSearch.add(
                                      LatLng(
                                        element.coordinates?[0].lat ?? 0,
                                        element.coordinates?[0].lon ?? 0,
                                      ),
                                    );
                                  });
                                  return ValueListenableBuilder<List<String>>(
                                    valueListenable:
                                        listOfAddressTilteSeletedByUser,
                                    builder: (context, addressTilteSeletedByUser, _) {
                                      if (listOfAddressTilteSeletedByUser
                                              .value
                                              .length >
                                          0) {
                                        panelController.close();
                                      }
                                      return Positioned(
                                        bottom: 0,
                                        child: Container(
                                          width: 1.sw,
                                          height: isShowPanel ? 500.h : 0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30.r),
                                              topRight: Radius.circular(30.r),
                                            ),
                                          ),
                                          child: BlocBuilder<HomeBloc, HomeState>(
                                            buildWhen: (p, c) =>
                                                p.getCartItemsStatus !=
                                                c.getCartItemsStatus,
                                            builder: (context, homeState) {
                                              return SlidingUpPanel(
                                                controller: panelController,
                                                borderRadius:
                                                    ((homeState.cartCollection ==
                                                            null ||
                                                        homeState
                                                            .cartCollection!
                                                            .isEmpty))
                                                    ? null
                                                    : BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              30.r,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              30.r,
                                                            ),
                                                      ),
                                                onPanelClosed: () {
                                                  finishSelectedByUser = [
                                                    address.RegionDetails(
                                                      province:
                                                          addressTilteSeletedByUser
                                                                  .length >
                                                              0
                                                          ? addressTilteSeletedByUser[0]
                                                          : "",
                                                      city:
                                                          addressTilteSeletedByUser
                                                                  .length >
                                                              1
                                                          ? addressTilteSeletedByUser[1]
                                                          : "",
                                                      town:
                                                          addressTilteSeletedByUser
                                                                  .length >
                                                              2
                                                          ? addressTilteSeletedByUser[2]
                                                          : "",
                                                      street:
                                                          addressTilteSeletedByUser
                                                                  .length >
                                                              3
                                                          ? addressTilteSeletedByUser[3]
                                                          : "",
                                                      building:
                                                          addressTilteSeletedByUser
                                                                  .length >
                                                              4
                                                          ? addressTilteSeletedByUser[4]
                                                          : "",
                                                      zip:
                                                          addressTilteSeletedByUser
                                                                  .length >
                                                              5
                                                          ? addressTilteSeletedByUser[5]
                                                          : "",
                                                    ),
                                                  ];

                                                  searchController.text = "";
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();
                                                  showShadowForPanel.value =
                                                      false;
                                                  showPanel.value = false;
                                                  listOfAddressTilteSeletedByUser
                                                          .value =
                                                      [];
                                                  fillAllContainers.value =
                                                      !fillAllContainers.value;
                                                },
                                                onPanelOpened: () {},
                                                minHeight: 0,
                                                maxHeight: 500.h,
                                                panelBuilder: (sc) => Container(
                                                  height: 500.h,
                                                  width: 1.sw,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Center(
                                                        child: Container(
                                                          width: 150.w,
                                                          height: 25.h,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .detectedSvg,
                                                                height: 16.h,
                                                                // ignore: deprecated_member_use
                                                                color:
                                                                    const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                              ),
                                                              Text(
                                                                "  ${LocaleKeys.select_from_list.tr()} ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.rq
                                                                    .copyWith(
                                                                      color: const Color(
                                                                        0xff1D1D1D,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          14.sp,
                                                                      height:
                                                                          1.2,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      Container(
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 10.w,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 18.w,
                                                              height: 18.h,
                                                              child:
                                                                  country?.iso
                                                                          ?.toUpperCase() ==
                                                                      "SY"
                                                                  ? SvgPicture.asset(
                                                                      AppAssets
                                                                          .syriaFlagSvg,
                                                                      width:
                                                                          18.w,
                                                                      height:
                                                                          18.h,
                                                                    )
                                                                  : CountryFlag.fromCountryCode(
                                                                      "${country?.iso}",
                                                                      height:
                                                                          18.h,
                                                                      width:
                                                                          18.w,
                                                                      borderRadius:
                                                                          4.r,
                                                                    ),
                                                            ),
                                                            Text(
                                                              " ${country?.name} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        14.sp,
                                                                    height: 1.2,
                                                                  ),
                                                            ),
                                                            addressTilteSeletedByUser
                                                                        .length ==
                                                                    0
                                                                ? Text(
                                                                    " | ${LocaleKeys.province.tr()}",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.mq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                  )
                                                                : Text(
                                                                    " | ${addressTilteSeletedByUser[0]}",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                  ),
                                                            addressTilteSeletedByUser
                                                                        .length <=
                                                                    1
                                                                ? Text(
                                                                    " | ${LocaleKeys.district.tr()}",
                                                                    style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                      color:
                                                                          addressTilteSeletedByUser.length ==
                                                                              1
                                                                          ? const Color(
                                                                              0xff1D1D1D,
                                                                            )
                                                                          : const Color(
                                                                              0xffD3D3D3,
                                                                            ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          14.sp,
                                                                      height:
                                                                          1.2,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    " | ${addressTilteSeletedByUser[1]}",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                  ),
                                                            addressTilteSeletedByUser
                                                                        .length <=
                                                                    2
                                                                ? Text(
                                                                    " | ${LocaleKeys.town.tr()}",
                                                                    style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                      color:
                                                                          addressTilteSeletedByUser.length ==
                                                                              2
                                                                          ? const Color(
                                                                              0xff1D1D1D,
                                                                            )
                                                                          : const Color(
                                                                              0xffD3D3D3,
                                                                            ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          14.sp,
                                                                      height:
                                                                          1.2,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    " | ${addressTilteSeletedByUser[2]}",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                  ),
                                                            addressTilteSeletedByUser
                                                                        .length <=
                                                                    3
                                                                ? Text(
                                                                    " | ${LocaleKeys.street.tr()}",
                                                                    style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                      color:
                                                                          addressTilteSeletedByUser.length ==
                                                                              3
                                                                          ? const Color(
                                                                              0xff1D1D1D,
                                                                            )
                                                                          : const Color(
                                                                              0xffD3D3D3,
                                                                            ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          14.sp,
                                                                      height:
                                                                          1.2,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    " | ${addressTilteSeletedByUser[3]}",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 10.w,
                                                            ),
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 15.w,
                                                            ),
                                                        height: 40.h,
                                                        width: 1.sw,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.r,
                                                              ),
                                                          color: const Color(
                                                            0xffF8F8F8,
                                                          ),
                                                        ),
                                                        child: AppTextField(
                                                          textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                          onChange: (val) {
                                                            if (val.length >
                                                                1) {
                                                              orderBloc.add(
                                                                GetAddressByTextEvent(
                                                                  reset: false,
                                                                  query: val,
                                                                ),
                                                              );
                                                            } else {
                                                              orderBloc.add(
                                                                GetAddressByTextEvent(
                                                                  reset: true,
                                                                  query: val,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          onTap: () {},
                                                          controller:
                                                              searchController,
                                                          onFieldSubmitted:
                                                              (val) {
                                                                FocusScope.of(
                                                                  context,
                                                                ).unfocus();
                                                              },
                                                          contentPadding:
                                                              const EdgeInsets.only(),
                                                          filledColor:
                                                              const Color(
                                                                0xffF8F8F8,
                                                              ),
                                                          bordersColor:
                                                              const Color(
                                                                0xffF8F8F8,
                                                              ),
                                                          icon:
                                                              orderState
                                                                      .getAddressByTextStatus ==
                                                                  GetAddressByTextStatus
                                                                      .loading
                                                              ? Container(
                                                                  width: 15,
                                                                  height: 15,
                                                                  child:
                                                                      TrydosLoader(
                                                                        size:
                                                                            12,
                                                                      ),
                                                                )
                                                              : SvgPicture.asset(
                                                                  AppAssets
                                                                      .searchOutlinedSvg,
                                                                  height: 18,
                                                                  width: 18,
                                                                  // ignore: deprecated_member_use
                                                                  color: const Color(
                                                                    0xff388CFF,
                                                                  ),
                                                                ),
                                                          hintText:
                                                              "${LocaleKeys.search.tr()} ${LocaleKeys.province_district_town_street.tr()}",
                                                          hintTextStyle: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.lq
                                                              .copyWith(
                                                                color:
                                                                    const Color(
                                                                      0xffC4C2C2,
                                                                    ),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 14.sp,
                                                                height: 0.8,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5.h),
                                                      Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        height: 260.h,
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 15.w,
                                                            ),
                                                        child: ListView.separated(
                                                          controller: sc,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                          itemBuilder: (context, index) {
                                                            String
                                                            apprearfilterResultSearch =
                                                                "";
                                                            if ((searchController
                                                                    .text
                                                                    .length) >
                                                                0) {
                                                              apprearfilterResultSearch =
                                                                  " ${filterResultSearch[index].province ?? ""} ${filterResultSearch[index].city ?? ""} ${filterResultSearch[index].town ?? ""} ${filterResultSearch[index].street ?? ""} ${filterResultSearch[index].street ?? ""} ${filterResultSearch[index].building ?? ""}";
                                                            }

                                                            return InkWell(
                                                              onTap: () {
                                                                if ((searchController
                                                                        .text
                                                                        .length) >
                                                                    0) {
                                                                  _locationFromSearch =
                                                                      filterLatLngSearch[index];
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                  address.RegionDetails
                                                                  filterSearchTadd =
                                                                      filterResultSearch[index];
                                                                  listOfAddressTilteSeletedByUser
                                                                      .value = [
                                                                    ...[
                                                                      filterSearchTadd
                                                                              .province ??
                                                                          "",
                                                                      filterSearchTadd
                                                                              .city ??
                                                                          "",
                                                                      filterSearchTadd
                                                                              .town ??
                                                                          "",
                                                                      filterSearchTadd
                                                                              .street ??
                                                                          "",
                                                                      filterSearchTadd
                                                                              .building ??
                                                                          "",
                                                                      filterSearchTadd
                                                                              .zip ??
                                                                          "",
                                                                    ],
                                                                  ];
                                                                  panelController
                                                                      .close();
                                                                } else {
                                                                  listOfAddressTilteSeletedByUser
                                                                      .value = [
                                                                    ...addressTilteSeletedByUser,
                                                                    addressTilte[index],
                                                                  ];
                                                                }
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          35.w,
                                                                    ),
                                                                alignment:
                                                                    LanguageService
                                                                            .languageCode ==
                                                                        "ar"
                                                                    ? Alignment
                                                                          .centerRight
                                                                    : Alignment
                                                                          .centerLeft,
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.mq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                    text:
                                                                        (searchController.text.length) >
                                                                            0
                                                                        ? apprearfilterResultSearch.substring(
                                                                            0,
                                                                            (searchController.text.length),
                                                                          )
                                                                        : addressTilte[index],
                                                                    children: [
                                                                      TextSpan(
                                                                        style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                          color: const Color(
                                                                            0xff8D8D8D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14.sp,
                                                                          height:
                                                                              1.2,
                                                                        ),
                                                                        text:
                                                                            (searchController.text.length) >
                                                                                0
                                                                            ? apprearfilterResultSearch.substring(
                                                                                searchController.text.length,
                                                                              )
                                                                            : "",
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(
                                                                    0xffF8F8F8,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12.r,
                                                                      ),
                                                                ),
                                                                height: 50.h,
                                                              ),
                                                            );
                                                          },
                                                          separatorBuilder:
                                                              (
                                                                context,
                                                                index,
                                                              ) =>
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                          itemCount:
                                                              (searchController
                                                                      .text
                                                                      .length) >
                                                                  0
                                                              ? filterResultSearch
                                                                    .length
                                                              : addressTilte
                                                                    .length,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/*class AddressInfoClassToSave {
  final String? id;
  final String? recipientName;
  final String? contactPhone;
  final String? addressTitle;
  final String? detailedAddress;
  final String? province;
  final String? alternativePhone;
  final String? district;
  final String? town;
  final String? street;
  final String? country;
  AddressInfoClassToSave({
    this.id,
    this.recipientName,
    this.contactPhone,
    this.addressTitle,
    this.detailedAddress,
    this.province,
    this.alternativePhone,
    this.district,
    this.town,
    this.street,
    this.country,
  });

  AddressInfoClassToSave copyWith(
          {final String? id,
          final String? recipientName,
          final String? contactPhone,
          final String? addressTitle,
          final String? detailedAddress,
          final String? province,
          final String? district,
          final String? town,
          final String? street,
          final String? country}) =>
      AddressInfoClassToSave(
          id: id ?? this.id,
          recipientName: recipientName ?? this.recipientName,
          contactPhone: contactPhone ?? this.contactPhone,
          addressTitle: addressTitle ?? this.addressTitle,
          detailedAddress: detailedAddress ?? this.detailedAddress,
          province: province ?? this.province,
          district: district ?? this.district,
          town: town ?? this.town,
          street: street ?? this.street,
          country: country ?? this.country);
  factory AddressInfoClassToSave.fromJson(Map<String, dynamic> json) =>
      AddressInfoClassToSave(
        id: json["id"],
        recipientName: json["recipient_name"],
        contactPhone: json[" contact_phone"],
        addressTitle: json["address_title"],
        detailedAddress: json["detaile_address"],
        province: json["province"],
        district: json["district"],
        town: json["town"],
        street: json["street"],
        country: json["country"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "recipient_name": recipientName,
        " contact_phone": contactPhone,
        "address_title": addressTitle,
        "detaile_address": detailedAddress,
        "province": province,
        "district": district,
        "town": town,
        "street": street,
        "country": country,
      };
}
*/
