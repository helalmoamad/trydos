import 'dart:async';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../manager/auth_bloc.dart';

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
  Timer? retryTimer;
  int remainingSeconds = 60;
  String? lastSelectedMethod;

  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = GetIt.I<AuthBloc>();

    // Reset the SendOTP status when initializing the page
    // This ensures clean state when returning to this page
    if (authBloc.state.sendOtpStatus == SendOtpStatus.failure ||
        authBloc.state.sendOtpStatus == SendOtpStatus.success) {
      // Reset to initial state
      authBloc.emit(authBloc.state.copyWith(
        sendOtpStatus: SendOtpStatus.init,
        sendOtpError: null,
      ));
    }

    // Reset local timer state
    remainingSeconds = 60;
    retryTimer?.cancel();
    lastSelectedMethod = null;
  }

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.verificationMethodsScreen,
    );

    // Additional safety check when dependencies change (like when returning to page)
    // Reset timer state if it's still running from previous session
    if (remainingSeconds < 60 && remainingSeconds > 0) {
      remainingSeconds = 60;
      retryTimer?.cancel();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    retryTimer?.cancel();

    // Optionally reset the SendOTP status when leaving the page
    // This ensures clean state for next time
    if (authBloc.state.sendOtpStatus == SendOtpStatus.failure) {
      authBloc.emit(authBloc.state.copyWith(
        sendOtpStatus: SendOtpStatus.init,
        sendOtpError: null,
      ));
    }

    super.dispose();
  }

  void startRetryTimer() {
    remainingSeconds = 60;
    retryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void sendOtp(String method) {
    lastSelectedMethod = method;
    int isViaWhatsApp = method == 'whatsapp' ? 1 : 0;

    authBloc.add(SendOtpEvent(
      phone: widget.phoneNumber,
      isViaWhatsApp: isViaWhatsApp,
    ));
  }

  Widget buildLoadingOrTimer(SendOtpStatus status) {
    if (status == SendOtpStatus.loading) {
      return Container(
        height: 40,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff388cff)),
          ),
        ),
      );
    } else if (status == SendOtpStatus.failure) {
      if (remainingSeconds > 0) {
        return Container(
          height: 40,
          child: Center(
            child: MyTextWidget(
              '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()} ${remainingSeconds}s',
              style: context.textTheme.titleMedium?.ra.copyWith(
                color: Color(0xff5D5C5D),
              ),
            ),
          ),
        );
      } else {
        return Container(
          height: 40,
          child: Center(
            child: InkWell(
              onTap: () {
                if (lastSelectedMethod != null) {
                  sendOtp(lastSelectedMethod!);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xff388cff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MyTextWidget(
                  LocaleKeys.resend_code.tr(),
                  style: context.textTheme.titleMedium?.ra.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    // For init, success, or any other status, show empty space
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state.sendOtpStatus == SendOtpStatus.success) {
          // Cancel any running timer before navigation
          retryTimer?.cancel();
          remainingSeconds = 60;

          // Navigate based on the selected method
          if (lastSelectedMethod == 'whatsapp') {
            widget.onChooseWhatsapp();
          } else if (lastSelectedMethod == 'sms') {
            widget.onChooseSms();
          }
        } else if (state.sendOtpStatus == SendOtpStatus.failure) {
          // Only start timer if it's not already running
          if (retryTimer?.isActive != true) {
            startRetryTimer();
          }
        } else if (state.sendOtpStatus == SendOtpStatus.init) {
          // Reset timer when status is reset to init
          retryTimer?.cancel();
          remainingSeconds = 60;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        bloc: authBloc,
        builder: (context, state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 40.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      SvgPicture.asset(AppAssets.phoneOtpSvg,
                          width: 15, height: 15),
                10.horizontalSpace,
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextWidget(
                      LocaleKeys.we_will_send_code.tr(),
                            style: context.textTheme.titleMedium?.ra.copyWith(
                                color: Color(0xff5D5C5D), height: 1.42),
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
                                    .copyWith(
                                        color: Color(0xffC4C2C2), height: 1.25),
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
                                    .copyWith(
                                        color: Color(0xffC4C2C2), height: 1.25),
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
                height: 30,
              ),
              buildLoadingOrTimer(state.sendOtpStatus),
              SizedBox(
                height: 15,
        ),
        Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    key: TestVariables.kTestMode
                        ? Key(WidgetsKeys.chooseWhatsappButtonKey)
                        : null,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                          onTap: (state.sendOtpStatus ==
                                      SendOtpStatus.loading ||
                                  (state.sendOtpStatus ==
                                          SendOtpStatus.failure &&
                                      remainingSeconds > 0))
                              ? null
                              : () {
                      clickButton.value = 0;
                      Future.delayed(
                        Duration(milliseconds: 100),
                        () {
                          clickButton.value = -1;
                                      sendOtp('whatsapp');
                        },
                      );
                      ////////////////
                      FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                            .chooseWhatsappButton,
                      );
                    },
                    child: ValueListenableBuilder<int>(
                        valueListenable: clickButton,
                        builder: (context, index, _) {
                                bool isDisabled = state.sendOtpStatus ==
                                        SendOtpStatus.loading ||
                                    (state.sendOtpStatus ==
                                            SendOtpStatus.failure &&
                                        remainingSeconds > 0);
                                return Opacity(
                                  opacity: isDisabled ? 0.5 : 1.0,
                                  child: DottedBorder(
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                children: [
                                          SvgPicture.asset(
                                              AppAssets.whatsappSvg,
                                              width: 20,
                                              height: 20),
                                  10.horizontalSpace,
                                  MyTextWidget(
                                    LocaleKeys.whatsApp.tr(),
                                            style: context
                                                .textTheme.titleLarge?.ra
                                        .copyWith(
                                            color: Color(0xff5D5C5D),
                                            height: 1.42),
                                  ),
                                ],
                                      ),
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
                          onTap: (state.sendOtpStatus ==
                                      SendOtpStatus.loading ||
                                  (state.sendOtpStatus ==
                                          SendOtpStatus.failure &&
                                      remainingSeconds > 0))
                              ? null
                              : () {
                      clickButton.value = 1;
                      Future.delayed(
                        Duration(milliseconds: 100),
                        () {
                          clickButton.value = -1;
                                      sendOtp('sms');
                        },
                      );
                      ///////////////////
                      FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                        executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .chooseSmsButton,
                      );
                    },
                    child: ValueListenableBuilder<int>(
                        valueListenable: clickButton,
                        builder: (context, index, _) {
                                bool isDisabled = state.sendOtpStatus ==
                                        SendOtpStatus.loading ||
                                    (state.sendOtpStatus ==
                                            SendOtpStatus.failure &&
                                        remainingSeconds > 0);
                                return Opacity(
                                  opacity: isDisabled ? 0.5 : 1.0,
                                  child: DottedBorder(
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppAssets.smsSvg,
                                      width: 20, height: 20),
                                  10.horizontalSpace,
                                  MyTextWidget(
                                    LocaleKeys.sms.tr(),
                                            style: context
                                                .textTheme.titleLarge?.ra
                                        .copyWith(
                                            color: Color(0xff5D5C5D),
                                            height: 1.42),
                                  ),
                                ],
                                      ),
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
        },
      ),
    );
  }
}
