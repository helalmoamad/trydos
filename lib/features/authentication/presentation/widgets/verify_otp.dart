import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/authentication/presentation/widgets/pin_item.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';
import 'dart:ui' as ui;

class VerifyOtp extends StatefulWidget {
  VerifyOtp(
      {Key? key,
      required this.methodIcon,
      required this.fromLogin,
      required this.isVisWhatsApp,
      required this.navigateToAddName,
      required this.onLoginFailed,
      required this.goBack,
      required this.phoneNumber})
      : super(key: key);
  final String methodIcon;
  final bool fromLogin;
  final String phoneNumber;
  final void Function() onLoginFailed;
  final void Function() goBack;
  final void Function() navigateToAddName;
  final int isVisWhatsApp;

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with FormStateMinxin {
  late ValueNotifier<bool> _enabledResendNotifier;
  late ValueNotifier<int> checkOtp;
  int secondsDuration = 120;
  late CountdownTimerController controller;
  late int endTime;
  late AuthBloc authBloc;

  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  void onEnd() {
    controller.disposeTimer();

    if (secondsDuration < 60) {
      secondsDuration += 15;
    }
    checkOtp.value = 0;
    _enabledResendNotifier.value = true;
  }

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    _enabledResendNotifier = ValueNotifier<bool>(false);
    checkOtp = ValueNotifier<int>(0);

    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * secondsDuration;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) =>
            p.verifyOtpSignInStatus != c.verifyOtpSignInStatus,
        listener: (context, state) {
          if (state.verifyOtpSignInStatus == VerifyOtpSignInStatus.failure) {
            if (state.signInErrorMessage == 'auth-001') {
              context.go(
                  GRouter.config.applicationRoutes.kNumberNotRegisteredPage +
                      '?phoneNumber=${widget.phoneNumber}',
                  extra: widget.onLoginFailed);
              return;
            }
            checkOtp.value = 2;
          } else if (state.verifyOtpSignInStatus ==
              VerifyOtpSignInStatus.success) {
            checkOtp.value = 1;
            Future.delayed(
              Duration(milliseconds: 700),
              () {
                widget.navigateToAddName.call();
              },
            );
          }
        },
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
          listener: (context, state) {
            if (state.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.failure) {
              if (state.signUpErrorMessage == 'auth-001') {
                debugPrint('auth-00122');
                context.go(
                  GRouter.config.applicationRoutes.kUserExistPage +
                      '?phoneNumber=${widget.phoneNumber}',
                );
                return;
              }
              checkOtp.value = 2;
            } else if (state.verifyOtpSignUpStatus ==
                VerifyOtpSignUpStatus.success) {
              checkOtp.value = 1;
              Future.delayed(
                Duration(milliseconds: 700),
                () {
                  widget.navigateToAddName.call();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: (state.verifyOtpSignInStatus !=
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
                                LocaleKeys.we_have_sent_code.tr(),
                                style: context.textTheme.caption?.ra.copyWith(
                                    color: Color(0xff5D5C5D), height: 1.42),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: HWEdgeInsets.only(top: 3.0),
                                    child: SvgPicture.asset(
                                        AppAssets.phoneCallSvg,
                                        width: 10,
                                        height: 10),
                                  ),
                                  5.horizontalSpace,
                                  MyTextWidget(
                                    widget.phoneNumber,
                                    textAlign: TextAlign.start,
                                    style: context.textTheme.caption?.ra
                                        .copyWith(
                                            color: Color(0xffC4C2C2),
                                            height: 1.25),
                                  ),
                                ],
                              ),
                              5.verticalSpace,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(widget.methodIcon,
                                      width: 10, height: 10),
                                  5.horizontalSpace,
                                  MyTextWidget(
                                    LocaleKeys.please_enter_the_verification_cod
                                            .tr() +
                                        ' ${widget.methodIcon == AppAssets.whatsappSvg ? LocaleKeys.whatsApp.tr() : LocaleKeys.sms.tr()}',
                                    style: context.textTheme.caption?.ra
                                        .copyWith(
                                            color: Color(0xffC4C2C2),
                                            height: 1.25),
                                  )
                                ],
                              ),
                              4.verticalSpace,
                              ValueListenableBuilder<bool>(
                                  valueListenable: _enabledResendNotifier,
                                  builder: (context, resend, _) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                AppAssets.registerInfoSvg,
                                                width: 10,
                                                height: 10),
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
                                                  .textTheme.caption?.ra
                                                  .copyWith(
                                                      color: Color(0xffC4C2C2),
                                                      height: 1.25),
                                            ),
                                            4.horizontalSpace,
                                            ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    _enabledResendNotifier,
                                                builder: (context,
                                                    enabledResend, _) {
                                                  if (!enabledResend)
                                                    return Directionality(
                                                      textDirection:
                                                          ui.TextDirection.ltr,
                                                      child: CountdownTimer(
                                                        widgetBuilder:
                                                            (_, remainingTime) {
                                                          String seconds = (remainingTime
                                                                          ?.sec ??
                                                                      0) <
                                                                  10
                                                              ? '0${remainingTime?.sec}'
                                                              : '${remainingTime?.sec}';
                                                          return MyTextWidget(
                                                            '0${remainingTime?.min ?? '0'} : $seconds ',
                                                            style: context
                                                                .textTheme
                                                                .caption
                                                                ?.ra
                                                                .copyWith(
                                                                    color: Color(
                                                                        0xff4D84FF),
                                                                    height:
                                                                        1.25),
                                                          );
                                                        },
                                                        controller: controller,
                                                        onEnd: onEnd,
                                                        endTime: endTime,
                                                        endWidget:
                                                            const SizedBox(),
                                                      ),
                                                    );
                                                  return InkWell(
                                                    onTap: _onResendSucceed,
                                                    child: MyTextWidget(
                                                      LocaleKeys.resend_code
                                                              .tr() +
                                                          " ",
                                                      style: context
                                                          .textTheme.caption?.ra
                                                          .copyWith(
                                                              color: Color(
                                                                  0xff4D84FF),
                                                              height: 1.25),
                                                    ),
                                                  );
                                                }),
                                            resend
                                                ? MyTextWidget(
                                                    LocaleKeys.or.tr() + " ",
                                                    style: context
                                                        .textTheme.caption?.ra
                                                        .copyWith(
                                                            color: Color(
                                                                0xff5D5C5D),
                                                            height: 1.25),
                                                  )
                                                : const SizedBox.shrink(),
                                            resend
                                                ? InkWell(
                                                    onTap: widget.goBack,
                                                    child: MyTextWidget(
                                                      LocaleKeys.change_method
                                                          .tr(),
                                                      maxLines: 2,
                                                      style: context
                                                          .textTheme.caption?.ra
                                                          .copyWith(
                                                              color: Color(
                                                                  0xff4D84FF),
                                                              height: 1.25),
                                                    ),
                                                  )
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                        resend
                                            ? Padding(
                                                padding: HWEdgeInsets.only(
                                                    left: 15.0),
                                                child: InkWell(
                                                  onTap: widget.goBack,
                                                  child: MyTextWidget(
                                                    LocaleKeys
                                                        .the_method_of_receiving
                                                        .tr(),
                                                    maxLines: 2,
                                                    style: context
                                                        .textTheme.caption?.ra
                                                        .copyWith(
                                                            color: Color(
                                                                0xff4D84FF),
                                                            height: 1.25),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink()
                                      ],
                                    );
                                  }),
                            ],
                          )
                        ],
                      ),
                    ]),
                  ),
                  25.verticalSpace,
                  Padding(
                    padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                    child: ValueListenableBuilder<bool>(
                        valueListenable: _enabledResendNotifier,
                        builder: (context, isExpired, _) {
                          return ValueListenableBuilder<int>(
                              valueListenable: checkOtp,
                              builder: (context, codeStatus, _) {
                                return Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      PinItem(
                                        key: Key('otp_item_1'),
                                        borderColor: codeStatus == 1
                                            ? Color(0xff35CE3F)
                                            : codeStatus == 2
                                                ? Color(0xffFF5F61)
                                                : isExpired
                                                    ? Color(0xffFFBC26)
                                                    : Color(0xff4D84FF),
                                        isExpired: isExpired,
                                        contentColor: codeStatus == 1
                                            ? Color(0xffF4FFF4)
                                            : codeStatus == 2
                                                ? Color(0xffFDF5F5)
                                                : Color(0xffFAFAFA),
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
                                        key: Key('otp_item_2'),
                                        borderColor: codeStatus == 1
                                            ? Color(0xff35CE3F)
                                            : codeStatus == 2
                                                ? Color(0xffFF5F61)
                                                : isExpired
                                                    ? Color(0xffFFBC26)
                                                    : Color(0xff4D84FF),
                                        contentColor: codeStatus == 1
                                            ? Color(0xffF4FFF4)
                                            : codeStatus == 2
                                                ? Color(0xffFDF5F5)
                                                : Color(0xffFAFAFA),
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
                                        key: Key('otp_item_3'),
                                        borderColor: codeStatus == 1
                                            ? Color(0xff35CE3F)
                                            : codeStatus == 2
                                                ? Color(0xffFF5F61)
                                                : isExpired
                                                    ? Color(0xffFFBC26)
                                                    : Color(0xff4D84FF),
                                        isExpired: isExpired,
                                        contentColor: codeStatus == 1
                                            ? Color(0xffF4FFF4)
                                            : codeStatus == 2
                                                ? Color(0xffFDF5F5)
                                                : Color(0xffFAFAFA),
                                        index: 2,
                                        wrongCode: codeStatus == 2,
                                        onChange: () {
                                          checkOtp.value = 0;
                                        },
                                        controller: form.controllers[2],
                                        autoFocus: false,
                                      ),
                                      PinItem(
                                        key: Key('otp_item_4'),
                                        borderColor: codeStatus == 1
                                            ? Color(0xff35CE3F)
                                            : codeStatus == 2
                                                ? Color(0xffFF5F61)
                                                : isExpired
                                                    ? Color(0xffFFBC26)
                                                    : Color(0xff4D84FF),
                                        isExpired: isExpired,
                                        contentColor: codeStatus == 1
                                            ? Color(0xffF4FFF4)
                                            : codeStatus == 2
                                                ? Color(0xffFDF5F5)
                                                : Color(0xffFAFAFA),
                                        index: 3,
                                        wrongCode: codeStatus == 2,
                                        onChange: () {
                                          checkOtp.value = 0;
                                        },
                                        controller: form.controllers[3],
                                        autoFocus: false,
                                      ),
                                      PinItem(
                                        key: Key('otp_item_5'),
                                        borderColor: codeStatus == 1
                                            ? Color(0xff35CE3F)
                                            : codeStatus == 2
                                                ? Color(0xffFF5F61)
                                                : isExpired
                                                    ? Color(0xffFFBC26)
                                                    : Color(0xff4D84FF),
                                        contentColor: codeStatus == 1
                                            ? Color(0xffF4FFF4)
                                            : codeStatus == 2
                                                ? Color(0xffFDF5F5)
                                                : Color(0xffFAFAFA),
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
                                        key: Key('otp_item_6'),
                                        borderColor: codeStatus == 1
                                            ? Color(0xff35CE3F)
                                            : codeStatus == 2
                                                ? Color(0xffFF5F61)
                                                : isExpired
                                                    ? Color(0xffFFBC26)
                                                    : Color(0xff4D84FF),
                                        isExpired: isExpired,
                                        contentColor: codeStatus == 1
                                            ? Color(0xffF4FFF4)
                                            : codeStatus == 2
                                                ? Color(0xffFDF5F5)
                                                : Color(0xffFAFAFA),
                                        index: 5,
                                        wrongCode: codeStatus == 2,
                                        onChange: () {
                                          checkOtp.value = 0;
                                        },
                                        checkOtp: () {
                                          if (prefsRepository.verificationId !=
                                              null) {
                                            String insertedCode =
                                                form.controllers[0].text +
                                                    form.controllers[1].text +
                                                    form.controllers[2].text +
                                                    form.controllers[3].text +
                                                    form.controllers[4].text +
                                                    form.controllers[5].text;
                                            if (widget.fromLogin) {
                                              authBloc.add(VerifyOtpSignInEvent(
                                                  verificationId:
                                                      prefsRepository
                                                          .verificationId!,
                                                  otp: insertedCode,
                                                  phone: widget.phoneNumber));
                                            } else {
                                              authBloc.add(VerifyOtpSignUpEvent(
                                                  verificationId:
                                                      prefsRepository
                                                          .verificationId!,
                                                  otp: insertedCode));
                                            }
                                          } else {
                                            showMessage(LocaleKeys
                                                .please_wait_5_seconds
                                                .tr());
                                            pasteOtpCode('');
                                            //checkOtp.value = 2;
                                          }
                                        },
                                        controller: form.controllers[5],
                                        autoFocus: false,
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }),
                  ),
                  10.verticalSpace,
                  ValueListenableBuilder<int>(
                      valueListenable: checkOtp,
                      builder: (context, codeStatus, _) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: _enabledResendNotifier,
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
                                          style: context.textTheme.caption?.ra
                                              .copyWith(
                                                  color: Color(0xff5D5C5D),
                                                  height: 1.25),
                                        ),
                                        10.verticalSpace,
                                      ],
                                    )
                                  : const SizedBox.shrink();
                            });
                      }),
                ],
              );
            },
          ),
        ));
  }

  pasteOtpCode(String text) {
    form.controllers[0].text = text[0];
    form.controllers[1].text = text[1];
    form.controllers[2].text = text[2];
    form.controllers[3].text = text[3];
    form.controllers[4].text = text[4];
    form.controllers[5].text = text[5];
    if (widget.fromLogin) {
      authBloc.add(VerifyOtpSignInEvent(
          verificationId: prefsRepository.verificationId!,
          otp: text,
          phone: widget.phoneNumber));
    } else {
      authBloc.add(VerifyOtpSignUpEvent(
          verificationId: prefsRepository.verificationId!, otp: text));
    }
  }

  void _onResendSucceed() {
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * secondsDuration;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    controller.start();
    _enabledResendNotifier.value = false;
    checkOtp.value = 0;
    authBloc.add(SendOtpEvent(
        phone: widget.phoneNumber, isViaWhatsApp: widget.isVisWhatsApp));
  }

  @override
// TODO: implement numberOfFields
  int get numberOfFields => 6;
}
