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
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class NumberNotRegistered extends StatefulWidget {
  const NumberNotRegistered({required this.phoneNumber, Key? key})
      : super(key: key);
  final String phoneNumber;

  @override
  State<NumberNotRegistered> createState() => _NumberNotRegisteredState();
}

class _NumberNotRegisteredState extends ThemeState<NumberNotRegistered> {
  bool _eventLogged = false;
  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffFFF9F0),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: "later_take_look_button",
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': AuthScreenConst.USER_NOT_FOUND_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final PageController pageController = PageController();
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: pageContent,
        builder: (context, index, _) {
          return Scaffold(
            backgroundColor:
                index == 0 ? const Color(0xffFFF9F0) : const Color(0xffF4FFF4),
            body: WillPopScope(
              onWillPop: () async {
                if (pageController.page == 1) {
                  BlocProvider.of<AppBloc>(context).add(ChangeBasePage(0));
                  prefsRepository.setMyMarketName("");
                  context.go(GRouter
                          .config.applicationRoutes.kRegistrationCompletedPage +
                      '?userName=');
                  return false;
                }
                return true;
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(top: 50, left: 40, right: 40, child: logo),
                  PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: [
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
                                      color: Color(0xffFCAC2D),
                                    ),
                                    10.horizontalSpace,
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextWidget(
                                          LocaleKeys
                                              .sorry_this_number_is_not_registered_with_us
                                              .tr(),
                                          style: context
                                              .textTheme.titleLarge?.ra
                                              .copyWith(
                                                  color: Color(0xff5D5C5D),
                                                  height: 1.42),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  HWEdgeInsets.only(top: 3.0),
                                              child: SvgPicture.asset(
                                                  AppAssets.phoneCallSvg,
                                                  width: 10,
                                                  height: 10),
                                            ),
                                            5.horizontalSpace,
                                            MyTextWidget(
                                              widget.phoneNumber,
                                              textAlign: TextAlign.start,
                                              style: context
                                                  .textTheme.titleMedium?.ra
                                                  .copyWith(
                                                      color: Color(0xff8D8D8D),
                                                      height: 1.25),
                                            ),
                                          ],
                                        ),
                                        10.verticalSpace,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            15.horizontalSpace,
                                            MyTextWidget(
                                              LocaleKeys
                                                  .register_create_new_account
                                                  .tr(),
                                              style: context
                                                  .textTheme.titleMedium?.ra
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
                                  ? Key(WidgetsKeys.createNewAccountContinueKey)
                                  : null,
                              onTap: () {
                                pageContent.value = 1;
                                pageController.animateToPage(1,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut);
                                ///////////////////

                                FirebaseAnalyticsService.logEventForSession(
                                  eventName: AnalyticsEventsConst.CLICK,
                                  executedEventName:
                                      "CREATE_NEW_ACCOUNT_CONTINUE_BUTTON",
                                  extraParams: {
                                    'button_name':
                                        AnalyticsButtonsEventNameConst
                                            .CREATE_NEW_ACCOUNT_CONTINUE_BUTTON,
                                  },
                                );
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
                                      LocaleKeys.create_new_account_continue
                                          .tr(),
                                      style:
                                          textTheme.displayMedium?.ra.copyWith(
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
                              focusColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () async {
                                Future.delayed(
                                  Duration(milliseconds: 100),
                                  () async {
                                    /*   if (GetIt.I<PrefsRepository>()
                                                .isVerifiedPhone !=
                                            false ||
                                        ((GetIt.I<PrefsRepository>()
                                                        .marketToken
                                                        ?.length ??
                                                    0) <
                                                5 ||
                                            GetIt.I<PrefsRepository>()
                                                    .marketToken ==
                                                "" ||
                                            GetIt.I<PrefsRepository>()
                                                    .marketToken ==
                                                null)) {*/
                                    String? deviceId =
                                        await HelperFunctions.getDeviceId();
                                    BlocProvider.of<AuthBloc>(context).add(
                                        RegisterGuestEvent(
                                            deviceId: deviceId!));
                                    //}
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      context.go(GRouter
                                          .config.applicationRoutes.kBasePage);
                                    }
                                  },
                                );

                                ///////////////////

                                FirebaseAnalyticsService.logEventForSession(
                                  executedEventName: "LATER_TAKE_LOOK_BUTTON",
                                  eventName: AnalyticsEventsConst
                                      .LATER_TAKE_LOOK_CLICKED,
                                  extraParams: {
                                    'button_name':
                                        AnalyticsButtonsEventNameConst
                                            .LATER_TAKE_LOOK_BUTTON,
                                    'screen_name':
                                        AuthScreenConst.USER_NOT_FOUND_SCREEN,
                                  },
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: MyTextWidget(
                                  LocaleKeys.cancel.tr() +
                                      "&" +
                                      LocaleKeys.later_take_look.tr(),
                                  style: textTheme.titleLarge?.ra.copyWith(
                                    color: Color(0xff4d84ff),
                                    letterSpacing: 0.14,
                                    height: 1.43,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 44,
                            ),
                          ]),
                      AddingName(
                        fromLogin: true,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
