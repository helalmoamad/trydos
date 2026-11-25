import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
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
import '../../../core/domin/repositories/prefs_repository.dart';
import '../../../core/utils/theme_state.dart';
import '../../home/presentation/pages/notifications_page.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';
import '../my_text_widget.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'nav_v2/app_bottom_nav_v2.dart';

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
        return _navV2(state);
      },
    );
  }
  /* ------------------------------ شريط التصميم الجديد ----------------------- */

  /// ترتيب خانات التصميم: 0 الرئيسيّة، 1 البحث، 2 السلّة، 3 الدردشة،
  /// 4 الحساب. وترتيب صفحات التطبيق غيرُه: 0 الرئيسيّة، 1 السلّة، 2 الدردشة،
  /// 3 الحساب، 4 البحث. فهذا المحوّل بينهما.
  static int? _designIndexOf(int appIndex) => switch (appIndex) {
    0 => 0,
    4 => 1,
    1 => 2,
    2 => 3,
    3 => 4,
    _ => null,
  };

  Widget _navV2(AppState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) =>
          p.loginToChatStatus != c.loginToChatStatus ||
          p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
          p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus ||
          p.verifyOtpFromGuestStatus != c.verifyOtpFromGuestStatus ||
          p.registerGuestStatus != c.registerGuestStatus,
      builder: (context, authState) {
        // الانتظار نفسه الذي كان يُظهر مؤشّر التحميل على خانتي الدردشة
        // والحساب في الشريط السابق.
        final bool chatBusy =
            authState.loginToChatStatus == LoginToChatStatus.loading ||
            authState.registerGuestStatus == RegisterGuestStatus.loading ||
            authState.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.loading ||
            authState.verifyOtpSignInStatus ==
                VerifyOtpInProfileStatus.loading ||
            authState.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.loading;
        final bool profileBusy =
            authState.registerGuestStatus == RegisterGuestStatus.loading ||
            authState.verifyOtpFromGuestStatus ==
                VerifyOtpFromGuestStatus.loading ||
            authState.verifyOtpSignInStatus ==
                VerifyOtpInProfileStatus.loading ||
            authState.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.loading;

        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) =>
              p.updateItemInCartStatus != c.updateItemInCartStatus ||
              p.addItemInCartStatus != c.addItemInCartStatus ||
              p.deleteItemInCartStatus != c.deleteItemInCartStatus ||
              p.getCartItemsStatus != c.getCartItemsStatus,
          builder: (context, homeState) {
            return BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (p, c) =>
                  p.unReadMessagesFromAllChats != c.unReadMessagesFromAllChats,
              builder: (context, chatState) {
                final String? photo = prefsRepository.myProfilePhoto;
                return AppBottomNavV2(
                  active: _designIndexOf(state.currentIndex),
                  // الشاشة الجديدة تبدأ من أعلاها، فيعود الشريط إلى حجمه.
                  resetKey: state.currentIndex,
                  labels: <String>[
                    LocaleKeys.home_tab.tr(),
                    LocaleKeys.search.tr(),
                    LocaleKeys.cart.tr(),
                    LocaleKeys.chat.tr(),
                    LocaleKeys.me.tr(),
                  ],
                  photo: (photo?.isEmpty ?? true) ? null : photo,
                  verified: prefsRepository.isVerifiedPhone ?? false,
                  cartCount: homeState.cartCollection?.length ?? 0,
                  chatCount: chatState.unReadMessagesFromAllChats,
                  busy: <int>{if (chatBusy) 3, if (profileBusy) 4},
                  onSelect: _selectV2,
                  // أدوات المطوّر: ضغطٌ مطوّل على خانة الحساب، كما كان.
                  onLongPress: (int index) {
                    if (index == 4) _showDevToolsV2();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _selectV2(int designIndex) {
    switch (designIndex) {
      case 0:
        _openHomeV2();
      case 1:
        _openSearchV2();
      case 2:
        _openCartV2();
      case 3:
        _openChatV2();
      case 4:
        _openProfileV2();
    }
  }

  void _popIfCanV2() {
    if (!context.canPop()) return;
    try {
      Navigator.of(context).pop();
    } catch (e) {
      devLog('app_bottom_navigation_bar.dart: ignored error', e);
    }
  }

  /// منطق خانة الرئيسيّة كما كان حرفياً، وحالةُ البوتيك تُقرأ من البلوك بدل
  /// `BlocBuilder` الذي كان يلفّ الخانة.
  void _openHomeV2() {
    final BoutiqueState boutiqueState = boutiqueBloc.state;
    if (boutiqueState.currentMainCategoryTaped != "Empty" &&
        boutiqueState.currentMainCategoryTaped != "") {
      boutiqueBloc.add(
        AddCurrentMainCategoryTapedEvent(currentMainCategoryTaped: "Empty"),
      );
      categoryBloc.add(ChangeCurrentIndexForMainCategoryEvent(index: -1));
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
        for (final String slug in <String>[
          "*featured*",
          "*flashDeal*",
          "*recommended*",
        ]) {
          boutiqueBloc.add(
            GetProductWithFiltersWithoutCancelingPreviousEvents(
              categorySlugs: const <String>[],
              cashedOrginalBoutique: true,
              boutiqueSlug: slug,
            ),
          );
        }
      }

      appBloc.add(ChangeTab(-1));
      categoryBloc.add(ChangeCurrentIndexForMainCategoryEvent(index: -1));
    }

    _popIfCanV2();

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
  }

  /// خانةٌ جديدة: التصميم فيه خمسُ خانات والبحث إحداها. ومدخلُ البحث السابق
  /// (زرّ العدسة في شريط التصنيفات) كان يُخفي الشريط السفليّ
  /// (`HideBottomNavigationBar(true)`)؛ وهنا لا يُخفى، فالبحث صار تبويباً
  /// يُرى في الشريط كبقيّة التبويبات — وهذا ما يرسمه الويب.
  void _openSearchV2() {
    _popIfCanV2();
    appBloc.add(ChangeIndexForSearch(2));
    appBloc.add(ChangeBasePage(4));
  }

  void _openCartV2() {
    _popIfCanV2();
    appBloc.add(ChangeBasePage(1));
  }

  /// منطق خانة الدردشة كما كان حرفياً.
  Future<void> _openChatV2() async {
    final AuthState authState = authBloc.state;
    if (authState.loginToChatStatus == LoginToChatStatus.loading ||
        authState.registerGuestStatus == RegisterGuestStatus.loading ||
        authState.verifyOtpFromGuestStatus ==
            VerifyOtpFromGuestStatus.loading ||
        authState.verifyOtpSignInStatus == VerifyOtpInProfileStatus.loading ||
        authState.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.loading) {
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
    } else if ((prefsRepository.myMarketName?.length ?? 0) < 3) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return UpdateUserNameWidget();
        },
      );
    } else {
      NotificationSettings settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (!mounted) return;
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        openAppSettings();
        showWarningMessage(
          context,
          LocaleKeys.please_enable_send_notification_for_this_app.tr(),
        );
      } else {
        _popIfCanV2();
        appBloc.add(ChangeBasePage(2));
      }
    }
  }

  /// منطق خانة الحساب كما كان حرفياً.
  void _openProfileV2() {
    final AuthState authState = authBloc.state;
    if (authState.registerGuestStatus == RegisterGuestStatus.loading ||
        authState.verifyOtpFromGuestStatus ==
            VerifyOtpFromGuestStatus.loading ||
        authState.verifyOtpSignInStatus == VerifyOtpInProfileStatus.loading ||
        authState.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.loading) {
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    appBloc.add(ChangeBasePage(3));
  }

  /// أدوات المطوّر: ما كان جسم `onLongPress` على خانة الحساب حرفياً،
  /// مُستخرَجاً ليستدعيه الشريطان — القديم والجديد.
  void _showDevToolsV2() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const MyTextWidget('Dev tools'),
          actions: [
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (p, c) =>
                  p.getAllowedCountriesModel != c.getAllowedCountriesModel ||
                  p.getStartingSettingsStatus != c.getStartingSettingsStatus,
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FeedBackScreen(showRequests: true),
                                  ),
                                );
                              },
                              child: const MyTextWidget('requests'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SharedPreferencePage(),
                                  ),
                                );
                              },
                              child: const MyTextWidget('shared preferences'),
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
                              child: const MyTextWidget('Firebase Setting'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FeedBackScreen(showRequests: false),
                                  ),
                                );
                              },
                              child: const MyTextWidget('flutter errors'),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UserInfoPage(),
                                  ),
                                );
                              },
                              child: const MyTextWidget('add user info'),
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
                                prefsRepository.resetAllRedeemTimer();
                                Navigator.pop(context);
                              },
                              child: const MyTextWidget('ٌReset Redeem Timer'),
                            ),
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                icon: const Icon(Icons.notifications),
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
                                prefsRepository.getFcmTokens.length > 0
                                    ? authBloc.add(
                                        DeleteFcmTokenFromChatEvent(
                                          fcmToken:
                                              prefsRepository.getFcmTokens[0],
                                        ),
                                      )
                                    : null;
                                prefsRepository.addFcmToken("");
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
                                GetIt.I<HomeBloc>().add(
                                  const ClearAllAppCashEvent(),
                                );
                                clearCustomCashe();
                                prefsRepository.setIsFoundDataCashed(false);
                                GetIt.I<AppBloc>().add(ChangeBasePage(0));
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

                                prefsRepository.setVerifiedPhone(false);
                                prefsRepository.setPhoneNumber("");
                                prefsRepository.setChatToken("");
                                prefsRepository.setMarketToken(null);
                                prefsRepository.setMyMarketName("");
                                prefsRepository.setWalletToken("");
                                prefsRepository.setStoriesToken("");
                                prefsRepository.setStoriesRefreshToken("");
                                prefsRepository.setMyChatName("");
                                prefsRepository.setMyStoriesName("");

                                prefsRepository.setMyProfilePhoto("");
                                String? deviceId =
                                    await HelperFunctions.getDeviceId();

                                GetIt.I<AuthBloc>().add(
                                  RegisterGuestEvent(deviceId: deviceId ?? ""),
                                );
                                HydratedBloc.storage.clear();
                                GetIt.I<ChatBloc>().add(const ClearChatEvent());

                                Future.delayed(
                                  const Duration(microseconds: 500),
                                  () {
                                    GoRouter.of(context).go("/");
                                  },
                                );
                              },
                              child: const MyTextWidget('log out'),
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
  }
}
