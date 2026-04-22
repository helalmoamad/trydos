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
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
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

class MethodsLogin extends StatefulWidget {
  MethodsLogin({
    required this.goToAddPhone,
    required this.goToScanQrCode,
    Key? key,
  }) : super(key: key);
  final void Function() goToAddPhone;
  final void Function() goToScanQrCode;

  @override
  State<MethodsLogin> createState() => _MethodsLoginState();
}

class _MethodsLoginState extends State<MethodsLogin> {
  //  bool _eventLogged = false;
  /*@override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        executedEventName: AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
        extraParams: {
          'screen_name': AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      _eventLogged = true;
    }

    super.didChangeDependencies();
  }*/

  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 30.w),
            child: MyTextWidget(
              LocaleKeys.welcome_page_description.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.lq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.14,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          MyTextWidget(
            LocaleKeys.why_we_know_you_label.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.lq.copyWith(
              color: const Color(0xffF85555),
              letterSpacing: 0.14,
              height: 1.43,
            ),
          ),
          SizedBox(height: 20.h),
          InkWell(
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.haveAccountButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              print(
                "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%lattttttter",
              );
              clickButton.value = 0;
              Future.delayed(const Duration(milliseconds: 100), () {
                debugPrint(
                  "/////// user_id : ${prefsRepository.myMarketId.toString()} ///////",
                );
                debugPrint(
                  "/////// user_name: ${prefsRepository.myMarketName.toString()} ///////",
                );
                clickButton.value = -1;
                widget.goToScanQrCode.call();
              });
              FirebaseAnalyticsService.logEventForSession(
                executedEventName:
                    AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
                eventName: AnalyticsEventsConst.LOGIN_START,
                extraParams: {
                  'button_name': AnalyticsButtonsEventNameConst
                      .I_HAVE_ALREADY_ACCOUNT_BUTTON,
                  'method': 'phone',
                },
              );
            },
            child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                return Padding(
                  padding: HWEdgeInsets.fromLTRB(20.w, 0.0, 20.w, 0.0),
                  child: DottedBorder(
                    padding: EdgeInsets.zero,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    borderType: BorderType.RRect,
                    dashPattern: const [3, 3],
                    radius: Radius.circular(20.r),
                    color: index == 0
                        ? const Color(0xff707070)
                        : const Color(0xfffafafa),
                    child: Container(
                      width: 1.sw,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Colors.white
                            : const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: MyTextWidget(
                          LocaleKeys.methods_login_scan_qr_option.tr(),
                          style: context.textTheme.displayMedium?.rq.copyWith(
                            color: const Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.createNewAccountButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 1;
              Future.delayed(const Duration(milliseconds: 100), () {
                clickButton.value = -1;
                widget.goToAddPhone.call();
              });
            },
            child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0.0, 20.w, 0.0),
                  child: DottedBorder(
                    padding: EdgeInsets.zero,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    borderType: BorderType.RRect,
                    dashPattern: const [3, 3],
                    radius: Radius.circular(20.r),
                    color: index == 1
                        ? const Color(0xff707070)
                        : const Color(0xfffafafa),
                    child: Container(
                      width: 1.sw,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: index == 1
                            ? Colors.white
                            : const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: Center(
                        child: MyTextWidget(
                          LocaleKeys.methods_login_phone_option.tr(),
                          style: context.textTheme.displayMedium?.rq.copyWith(
                            color: const Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 15.h),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.laterTakeLookKey)
                : null,
            onTap: () {
              Future.delayed(const Duration(milliseconds: 100), () async {
                /*   if (prefsRepository.isVerifiedPhone != false ||
                      (prefsRepository.isTokenExpired ??
                          false ||
                              prefsRepository.marketToken == "" ||
                              prefsRepository.marketToken == null)) {*/
                String? deviceId = await HelperFunctions.getDeviceId();
                BlocProvider.of<AuthBloc>(
                  context,
                ).add(RegisterGuestEvent(deviceId: deviceId!));
                //   }
                if (Navigator.of(context).canPop()) {
                  print(
                    "############################################################3",
                  );
                  Navigator.of(context).pop();
                } else {
                  context.go(GRouter.config.applicationRoutes.kBasePage);
                }
              });
              //////////////////////////
              FirebaseAnalyticsService.logEventForSession(
                executedEventName:
                    AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
                eventName: AnalyticsEventsConst.LATER_TAKE_LOOK_CLICKED,
                extraParams: {
                  'button_name':
                      AnalyticsButtonsEventNameConst.LATER_TAKE_LOOK_BUTTON,
                  'screen_name':
                      AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
                },
              );
              //////////////////////////
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: MyTextWidget(
                LocaleKeys.later_take_look.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.rq.copyWith(
                  color: const Color(0xff4d84ff),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}
