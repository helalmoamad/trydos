import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/test_utils/test_var.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
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

  bool _eventLogged = false;

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffF4F8FF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AuthScreenConst.USER_ALREADY_EXISTS_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': AuthScreenConst.USER_ALREADY_EXISTS_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    LastPagesTracker.push('AlreadyExistAccount');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool verifiedBySignIn = false;
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50.h, left: 40.w, right: 40.w, child: logo),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.registerInfoSvg,
                          width: 15.w,
                          height: 15.h,
                          // ignore: deprecated_member_use
                          color: const Color(0xff388CFF),
                        ),
                        10.horizontalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextWidget(
                              LocaleKeys.this_numbber_already.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                                height: 1.42,
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: HWEdgeInsets.only(top: 3.0),
                                  child: SvgPicture.asset(
                                    AppAssets.phoneCallSvg,
                                    width: 10.w,
                                    height: 10.h,
                                  ),
                                ),
                                5.horizontalSpace,
                                MyTextWidget(
                                  widget.phoneNumber,
                                  textAlign: TextAlign.start,
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        height: 1.25,
                                      ),
                                ),
                              ],
                            ),
                            10.verticalSpace,
                            Row(
                              children: [
                                15.horizontalSpace,
                                MyTextWidget(
                                  LocaleKeys.you_can_login_now.tr(),
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xffC4C2C2),
                                        height: 1.25,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) =>
                    previous.verifyOtpSignInStatus !=
                    current.verifyOtpSignInStatus,
                builder: (context, state) {
                  if (state.verifyOtpSignInStatus ==
                          VerifyOtpSignInStatus.success &&
                      verifiedBySignIn) {
                    verifiedBySignIn = false;
                    Future.delayed(const Duration(seconds: 2), () {
                      context.go(
                        GRouter
                                .config
                                .applicationRoutes
                                .kRegistrationCompletedPage +
                            '?userName=${prefsRepository.myMarketName}',
                      );
                    });
                  }
                  return InkWell(
                    key: TestVariables.kTestMode
                        ? const Key(WidgetsKeys.loginContinueButtonKey)
                        : null,
                    onTap: () {
                      context.go(GRouter.config.applicationRoutes.kBasePage);
                      verifiedBySignIn = true;
                      ////////////////////
                      FirebaseAnalyticsService.logEventForSession(
                        executedEventName:
                            AuthScreenConst.USER_ALREADY_EXISTS_SCREEN,
                        eventName: AnalyticsEventsConst.CLICK,
                        extraParams: {
                          'button_name': AnalyticsButtonsEventNameConst
                              .LOGIN_CONTINUE_BUTTON,
                        },
                      );
                      //////////////////////
                      debugPrint(
                        '////////// loginContinueButton  ///////////////',
                      );
                    },
                    child:
                        state.verifyOtpSignInStatus ==
                            VerifyOtpSignInStatus.loading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 1.sw,
                              height: 60.h,
                              margin: HWEdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          )
                        : Container(
                            width: 1.sw,
                            height: 60.h,
                            margin: HWEdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyTextWidget(
                                  LocaleKeys.login_continue.tr(),
                                  style: textTheme.displayMedium?.rq.copyWith(
                                    color: const Color(0xff5D5C5D),
                                    letterSpacing: 0.16,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                },
              ),
              20.verticalSpace,
              InkWell(
                key: TestVariables.kTestMode
                    ? const Key(WidgetsKeys.takeLookButtonKey)
                    : null,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  Future.delayed(const Duration(milliseconds: 100), () async {
                    /*    if (GetIt.I<PrefsRepository>().isVerifiedPhone !=
                                false ||
                            (prefsRepository.isTokenExpired ??
                                false ||
                                    prefsRepository.marketToken == "" ||
                                    prefsRepository.marketToken == null)) {*/
                    String? deviceId = await HelperFunctions.getDeviceId();
                    BlocProvider.of<AuthBloc>(
                      context,
                    ).add(RegisterGuestEvent(deviceId: deviceId!));
                    // }
                    context.go(GRouter.config.applicationRoutes.kBasePage);
                  });

                  ////////////////////

                  FirebaseAnalyticsService.logEventForSession(
                    eventName: AnalyticsEventsConst.LATER_TAKE_LOOK_CLICKED,
                    executedEventName:
                        AuthScreenConst.USER_ALREADY_EXISTS_SCREEN,
                    extraParams: {
                      'button_name':
                          AnalyticsButtonsEventNameConst.LATER_TAKE_LOOK_BUTTON,
                      'screen_name': AuthScreenConst.USER_ALREADY_EXISTS_SCREEN,
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: MyTextWidget(
                    LocaleKeys.cancel.tr() + " , " + LocaleKeys.take_look.tr(),
                    style: textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff4d84ff),
                      letterSpacing: 0.14,
                      height: 1.43,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
