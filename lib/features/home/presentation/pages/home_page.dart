import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:html/parser.dart' show parse;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/common/helper/show_message.dart';
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
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/create_account_section.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/authentication/presentation/widgets/welcome_section.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart'
    as productDetail;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/features_products_widget.dart';
import 'package:trydos/features/home/presentation/widgets/flash_deal_products_widget.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_boutique_card.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet_new.dart';
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
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;

class HomePage extends StatefulWidget {
  final ValueNotifier<bool> isShowPanelForVerified;
  HomePage({Key? key, required this.isShowPanelForVerified}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 🛡️ حماية حالة الصفحة الرئيسية

  late AppBloc appBloc;
  late HomeBloc homeBloc;
  late BoutiqueBloc boutiqueBloc;
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  late CategoryBloc categoryBloc;
  ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();
  List<filter.Products> products = [];
  final ValueNotifier<String?> productNotAvailableNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> loadingForRquestProductDetails = ValueNotifier(
    false,
  );
    bool fromLogin = false;
  final ValueNotifier<bool> animate = ValueNotifier(false);
  Duration animationDuration = const Duration(milliseconds: 500);

  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final ValueNotifier<bool> productIsFlashDeal = ValueNotifier(false);
  final ValueNotifier<bool> productIsRecommend = ValueNotifier(false);
  final ScrollController scrollController = ScrollController();
  int currentSelectedColor = -1;
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  Map<String, Key> reRenderingListViewKey = {};
  Map<String, int> lastIndexRequestedInEachMainCategoryForPrefetchBoutiques =
      {};
  final PanelController panelController = PanelController();
  String selectedCategorySlug = "Empty";
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  late ChatBloc chatBloc;
  late AuthBloc authBloc;
  bool changeAppearSizeForProduct = true;
  final ValueNotifier<bool> finishRedeem = ValueNotifier(false);
  Timer? debounce;
  // Variables to prevent excessive API calls

  Timer? _fastScrollTimer;
  Timer? _emergencyMemoryTimer;

  /// لتفادي إرسال أحداث Bloc في كل rebuild — نرسل فقط عند تغيّر tapIndex
  int _lastDispatchedTapIndex = -2;

  /// كاش وصف البوتيك بدون HTML (مرة واحدة لكل بوتيك — الكارد يبقى StatelessWidget)
  final Map<String, String> _boutiqueDescriptionCache = {};

  static String _stripHtmlTagsForBoutique(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement?.text ?? '';
    return parsedString.trim();
  }

  /// فلترة عروض الفلاش حسب تاريخ الانتهاء (خارج الـ builder لتحسين الأداء)
  static List<filter.Products> _filterFlashDealProductsByEndDate(
    List<filter.Products> raw,
  ) {
    final now = DateTime.now();
    final List<filter.Products> result = [];
    for (final element in raw) {
      DateTime endDate;
      try {
        endDate = tran.DateFormat(
          'MM/dd/yyyy',
          'en_US',
        ).parse(element.flashDealEndDate ?? '');
        endDate = endDate.add(const Duration(days: 1));
      } catch (e) {
        endDate = now;
      }
      final duration = endDate.difference(now);
      if (!duration.isNegative && duration.inSeconds >= 1) {
        result.add(element);
      }
    }
    return result;
  }

  /// ⚡ نظام تحسين التمرير السريع الذكي للصفحة الرئيسية
  void listenToScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 600), () {
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
      /*  if (lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
              selectedCategorySlug] ==
          null) {
        lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
            selectedCategorySlug] = -1;
      }
      if (lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
              selectedCategorySlug] !=
          lastIndexSeenByUser) {
        // prefetchBoutiques(selectedCategorySlug);
        lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
            selectedCategorySlug] = lastIndexSeenByUser;
      }*/
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.6)) {
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
            context: context,
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
          context,
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

    if (!(prefsRepository.isRequestNotificationPermission ?? false)) {
      PermissionServices().requestNotificationPermission();
      prefsRepository.setRequestNotificationPermission(true);
    }

    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    chatBloc = BlocProvider.of<ChatBloc>(context);

    appBloc.add(ChangeIndexForSearch(0));
    prefsRepository.setLanguage(
      (LanguageService.isKurdish ? "ku" : LanguageService.languageCode),
    );
    // scrollController.addListener(listenToScroll);

    // معالج الأخطاء مرة واحدة فقط (تحسين أداء - لا داخل build)
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    // 🚀 تحميل البيانات الأساسية فوراً في الخلفية
    _initializeBackgroundOperations();
  }

  /// جلب البيانات عند السحب للتحديث (خارج build لتحسين الأداء)
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
      categoryBloc.add(
        GetMainCategoriesEvent(getWithPrefech: false, context: context),
      );
    }
  }

  /// 🚀 تحميل العمليات في الخلفية دون تأثير على العرض
  void _initializeBackgroundOperations() {
    if (!(prefsRepository.isFoundDataCashed ?? false)) {
      Future.delayed(
        const Duration(seconds: 10),
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
        /*  if ((prefsRepository.chatToken?.length ?? 0) > 10 &&
            (prefsRepository.myChatName != prefsRepository.myMarketName &&
                !(prefsRepository.myMarketName.isNullOrEmpty))) {
          authBloc.add(
            UpdateChatUserNameEvent(name: prefsRepository.myMarketName ?? ""),
          );
        }*/
        /*if ((prefsRepository.storiesToken?.length ?? 0) > 10 &&
            (prefsRepository.myStoriesName != prefsRepository.myMarketName &&
                !(prefsRepository.myMarketName.isNullOrEmpty))) {
          authBloc.add(
            UpdateStoriesUserEvent(name: prefsRepository.myMarketName ?? ""),
          );
        }*/
      });
    }
    // تحميل بيانات البحث في الخلفية

    // العمليات الثقيلة تتم في الخلفية
    Future.delayed(const Duration(seconds: 2), () {
      _handleDeferredNotifications();
    });
  }

  /// معالجة الإشعارات المؤجلة
  Future<void> _handleDeferredNotifications() async {
    try {
      final String? rawData = await GetIt.I<PrefsRepository>()
          .getNotificationTypeFromTerminated();
      String notificationTypesOfMarketFromTerminated = rawData ?? "";
      if (kDebugMode) print(
        "chatNotification//////////////////////////0***${notificationTypesOfMarketFromTerminated}00000",
      );
      if (notificationTypesOfMarketFromTerminated != "") {
        if (kDebugMode) print("chatNotification//////////////////////////000000");
        GetIt.I<PrefsRepository>().setNotificationTypesFromTerminated("");
        try {
          if (notificationTypesOfMarketFromTerminated.contains(
            "chatNotification",
          )) {
            if (kDebugMode) print("chatNotification//////////////////////////11111");
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
            if (kDebugMode) print("chatNotification//////////////////////////22222");
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
          debugPrint('❌ Error handling deferred notifications: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in deferred notifications: $e');
    }
  }

  @override
  void dispose() {
    // تنظيف آمن للذاكرة عند إغلاق الصفحة
    try {
      scrollController.removeListener(listenToScroll);
      scrollController.dispose();
      debounce?.cancel();

      // 🔥 تنظيف Fast Scroll Protection Timers
      _fastScrollTimer?.cancel();
      _emergencyMemoryTimer?.cancel();

      // تنظيف ValueNotifiers
      tapIndexToAddProductToCart.dispose();
      productNotAvailableNotifier.dispose();
      currentActiveTab.dispose();
      loadingForRquestProductDetails.dispose();
      productIsFlashDeal.dispose();
      productIsRecommend.dispose();
      addToBagButtonShapeNotifier.dispose();

      debugPrint('🏠 Home page disposed with instant loading optimization');
    } catch (e) {
      debugPrint('❌ Error in home page dispose: $e');
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
        child: Stack(
          children: [
            // BlocBuilder<AppBloc, AppState>(
            //   builder: (context, appState) {
            //     return BlocBuilder<CategoryBloc, CategoryState>(
            //       buildWhen: (p, c) {
            //         String? currentSlug = appState.tabIndex != -1
            //             ? (c.mainCategoriesResponseModel?.data
            //                     ?.mainCategories?[appState.tabIndex].slug ??
            //                 "Empty")
            //             : "Empty";
            //         bool rebuild = (p
            //                     .getHomeBoutiquesPaginationObjectByMainCategory[
            //                         currentSlug]
            //                     ?.paginationStatus !=
            //                 c
            //                     .getHomeBoutiquesPaginationObjectByMainCategory[
            //                         currentSlug]
            //                     ?.paginationStatus ||
            //             p.currentIndexForMainCategoryEvent !=
            //                 c.currentIndexForMainCategoryEvent);

            //         return rebuild;
            //       },
            //       builder: (context, categoryState) {
            //         String? currentSlug = appState.tabIndex != -1
            //             ? (categoryState.mainCategoriesResponseModel?.data
            //                     ?.mainCategories?[appState.tabIndex].slug ??
            //                 "Empty")
            //             : "Empty";
            //         debugPrint(
            //             "..............${categoryState.getHomeBoutiquesPaginationObjectByMainCategory.keys.toList()}.................${(categoryState.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]?.items.length ?? 0)}");

            //         if ((categoryState
            //                         .getHomeBoutiquesPaginationObjectByMainCategory[
            //                             currentSlug]
            //                         ?.paginationStatus ==
            //                     PaginationStatus.loading ||
            //                 categoryState
            //                         .getHomeBoutiquesPaginationObjectByMainCategory[
            //                             currentSlug]
            //                         ?.paginationStatus ==
            //                     PaginationStatus.initial) &&
            //             (categoryState
            //                         .getHomeBoutiquesPaginationObjectByMainCategory[
            //                             currentSlug]
            //                         ?.items
            //                         .length ??
            //                     0) ==
            //                 0) {
            //           debugPrint(
            //               "1111111111999999999999999999..${(categoryState.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]?.items.length ?? 0)}");

            //           return ListView.separated(
            //             key: TestVariables.kTestMode
            //                 ? Key(WidgetsKeys.boutiquesFailureStatusKey)
            //                 : null,
            //             itemCount: 10,
            //             itemBuilder: (context, index) {
            //               return Padding(
            //                 padding: HWEdgeInsets.symmetric(horizontal: 15.w),
            //                 child: ClipRRect(
            //                   borderRadius: BorderRadius.circular(20.0),
            //                   child: Shimmer.fromColors(
            //                     baseColor: Colors.grey.shade300,
            //                     highlightColor: Colors.grey.shade100,
            //                     enabled: true,
            //                     child: Stack(
            //                       alignment: Alignment.center,
            //                       children: [
            //                         Container(
            //                             width: 1.sw,
            //                             height: 235,
            //                             decoration: BoxDecoration(
            //                               borderRadius:
            //                                   BorderRadius.circular(20.0),
            //                               boxShadow: [
            //                                 BoxShadow(
            //                                   color: const Color(0xff000000)
            //                                       .withOpacity(0.4),
            //                                   offset: Offset(0, 3),
            //                                   blurRadius: 6,
            //                                 )
            //                               ],
            //                             )),
            //                         Container(
            //                             margin: EdgeInsets.symmetric(
            //                                 horizontal: 20),
            //                             width: 1.sw,
            //                             height: 135,
            //                             decoration: BoxDecoration(
            //                               borderRadius:
            //                                   BorderRadius.circular(20.0),
            //                               boxShadow: [
            //                                 BoxShadow(
            //                                   color: const Color(0xff000000)
            //                                       .withOpacity(0.6),
            //                                   offset: Offset(0, 3),
            //                                   blurRadius: 6,
            //                                 )
            //                               ],
            //                             )),
            //                         Positioned(
            //                           bottom: 30,
            //                           child: Row(
            //                             children: List.generate(
            //                                 5,
            //                                 (index) => CircleAvatar(
            //                                       radius: 20,
            //                                     )),
            //                           ),
            //                         )
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               );
            //             },
            //             separatorBuilder: (context, index) {
            //               return SizedBox(
            //                 height: 20,
            //               );
            //             },
            //           );
            //         }
            //         return ListView.separated(
            //           itemCount: categoryState
            //                           .getHomeBoutiquesPaginationObjectByMainCategory[
            //                       currentSlug] ==
            //                   null
            //               ? 0
            //               : categoryState
            //                       .getHomeBoutiquesPaginationObjectByMainCategory[
            //                           currentSlug]!
            //                       .items
            //                       .length +
            //                   1,
            //           physics: const ClampingScrollPhysics(
            //               parent: AlwaysScrollableScrollPhysics()),
            //           key: TestVariables.kTestMode
            //               ? Key(WidgetsKeys.boutiquesSuccessStatusKey)
            //               : reRenderingListViewKey[currentSlug],
            //           controller: scrollController,
            //           itemBuilder: (context, index) {
            //             return index == 0
            //                 ? Column(
            //                     children: [
            //                       _isLoading
            //                           ? Center(
            //                               child: CircularProgressIndicator(),
            //                             ) // إظهار مؤشر التحميل
            //                           : SizedBox.shrink(),
            //                       /////////////////////////////////
            //                       SizedBox(
            //                         height: 90,
            //                       ),
            //                       /////////////////////////////////
            //                       storySection(currentLocale, context),
            //                     ],
            //                   )
            //                 : Padding(
            //                     padding:
            //                         HWEdgeInsets.symmetric(horizontal: 15.w),
            //                     child: categoryState
            //                             .getHomeBoutiquesPaginationObjectByMainCategory[
            //                                 currentSlug]!
            //                             .items[index - 1]
            //                             .banners
            //                             .isNullOrEmpty
            //                         ? SizedBox.shrink()
            //                         : HomePageCard2(
            //                             isShowPanelForVerified:
            //                                 widget.isShowPanelForVerified,
            //                             key: TestVariables.kTestMode
            //                                 ? Key(
            //                                     '${WidgetsKeys.boutiqueCardKey}${index - 1}')
            //                                 : null,
            //                             category_Slug: currentSlug,
            //                             withSlidingImages: categoryState
            //                                     .getHomeBoutiquesPaginationObjectByMainCategory[
            //                                         currentSlug]!
            //                                     .items[index - 1]
            //                                     .banners!
            //                                     .length >
            //                                 1,
            //                             boutique: categoryState
            //                                 .getHomeBoutiquesPaginationObjectByMainCategory[
            //                                     currentSlug]!
            //                                 .items[index - 1],
            //                           )

            //                     //HomePageCard(showWhite: index % 2 == 0),
            //                     );
            //           },
            //           separatorBuilder: (context, index) {
            //             return SizedBox(
            //               height: 20,
            //             );
            //           },
            //         );
            //       },
            //     );
            //   },
            // ),

            ///////////////////////////
            CustomScrollView(
              key: TestVariables.kTestMode
                  ? const Key(WidgetsKeys.homepageScrollKey)
                  : null,
              controller: scrollController,
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ), // تحسين الفيزيائيات للسلاسة
              //  scrollBehavior:
              //     const ScrollBehavior().copyWith(overscroll: false),
              slivers: [
                // 🚨 عرض مؤشر التحميل فقط في البداية

                // 🏗️ بعد التعديل: اجمعهم في SliverList واحدة
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    100.verticalSpace, // المسافة في الأعلى
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
                  ]),
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

                            key: TestVariables.kTestMode
                                ? const Key(
                                    WidgetsKeys.boutiquesFailureStatusKey,
                                  )
                                : null,
                            itemBuilder: (_, index) => Padding(
                              padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
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
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
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
                          key: TestVariables.kTestMode
                              ? const Key(WidgetsKeys.boutiquesSuccessStatusKey)
                              : reRenderingListViewKey[currentSlug],
                          itemBuilder: (_, index) =>
                              ((((categoryState
                                                  .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                                  ?.items
                                                  .length ??
                                              0)) <
                                          3 &&
                                      index ==
                                          (categoryState
                                                  .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                                  ?.items
                                                  .length ??
                                              0)) ||
                                  index == 2)
                              ? RecommendProductsWidget(
                                  finishRedeem: finishRedeem,
                                  productIsRecommend: productIsRecommend,
                                  tapIndexToAddProductToCart:
                                      tapIndexToAddProductToCart,
                                )
                              : Padding(
                                  padding: HWEdgeInsets.symmetric(),
                                  child: () {
                                    final boutiqueItem = categoryState
                                        .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
                                        .items[index > 2 ? index - 1 : index];
                                    if (boutiqueItem.banners.isNullOrEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    final cacheKey =
                                        boutiqueItem.slug ??
                                        '${currentSlug}_$index';
                                    final descriptionPlain =
                                        _boutiqueDescriptionCache[cacheKey] ??=
                                            _stripHtmlTagsForBoutique(
                                              boutiqueItem.description ?? '',
                                            );
                                    return HomePageBoutiqueCard(
                                      isShowPanelForVerified:
                                          widget.isShowPanelForVerified,
                                      key: TestVariables.kTestMode
                                          ? Key(
                                              '${WidgetsKeys.boutiqueCardKey}${index > 2 ? index - 1 : index}',
                                            )
                                          : null,
                                      category_Slug: currentSlug,
                                      withSlidingImages:
                                          boutiqueItem.banners!.length > 1,
                                      boutique: boutiqueItem,
                                      index: index > 2 ? index - 1 : index,
                                      descriptionPlain: descriptionPlain,
                                    );
                                  }(),

                                  //HomePageCard(showWhite: index % 2 == 0),
                                ),
                          separator: const SizedBox(height: 20),
                          childCount:
                              ((categoryState
                                      .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
                                      ?.items
                                      .length ??
                                  0) +
                              1),
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
            ValueListenableBuilder<bool>(
              valueListenable: showShadowForPanel,
              builder: (context, _showShadowForPanel, _) {
                return _showShadowForPanel
                    ? GestureDetector(
                        onTap: () {
                          showShadowForPanel.value = false;
                          currentActiveTab.value = -1;
                          panelControllerForCart.close();
                        },
                        child: Container(
                          height: 1.sh,
                          width: 1.sw,
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.55),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            //////////////////////////////
            Positioned(
              bottom: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.isShowPanelForVerified,
                builder: (context, _isShowPanelForVerified, _) {
                  if (_isShowPanelForVerified) {
                    if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ??
                        false)) {
                      authBloc.add(
                        SendOtpEvent(
                          phone: prefsRepository.myPhoneNumber!,
                          isViaWhatsApp: 1,
                        ),
                      );
                    }

                    ;
                    Future.delayed(
                      const Duration(milliseconds: 500),
                      () => panelController.open(),
                    );
                  }
                  return !_isShowPanelForVerified
                      ? const SizedBox.shrink()
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 1.sh,
                          height: 1.sh / 2.7,
                          child: SlidingUpPanel(
                            minHeight: 0,
                            maxHeight: 1.sh / 2.7,
                            controller: panelController,
                            onPanelClosed: () {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () =>
                                    widget.isShowPanelForVerified.value = false,
                              );
                            },
                            panelBuilder: (sc) {
                              return AnimatedPadding(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: const EdgeInsets.only(top: 20),
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      PageView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        controller: pageController,
                                        children:
                                            (prefsRepository
                                                    .isVerifiedPhonePeforeExpiredToken ??
                                                false)
                                            ? [
                                                VerifyOtp(
                                                  fromProfile: false,
                                                  navigateToProfile: () {},
                                                  fromExpired: true,
                                                  isVisWhatsApp: 1,
                                                  navigateToAddName: () {},
                                                  navigateTocartOrProfile: () {
                                                    Future.delayed(
                                                      const Duration(
                                                        seconds: 3,
                                                      ),
                                                      () => panelController
                                                          .close(),
                                                    );
                                                  },
                                                  fromLogin: false,
                                                  onLoginFailed: () {
                                                    //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                  },
                                                  goBack: () {
                                                    // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                  },
                                                  methodIcon:
                                                      AppAssets.whatsappSvg,
                                                  phoneNumber: prefsRepository
                                                      .myPhoneNumber!,
                                                ),
                                              ]
                                            : [
                                                WelcomeSection(
                                                                              goToLoginSection: () {
                                                                                fromLogin = true;
                                                                                animationDuration = const Duration(
                                                                                  seconds: 1,
                                                                                );
                                                                                animate.value = true;
                                                                                pageContent.value = 2;
                                                                                pageController.animateToPage(
                                                                                  2,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 100,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                              },
                                                                              goToCreateAccount: () {
                                                                                fromLogin = false;
                                                                                animate.value = true;
                                                                                pageContent.value = 1;
                                                                                pageController.animateToPage(
                                                                                  1,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                                //_animationController.forward();
                                                                              },
                                                                            ),
                                                                            CreateAccountSection(
                                                                              moveToNextStep: () {
                                                                                pageContent.value = 2;
                                                                                pageController.animateToPage(
                                                                                  2,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                              },
                                                                            ),
                                                InsertPhoneTab(
                                                  focusNode: focusNode,
                                                  moveToNextStep:
                                                      (String phoneNumber) {
                                                        this.phoneNumber =
                                                            phoneNumber
                                                                .replaceAll(
                                                                  ' ',
                                                                  '',
                                                                );
                                                        pageController
                                                            .animateToPage(
                                                              1,
                                                              duration:
                                                                  const Duration(
                                                                    milliseconds:
                                                                        500,
                                                                  ),
                                                              curve: Curves
                                                                  .easeInOut,
                                                            );
                                                        setState(() {});
                                                      },
                                                ),
                                                VerificationMethods(
                                                  phoneNumber: phoneNumber,
                                                  isFromLogin: true,
                                                  onChooseWhatsapp: () {
                                                    isVisWhatsApp = 1;
                                                    pageController
                                                        .animateToPage(
                                                          2,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    100,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );

                                                    if (prefsRepository
                                                            .isTimerForOtpRunning ??
                                                        false) {
                                                      showWarningMessage(
                                                        context,
                                                        '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                                                      );
                                                      return;
                                                    }
                                                    /* authBloc.add(SendOtpEvent(
                                                        phone: phoneNumber,
                                                        isViaWhatsApp: 1));*/
                                                  },
                                                  goBackToPhone: () {
                                                    pageController
                                                        .animateToPage(
                                                          0,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                  },
                                                  onChooseSms: () {
                                                    isVisWhatsApp = 0;
                                                    pageController
                                                        .animateToPage(
                                                          3,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                    /*  authBloc.add(SendOtpEvent(
                                                        phone: phoneNumber,
                                                        isViaWhatsApp: 0));*/
                                                  },
                                                ),
                                                VerifyOtp(
                                                  fromProfile: false,
                                                  navigateToProfile: () {},
                                                  fromExpired: true,
                                                  isVisWhatsApp: isVisWhatsApp,
                                                  navigateToAddName: () {},
                                                  navigateTocartOrProfile: () {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          Future.delayed(
                                                            const Duration(
                                                              seconds: 3,
                                                            ),
                                                            () =>
                                                                panelController
                                                                    .close(),
                                                          );
                                                        });
                                                  },
                                                  fromLogin: false,
                                                  onLoginFailed: () {
                                                    pageController
                                                        .animateToPage(
                                                          3,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                  },
                                                  goBack: () {
                                                    pageController
                                                        .animateToPage(
                                                          1,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                  },
                                                  methodIcon: isVisWhatsApp == 1
                                                      ? AppAssets.whatsappSvg
                                                      : AppAssets.smsSvg,
                                                  phoneNumber: phoneNumber,
                                                ),
                                              ],
                                      ),
                                      Positioned(
                                        top: 0,
                                        left:
                                            LanguageService.languageCode != "ar"
                                            ? null
                                            : 0,
                                        right:
                                            LanguageService.languageCode != "ar"
                                            ? 0
                                            : null,
                                        child: Container(
                                          margin: const EdgeInsets.all(10),
                                          height: 20,
                                          width: 40,
                                          child: InkWell(
                                            onTap: () =>
                                                panelController.close(),
                                            child: SvgPicture.asset(
                                              AppAssets.closeSvg,
                                              height: 15,
                                              width: 30,
                                              // ignore: deprecated_member_use
                                              color: const Color(0xffFF5F61),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: productIsRecommend,
              builder: (context, _productIsRecommend, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: productIsFlashDeal,
                  builder: (context, _productIsFlashDeal, _) {
                    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
                      buildWhen: (previous, current) {
                        return previous
                                    .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                                    ?.paginationStatus !=
                                current
                                    .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                                    ?.paginationStatus ||
                            previous
                                    .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                                    ?.paginationStatus !=
                                current
                                    .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                                    ?.paginationStatus ||
                            previous
                                    .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                                    ?.paginationStatus !=
                                current
                                    .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                                    ?.paginationStatus;
                      },
                      builder: (context, state) {
                        if (_productIsFlashDeal) {
                          final raw =
                              state
                                  .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                                  ?.items ??
                              [];
                          products = _filterFlashDealProductsByEndDate(raw);
                        } else if (_productIsRecommend) {
                          products =
                              state.getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"] ==
                                  null
                              ? []
                              : state
                                    .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]!
                                    .items;
                        } else {
                          products =
                              state.getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] ==
                                  null
                              ? []
                              : state
                                    .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]!
                                    .items;
                        }

                        return ValueListenableBuilder<int>(
                          valueListenable: tapIndexToAddProductToCart,
                          builder: (context, tapIndex, _) {
                            // إرسال الأحداث مرة واحدة عند تغيّر tapIndex فقط (تحسين أداء)
                            if (tapIndex != -1) {
                              if (tapIndex != _lastDispatchedTapIndex &&
                                  products.isNotEmpty &&
                                  tapIndex < products.length) {
                                _lastDispatchedTapIndex = tapIndex;
                                appBloc.add(HideBottomNavigationBar(true));
                                homeBloc.add(
                                  const IsChangedVariationWhenQtyZeroEvent(
                                    isChangedVariationWhenQtyZero: false,
                                  ),
                                );
                                changeAppearSizeForProduct = true;
                                homeBloc.add(
                                  GetProductDatailsWithoutRelatedProductsEvent(
                                    fromListingPage: true,
                                    productSlug: products[tapIndex].slug,
                                    productId: products[tapIndex].productId
                                        .toString(),
                                  ),
                                );
                                loadingForRquestProductDetails.value = true;
                                Future.delayed(
                                  const Duration(milliseconds: 600),
                                  () => loadingForRquestProductDetails.value =
                                      false,
                                );
                              }
                            } else {
                              if (_lastDispatchedTapIndex != -1) {
                                _lastDispatchedTapIndex = -1;
                                appBloc.add(HideBottomNavigationBar(false));
                                currentActiveTab.value = 0;
                              }
                              return const SizedBox.shrink();
                            }
                            return ValueListenableBuilder<bool>(
                              valueListenable: loadingForRquestProductDetails,
                              builder: (context, _loadingForRquestProductDetails, _) {
                                return Positioned(
                                  bottom: -10.h,
                                  child: _loadingForRquestProductDetails
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: TrydosLoader(size: 15),
                                        )
                                      : SizedBox(
                                          height: tapIndex == -1 ? 0 : 1.sh,
                                          width: 1.sw,
                                          child: BlocBuilder<HomeBloc, HomeState>(
                                            buildWhen: (previous, current) =>
                                                previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                                    current
                                                        .getProductDetailWithoutSimilarRelatedProductsStatus ||
                                                previous.getCartOverviewStatus !=
                                                    current
                                                        .getCartOverviewStatus ||
                                                previous.authProductDetailsStatus !=
                                                    current
                                                        .authProductDetailsStatus ||
                                                previous.currentSelectedColorForEveryProduct !=
                                                    current
                                                        .currentSelectedColorForEveryProduct ||
                                                previous.enableAddToCardAfterChangeVariantZero !=
                                                    current
                                                        .enableAddToCardAfterChangeVariantZero ||
                                                previous.isChangedvariationWhenQtyZero !=
                                                    current
                                                        .isChangedvariationWhenQtyZero ||
                                                previous.cartCollection !=
                                                    current.cartCollection,
                                            builder: (context, state) {
                                              List<filter.ProductColor>?
                                              productColors = [];
                                              if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                      GetProductDetailWithoutSimilarRelatedProductsStatus
                                                          .success &&
                                                  state.authProductDetailsStatus ==
                                                      AuthProductDetailsStatus
                                                          .success) {
                                                productColors = state
                                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                        .productId
                                                        .toString()]!
                                                    .product!
                                                    .colors;
                                              }

                                              String productId =
                                                  products[tapIndex].productId
                                                      .toString();
                                              String productSlug =
                                                  products[tapIndex].slug
                                                      .toString();
                                              currentSelectedColor =
                                                  state
                                                      .currentSelectedColorForEveryProduct[productSlug] ??
                                                  (products[tapIndex]
                                                              .syncColorImages
                                                              ?.length ??
                                                          0) ~/
                                                      2;
                                              String
                                              currentSelectedColorOption =
                                                  ((productColors?.length ??
                                                          0) >
                                                      0)
                                                  ? productColors![currentSelectedColor]
                                                            .option ??
                                                        ""
                                                  : "";

                                              String currentVariantType =
                                                  "${currentSelectedColorOption != "" ? currentSelectedColorOption : ""}" +
                                                  "${(state.currentColorSizeForCart?["choiceOption"] != null && !(state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.sizes?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["choiceOption"] != "") && (currentSelectedColorOption != "") ? "-" : ""}" +
                                                  "${(state.currentColorSizeForCart?["choiceOption"] != null && !(state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.sizes?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["choiceOption"] != "") ? "${state.currentColorSizeForCart?["choiceOption"]}" : ""}";

                                              productDetail.Variation?
                                              currentVariation = state
                                                  .authProductDetailsModel
                                                  ?.data
                                                  ?.variation
                                                  ?.firstWhere(
                                                    (element) =>
                                                        element.type!.contains(
                                                          currentVariantType,
                                                        ),
                                                    orElse: () {
                                                      return productDetail.Variation();
                                                    },
                                                  );
                                              String currentVariationId =
                                                  currentVariation?.id ?? "";
                                              /*  List<String> syncColorNames =
                                                      [];
                                                  List<filter.SyncColorImage>
                                                      syncColorImagesFromListing =
                                                      products[tapIndex]
                                                              .syncColorImages ??
                                                          [];
                                                  List<filter.Color>?
                                                      colorsFromListing =
                                                      products[tapIndex]
                                                              .colors ??
                                                          [];*/

                                              currentSelectedColor =
                                                  state
                                                      .currentSelectedColorForEveryProduct[productSlug] ??
                                                  (products[tapIndex]
                                                              .syncColorImages
                                                              ?.length ??
                                                          0) ~/
                                                      2;

                                              if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                          GetProductDetailWithoutSimilarRelatedProductsStatus
                                                              .failure ||
                                                      state.authProductDetailsStatus ==
                                                          AuthProductDetailsStatus
                                                              .failure) &&
                                                  (prefsRepository
                                                          .isTokenExpired ??
                                                      false ||
                                                          prefsRepository
                                                                  .marketToken ==
                                                              "" ||
                                                          prefsRepository
                                                                  .marketToken ==
                                                              null)) {
                                                Future.delayed(
                                                  const Duration(seconds: 5),
                                                  () {
                                                    homeBloc.add(
                                                      GetProductDatailsWithoutRelatedProductsEvent(
                                                        fromListingPage: true,
                                                        productSlug:
                                                            products[tapIndex]
                                                                .slug,
                                                        productId:
                                                            products[tapIndex]
                                                                .productId
                                                                .toString(),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                                () {
                                                  if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                          GetProductDetailWithoutSimilarRelatedProductsStatus
                                                              .success &&
                                                      state.authProductDetailsStatus ==
                                                          AuthProductDetailsStatus
                                                              .success &&
                                                      tapIndex != -1)) {
                                                    if (state
                                                            .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                            ?.product
                                                            ?.countryIsRestricted ==
                                                        true) {
                                                      productNotAvailableNotifier
                                                          .value = LocaleKeys
                                                          .product_is_not_available_in_your_country
                                                          .tr();
                                                    } else if (state
                                                            .authProductDetailsModel
                                                            ?.data
                                                            ?.availableQuantity ==
                                                        0) {
                                                      productNotAvailableNotifier
                                                          .value = LocaleKeys
                                                          .this_product_is_not_available_in_store
                                                          .tr();
                                                    } else {
                                                      productNotAvailableNotifier
                                                              .value =
                                                          null;
                                                    }
                                                  }
                                                },
                                              );
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                                () {
                                                  if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                          GetProductDetailWithoutSimilarRelatedProductsStatus
                                                              .failure ||
                                                      state.authProductDetailsStatus ==
                                                          AuthProductDetailsStatus
                                                              .failure) {
                                                    tapIndexToAddProductToCart
                                                            .value =
                                                        -1;
                                                  }
                                                },
                                              );
                                              homeBloc.add(
                                                AddSizesForColorsEvent(
                                                  currentColorName:
                                                      !(productColors
                                                          .isNullOrEmpty)
                                                      ? productColors![currentSelectedColor]
                                                                .option ??
                                                            ""
                                                      : "",
                                                  variation:
                                                      state
                                                              .authProductDetailsModel
                                                              ?.data !=
                                                          null
                                                      ? state
                                                            .authProductDetailsModel
                                                            ?.data!
                                                            .variation
                                                      : null,
                                                ),
                                              );
                                              if (productId != "" &&
                                                  tapIndex != -1 &&
                                                  state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                      GetProductDetailWithoutSimilarRelatedProductsStatus
                                                          .success &&
                                                  state.authProductDetailsStatus ==
                                                      AuthProductDetailsStatus
                                                          .success &&
                                                  changeAppearSizeForProduct) {
                                                if (!state
                                                        .cachedProductWithoutRelatedProductsModel
                                                        .containsKey(
                                                          productId,
                                                        ) ||
                                                    (state.cachedProductWithoutRelatedProductsModel[productId] !=
                                                            null
                                                        ? state
                                                                      .cachedProductWithoutRelatedProductsModel[productId]!
                                                                      .product !=
                                                                  null
                                                              ? state
                                                                    .cachedProductWithoutRelatedProductsModel[productId]!
                                                                    .product!
                                                                    .sizes
                                                                    .isNullOrEmpty
                                                              : true
                                                        : true)) {
                                                  homeBloc.add(
                                                    AddCurrentColorSizeEvent(),
                                                  );
                                                } else if (!(state
                                                            .cachedProductWithoutRelatedProductsModel[productId] !=
                                                        null
                                                    ? state
                                                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                                                  .product !=
                                                              null
                                                          ? state
                                                                .cachedProductWithoutRelatedProductsModel[productId]!
                                                                .product!
                                                                .sizes
                                                                .isNullOrEmpty
                                                          : true
                                                    : true)) {
                                                  String sizeSelect =
                                                      (state
                                                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                                                  .product!
                                                                  .sizes
                                                                  ?.length ??
                                                              0) ==
                                                          0
                                                      ? ""
                                                      : state
                                                            .cachedProductWithoutRelatedProductsModel[productId]!
                                                            .product!
                                                            .sizes![(state
                                                                    .cachedProductWithoutRelatedProductsModel[productId]!
                                                                    .product
                                                                    ?.sizes
                                                                    ?.length ??
                                                                0) ~/
                                                            2];
                                                  String sizeOptionSelect =
                                                      (state
                                                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                                                  .product!
                                                                  .sizes
                                                                  ?.length ??
                                                              0) ==
                                                          0
                                                      ? ""
                                                      : state
                                                            .cachedProductWithoutRelatedProductsModel[productId]!
                                                            .product!
                                                            .sizes![(state
                                                                    .cachedProductWithoutRelatedProductsModel[productId]!
                                                                    .product
                                                                    ?.sizes
                                                                    ?.length ??
                                                                0) ~/
                                                            2];

                                                  homeBloc.add(
                                                    AddCurrentColorSizeEvent(
                                                      choice_1: sizeSelect,
                                                      choiceOption:
                                                          sizeOptionSelect,
                                                    ),
                                                  );
                                                }
                                                homeBloc.add(
                                                  const IsChangedVariationWhenQtyZeroEvent(
                                                    isChangedVariationWhenQtyZero:
                                                        true,
                                                  ),
                                                );

                                                currentActiveTab.value = 3;
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 600,
                                                  ),
                                                  () {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          panelControllerForCart
                                                              .open();
                                                          changeAppearSizeForProduct =
                                                              false;
                                                        });
                                                  },
                                                );
                                              }

                                              return state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                          GetProductDetailWithoutSimilarRelatedProductsStatus
                                                              .loading ||
                                                      state.authProductDetailsStatus ==
                                                          AuthProductDetailsStatus
                                                              .loading ||
                                                      state.enableAddToCardAfterChangeVariantZero !=
                                                          EnableAddToCardAfterChangeVariantZero
                                                              .success ||
                                                      state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                              .productId
                                                              .toString()] ==
                                                          null
                                                  ? Container(
                                                      width: 1.sw,
                                                      height: 1.sh,
                                                      color:
                                                          const Color.fromRGBO(
                                                            0,
                                                            0,
                                                            0,
                                                            0.3,
                                                          ),
                                                      child: TrydosLoader(
                                                        size: 25,
                                                      ),
                                                    )
                                                  : ValueListenableBuilder<
                                                      bool
                                                    >(
                                                      valueListenable:
                                                          finishRedeem,
                                                      builder: (context, _finishRedeem, _) {
                                                        return ValueListenableBuilder<
                                                          bool
                                                        >(
                                                          valueListenable:
                                                              visibleFlashDeal,
                                                          builder:
                                                              (
                                                                context,
                                                                _visibleFlashDeal,
                                                                _,
                                                              ) {
                                                                bool
                                                                isFlashDealEnded =
                                                                    false;
                                                                DateTime
                                                                endDate;
                                                                Duration
                                                                _duration =
                                                                    const Duration();
                                                                final now =
                                                                    DateTime.now();
                                                                try {
                                                                  endDate =
                                                                      tran.DateFormat(
                                                                        'MM/dd/yyyy',
                                                                        'en_US',
                                                                      ).parse(
                                                                        state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.flashDealEndDate ??
                                                                            "",
                                                                      );
                                                                  endDate =
                                                                      endDate.add(
                                                                        const Duration(
                                                                          days:
                                                                              1,
                                                                        ),
                                                                      );
                                                                } catch (e) {
                                                                  endDate =
                                                                      DateTime.now();
                                                                  if (kDebugMode) print(
                                                                    'Error parsing date: $e',
                                                                  );
                                                                }
                                                                _duration = endDate
                                                                    .difference(
                                                                      now,
                                                                    );
                                                                if (_duration
                                                                        .isNegative ||
                                                                    _duration
                                                                            .inSeconds <
                                                                        1) {
                                                                  isFlashDealEnded =
                                                                      true;
                                                                }

                                                                return ProductDetailsBottomSheetNew(
                                                                  showShadowForPanel:
                                                                      showShadowForPanel,
                                                                  currentVariant:
                                                                      currentVariantType,
                                                                  visibleRedeemNotifier:
                                                                      finishRedeem,
                                                                  variationId:
                                                                      currentVariationId,
                                                                  visibleFlashDeal:
                                                                      visibleFlashDeal,
                                                                  isFlashDealEnded:
                                                                      isFlashDealEnded,
                                                                  flashDealEndDate:
                                                                      state
                                                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()]
                                                                          ?.product
                                                                          ?.flashDealEndDate ??
                                                                      "",
                                                                  redeemVariantPrice:
                                                                      (currentVariation
                                                                              ?.luckPrice !=
                                                                          null)
                                                                      ? currentVariation?.luckPrice ??
                                                                            0
                                                                      : state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.redeemPrice ??
                                                                            0,
                                                                  isRedeem:
                                                                      (prefsRepository
                                                                                  .getRedeemDateForProduct(
                                                                                    products[tapIndex].productId.toString(),
                                                                                  )
                                                                                  ?.isAfter(
                                                                                    DateTime.now().add(
                                                                                      const Duration(
                                                                                        seconds: 1,
                                                                                      ),
                                                                                    ),
                                                                                  ) ==
                                                                              true &&
                                                                          state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.isRedeem ==
                                                                              true) ||
                                                                      (GetIt.I<
                                                                                    PrefsRepository
                                                                                  >()
                                                                                  .getRedeemSecondRemainingForProduct(
                                                                                    products[tapIndex].productId.toString(),
                                                                                  ) ??
                                                                              0) >
                                                                          0,
                                                                  redeemPrice:
                                                                      state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()] !=
                                                                          null
                                                                      ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.redeemPrice ??
                                                                                  0
                                                                            : 0
                                                                      : 0,
                                                                  initOfferPrice:
                                                                      (products[tapIndex]
                                                                          .offerPrice ??
                                                                      0),
                                                                  initPrice:
                                                                      (products[tapIndex]
                                                                          .price ??
                                                                      0),
                                                                  isGetFullProductDetails:
                                                                      false,
                                                                  currentColorOption:
                                                                      productColors
                                                                          .isNullOrEmpty
                                                                      ? ''
                                                                      : productColors?[currentSelectedColor].option ??
                                                                            products[tapIndex].colors![currentSelectedColor].option ??
                                                                            "",
                                                                  productNotAvailableNotifier:
                                                                      productNotAvailableNotifier,
                                                                  currentActiveTab:
                                                                      currentActiveTab,
                                                                  collectedAfterOrdering:
                                                                      state
                                                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()]
                                                                          ?.product
                                                                          ?.collectedAfterOrdering ==
                                                                      1,
                                                                  tapIndexToAddProductToCart:
                                                                      tapIndexToAddProductToCart,
                                                                  fromListingPage:
                                                                      true,
                                                                  productIdForCashData:
                                                                      products[tapIndex]
                                                                          .productId
                                                                          .toString(),
                                                                  panelController:
                                                                      panelControllerForCart,
                                                                  productSlugForTopic:
                                                                      state
                                                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()]
                                                                          ?.product
                                                                          ?.slug ??
                                                                      "",
                                                                  productDescription:
                                                                      HtmlParser.parseHTML(
                                                                        products[tapIndex].details ??
                                                                            "",
                                                                      ).text,
                                                                  countOfPieces:
                                                                      state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()] !=
                                                                          null
                                                                      ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.countOfPieces ??
                                                                                  0
                                                                            : 0
                                                                      : 0,
                                                                  addToBagButtonShapeNotifier:
                                                                      addToBagButtonShapeNotifier,
                                                                  currentColornum:
                                                                      productColors
                                                                          .isNullOrEmpty
                                                                      ? ''
                                                                      : productColors?[currentSelectedColor].color ??
                                                                            "",
                                                                  boutiqueIcon:
                                                                      state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()] !=
                                                                          null
                                                                      ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique!.icon !=
                                                                                            null
                                                                                        ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique!.icon!.filePath ??
                                                                                              ""
                                                                                        : ""
                                                                                  : ""
                                                                            : ""
                                                                      : "",
                                                                  boutiqueId:
                                                                      state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()] !=
                                                                          null
                                                                      ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique!.id!
                                                                                  : 0
                                                                            : 0
                                                                      : 0,
                                                                  currentColorName:
                                                                      productColors
                                                                          .isNullOrEmpty
                                                                      ? ''
                                                                      : productColors?[currentSelectedColor].name ??
                                                                            "",
                                                                  productItem: products[tapIndex].copyWith(
                                                                    price:
                                                                        currentVariation?.price !=
                                                                            null
                                                                        ? currentVariation
                                                                              ?.price
                                                                        : state
                                                                              .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
                                                                              .product
                                                                              ?.price,
                                                                    offerPrice:
                                                                        currentVariation?.offerPrice !=
                                                                            null
                                                                        ? currentVariation
                                                                              ?.offerPrice
                                                                        : state
                                                                              .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
                                                                              .product
                                                                              ?.offerPrice,
                                                                    variation: state
                                                                        .authProductDetailsModel
                                                                        ?.data
                                                                        ?.variation,

                                                                    availableQuantity:
                                                                        state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId
                                                                                .toString()] ==
                                                                            null
                                                                        ? 0
                                                                        : state
                                                                              .authProductDetailsModel
                                                                              ?.data
                                                                              ?.availableQuantity,
                                                                    sizes:
                                                                        state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId
                                                                                .toString()] ==
                                                                            null
                                                                        ? []
                                                                        : state
                                                                              .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
                                                                              .product
                                                                              ?.sizes,
                                                                    colors: state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                            .productId
                                                                            .toString()]!
                                                                        .product
                                                                        ?.colors,
                                                                    images:
                                                                        state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId
                                                                                .toString()] ==
                                                                            null
                                                                        ? []
                                                                        : state
                                                                              .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
                                                                              .product
                                                                              ?.images,
                                                                    syncColorImages: state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                            .productId
                                                                            .toString()]!
                                                                        .product
                                                                        ?.syncColorImages,
                                                                  ),
                                                                  currentColor:
                                                                      currentSelectedColor,
                                                                  maxAllowedToAddCart:
                                                                      state
                                                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                              .productId
                                                                              .toString()]
                                                                          ?.product
                                                                          ?.maxAllowedQty ??
                                                                      "0",
                                                                );
                                                              },
                                                        );
                                                      },
                                                    );
                                            },
                                          ),
                                        ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
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
        StoriesList(
          isShowPanelForVerified: widget.isShowPanelForVerified,
        ), // height 220
        Positioned(
          top: 5.h,
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

  /// ⚡ تحديد cacheExtent الأمثل حسب مواصفات الجهاز - مُحسن خصيصاً للعودة من listing
}
