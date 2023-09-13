import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/authentication/presentation/widgets/pin_item.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';

class VerifyOtp extends StatefulWidget {
  VerifyOtp(
      {Key? key,
      required this.methodIcon,
      required this.navigateToAddName,
      required this.goBack,
      required this.phoneNumber})
      : super(key: key);
  final String methodIcon;
  final String phoneNumber;
  final void Function() goBack;
  final void Function() navigateToAddName;

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with FormStateMinxin {
  late ValueNotifier<bool> _enabledResendNotifier;
  late ValueNotifier<int> checkOtp;
  int secondsDuration = 120;
  late CountdownTimerController controller;
  late int endTime;

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
    _enabledResendNotifier = ValueNotifier<bool>(false);
    checkOtp = ValueNotifier<int>(0);

    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * secondsDuration;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
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
                  SvgPicture.asset(AppAssets.phoneOtpSvg,
                      width: 15, height: 15),
                  10.horizontalSpace,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We Have Sent A Verification Code:',
                        style: context.textTheme.caption?.ra
                            .copyWith(color: Color(0xff5D5C5D), height: 1.42),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: HWEdgeInsets.only(top: 3.0),
                            child: SvgPicture.asset(AppAssets.phoneCallSvg,
                                width: 10, height: 10),
                          ),
                          5.horizontalSpace,
                          Text(
                            widget.phoneNumber,
                            textAlign: TextAlign.start,
                            style: context.textTheme.caption?.ra.copyWith(
                                color: Color(0xffC4C2C2), height: 1.25),
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
                          Text(
                            'Please Enter The Verification Code Sent To Your ${widget.methodIcon == AppAssets.whatsappSvg ? 'Whatsapp' : 'SMS'}',
                            style: context.textTheme.caption?.ra.copyWith(
                                color: Color(0xffC4C2C2), height: 1.25),
                          )
                        ],
                      ),
                      4.verticalSpace,
                      ValueListenableBuilder<bool>(
                          valueListenable: _enabledResendNotifier,
                          builder: (context, resend, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(AppAssets.registerInfoSvg,
                                        width: 10, height: 10),
                                    5.horizontalSpace,
                                    Text(
                                      resend
                                          ? 'You Can Resend The Code After'
                                          : 'Didn’t You Receive A Code?',
                                      style: context.textTheme.caption?.ra
                                          .copyWith(
                                              color: Color(0xffC4C2C2),
                                              height: 1.25),
                                    ),
                                    4.horizontalSpace,
                                    ValueListenableBuilder<bool>(
                                        valueListenable: _enabledResendNotifier,
                                        builder: (context, enabledResend, _) {
                                          if (!enabledResend)
                                            return CountdownTimer(
                                              widgetBuilder:
                                                  (_, remainingTime) {
                                                String seconds = (remainingTime
                                                                ?.sec ??
                                                            0) <
                                                        10
                                                    ? '0${remainingTime?.sec}'
                                                    : '${remainingTime?.sec}';
                                                return Text(
                                                  '0${remainingTime?.min ?? '0'} : $seconds ',
                                                  style: context
                                                      .textTheme.caption?.ra
                                                      .copyWith(
                                                          color:
                                                              Color(0xff4D84FF),
                                                          height: 1.25),
                                                );
                                              },
                                              controller: controller,
                                              onEnd: onEnd,
                                              endTime: endTime,
                                              endWidget: const SizedBox(),
                                            );
                                          return InkWell(
                                            onTap: _onResendSucceed,
                                            child: Text(
                                              'Resend Code',
                                              style: context
                                                  .textTheme.caption?.ra
                                                  .copyWith(
                                                      color: Color(0xff4D84FF),
                                                      height: 1.25),
                                            ),
                                          );
                                        }),
                                    resend
                                        ? Text(
                                            ' Or ',
                                            style: context.textTheme.caption?.ra
                                                .copyWith(
                                                    color: Color(0xff5D5C5D),
                                                    height: 1.25),
                                          )
                                        : const SizedBox.shrink(),
                                    resend
                                        ? InkWell(
                                            onTap: widget.goBack,
                                            child: Text(
                                              'Change',
                                              maxLines: 2,
                                              softWrap: true,
                                              style: context
                                                  .textTheme.caption?.ra
                                                  .copyWith(
                                                      color: Color(0xff4D84FF),
                                                      height: 1.25),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                                resend
                                    ? Padding(
                                        padding: HWEdgeInsets.only(left: 15.0),
                                        child: InkWell(
                                          onTap: widget.goBack,
                                          child: Text(
                                            'The Method Of Receiving',
                                            maxLines: 2,
                                            softWrap: true,
                                            style: context.textTheme.caption?.ra
                                                .copyWith(
                                                    color: Color(0xff4D84FF),
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
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PinItem(
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
                                controller: form.controllers[0],
                                wrongCode: codeStatus == 2,
                                index: 0,
                                onChange: () {
                                  checkOtp.value = 0;
                                },
                                autoFocus: true),
                            PinItem(
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
                                controller: form.controllers[1],
                                wrongCode: codeStatus == 2,
                                index: 1,
                                onChange: () {
                                  checkOtp.value = 0;
                                },
                                autoFocus: false),
                            PinItem(
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
                                index: 2,
                                wrongCode: codeStatus == 2,
                                onChange: () {
                                  checkOtp.value = 0;
                                },
                                controller: form.controllers[2],
                                autoFocus: false),
                            PinItem(
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
                                index: 3,
                                wrongCode: codeStatus == 2,
                                onChange: () {
                                  checkOtp.value = 0;
                                },
                                controller: form.controllers[3],
                                autoFocus: false),
                            PinItem(
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
                                index: 4,
                                wrongCode: codeStatus == 2,
                                onChange: () {
                                  checkOtp.value = 0;
                                },
                                controller: form.controllers[4],
                                autoFocus: false),
                            PinItem(
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
                                index: 5,
                                wrongCode: codeStatus == 2,
                                onChange: () {
                                  checkOtp.value = 0;
                                },
                                checkOtp: () {
                                  String insertedCode =
                                      form.controllers[0].text +
                                          form.controllers[1].text +
                                          form.controllers[2].text +
                                          form.controllers[3].text +
                                          form.controllers[4].text +
                                          form.controllers[5].text;
                                  print('insertedCode: $insertedCode');
                                  if (insertedCode == '000000') {
                                    checkOtp.value = 1;
                                    Future.delayed(
                                      Duration(milliseconds: 700),
                                      () {
                                       widget.navigateToAddName.call();
                                       return true;
                                      },
                                    );
                                    return true;
                                  } else {
                                    checkOtp.value = 2;
                                    return false;
                                  }
                                },
                                controller: form.controllers[5],
                                autoFocus: false),
                          ],
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
                    return codeStatus == 2 || isExpired ? Column(
                            children: [
                              Text(
                                codeStatus == 2 ? 'Please Enter The Correct Code Sent To Your Phone' : 'The Code Sent Has Expired',
                                style: context.textTheme.caption?.ra.copyWith(
                                    color: Color(0xff5D5C5D), height: 1.25),
                              ),
                              10.verticalSpace,
                            ],
                          )
                        : const SizedBox.shrink();
                  });
            }
          ),
        ],
      ),
    );
  }

  _onResend() {}

  void _onResendSucceed() {
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * secondsDuration;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    controller.start();
    _enabledResendNotifier.value = false;
    checkOtp.value = 0;
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 6;
}
