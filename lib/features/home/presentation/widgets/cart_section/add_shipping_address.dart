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
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class AddShippingAdress extends StatefulWidget {
  const AddShippingAdress(
      {Key? key, this.addressInfoClassToEdid, this.fromEdid = false});
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
  List<String> addressTilte = [
    "Istanbul",
    "Ankara",
    "Adana",
    "Mersin",
    "Antalya",
    "Istanbul",
    "Ankara",
    "Adana",
    "Mersin",
    "Antalya"
  ];

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
  final TextEditingController alternativePhoneController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late GoogleMapController mapController;

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
  bool? fromEditeTodenychangeDetailAddress;
  Future<void> _goToCurrentLocation({required LatLng? latlng}) async {
    Location location = new Location();
    LocationData currentLocation;
    loadingToGoCurrentLoacation.value = true;
    try {
      if (latlng?.latitude != null && latlng?.longitude != null) {
        _currentLocation = latlng!;
      } else {
        currentLocation =
            await location.getLocation().timeout(Duration(seconds: 15));
        _currentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      }
      await Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId('current_location'),
            position: _currentLocation!,
            infoWindow: InfoWindow(title: 'موقعي الحالي'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed), // علامة حمراء
          ));
        });
      });
      // إضافة علامة حمراء في الموقع الحالي

      // تحريك الكاميرا إلى الموقع الحالي
      mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
      loadingToGoCurrentLoacation.value = false;
    } catch (e) {
      loadingToGoCurrentLoacation.value = false;
      print('خطأ في الحصول على الموقع: $e');
    }
  }

  @override
  void initState() {
    fromEditeTodenychangeDetailAddress = widget.fromEdid ?? false;
    homeBloc = BlocProvider.of<HomeBloc>(context);
    alowCountries = homeBloc.state.getAllowedCountriesModel?.data?.countries;

    choosedCountry = GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
        ? GetIt.I<PrefsRepository>().userChoosedCountryIso
        : GetIt.I<PrefsRepository>().countryIso;
    country = alowCountries?.firstWhere(
        (element) => '${choosedCountry?.toLowerCase()}'
            .startsWith(element.iso!.toLowerCase()),
        orElse: () => alowCountries![0]);

    _markersInSmallMap = [
      Marker(
          markerId: MarkerId("initial"),
          position: LatLng(double.tryParse(country?.latitude ?? "0") ?? 0,
              double.tryParse(country?.longitude ?? "0") ?? 0))
    ];
    //_currentLocation = LatLng(double.tryParse(country?.latitude ?? "0") ?? 0,
    //    double.tryParse(country?.longitude ?? "0") ?? 0);

    if (widget.fromEdid ?? false) {
      _currentLocation = LatLng(
          double.tryParse(widget.addressInfoClassToEdid!.location!.latitude!)!,
          double.tryParse(
              widget.addressInfoClassToEdid!.location!.longitude!)!);
      _kinitialPosition = CameraPosition(
          bearing: 0, target: _currentLocation!, tilt: 0, zoom: 8);
      _goToCurrentLocation(latlng: _currentLocation);
      if (alternativePhoneController.text.length > 0) {
        visiblePrefixOptional.value = true;
      }
      if (contactPhoneController.text.length > 0) {
        visiblePrefix.value = true;
      }
      if (alternativePhoneController.text.length > 0) {
        visiblePrefixOptional.value = true;
      }
      _locationFromSearch = LatLng(
          double.tryParse(widget.addressInfoClassToEdid!.location!.latitude!)!,
          double.tryParse(
              widget.addressInfoClassToEdid!.location!.longitude!)!);
      contactPhoneController.text =
          widget.addressInfoClassToEdid?.contactInfo?.phone ?? "";
      detailsAddressController.text =
          widget.addressInfoClassToEdid?.addressDetail ?? "";
      addressTitleController.text =
          widget.addressInfoClassToEdid?.address ?? "";
      alternativePhoneController.text =
          widget.addressInfoClassToEdid?.contactInfo?.alternativePhone ?? "";
      reciptionNameController.text =
          widget.addressInfoClassToEdid?.contactInfo?.name ?? "";
      finishSelectedByUser = [
        address.RegionDetails(
            building:
                widget.addressInfoClassToEdid?.regionDetails?.building ?? "",
            city: widget.addressInfoClassToEdid?.regionDetails?.city ?? "",
            country: "",
            province:
                widget.addressInfoClassToEdid?.regionDetails?.province ?? "",
            street: widget.addressInfoClassToEdid?.regionDetails?.street ?? "",
            town: widget.addressInfoClassToEdid?.regionDetails?.town ?? "")
      ];
      if (alternativePhoneController.text.length > 0) {
        visiblePrefixOptional.value = true;
      }
      if (contactPhoneController.text.length > 0) {
        visiblePrefix.value = true;
      }
    } else {
      _kinitialPosition = CameraPosition(
          bearing: 0,
          target: LatLng(double.tryParse(country?.latitude ?? "0") ?? 0,
              double.tryParse(country?.longitude ?? "0") ?? 0),
          tilt: 0,
          zoom: 6);
      //   _goToCurrentLocation(latlng: _currentLocation);
    }
    // appBloc = BlocProvider.of<AppBloc>(context);

    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
  }

  @override
  void didChangeDependencies() {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.cartScreen,
    );
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
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

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

    Widget AddressInfoWidget(
        {required String title,
        required String title2,
        required String hint,
        required String hint2,
        required bool isPhone,
        required TextEditingController controller,
        required bool isComplate,
        required int height,
        required BuildContext context}) {
      return ValueListenableBuilder<bool>(
          valueListenable: validateBox,
          builder: (context, isValidateBox, _) {
            if (isValidateBox && controller.text.isNullOrEmpty) {
              animationController.forward();
              Future.delayed(
                Duration(seconds: 2),
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
                          0),
                      child: Container(
                        height: height.toDouble(),
                        width: 1.sw,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                                color: (isValidateBox &&
                                        controller.text.isNullOrEmpty)
                                    ? Colors.red
                                    : Color(0xffD3D3D3))),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(top: 5, left: 8, right: 8),
                                height: 18,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: context.textTheme.bodyMedium?.rr
                                          .copyWith(
                                              color: const Color(0xff505050),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
                                              height: LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? 0.5
                                                  : 0.8),
                                    ),
                                    title2 == ""
                                        ? SizedBox.shrink()
                                        : Text(
                                            " (${LocaleKeys.optional.tr()})",
                                            style: context
                                                .textTheme.bodyMedium?.rr
                                                .copyWith(
                                                    color:
                                                        const Color(0xffD3D3D3),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12,
                                                    height: 0.8),
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
                                            builder: (context,
                                                _maxLengthForNumber, _) {
                                              return AppTextField(
                                                controller: controller,
                                                prefix: isVisiblePrefix
                                                    ? Text("+",
                                                        style: context.textTheme
                                                            .bodyMedium?.mr
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xff1D1D1D),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 16,
                                                                height: 0.8))
                                                    : SizedBox.shrink(),
                                                textInputType:
                                                    TextInputType.phone,
                                                bordersColor: Colors.white,
                                                isErrorBorder: false,
                                                maxLength: _maxLengthForNumber,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9\s]'))
                                                ],
                                                textInputAction:
                                                    TextInputAction.done,
                                                onChange: (val) {
                                                  fillAllContainers.value =
                                                      !fillAllContainers.value;
                                                  if (val.length > 0 &&
                                                      isPhone) {
                                                    visiblePrefix.value = true;
                                                  } else if (val.length == 0 &&
                                                      isPhone) {
                                                    visiblePrefix.value = false;
                                                  }

                                                  Country newCountry = countries.firstWhere(
                                                      (element) =>
                                                          '+${val.toLowerCase()}'
                                                              .startsWith(element
                                                                  .dialCode
                                                                  .toLowerCase()),
                                                      orElse: () => Country(
                                                          name: '',
                                                          flag: '',
                                                          code: '',
                                                          dialCode: '',
                                                          minLength: 0,
                                                          maxLength: 0));
                                                  if (newCountry.code != "") {
                                                    String formattedText =
                                                        _formatNumber(
                                                            val,
                                                            newCountry.dialCode
                                                                .split("+")
                                                                .toList()[1]);
                                                    controller.value =
                                                        TextEditingValue(
                                                      text: formattedText,
                                                    );
                                                  }
                                                  if (newCountry.code != "") {
                                                    int spaces = ((newCountry
                                                                .maxLength) /
                                                            3)
                                                        .floor();
                                                    if (newCountry.maxLength %
                                                            3 ==
                                                        0) {
                                                      spaces--;
                                                    }
                                                    maxLengthForNumber.value =
                                                        newCountry.maxLength +
                                                            newCountry.dialCode
                                                                .length +
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
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                hintText: '${hint}' +
                                                    "${hint2 == "" ? "" : "\n${hint2}"}",
                                                contentPadding:
                                                    HWEdgeInsetsDirectional.only(
                                                        start: (LanguageService
                                                                    .languageCode !=
                                                                "ar")
                                                            ? 8
                                                            : 8,
                                                        end: 1,
                                                        bottom: 1,
                                                        top: 1),
                                                textAlign: TextAlign.start,
                                                maxLines: hint2 == "" ? 1 : 2,
                                                minLines: 1,
                                                textStyle: context
                                                    .textTheme.bodyMedium?.mr
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff1D1D1D),
                                                        letterSpacing: 0.18,
                                                        fontSize: 14,
                                                        height: 1.1),
                                                hintTextStyle: context
                                                    .textTheme.bodyMedium?.rr
                                                    .copyWith(
                                                        color: const Color(
                                                            0xffD3D3D3),
                                                        letterSpacing: 0.18,
                                                        fontSize: 14,
                                                        height: hint2 == ""
                                                            ? 1
                                                            : 1.3),
                                              );
                                            }),
                                      )
                                    : AppTextField(
                                        controller: controller,
                                        textInputType: TextInputType.text,
                                        bordersColor: Colors.white,
                                        isErrorBorder: false,
                                        inputFormatters: !isPhone
                                            ? null
                                            : [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9\s]'))
                                              ],
                                        textInputAction: TextInputAction.done,
                                        onChange: (val) {
                                          fillAllContainers.value =
                                              !fillAllContainers.value;
                                          if (val.length > 0 && isPhone) {
                                            visiblePrefix.value = true;
                                          } else if (val.length == 0 &&
                                              isPhone) {
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
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        hintText: '${hint}' +
                                            "${hint2 == "" ? "" : "\n${hint2}"}",
                                        contentPadding:
                                            HWEdgeInsetsDirectional.only(
                                                start: 8,
                                                end: 1,
                                                bottom: 1,
                                                top: 1),
                                        textAlign: TextAlign.start,
                                        maxLines: hint2 == "" ? 1 : 2,
                                        minLines: 1,
                                        textStyle: context
                                            .textTheme.bodyMedium?.mr
                                            .copyWith(
                                                color: const Color(0xff1D1D1D),
                                                letterSpacing: 0.18,
                                                fontSize: 14,
                                                height: 1.1),
                                        hintTextStyle: context
                                            .textTheme.bodyMedium?.rr
                                            .copyWith(
                                                color: const Color(0xffD3D3D3),
                                                letterSpacing: 0.18,
                                                fontSize: 14,
                                                height: hint2 == "" ? 1 : 1.3),
                                      ),
                              ),
                            ] /**Column(
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
                });
          });
    }

    Future<void> getAddressFromCoordinates(
        double latitude, double longitude) async {
      /* List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude).onError(
        (error, stackTrace) {
          showFulMap.value = false;
          return [];
        },
      );
      Placemark place = placemarks[0];
      print("111${place.administrativeArea ?? "  "}");

      print("22${place.name ?? "  "}3");

      print("33${place.locality ?? place.subLocality ?? " "}");

      print("44${place.street ?? place.thoroughfare ?? " "}");

      finishSelectedByUser = [
        place.administrativeArea ?? "  ",
        place.subLocality ?? "  ",
        place.locality ?? place.subLocality ?? " ",
        place.street?.split(",")[0] ?? place.thoroughfare ?? " "
      ];*/
    }

    Widget AddressInfoWidgetOptional(
        {required String title,
        required String title2,
        required String hint,
        required String hint2,
        required bool isPhone,
        required TextEditingController controller,
        required bool isComplate,
        required int height,
        required BuildContext context}) {
      return ValueListenableBuilder<bool>(
          valueListenable: validateBox,
          builder: (context, isValidateBox, _) {
            if (isValidateBox && controller.text.isNullOrEmpty) {
              animationController.forward();
              Future.delayed(
                Duration(seconds: 2),
                () => animationController.reset(),
              );
            }
            return ValueListenableBuilder<bool>(
                valueListenable: visiblePrefixOptional,
                builder: (context, isVisiblePrefixOptional, _) {
                  return Container(
                    height: height.toDouble(),
                    width: 1.sw,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Color(0xffD3D3D3))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 5, left: 8, right: 8),
                            height: 18,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: context.textTheme.bodyMedium?.rr
                                      .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 12,
                                          height:
                                              LanguageService.languageCode ==
                                                      "ar"
                                                  ? 0.5
                                                  : 0.8),
                                ),
                                title2 == ""
                                    ? SizedBox.shrink()
                                    : Text(
                                        " (${LocaleKeys.optional.tr()})",
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                                color: const Color(0xffD3D3D3),
                                                letterSpacing: 0.18,
                                                fontSize: 12,
                                                height: 0.8),
                                      ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ValueListenableBuilder<int>(
                                  valueListenable: maxLengthForOptionalNumber,
                                  builder: (context,
                                      _maxLengthForOptionalNumber, _) {
                                    return AppTextField(
                                      controller: controller,
                                      prefix: isPhone && isVisiblePrefixOptional
                                          ? Text("+",
                                              style: context
                                                  .textTheme.bodyMedium?.mr
                                                  .copyWith(
                                                      color: const Color(
                                                          0xff1D1D1D),
                                                      letterSpacing: 0.18,
                                                      fontSize: 16,
                                                      height: 0.8))
                                          : SizedBox.shrink(),
                                      textInputType: isPhone
                                          ? TextInputType.numberWithOptions()
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
                                                  15), // يمكنك تحديد الحد الأقصى لعدد الأرقام
                                            ],
                                      textInputAction: TextInputAction.done,
                                      onChange: (val) {
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
                                        Country newCountry = countries
                                            .firstWhere(
                                                (element) =>
                                                    '+${val.toLowerCase()}'
                                                        .startsWith(element
                                                            .dialCode
                                                            .toLowerCase()),
                                                orElse: () => Country(
                                                    name: '',
                                                    flag: '',
                                                    code: '',
                                                    dialCode: '',
                                                    minLength: 0,
                                                    maxLength: 0));
                                        if (newCountry.code != "") {
                                          String formattedText = _formatNumber(
                                              val,
                                              newCountry.dialCode
                                                  .split("+")
                                                  .toList()[1]);
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
                                          maxLengthForOptionalNumber.value =
                                              newCountry.maxLength +
                                                  newCountry.dialCode.length +
                                                  spaces;
                                        }
                                        fillAllContainers.value =
                                            !fillAllContainers.value;
                                        if (val.length > 0 && isPhone) {
                                          visiblePrefixOptional.value = true;
                                        } else if (val.length == 0 && isPhone) {
                                          visiblePrefixOptional.value = false;
                                        }
                                      },
                                      onTap: () {},
                                      onFieldSubmitted: (val) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      hintText: '${hint}' +
                                          "${hint2 == "" ? "" : "\n${hint2}"}",
                                      contentPadding:
                                          HWEdgeInsetsDirectional.only(
                                              start: 8,
                                              end: 1,
                                              bottom: 1,
                                              top: 1),
                                      textAlign: TextAlign.start,
                                      maxLines: hint2 == "" ? 1 : 2,
                                      minLines: 1,
                                      textStyle: context
                                          .textTheme.bodyMedium?.mr
                                          .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 14,
                                              height: 1.1),
                                      hintTextStyle: context
                                          .textTheme.bodyMedium?.rr
                                          .copyWith(
                                              color: const Color(0xffD3D3D3),
                                              letterSpacing: 0.18,
                                              fontSize: 14,
                                              height: hint2 == "" ? 1 : 1.3),
                                    );
                                  }),
                            ),
                          ),
                        ] /**Column(
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
                });
          });
    }

    return WillPopScope(
        onWillPop: () async {
          // didCallOnWillPop = true;
          if (showFulMap.value == true) {
            showFulMap.value = false;
            loadingToGoCurrentLoacation.value = false;
            return false;
          }
          if (Navigator.canPop(context)) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();

              return false;
              // منع الإغلاق بعد تنفيذ pop
            }

            // يسمح بالإغلاق إذا لم تنطبق أي من الشروط
          }
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return ValueListenableBuilder<bool>(
                    valueListenable: showPanel,
                    builder: (context, _showPanel, _) {
                      return Form(
                        key: formKey,
                        child: BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (previous, current) =>
                              previous.getAddressByCoordinatesStatus !=
                              current.getAddressByCoordinatesStatus,
                          builder: (context, state) {
                            if (state.getAddressByCoordinatesStatus ==
                                    GetAddressByCoordinatesStatus.success &&
                                !((fromEditeTodenychangeDetailAddress ??
                                    false)) &&
                                state.getAddressByCoordinatesModel?.data
                                        ?.province !=
                                    null) {
                              finishSelectedByUser = [
                                address.RegionDetails(
                                  building: state.getAddressByCoordinatesModel
                                          ?.data?.building ??
                                      "",
                                  city: state.getAddressByCoordinatesModel?.data
                                          ?.city ??
                                      "",
                                  country: "",
                                  province: state.getAddressByCoordinatesModel
                                          ?.data?.province ??
                                      "",
                                  street: state.getAddressByCoordinatesModel
                                          ?.data?.street ??
                                      "",
                                  town: state.getAddressByCoordinatesModel?.data
                                          ?.town ??
                                      "",
                                )
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
                                                  loadingToGoCurrentLoacation
                                                      .value = false;
                                                  showFulMap.value = false;
                                                  return;
                                                }
                                                // didCallOnWillPop = true;
                                                if (Navigator.canPop(context)) {
                                                  if (Navigator.of(context)
                                                      .canPop()) {
                                                    Navigator.of(context).pop();
                                                    return;
                                                    // منع الإغلاق بعد تنفيذ pop
                                                  }

                                                  // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                                  return;
                                                } else {}
                                              },
                                              child: Container(
                                                  width: 40,
                                                  child: Transform.rotate(
                                                    angle: LanguageService
                                                                .languageCode ==
                                                            "ar"
                                                        ? pi
                                                        : 0,
                                                    child: SvgPicture.asset(
                                                      AppAssets
                                                          .backIconArrowSvg,
                                                      height: 20,
                                                    ),
                                                  )),
                                            ),
                                            Spacer(),
                                            Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    height: 18,
                                                    AppAssets
                                                        .addShippingAddressSvg,
                                                  ),
                                                  Positioned(
                                                    height: 18,
                                                    top: -2,
                                                    child: SvgPicture.asset(
                                                      AppAssets
                                                          .addShippingAddressWhiteSvg,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5.w,
                                            ),
                                            Text(
                                                "${LocaleKeys.add_shipping_address.tr()} ",
                                                style: context
                                                    .textTheme.bodyMedium?.mr
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff1D1D1D),
                                                        letterSpacing: 0.2,
                                                        fontSize: 14,
                                                        height: 1.33)),
                                            SizedBox(
                                              width: 120.w,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ValueListenableBuilder<bool>(
                                          valueListenable: showFulMap,
                                          builder: (context, isShowFulMap, _) {
                                            return Scaffold(
                                              resizeToAvoidBottomInset: true,
                                              body: SingleChildScrollView(
                                                  physics: isShowFulMap
                                                      ? NeverScrollableScrollPhysics()
                                                      : ClampingScrollPhysics(),
                                                  child: Container(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: Center(
                                                          child: Column(
                                                              children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xffF8F8F8),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xffD3D3D3))),
                                                              height: 50,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 20.w,
                                                                  ),
                                                                  SvgPicture
                                                                      .asset(
                                                                    AppAssets
                                                                        .enterInfoSvg,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10.w,
                                                                  ),
                                                                  Container(
                                                                    width:
                                                                        370.w,
                                                                    height: 32,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        Text(
                                                                          "${LocaleKeys.entering_the_information_below_clearly.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                              color: const Color(0xff8D8D8D),
                                                                              letterSpacing: 0.18,
                                                                              fontSize: 11,
                                                                              height: 0.8),
                                                                        ),
                                                                        Text(
                                                                          "${LocaleKeys.your_order_arrives_without_problems.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                              color: const Color(0xff8D8D8D),
                                                                              letterSpacing: 0.18,
                                                                              fontSize: 11,
                                                                              height: 0.8),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            isShowFulMap
                                                                ? SizedBox
                                                                    .shrink()
                                                                : SizedBox(
                                                                    height: 10,
                                                                  ),
                                                            isShowFulMap
                                                                ? Stack(
                                                                    children: [
                                                                      Container(
                                                                        width: 1
                                                                            .sw,
                                                                        height: 1.sh /
                                                                            1.7,
                                                                        margin: EdgeInsets.only(
                                                                            bottom:
                                                                                0,
                                                                            left:
                                                                                15,
                                                                            right:
                                                                                15,
                                                                            top:
                                                                                15),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.r),
                                                                            border: Border.all(color: Color(0xffD3D3D3))),
                                                                        child:
                                                                            Container(
                                                                          clipBehavior:
                                                                              Clip.antiAlias,
                                                                          width:
                                                                              1.sw,
                                                                          height:
                                                                              1.sh / 1.7,
                                                                          margin:
                                                                              EdgeInsets.all(10),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(15.r),
                                                                              border: Border.all(color: Color(0xffD3D3D3))),
                                                                          child:
                                                                              GoogleMap(
                                                                            buildingsEnabled:
                                                                                true,
                                                                            mapType:
                                                                                MapType.normal,
                                                                            initialCameraPosition:
                                                                                _kinitialPosition,
                                                                            markers:
                                                                                _markers.toSet(),
                                                                            myLocationButtonEnabled:
                                                                                true,
                                                                            onTap:
                                                                                (argument) {
                                                                              _markers = [];
                                                                              _markers.add(Marker(markerId: MarkerId('current_location'), position: LatLng(argument.latitude, argument.longitude)));
                                                                              _currentLocation = LatLng(argument.latitude, argument.longitude);
                                                                              setState(() {});
                                                                            },
                                                                            onMapCreated:
                                                                                (GoogleMapController controller) {
                                                                              mapController = controller;

                                                                              //    controller.animateCamera(CameraUpdate.newLatLng(LatLng()))
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ValueListenableBuilder<
                                                                              bool>(
                                                                          valueListenable:
                                                                              loadingToGoCurrentLoacation,
                                                                          builder: (context,
                                                                              _loadingToGoCurrentLoacation,
                                                                              _) {
                                                                            return Positioned(
                                                                                bottom: 120,
                                                                                right: 35,
                                                                                child: _loadingToGoCurrentLoacation
                                                                                    ? Container(
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                        color: Color(0xffFFFFFF),
                                                                                        child: TrydosLoader(
                                                                                          color: Color(0xff1D1D1D),
                                                                                          size: 15,
                                                                                        ),
                                                                                      )
                                                                                    : InkWell(
                                                                                        onTap: () async {
                                                                                          var status = await Permission.location.status;

                                                                                          if (!status.isGranted) {
                                                                                            // إذا لم يكن الإذن ممنوحًا، اطلبه
                                                                                            if (await Permission.location.request().isGranted) {
                                                                                              // إذا تم منح الإذن، تابع الحصول على الموقع
                                                                                              _goToCurrentLocation(latlng: null);
                                                                                            } else {
                                                                                              // إذا تم رفض الإذن، يمكنك إظهار رسالة للمستخدم
                                                                                              print('إذن الموقع مرفوض.');
                                                                                            }
                                                                                          } else {
                                                                                            // إذا كان الإذن ممنوحًا، تابع الحصول على الموقع
                                                                                            _goToCurrentLocation(latlng: null);
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          color: Colors.black12,
                                                                                          alignment: Alignment.center,
                                                                                          width: 50,
                                                                                          height: 50,
                                                                                          child: Icon(Icons.my_location),
                                                                                        ),
                                                                                      ));
                                                                          })
                                                                    ],
                                                                  )
                                                                : ValueListenableBuilder<
                                                                        bool>(
                                                                    valueListenable:
                                                                        validateBox,
                                                                    builder:
                                                                        (context,
                                                                            isValidateBox,
                                                                            _) {
                                                                      return Container(
                                                                          width: 1
                                                                              .sw,
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal: 15
                                                                                  .w),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(15.r),
                                                                              border: Border.all(color: Color(0xffD3D3D3))),
                                                                          height: 118,
                                                                          child: Column(
                                                                            children: [
                                                                              Stack(
                                                                                alignment: Alignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    height: 80,
                                                                                    margin: EdgeInsets.all(10.w),
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), border: Border.all(color: Color(0xffD3D3D3))),
                                                                                    child: IgnorePointer(
                                                                                      ignoring: true,
                                                                                      child: GoogleMap(
                                                                                        zoomControlsEnabled: false,
                                                                                        compassEnabled: false,
                                                                                        markers: _markersInSmallMap.toSet(),
                                                                                        zoomGesturesEnabled: false,
                                                                                        mapType: MapType.normal,
                                                                                        initialCameraPosition: _kinitialPosition,
                                                                                        onMapCreated: (GoogleMapController controller) {
                                                                                          mapController = controller;
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      if ((_locationFromSearch?.latitude != null && _locationFromSearch?.longitude != null)) {
                                                                                        _goToCurrentLocation(latlng: _locationFromSearch);
                                                                                      }

                                                                                      showFulMap.value = true;
                                                                                    },
                                                                                    child: Container(
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${LocaleKeys.locate_your_location_on_map.tr()} ",
                                                                                            style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xffF4F4F4), letterSpacing: 0.18, fontSize: 12, height: 0.8),
                                                                                          ),
                                                                                          SvgPicture.asset(
                                                                                            AppAssets.navigationSvg,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      height: 35,
                                                                                      width: 210.w,
                                                                                      margin: EdgeInsets.all(10.w),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color.fromRGBO(43, 44, 44, 0.7),
                                                                                        borderRadius: BorderRadius.circular(15.r),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Text(
                                                                                "${LocaleKeys.location_is_accurate_making_it_easy_to_receive_shipments.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff505050), letterSpacing: 0.18, fontSize: 12, height: 0.8),
                                                                              ),
                                                                            ],
                                                                          ));
                                                                    }),
                                                            isShowFulMap
                                                                ? SizedBox
                                                                    .fromSize()
                                                                : SizedBox(
                                                                    height: 28,
                                                                  ),
                                                            isShowFulMap
                                                                ? SizedBox
                                                                    .fromSize()
                                                                : Container(
                                                                    height: 280,
                                                                    width: 1.sw,
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15.w),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              15,
                                                                          width:
                                                                              116,
                                                                          margin:
                                                                              EdgeInsets.symmetric(horizontal: 10.w),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              SvgPicture.asset(
                                                                                AppAssets.addressInfoSvg,
                                                                              ),
                                                                              Text(
                                                                                "${LocaleKeys.address_info.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff404040), letterSpacing: 0.18, fontSize: 12, height: LanguageService.languageCode == "ar" ? 0.8 : 1.2),
                                                                              ),
                                                                              SvgPicture.asset(
                                                                                AppAssets.chatWithQuestionSvg,
                                                                                color: Color(0xffD3D3D3),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              1.sw,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(15.r),
                                                                              border: Border.all(color: Color(0xffD3D3D3))),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 8),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  LocaleKeys.countr_region.tr(),
                                                                                  style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff505050), letterSpacing: 0.18, fontSize: 12, height: 0.8),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Container(
                                                                                  width: 250.w,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Container(
                                                                                          width: 18,
                                                                                          height: 18,
                                                                                          child: CountryFlag.fromCountryCode(
                                                                                            "${country?.iso}",
                                                                                            height: 18.h,
                                                                                            width: 18.w,
                                                                                            borderRadius: 4.r,
                                                                                          )),
                                                                                      SizedBox(
                                                                                        width: 8.w,
                                                                                      ),
                                                                                      Text(
                                                                                        "${country?.name}",
                                                                                        style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        ValueListenableBuilder<
                                                                                bool>(
                                                                            valueListenable:
                                                                                validateBox,
                                                                            builder: (context,
                                                                                isValidateBox,
                                                                                _) {
                                                                              if (isValidateBox && (finishSelectedByUserToAppear.length == 0)) {
                                                                                animationController.forward();
                                                                                Future.delayed(
                                                                                  Duration(seconds: 2),
                                                                                  () => animationController.reset(),
                                                                                );
                                                                              }
                                                                              return ValueListenableBuilder<bool>(
                                                                                  valueListenable: showPanel,
                                                                                  builder: (context, _showPanel, _) {
                                                                                    if (finishSelectedByUser.length > 0) {
                                                                                      finishSelectedByUserToAppear = [
                                                                                        finishSelectedByUser[0].province ?? "",
                                                                                        finishSelectedByUser[0].city ?? "",
                                                                                        finishSelectedByUser[0].town ?? "",
                                                                                        finishSelectedByUser[0].street ?? "",
                                                                                        finishSelectedByUser[0].building ?? ""
                                                                                      ];
                                                                                      finishSelectedByUserToAppear.removeWhere(
                                                                                        (element) => element == "",
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
                                                                                          builder: (context, child) => Transform.translate(
                                                                                            offset: Offset(!(finishSelectedByUserToAppear.length == 0) ? 0 : sin(3 * 2 * pi * animationController.value) * 5, 0),
                                                                                            child: state.getAddressByCoordinatesStatus == GetAddressByCoordinatesStatus.loading
                                                                                                ? Shimmer.fromColors(baseColor: Colors.grey[500]!, highlightColor: Colors.grey[200]!, child: Container(margin: EdgeInsets.symmetric(vertical: 10.h), width: 1.sw, height: 53.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), border: Border.all(color: (isValidateBox && (finishSelectedByUserToAppear.length == 0)) ? Colors.red : Color(0xffD3D3D3))), child: Padding(padding: const EdgeInsets.all(8.0))))
                                                                                                : Container(
                                                                                                    margin: EdgeInsets.symmetric(vertical: 10.h),
                                                                                                    width: 1.sw,
                                                                                                    height: 53,
                                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), border: Border.all(color: (isValidateBox && (finishSelectedByUserToAppear.length == 0)) ? Colors.red : Color(0xffD3D3D3))),
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            finishSelectedByUserToAppear.length > 0 ? LocaleKeys.change_from_list.tr() : LocaleKeys.select_from_list.tr(),
                                                                                                            style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff505050), letterSpacing: 0.18, fontSize: 12, height: LanguageService.languageCode == "ar" ? 0.6 : 0.5),
                                                                                                          ),
                                                                                                          Container(
                                                                                                            width: 350.w,
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                SvgPicture.asset(
                                                                                                                  AppAssets.detectedSvg,
                                                                                                                  color: finishSelectedByUserToAppear.length > 0 ? Color(0xff1D1D1D) : Color(0xffD3D3D3),
                                                                                                                  height: 16,
                                                                                                                ),
                                                                                                                SizedBox(
                                                                                                                  width: 5.w,
                                                                                                                ),
                                                                                                                finishSelectedByUserToAppear.length > 0
                                                                                                                    ? Container(
                                                                                                                        width: 300.w,
                                                                                                                        height: 20,
                                                                                                                        child: ListView.builder(
                                                                                                                          scrollDirection: Axis.horizontal,
                                                                                                                          itemCount: finishSelectedByUserToAppear.length,
                                                                                                                          itemBuilder: (context, index) => Text(
                                                                                                                            index == finishSelectedByUserToAppear.length - 1 ? "${finishSelectedByUserToAppear[index]}." : "${finishSelectedByUserToAppear[index]} | ",
                                                                                                                            style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.3),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      )
                                                                                                                    : Text(
                                                                                                                        LocaleKeys.province_district_town_street.tr(),
                                                                                                                        style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xffD3D3D3), letterSpacing: 0.18, fontSize: 14, height: 0.8),
                                                                                                                      ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                    )),
                                                                                          ),
                                                                                        ));
                                                                                  });
                                                                            }),
                                                                        AddressInfoWidget(
                                                                            controller:
                                                                                detailsAddressController,
                                                                            context:
                                                                                context,
                                                                            isPhone:
                                                                                false,
                                                                            isComplate:
                                                                                false,
                                                                            height:
                                                                                72,
                                                                            title2:
                                                                                "",
                                                                            hint2:
                                                                                '${LocaleKeys.street_address_building_flat_door_unit.tr()}.',
                                                                            title:
                                                                                LocaleKeys.detailed_address_note.tr(),
                                                                            hint: '${LocaleKeys.write_the_address_clearly_including.tr()}'),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        AddressInfoWidget(
                                                                            controller:
                                                                                addressTitleController,
                                                                            context:
                                                                                context,
                                                                            isPhone:
                                                                                false,
                                                                            isComplate:
                                                                                false,
                                                                            height:
                                                                                50,
                                                                            title2:
                                                                                "",
                                                                            hint2:
                                                                                "",
                                                                            title:
                                                                                LocaleKeys.address_title.tr(),
                                                                            hint: '${LocaleKeys.ex_home.tr()}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                            isShowFulMap
                                                                ? SizedBox
                                                                    .fromSize()
                                                                : SizedBox(
                                                                    height: 20,
                                                                  ),
                                                            isShowFulMap
                                                                ? SizedBox
                                                                    .fromSize()
                                                                : Container(
                                                                    height: 197,
                                                                    width: 1.sw,
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15.w),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              15,
                                                                          width:
                                                                              116,
                                                                          margin:
                                                                              EdgeInsets.symmetric(horizontal: 10.w),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              SvgPicture.asset(
                                                                                AppAssets.personSvg,
                                                                              ),
                                                                              Text(
                                                                                "${LocaleKeys.contact_info.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff404040), letterSpacing: 0.18, fontSize: 12, height: LanguageService.languageCode == "ar" ? 1 : 1.2),
                                                                              ),
                                                                              SvgPicture.asset(
                                                                                AppAssets.chatWithQuestionSvg,
                                                                                color: Color(0xffD3D3D3),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        AddressInfoWidget(
                                                                            controller:
                                                                                reciptionNameController,
                                                                            isPhone:
                                                                                false,
                                                                            title2:
                                                                                "",
                                                                            context:
                                                                                context,
                                                                            isComplate:
                                                                                false,
                                                                            height:
                                                                                50,
                                                                            hint2:
                                                                                "",
                                                                            title:
                                                                                LocaleKeys.recipient_name.tr(),
                                                                            hint: '${LocaleKeys.enter_ful_recipient_name.tr()}'),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        AddressInfoWidget(
                                                                            controller:
                                                                                contactPhoneController,
                                                                            isPhone:
                                                                                true,
                                                                            context:
                                                                                context,
                                                                            isComplate:
                                                                                false,
                                                                            title2:
                                                                                "",
                                                                            height:
                                                                                50,
                                                                            hint2:
                                                                                "",
                                                                            title:
                                                                                LocaleKeys.contact_phone.tr(),
                                                                            hint: "${LocaleKeys.county_code.tr()} + " + '${LocaleKeys.enter_recipient_phone.tr()}'),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        AddressInfoWidgetOptional(
                                                                            height:
                                                                                50,
                                                                            context:
                                                                                context,
                                                                            isPhone:
                                                                                true,
                                                                            isComplate:
                                                                                false,
                                                                            controller:
                                                                                alternativePhoneController,
                                                                            hint2:
                                                                                "",
                                                                            hint:
                                                                                "${LocaleKeys.county_code.tr()} + " + LocaleKeys.enter_alternative_recipient_phone.tr(),
                                                                            title: LocaleKeys.alternative_phone.tr(),
                                                                            title2: LocaleKeys.optional.tr())
                                                                      ],
                                                                    ),
                                                                  ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                          ])))),
                                            );
                                          }),
                                    ),
                                    _showPanel
                                        ? SizedBox.fromSize()
                                        : ValueListenableBuilder<bool>(
                                            valueListenable: showFulMap,
                                            builder:
                                                (context, isShowFulMap, _) {
                                              return Container(
                                                height: 92,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 10,
                                                      blurStyle:
                                                          BlurStyle.solid,
                                                      color: Color(0xffF1F1F1),
                                                    )
                                                  ],
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                ),
                                                width: 1.sw,
                                                child: InkWell(
                                                  onTap: () {
                                                    validateBox.value = true;
                                                    formKey.currentState!
                                                        .validate();
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    Future.delayed(
                                                      Duration(seconds: 2),
                                                      () => validateBox.value =
                                                          false,
                                                    );
                                                  },
                                                  child: isShowFulMap
                                                      ? Container(
                                                          height: 70,
                                                          width: 1.sw,
                                                          child: Row(
                                                            children: [
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  loadingToGoCurrentLoacation
                                                                          .value =
                                                                      false;
                                                                  showFulMap
                                                                          .value =
                                                                      false;
                                                                  _markers = [];
                                                                  fromEditeTodenychangeDetailAddress =
                                                                      false;
                                                                  homeBloc.add(GetAddressByCoordinatesEvent(
                                                                      latitude:
                                                                          _currentLocation?.latitude ??
                                                                              0,
                                                                      longitude:
                                                                          _currentLocation?.longitude ??
                                                                              0));
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
                                                                child:
                                                                    Container(
                                                                  height: 70,
                                                                  width: 280.w,
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.r),
                                                                    color: Color(
                                                                        0xff346BFF),
                                                                  ),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    LocaleKeys
                                                                        .select
                                                                        .tr(),
                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                        color: const Color(
                                                                            0xffFEFEFE),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        fontSize:
                                                                            18,
                                                                        height:
                                                                            0.8),
                                                                  )),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 20.w,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  showFulMap
                                                                          .value =
                                                                      false;
                                                                  _currentLocation =
                                                                      null;

                                                                  _markers = [];
                                                                },
                                                                child: Container(
                                                                    alignment: Alignment.center,
                                                                    height: 70,
                                                                    width: 70.w,
                                                                    child: Text(
                                                                      "${LocaleKeys.cansel.tr()} ",
                                                                      style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                          color: const Color(
                                                                              0xff1D1D1D),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              18,
                                                                          height:
                                                                              1.2),
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : ValueListenableBuilder<
                                                              bool>(
                                                          valueListenable:
                                                              fillAllContainers,
                                                          builder: (context,
                                                              isFillAllContainers,
                                                              _) {
                                                            return InkWell(
                                                              onTap: () {
                                                                validateBox
                                                                        .value =
                                                                    true;
                                                                formKey
                                                                    .currentState!
                                                                    .validate();
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                                  () => validateBox
                                                                          .value =
                                                                      false,
                                                                );
                                                                if ((reciptionNameController.text.length > 0 &&
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
                                                                    homeBloc.add(
                                                                        AddAddressInfoClassEvent(
                                                                            addressInfoClassToSave:
                                                                                address.CustomerAddressesInfo(
                                                                      addressDetail:
                                                                          detailsAddressController
                                                                              .text,
                                                                      contactInfo:
                                                                          address
                                                                              .ContactInfo(
                                                                        alternativePhone:
                                                                            alternativePhoneController.text,
                                                                        name: reciptionNameController
                                                                            .text,
                                                                        phone: contactPhoneController
                                                                            .text,
                                                                      ),
                                                                      address:
                                                                          addressTitleController
                                                                              .text,
                                                                      location: address.Location(
                                                                          latitude: _currentLocation?.latitude.toString() ??
                                                                              " ",
                                                                          longitude:
                                                                              _currentLocation?.longitude.toString() ?? " "),
                                                                      regionDetails:
                                                                          address
                                                                              .RegionDetails(
                                                                        building: finishSelectedByUser.length >
                                                                                0
                                                                            ? finishSelectedByUser[0].building
                                                                            : "",
                                                                        city: finishSelectedByUser.length >
                                                                                0
                                                                            ? finishSelectedByUser[0].city
                                                                            : "",
                                                                        country:
                                                                            "${country?.name}",
                                                                        province:
                                                                            finishSelectedByUser[0].province,
                                                                        street: finishSelectedByUser.length >
                                                                                0
                                                                            ? finishSelectedByUser[0].street
                                                                            : "",
                                                                        town: finishSelectedByUser.length >
                                                                                0
                                                                            ? finishSelectedByUser[0].town
                                                                            : "",
                                                                      ),
                                                                    )));
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  } else {
                                                                    homeBloc.add(
                                                                        EditAdressInfoClassEvent(
                                                                            preIdToEdit: widget.addressInfoClassToEdid!.id ??
                                                                                0,
                                                                            addressInfoClassToSave:
                                                                                address.CustomerAddressesInfo(
                                                                              regionDetails: address.RegionDetails(
                                                                                building: finishSelectedByUser.length > 0 ? finishSelectedByUser[0].building : "",
                                                                                city: finishSelectedByUser.length > 0 ? finishSelectedByUser[0].city : "",
                                                                                country: "${country?.name}",
                                                                                province: finishSelectedByUser[0].province,
                                                                                street: finishSelectedByUser.length > 0 ? finishSelectedByUser[0].street : "",
                                                                                town: finishSelectedByUser.length > 0 ? finishSelectedByUser[0].town : "",
                                                                              ),
                                                                              addressDetail: detailsAddressController.text,
                                                                              contactInfo: address.ContactInfo(
                                                                                alternativePhone: alternativePhoneController.text,
                                                                                name: reciptionNameController.text,
                                                                                phone: contactPhoneController.text,
                                                                              ),
                                                                              address: addressTitleController.text,
                                                                              location: address.Location(latitude: _currentLocation?.latitude.toString() ?? "", longitude: _currentLocation?.longitude.toString() ?? ""),
                                                                            )));

                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 70,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.r),
                                                                  color: (reciptionNameController.text.length > 0 &&
                                                                          (finishSelectedByUserToAppear.length) >
                                                                              0 &&
                                                                          addressTitleController.text.length >
                                                                              0 &&
                                                                          detailsAddressController.text.length >
                                                                              0 &&
                                                                          contactPhoneController.text.length >
                                                                              0)
                                                                      ? Color(
                                                                          0xff346BFF)
                                                                      : Color(
                                                                          0xffC4C2C2),
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
                                                                      ?.mr
                                                                      .copyWith(
                                                                          color: const Color(
                                                                              0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              18,
                                                                          height:
                                                                              0.8),
                                                                )),
                                                              ),
                                                            );
                                                          }),
                                                ),
                                              );
                                            })
                                  ],
                                ),
                                ValueListenableBuilder<bool>(
                                    valueListenable: showShadowForPanel,
                                    builder:
                                        (context, isShowShadowForPanel, _) {
                                      return !isShowShadowForPanel
                                          ? SizedBox.shrink()
                                          : InkWell(
                                              onTap: () {
                                                showShadowForPanel.value =
                                                    false;
                                                Future.delayed(
                                                  Duration(microseconds: 300),
                                                  () {
                                                    panelController.close();
                                                    showShadowForPanel.value =
                                                        false;
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: 1.sh,
                                                width: 1.sw,
                                                color: Color.fromRGBO(
                                                    29, 29, 29, 0.6),
                                              ),
                                            );
                                    }),
                                ValueListenableBuilder<bool>(
                                    valueListenable: showPanel,
                                    builder: (context, isShowPanel, _) {
                                      return BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (p, c) =>
                                              p.getAddressByTextStatus !=
                                              c.getAddressByTextStatus,
                                          builder: (context, state) {
                                            filterResultSearch = [];
                                            filterLatLngSearch = [];
                                            state.resultSearch?.forEach(
                                              (element) {
                                                filterResultSearch.add(
                                                    address.RegionDetails(
                                                        building:
                                                            element.building,
                                                        city: element.city,
                                                        country: "",
                                                        province:
                                                            element.province,
                                                        street: element.street,
                                                        town: element.town));
                                                filterLatLngSearch.add(LatLng(
                                                    element.coordinates?.lat ??
                                                        0,
                                                    element.coordinates?.lon ??
                                                        0));
                                              },
                                            );

                                            return ValueListenableBuilder<
                                                    List<String>>(
                                                valueListenable:
                                                    listOfAddressTilteSeletedByUser,
                                                builder: (context,
                                                    addressTilteSeletedByUser,
                                                    _) {
                                                  if (listOfAddressTilteSeletedByUser
                                                          .value.length >=
                                                      4) {
                                                    panelController.close();
                                                  }
                                                  return Positioned(
                                                      bottom: 0,
                                                      child: Container(
                                                        width: 1.sw,
                                                        height: isShowPanel
                                                            ? 441
                                                            : 0,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        30.r),
                                                                topRight: Radius
                                                                    .circular(
                                                                        30.r))),
                                                        child: SlidingUpPanel(
                                                          controller:
                                                              panelController,
                                                          borderRadius: ((state
                                                                          .cartCollection ==
                                                                      null ||
                                                                  state
                                                                      .cartCollection!
                                                                      .isEmpty))
                                                              ? null
                                                              : BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          30.r),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          30.r)),
                                                          isDraggable: true,
                                                          slideDirection:
                                                              SlideDirection.UP,
                                                          onPanelClosed: () {
                                                            finishSelectedByUser =
                                                                [
                                                              address.RegionDetails(
                                                                  province:
                                                                      addressTilteSeletedByUser.length >
                                                                              0
                                                                          ? addressTilteSeletedByUser[
                                                                              0]
                                                                          : "",
                                                                  city: addressTilteSeletedByUser
                                                                              .length >
                                                                          1
                                                                      ? addressTilteSeletedByUser[
                                                                          1]
                                                                      : "",
                                                                  town: addressTilteSeletedByUser
                                                                              .length >
                                                                          2
                                                                      ? addressTilteSeletedByUser[
                                                                          2]
                                                                      : "",
                                                                  street: addressTilteSeletedByUser
                                                                              .length >
                                                                          3
                                                                      ? addressTilteSeletedByUser[
                                                                          3]
                                                                      : "",
                                                                  building:
                                                                      addressTilteSeletedByUser.length >
                                                                              4
                                                                          ? addressTilteSeletedByUser[
                                                                              4]
                                                                          : "")
                                                            ];

                                                            searchController
                                                                .text = "";
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            showShadowForPanel
                                                                .value = false;
                                                            showPanel.value =
                                                                false;
                                                            listOfAddressTilteSeletedByUser
                                                                .value = [];
                                                            fillAllContainers
                                                                    .value =
                                                                !fillAllContainers
                                                                    .value;
                                                          },
                                                          onPanelOpened: () {},
                                                          minHeight: 0,
                                                          maxHeight: 441,
                                                          panelBuilder: (sc) =>
                                                              Container(
                                                            height: 441,
                                                            width: 1.sw,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Center(
                                                                  child:
                                                                      Container(
                                                                    width: 125,
                                                                    height: 20,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          AppAssets
                                                                              .detectedSvg,
                                                                          color:
                                                                              Color(0xff1D1D1D),
                                                                        ),
                                                                        Text(
                                                                          "${LocaleKeys.select_from_list.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.rr.copyWith(
                                                                              color: const Color(0xff1D1D1D),
                                                                              letterSpacing: 0.18,
                                                                              fontSize: 14,
                                                                              height: 1.2),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                          width:
                                                                              18,
                                                                          height:
                                                                              18,
                                                                          child:
                                                                              CountryFlag.fromCountryCode(
                                                                            "${country?.iso}",
                                                                            height:
                                                                                18.h,
                                                                            width:
                                                                                18.w,
                                                                            borderRadius:
                                                                                4.r,
                                                                          )),
                                                                      Text(
                                                                        " ${country?.name} ",
                                                                        style: context.textTheme.bodyMedium?.rr.copyWith(
                                                                            color: const Color(
                                                                                0xff1D1D1D),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            fontSize:
                                                                                14,
                                                                            height:
                                                                                1.2),
                                                                      ),
                                                                      addressTilteSeletedByUser.length ==
                                                                              0
                                                                          ? Text(
                                                                              " | ${LocaleKeys.province.tr()}",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            )
                                                                          : Text(
                                                                              " | ${addressTilteSeletedByUser[0]}",
                                                                              style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            ),
                                                                      addressTilteSeletedByUser.length <=
                                                                              1
                                                                          ? Text(
                                                                              " | ${LocaleKeys.district.tr()}",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(color: addressTilteSeletedByUser.length == 1 ? const Color(0xff1D1D1D) : const Color(0xffD3D3D3), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            )
                                                                          : Text(
                                                                              " | ${addressTilteSeletedByUser[1]}",
                                                                              style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            ),
                                                                      addressTilteSeletedByUser.length <=
                                                                              2
                                                                          ? Text(
                                                                              " | ${LocaleKeys.town.tr()}",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(color: addressTilteSeletedByUser.length == 2 ? const Color(0xff1D1D1D) : const Color(0xffD3D3D3), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            )
                                                                          : Text(
                                                                              " | ${addressTilteSeletedByUser[2]}",
                                                                              style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            ),
                                                                      addressTilteSeletedByUser.length <=
                                                                              3
                                                                          ? Text(
                                                                              " | ${LocaleKeys.street.tr()}",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(color: addressTilteSeletedByUser.length == 3 ? const Color(0xff1D1D1D) : const Color(0xffD3D3D3), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            )
                                                                          : Text(
                                                                              " | ${addressTilteSeletedByUser[3]}",
                                                                              style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2),
                                                                            )
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  height: 40,
                                                                  width: 1.sw,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(12
                                                                              .r),
                                                                      color: Color(
                                                                          0xffF8F8F8)),
                                                                  child:
                                                                      AppTextField(
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .done,
                                                                    onChange:
                                                                        (val) {
                                                                      if (val.length >
                                                                          1) {
                                                                        homeBloc.add(GetAddressByTextEvent(
                                                                            reset:
                                                                                false,
                                                                            query:
                                                                                val));
                                                                      } else {
                                                                        homeBloc.add(GetAddressByTextEvent(
                                                                            reset:
                                                                                true,
                                                                            query:
                                                                                val));
                                                                      }
                                                                    },
                                                                    onTap:
                                                                        () {},
                                                                    controller:
                                                                        searchController,
                                                                    onFieldSubmitted:
                                                                        (val) {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                    },
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            left:
                                                                                0,
                                                                            right:
                                                                                0),
                                                                    filledColor:
                                                                        Color(
                                                                            0xffF8F8F8),
                                                                    bordersColor:
                                                                        Color(
                                                                            0xffF8F8F8),
                                                                    icon: SvgPicture
                                                                        .asset(
                                                                      AppAssets
                                                                          .searchOutlinedSvg,
                                                                      height:
                                                                          18,
                                                                      width: 18,
                                                                      color: Color(
                                                                          0xff388CFF),
                                                                    ),
                                                                    hintText:
                                                                        "${LocaleKeys.search.tr()} ${LocaleKeys.province_district_town_street.tr()}",
                                                                    hintTextStyle: context.textTheme.bodyMedium?.lr.copyWith(
                                                                        color: const Color(
                                                                            0xffC4C2C2),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        fontSize:
                                                                            14,
                                                                        height:
                                                                            0.8),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  height: 260,
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child: ListView
                                                                      .separated(
                                                                          controller:
                                                                              sc,
                                                                          padding: EdgeInsets.all(
                                                                              0),
                                                                          itemBuilder:
                                                                              (context,
                                                                                  index) {
                                                                            String
                                                                                apprearfilterResultSearch =
                                                                                "";
                                                                            if ((searchController.text.length) >
                                                                                0) {
                                                                              apprearfilterResultSearch = " ${filterResultSearch[index].province ?? ""} ${filterResultSearch[index].city ?? ""} ${filterResultSearch[index].town ?? ""} ${filterResultSearch[index].street ?? ""} ${filterResultSearch[index].street ?? ""} ${filterResultSearch[index].building ?? ""}";
                                                                            }

                                                                            return InkWell(
                                                                              onTap: () {
                                                                                if ((searchController.text.length) > 0) {
                                                                                  _locationFromSearch = filterLatLngSearch[index];
                                                                                  setState(() {});
                                                                                  address.RegionDetails filterSearchTadd = filterResultSearch[index];
                                                                                  listOfAddressTilteSeletedByUser.value = [
                                                                                    ...[
                                                                                      filterSearchTadd.province ?? "",
                                                                                      filterSearchTadd.city ?? "",
                                                                                      filterSearchTadd.town ?? "",
                                                                                      filterSearchTadd.street ?? "",
                                                                                      filterSearchTadd.building ?? ""
                                                                                    ]
                                                                                  ];
                                                                                  panelController.close();
                                                                                } else {
                                                                                  listOfAddressTilteSeletedByUser.value = [
                                                                                    ...addressTilteSeletedByUser,
                                                                                    addressTilte[index]
                                                                                  ];
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 35),
                                                                                alignment: LanguageService.languageCode == "ar" ? Alignment.centerRight : Alignment.centerLeft,
                                                                                child: RichText(
                                                                                  text: TextSpan(style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.2), text: (searchController.text.length) > 0 ? apprearfilterResultSearch.substring(0, (searchController.text.length)) : addressTilte[index], children: [
                                                                                    TextSpan(style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff8D8D8D), letterSpacing: 0.18, fontSize: 14, height: 1.2), text: (searchController.text.length) > 0 ? apprearfilterResultSearch.substring(searchController.text.length) : "")
                                                                                  ]),
                                                                                ),
                                                                                decoration: BoxDecoration(color: Color(0xffF8F8F8), borderRadius: BorderRadius.circular(12.r)),
                                                                                height: 50,
                                                                              ),
                                                                            );
                                                                          },
                                                                          separatorBuilder: (context, index) =>
                                                                              SizedBox(
                                                                                height: 2,
                                                                              ),
                                                                          itemCount: (searchController.text.length) > 0
                                                                              ? filterResultSearch.length
                                                                              : addressTilte.length),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                });
                                          });
                                    })
                              ],
                            );
                          },
                        ),
                      );
                    });
              },
            )));
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
