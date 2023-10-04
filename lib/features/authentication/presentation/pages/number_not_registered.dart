import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/routes/router.dart';

import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';

class NumberNotRegistered extends StatefulWidget {
  const NumberNotRegistered(
      {required this.phoneNumber, Key? key})
      : super(key: key);
  final String phoneNumber;


  @override
  State<NumberNotRegistered> createState() => _NumberNotRegisteredState();
}

class _NumberNotRegisteredState extends ThemeState<NumberNotRegistered> {
  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffFFF9F0),
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }
  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: pageContent,
      builder: (context , index , _) {
        return Scaffold(
          backgroundColor: index == 0 ? const Color(0xffFFF9F0) : const Color(0xffF4FFF4),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(top: 50, left: 40, right: 40, child: logo),
              PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          Padding(
                            padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.registerInfoSvg,
                                    width: 15,
                                    height: 15,
                                    color: Color(0xffFCAC2D),
                                  ),
                                  10.horizontalSpace,
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sorry, This Number Is Not Registered With Us !',
                                        style: context.textTheme.bodyText2?.ra.copyWith(
                                            color: Color(0xff5D5C5D), height: 1.42),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: HWEdgeInsets.only(top: 3.0),
                                            child: SvgPicture.asset(
                                                AppAssets.phoneCallSvg,
                                                width: 10,
                                                height: 10),
                                          ),
                                          5.horizontalSpace,
                                          Text(
                                            widget.phoneNumber,
                                            textAlign: TextAlign.start,
                                            style: context.textTheme.caption?.ra
                                                .copyWith(
                                                color: Color(0xff8D8D8D),
                                                height: 1.25),
                                          ),
                                        ],
                                      ),
                                      10.verticalSpace,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          15.horizontalSpace,
                                          Text(
                                            'Register & Create New Account With Us In A Few Simple\nSteps',
                                            style: context.textTheme.caption?.ra
                                                .copyWith(
                                                color: Color(0xffC4C2C2),
                                                height: 1.25),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              pageContent.value=1;
                              pageController.animateToPage(1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            },
                            child: Container(
                              width: 1.sw,
                              height: 60,
                              margin: HWEdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create New Account & Continue',
                                    style: textTheme.bodyText1?.ra.copyWith(
                                      color: Color(0xff5D5C5D),
                                      letterSpacing: 0.16,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          30.verticalSpace,
                          Text(
                            'Cancel & Take A Look At The App',
                            style: textTheme.bodyText2?.ra.copyWith(
                              color: Color(0xff4d84ff),
                              letterSpacing: 0.14,
                              height: 1.43,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 54,),
                        ]),
                  ),
                  AddingName(fromLogin: true,)
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
