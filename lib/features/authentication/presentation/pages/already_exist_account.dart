import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/test_utils/test_var.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';

import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class AlreadyExistAccount extends StatefulWidget {
  const AlreadyExistAccount({required this.phoneNumber, Key? key})
      : super(key: key);
  final String phoneNumber;
  @override
  State<AlreadyExistAccount> createState() => _AlreadyExistAccountState();
}

class _AlreadyExistAccountState extends ThemeState<AlreadyExistAccount> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffF4F8FF),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.userExistsScreen,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50, left: 40, right: 40, child: logo),
          Column(
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
                          color: Color(0xff388CFF),
                        ),
                        10.horizontalSpace,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextWidget(
                              LocaleKeys.this_numbber_already.tr(),
                              style: context.textTheme.titleLarge?.ra.copyWith(
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
                                MyTextWidget(
                                  widget.phoneNumber,
                                  textAlign: TextAlign.start,
                                  style: context.textTheme.titleMedium?.ra
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
                                MyTextWidget(
                                  LocaleKeys.you_can_login_now.tr(),
                                  style: context.textTheme.titleMedium?.ra
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
                  key: TestVariables.kTestMode
                      ? Key(WidgetsKey.loginContinueButtonKey)
                      : null,
                  onTap: () {
                    Future.delayed(
                      Duration(milliseconds: 100),
                      () {
                        context.go(GRouter.config.applicationRoutes.kBasePage);
                        BlocProvider.of<AuthBloc>(context)
                            .add(VerifyOtpSignInEvent(
                          otp: prefsRepository.otpCode!,
                          verificationId: prefsRepository.verificationId!,
                          phone: widget.phoneNumber,
                        ));
                      },
                    );
                    ////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.loginContinueButton,
                    );
                    //////////////////////
                    debugPrint(
                        '////////// loginContinueButton  ///////////////');
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
                        MyTextWidget(
                          LocaleKeys.login_continue.tr(),
                          style: textTheme.displayMedium?.ra.copyWith(
                            color: Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                20.verticalSpace,
                InkWell(
                  key: TestVariables.kTestMode
                      ? Key(WidgetsKey.takeLookButtonKey)
                      : null,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () async {
                    Future.delayed(
                      Duration(milliseconds: 100),
                      () async {
                        if (GetIt.I<PrefsRepository>().isVerifiedPhone !=
                            false) {
                          String? deviceId =
                              await HelperFunctions.getDeviceId();
                          BlocProvider.of<AuthBloc>(context)
                              .add(RegisterGuestEvent(deviceId: deviceId!));
                        }
                        context.go(GRouter.config.applicationRoutes.kBasePage);
                      },
                    );

                    ////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.laterTakeLookButton,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: MyTextWidget(
                      LocaleKeys.cancel.tr() +
                          " , " +
                          LocaleKeys.take_look.tr(),
                      style: textTheme.titleLarge?.ra.copyWith(
                        color: Color(0xff4d84ff),
                        letterSpacing: 0.14,
                        height: 1.43,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}
