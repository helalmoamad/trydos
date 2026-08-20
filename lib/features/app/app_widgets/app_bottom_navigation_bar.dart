import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/update_user_name_widget.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/user_info_page.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/guest_phone_verification_dialog.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart'
    show ChatBloc;
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/feed_back/presentation/pages/feed_back_page.dart';
import 'package:trydos/features/feed_back/presentation/pages/shared_preference_page.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/notification_service/setting_fitrbase_notification.dart';
import '../../../common/helper/helper_functions.dart';
import '../../../common/test_utils/test_var.dart';
import '../../../core/domin/repositories/prefs_repository.dart';
import '../../../core/utils/theme_state.dart';
import '../../home/presentation/pages/notifications_page.dart';
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
  late BoutiqueBloc boutiqueBloc;
  late CategoryBloc categoryBloc;
  late AuthBloc authBloc;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    super.initState();
  }

  @override
  dispose() {
    // هذه بلوكات @LazySingleton يملكها GetIt طوال عمر التطبيق؛ لا نُغلقها هنا.
    // إغلاقها كان يُغلق الـ singleton للتطبيق كله فتفشل أي إضافة حدث لاحقة بـ:
    // "Cannot add new events after calling close" (ظهر عند تسجيل الخروج).
    super.dispose();
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
                // ignore: deprecated_member_use
                color: colorScheme.black.withOpacity(0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: BlocBuilder<BoutiqueBloc, BoutiqueState>(
                  buildWhen: (previous, current) =>
                      previous
                              .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                              ?.paginationStatus !=
                          current
                              .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                              ?.paginationStatus ||
                      previous
                              .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                              ?.paginationStatus !=
                          current
                              .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                              ?.paginationStatus ||
                      previous
                              .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                              ?.paginationStatus !=
                          current
                              .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                              ?.paginationStatus ||
                      previous.getProductFiltersStatus["*flashDeal*"] !=
                          current.getProductFiltersStatus["*flashDeal*"],
                  builder: (context, boutiqueState) {
                    return InkWell(
                      onTap: () {
                        if (boutiqueState.currentMainCategoryTaped != "Empty" &&
                            boutiqueState.currentMainCategoryTaped != "") {
                          boutiqueBloc.add(
                            AddCurrentMainCategoryTapedEvent(
                              currentMainCategoryTaped: "Empty",
                            ),
                          );
                          categoryBloc.add(
                            ChangeCurrentIndexForMainCategoryEvent(index: -1),
                          );
                          if (!(boutiqueState
                                      .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading ||
                              boutiqueState
                                      .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading ||
                              boutiqueState
                                      .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading)) {
                            boutiqueBloc.add(
                              const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                categorySlugs: [],
                                cashedOrginalBoutique: true,
                                boutiqueSlug: "*featured*",
                              ),
                            );
                            boutiqueBloc.add(
                              const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                categorySlugs: [],
                                cashedOrginalBoutique: true,
                                boutiqueSlug: "*flashDeal*",
                              ),
                            );
                            boutiqueBloc.add(
                              const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                categorySlugs: [],
                                cashedOrginalBoutique: true,
                                boutiqueSlug: "*recommended*",
                              ),
                            );
                          }

                          appBloc.add(ChangeTab(-1));
                          categoryBloc.add(
                            ChangeCurrentIndexForMainCategoryEvent(index: -1),
                          );
                        }

                        if (Navigator.of(context).canPop()) {
                          try {
                            Navigator.of(context).pop();
                          } catch (e) {}
                        }

                        categoryBloc.add(
                          GetHomeBoutiqesEvent(
                            getWithPrefetchToStoreInMemory: false,
                            getWithOutPrefetchForEachBoutiques: true,

                            categorySlug: "Empty",
                            offset: "1",
                          ),
                        );

                        appBloc.add(ChangeBasePage(0));
                        boutiqueBloc.add(ResetAllSelectedAppliedFilterEvent());
                        /////////////////////////
                        // FirebaseAnalyticsService.logEventForSession(
                        //   eventName: AnalyticsEventsConst.buttonClicked,
                        //   executedEventName:
                        //       AnalyticsButtonsEventNameConst.homeNavBarButton,
                        // );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          state.currentIndex == 0
                              ? SvgPicture.asset(
                                  AppAssets.bottomBarLogoActiveSvg,
                                  height: 30.h,
                                )
                              : SvgPicture.asset(
                                  AppAssets.bottomBarLogoActiveSvg,
                                  height: 30.h,
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
                    );
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      try {
                        Navigator.of(context).pop();
                      } catch (e) {}
                    }
                    appBloc.add(ChangeBasePage(1));
                    /////////////////////////
                    // FirebaseAnalyticsService.logEventForSession(
                    //   eventName: AnalyticsEventsConst.buttonClicked,
                    //   executedEventName:
                    //       AnalyticsButtonsEventNameConst.cartNavBarButton,
                    // );
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
                          Stack(
                            children: [
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
                                      ),
                              ),
                              (qtyItemsInCart > 0)
                                  ? Positioned(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          color: Colors.green,
                                        ),
                                        child: MyTextWidget(
                                          (qtyItemsInCart > 0)
                                              ? "${qtyItemsInCart}"
                                              : "",
                                          maxLines: 1,
                                          style: textTheme.titleSmall?.rq
                                              .copyWith(
                                                fontSize: 12,
                                                color: Colors.white,
                                                letterSpacing: 0.28,
                                              ),
                                        ),
                                      ),
                                      top: 0,
                                      right:
                                          (qtyItemsInCart.toString().length) > 1
                                          ? 1
                                          : 5,
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          10.verticalSpace,
                          MyTextWidget(
                            LocaleKeys.cart.tr(),
                            maxLines: 1,
                            style: textTheme.titleSmall?.lq.copyWith(
                              color: state.currentIndex != 1
                                  ? colorScheme.grey200
                                  : colorScheme.black,
                              letterSpacing: 0.28,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) =>
                      previous.loginToChatStatus != current.loginToChatStatus ||
                      previous.verifyOtpSignInStatus !=
                          current.verifyOtpSignInStatus ||
                      previous.verifyOtpSignUpStatus !=
                          current.verifyOtpSignUpStatus ||
                      current.verifyOtpFromGuestStatus !=
                          previous.verifyOtpFromGuestStatus ||
                      previous.registerGuestStatus !=
                          current.registerGuestStatus,
                  builder: (context, authState) {
                    return InkWell(
                      key: TestVariables.kTestMode
                          ? const Key(WidgetsKeys.chatNavBarKey)
                          : null,
                      onTap: () async {
                        if (authState.loginToChatStatus ==
                                LoginToChatStatus.loading ||
                            authState.registerGuestStatus ==
                                RegisterGuestStatus.loading ||
                            authState.verifyOtpFromGuestStatus ==
                                VerifyOtpFromGuestStatus.loading ||
                            authState.verifyOtpSignInStatus ==
                                VerifyOtpInProfileStatus.loading ||
                            authState.verifyOtpSignUpStatus ==
                                VerifyOtpSignUpStatus.loading) {
                          return;
                        }

                        if (prefsRepository.isVerifiedPhone != true ||
                            (prefsRepository.isLogInToChat ?? false) != true ||
                            (prefsRepository.chatToken?.length ?? 0) < 7) {
                          appBloc.add(ChangeBasePage(0));
                          Future.delayed(
                            const Duration(milliseconds: 300),
                            () => GuestPhoneVerificationDialog.show(context),
                          );
                        } else if ((prefsRepository.myMarketName?.length ?? 0) <
                            3) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return UpdateUserNameWidget();
                            },
                          );
                        } else {
                          NotificationSettings settings =
                              await FirebaseMessaging.instance
                                  .getNotificationSettings();
                          if (settings.authorizationStatus ==
                              AuthorizationStatus.denied) {
                            openAppSettings();
                            showWarningMessage(
                              context,
                              LocaleKeys
                                  .please_enable_send_notification_for_this_app
                                  .tr(),
                            );
                          } else {
                            if (context.canPop()) {
                              Navigator.of(context).pop();
                            }
                            appBloc.add(ChangeBasePage(2));
                          }
                        }
                        /////////////////////////
                        // FirebaseAnalyticsService.logEventForSession(
                        //   eventName: AnalyticsEventsConst.buttonClicked,
                        //   executedEventName:
                        //       AnalyticsButtonsEventNameConst.chatNavBarButton,
                        // );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          authState.loginToChatStatus ==
                                      LoginToChatStatus.loading ||
                                  authState.registerGuestStatus ==
                                      RegisterGuestStatus.loading ||
                                  authState.verifyOtpFromGuestStatus ==
                                      VerifyOtpFromGuestStatus.loading ||
                                  authState.verifyOtpSignInStatus ==
                                      VerifyOtpInProfileStatus.loading ||
                                  authState.verifyOtpSignUpStatus ==
                                      VerifyOtpSignUpStatus.loading
                              ? Container(
                                  height: 40.h,
                                  width: 40.h,
                                  child: TrydosLoader(size: 15),
                                )
                              : state.currentIndex == 2
                              ? SvgPicture.asset(
                                  AppAssets.activeChatSvg,
                                  height: 30.h,
                                )
                              : BlocBuilder<ChatBloc, ChatState>(
                                  buildWhen: (p, c) =>
                                      p.unReadMessagesFromAllChats !=
                                      c.unReadMessagesFromAllChats,
                                  builder: (context, state) {
                                    return Container(
                                      height: 30.h,
                                      width: 30.h,
                                      child: Stack(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.chatSvg,
                                            height: 30.h,
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Visibility(
                                              visible:
                                                  state
                                                      .unReadMessagesFromAllChats >
                                                  0,
                                              child: Row(
                                                children: [
                                                  MyTextWidget(
                                                    state
                                                        .unReadMessagesFromAllChats
                                                        .toString(),
                                                    maxLines: 1,
                                                    style: context
                                                        .textTheme
                                                        .titleMedium
                                                        ?.rq
                                                        .copyWith(
                                                          color: const Color(
                                                            0xff007CFF,
                                                          ),
                                                        ),
                                                  ),
                                                  2.horizontalSpace,
                                                  SvgPicture.asset(
                                                    AppAssets
                                                        .chatNotificationSvg,
                                                    height: 12.h,
                                                    width: 12.h,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          10.verticalSpace,
                          MyTextWidget(
                            LocaleKeys.chat.tr(),
                            maxLines: 1,
                            style: textTheme.titleSmall?.lq.copyWith(
                              letterSpacing: 0.28,
                              color: state.currentIndex != 2
                                  ? colorScheme.grey200
                                  : colorScheme.black,
                            ),
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
                              content: const MyTextWidget('Dev tools'),
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
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'requests',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            SharedPreferencePage(),
                                                      ),
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'shared preferences',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const SwitchListForNotification(),
                                                      ),
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'Firebase Setting',
                                                  ),
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
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'flutter errors',
                                                  ),
                                                ),

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const UserInfoPage(),
                                                      ),
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'add user info',
                                                  ),
                                                ),
                                                /*TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const AddCallUrl(),
                                                      ),
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'Add Call URl',
                                                  ),
                                                ),*/
                                                /*  TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    FilesExistPage()));
                                                      },
                                                      child: const MyTextWidget(
                                                          'files exists'),
                                                    ),*/
                                                /*      TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    EditUrlsPage()));
                                                      },
                                                      child: MyTextWidget(
                                                          'Edit Urls'),
                                                    ),*/
                                                TextButton(
                                                  onPressed: () {
                                                    prefsRepository
                                                        .resetAllRedeemTimer();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const MyTextWidget(
                                                    'ٌReset Redeem Timer',
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.notifications,
                                                    ),
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      HelperFunctions.slidingNavigation(
                                                        context,
                                                        const NotificationsPage(),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                //////////////
                                                TextButton(
                                                  onPressed: () async {
                                                    prefsRepository
                                                                .getFcmTokens
                                                                .length >
                                                            0
                                                        ? authBloc.add(
                                                            DeleteFcmTokenFromChatEvent(
                                                              fcmToken:
                                                                  prefsRepository
                                                                      .getFcmTokens[0],
                                                            ),
                                                          )
                                                        : null;
                                                    prefsRepository.addFcmToken(
                                                      "",
                                                    );
                                                    await Future.delayed(
                                                      const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                    );
                                                    GetIt.I<HomeBloc>().add(
                                                      const ClearAllAppCashEvent(),
                                                    );
                                                    clearCustomCashe();
                                                    prefsRepository
                                                        .setIsFoundDataCashed(
                                                          false,
                                                        );
                                                    GetIt.I<AppBloc>().add(
                                                      ChangeBasePage(0),
                                                    );
                                                    GetIt.I<HomeBloc>().add(
                                                      SaveUserInfoFromAuthEvent(
                                                        userInfo: User(
                                                          alternativePhone: "",
                                                          email: "",
                                                          image: "",
                                                          isPhoneVerified: 0,
                                                          lastOtpIdToken: "",
                                                          name: "",
                                                          phone: "",
                                                        ),
                                                      ),
                                                    );

                                                    prefsRepository
                                                        .setVerifiedPhone(
                                                          false,
                                                        );
                                                    prefsRepository
                                                        .setPhoneNumber("");
                                                    prefsRepository
                                                        .setChatToken("");
                                                    prefsRepository
                                                        .setMarketToken(null);
                                                    prefsRepository
                                                        .setMyMarketName("");
                                                    prefsRepository
                                                        .setWalletToken("");
                                                    prefsRepository
                                                        .setStoriesToken("");
                                                    prefsRepository
                                                        .setMyChatName("");
                                                    prefsRepository
                                                        .setMyStoriesName("");

                                                    prefsRepository
                                                        .setMyProfilePhoto("");
                                                    String? deviceId =
                                                        await HelperFunctions.getDeviceId();

                                                    GetIt.I<AuthBloc>().add(
                                                      RegisterGuestEvent(
                                                        deviceId:
                                                            deviceId ?? "",
                                                      ),
                                                    );
                                                    HydratedBloc.storage
                                                        .clear();
                                                    GetIt.I<ChatBloc>().add(
                                                      const ClearChatEvent(),
                                                    );

                                                    Future.delayed(
                                                      const Duration(
                                                        microseconds: 500,
                                                      ),
                                                      () {
                                                        GoRouter.of(
                                                          context,
                                                        ).go("/");
                                                      },
                                                    );
                                                  },
                                                  child: const MyTextWidget(
                                                    'log out',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
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
                                  child: TrydosLoader(size: 15),
                                )
                              : prefsRepository.myProfilePhoto == null ||
                                    prefsRepository.myProfilePhoto == ""
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
                                      color: (state.currentIndex == 3)
                                          ? const Color(0xfff53c3c)
                                          : const Color(0xfffff),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 30.h,
                                  width: 30.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                      color: (state.currentIndex == 3)
                                          ? const Color(0xfff53c3c)
                                          : const Color(0xfffff),
                                    ),
                                  ),
                                  child: MyCachedNetworkImage(
                                    imageUrl: prefsRepository.myProfilePhoto!,
                                    height: 30.h,
                                    width: 30.h,
                                    imageFit: BoxFit.cover,
                                  ),
                                ),
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
                            style: textTheme.titleSmall?.lq.copyWith(
                              letterSpacing: 0.28,
                              color: state.currentIndex != 3
                                  ? colorScheme.grey200
                                  : colorScheme.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
