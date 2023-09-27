import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';

class AlreadyExistAccount extends StatefulWidget {
  const AlreadyExistAccount({required this.phoneNumber , Key? key}) : super(key: key);
 final String phoneNumber ;
  @override
  State<AlreadyExistAccount> createState() => _AlreadyExistAccountState();
}

class _AlreadyExistAccountState extends ThemeState<AlreadyExistAccount> {

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffF4F8FF),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50.h, left: 40.w, child: logo),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(AppAssets.registerInfoSvg,
                                width: 15, height: 15,color: Color(0xff388CFF),),
                            10.horizontalSpace,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This Number Already Registered With Us !',
                                  style: context.textTheme.bodyText2?.ra.copyWith(
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
                                    Text(
                                      widget.phoneNumber,
                                      textAlign: TextAlign.start,
                                      style: context.textTheme.caption?.ra.copyWith(
                                          color: Color(0xff8D8D8D), height: 1.25),
                                    ),
                                  ],
                                ),
                                10.verticalSpace,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    15.horizontalSpace,
                                    Text(
                                      'You Can Log In Now',
                                      style: context.textTheme.caption?.ra.copyWith(
                                          color: Color(0xffC4C2C2), height: 1.25),
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
                Container(
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
                        'Login & Continue',
                        style: textTheme.bodyText1?.ra.copyWith(
                          color: Color(0xff5D5C5D),
                          letterSpacing: 0.16,
                          height: 1.25,
                        ),
                      ),
                    ],
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
                5.verticalSpace,
              ]),
        ],
      ),
    );
  }
}
