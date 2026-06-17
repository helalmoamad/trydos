import 'dart:async';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/authentication/presentation/widgets/pin_item.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';
import 'dart:ui' as ui;

class VerifyOtp extends StatefulWidget {
  VerifyOtp({
    Key? key,
    required this.methodIcon,
    required this.fromLogin,
    required this.isVisWhatsApp,
    required this.navigateToAddName,
    required this.navigateTocartOrProfile,
    required this.onLoginFailed,
    required this.goBack,
    required this.navigateToProfile,
    required this.fromProfile,
    required this.fromExpired,
    required this.phoneNumber,
  }) : super(key: key);
  final String methodIcon;
  final bool fromLogin;
  final bool fromExpired;
  final bool fromProfile;
  final String phoneNumber;
  final void Function() onLoginFailed;
  final void Function() goBack;
  final void Function() navigateToAddName;
  final void Function() navigateTocartOrProfile;
  final void Function() navigateToProfile;
  final int isVisWhatsApp;
  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with FormStateMinxin {
  late AuthBloc authBloc;
  CountdownTimerController? countdownTimerController;

  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int endTime = (DateTime.now().millisecondsSinceEpoch + 1000 * 120);
  late final ValueNotifier<bool> enabledResendNotifier;
  late final ValueNotifier<int> checkOtp;

  int attempt = 1;

  void onEnd() {
    prefsRepository.setTimerForOtpRunning(false);
    prefsRepository.removeOtpTimerEndTime();
    checkOtp.value = 0;
    enabledResendNotifier.value = true;
    ///////////////////////////
    FirebaseAnalyticsService.logEventForSession(
      executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
      eventName: AnalyticsEventsConst.TIMER_EXPIRED,
      extraParams: {
        'mission_name': widget.fromLogin ? 'login' : 'signup',
        'method': widget.isVisWhatsApp == 1 ? 'whatsapp' : 'sms',
      },
    );
  }

  bool _eventLogged = false;

  @override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': AuthScreenConst.OTP_INPUT_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    enabledResendNotifier = ValueNotifier<bool>(false);
    // Try to resume existing timer if running
    final now = DateTime.now().millisecondsSinceEpoch;
    final savedEnd = prefsRepository.otpTimerEndTime;
    if (prefsRepository.isTimerForOtpRunning ?? false &&
        savedEnd != null &&
        savedEnd > now) {
      endTime = savedEnd!;
      enabledResendNotifier.value = false;
    } else {
      endTime = now + 1000 * 120;
      prefsRepository.setOtpTimerEndTime(endTime);
      prefsRepository.setTimerForOtpRunning(true);
      enabledResendNotifier.value = false;
    }

    if (countdownTimerController == null) {
      countdownTimerController = CountdownTimerController(
        endTime: endTime,
        onEnd: onEnd,
      );
    }
    checkOtp = ValueNotifier<int>(0);
    authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
          p.sendOtpStatus != c.sendOtpStatus &&
          c.sendOtpStatus == SendOtpStatus.failure,
      listener: (context, state) {
        //   showWarningMessage(context, state.sendOtpError.toString());
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) =>
            p.verifyOtpInProfileStatus != c.verifyOtpInProfileStatus,
        listener: (context, state) {
          if (state.verifyOtpInProfileStatus ==
              VerifyOtpInProfileStatus.failure) {
            checkOtp.value = 2;
          } else if (state.verifyOtpInProfileStatus ==
              VerifyOtpInProfileStatus.success) {
            checkOtp.value = 1;

            Future.delayed(const Duration(milliseconds: 700), () {
              widget.navigateToProfile.call();
            });
          }
        },
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.verifyOtpFromGuestStatus != c.verifyOtpFromGuestStatus,
          listener: (context, state) {
            if (state.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.failure) {
              checkOtp.value = 2;
            } else if (state.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.success) {
              checkOtp.value = 1;
              widget.navigateTocartOrProfile.call();
              Future.delayed(const Duration(milliseconds: 700), () {
                widget.navigateToAddName.call();
              });
            }
          },
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (p, c) =>
                p.verifyOtpSignInStatus != c.verifyOtpSignInStatus,
            listener: (context, state) {
              if (state.verifyOtpSignInStatus ==
                  VerifyOtpSignInStatus.failure) {
                if (!widget.fromExpired && !widget.fromProfile) {
                  if (state.signInErrorMessage == 'auth-001') {
                    context.go(
                      GRouter
                              .config
                              .applicationRoutes
                              .kNumberNotRegisteredPage +
                          '?phoneNumber=${widget.phoneNumber}',
                      extra: widget.onLoginFailed,
                    );
                    /////////////////////////////////////////////

                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
                      eventName: AnalyticsEventsConst.EXCEPTION,
                      extraParams: {
                        'description': 'phone Number Not Registered',
                        'context': widget.fromLogin ? 'login' : 'signup',
                        'mission_name': widget.fromLogin ? 'login' : 'signup',
                      },
                    );

                    return;
                  } else {
                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
                      eventName: AnalyticsEventsConst.EXCEPTION,
                      extraParams: {
                        'description': 'otp Failed',
                        'context': widget.fromLogin ? 'login' : 'signup',
                        'mission_name': widget.fromLogin ? 'login' : 'signup',
                      },
                    );
                  }
                }
                checkOtp.value = 2;
              } else if (state.verifyOtpSignInStatus ==
                  VerifyOtpSignInStatus.success) {
                checkOtp.value = 1;

                Future.delayed(const Duration(milliseconds: 700), () {
                  widget.navigateToAddName.call();
                });
                /////////////////////////////////

                FirebaseAnalyticsService.logEventForSession(
                  executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
                  eventName: AnalyticsEventsConst.VERIFY_OTP,
                  extraParams: {
                    'status': 'success',
                    'attempt': attempt.toString(),
                    'mission_name': widget.fromLogin ? 'login' : 'signup',
                    'method': widget.isVisWhatsApp == 1 ? 'whatsapp' : 'sms',
                  },
                );
              }
            },
            child: BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) =>
                  p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
              listener: (context, state) {
                if (state.verifyOtpSignUpStatus ==
                    VerifyOtpSignUpStatus.failure) {
                  if (state.signUpErrorMessage == 'auth-001') {
                    debugPrint('auth-00122');
                    context.go(
                      GRouter.config.applicationRoutes.kUserExistPage +
                          '?phoneNumber=${widget.phoneNumber}',
                    );
                    /////////////////////////

                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
                      eventName: AnalyticsEventsConst.EXCEPTION,
                      extraParams: {
                        'description': 'user Already Exists',
                        'context': widget.fromLogin ? 'login' : 'signup',
                        'mission_name': widget.fromLogin ? 'login' : 'signup',
                      },
                    );
                    return;
                  } else {
                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
                      eventName: AnalyticsEventsConst.EXCEPTION,
                      extraParams: {
                        'description': 'otp Failed',
                        'context': widget.fromLogin ? 'login' : 'signup',
                        'mission_name': widget.fromLogin ? 'login' : 'signup',
                      },
                    );
                  }

                  checkOtp.value = 2;
                } else if (state.verifyOtpSignUpStatus ==
                    VerifyOtpSignUpStatus.success) {
                  checkOtp.value = 1;

                  Future.delayed(const Duration(milliseconds: 700), () {
                    widget.navigateToAddName.call();
                  });
                  /////////////////////////

                  FirebaseAnalyticsService.logEventForSession(
                    executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
                    eventName: AnalyticsEventsConst.VERIFY_OTP,
                    extraParams: {
                      'status': 'success',
                      'attempt': attempt.toString(),
                      'mission_name': widget.fromLogin ? 'login' : 'signup',
                      'method': widget.isVisWhatsApp == 1 ? 'whatsapp' : 'sms',
                    },
                  );
                }
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (p, c) =>
                    p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
                    p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment:
                        (state.verifyOtpFromGuestStatus !=
                                VerifyOtpFromGuestStatus.loading &&
                            state.verifyOtpFromGuestStatus !=
                                VerifyOtpFromGuestStatus.success &&
                            state.verifyOtpSignInStatus !=
                                VerifyOtpSignInStatus.loading &&
                            state.verifyOtpSignUpStatus !=
                                VerifyOtpSignUpStatus.loading &&
                            state.verifyOtpSignInStatus !=
                                VerifyOtpSignInStatus.success &&
                            state.verifyOtpSignUpStatus !=
                                VerifyOtpSignUpStatus.success)
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: HWEdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.phoneOtpSvg,
                                  width: 15.w,
                                  height: 15.h,
                                ),
                                10.horizontalSpace,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextWidget(
                                      LocaleKeys.we_have_sent_code.tr(),
                                      style: context.textTheme.titleMedium?.rq
                                          .copyWith(
                                            color: const Color(0xff5D5C5D),
                                            height: 1.42,
                                          ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: HWEdgeInsets.only(top: 3.0),
                                          child: SvgPicture.asset(
                                            AppAssets.phoneCallSvg,
                                            width: 10.w,
                                            height: 10.h,
                                          ),
                                        ),
                                        5.horizontalSpace,
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: MyTextWidget(
                                            widget.phoneNumber,
                                            textAlign: TextAlign.start,
                                            style: context
                                                .textTheme
                                                .titleMedium
                                                ?.rq
                                                .copyWith(
                                                  color: const Color(
                                                    0xffC4C2C2,
                                                  ),
                                                  height: 1.25,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    5.verticalSpace,
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          widget.methodIcon,
                                          width: 10.w,
                                          height: 10.h,
                                        ),
                                        5.horizontalSpace,
                                        MyTextWidget(
                                          LocaleKeys
                                                  .please_enter_the_verification_cod
                                                  .tr() +
                                              ' ${widget.methodIcon == AppAssets.whatsappSvg ? LocaleKeys.whatsApp.tr() : LocaleKeys.sms.tr()}',
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.rq
                                              .copyWith(
                                                color: const Color(0xffC4C2C2),
                                                height: 1.25,
                                              ),
                                        ),
                                      ],
                                    ),
                                    4.verticalSpace,
                                    ValueListenableBuilder<bool>(
                                      valueListenable: enabledResendNotifier,
                                      builder: (context, resend, _) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.registerInfoSvg,
                                                  width: 10.w,
                                                  height: 10.h,
                                                ),
                                                5.horizontalSpace,
                                                MyTextWidget(
                                                  resend
                                                      ? LocaleKeys
                                                            .you_can_resend_code
                                                            .tr()
                                                      : LocaleKeys
                                                            .didnt_receive_code
                                                            .tr(),
                                                  style: context
                                                      .textTheme
                                                      .titleMedium
                                                      ?.rq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xffC4C2C2,
                                                        ),
                                                        height: 1.25,
                                                      ),
                                                ),
                                                4.horizontalSpace,
                                                ValueListenableBuilder<bool>(
                                                  valueListenable:
                                                      enabledResendNotifier,
                                                  builder: (context, enabledResend, _) {
                                                    if (!enabledResend)
                                                      return Directionality(
                                                        textDirection: ui
                                                            .TextDirection
                                                            .ltr,
                                                        child: CountdownTimer(
                                                          widgetBuilder: (_, remainingTime) {
                                                            String seconds =
                                                                (remainingTime
                                                                            ?.sec ??
                                                                        0) <
                                                                    10
                                                                ? '0${remainingTime?.sec}'
                                                                : '${remainingTime?.sec}';
                                                            return MyTextWidget(
                                                              key:
                                                                  TestVariables
                                                                      .kTestMode
                                                                  ? const Key(
                                                                      WidgetsKeys
                                                                          .otpRemainingTimeKey,
                                                                    )
                                                                  : null,
                                                              '0${remainingTime?.min ?? '0'} : $seconds ',
                                                              style: context
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff4D84FF,
                                                                    ),
                                                                    height:
                                                                        1.25,
                                                                  ),
                                                            );
                                                          },
                                                          controller:
                                                              countdownTimerController,
                                                          endWidget:
                                                              const SizedBox(),
                                                        ),
                                                      );
                                                    return InkWell(
                                                      onTap: _onResendSucceed,
                                                      child: MyTextWidget(
                                                        key:
                                                            TestVariables
                                                                .kTestMode
                                                            ? const Key(
                                                                WidgetsKeys
                                                                    .resendCodeButtonKey,
                                                              )
                                                            : null,
                                                        LocaleKeys.resend_code
                                                                .tr() +
                                                            " ",
                                                        style: context
                                                            .textTheme
                                                            .titleMedium
                                                            ?.rq
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xff4D84FF,
                                                                  ),
                                                              height: 1.25,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                resend
                                                    ? MyTextWidget(
                                                        LocaleKeys.or.tr() +
                                                            " ",
                                                        style: context
                                                            .textTheme
                                                            .titleMedium
                                                            ?.rq
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xff5D5C5D,
                                                                  ),
                                                              height: 1.25,
                                                            ),
                                                      )
                                                    : const SizedBox.shrink(),
                                                resend
                                                    ? InkWell(
                                                        onTap: widget.goBack,
                                                        child: MyTextWidget(
                                                          LocaleKeys
                                                              .change_method
                                                              .tr(),
                                                          maxLines: 2,
                                                          style: context
                                                              .textTheme
                                                              .titleMedium
                                                              ?.rq
                                                              .copyWith(
                                                                color:
                                                                    const Color(
                                                                      0xff4D84FF,
                                                                    ),
                                                                height: 1.25,
                                                              ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                            resend
                                                ? Padding(
                                                    padding: HWEdgeInsets.only(
                                                      left: 15.w,
                                                    ),
                                                    child: InkWell(
                                                      onTap: widget.goBack,
                                                      child: MyTextWidget(
                                                        LocaleKeys
                                                            .the_method_of_receiving
                                                            .tr(),
                                                        maxLines: 2,
                                                        style: context
                                                            .textTheme
                                                            .titleMedium
                                                            ?.rq
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xff4D84FF,
                                                                  ),
                                                              height: 1.25,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      25.verticalSpace,
                      Padding(
                        padding: HWEdgeInsets.symmetric(horizontal: 20.w),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: enabledResendNotifier,
                          builder: (context, isExpired, _) {
                            return ValueListenableBuilder<int>(
                              valueListenable: checkOtp,
                              builder: (context, codeStatus, _) {
                                return BlocBuilder<AuthBloc, AuthState>(
                                  buildWhen: (p, c) =>
                                      p.sendOtpStatus != c.sendOtpStatus,
                                  builder: (context, state) {
                                    if (state.sendOtpStatus ==
                                        SendOtpStatus.loading) {
                                      return Center(
                                        child: SizedBox(
                                          width: 16.w,
                                          height: 16.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.w,
                                          ),
                                        ),
                                      );
                                    } else if (state.sendOtpStatus ==
                                        SendOtpStatus.failure) {
                                      return const _FailureWithTimerAndTryAgain();
                                    } else {
                                      // success أو الحالة الافتراضية: الحقول كما هي الآن
                                      return Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            PinItem(
                                              key: const Key('otp_item_1'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              controller: form.controllers[0],
                                              wrongCode: codeStatus == 2,
                                              index: 0,
                                              pasteOtpCode: pasteOtpCode,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              autoFocus: true,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_2'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              isExpired: isExpired,
                                              controller: form.controllers[1],
                                              wrongCode: codeStatus == 2,
                                              index: 1,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_3'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              index: 2,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              controller: form.controllers[2],
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_4'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              index: 3,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              controller: form.controllers[3],
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_5'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              isExpired: isExpired,
                                              index: 4,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              controller: form.controllers[4],
                                              autoFocus: false,
                                            ),
                                            PinItem(
                                              key: const Key('otp_item_6'),
                                              borderColor: codeStatus == 1
                                                  ? const Color(0xff35CE3F)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFF5F61)
                                                  : isExpired
                                                  ? const Color(0xffFFBC26)
                                                  : const Color(0xff4D84FF),
                                              isExpired: isExpired,
                                              contentColor: codeStatus == 1
                                                  ? const Color(0xffF4FFF4)
                                                  : codeStatus == 2
                                                  ? const Color(0xffFDF5F5)
                                                  : const Color(0xffFAFAFA),
                                              index: 5,
                                              wrongCode: codeStatus == 2,
                                              onChange: () {
                                                checkOtp.value = 0;
                                              },
                                              checkOtp: () {
                                                debugPrint(
                                                  '/// checkOtp //////',
                                                );
                                                debugPrint(
                                                  prefsRepository
                                                      .verificationId,
                                                );
                                                if (prefsRepository
                                                        .verificationId !=
                                                    null) {
                                                  debugPrint(
                                                    '/// verificationId not null //////',
                                                  );
                                                  String insertedCode =
                                                      form.controllers[0].text +
                                                      form.controllers[1].text +
                                                      form.controllers[2].text +
                                                      form.controllers[3].text +
                                                      form.controllers[4].text +
                                                      form.controllers[5].text;
                                                  if (widget.fromProfile) {
                                                    authBloc.add(
                                                      VerifyOtpInProfileEvent(
                                                        verificationId:
                                                            prefsRepository
                                                                .verificationId!,
                                                        otp: insertedCode,
                                                      ),
                                                    );
                                                  } else if (widget
                                                      .fromExpired) {
                                                    authBloc.add(
                                                      VerifyOtpFromGuestEvent(
                                                        verificationId:
                                                            prefsRepository
                                                                .verificationId!,
                                                        otp: insertedCode,
                                                      ),
                                                    );
                                                  } else if (widget.fromLogin) {
                                                    debugPrint(
                                                      '/// fromLogin //////',
                                                    );

                                                    authBloc.add(
                                                      VerifyOtpSignInEvent(
                                                        verificationId:
                                                            prefsRepository
                                                                .verificationId!,
                                                        otp: insertedCode,
                                                        phone:
                                                            widget.phoneNumber,
                                                      ),
                                                    );

                                                    /////////////////////////////////////

                                                    FirebaseAnalyticsService.logEventForSession(
                                                      executedEventName:
                                                          AuthScreenConst
                                                              .OTP_INPUT_SCREEN,
                                                      eventName:
                                                          AnalyticsEventsConst
                                                              .VERIFY_OTP_SIGNIN,
                                                      extraParams: {
                                                        'mission_name':
                                                            widget.fromLogin
                                                            ? 'login'
                                                            : 'signup',
                                                        'method':
                                                            widget.isVisWhatsApp ==
                                                                1
                                                            ? 'whatsapp'
                                                            : 'sms',
                                                      },
                                                    );
                                                  } else {
                                                    authBloc.add(
                                                      VerifyOtpSignUpEvent(
                                                        verificationId:
                                                            prefsRepository
                                                                .verificationId!,
                                                        otp: insertedCode,
                                                      ),
                                                    );

                                                    /////////////////////////////////////
                                                    FirebaseAnalyticsService.logEventForSession(
                                                      executedEventName:
                                                          AuthScreenConst
                                                              .OTP_INPUT_SCREEN,
                                                      eventName:
                                                          AnalyticsEventsConst
                                                              .VERIFY_OTP_SIGNUP,
                                                      extraParams: {
                                                        'mission_name':
                                                            widget.fromLogin
                                                            ? 'login'
                                                            : 'signup',
                                                        'method':
                                                            widget.isVisWhatsApp ==
                                                                1
                                                            ? 'whatsapp'
                                                            : 'sms',
                                                      },
                                                    );
                                                  }
                                                } else {
                                                  debugPrint(
                                                    '/// verificationId is null //////',
                                                  );
                                                  showWarningMessage(
                                                    context,
                                                    LocaleKeys
                                                        .please_wait_5_seconds
                                                        .tr(),
                                                  );
                                                  pasteOtpCode('');
                                                  //widget.checkOtp.value = 2;
                                                  /////////////////////////////////////

                                                  FirebaseAnalyticsService.logEventForSession(
                                                    executedEventName:
                                                        AuthScreenConst
                                                            .OTP_INPUT_SCREEN,
                                                    eventName:
                                                        AnalyticsEventsConst
                                                            .EXCEPTION,
                                                    extraParams: {
                                                      'description':
                                                          'please Wait 5 Seconds',
                                                      'context':
                                                          widget.fromLogin
                                                          ? 'login'
                                                          : 'signup',
                                                      'mission_name':
                                                          widget.fromLogin
                                                          ? 'login'
                                                          : 'signup',
                                                    },
                                                  );
                                                }
                                              },
                                              controller: form.controllers[5],
                                              autoFocus: false,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      (checkOtp.value == 2 || enabledResendNotifier.value)
                          ? 20.verticalSpace
                          : 120.verticalSpace,
                      ValueListenableBuilder<int>(
                        valueListenable: checkOtp,
                        builder: (context, codeStatus, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: enabledResendNotifier,
                            builder: (context, isExpired, _) {
                              return codeStatus == 2 || isExpired
                                  ? Column(
                                      children: [
                                        MyTextWidget(
                                          codeStatus == 2
                                              ? LocaleKeys
                                                    .please_correct_code_sent_to_your_phone
                                                    .tr()
                                              : LocaleKeys
                                                    .the_code_sent_has_expired
                                                    .tr(),
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.rq
                                              .copyWith(
                                                color: const Color(0xff5D5C5D),
                                                height: 1.25,
                                              ),
                                        ),
                                        100.verticalSpace,
                                      ],
                                    )
                                  : const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  pasteOtpCode(String text) {
    form.controllers[0].text = text[0];
    form.controllers[1].text = text[1];
    form.controllers[2].text = text[2];
    form.controllers[3].text = text[3];
    form.controllers[4].text = text[4];
    form.controllers[5].text = text[5];
    if (widget.fromProfile) {
      authBloc.add(
        VerifyOtpInProfileEvent(
          verificationId: prefsRepository.verificationId!,
          otp: text,
        ),
      );
    } else if (widget.fromExpired) {
      authBloc.add(
        VerifyOtpFromGuestEvent(
          verificationId: prefsRepository.verificationId!,
          otp: text,
        ),
      );
    } else if (widget.fromLogin) {
      authBloc.add(
        VerifyOtpSignInEvent(
          verificationId: prefsRepository.verificationId!,
          otp: text,
          phone: widget.phoneNumber,
        ),
      );
    } else {
      authBloc.add(
        VerifyOtpSignUpEvent(
          verificationId: prefsRepository.verificationId!,
          otp: text,
        ),
      );
    }
  }

  void _onResendSucceed() {
    attempt = attempt + 1;
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    prefsRepository.setOtpTimerEndTime(endTime);
    prefsRepository.setTimerForOtpRunning(true);
    countdownTimerController = CountdownTimerController(
      endTime: endTime,
      onEnd: onEnd,
    );
    enabledResendNotifier.value = false;
    checkOtp.value = 0;
    authBloc.add(
      SendOtpEvent(
        phone: widget.phoneNumber,
        isViaWhatsApp: widget.isVisWhatsApp,
      ),
    );
    ////////////////////

    FirebaseAnalyticsService.logEventForSession(
      executedEventName: AuthScreenConst.OTP_INPUT_SCREEN,
      eventName: AnalyticsEventsConst.RESEND_OTP,
      extraParams: {
        'mission_name': widget.fromLogin ? 'login' : 'signup',
        'method': widget.isVisWhatsApp == 1 ? 'whatsapp' : 'sms',
        'button_name': AnalyticsButtonsEventNameConst.RESEND_OTP_BUTTON,
        'attempt': attempt.toString(),
      },
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 6;
}

class _FailureWithTimerAndTryAgain extends StatelessWidget {
  const _FailureWithTimerAndTryAgain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyTextWidget(
        LocaleKeys.otp_error_try_again_later.tr(),
        style: Theme.of(context).textTheme.bodySmall?.rq.copyWith(
          fontSize: 12.sp,
          color: const Color(0xFF1D1D1D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
