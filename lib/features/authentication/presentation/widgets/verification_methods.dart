import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';

class VerificationMethods extends StatefulWidget {
  VerificationMethods(
      {Key? key,
      required this.phoneNumber,
      required this.goBackToPhone,
      required this.onChooseWhatsapp,
      required this.onChooseSms})
      : super(key: key);
  final String phoneNumber;
  final void Function() onChooseWhatsapp;
  final void Function() onChooseSms;
  final void Function() goBackToPhone;

  @override
  State<VerificationMethods> createState() => _VerificationMethodsState();
}

class _VerificationMethodsState extends State<VerificationMethods> {
  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.verificationMethodsScreen,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                SvgPicture.asset(AppAssets.phoneOtpSvg, width: 15, height: 15),
                10.horizontalSpace,
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextWidget(
                      LocaleKeys.we_will_send_code.tr(),
                      style: context.textTheme.titleMedium?.ra
                          .copyWith(color: Color(0xff5D5C5D), height: 1.42),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: HWEdgeInsets.only(top: 3.0),
                          child: SvgPicture.asset(AppAssets.phoneCallSvg,
                              width: 10, height: 10),
                        ),
                        5.horizontalSpace,
                        MyTextWidget(
                          widget.phoneNumber,
                          textAlign: TextAlign.start,
                          style: context.textTheme.titleMedium?.ra
                              .copyWith(color: Color(0xffC4C2C2), height: 1.25),
                        ),
                        InkWell(
                          onTap: widget.goBackToPhone,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 4,
                              ),
                              SvgPicture.asset(AppAssets.editPenSvg,
                                  width: 10, height: 10),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(AppAssets.registerInfoSvg,
                            width: 10, height: 10),
                        5.horizontalSpace,
                        MyTextWidget(
                          LocaleKeys.choose_verification.tr(),
                          style: context.textTheme.titleMedium?.ra
                              .copyWith(color: Color(0xffC4C2C2), height: 1.25),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                  ],
                )
              ],
            ),
          ]),
        ),
        SizedBox(
          height: 45,
        ),
        Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    key: TestVariables.kTestMode
                        ? Key(WidgetsKey.chooseWhatsappButtonKey)
                        : null,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      clickButton.value = 0;
                      Future.delayed(
                        Duration(milliseconds: 100),
                        () {
                          clickButton.value = -1;
                          widget.onChooseWhatsapp.call();
                        },
                      );
                      ////////////////
                      FirebaseAnalyticsService.logEventForSession(
                        eventName: AnalyticsEventsConst.buttonClicked,
                        executedEventName: AnalyticsExecutedEventNameConst
                            .chooseWhatsappButton,
                      );
                    },
                    child: ValueListenableBuilder<int>(
                        valueListenable: clickButton,
                        builder: (context, index, _) {
                          return DottedBorder(
                            borderPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            borderType: BorderType.RRect,
                            strokeCap: StrokeCap.round,
                            strokeWidth: 0.5,
                            dashPattern: [3, 3],
                            radius: Radius.circular(20.0),
                            color: index == 0
                                ? const Color(0xff388cff)
                                : const Color(0xffF5F5F5),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? const Color(0xffffffff)
                                    : const Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppAssets.whatsappSvg,
                                      width: 20, height: 20),
                                  10.horizontalSpace,
                                  MyTextWidget(
                                    LocaleKeys.whatsApp.tr(),
                                    style: context.textTheme.titleLarge?.ra
                                        .copyWith(
                                            color: Color(0xff5D5C5D),
                                            height: 1.42),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                4.horizontalSpace,
                Expanded(
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      clickButton.value = 1;
                      Future.delayed(
                        Duration(milliseconds: 100),
                        () {
                          clickButton.value = -1;
                          widget.onChooseSms.call();
                        },
                      );
                      ///////////////////
                      FirebaseAnalyticsService.logEventForSession(
                        eventName: AnalyticsEventsConst.buttonClicked,
                        executedEventName:
                            AnalyticsExecutedEventNameConst.chooseSmsButton,
                      );
                    },
                    child: ValueListenableBuilder<int>(
                        valueListenable: clickButton,
                        builder: (context, index, _) {
                          return DottedBorder(
                            borderPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            borderType: BorderType.RRect,
                            strokeCap: StrokeCap.round,
                            strokeWidth: 0.5,
                            dashPattern: [3, 3],
                            radius: Radius.circular(20.0),
                            color: index == 1
                                ? const Color(0xff388cff)
                                : const Color(0xffF5F5F5),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: index == 1
                                    ? const Color(0xffffffff)
                                    : const Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppAssets.smsSvg,
                                      width: 20, height: 20),
                                  10.horizontalSpace,
                                  MyTextWidget(
                                    LocaleKeys.sms.tr(),
                                    style: context.textTheme.titleLarge?.ra
                                        .copyWith(
                                            color: Color(0xff5D5C5D),
                                            height: 1.42),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            )),
        10.verticalSpace,
      ],
    );
  }
}
