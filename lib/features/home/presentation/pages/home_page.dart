import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:html/parser.dart' show parse;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/widgets/features_products_widget.dart';
import 'package:trydos/features/home/presentation/widgets/flash_deal_products_widget.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_boutique_card.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_quick_view_popup.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/home/presentation/widgets/recommend_products_widget.dart';
import 'package:trydos/features/home/presentation/widgets/sliver_list_seprated.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/request_permission_notification.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../../../story/presentation/widget/stories_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ðŸ›¡ï¸ Ø­Ù…Ø§ÙŠØ© Ø­Ø§Ù„Ø© Ø§Ù„ØµÙØ­Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©

  late AppBloc appBloc;
  late BoutiqueBloc boutiqueBloc;
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  late CategoryBloc categoryBloc;
  ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();
  final ValueNotifier<String?> productNotAvailableNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> loadingForRquestProductDetails = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> productIsFlashDeal = ValueNotifier(false);
  final ValueNotifier<bool> productIsRecommend = ValueNotifier(false);
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  String selectedCategorySlug = "Empty";
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
  final ValueNotifier<bool> finishRedeem = ValueNotifier(false);
  Timer? debounce;
  // Variables to prevent excessive API calls

  Timer? _fastScrollTimer;
  Timer? _emergencyMemoryTimer;

  /// Ù„ØªÙØ§Ø¯ÙŠ Ø¥Ø±Ø³Ø§Ù„ Ø£Ø­Ø¯Ø§Ø« Bloc ÙÙŠ ÙƒÙ„ rebuild â€” Ù†Ø±Ø³Ù„ ÙÙ‚Ø· Ø¹Ù†Ø¯ ØªØºÙŠÙ‘Ø± tapIndex
  bool _isQuickViewOpen = false;

  /// ÙƒØ§Ø´ ÙˆØµÙ Ø§Ù„Ø¨ÙˆØªÙŠÙƒ Ø¨Ø¯ÙˆÙ† HTML (Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø© Ù„ÙƒÙ„ Ø¨ÙˆØªÙŠÙƒ â€” Ø§Ù„ÙƒØ§Ø±Ø¯ ÙŠØ¨Ù‚Ù‰ StatelessWidget)
  final Map<String, String> _boutiqueDescriptionCache = {};

  static String _stripHtmlTagsForBoutique(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement?.text ?? '';
    return parsedString.trim();
  }

  /// ÙÙ„ØªØ±Ø© Ø¹Ø±ÙˆØ¶ Ø§Ù„ÙÙ„Ø§Ø´ Ø­Ø³Ø¨ ØªØ§Ø±ÙŠØ® Ø§Ù„Ø§Ù†ØªÙ‡Ø§Ø¡ (Ø®Ø§Ø±Ø¬ Ø§Ù„Ù€ builder Ù„ØªØ­Ø³ÙŠÙ† Ø§Ù„Ø£Ø¯Ø§Ø¡)
  /// يفتح نافذة تفاصيل/شراء المنتج كـ popup منفصل عند الضغط على منتج.
  ///
  /// المنطق كاملاً في [ProductQuickViewPopup]؛ هنا نتكفّل فقط بفتح المسار مرة
  /// واحدة، وباستعادة حالة الصفحة عند إغلاقه مهما كان السبب (زر الرجوع مثلاً).
  void _handleQuickViewRequest() {
    if (!mounted || _isQuickViewOpen) return;
    if (tapIndexToAddProductToCart.value == -1) return;

    _isQuickViewOpen = true;
    ProductQuickViewPopup.show(
      context: context,
      tapIndexToAddProductToCart: tapIndexToAddProductToCart,
      productIsFlashDeal: productIsFlashDeal,
      productIsRecommend: productIsRecommend,
      finishRedeem: finishRedeem,
      visibleFlashDeal: visibleFlashDeal,
      showShadowForPanel: showShadowForPanel,
      loadingForRquestProductDetails: loadingForRquestProductDetails,
      currentActiveTab: currentActiveTab,
      addToBagButtonShapeNotifier: addToBagButtonShapeNotifier,
      productNotAvailableNotifier: productNotAvailableNotifier,
      panelController: panelControllerForCart,
    ).whenComplete(() {
      _isQuickViewOpen = false;
      if (!mounted) return;
      showShadowForPanel.value = false;
      if (tapIndexToAddProductToCart.value != -1) {
        tapIndexToAddProductToCart.value = -1;
      }
      appBloc.add(HideBottomNavigationBar(false));
      currentActiveTab.value = 0;
    });
  }

  /// âš¡ Ù†Ø¸Ø§Ù… ØªØ­Ø³ÙŠÙ† Ø§Ù„ØªÙ…Ø±ÙŠØ± Ø§Ù„Ø³Ø±ÙŠØ¹ Ø§Ù„Ø°ÙƒÙŠ Ù„Ù„ØµÙØ­Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©
  void listenToScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 300), () {
      int lastIndexSeenByUser =
          (scrollController.position.pixels +
              scrollController.position.viewportDimension +
              235) ~/
          235;
      int currentSelectedMainCategoryTab = appBloc.state.tabIndex;

      if (currentSelectedMainCategoryTab == -1) {
        selectedCategorySlug = "Empty";
      } else {
        selectedCategorySlug =
            categoryBloc
                .state
                .mainCategoriesResponseModel
                ?.data
                ?.mainCategories?[currentSelectedMainCategoryTab]
                .slug ??
            '';
      }

      if (selectedCategorySlug == '') return;
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.4)) {
        categoryBloc.add(
          GetHomeBoutiqesEvent(
            getWithPrefetchToStoreInMemory: false,
            categorySlug: selectedCategorySlug,
            offset:
                categoryBloc
                    .state
                    .getHomeBoutiquesPaginationObjectByMainCategory[selectedCategorySlug]!
                    .offset ??
                "",
            getWithPagination: true,
          ),
        );
      }
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.4)) {
        categoryBloc.prefetchBoutiques(
          selectedCategorySlug,

          lastIndexSeenByUser,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    LastPagesTracker.push("Home Page");
    scrollController.addListener(listenToScroll);
    tapIndexToAddProductToCart.addListener(_handleQuickViewRequest);

    if (!(prefsRepository.isRequestNotificationPermission ?? false)) {
      PermissionServices().requestNotificationPermission();
      prefsRepository.setRequestNotificationPermission(true);
    }
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    appBloc.add(ChangeIndexForSearch(0));
    prefsRepository.setLanguage(
      (LanguageService.isKurdish ? "ku" : LanguageService.languageCode),
    );
    // scrollController.addListener(listenToScroll);

    // Ù…Ø¹Ø§Ù„Ø¬ Ø§Ù„Ø£Ø®Ø·Ø§Ø¡ Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø© ÙÙ‚Ø· (ØªØ­Ø³ÙŠÙ† Ø£Ø¯Ø§Ø¡ - Ù„Ø§ Ø¯Ø§Ø®Ù„ build)
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    // ðŸš€ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ© ÙÙˆØ±Ø§Ù‹ ÙÙŠ Ø§Ù„Ø®Ù„ÙÙŠØ©
    _initializeBackgroundOperations();
  }

  /// Ø¬Ù„Ø¨ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø¹Ù†Ø¯ Ø§Ù„Ø³Ø­Ø¨ Ù„Ù„ØªØ­Ø¯ÙŠØ« (Ø®Ø§Ø±Ø¬ build Ù„ØªØ­Ø³ÙŠÙ† Ø§Ù„Ø£Ø¯Ø§Ø¡)
  Future<void> _refreshData() async {
    GetIt.I<BoutiqueBloc>().add(
      const GetProductWithFiltersWithoutCancelingPreviousEvents(
        categorySlugs: [],
        cashedOrginalBoutique: true,
        boutiqueSlug: "*featured*",
      ),
    );
    GetIt.I<BoutiqueBloc>().add(
      const GetProductWithFiltersWithoutCancelingPreviousEvents(
        categorySlugs: [],
        cashedOrginalBoutique: true,
        boutiqueSlug: "*recommended*",
      ),
    );
    GetIt.I<BoutiqueBloc>().add(
      const GetProductWithFiltersWithoutCancelingPreviousEvents(
        categorySlugs: [],
        cashedOrginalBoutique: true,
        boutiqueSlug: "*flashDeal*",
      ),
    );
    if (mounted) {
      BlocProvider.of<StoryBloc>(
        context,
      ).add(const GetStoryEvent(withPaginition: false));
      categoryBloc.add(const GetMainCategoriesEvent(getWithPrefech: false));
    }
  }

  /// ðŸš€ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø¹Ù…Ù„ÙŠØ§Øª ÙÙŠ Ø§Ù„Ø®Ù„ÙÙŠØ© Ø¯ÙˆÙ† ØªØ£Ø«ÙŠØ± Ø¹Ù„Ù‰ Ø§Ù„Ø¹Ø±Ø¶
  void _initializeBackgroundOperations() {
    if (!(prefsRepository.isFoundDataCashed ?? false)) {
      Future.delayed(
        const Duration(seconds: 3),
        () => prefsRepository.setIsFoundDataCashed(true),
      );
      Future.microtask(() {
        if (!mounted) return;

        boutiqueBloc.add(
          GetProductsWithFiltersEvent(
            boutiqueSlug: "search",
            cashedOrginalBoutique: true,
            fromSearch: true,
            offset: 1,
          ),
        );
        boutiqueBloc.add(
          ChangeAppliedFiltersEvent(
            boutiqueSlug: 'search',
            resetAppliedFilters: true,
          ),
        );
        boutiqueBloc.add(
          ChangeSelectedFiltersEvent(
            resetChoosedFilters: true,
            fromHomePageSearch: true,
            boutiqueSlug: 'search',
          ),
        );
      });
    }
    // ØªØ­Ù…ÙŠÙ„ Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø¨Ø­Ø« ÙÙŠ Ø§Ù„Ø®Ù„ÙÙŠØ©

    // Ø§Ù„Ø¹Ù…Ù„ÙŠØ§Øª Ø§Ù„Ø«Ù‚ÙŠÙ„Ø© ØªØªÙ… ÙÙŠ Ø§Ù„Ø®Ù„ÙÙŠØ©
    Future.delayed(const Duration(seconds: 2), () {
      _handleDeferredNotifications();
    });
  }

  /// Ù…Ø¹Ø§Ù„Ø¬Ø© Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø§Ù„Ù…Ø¤Ø¬Ù„Ø©
  Future<void> _handleDeferredNotifications() async {
    try {
      final String? rawData = await GetIt.I<PrefsRepository>()
          .getNotificationTypeFromTerminated();
      String notificationTypesOfMarketFromTerminated = rawData ?? "";
      if (notificationTypesOfMarketFromTerminated != "") {
        GetIt.I<PrefsRepository>().setNotificationTypesFromTerminated("");
        try {
          if (notificationTypesOfMarketFromTerminated.contains(
            "chatNotification",
          )) {
            Message myMessage = Message.fromJson(
              jsonDecode(
                notificationTypesOfMarketFromTerminated
                    .split("chatNotification")
                    .first,
              ),
            );

            String info = notificationTypesOfMarketFromTerminated
                .split("chatNotification")
                .last;
            String prevMessageId = info.split('#orderId#')[0];
            String orderInfo = info.split('#orderId#')[1];
            String orderId = orderInfo.split('#groupeOrderId#')[0];
            String orderGroupIdWithReturnRequestId = orderInfo.split(
              '#groupeOrderId#',
            )[1];
            String orderGroupId = orderGroupIdWithReturnRequestId.split(
              '#parentOrderId#',
            )[0];
            String parentOrderId = orderGroupIdWithReturnRequestId.split(
              '#parentOrderId#',
            )[1];
            handleOpenChatPageFromNotificationInBackground(
              prevMessageId,
              orderId,
              orderGroupId,
              parentOrderId,
              message: myMessage,
            );
          } else {
            Map data = jsonDecode(notificationTypesOfMarketFromTerminated);
            HandlingMarketNotifications.dealWithNotificationFromMarket(
              data,
              true,
            );
          }
        } catch (e) {
          debugPrint('âŒ Error handling deferred notifications: $e');
        }
      }
    } catch (e) {
      debugPrint('âŒ Error in deferred notifications: $e');
    }
  }

  /// عند طلب تأكيد الهاتف (زائر) عبر الإشعار المشترك،
  /// نعرض حوار التحقق الموحّد بدل اللوحة المضمّنة القديمة.

  @override
  void dispose() {
    // ØªÙ†Ø¸ÙŠÙ Ø¢Ù…Ù† Ù„Ù„Ø°Ø§ÙƒØ±Ø© Ø¹Ù†Ø¯ Ø¥ØºÙ„Ø§Ù‚ Ø§Ù„ØµÙØ­Ø©
    try {
      scrollController.removeListener(listenToScroll);
      scrollController.dispose();

      debounce?.cancel();

      // ðŸ”¥ ØªÙ†Ø¸ÙŠÙ Fast Scroll Protection Timers
      _fastScrollTimer?.cancel();
      _emergencyMemoryTimer?.cancel();

      // ØªÙ†Ø¸ÙŠÙ ValueNotifiers
      tapIndexToAddProductToCart.removeListener(_handleQuickViewRequest);
      tapIndexToAddProductToCart.dispose();
      productNotAvailableNotifier.dispose();
      currentActiveTab.dispose();
      loadingForRquestProductDetails.dispose();
      productIsFlashDeal.dispose();
      productIsRecommend.dispose();
      addToBagButtonShapeNotifier.dispose();

      debugPrint('ðŸ  Home page disposed with instant loading optimization');
    } catch (e) {
      debugPrint('âŒ Error in home page dispose: $e');
    }
    super.dispose();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: GlobalScreenConst.HOME_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.HOME_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    return Padding(
      padding: HWEdgeInsets.symmetric(horizontal: 0.w),
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.black,
        onRefresh: _refreshData,
        child: CustomScrollView(
          key: TestVariables.kTestMode
              ? const Key(WidgetsKeys.homepageScrollKey)
              : null,
          controller: scrollController,
          cacheExtent: 50,
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                [
                  100.verticalSpace,
                  storySection(currentLocale, context),
                  FeatureProductsWidget(
                    finishRedeem: finishRedeem,
                    tapIndexToAddProductToCart: tapIndexToAddProductToCart,
                  ),
                  10.verticalSpace,
                  FlashDealProductsWidget(
                    finishRedeem: finishRedeem,
                    productIsFlashDeal: productIsFlashDeal,
                    tapIndexToAddProductToCart: tapIndexToAddProductToCart,
                  ),
                ],
              ),
            ),

            BlocBuilder<AppBloc, AppState>(
              buildWhen: (previous, current) =>
                  previous.tabIndex != current.tabIndex,
              builder: (context, appState) {
                return BlocBuilder<CategoryBloc, CategoryState>(
                  buildWhen: (p, c) {
                    String? currentSlug = appState.tabIndex != -1
                        ? (c
                                  .mainCategoriesResponseModel
                                  ?.data
                                  ?.mainCategories?[appState.tabIndex]
                                  .slug ??
                              "Empty")
                        : "Empty";
                    bool rebuild =
                        (p
                                .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                ?.paginationStatus !=
                            c
                                .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                ?.paginationStatus ||
                        p.currentIndexForMainCategoryEvent !=
                            c.currentIndexForMainCategoryEvent);

                    return rebuild;
                  },
                  builder: (context, categoryState) {
                    String? currentSlug = appState.tabIndex != -1
                        ? (categoryState
                                  .mainCategoriesResponseModel
                                  ?.data
                                  ?.mainCategories?[appState.tabIndex]
                                  .slug ??
                              "Empty")
                        : "Empty";

                    if ((categoryState
                                    .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                    ?.paginationStatus ==
                                PaginationStatus.loading ||
                            categoryState
                                    .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                    ?.paginationStatus ==
                                PaginationStatus.initial) &&
                        (categoryState
                                    .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                    ?.items
                                    .length ??
                                0) ==
                            0) {
                      return sliverListSeparated(
                        addSemanticIndexes: false,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,

                        key: TestVariables.kTestMode
                            ? const Key(WidgetsKeys.boutiquesFailureStatusKey)
                            : null,
                        itemBuilder: (_, index) => Padding(
                          padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 1.sw,
                                    height: 235,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              // ignore: deprecated_member_use
                                              .withOpacity(0.4),
                                          offset: const Offset(0, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    width: 1.sw,
                                    height: 135,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              // ignore: deprecated_member_use
                                              .withOpacity(0.6),
                                          offset: const Offset(0, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    child: Row(
                                      children: List.generate(
                                        5,
                                        (index) =>
                                            const CircleAvatar(radius: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //HomePageCard(showWhite: index % 2 == 0),
                        separator: const SizedBox(height: 20),
                        childCount: 10,
                      );
                    }
                    return sliverListSeparated(
                      addRepaintBoundaries: false,
                      addAutomaticKeepAlives: false, // 🟢 ممتاز للأداء
                      key: TestVariables.kTestMode
                          ? const Key(WidgetsKeys.boutiquesSuccessStatusKey)
                          : null,
                      separator: const SizedBox(height: 20),
                      childCount:
                          ((categoryState
                                  .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                  ?.items
                                  .length ??
                              0) +
                          1),
                      itemBuilder: (context, index) {
                        // 1️⃣ استخراج القائمة بأمان ومنع أي Null Exception
                        final boutiquesList = categoryState
                            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                            ?.items;
                        final itemsCount = boutiquesList?.length ?? 0;

                        // 2️⃣ حساب شرط إدراج ويدجت "المنتجات المقترحة" (RecommendProductsWidget)
                        final isRecommendPosition =
                            (itemsCount < 3 && index == itemsCount) ||
                            index == 2;

                        if (isRecommendPosition) {
                          return RecommendProductsWidget(
                            finishRedeem: finishRedeem,
                            productIsRecommend: productIsRecommend,
                            tapIndexToAddProductToCart:
                                tapIndexToAddProductToCart,
                          );
                        }

                        // 3️⃣ حساب فهرس البوتيك الصحيح بدقة
                        final boutiqueIndex = index > 2 ? index - 1 : index;

                        // التأكد من أن الفهرس داخل حدود القائمة
                        if (boutiquesList == null ||
                            boutiqueIndex >= itemsCount) {
                          return const SizedBox.shrink();
                        }

                        final boutiqueItem = boutiquesList[boutiqueIndex];

                        // إذا لم تكن هناك بنرات، لا نعرض البوتيك
                        if (boutiqueItem.banners.isNullOrEmpty) {
                          return const SizedBox.shrink();
                        }

                        // 4️⃣ قراءة أو حساب الوصف النصي المخزن كاش
                        final cacheKey =
                            boutiqueItem.slug ??
                            '${currentSlug}_$boutiqueIndex';
                        final descriptionPlain =
                            _boutiqueDescriptionCache[cacheKey] ??=
                                _stripHtmlTagsForBoutique(
                                  boutiqueItem.description ?? '',
                                );

                        // 5️⃣ إرجاع البطاقة النهائية
                        return Padding(
                          padding: HWEdgeInsets.symmetric(),
                          child: HomePageBoutiqueCard(
                            key: TestVariables.kTestMode
                                ? Key(
                                    '${WidgetsKeys.boutiqueCardKey}$boutiqueIndex',
                                  )
                                : null,
                            category_Slug: currentSlug,
                            withSlidingImages: boutiqueItem.banners!.length > 1,
                            boutique: boutiqueItem,
                            index: boutiqueIndex,
                            descriptionPlain: descriptionPlain,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SliverToBoxAdapter(child: 20.verticalSpace),
            BlocBuilder<AppBloc, AppState>(
              buildWhen: (previous, current) =>
                  previous.tabIndex != current.tabIndex,
              builder: (context, appState) {
                return BlocBuilder<CategoryBloc, CategoryState>(
                  buildWhen: (p, c) {
                    String? currentSlug = appState.tabIndex != -1
                        ? (c
                                  .mainCategoriesResponseModel
                                  ?.data
                                  ?.mainCategories?[appState.tabIndex]
                                  .slug ??
                              "Empty")
                        : "Empty";
                    bool rebuild =
                        (p
                                .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                ?.paginationStatus !=
                            c
                                .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                ?.paginationStatus ||
                        p.currentIndexForMainCategoryEvent !=
                            c.currentIndexForMainCategoryEvent);
                    return rebuild;
                  },
                  builder: (context, state) {
                    String? currentSlug = appState.tabIndex != -1
                        ? (state
                                  .mainCategoriesResponseModel
                                  ?.data
                                  ?.mainCategories?[appState.tabIndex]
                                  .slug ??
                              "Empty")
                        : "Empty";
                    if (((state
                                    .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                    ?.items
                                    .length ??
                                0) >
                            9) &&
                        state
                                .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                ?.paginationStatus ==
                            PaginationStatus.loading) {
                      return SliverToBoxAdapter(
                        child: Center(child: TrydosLoader()),
                      );
                    }
                    return const SliverToBoxAdapter();
                  },
                );
              },
            ),
            SliverToBoxAdapter(child: 20.verticalSpace),
          ],
        ),
      ),
    );
  }

  Widget storySection(Locale currentLocale, BuildContext context) {
    return Stack(
      children: [
        //   Directionality(
        //  textDirection: TextDirection.ltr,
        const StoriesList(), // height 220
        Positioned(
          top: 10.h,
          right: LanguageService.languageCode == "ar" ? 10.w : null,
          left: LanguageService.languageCode == "ar" ? null : 10.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.storyFilmSvg,
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 10.w),
              MyTextWidget(
                LocaleKeys.story.tr(),
                style: context.textTheme.titleLarge?.rq.copyWith(
                  height: 0.86,
                  fontSize: 16.sp,
                  color: const Color(0xff3C3C3C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// âš¡ ØªØ­Ø¯ÙŠØ¯ cacheExtent Ø§Ù„Ø£Ù…Ø«Ù„ Ø­Ø³Ø¨ Ù…ÙˆØ§ØµÙØ§Øª Ø§Ù„Ø¬Ù‡Ø§Ø² - Ù…ÙØ­Ø³Ù† Ø®ØµÙŠØµØ§Ù‹ Ù„Ù„Ø¹ÙˆØ¯Ø© Ù…Ù† listing
}
