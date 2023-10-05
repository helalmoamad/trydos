import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';

import '../../../../core/utils/responsive_padding.dart';
import '../manager/auth_bloc.dart';

List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
int currentToType = 0;
bool checkingOtp = false;

class PinItem extends StatefulWidget {
  final TextEditingController controller;
  bool isExpired;
  final bool autoFocus;
  bool wrongCode;
  final Color borderColor;
  final Color contentColor;
  final int index;
  final void Function()? checkOtp;
  final void Function() onChange;
  final void Function(String text)? pasteOtpCode;

  PinItem(
      {this.checkOtp,
      required this.contentColor,
      required this.isExpired,
      this.wrongCode = false,
      this.pasteOtpCode,
      required this.onChange,
      required this.borderColor,
      required this.index,
      required this.controller,
      required this.autoFocus,
      Key? key})
      : super(key: key);

  @override
  State<PinItem> createState() => _PinItemState();
}

class _PinItemState extends State<PinItem> with SingleTickerProviderStateMixin {
  bool withBorder = true;
  TextEditingValue zwspEditingValue = TextEditingValue(
      text: '\u200b', selection: TextSelection(baseOffset: 1, extentOffset: 1));
  late final animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationController.addStatusListener(_updateStatus);
    focusNodes[0].requestFocus();
    widget.controller.value = zwspEditingValue;
    currentToType = 0;
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void resetPins() {
    focusNodes[0].requestFocus();
    currentToType = 0;
    checkingOtp = false;
    withBorder = true;
    widget.controller.value = zwspEditingValue;
    widget.wrongCode = false;
    widget.isExpired = false;
    setState(() {});
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      print('hello');
      animationController.reset();
      resetPins();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('wrong otp : ${widget.wrongCode}');
    if (widget.wrongCode) {
      animationController.forward();
    }
    if (widget.controller.text.length == 1 && checkingOtp) {
      withBorder = true;
    } else {
      withBorder = widget.controller.text == '\u200b';
    }
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) =>
          p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
          p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
      builder: (context, state) {
        return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final sineValue = sin(3 * 2 * pi * animationController.value);
              return Transform.translate(
                offset: Offset(sineValue * 5, 0),
                child: SizedBox(
                  height: 60,
                  width: 50.w,
                  child: DottedBorder(
                    borderPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    dashPattern: [3, 3],
                    radius: Radius.circular(15.0),
                    color: (withBorder &&
                            (state.verifyOtpSignInStatus !=
                                    VerifyOtpSignInStatus.loading &&
                                state.verifyOtpSignUpStatus !=
                                    VerifyOtpSignUpStatus.loading))
                        ? widget.borderColor
                        : Color(0xffF5F5F5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: TextFormField(
                        controller: widget.controller,
                        enabled: (state.verifyOtpSignInStatus !=
                                VerifyOtpSignInStatus.loading &&
                            state.verifyOtpSignUpStatus !=
                                VerifyOtpSignUpStatus.loading),
                        focusNode: focusNodes[widget.index],
                        onTap: () {
                          if (widget.index != currentToType) {
                            focusNodes[currentToType].requestFocus();
                          }
                        },
                        onChanged: (String? text) {
                          widget.onChange.call();
                          if (widget.index == 0 && (text?.length ?? 0) > 1) {
                            widget.pasteOtpCode!.call(text!);
                          }
                          if ((text?.length ?? 0) > 1) {
                            widget.controller.text = text![0];
                            text = text[0];
                          }
                          setState(() {
                            if ((text?.length ?? 0) == 1) {
                              if (widget.index == 5) {
                                checkingOtp = true;
                                widget.checkOtp!.call();
                              }
                              focusNodes[min(5, widget.index + 1)]
                                  .requestFocus();
                              currentToType = min(5, widget.index + 1);
                              withBorder = widget.index == 5;
                            } else if (text?.isEmpty ?? true) {
                              widget.onChange.call();
                              checkingOtp = false;
                              widget.controller.value = zwspEditingValue;
                              focusNodes[max(0, widget.index - 1)]
                                  .requestFocus();
                              currentToType = max(0, widget.index - 1);
                              withBorder = true;
                            }
                          });
                        },
                        textAlign: TextAlign.center,
                        autofocus: widget.autoFocus,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        autocorrect: false,
                        cursorColor: Color(0xff5D5C5D),
                        cursorHeight: 0,
                        enableInteractiveSelection: widget.index == 0,
                        cursorWidth: 0,
                        textAlignVertical: TextAlignVertical.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: context.textTheme.headline5?.ra.copyWith(
                          color: const Color(0xff707070),
                          height: 0.6,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                           contentPadding: HWEdgeInsets.only(top: 30 ,bottom: 15),
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: !(withBorder &&
                                  (state.verifyOtpSignInStatus !=
                                          VerifyOtpSignInStatus.loading &&
                                      state.verifyOtpSignUpStatus !=
                                          VerifyOtpSignUpStatus.loading))
                              ? Color(0xffF5F5F5)
                              : Color(0xffFAFAFA),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
