import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../manager/auth_bloc.dart';

class LoginSuccessfully extends StatefulWidget {
  const LoginSuccessfully({required this.phoneNumber, Key? key})
      : super(key: key);
  final String phoneNumber;

  @override
  State<LoginSuccessfully> createState() => _LoginSuccessfullyState();
}

class _LoginSuccessfullyState extends ThemeState<LoginSuccessfully> {
  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffE0FFEE),
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "Login Successfully Page");
    Future.delayed(
      Duration(seconds: 1),
      () {
        if (mounted) context.go(GRouter.config.applicationRoutes.kBasePage);
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0FFEE),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50, left: 40, right: 40, child: logo),
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
                            AppAssets.enterSvg,
                            width: 15,
                            height: 15,
                            color: Color(0xff388CFF),
                          ),
                          10.horizontalSpace,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logged In Successfully !',
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
                              Padding(
                                padding: HWEdgeInsets.only(left: 30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: HWEdgeInsets.only(left: 4.0),
                                      child: Text('Hello',
                                          textAlign: TextAlign.start,
                                          style: textTheme.headline3?.ba
                                              .copyWith(
                                                  color: Color(0xff5D5C5D),
                                                  height: 1.25)),
                                    ),
                                    17.verticalSpace,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            if(state.marketUser!.name==null || state.marketUser!.name==''){
                                              return const SizedBox.shrink();
                                            }
                                            return Text(','+state.marketUser!.name.toString(),
                                                textAlign: TextAlign.start,
                                                style: textTheme.headline3?.la
                                                    .copyWith(
                                                  color: Color(0xff5D5C5D),
                                                  letterSpacing: 0.3,
                                                  height: 0.67,
                                                ));
                                          },
                                        ),
                                        18.verticalSpace,
                                        Text('Enjoy With Our Services',
                                            textAlign: TextAlign.center,
                                            style: textTheme.subtitle1?.la
                                                .copyWith(
                                                    color: Color(0xff5D5C5D),
                                                    height: 1.25)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ]),
                  ),
                  Spacer(),
                ]),
          ),
        ],
      ),
    );
  }
}
