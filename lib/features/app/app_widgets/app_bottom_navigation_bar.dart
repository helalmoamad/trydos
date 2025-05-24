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
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/update_user_name_widget.dart';
import 'package:trydos/features/app/country_dropdown.dart';
import 'package:trydos/features/app/language_dropdown.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/feed_back/presentation/pages/feed_back_page.dart';
import 'package:trydos/features/feed_back/presentation/pages/files_exist_page.dart';
import 'package:trydos/features/feed_back/presentation/pages/shared_preference_page.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/notification_service/setting_fitrbase_notification.dart';
import 'package:trydos/splash_page.dart';
import '../../../common/helper/helper_functions.dart';
import '../../../common/test_utils/test_var.dart';
import '../../../core/domin/repositories/prefs_repository.dart';
import '../../../core/utils/theme_state.dart';
import '../../../routes/router.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../feed_back/presentation/pages/edit_urls_page.dart';
import '../../home/presentation/pages/notifications_page.dart';
import '../../home/presentation/pages/Order/orders_page.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';
import '../my_text_widget.dart';

class AppBottomNavBar extends StatefulWidget {
  final ValueNotifier<bool> isShowPanelForVerified;
  const AppBottomNavBar({Key? key, required this.isShowPanelForVerified})
      : super(key: key);

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends ThemeState<AppBottomNavBar> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  late BoutiqueBloc boutiqueBloc;
  late CategoryBloc categoryBloc;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
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
                    categoryBloc.add(
                      ChangeCurrentIndexForMainCategoryEvent(index: -1),
                    );

                    if (Navigator.of(context).canPop()) {
                      try {
                        Navigator.of(context).pop();
                      } catch (e) {}
                    }

                    categoryBloc.add(
                      GetHomeBoutiqesEvent(
                        getWithPrefetchToStoreInMemory: false,
                        getWithOutPrefetchForEachBoutiques: true,
                        context: context,
                        categorySlug: "Empty",
                        offset: "1",
                        getWithPagination: false,
                      ),
                    );

