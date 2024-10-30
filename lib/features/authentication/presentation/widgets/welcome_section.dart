import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'dart:ui' as ui;
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class WelcomeSection extends StatefulWidget {
  WelcomeSection(
      {required this.goToCreateAccount,
      required this.goToLoginSection,
      Key? key})
      : super(key: key);
  final void Function() goToCreateAccount;
  final void Function() goToLoginSection;

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection> {
  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.welcomeScreen,
    );

    super.didChangeDependencies();
  }

  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 30.0),
            child: MyTextWidget(
              LocaleKeys.welcome_page_description.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.la.copyWith(
                color: Color(0xff5D5C5D),
                letterSpacing: 0.14,
                height: 1.43,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          MyTextWidget(
            LocaleKeys.why_we_know_you_label.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.la.copyWith(
              color: Color(0xffF85555),
              letterSpacing: 0.14,
              height: 1.43,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          InkWell(
            key: TestVariables.kTestMode
                ? Key(WidgetsKey.haveAccountButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 0;
              Future.delayed(Duration(milliseconds: 100), () {
                debugPrint(
                    "/////// user_id : ${prefsRepository.myMarketId.toString()} ///////");
                debugPrint(
                    "/////// user_name: ${prefsRepository.myMarketName.toString()} ///////");
                clickButton.value = -1;
                widget.goToLoginSection.call();
              });
              FirebaseAnalyticsService.logEventForSession(
                eventName: AnalyticsEventsConst.buttonClicked,
                executedEventName:
                    AnalyticsExecutedEventNameConst.haveAlreadyAccountButton,
              );
            },
            child: ValueListenableBuilder<int>(
                valueListenable: clickButton,
                builder: (context, index, _) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: DottedBorder(
                      borderPadding: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 0.5,
                      borderType: BorderType.RRect,
                      dashPattern: [3, 3],
                      radius: Radius.circular(20.0),
                      color: index == 0
                          ? const Color(0xff707070)
                          : const Color(0xfffafafa),
                      child: Container(
                        width: 1.sw,
                        height: 60,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.white
                              : const Color(0xfffafafa),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: MyTextWidget(
                            LocaleKeys.i_have_account.tr(),
                            style: context.textTheme.displayMedium?.ra.copyWith(
                              color: Color(0xff5D5C5D),
                              letterSpacing: 0.16,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            key: TestVariables.kTestMode
                ? Key(WidgetsKey.createNewAccountButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 1;
              Future.delayed(Duration(milliseconds: 100), () {
                clickButton.value = -1;
                widget.goToCreateAccount.call();
              });
              FirebaseAnalyticsService.logEventForSession(
                eventName: AnalyticsEventsConst.buttonClicked,
                executedEventName:
                    AnalyticsExecutedEventNameConst.createNewAccountButton,
              );
            },
            child: ValueListenableBuilder<int>(
                valueListenable: clickButton,
                builder: (context, index, _) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: DottedBorder(
                      borderPadding: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 0.5,
                      borderType: BorderType.RRect,
                      dashPattern: [3, 3],
                      radius: Radius.circular(20.0),
                      color: index == 1
                          ? const Color(0xff707070)
                          : const Color(0xfffafafa),
                      child: Container(
                        width: 1.sw,
                        height: 60,
                        decoration: BoxDecoration(
                          color: index == 1
                              ? Colors.white
                              : const Color(0xfffafafa),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: MyTextWidget(
                            LocaleKeys.create_new_account.tr(),
                            style: context.textTheme.displayMedium?.ra.copyWith(
                              color: Color(0xff5D5C5D),
                              letterSpacing: 0.16,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            key: TestVariables.kTestMode
                ? Key(WidgetsKey.laterTakeLookKey)
                : null,
            onTap: () {
              Future.delayed(
                Duration(milliseconds: 100),
                () async {
                  if (prefsRepository.isVerifiedPhone != false) {
                    String? deviceId = await HelperFunctions.getDeviceId();
                    BlocProvider.of<AuthBloc>(context)
                        .add(RegisterGuestEvent(deviceId: deviceId!));
                  }
                  context.go(GRouter.config.applicationRoutes.kBasePage);
                },
              );
              //////////////////////////
              FirebaseAnalyticsService.logEventForSession(
                eventName: AnalyticsEventsConst.buttonClicked,
                executedEventName:
                    AnalyticsExecutedEventNameConst.laterTakeLookButton,
              );
              //////////////////////////
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MyTextWidget(
                LocaleKeys.later_take_look.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.ra.copyWith(
                  color: Color(0xff4d84ff),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
          ),
        ],
      ),
    );
  }
}
