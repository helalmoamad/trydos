import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/camera_screen.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/camera_profile.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ProfilePersonalInfoPage extends StatefulWidget {
  const ProfilePersonalInfoPage({super.key});

  @override
  State<ProfilePersonalInfoPage> createState() =>
      _ProfilePersonalInfoPageState();
}

class _ProfilePersonalInfoPageState extends State<ProfilePersonalInfoPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<String?> changeGender = ValueNotifier("null");
  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final ValueNotifier<bool> validateBox = ValueNotifier(false);
  final ValueNotifier<int> maxLengthForNumber = ValueNotifier(25);
  final TextEditingController fullNameController = TextEditingController();
  final ValueNotifier<int> maxLengthForOptionalNumber = ValueNotifier(25);
  final TextEditingController PhoneController = TextEditingController();
  final TextEditingController alternativePhoneController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<bool> visiblePrefix = ValueNotifier(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> visiblePrefixOptional = ValueNotifier(false);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late AnimationController animationController;
  List<CameraDescription> cameras = [];
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    fullNameController.text = homeBloc.state.userInfo?.name ?? "";
    PhoneController.text = homeBloc.state.userInfo?.phone ?? "";
    alternativePhoneController.text =
        homeBloc.state.userInfo?.alternativePhone ?? "";
    emailController.text = homeBloc.state.userInfo?.email ?? "";
    changeGender.value =
        (homeBloc.state.userInfo?.gender?.name.toString()) ?? null;
    animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    if (PhoneController.text.length > 0) {
      visiblePrefix.value = true;
    }
    if (alternativePhoneController.text.length > 0) {
      visiblePrefixOptional.value = true;
    }
    super.initState();
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

    return ValueListenableBuilder<bool>(
        valueListenable: visibleSave,
        builder: (context, _visibleSave, _) {
          print("ddddddddddddddddddddddddddddddddddddddd${_visibleSave}");
          return Scaffold(
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    backgroundColor: Color(0x000000),
                    action: [
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: 55.w,
                            ),
                      Text(
                        LocaleKeys.profile_personal_info.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14,
                            height: 1.3),
                      ),
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : BlocBuilder<HomeBloc, HomeState>(
                              buildWhen: (previous, current) =>
                                  previous.updateProfileStatus !=
                                  current.updateProfileStatus,
                              builder: (context, state) {
                                if (state.updateProfileStatus ==
                                    UpdateProfileStatus.success) {
                                  Future.delayed(Duration(milliseconds: 300),
                                      () => visibleSave.value = false);
                                  homeBloc.add(UpdateProfileEvent(
                                      changeStatusToInit: true));
                                }
                                return InkWell(
                                  onTap: () {
                                    validateBox.value = true;
                                    formKey.currentState!.validate();
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    String genderIndex = "3";
                                    if (changeGender.value == "Man") {
                                      genderIndex = "1";
                                    } else if (changeGender.value!
                                        .startsWith("Wom")) {
                                      genderIndex = "2";
                                    } else {
                                      genderIndex = "3";
                                    }
                                    homeBloc.add(UpdateProfileEvent(
                                        name: fullNameController.text,
                                        alternative_phone:
                                            alternativePhoneController.text
                                                .replaceAll(" ", ""),
                                        phone: PhoneController.text
                                            .replaceAll(" ", ""),
                                        email: emailController.text,
                                        gender: genderIndex));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 40,
                                    height: 20,
                                    child: state.updateProfileStatus ==
                                            UpdateProfileStatus.loading
                                        ? TrydosLoader(
                                            size: 18,
                                          )
                                        : Text(
                                            LocaleKeys.save.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.mr
                                                .copyWith(
                                                    color:
                                                        const Color(0xff402CDD),
                                                    letterSpacing: 0.18,
                                                    fontSize: 14,
                                                    height: 1.3),
                                          ),
                                  ),
                                );
                              }),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: 15.w,
                            )
                    ],
                    scrolledUnderElevation: 0,
                    backIconColor: Colors.black,
                    withShadow: false),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 50,
                            width: 1.sw,
                            decoration: BoxDecoration(
                                color: Color(0xffF8F8F8),
                                border: Border.all(color: Color(0xffD3D3D3))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10.w,
                                ),
                                SvgPicture.asset(
                                  AppAssets.infoSvg,
                                  color: Color(0xff402CDD),
                                  width: 25.w,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  LocaleKeys.entering_your_information_correctly
                                      .tr(),
                                  style: context.textTheme.bodyMedium?.rr
                                      .copyWith(
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          fontSize: 10.sp,
                                          height: 1.3),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 15,
                          width: 150,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AppAssets.personalInfoSvg,
                                height: 15,
                                color: Color(0xff1D1D1D),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${LocaleKeys.personal_info.tr()}",
                                style: context.textTheme.bodyMedium?.mr
                                    .copyWith(
                                        color: const Color(0xff404040),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.2),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              SvgPicture.asset(
                                AppAssets.chatWithQuestionSvg,
                                color: Color(0xffD3D3D3),
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _personInfoWidget(
                            controller: fullNameController,
                            isPhone: false,
                            title2: "",
                            context: context,
                            isComplate: false,
                            height: 50,
                            hint2: "",
                            title: LocaleKeys.full_name.tr(),
                            hint: LocaleKeys.enter_full_name.tr(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _personInfoWidget(
                            controller: PhoneController,
                            isPhone: true,
                            context: context,
                            isComplate: false,
                            title2: "",
                            height: 50,
                            hint2: "",
                            title: LocaleKeys.phone.tr(),
                            hint: LocaleKeys.enter_phone.tr(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _personInfoWidgetOptional(
                              height: 50,
                              context: context,
                              isPhone: true,
                              isComplate: false,
                              controller: alternativePhoneController,
                              hint2: "",
                              hint: LocaleKeys.enter_alternative_phone.tr(),
                              title: LocaleKeys.alternative_phone.tr(),
                              title2: LocaleKeys.optional.tr()),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _personInfoWidget(
                            controller: emailController,
                            isPhone: false,
                            title2: "",
                            context: context,
                            isComplate: false,
                            height: 50,
                            hint2: "",
                            title: LocaleKeys.email.tr(),
                            hint: LocaleKeys.enter_email_address.tr(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _genderWidget(),
                        )
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  Widget _genderWidget() {
    return ValueListenableBuilder<String?>(
        valueListenable: changeGender,
        builder: (context, _changeGender, _) {
          return Container(
              height: 85,
              width: 1.sw,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Color(0xffD3D3D3))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 7, left: 8, right: 8),
                        height: 18,
                        child: Text(
                          LocaleKeys.gender.tr(),
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff505050),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: LanguageService.languageCode == "ar"
                                  ? 0.5
                                  : 0.8),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                visibleSave.value = true;
                                changeGender.value = "Man";
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 120.w,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                          color: changeGender.value == "Man"
                                              ? const Color(0xff402CDD)
                                              : Color(0xffD3D3D3))),
                                  child: Text(
                                    LocaleKeys.man.tr(),
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: changeGender.value == "Man"
                                                ? const Color(0xff1D1D1D)
                                                : const Color(0xffD3D3D3),
                                            letterSpacing: 0.18,
                                            fontSize: 14,
                                            height:
                                                LanguageService.languageCode ==
                                                        "ar"
                                                    ? 0.5
                                                    : 0.8),
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                visibleSave.value = true;
                                changeGender.value = "Women";
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 120.w,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                          color: changeGender.value!
                                                  .startsWith("Wom")
                                              ? const Color(0xff402CDD)
                                              : Color(0xffD3D3D3))),
                                  child: Text(
                                    LocaleKeys.women.tr(),
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: changeGender.value!
                                                    .startsWith("Wom")
                                                ? const Color(0xff1D1D1D)
                                                : const Color(0xffD3D3D3),
                                            letterSpacing: 0.18,
                                            fontSize: 14,
                                            height:
                                                LanguageService.languageCode ==
                                                        "ar"
                                                    ? 0.5
                                                    : 0.8),
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                visibleSave.value = true;
                                changeGender.value = "Other";
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 120.w,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                          color: changeGender.value == "Other"
                                              ? const Color(0xff402CDD)
                                              : Color(0xffD3D3D3))),
                                  child: Text(
                                    LocaleKeys.other.tr(),
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: changeGender.value == "Other"
                                                ? const Color(0xff1D1D1D)
                                                : const Color(0xffD3D3D3),
                                            letterSpacing: 0.18,
                                            fontSize: 14,
                                            height:
                                                LanguageService.languageCode ==
                                                        "ar"
                                                    ? 0.5
                                                    : 0.8),
                                  )),
                            )
                          ],
                        ))
                  ]));
        });
  }

  Widget _personInfoWidgetOptional(
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
                                            LanguageService.languageCode == "ar"
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
                                builder:
                                    (context, _maxLengthForOptionalNumber, _) {
                                  return AppTextField(
                                    controller: controller,
                                    prefix: isPhone && isVisiblePrefixOptional
                                        ? Text("+",
                                            style: context
                                                .textTheme.bodyMedium?.mr
                                                .copyWith(
                                                    color:
                                                        const Color(0xff1D1D1D),
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
                                      Country newCountry = countries.firstWhere(
                                          (element) => '+${val.toLowerCase()}'
                                              .startsWith(element.dialCode
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

                                      if (val.length > 0 && isPhone) {
                                        visiblePrefixOptional.value = true;
                                      } else if (val.length == 0 && isPhone) {
                                        visiblePrefixOptional.value = false;
                                      }
                                      visibleSave.value = true;
                                    },
                                    onTap: () {},
                                    onFieldSubmitted: (val) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    textAlignVertical: TextAlignVertical.center,
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
                                    textStyle: context.textTheme.bodyMedium?.mr
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

  Widget _personInfoWidget(
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
                                                visibleSave.value = true;
                                                if (val.length > 0 && isPhone) {
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
                                                  int spaces =
                                                      ((newCountry.maxLength) /
                                                              3)
                                                          .floor();
                                                  if (newCountry.maxLength %
                                                          3 ==
                                                      0) {
                                                    spaces--;
                                                  }
                                                  maxLengthForNumber.value =
                                                      newCountry.maxLength +
                                                          newCountry
                                                              .dialCode.length +
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
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9\s]'))
                                            ],
                                      textInputAction: TextInputAction.done,
                                      onChange: (val) {
                                        visibleSave.value = true;
                                        if (val.length > 0 && isPhone) {
                                          visiblePrefix.value = true;
                                        } else if (val.length == 0 && isPhone) {
                                          visiblePrefix.value = false;
                                        }
                                      },
                                      onTap: () {},
                                      validator: (value) {
                                        if ((value?.length ?? 0) < 8) {
                                          return LocaleKeys
                                              .must_be_at_least_8_characters
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
                          ]),
                    ),
                  ),
                );
              });
        });
  }

  String _formatNumber(String input, String countryCode) {
    // إزالة الفراغات

    String inputWithoutCode = input.split("${countryCode}").toList()[1];
    String digitsOnly =
        inputWithoutCode.replaceAll(' ', '').replaceAll(RegExp(r'[^0-9]'), '');

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
}