                    appBloc.add(ChangeBasePage(0));
                    boutiqueBloc.add(ResetAllSelectedAppliedFilterEvent());
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
                      try {
                        Navigator.of(context).pop();
                      } catch (e) {}
                    }
                    appBloc.add(ChangeBasePage(1));
                    /////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.cartNavBarButton,
                    );
                  },
                  child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) {
                      return previous.updateItemInCartStatus !=
                              current.updateItemInCartStatus ||
                          previous.addItemInCartStatus !=
                              current.addItemInCartStatus ||
                          previous.deleteItemInCartStatus !=
                              current.deleteItemInCartStatus ||
                          previous.getCartItemsStatus !=
                              current.getCartItemsStatus;
                    },
                    builder: (context, stateHome) {
                      int qtyItemsInCart =
                          stateHome.cartCollection?.length ?? 0;
                      /*  stateHome.cartCollection?.forEach(
                        (element) {
                          qtyItemsInCart =
                              qtyItemsInCart + (element.quantity ?? 0);
                        },
                      );*/
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(children: [
                            Container(
                                width: 50,
                                child: state.currentIndex == 1
                                    ? SvgPicture.asset(
                                        AppAssets.bagsSvg,
                                        height: 30.h,
                                      )
                                    : SvgPicture.asset(
                                        AppAssets.cartSvg,
                                        height: 30.h,
                                      )),
                            (qtyItemsInCart > 0)
                                ? Positioned(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.green),
                                      child: MyTextWidget(
                                        (qtyItemsInCart > 0)
                                            ? "${qtyItemsInCart}"
                                            : "",
                                        maxLines: 1,
                                        style: textTheme.titleSmall?.ra
                                            .copyWith(
                                                fontSize: 12,
                                                color: Colors.white,
                                                letterSpacing: 0.28),
                                      ),
                                    ),
                                    top: 0,
                                    right:
                                        (qtyItemsInCart.toString().length) > 1
                                            ? 1
                                            : 5,
                                  )
                                : SizedBox.shrink()
                          ]),
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
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) =>
                      previous.loginToChatStatus != current.loginToChatStatus,
                  builder: (context, authState) {
                    return InkWell(
                      key: TestVariables.kTestMode
                          ? Key(WidgetsKeys.chatNavBarKey)
                          : null,
                      onTap: () async {
                        if (authState.loginToChatStatus ==
                            LoginToChatStatus.loading) {
                          return;
                        }
                        if (prefsRepository.isVerifiedPhone != true ||
                            (prefsRepository.isLogInToChat ?? false) != true ||
                            (prefsRepository.chatToken?.length ?? 0) < 7) {
                          widget.isShowPanelForVerified.value = true;
                        } else if ((prefsRepository.myMarketName?.length ?? 0) <
                            3) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return UpdateUserNameWidget();
                              });
                        } else {
                          NotificationSettings settings =
                              await FirebaseMessaging.instance
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
                          authState.loginToChatStatus ==
                                  LoginToChatStatus.loading
                              ? Container(
                                  height: 30.h,
                                  width: 30.h,
                                  child: TrydosLoader(size: 15))
                              : state.currentIndex == 2
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
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (p, c) =>
                        p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
                        p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus ||
                        c.verifyOtpFromGuestStatus !=
                            p.verifyOtpFromGuestStatus ||
                        p.registerGuestStatus != c.registerGuestStatus,
                    builder: (context, authstate) {
                      return InkWell(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: MyTextWidget('Dev tools'),
                                  actions: [
                                    BlocBuilder<HomeBloc, HomeState>(
                                      buildWhen: (p, c) =>
                                          p.getAllowedCountriesModel !=
                                              c.getAllowedCountriesModel ||
                                          p.getStartingSettingsStatus !=
                                              c.getStartingSettingsStatus,
                                      builder: (context, homestate) {
                                        return Container(
                                          alignment: Alignment.center,
                                          width: 300,
                                          height: 390,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                left: 10,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
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
                                                      child: MyTextWidget(
                                                          'requests'),
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
                                                                    SwitchListForNotification()));
                                                      },
                                                      child: MyTextWidget(
                                                          'Firebase Setting'),
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
                                                      child: MyTextWidget(
                                                          'files exists'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    EditUrlsPage()));
                                                      },
                                                      child: MyTextWidget(
                                                          'Edit Urls'),
                                                    ),
                                                    SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: IconButton(
                                                        icon: Icon(Icons
                                                            .notifications),
                                                        color: Colors.red,
                                                        onPressed: () {
                                                          HelperFunctions
                                                              .slidingNavigation(
                                                            context,
                                                            NotificationsPage(),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    //////////////
                                                    TextButton(
                                                      onPressed: () {
                                                        BlocProvider.of<
                                                                    HomeBloc>(
                                                                context)
                                                            .add(
                                                                ClearAllAppCashEvent());
                                                        BlocProvider.of<
                                                                    HomeBloc>(
                                                                context)
                                                            .add(
                                                                SaveUserInfoFromAuthEvent(
                                                                    userInfo:
                                                                        User(
                                                          alternativePhone: "",
                                                          email: "",
                                                          gender: null,
                                                          id: null,
                                                          image: "",
                                                          isPhoneVerified: 0,
                                                          lastOtpIdToken: "",
                                                          name: "",
                                                          phone: "",
                                                          tall: null,
                                                          weight: null,
                                                        )));
                                                        prefsRepository
                                                            .setVerifiedPhone(
                                                                false);
                                                        prefsRepository
                                                            .setPhoneNumber("");
                                                        prefsRepository
                                                            .setChatToken("");
                                                        prefsRepository
                                                            .setMarketToken(
                                                                null);
                                                        prefsRepository
                                                            .setMyMarketName(
                                                                "");
                                                        prefsRepository
                                                            .setMyProfilePhoto(
                                                                "");
                                                        Future.delayed(
                                                          Duration(
                                                              microseconds:
                                                                  500),
                                                          () {
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacement(
                                                                    PageRouteBuilder(
                                                              pageBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation) =>
                                                                  RegistrationPage(
                                                                      fromLogOut:
                                                                          true),
                                                            ));
                                                          },
                                                        );
                                                      },
                                                      child: MyTextWidget(
                                                          'log out'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        onTap: () {
                          /*  if (!(prefsRepository.isVerifiedPhone ?? false)) {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                RegistrationPage(),
                          ));
                        } else {*/
                          if (authstate.registerGuestStatus ==
                                  RegisterGuestStatus.loading ||
                              authstate.verifyOtpFromGuestStatus ==
                                  VerifyOtpFromGuestStatus.loading ||
                              authstate.verifyOtpSignInStatus ==
                                  VerifyOtpInProfileStatus.loading ||
                              authstate.verifyOtpSignUpStatus ==
                                  VerifyOtpSignUpStatus.loading) {
                            return;
                          }
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                          appBloc.add(ChangeBasePage(3));
                          //  }

                          /*      // if (prefsRepository.chatToken != null) return;
                        //appBloc.add(ChangeBasePage(0));
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              RegistrationPage(),
                        ));
                        /////////////////////////
                        FirebaseAnalyticsService.logEventForSession(
                          eventName: AnalyticsEventsConst.buttonClicked,
                          executedEventName:
                              AnalyticsExecutedEventNameConst.meNavBarButton,
                        );*/
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            authstate.registerGuestStatus ==
                                        RegisterGuestStatus.loading ||
                                    authstate.verifyOtpFromGuestStatus ==
                                        VerifyOtpFromGuestStatus.loading ||
                                    authstate.verifyOtpSignInStatus ==
                                        VerifyOtpInProfileStatus.loading ||
                                    authstate.verifyOtpSignUpStatus ==
                                        VerifyOtpSignUpStatus.loading
                                ? Container(
                                    height: 30.h,
                                    width: 30.h,
                                    child: TrydosLoader(size: 15))
                                : prefsRepository.myProfilePhoto == null ||
                                        prefsRepository.myProfilePhoto == ""
                                    ? Container(
                                        height: 30.h,
                                        width: 30.h,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppAssets.profileJpg),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                            width: 1.0,
                                            color: (state.currentIndex == 3)
                                                ? const Color(0xfff53c3c)
                                                : Color(0xfffff),
                                          ),
                                        ))
                                    : Container(
                                        height: 30.h,
                                        width: 30.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                            width: 1.0,
                                            color: (state.currentIndex == 3)
                                                ? const Color(0xfff53c3c)
                                                : Color(0xfffff),
                                          ),
                                        ),
                                        child: MyCachedNetworkImage(
                                            imageUrl:
                                                prefsRepository.myProfilePhoto!,
                                            height: 30.h,
                                            width: 30.h,
                                            imageFit: BoxFit.cover)),
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
                            /*  : SizedBox(
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
                                                  ),*/
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
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}
