import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/authentication/presentation/widgets/phone_form_fields.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';

import '../../../../common/constant/countries.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';

class InsertPhoneTab extends StatefulWidget {
  const InsertPhoneTab(
      {this.fromLogin = false,
      required this.moveToNextStep,
      required this.focusNode,
      Key? key})
      : super(key: key);
  final bool fromLogin;
  final void Function(String phoneNumber) moveToNextStep;
  final FocusNode focusNode;

  @override
  State<InsertPhoneTab> createState() => _InsertPhoneTabState();
}

class _InsertPhoneTabState extends State<InsertPhoneTab> with FormStateMinxin {
  final ValueNotifier<Country> countryChanged = ValueNotifier(Country(
      name: '', flag: '', code: '', dialCode: '', minLength: 0, maxLength: 0));
  final ValueNotifier<bool> displaySubmit = ValueNotifier(false);
  final ValueNotifier<bool> changeTextInputFieldContent = ValueNotifier(false);
  int maxLength = 25;

  @override
  void initState() {
    widget.focusNode.requestFocus();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffFFFFFF),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    ///////////////////
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.insertPhoneScreen,
    );
    ///////////////////
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('yes rebuilt');
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 40.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                    widget.fromLogin
                        ? AppAssets.enterSvg
                        : AppAssets.phoneCallOutlinedSvg,
                    width: 15,
                    height: 15),
                10.horizontalSpace,
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextWidget(
                      LocaleKeys.enter_your_number.tr() +
                          " " +
                          (widget.fromLogin
                              ? LocaleKeys.to_login.tr()
                              : LocaleKeys.registered_with_us.tr()),
                      style: context.textTheme.titleMedium?.ra
                          .copyWith(color: Color(0xff5D5C5D), height: 1.42),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: HWEdgeInsets.only(top: 3.0),
                          child: SvgPicture.asset(AppAssets.registerInfoSvg,
                              width: 10, height: 10),
                        ),
                        5.horizontalSpace,
                        MyTextWidget(
                          LocaleKeys.enter_your_phonenumber_registered_with_us
                              .tr(),
                          textAlign: TextAlign.start,
                          style: context.textTheme.titleMedium?.ra
                              .copyWith(color: Color(0xffC4C2C2), height: 1.25),
                        )
                      ],
                    ),
                    if (widget.fromLogin) ...{
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(AppAssets.phoneOtpSvg,
                              width: 10, height: 10),
                          5.horizontalSpace,
                          SizedBox(
                            width: 1.sw - 120,
                            child: MyTextWidget(
                              LocaleKeys.we_will_send_code.tr(),
                              style: context.textTheme.titleMedium?.ra.copyWith(
                                  color: Color(0xffC4C2C2), height: 1.25),
                            ),
                          )
                        ],
                      ),
                    } else ...{
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: HWEdgeInsets.only(top: 3.0),
                            child: SvgPicture.asset(AppAssets.privacySvg,
                                width: 10, height: 10),
                          ),
                          5.horizontalSpace,
                          SizedBox(
                            width: 1.sw - 120,
                            child: MyTextWidget(
                              LocaleKeys.your_Privacy.tr(),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: context.textTheme.titleMedium?.ra.copyWith(
                                  color: Color(0xffC4C2C2), height: 1.25.h),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      )
                    }
                  ],
                )
              ],
            ),
          ]),
        ),
        SizedBox(height: 29.h),
        Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 20.0),
            child: ValueListenableBuilder<bool>(
                valueListenable: displaySubmit,
                builder: (context, display, _) {
                  return PhoneFormField(
                    key: TestVariables.kTestMode
                        ? Key(WidgetsKey.loginPhoneFormFieldKey)
                        : null,
                    focusNode: widget.focusNode,
                    onChange: (String? text) {
                      Country newCountry = countries.firstWhere(
                          (element) => '+${text?.toLowerCase()}'
                              .startsWith(element.dialCode.toLowerCase()),
                          orElse: () => Country(
                              name: '',
                              flag: '',
                              code: '',
                              dialCode: '',
                              minLength: 0,
                              maxLength: 0));
                      if (text?.isNotEmpty ?? false) {
                        displaySubmit.value =
                            text!.replaceAll(' ', '').length >=
                                    (newCountry.minLength +
                                        newCountry.dialCode.length -
                                        1) &&
                                text.replaceAll(' ', '').length <=
                                    (newCountry.maxLength +
                                        newCountry.dialCode.length -
                                        1);
                      }
                      countryChanged.value = newCountry;
                      debugPrint(
                          'form.controllers[0].text${form.controllers[0].text}');
                      return form.controllers[0].text.isNotEmpty
                          ? form.controllers[0]
                                  .text[form.controllers[0].text.length - 1] ==
                              ' '
                          : false;
                    },
                    maxLength: maxLength - 1,
                    prefixIcon: Padding(
                      padding: HWEdgeInsets.only(left: 20.0, top: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(AppAssets.phoneCallSvg),
                          10.horizontalSpace,
                          ValueListenableBuilder<Country>(
                              valueListenable: countryChanged,
                              builder: (context, country, _) {
                                if (country.code == '')
                                  return SizedBox(
                                    width: 22.w,
                                    height: 15.h,
                                  );
                                else
                                  return CountryFlag.fromCountryCode(
                                    country.code,
                                    height: 15.h,
                                    width: 22.w,
                                    borderRadius: 4.r,
                                  );
                              }),
                          10.horizontalSpace,
                          MyTextWidget(
                            '+',
                            style: context.textTheme.bodyMedium?.rr
                                .copyWith(color: Color(0xff8E8E8E)),
                          ),
                          4.horizontalSpace
                        ],
                      ),
                    ),
                    ready: display,
                    suffixIcon: Padding(
                      padding: HWEdgeInsets.only(right: 20.0, top: 22),
                      child: !display
                          ? SizedBox(
                              width: 22.w,
                              height: 15.h,
                            )
                          : InkWell(
                              key: TestVariables.kTestMode
                                  ? Key(WidgetsKey.loginConfirmPhoneButtonKey)
                                  : null,
                              onTap: () {
                                widget.moveToNextStep
                                    .call('${form.controllers[0].text}');
                                //////////////////////////
                                FirebaseAnalyticsService.logEventForSession(
                                  eventName: AnalyticsEventsConst.buttonClicked,
                                  executedEventName:
                                      AnalyticsExecutedEventNameConst
                                          .confirmPhoneNumberButton,
                                );
                              },
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.submitArrowSvg,
                                      width: 10.w,
                                      height: 20.h,
                                    ),
                                  ]),
                            ),
                    ),
                    hintText: LocaleKeys.phone_numbber.tr(),
                    controller: form.controllers[0],
                  );
                })),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
