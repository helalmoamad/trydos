import 'dart:math';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/guest_phone_verification_dialog.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class ProfilePersonalInfoPage extends StatefulWidget {
  final ValueNotifier<String?> changeGender;
  final ValueNotifier<bool> visibleSave;
  final TextEditingController emailController;
  final ValueNotifier<bool> visiblePrefix;
  final ValueNotifier<bool> visiblePrefixOptional;
  final TextEditingController phoneController;
  final TextEditingController alternativePhoneController;
  final TextEditingController fullNameController;
  const ProfilePersonalInfoPage({
    super.key,
    required this.changeGender,
    required this.visibleSave,
    required this.emailController,
    required this.visiblePrefix,
    required this.visiblePrefixOptional,
    required this.phoneController,
    required this.alternativePhoneController,
    required this.fullNameController,
  });

  @override
  State<ProfilePersonalInfoPage> createState() =>
      _ProfilePersonalInfoPageState();
}

class _ProfilePersonalInfoPageState extends State<ProfilePersonalInfoPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> validateBox = ValueNotifier(false);
  final ValueNotifier<int> maxLengthForNumber = ValueNotifier(25);

  final ValueNotifier<int> maxLengthForOptionalNumber = ValueNotifier(25);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late AnimationController animationController;
  List<CameraDescription> cameras = [];
  late HomeBloc homeBloc;
  late AuthBloc authBloc;
  @override
  void initState() {
    LastPagesTracker.push('ProfilePersonalInfoPage');
    homeBloc = BlocProvider.of<HomeBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
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
    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibleSave,
      builder: (context, _visibleSave, _) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            // إذا كان الكيبورد مفتوح، أغلق الكيبورد فقط
            if (MediaQuery.of(context).viewInsets.bottom > 0) {
              FocusScope.of(context).unfocus();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: TrydosAppBar(
              appBarParams: AppBarParams(
                backgroundColor: const Color(0x000000),
                action: [
                  const Spacer(),
                  !_visibleSave
                      ? const SizedBox.shrink()
                      : SizedBox(width: 55.w),
                  Text(
                    LocaleKeys.profile_personal_info.tr(),
                    style: context.textTheme.bodyMedium?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14.sp,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  !_visibleSave
                      ? const SizedBox.shrink()
                      : BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (previous, current) =>
                              previous.updateProfileStatus !=
                              current.updateProfileStatus,
                          builder: (context, state) {
                            if (state.updateProfileStatus ==
                                UpdateProfileStatus.success) {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () => widget.visibleSave.value = false,
                              );
                              homeBloc.add(
                                UpdateProfileEvent(changeStatusToInit: true),
                              );
                            }
                            return InkWell(
                              onTap: () {
                                if (state.updateProfileStatus ==
                                    UpdateProfileStatus.loading) {
                                  return;
                                }
                                validateBox.value = true;
                                formKey.currentState!.validate();
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                String? genderIndex;
                                if (widget.changeGender.value == "Man") {
                                  genderIndex = "1";
                                } else if (widget.changeGender.value!
                                    .startsWith("Wom")) {
                                  genderIndex = "2";
                                } else if (widget.changeGender.value!
                                    .startsWith("Other")) {
                                  genderIndex = "3";
                                }
                                // The number the account is registered with,
                                // without its "+", so it can be compared to
                                // what the field holds.
                                final String? registeredPhone =
                                    ((((state.userInfo?.phone
                                                        ?.split("+")
                                                        .toList()) ??
                                                    [])
                                                .length >
                                            1)
                                        ? (state.userInfo?.phone
                                              ?.split("+")
                                              .toList()[1])
                                        : state.userInfo?.phone);
                                final bool phoneChanged =
                                    widget.phoneController.text.replaceAll(
                                          " ",
                                          "",
                                        ) !=
                                        registeredPhone;

                                if (phoneChanged) {
                                  // A new number has to be proven before it is
                                  // saved. The dialog sends the code — that is
                                  // what choosing WhatsApp or SMS does — and
                                  // saves the profile once the code checks out.
                                  _startPhoneChangeVerification();
                                  return;
                                }
                                homeBloc.add(
                                  UpdateProfileEvent(
                                    name: widget.fullNameController.text,
                                    alternative_phone:
                                        widget
                                                .alternativePhoneController
                                                .text
                                                .length >
                                            0
                                        ? "+" +
                                              widget
                                                  .alternativePhoneController
                                                  .text
                                                  .replaceAll(" ", "")
                                        : null,
                                    email: widget.emailController.text,
                                    gender: genderIndex,
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 40.w,
                                height: 20.h,
                                child:
                                    state.updateProfileStatus ==
                                        UpdateProfileStatus.loading
                                    ? TrydosLoader(size: 18.h)
                                    : Text(
                                        LocaleKeys.save.tr(),
                                        style: context.textTheme.bodyMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff402CDD),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: 1.3,
                                            ),
                                      ),
                              ),
                            );
                          },
                        ),
                  !_visibleSave
                      ? const SizedBox.shrink()
                      : SizedBox(width: 15.w),
                ],
                scrolledUnderElevation: 0,
                backIconColor: Colors.black,
                withShadow: false,
              ),
            ),
            body: SafeArea(
              child: Form(
                key: formKey,
                child: Container(
                  height: 1.sh,
                  width: 1.sw,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 50.h,
                            width: 1.sw,
                            decoration: BoxDecoration(
                              color: const Color(0xffF8F8F8),
                              border: Border.all(
                                color: const Color(0xffD3D3D3),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 10.w),
                                SvgPicture.asset(
                                  AppAssets.infoSvg,
                                  // ignore: deprecated_member_use
                                  color: const Color(0xff402CDD),
                                  width: 25.w,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  LocaleKeys.entering_your_information_correctly
                                      .tr(),
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        fontSize: 9.sp,
                                        height: 1.3,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 15.h,
                            width: 150.w,
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppAssets.personalInfoSvg,
                                  height: 15.h,
                                  // ignore: deprecated_member_use
                                  color: const Color(0xff1D1D1D),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "${LocaleKeys.personal_info.tr()}",
                                  style: context.textTheme.bodyMedium?.mq
                                      .copyWith(
                                        color: const Color(0xff404040),
                                        letterSpacing: 0.18,
                                        fontSize: 12.sp,
                                        height: 1.2,
                                      ),
                                ),
                                SizedBox(width: 15.w),
                                SvgPicture.asset(
                                  AppAssets.chatWithQuestionSvg,
                                  // ignore: deprecated_member_use
                                  color: const Color(0xffD3D3D3),
                                  height: 15.h,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: _personInfoWidget(
                              controller: widget.fullNameController,
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
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: _personInfoWidget(
                              controller: widget.phoneController,
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
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: _personInfoWidgetOptional(
                              height: 50,
                              context: context,
                              isPhone: true,
                              isComplate: false,
                              controller: widget.alternativePhoneController,
                              hint2: "",
                              hint: LocaleKeys.enter_alternative_phone.tr(),
                              title: LocaleKeys.alternative_phone.tr(),
                              title2: LocaleKeys.optional.tr(),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: _personInfoWidget(
                              controller: widget.emailController,
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
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: _genderWidget(),
                          ),
                        ],
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
  }

  /// Opens the shared verification flow for a number the user just typed.
  ///
  /// Same popup every other page uses, and the same two steps it uses — choose
  /// how to receive the code, then type it — only entered at the second step,
  /// because the account and the number are both already known here.
  ///
  /// The verify request itself is the profile one (`VerifyOtpInProfileEvent`,
  /// through `fromProfile`), not the guest or sign-in one: it proves a phone
  /// for a session that already exists rather than starting a new session.
  void _startPhoneChangeVerification() {
    final String newPhone = widget.phoneController.text.replaceAll(" ", "");
    if (newPhone.isEmpty) return;
    GuestPhoneVerificationDialog.show(
      context,
      startAtMethods: true,
      initialPhone: newPhone,
      fromProfile: true,
      // The guest recovery flow is a different verify request. Passing both
      // flags used to work only because `fromProfile` is tested first.
      fromExpired: false,
      onVerified: _saveProfileWithVerifiedPhone,
    );
  }

  /// Saves the profile once the new number has been proven.
  ///
  /// Runs after the code is accepted, so `prefsRepository.idToken` is the fresh
  /// one that verification just stored — the market update is authorised with
  /// it.
  void _saveProfileWithVerifiedPhone() {
    String? genderIndex;
    if (widget.changeGender.value == "Man") {
      genderIndex = "1";
    } else if (widget.changeGender.value!.startsWith("Wom")) {
      genderIndex = "2";
    } else if (widget.changeGender.value!.startsWith("Other")) {
      genderIndex = "3";
    }
    GetIt.I<HomeBloc>().add(
      UpdateProfileEvent(
        fromGuest: !(prefsRepository.isVerifiedPhone ?? false),
        phone: (widget.phoneController.text.length) > 0
            ? "+" + widget.phoneController.text.replaceAll(" ", "")
            : null,
        idToken: prefsRepository.idToken,
        name: widget.fullNameController.text,
        alternative_phone:
            (widget.alternativePhoneController.text.length) > 0
            ? widget.alternativePhoneController.text.replaceAll(" ", "")
            : null,
        email: widget.emailController.text,
        gender: genderIndex,
      ),
    );
  }

  Widget _genderWidget() {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.changeGender,
      builder: (context, _changeGender, _) {
        return Container(
          height: 85.h,
          width: 1.sw,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: const Color(0xffD3D3D3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 7.h, left: 8.w, right: 8.w),
                height: 18.h,
                child: Text(
                  LocaleKeys.gender.tr(),
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff505050),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: LanguageService.languageCode == "ar" ? 0.5 : 0.8,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Container(
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                height: 50.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        widget.visibleSave.value = true;
                        widget.changeGender.value = "Man";
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 120.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: widget.changeGender.value == "Man"
                                ? const Color(0xff402CDD)
                                : const Color(0xffD3D3D3),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.man.tr(),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: widget.changeGender.value == "Man"
                                ? const Color(0xff1D1D1D)
                                : const Color(0xffD3D3D3),
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
                            height: LanguageService.languageCode == "ar"
                                ? 0.5
                                : 0.8,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.visibleSave.value = true;
                        widget.changeGender.value = "Women";
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 120.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: widget.changeGender.value!.startsWith("Wom")
                                ? const Color(0xff402CDD)
                                : const Color(0xffD3D3D3),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.women.tr(),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: widget.changeGender.value!.startsWith("Wom")
                                ? const Color(0xff1D1D1D)
                                : const Color(0xffD3D3D3),
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
                            height: LanguageService.languageCode == "ar"
                                ? 0.5
                                : 0.8,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.visibleSave.value = true;
                        widget.changeGender.value = "Other";
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 120.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: widget.changeGender.value == "Other"
                                ? const Color(0xff402CDD)
                                : const Color(0xffD3D3D3),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.other_option.tr(),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: widget.changeGender.value == "Other"
                                ? const Color(0xff1D1D1D)
                                : const Color(0xffD3D3D3),
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
                            height: LanguageService.languageCode == "ar"
                                ? 0.5
                                : 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _personInfoWidgetOptional({
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
          valueListenable: widget.visiblePrefixOptional,
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
                                (element) => '+${controller.text.toLowerCase()}'
                                    .startsWith(element.dialCode.toLowerCase()),
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

                              if (controller.text.length > 0 && isPhone) {
                                widget.visiblePrefixOptional.value = true;
                              } else if (controller.text.length == 0 &&
                                  isPhone) {
                                widget.visiblePrefixOptional.value = false;
                              }
                              widget.visibleSave.value = true;
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

  Widget _personInfoWidget({
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
          valueListenable: widget.visiblePrefix,
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
                                            // controller.text = val.replaceFirst(
                                            //   RegExp(r'0'),
                                            //   '',
                                            // );
                                          }
                                        }
                                        widget.visibleSave.value = true;
                                        if (controller.text.length > 0 &&
                                            isPhone) {
                                          widget.visiblePrefix.value = true;
                                        } else if (controller.text.length ==
                                                0 &&
                                            isPhone) {
                                          widget.visiblePrefix.value = false;
                                        }

                                        Country newCountry = countries
                                            .firstWhere(
                                              (element) =>
                                                  '+${val.toLowerCase()}'
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
                                          String formattedText = _formatNumber(
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
                                                (LanguageService.languageCode !=
                                                    "ar")
                                                ? 8.h
                                                : 8.h,
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
                            : Directionality(
                                textDirection: TextDirection.ltr,
                                child: AppTextField(
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
                                    widget.visibleSave.value = true;
                                    if (val.length > 0 && isPhone) {
                                      widget.visiblePrefix.value = true;
                                    } else if (val.length == 0 && isPhone) {
                                      widget.visiblePrefix.value = false;
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
                                  textAlignVertical: TextAlignVertical.center,
                                  hintText:
                                      '${hint}' +
                                      "${hint2 == "" ? "" : "\n${hint2}"}",
                                  contentPadding: HWEdgeInsetsDirectional.only(
                                    start: 8,
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatNumber(String input, String countryCode) {
    if (countryCode == "") {
      return input;
    }
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

  /* String _getCountryCodeFromNumber(String num) {
    Country newCountry = countries.firstWhere(
        (element) =>
            '+${num.toLowerCase()}'.startsWith(element.dialCode.toLowerCase()),
        orElse: () => const Country(
            name: '',
            flag: '',
            code: '',
            dialCode: '',
            minLength: 0,
            maxLength: 0));
    if (newCountry.code != "") {
      return newCountry.dialCode.split("+").toList()[1];
    }
    return "";
  }*/
}
