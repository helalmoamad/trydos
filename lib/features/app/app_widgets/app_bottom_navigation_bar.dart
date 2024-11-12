import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/app_widgets/update_user_name_widget.dart';
import 'package:trydos/features/app/language_dropdown.dart';
import 'package:trydos/features/feed_back/presentation/pages/feed_back_page.dart';
import 'package:trydos/features/feed_back/presentation/pages/files_exist_page.dart';
import 'package:trydos/features/feed_back/presentation/pages/shared_preference_page.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../common/test_utils/test_var.dart';
import '../../../core/domin/repositories/prefs_repository.dart';
import '../../../core/utils/theme_state.dart';
import '../../../routes/router.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../feed_back/presentation/pages/edit_urls_page.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';
import '../my_text_widget.dart';

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({Key? key}) : super(key: key);

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends ThemeState<AppBottomNavBar> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (oldState, newState) =>
          oldState.currentIndex != newState.currentIndex,
      builder: (context, state) {
        return Container(
          width: 1.sw,
          height: 70.h,
          decoration: BoxDecoration(
            color: colorScheme.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 0),
                  color: colorScheme.black.withOpacity(0.1),
                  blurRadius: 6)
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    appBloc.add(ChangeTab(-1));
                    homeBloc.add(
                      ChangeCurrentIndexForMainCategoryEvent(index: -1),
                    );

                    if (context.canPop()) {
                      Navigator.of(context).pop();
                    }
                    if (state.currentIndex != 0) {
                      homeBloc.add(
                        GetHomeBoutiqesEvent(
                          getWithPrefetchForBoutiques: false,
                          context: context,
                          offset: '1',
                          categorySlug: 'Empty',
                        ),
                      );
                    }
                    appBloc.add(ChangeBasePage(0));
                    homeBloc.add(ResetAllSelectedAppliedFilterEvent());
                    /////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.homeNavBarButton,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 0
                          ? SvgPicture.asset(
                              AppAssets.bottomBarLogoActiveSvg,
                            )
                          : SvgPicture.asset(
                              AppAssets.bottomBarLogoActiveSvg,
                            ),
                      10.verticalSpace,
                      state.currentIndex == 0
                          ? SvgPicture.asset(
                              AppAssets.logoTextActiveSvg,
                              height: 10.h,
                            )
                          : SvgPicture.asset(
                              AppAssets.logoTextInactiveSvg,
                              height: 10.h,
                            ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onLongPress: () {
                    context.go(GRouter
                        .config.applicationRoutes.kSharedPreferencePagePath);
                  },
                  onTap: () {
                    if (context.canPop()) {
                      Navigator.of(context).pop();
                    }
                    appBloc.add(ChangeBasePage(1));
                    /////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.cartNavBarButton,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 1
                          ? SvgPicture.asset(
                              AppAssets.bagsSvg,
                              height: 30.h,
                            )
                          : SvgPicture.asset(
                              AppAssets.cartSvg,
                              height: 30.h,
                            ),
                      10.verticalSpace,
                      MyTextWidget(
                        LocaleKeys.cart.tr(),
                        maxLines: 1,
                        style: textTheme.titleSmall?.lr.copyWith(
                            color: state.currentIndex != 1
                                ? colorScheme.grey200
                                : colorScheme.black,
                            letterSpacing: 0.28),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  key: TestVariables.kTestMode
                      ? Key(WidgetsKey.chatNavBarKey)
                      : null,
                  onTap: () async {
                    if (prefsRepository.isVerifiedPhone != true) {
                      context.go(GRouter
                          .config.applicationRoutes.kRegistrationPagePath);
                    } else if (prefsRepository.myMarketName == null) {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return UpdateUserNameWidget();
                          });
                    } else {
                      NotificationSettings settings = await FirebaseMessaging
                          .instance
                          .getNotificationSettings();
                      if (settings.authorizationStatus ==
                          AuthorizationStatus.denied) {
                        openAppSettings();
                        showMessage(LocaleKeys
                            .please_enable_send_notification_for_this_app
                            .tr());
                      } else {
                        if (context.canPop()) {
                          Navigator.of(context).pop();
                        }
                        appBloc.add(ChangeBasePage(2));
                      }
                    }
                    /////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.chatNavBarButton,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 2
                          ? SvgPicture.asset(
                              AppAssets.activeChatSvg,
                              height: 30.h,
                            )
                          : SvgPicture.asset(
                              AppAssets.chatSvg,
                              height: 30.h,
                            ),
                      10.verticalSpace,
                      MyTextWidget(
                        LocaleKeys.chat.tr(),
                        maxLines: 1,
                        style: textTheme.titleSmall?.lr.copyWith(
                            letterSpacing: 0.28,
                            color: state.currentIndex != 2
                                ? colorScheme.grey200
                                : colorScheme.black),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: MyTextWidget('Dev tools'),
                            actions: [
                              Container(
                                width: 300,
                                height: 300,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        left: 10,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            FeedBackScreen(
                                                              showRequests:
                                                                  true,
                                                            )));
                                              },
                                              child: MyTextWidget('requests'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            SharedPreferencePage()));
                                              },
                                              child: MyTextWidget(
                                                  'shared preferences'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            FeedBackScreen(
                                                              showRequests:
                                                                  false,
                                                            )));
                                              },
                                              child: MyTextWidget(
                                                  'flutter errors'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            FilesExistPage()));
                                              },
                                              child:
                                                  MyTextWidget('files exists'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            EditUrlsPage()));
                                              },
                                              child: MyTextWidget('Edit Urls'),
                                            ),
                                            LanguageDropdown(),
                                          ],
                                        )),
                                  ],
                                ),
                              )
                            ],
                          );
                        });
                  },
                  onTap: () {
                    // if (prefsRepository.chatToken != null) return;
                    //appBloc.add(ChangeBasePage(0));
                    context
                        .go(GRouter.config.applicationRoutes.kRegistrationPage);
                    /////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.meNavBarButton,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 3
                          ? Container(
                              height: 30.h,
                              width: 30.h,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(AppAssets.profileJpg),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    width: 1.0, color: const Color(0xfff53c3c)),
                              ),
                            )
                          // Container(
                          //     height: 30.h,
                          //     width: 30.h,
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(15.r),
                          //         border: Border.all(
                          //             color: colorScheme.error, width: 1)),
                          //     child: Image.asset(
                          //       AppAssets.profilePng,
                          //       fit: BoxFit.fitHeight,
                          //     ),
                          //       )
                          : SizedBox(
                              height: 30.h,
                              width: 30.h,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 30.h,
                                    width: 30.h,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(AppAssets.profileJpg),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          offset: Offset(0, 3),
                                          blurRadius: 3,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  // Container(
                                  //   height: 6,
                                  //   width: 1.sw,
                                  //   decoration: BoxDecoration(
                                  //     gradient: LinearGradient(
                                  //       begin: const Alignment(1, 1),
                                  //       end: const Alignment(1, -3),
                                  //       colors: [
                                  //         colorScheme.white,
                                  //         colorScheme.white.withOpacity(0.6),
                                  //       ],
                                  //       stops: const [0.0, 1.0],
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(20.0),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                      10.verticalSpace,
                      MyTextWidget(
                        LocaleKeys.me.tr(),
                        maxLines: 1,
                        style: textTheme.titleSmall?.lr.copyWith(
                            letterSpacing: 0.28,
                            color: state.currentIndex != 3
                                ? colorScheme.grey200
                                : colorScheme.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
