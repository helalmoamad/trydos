import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../base_page.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
class WelcomeSection extends StatelessWidget {
   WelcomeSection({required this.goToCreateAccount , required this.goToLoginSection ,Key? key}) : super(key: key);
  void Function() goToCreateAccount;
  void Function() goToLoginSection;

  ValueNotifier<int> clickButton = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            'To Take Advantage Of All The Advantages Of The Application,\nPlease Join Us In Quick And Easy Steps And For Just One Time',
            textAlign: TextAlign.start,
            textHeightBehavior:
            TextHeightBehavior(applyHeightToFirstAscent: false),
            style: context.textTheme.bodyText2?.la.copyWith(
              color: Color(0xff5D5C5D),
              letterSpacing: 0.14,
              height: 1.43,
            ),
          ),
        ),
        SizedBox(height: 20,),
        Text(
          'Why We Know You ?',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyText2?.la.copyWith(
            color: Color(0xffF85555),
            letterSpacing: 0.14,
            height: 1.43,
          ),
        ),
        SizedBox(height: 30,),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            clickButton.value = 0;
            Future.delayed(
                Duration(milliseconds: 100),
                    (){
                  clickButton.value = -1;
                  goToLoginSection.call();
                }
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
                        child: Text(
                          'I Have Already Account',
                          style: context.textTheme.bodyText1?.ra.copyWith(
                            color: Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
        SizedBox(height: 10,),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            clickButton.value = 1;
            Future.delayed(Duration(milliseconds: 100), () {
              clickButton.value = -1;
                goToCreateAccount.call();
            });
          },
          child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                print(index);
                return Padding(
                  padding:  EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
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
                        child: Text(
                          'Create New Account',
                          style: context.textTheme.bodyText1?.ra.copyWith(
                            color: Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
        SizedBox(height: 30,),
        InkWell(
          onTap: (){
            context.go(GRouter.config.applicationRoutes.kBasePage);
          },
          child: Text(
            'Later, Take A Look At The App',
            textAlign: TextAlign.center,
            textHeightBehavior:
            TextHeightBehavior(applyHeightToFirstAscent: false),
            style: context.textTheme.bodyText2?.ra.copyWith(
              color: Color(0xff4d84ff),
              letterSpacing: 0.14,
              height: 1.43,
            ),
          ),
        ),
        SizedBox(height: 56,),
      ],
    );
  }
}
