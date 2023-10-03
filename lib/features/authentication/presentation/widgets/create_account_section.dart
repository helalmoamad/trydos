import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../routes/router.dart';

class CreateAccountSection extends StatelessWidget {
  CreateAccountSection({Key? key  ,required this.moveToNextStep}) : super(key: key);
  final ValueNotifier<int> clickButton = ValueNotifier(-1);
  final void Function() moveToNextStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'To ',
                style: context.textTheme.bodyText2?.la.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: 'Create new account',
                style: context.textTheme.bodyText2?.lr.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: ' Tap “Agree & Continue” To Accept\n',
                style: context.textTheme.bodyText2?.la.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: 'trydos',
                style: context.textTheme.bodyText2?.la.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
            ],
          ),
          textHeightBehavior:
          TextHeightBehavior(applyHeightToFirstAscent: false),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 23,),
        SvgPicture.asset(AppAssets.termsSvg),
        SizedBox(height: 10,),
        Text(
          'Terms Of Services',
          style: context.textTheme.bodyText2?.ra.copyWith(
            color: const Color(0xff388CFF),
            height: 1.42,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 78,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              clickButton.value=0;
              Future.delayed(Duration(milliseconds: 100),() {
                clickButton.value=-1;
                moveToNextStep.call();
              },);
            },
            child: ValueListenableBuilder<int>(
                valueListenable: clickButton,
                builder: (context , index ,_) {
                  return DottedBorder(
                    borderPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    dashPattern: [3, 3],
                    radius: Radius.circular(20.0),
                    color: index==0 ? const Color(0xff388cff) : const Color(0xfffafafa),
                    child: Container(
                      width: 1.sw,
                      height: 60,
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.white : const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Text(
                          'Agree & Continue',
                          style: context.textTheme.bodyText1?.ra.copyWith(
                            color: const Color(0xff3c3c3c),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textHeightBehavior:
                          TextHeightBehavior(applyHeightToFirstAscent: false),
                          textAlign: TextAlign.center,
                          softWrap: false,
                        ),
                      ),
                    ),
                  );
                }
            ),
          ),
        ),
        SizedBox(height: 29,),
        InkWell(
          onTap: (){
            context.go(GRouter.config.applicationRoutes.kBasePage);
          },
          child: Text(
            'Later, Take A Look At The App',
            style: context.textTheme.bodyText2?.ra.copyWith(
              color: const Color(0xff4D84FF),
              letterSpacing: 0.14,
              height: 1.43,
            ),
            textHeightBehavior:
            TextHeightBehavior(applyHeightToFirstAscent: false),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
        SizedBox(height: 55,),
      ],
    );
  }
}
