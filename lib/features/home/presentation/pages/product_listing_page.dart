import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/animated_search_bar/animated_search_bar.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter_products;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_quick_view_popup.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_colors_panel.dart';
import 'package:trydos/features/search/presentation/widgets/search_with_image_related_gemini.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../data/models/get_home_boutiqes_model.dart' as boutiques;
import '../manager/homeBloc/home_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../widgets/product_listing/product_item.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../widgets/product_listing/product_listing_filter_list.dart';
import '../widgets/product_listing/product_listing_loading.dart';
import '../widgets/product_listing/sort_products_sheet.dart';

class ProductListingPage extends StatefulWidget {
  final String boutiqueSlug;
  final String? category;
  final String? boutiqueIcon;
  final String? boutiqueName;
  final String? boutiqueFirstBanner;
  final bool withSlidingImages;
  final bool? fromNotificationCategory;
  final List<boutiques.BunnerBoutique>? banner;
  final TextEditingController? controllerFormSearchPage;
  final bool fromSearch;

  final bool fromBackground;
  final GetProductFiltersModel? getProductFiltersModel;

  const ProductListingPage({
    super.key,
    required this.boutiqueSlug,
    this.fromBackground = false,
    this.getProductFiltersModel,
    this.boutiqueName,

    this.controllerFormSearchPage,
    this.fromNotificationCategory,
    this.withSlidingImages = false,
    this.banner,
    this.boutiqueFirstBanner,
    this.category,
    this.fromSearch = false,
    this.boutiqueIcon,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  late BoutiqueBloc boutiqueBloc;
  late CategoryBloc categoryBloc;

  final FocusNode focusNode = FocusNode();

  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);

  final ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final ValueNotifier<int> tapIndexToShowColorImages = ValueNotifier(-1);

  final ValueNotifier<bool> loadingForRquestProductDetails = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> searchVisible = ValueNotifier(true);
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final TextEditingController controller = TextEditingController();
  Timer? timerForDisplayFilterSectionTitle;
  final GlobalKey htmlDescriptionKey = GlobalKey();
  final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
  final ValueNotifier<double> htmlDescriptionHeight = ValueNotifier(0);
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollControllerFilter = ScrollController();
  final PanelController colorImagesPanelController = PanelController();
  final ValueNotifier<bool> showShadowForColorImages = ValueNotifier(false);
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  // final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
  //   ValueNotifier(Tuple2(-1, -1));
  Timer? debounce;
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final ValueNotifier<bool> fromSearchListing = ValueNotifier(false);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();

  final ValueNotifier<String?> productNotAvailableNotifier = ValueNotifier(
    null,
  );
  bool isExpanded = false;

  /// هل نافذة تفاصيل/شراء المنتج مفتوحة حالياً (لمنع فتح مسارين).
  bool _isQuickViewOpen = false;

  /// يفتح نافذة تفاصيل/شراء المنتج كـ popup منفصل عند الضغط على منتج.
  ///
  /// المنطق كاملاً في [ProductQuickViewPopup]؛ هنا نتكفّل فقط بفتح المسار مرة
  /// واحدة، وباستعادة حالة الصفحة عند إغلاقه مهما كان السبب (زر الرجوع مثلاً).
  /// قائمة هذه الصفحة مشتقّة من slug البوتيك + الفلاتر + التصنيف، لذلك نمرّرها
  /// عبر `productsResolver` بدل مفاتيح المصادر الثابتة.
  void _handleQuickViewRequest() {
    if (!mounted || _isQuickViewOpen) return;
    if (tapIndexToAddProductToCart.value == -1) return;

    _isQuickViewOpen = true;
    ProductQuickViewPopup.show(
      context: context,
      tapIndexToAddProductToCart: tapIndexToAddProductToCart,
      finishRedeem: finishRedeem,
      visibleFlashDeal: visibleFlashDeal,
      showShadowForPanel: showShadowForPanel,
      loadingForRquestProductDetails: loadingForRquestProductDetails,
      currentActiveTab: currentActiveTab,
      addToBagButtonShapeNotifier: addToBagButtonShapeNotifier,
      productNotAvailableNotifier: productNotAvailableNotifier,
      panelController: panelControllerForCart,
      productsResolver: () => products,
      hideBottomNavigationBar: false,
    ).whenComplete(() {
      _isQuickViewOpen = false;
      if (!mounted) return;
      showShadowForPanel.value = false;
      if (tapIndexToAddProductToCart.value != -1) {
        tapIndexToAddProductToCart.value = -1;
      }
      currentActiveTab.value = 0;
    });
  }

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  bool? fromSearch;
  final SpeechToText _speechToText = SpeechToText();

  final ValueNotifier<bool> isRecordeForSearchWithMic = ValueNotifier(false);
  final ValueNotifier<bool> finishRedeem = ValueNotifier(false);
  Timer? searchDebounce;
  bool itExpendForFirst = true;
  String key = '';
  String keyWithoutFilter = '';
  Filter? prefAppliedFilters;
  Key gridViewKeyForRenderingForTheFiveFilters = UniqueKey();
  Key gridViewKeyForRendering = UniqueKey();
  bool _speechEnabled = false;
  bool firstOpenPage = true;

  /// ⚡ نظام تحسين التمرير السريع الذكي
  void _listenToScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(Duration(milliseconds: firstOpenPage ? 600 : 300), () {
      //videoProductInListingController.forEach((key, value) => value.pause());
      //if (setThisEnabledNotifier.value.item1 != -1) {
      //  setThisEnabledNotifier.value = Tuple2(-1, -1);
      // }
      boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

      if ((scrollController.hasClients && scrollController.offset >= 50) &&
          !(boutiqueBloc.state.isExpandedForListingPage ?? false) &&
          !widget.fromSearch &&
          widget.boutiqueIcon != "") {
        displayBoutiqueIconInAppBar.value = true;
      } else {
        displayBoutiqueIconInAppBar.value = false;
      }

      firstOpenPage = false;
      if (boutiqueBloc.state.isExpandedForListingPage ?? false) return;
      // if (scrollController.position.pixels <= 80) {
      //   debugPrint(scrollController.position.pixels.toString());
      //   appBloc.add(ShowOrHideBars(true));
      // }
      // else if(filterPageExpanded.value){
      //   scrollController.jumpTo(80);
      // }

      if (scrollController.hasClients &&
          scrollController.offset >=
              (scrollController.position.maxScrollExtent * 0.6)) {
        if (boutiqueBloc.state.isGettingProductListingWithPagination) return;

        if (boutiqueBloc
            .state
            .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                ((boutiqueBloc.state.cashedOrginalBoutique)
                    ? 'withoutFilter'
                    : "") +
                '${(widget.category ?? '')}']!
            .hasReachedMax) {
          return;
        }
        boutiqueBloc.add(
          GetProductsWithFiltersWithPaginationEvent(
            context: context,
            fromNotification: widget.fromNotificationCategory,
            limit: 10,
            cashedOrginalBoutique: !widget.fromSearch,
            boutiqueSlug: widget.boutiqueSlug,
            getWithPagination: true,
            fromSearch: widget.fromSearch,
            category: widget.category,
            searchText: controller.text,
            offset: 2,
          ),
        );
      }
    });
  }

  List<filter_products.Products> products = [];

  void _startListening() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    await _speechToText.listen(
      listenFor: const Duration(seconds: 7),
      onResult: (result) {
        if (result.recognizedWords.replaceAll(" ", "").length > 2) {
          resetSearchAfterSearchingWhileRemoveSearch = true;

          String searchText = result.recognizedWords;

          controller.text = result.recognizedWords;
          Filter filters =
              BlocProvider.of<BoutiqueBloc>(context)
                  .state
                  .choosedFiltersByUser[widget.boutiqueSlug +
                      (widget.category ?? "")]
                  ?.filters ??
              Filter();
          BlocProvider.of<BoutiqueBloc>(context).add(
            ChangeSelectedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              fromHomePageSearch: widget.fromSearch,
              filtersChoosedByUser: GetProductFiltersModel(
                filters: filters.copyWithSaveOtherField(
                  prices: filters.prices,
                  searchText: searchText,
                ),
              ),
            ),
          );
          BlocProvider.of<BoutiqueBloc>(context).add(
            ChangeAppliedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersAppliedByUser: GetProductFiltersModel(
                filters: filters.copyWithSaveOtherField(
                  prices: filters.prices,
                  searchText: searchText,
                ),
              ),
            ),
          );

          BlocProvider.of<BoutiqueBloc>(context).add(
            GetProductsWithFiltersEvent(
              offset: 1,
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              resetChoosedFilters: false,
              fromSearch: widget.fromSearch,
              searchText: searchText,
            ),
          );
          _stopListening();
          return;
        }
      },
    );
    isRecordeForSearchWithMic.value = true;
    Future.delayed(
      const Duration(seconds: 9),
      () => isRecordeForSearchWithMic.value = false,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();

    isRecordeForSearchWithMic.value = false;
  }

  @override
  void initState() {
    super.initState();
    LastPagesTracker.push(
      "Product Listing Page , boutique Name:${widget.boutiqueName ?? widget.boutiqueSlug}",
    );
    if (kDebugMode)
      print("%%%%%%%%%${GetIt.I<PrefsRepository>().marketToken}0*");
    if (kDebugMode)
      print("%%%%%%%%%${GetIt.I<PrefsRepository>().storiesToken}*");
    // 🔥 FIX: إزالة Timer.periodic الخطير - استخدام WidgetsBinding آمن بدلاً
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      _setHtmlDescriptionHeight();
    });*/
    productIdToSaveRedeemTimer = [];
    scrollController.addListener(_listenToScroll);
    tapIndexToAddProductToCart.addListener(_handleQuickViewRequest);
    itExpendForFirst = true;
    key = widget.boutiqueSlug + (widget.category ?? '');
    keyWithoutFilter =
        '${widget.boutiqueSlug}' +
        '${(!widget.fromSearch) ? 'withoutFilter' : ""}' +
        '${(widget.category ?? '')}';
    fromSearch = widget.fromSearch;
    searchVisible.value = false;
    if ((widget.controllerFormSearchPage?.text.length ?? 0) > 2) {
      controller.text = widget.controllerFormSearchPage?.text ?? "";
      resetSearchAfterSearchingWhileRemoveSearch = true;
    }

    appBloc = BlocProvider.of<AppBloc>(context);
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    if (widget.fromNotificationCategory ?? false) {
      homeBloc.add(
        const IsChangedVariationWhenQtyZeroEvent(
          isChangedVariationWhenQtyZero: false,
        ),
      );
      homeBloc.add(
        const IsChangedVariationWhenQtyZeroEvent(
          isChangedVariationWhenQtyZero: false,
        ),
      );

      boutiqueBloc.add(
        AddSizeAndColorFilterinTextToSearchEvent(
          sizeAndColorFilterinTextToSearch: const {},
        ),
      );
      appBloc.add(HideBottomNavigationBar(false));
      appBloc.add(ShowOrHideBars(true));
      appBloc.add(ChangeIndexForSearch(0));
      Future.delayed(const Duration(seconds: 1), () {
        boutiqueBloc.add(
          ChangeAppliedFiltersEvent(
            boutiqueSlug: "search",
            resetAppliedFilters: true,
          ),
        );
        boutiqueBloc.add(
          ChangeAppliedFiltersEvent(
            boutiqueSlug: "search",
            filtersAppliedByUser: widget.getProductFiltersModel,
          ),
        );
        boutiqueBloc.add(
          GetProductsWithFiltersEvent(
            fromNotification: widget.fromNotificationCategory,
            boutiqueSlug: "search",
            offset: 1,
            fromSearch: true,
          ),
        );
      });
    }

    ///scrollController.addListener(_listenToScroll);
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        executedEventName: AnalyticsButtonsEventNameConst.PRODUCT_LISTING_PAGE,
        extraParams: {
          'screen_name': GlobalScreenConst.BOUTIQUE_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //   productSlugToSaveVideoTimer = [];
    try {
      //clearvideoProductInListingController(
      //     productSlug: ""); // 🚀 تحسين الأداء عند إغلاق الصفحة لتسريع الانتقال
      debugPrint('🏁 Product listing dispose started');

      // إيقاف الـ listeners أولاً لمنع العمليات غير الضرورية
      //   scrollController.removeListener(_listenToScroll);

      // 🔥 تنظيف Fast Scroll Protection Timers
      //_fastScrollTimer?.cancel();
      //_emergencyMemoryTimer?.cancel();

      // تنظيف موارد الصفحة
      appBloc.add(HideBottomNavigationBar(false));
      if (!widget.fromSearch) {
        appBloc.add(ChangeIndexForSearch(0));
      }
      _speechToText.cancel();
      focusNode.dispose();
      appBloc.add(ShowOrHideBars(true));
      tapIndexToAddProductToCart.removeListener(_handleQuickViewRequest);
      scrollController.dispose();
      controller.dispose();

      // 🎯 دع Flutter يدير الذاكرة تلقائياً عند dispose

      categoryBloc.add(
        ReplyFromGeminiEvent(fromSearch: false, resetTheReply: true),
      );

      // 🔄 تصفير حالة الترتيب عند الخروج من صفحة القائمة
      boutiqueBloc.add(ResetSortEvent());

      debugPrint('✅ Product listing disposed with performance optimization');
    } catch (e) {
      debugPrint('❌ Error in product listing dispose: $e');
    }
    super.dispose();
  }

  /*void postFrameCallback(timer) {
    var context = htmlDescriptionKey.currentContext;
    if (context == null || htmlDescriptionHeight.value > 0) return;
    timer.cancel();
    htmlDescriptionHeight.value = context.size!.height;
  }*/

  // 🔥 NEW: دالة آمنة لضبط ارتفاع HTML بدون Timer مستمر
  /* void _setHtmlDescriptionHeight() {
    var context = htmlDescriptionKey.currentContext;
    if (context != null && htmlDescriptionHeight.value == 0) {
      htmlDescriptionHeight.value = context.size?.height ?? 0;
    } else {
      // إعادة المحاولة مرة واحدة فقط إذا لم ينجح
      Future.delayed(Duration(milliseconds: 100), () {
        var context = htmlDescriptionKey.currentContext;
        if (context != null && htmlDescriptionHeight.value == 0) {
          htmlDescriptionHeight.value = context.size?.height ?? 0;
        }
      });
    }
  }*/

  bool resetSearchAfterSearchingWhileRemoveSearch = false;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
          return false;
        }
        try {
          if (colorImagesPanelController.isPanelOpen) {
            colorImagesPanelController.close();
            showShadowForColorImages.value = false;
            return false;
          }
        } catch (e) {}
        prefsRepository.setTagsInUrlToFilter([]);
        try {
          if (panelControllerForCart.isPanelOpen) {
            panelControllerForCart.close();
            return Future.value(false);
          }
        } catch (e) {}
        if (widget.fromBackground) {
          context.go(GRouter.config.kRootRoute);

          return Future.value(false);
        }

        categoryBloc.add(
          ReplyFromGeminiEvent(fromSearch: false, resetTheReply: true),
        );
        if (widget.fromSearch) {
          widget.controllerFormSearchPage?.text = controller.text;
        }

        itExpendForFirst = false;

        searchVisible.value = false;
        if (boutiqueBloc.state.isExpandedForListingPage ?? false) {
          prefAppliedFilters =
              boutiqueBloc.state.prefAppliedFilterForExtendFilter ?? Filter();

          // homeBloc.add(GetProductFiltersEvent(
          //     fromHomePageSearch: widget.fromSearch,
          //     cashedOrginalBoutique: false,
          //     boutiqueSlug: widget.boutiqueSlug,
          //     category: widget.category,
          //     searchText: widget.searchText,
          //     filtersChoosedByUser:
          //         GetProductFiltersModel(filters: prefAppliedFilters)));
          boutiqueBloc.add(
            ChangeAppliedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersAppliedByUser: GetProductFiltersModel(
                filters: prefAppliedFilters,
              ),
            ),
          );
          controller.text = prefAppliedFilters!.searchText ?? "";

          resetSearchAfterSearchingWhileRemoveSearch = false;

          boutiqueBloc.add(
            AddIsExpandedForLidtingPageEvent(isExpandedForLidting: false),
          );

          ////////////////////////////////////
          /*  FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
          );*/
          return Future.value(false);
        } else {
          Navigator.of(context).pop();

          if (widget.fromSearch) {
            boutiqueBloc.add(
              ChangeSelectedFiltersEvent(
                fromHomePageSearch: widget.fromSearch,
                boutiqueSlug: widget.boutiqueSlug,
                filtersChoosedByUser: GetProductFiltersModel(
                  filters:
                      boutiqueBloc.state.appliedFiltersByUser[key]?.filters,
                ),
              ),
            );

            boutiqueBloc.add(
              ChangeAppliedFiltersEvent(
                boutiqueSlug: widget.boutiqueSlug,
                category: widget.category,
                resetAppliedFilters: true,
              ),
            );
          }

          ////////////////////////////////////
          /*   FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
          );*/
        }

        return Future.value(false);
      },
      child: SafeArea(
        child: Material(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Scaffold(
                backgroundColor: const Color(0xffF8F8F8),
                bottomNavigationBar: BlocBuilder<AppBloc, AppState>(
                  buildWhen: (p, c) => p.showBars != c.showBars,
                  builder: (context, state) {
                    if (state.showBars == true) {
                      return BlocBuilder<AppBloc, AppState>(
                        buildWhen: (p, c) =>
                            p.hideBottomNavigationBar !=
                            c.hideBottomNavigationBar,
                        builder: (context, state) {
                          return state.hideBottomNavigationBar ||
                                  (widget.fromSearch)
                              ? const SizedBox.shrink()
                              : const AppBottomNavBar();
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                body: /* ValueListenableBuilder<Tuple2<int, int>>(
                    valueListenable: setThisEnabledNotifier,
                    builder: (context, slidingMode, _) {
                      return */ BlocBuilder<BoutiqueBloc, BoutiqueState>(
                  buildWhen: (p, c) =>
                      p.isExpandedForListingPage != c.isExpandedForListingPage,
                  builder: (context, homeState) {
                    return BlocBuilder<CategoryBloc, CategoryState>(
                      buildWhen: (p, c) =>
                          ((p.sendRequestToGeminiStatus !=
                                  c.sendRequestToGeminiStatus ||
                              p.theReplyFromGemini != c.theReplyFromGemini) &&
                          c.fromSearchForSearchWithGemini == false),
                      builder: (context, state) {
                        if ((state.theReplyFromGemini ?? "") != "" &&
                            state.fromSearchForSearchWithGemini == false) {
                          String searchText = state.theReplyFromGemini!;

                          controller.text = state.theReplyFromGemini ?? "";
                          Filter filters =
                              BlocProvider.of<BoutiqueBloc>(
                                context,
                              ).state.choosedFiltersByUser['search']?.filters ??
                              Filter();
                          BlocProvider.of<BoutiqueBloc>(context).add(
                            ChangeSelectedFiltersEvent(
                              requestToUpdateFilters: false,
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              fromHomePageSearch: widget.fromSearch,
                              filtersChoosedByUser: GetProductFiltersModel(
                                filters: filters.copyWithSaveOtherField(
                                  prices: filters.prices,
                                  searchText: searchText,
                                ),
                              ),
                            ),
                          );
                          BlocProvider.of<BoutiqueBloc>(context).add(
                            ChangeAppliedFiltersEvent(
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              filtersAppliedByUser: GetProductFiltersModel(
                                filters: filters.copyWithSaveOtherField(
                                  prices: filters.prices,
                                  searchText: searchText,
                                ),
                              ),
                            ),
                          );

                          BlocProvider.of<BoutiqueBloc>(context).add(
                            GetProductsWithFiltersEvent(
                              offset: 1,
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              resetChoosedFilters: false,
                              fromSearch: widget.fromSearch,
                              searchText: searchText,
                            ),
                          );
                        }
                        /*   if (!(homeState.isExpandedForListingPage ?? false) &&
                              !itExpendForFirst) {
                            /*    homeBloc.add(GetProductsWithFiltersEvent(
                              cashedOrginalBoutique: fromSearch ?? false,
                              boutiqueSlug: widget.boutiqueSlug,
                              fromSearch: widget.fromSearch,
                              category: widget.category,
                              searchText: widget.fromSearch
                                  ? widget.searchText
                                  : null,
                              offset: 1));*/
                          }*/
                        isExpanded =
                            homeState.isExpandedForListingPage ?? false;

                        return SafeArea(
                          child: CustomScrollView(
                            /*scrollBehavior:
                                      const ScrollBehavior().copyWith(
                                    overscroll: false,
                                  ),*/
                            // منع overscroll للحماية من crashes
                            cacheExtent: 100, // قيمة محسنة لمنع التعليق
                            key: TestVariables.kTestMode
                                ? const Key(WidgetsKeys.productListingScrollKey)
                                : null,
                            controller: scrollController,
                            physics:
                                homeState
                                            .getProductFiltersModel[key]
                                            ?.filters
                                            ?.totalSize ==
                                        0 &&
                                    isExpanded
                                ? const NeverScrollableScrollPhysics()
                                : const ClampingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                            slivers: [
                              // 🛡️ حماية من تجاوز شريط الحالة
                              SliverSafeArea(
                                bottom: false,
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 0.h), // placeholder
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: tapIndexToAddProductToCart,
                                builder: (context, tapIndex, _) {
                                  return /* tapIndex != -1
                                                ? const SliverToBoxAdapter(
                                                    child: SizedBox(
                                                      height: 0.h,
                                                    ),
                                                  )
                                                :*/ SliverAppBar(
                                    pinned: true,
                                    backgroundColor: colorScheme.white,
                                    automaticallyImplyLeading: false,
                                    flexibleSpace: ValueListenableBuilder<bool>(
                                      valueListenable: searchVisible,
                                      builder: (context, searchOpen, _) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: 5.w,
                                            left: 5.w,
                                          ),
                                          child: /*TrydosAppBar(
                                                                    appBarParams: AppBarParams(
                                                                        scrolledUnderElevation: 0,
                                                                        backIconColor: Colors.black,
                                                                        action: [
                                                                          LanguageService.rtl
                                                                              ? const Spacer()
                                                                              : const SizedBox.shrink(),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsetsDirectional.only(end: 10.0),
                                                                            child:
                                                                                BlocBuilder<HomeBloc, HomeState>(
                                                                              buildWhen: (previous, current) => previous.getProductDetailWithoutSimilarRelatedProductsStatus != current.getProductDetailWithoutSimilarRelatedProductsStatus || previous.authProductDetailsStatus != current.authProductDetailsStatus || previous.updateItemInCartStatus != current.updateItemInCartStatus || previous.addItemInCartStatus != current.addItemInCartStatus || previous.deleteItemInCartStatus != current.deleteItemInCartStatus || previous.getCartItemsStatus != current.getCartItemsStatus,
                                                                              builder: (context, state) {
                                                                                int qtyItemsInCart = state.cartCollection?.length ?? 0;
                                                                                /* state.cartCollection?.forEach(
                                                                            (element) {
                                                                              qtyItemsInCart = qtyItemsInCart + (element.quantity ?? 0);
                                                                            },
                                                                          );*/

                                                                                return Container(
                                                                                  alignment: Alignment.center,
                                                                                  height: 40.h,
                                                                                  width: LanguageService.languageCode != "ar" ? 40 : 50,
                                                                                  child: InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.of(context).push(
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => const CartPage(
                                                                                              fromeFilters: true,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                        //////////////////////////////
                                                                                        /* FirebaseAnalyticsService.logEventForSession(
                                                                                        eventName: AnalyticsEventsConst.buttonClicked,
                                                                                        executedEventName: AnalyticsExecutedEventNameConst.showShoppingBagButton,
                                                                                      );*/
                                                                                      },
                                                                                      child: Stack(children: [
                                                                                        Positioned(
                                                                                          child: SvgPicture.asset(AppAssets.bagsSvg),
                                                                                          right: LanguageService.languageCode != "ar" ? 0 : null,
                                                                                          left: LanguageService.languageCode == "ar" ? 0 : null,
                                                                                          bottom: 5.h,
                                                                                        ),
                                                                                        Positioned(
                                                                                          child: Container(
                                                                                            width: (qtyItemsInCart > 0) ? 15 : 0,
                                                                                            alignment: Alignment.center,
                                                                                            height: (qtyItemsInCart > 0) ? 15 : 0,
                                                                                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20.r)),
                                                                                            child: MyTextWidget(
                                                                                              (qtyItemsInCart > 0) ? "${qtyItemsInCart}" : "",
                                                                                              maxLines: 1,
                                                                                              style: textTheme.titleSmall?.ra.copyWith(fontSize: 12.sp, color: Colors.white, letterSpacing: 0.28),
                                                                                            ),
                                                                                          ),
                                                                                          top: 0.h,
                                                                                          left: LanguageService.languageCode != "ar" ? 5 : null,
                                                                                          right: LanguageService.languageCode != "en"
                                                                                              ? (qtyItemsInCart.toString().length > 1)
                                                                                                  ? 0
                                                                                                  : 10
                                                                                              : null,
                                                                                        )
                                                                                      ])),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                        withShadow: false),
                                                                  )*/ TrydosAppBar(
                                            appBarParams: AppBarParams(
                                              onBack: () {
                                                prefsRepository
                                                    .setTagsInUrlToFilter([]);
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                                try {
                                                  if (panelControllerForCart
                                                      .isPanelOpen) {
                                                    panelControllerForCart
                                                        .close();
                                                    return;
                                                  }
                                                } catch (e) {}
                                                if (widget.fromBackground) {
                                                  context.go(
                                                    GRouter.config.kRootRoute,
                                                  );
                                                }
                                                categoryBloc.add(
                                                  ReplyFromGeminiEvent(
                                                    fromSearch: false,
                                                    resetTheReply: true,
                                                  ),
                                                );
                                                if (widget.fromSearch) {
                                                  widget
                                                      .controllerFormSearchPage
                                                      ?.text = controller
                                                      .text;
                                                  boutiqueBloc.add(
                                                    ChangeAppliedFiltersEvent(
                                                      boutiqueSlug:
                                                          widget.boutiqueSlug,
                                                      category: widget.category,
                                                      filtersAppliedByUser:
                                                          GetProductFiltersModel(
                                                            filters: boutiqueBloc
                                                                .state
                                                                .appliedFiltersByUser[key]
                                                                ?.filters,
                                                          ),
                                                    ),
                                                  );
                                                  boutiqueBloc.add(
                                                    ChangeSelectedFiltersEvent(
                                                      fromHomePageSearch:
                                                          widget.fromSearch,
                                                      boutiqueSlug:
                                                          widget.boutiqueSlug,
                                                      category: widget.category,
                                                      filtersChoosedByUser:
                                                          GetProductFiltersModel(
                                                            filters: boutiqueBloc
                                                                .state
                                                                .appliedFiltersByUser[key]
                                                                ?.filters,
                                                          ),
                                                    ),
                                                  );
                                                }
                                              },
                                              backgroundColor:
                                                  colorScheme.white,
                                              scrolledUnderElevation: 0,
                                              backIconColor: Colors.black,
                                              hasLeading:
                                                  !isExpanded && !searchOpen,
                                              action: [
                                                const Spacer(),
                                                ValueListenableBuilder<bool>(
                                                  valueListenable:
                                                      displayBoutiqueIconInAppBar,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional.only(
                                                          start: 30.w,
                                                        ),
                                                    child:
                                                        widget.boutiqueIcon !=
                                                            null
                                                        ? MyCachedNetworkImage(
                                                            imageUrl:
                                                                widget
                                                                    .boutiqueIcon ??
                                                                "",
                                                            height: 20.h,
                                                            imageFit:
                                                                BoxFit.contain,
                                                            width: 21.w,
                                                          )
                                                        : const SizedBox.shrink(),
                                                  ),
                                                  builder:
                                                      (
                                                        context,
                                                        display,
                                                        child,
                                                      ) {
                                                        return display
                                                            ? child!
                                                            : const SizedBox.shrink();
                                                      },
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsetsDirectional.only(
                                                        end: searchOpen
                                                            ? 10.w
                                                            : 20.w,
                                                      ),
                                                  child: AnimatedSearchBar(
                                                    key: TestVariables.kTestMode
                                                        ? const Key(
                                                            WidgetsKeys
                                                                .productListingSearchInputKey,
                                                          )
                                                        : null,
                                                    width: isExpanded
                                                        ? (1.sw - 90.w)
                                                        : (1.sw - 120.w),
                                                    height: 40.h,
                                                    onClickClose: () {
                                                      boutiqueBloc.add(
                                                        AddSizeAndColorFilterinTextToSearchEvent(
                                                          sizeAndColorFilterinTextToSearch:
                                                              const {},
                                                        ),
                                                      );

                                                      if (!isExpanded &&
                                                          controller
                                                              .text
                                                              .isNotEmpty) {
                                                        Filter filters =
                                                            boutiqueBloc
                                                                .state
                                                                .appliedFiltersByUser[key]
                                                                ?.filters ??
                                                            Filter();
                                                        boutiqueBloc.add(
                                                          ChangeAppliedFiltersEvent(
                                                            boutiqueSlug: widget
                                                                .boutiqueSlug,
                                                            category:
                                                                widget.category,
                                                            filtersAppliedByUser:
                                                                GetProductFiltersModel(
                                                                  filters: filters
                                                                      .copyWithSaveOtherField(
                                                                        prices:
                                                                            filters.prices,
                                                                      ),
                                                                ),
                                                          ),
                                                        );
                                                        boutiqueBloc.add(
                                                          GetProductsWithFiltersEvent(
                                                            offset: 1,
                                                            fromSearch:
                                                                fromSearch,
                                                            category:
                                                                widget.category,
                                                            boutiqueSlug: widget
                                                                .boutiqueSlug,
                                                          ),
                                                        );
                                                      }
                                                      if (isExpanded &&
                                                          controller
                                                              .text
                                                              .isNotEmpty) {
                                                        Filter filters =
                                                            boutiqueBloc
                                                                .state
                                                                .choosedFiltersByUser[key]
                                                                ?.filters ??
                                                            Filter();
                                                        boutiqueBloc.add(
                                                          ChangeSelectedFiltersEvent(
                                                            fromHomePageSearch:
                                                                widget
                                                                    .fromSearch,
                                                            boutiqueSlug: widget
                                                                .boutiqueSlug,
                                                            filtersChoosedByUser:
                                                                GetProductFiltersModel(
                                                                  filters: filters
                                                                      .copyWithSaveOtherField(
                                                                        prices:
                                                                            filters.prices,
                                                                      ),
                                                                ),
                                                          ),
                                                        );
                                                      }

                                                      resetSearchAfterSearchingWhileRemoveSearch =
                                                          false;
                                                      FocusScope.of(
                                                        context,
                                                      ).unfocus();

                                                      searchVisible.value =
                                                          false;

                                                      controller.clear();
                                                      appBloc.add(
                                                        HideBottomNavigationBar(
                                                          false,
                                                        ),
                                                      );
                                                      ///////////////////////////
                                                      /* FirebaseAnalyticsService.logEventForSession(
                                                                                eventName: AnalyticsEventsConst.buttonClicked,
                                                                                executedEventName: AnalyticsExecutedEventNameConst.resetCloseIconButton,
                                                                              );*/
                                                      return false;
                                                    },
                                                    textController: controller,
                                                    focusNode: focusNode,
                                                    onSuffixTap: () {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                            (timeStamp) {
                                                              searchVisible
                                                                      .value =
                                                                  true;
                                                            },
                                                          );
                                                    },
                                                    suffixWidget: Center(
                                                      child: SvgPicture.asset(
                                                        AppAssets
                                                            .searchOutlinedSvg,
                                                        height: 20.h,
                                                        width: 20.w,
                                                        // ignore: deprecated_member_use
                                                        color: const Color(
                                                          0xff388CFF,
                                                        ),
                                                      ),
                                                    ),
                                                    prefixWidget: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 15.w,
                                                        top: 10.h,
                                                        bottom: 10.h,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              SearchWithImageRelatedGemini.SelecteImageForSearch(
                                                                fromSearch:
                                                                    false,
                                                                context:
                                                                    context,
                                                              );
                                                              /////////////////////////////
                                                              /*  FirebaseAnalyticsService.logEventForSession(
                                                                                        eventName: AnalyticsEventsConst.buttonClicked,
                                                                                        executedEventName: AnalyticsExecutedEventNameConst.searchWithImageButton,
                                                                                      );*/
                                                            },
                                                            child:
                                                                state.sendRequestToGeminiStatus ==
                                                                    SendRequestToGeminiStatus
                                                                        .loading
                                                                ? TrydosLoader(
                                                                    size: 18.h,
                                                                  )
                                                                : SvgPicture.asset(
                                                                    AppAssets
                                                                        .realCameraSvg,
                                                                    height:
                                                                        20.h,
                                                                    width: 20.w,
                                                                  ),
                                                          ),
                                                          ValueListenableBuilder<
                                                            bool
                                                          >(
                                                            valueListenable:
                                                                isRecordeForSearchWithMic,
                                                            builder:
                                                                (
                                                                  context,
                                                                  recordeForSearchWithMic,
                                                                  _,
                                                                ) {
                                                                  return InkWell(
                                                                    onTap: () async {
                                                                      final status = await Permission
                                                                          .microphone
                                                                          .request();
                                                                      if (status !=
                                                                          PermissionStatus
                                                                              .granted) {
                                                                        return;
                                                                      }
                                                                      if (_speechToText
                                                                          .isNotListening) {
                                                                        _startListening();
                                                                        /////////////////////////////
                                                                        /*  FirebaseAnalyticsService.logEventForSession(
                                                                                              eventName: AnalyticsEventsConst.buttonClicked,
                                                                                              executedEventName: AnalyticsExecutedEventNameConst.searchWithVoiceButton,
                                                                                            );*/
                                                                      } else {
                                                                        _stopListening();
                                                                      }
                                                                    },
                                                                    child: SizedBox(
                                                                      width:
                                                                          20.w,
                                                                      child: Icon(
                                                                        _speechToText.isNotListening ||
                                                                                !recordeForSearchWithMic
                                                                            ? Icons.mic_off
                                                                            : Icons.mic,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    animationDurationInMilli:
                                                        400,
                                                    searchDecoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              focusNode.hasFocus
                                                              ? const Color(
                                                                  0xffE6E6E6,
                                                                )
                                                              : const Color(
                                                                  0xffF8F8F8,
                                                                ),
                                                          width: 0.4,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              kbrBorderTextField,
                                                            ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              focusNode.hasFocus
                                                              ? const Color(
                                                                  0xffE6E6E6,
                                                                )
                                                              : const Color(
                                                                  0xffF8F8F8,
                                                                ),
                                                          width: 0.4,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              kbrBorderTextField,
                                                            ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              focusNode.hasFocus
                                                              ? const Color(
                                                                  0xffE6E6E6,
                                                                )
                                                              : const Color(
                                                                  0xffF8F8F8,
                                                                ),
                                                          width: 0.4,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              kbrBorderTextField,
                                                            ),
                                                      ),
                                                      disabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              focusNode.hasFocus
                                                              ? const Color(
                                                                  0xffE6E6E6,
                                                                )
                                                              : const Color(
                                                                  0xffF8F8F8,
                                                                ),
                                                          width: 0.4,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              kbrBorderTextField,
                                                            ),
                                                      ),
                                                      errorBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: context
                                                              .colorScheme
                                                              .error,
                                                          width: 0.4,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              kbrBorderTextField,
                                                            ),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color: context
                                                                      .colorScheme
                                                                      .error,
                                                                  width: 0.4,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  kbrBorderTextField,
                                                                ),
                                                          ),
                                                      filled: true,
                                                      fillColor:
                                                          focusNode.hasFocus
                                                          ? colorScheme.white
                                                          : const Color(
                                                              0xffF8F8F8,
                                                            ),
                                                      prefixIcon: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 12.h,
                                                              bottom: 12.h,
                                                            ),
                                                        child: SvgPicture.asset(
                                                          AppAssets
                                                              .searchOutlinedSvg,
                                                          height: 20.h,
                                                          width: 20.w,
                                                          // ignore: deprecated_member_use
                                                          color: const Color(
                                                            0xff388CFF,
                                                          ),
                                                        ),
                                                      ),
                                                      suffixIcon: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              right: 15.w,
                                                              top: 10.h,
                                                              bottom: 10.h,
                                                            ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                SearchWithImageRelatedGemini.SelecteImageForSearch(
                                                                  fromSearch:
                                                                      false,
                                                                  context:
                                                                      context,
                                                                );
                                                                /////////////////////////////
                                                                /*   FirebaseAnalyticsService.logEventForSession(
                                                                                          eventName: AnalyticsEventsConst.buttonClicked,
                                                                                          executedEventName: AnalyticsExecutedEventNameConst.searchWithImageButton,
                                                                                        );*/
                                                              },
                                                              child:
                                                                  state.sendRequestToGeminiStatus ==
                                                                      SendRequestToGeminiStatus
                                                                          .loading
                                                                  ? TrydosLoader(
                                                                      size:
                                                                          18.h,
                                                                    )
                                                                  : SvgPicture.asset(
                                                                      AppAssets
                                                                          .realCameraSvg,
                                                                      height:
                                                                          20.h,
                                                                      width:
                                                                          20.w,
                                                                    ),
                                                            ),
                                                            SizedBox(
                                                              width: 20.w,
                                                            ),
                                                            ValueListenableBuilder<
                                                              bool
                                                            >(
                                                              valueListenable:
                                                                  isRecordeForSearchWithMic,
                                                              builder:
                                                                  (
                                                                    context,
                                                                    recordeForSearchWithMic,
                                                                    _,
                                                                  ) {
                                                                    return InkWell(
                                                                      onTap: () async {
                                                                        final status = await Permission
                                                                            .microphone
                                                                            .request();
                                                                        if (status !=
                                                                            PermissionStatus.granted) {
                                                                          return;
                                                                        }
                                                                        if (_speechToText
                                                                            .isNotListening) {
                                                                          _startListening();
                                                                          /////////////////////////////
                                                                          /*FirebaseAnalyticsService.logEventForSession(
                                                                                                eventName: AnalyticsEventsConst.buttonClicked,
                                                                                                executedEventName: AnalyticsExecutedEventNameConst.searchWithVoiceButton,
                                                                                              );*/
                                                                        } else {
                                                                          _stopListening();
                                                                        }
                                                                      },
                                                                      child: SizedBox(
                                                                        width:
                                                                            20.w,
                                                                        child: Icon(
                                                                          _speechToText.isNotListening ||
                                                                                  !recordeForSearchWithMic
                                                                              ? Icons.mic_off
                                                                              : Icons.mic,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      //context.colorScheme.white,
                                                      contentPadding:
                                                          HWEdgeInsetsDirectional.only(
                                                            start: 20.w,
                                                            end: 10.w,
                                                            bottom: 12.h,
                                                            top: 12.h,
                                                          ),
                                                      hintText:
                                                          '${LocaleKeys.search.tr()}',
                                                      hintStyle: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.lq
                                                          .copyWith(
                                                            color: const Color(
                                                              0xffC4C2C2,
                                                            ),
                                                          ),
                                                      labelStyle: context
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            color: context
                                                                .colorScheme
                                                                .hint,
                                                          ),
                                                    ),
                                                    onChanged: (String text) {
                                                      if (searchDebounce
                                                              ?.isActive ??
                                                          false) {
                                                        searchDebounce!
                                                            .cancel();
                                                      }
                                                      searchDebounce = Timer(
                                                        const Duration(
                                                          seconds: 1,
                                                        ),
                                                        () {
                                                          String searchText =
                                                              text;

                                                          if (isExpanded) {
                                                            Filter filters =
                                                                boutiqueBloc
                                                                    .state
                                                                    .choosedFiltersByUser[key]
                                                                    ?.filters ??
                                                                Filter();
                                                            if (text.length >
                                                                2) {
                                                              resetSearchAfterSearchingWhileRemoveSearch =
                                                                  true;
                                                              boutiqueBloc.add(
                                                                ChangeSelectedFiltersEvent(
                                                                  fromHomePageSearch:
                                                                      widget
                                                                          .fromSearch,
                                                                  boutiqueSlug:
                                                                      widget
                                                                          .boutiqueSlug,
                                                                  filtersChoosedByUser: GetProductFiltersModel(
                                                                    filters: filters.copyWithSaveOtherField(
                                                                      prices: filters
                                                                          .prices,
                                                                      searchText:
                                                                          searchText,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            if (text.length <
                                                                    3 &&
                                                                resetSearchAfterSearchingWhileRemoveSearch) {
                                                              resetSearchAfterSearchingWhileRemoveSearch =
                                                                  false;
                                                              boutiqueBloc.add(
                                                                ChangeSelectedFiltersEvent(
                                                                  fromHomePageSearch:
                                                                      widget
                                                                          .fromSearch,
                                                                  boutiqueSlug:
                                                                      widget
                                                                          .boutiqueSlug,
                                                                  filtersChoosedByUser: GetProductFiltersModel(
                                                                    filters: filters
                                                                        .copyWithSaveOtherField(
                                                                          prices:
                                                                              filters.prices,
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return;
                                                          }
                                                          if (text.length > 2) {
                                                            resetSearchAfterSearchingWhileRemoveSearch =
                                                                true;
                                                            Filter filters =
                                                                boutiqueBloc
                                                                    .state
                                                                    .appliedFiltersByUser[key]
                                                                    ?.filters ??
                                                                Filter();

                                                            boutiqueBloc.add(
                                                              ChangeAppliedFiltersEvent(
                                                                category: widget
                                                                    .category,
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                                filtersAppliedByUser: GetProductFiltersModel(
                                                                  filters: filters.copyWithSaveOtherField(
                                                                    prices: filters
                                                                        .prices,
                                                                    searchText:
                                                                        searchText,
                                                                  ),
                                                                ),
                                                              ),
                                                            );

                                                            boutiqueBloc.add(
                                                              GetProductsWithFiltersEvent(
                                                                offset: 1,
                                                                searchText:
                                                                    searchText,
                                                                fromSearch:
                                                                    fromSearch,
                                                                category: widget
                                                                    .category,
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                              ),
                                                            );
                                                          }
                                                          if (text.length < 3 &&
                                                              resetSearchAfterSearchingWhileRemoveSearch) {
                                                            boutiqueBloc.add(
                                                              AddSizeAndColorFilterinTextToSearchEvent(
                                                                sizeAndColorFilterinTextToSearch:
                                                                    const {},
                                                              ),
                                                            );
                                                            resetSearchAfterSearchingWhileRemoveSearch =
                                                                false;
                                                            Filter filters =
                                                                boutiqueBloc
                                                                    .state
                                                                    .appliedFiltersByUser[key]
                                                                    ?.filters ??
                                                                Filter();

                                                            boutiqueBloc.add(
                                                              ChangeAppliedFiltersEvent(
                                                                category: widget
                                                                    .category,
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                                filtersAppliedByUser: GetProductFiltersModel(
                                                                  filters: filters
                                                                      .copyWithSaveOtherField(
                                                                        prices:
                                                                            filters.prices,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                            boutiqueBloc.add(
                                                              GetFiltersEvent(
                                                                fromHomePageSearch:
                                                                    widget
                                                                        .fromSearch,
                                                                category: widget
                                                                    .category,
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                              ),
                                                            );
                                                            boutiqueBloc.add(
                                                              GetProductsWithFiltersEvent(
                                                                offset: 1,
                                                                fromSearch:
                                                                    fromSearch,
                                                                category: widget
                                                                    .category,
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                AnimatedSize(
                                                  curve: Curves.easeOut,
                                                  duration: const Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  reverseDuration:
                                                      const Duration(
                                                        milliseconds: 400,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      isExpanded
                                                          ? const SizedBox.shrink()
                                                          : Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional.only(
                                                                    end:
                                                                        searchOpen
                                                                        ? 10.w
                                                                        : 20.w,
                                                                  ),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  showSortProductsSheet(
                                                                    context:
                                                                        context,
                                                                    searchText:
                                                                        controller.text.length >
                                                                            2
                                                                        ? controller
                                                                              .text
                                                                        : null,
                                                                    boutiqueBloc:
                                                                        boutiqueBloc,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                    category: widget
                                                                        .category,
                                                                    fromSearch:
                                                                        widget
                                                                            .fromSearch,
                                                                  );
                                                                },
                                                                child:
                                                                    BlocBuilder<
                                                                      BoutiqueBloc,
                                                                      BoutiqueState
                                                                    >(
                                                                      buildWhen:
                                                                          (
                                                                            p,
                                                                            c,
                                                                          ) =>
                                                                              p.sortKey.isEmpty !=
                                                                              c.sortKey.isEmpty,
                                                                      builder:
                                                                          (
                                                                            context,
                                                                            sortState,
                                                                          ) {
                                                                            final bool
                                                                            sortActive =
                                                                                sortState.sortKey.isNotEmpty;
                                                                            return Stack(
                                                                              clipBehavior: Clip.none,
                                                                              children: [
                                                                                SvgPicture.asset(
                                                                                  AppAssets.sortingSvg,
                                                                                  width: 20.w,
                                                                                  height: 20.h,
                                                                                ),
                                                                                if (sortActive)
                                                                                  PositionedDirectional(
                                                                                    top: -2.h,
                                                                                    start: -2.w,
                                                                                    child: Container(
                                                                                      width: 8.w,
                                                                                      height: 8.w,
                                                                                      decoration: BoxDecoration(
                                                                                        color: const Color(
                                                                                          0xffFF5F61,
                                                                                        ),
                                                                                        shape: BoxShape.circle,
                                                                                        border: Border.all(
                                                                                          color: colorScheme.white,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            );
                                                                          },
                                                                    ),
                                                              ),
                                                            ),
                                                      BlocBuilder<
                                                        BoutiqueBloc,
                                                        BoutiqueState
                                                      >(
                                                        buildWhen: (p, c) {
                                                          return (p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                      '${homeState.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                      '${(widget.category ?? '')}'] !=
                                                                  c.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                      '${homeState.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                      '${(widget.category ?? '')}'] ||
                                                              p.getProductFiltersStatus[key] !=
                                                                  c.getProductFiltersStatus[key] ||
                                                              p.isExpandedForListingPage !=
                                                                  c.isExpandedForListingPage ||
                                                              p.cashedOrginalBoutique !=
                                                                  c.cashedOrginalBoutique);
                                                        },
                                                        builder: (context, state) {
                                                          isExpanded =
                                                              state
                                                                  .isExpandedForListingPage ??
                                                              false;
                                                          if ((state
                                                                      .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                          '${(widget.category ?? '')}']
                                                                      ?.items
                                                                      .length ??
                                                                  0) ==
                                                              1) {
                                                            return const SizedBox.shrink();
                                                          }
                                                          return Padding(
                                                            padding:
                                                                EdgeInsetsDirectional.only(
                                                                  end:
                                                                      searchOpen
                                                                      ? 10.w
                                                                      : 20.w,
                                                                ),
                                                            child: InkWell(
                                                              key:
                                                                  TestVariables
                                                                      .kTestMode
                                                                  ? const Key(
                                                                      WidgetsKeys
                                                                          .filterIconKey,
                                                                    )
                                                                  : null,
                                                              onTap: () {
                                                                if (!isExpanded) {
                                                                  prefAppliedFilters =
                                                                      boutiqueBloc
                                                                          .state
                                                                          .appliedFiltersByUser[key]
                                                                          ?.filters;
                                                                  boutiqueBloc.add(
                                                                    ChangeAppliedFiltersEvent(
                                                                      boutiqueSlug:
                                                                          widget
                                                                              .boutiqueSlug,
                                                                      category:
                                                                          widget
                                                                              .category,
                                                                      isExpandedForListing:
                                                                          true,
                                                                      resetAppliedFilters:
                                                                          true,
                                                                    ),
                                                                  );
                                                                  boutiqueBloc.add(
                                                                    AddPrefAppliedFilterForExtendFilterEvent(
                                                                      prefAppliedFilter:
                                                                          prefAppliedFilters,
                                                                    ),
                                                                  );

                                                                  boutiqueBloc.add(
                                                                    ChangeSelectedFiltersEvent(
                                                                      fromHomePageSearch:
                                                                          widget
                                                                              .fromSearch,
                                                                      boutiqueSlug:
                                                                          widget
                                                                              .boutiqueSlug,
                                                                      category:
                                                                          widget
                                                                              .category,
                                                                      isExpandedForListing:
                                                                          true,
                                                                      filtersChoosedByUser: GetProductFiltersModel(
                                                                        filters:
                                                                            prefAppliedFilters,
                                                                      ),
                                                                    ),
                                                                  );

                                                                  resetSearchAfterSearchingWhileRemoveSearch =
                                                                      false;
                                                                  // تم جعل الصفحة expanded باستخدام الأحداث السابقة لتجنب البناء المتكرر
                                                                  // homeBloc
                                                                  //     .add(
                                                                  //     AddIsExpandedForLidtingPageEvent(
                                                                  //         isExpandedForLidting: true));
                                                                  /////////////////////////////////////////
                                                                  /*FirebaseAnalyticsService.logEventForSession(
                                                                                              eventName: AnalyticsEventsConst.buttonClicked,
                                                                                              executedEventName: AnalyticsExecutedEventNameConst.productListingFilterIconButton,
                                                                                            );*/
                                                                  /////////////////////////////////////////
                                                                  /* FirebaseAnalyticsService.logScreen(
                                                                                              screen: AnalyticsScreensConst.productListingFilterScreen,
                                                                                            );*/
                                                                }
                                                              },
                                                              child: SvgPicture.asset(
                                                                AppAssets
                                                                    .filtersSvg,
                                                                width: 20.w,
                                                                height: 20.h,
                                                                // ignore: deprecated_member_use
                                                                color:
                                                                    isExpanded
                                                                    ? const Color(
                                                                        0xffFF5F61,
                                                                      )
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          if (isExpanded) {
                                                            prefAppliedFilters =
                                                                boutiqueBloc
                                                                    .state
                                                                    .prefAppliedFilterForExtendFilter;
                                                            controller.text =
                                                                prefAppliedFilters
                                                                    ?.searchText ??
                                                                "";

                                                            // homeBloc.add(GetProductFiltersEvent(
                                                            //     fromHomePageSearch: widget
                                                            //         .fromSearch,
                                                            //     cashedOrginalBoutique:
                                                            //         false,
                                                            //     boutiqueSlug:
                                                            //         widget.boutiqueSlug,
                                                            //     category: widget.category,
                                                            //     searchText: widget.searchText,
                                                            //     filtersChoosedByUser: GetProductFiltersModel(filters: prefAppliedFilters)));
                                                            boutiqueBloc.add(
                                                              ChangeAppliedFiltersEvent(
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                                isExpandedForListing:
                                                                    false,
                                                                category: widget
                                                                    .category,
                                                                filtersAppliedByUser:
                                                                    GetProductFiltersModel(
                                                                      filters:
                                                                          prefAppliedFilters,
                                                                    ),
                                                              ),
                                                            );
                                                            //////////////////////////////////
                                                            /* FirebaseAnalyticsService.logEventForSession(
                                                                                        eventName: AnalyticsEventsConst.buttonClicked,
                                                                                        executedEventName: AnalyticsExecutedEventNameConst.filterCloseIconButton,
                                                                                      );*/
                                                          }
                                                          // تم جعل الصفحة not expanded باستخدام الأحداث السابقة لتجنب البناء المتكرر
                                                          // homeBloc.add(
                                                          //     AddIsExpandedForLidtingPageEvent(
                                                          //         isExpandedForLidting:
                                                          //         false));

                                                          resetSearchAfterSearchingWhileRemoveSearch =
                                                              false;
                                                        },
                                                        child: SizedBox(
                                                          height: 30.h,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    searchOpen
                                                                    ? 0
                                                                    : !isExpanded
                                                                    ? 10.w
                                                                    : 12.5.w,
                                                              ),
                                                              !isExpanded
                                                                  ? SvgPicture.asset(
                                                                      AppAssets
                                                                          .shareSvg,
                                                                      width:
                                                                          20.w,
                                                                      height:
                                                                          20.h,
                                                                      // ignore: deprecated_member_use
                                                                      color: const Color(
                                                                        0xff3C3C3C,
                                                                      ),
                                                                    )
                                                                  : SvgPicture.asset(
                                                                      key:
                                                                          TestVariables
                                                                              .kTestMode
                                                                          ? const Key(
                                                                              WidgetsKeys.closeFilterPageKey,
                                                                            )
                                                                          : null,
                                                                      AppAssets
                                                                          .closeSvg,
                                                                      width:
                                                                          15.w,
                                                                      height:
                                                                          15.h,
                                                                      // ignore: deprecated_member_use
                                                                      color: const Color(
                                                                        0xffFF5F61,
                                                                      ),
                                                                    ),
                                                              SizedBox(
                                                                width:
                                                                    !isExpanded
                                                                    ? 10.w
                                                                    : 12.5.w,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              withShadow: false,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: searchVisible,
                                builder: (context, searchOpen, _) {
                                  return !fromSearch!
                                      ? ValueListenableBuilder<double>(
                                          valueListenable:
                                              htmlDescriptionHeight,
                                          builder: (context, htmlHeight, child) {
                                            return isExpanded
                                                ? const SliverToBoxAdapter()
                                                : SliverAppBar(
                                                    collapsedHeight:
                                                        180.h + htmlHeight,
                                                    backgroundColor:
                                                        colorScheme.white,
                                                    automaticallyImplyLeading:
                                                        false,
                                                    flexibleSpace: Column(
                                                      children: [
                                                        Center(
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  widget.boutiqueIcon !=
                                                                          null
                                                                      ? MyCachedNetworkImage(
                                                                          imageUrl:
                                                                              widget.boutiqueIcon ??
                                                                              "",
                                                                          height:
                                                                              20.h,
                                                                          imageFit:
                                                                              BoxFit.contain,
                                                                          width:
                                                                              20.w,
                                                                        )
                                                                      : const SizedBox.shrink(),
                                                                  SizedBox(
                                                                    width: 8.w,
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    AppAssets
                                                                        .verifiedBadgeSvg,
                                                                    height:
                                                                        15.h,
                                                                    width: 15.w,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8.w,
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    AppAssets
                                                                        .starBadgeSvg,
                                                                    height:
                                                                        15.h,
                                                                    width: 15.w,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 5.h,
                                                              ),
                                                              Text(
                                                                widget.boutiqueName ??
                                                                    '',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.rq
                                                                    .copyWith(
                                                                      color: const Color(
                                                                        0xff505050,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          12.sp,
                                                                      height:
                                                                          1.h,
                                                                    ),
                                                              ),
                                                              SizedBox(
                                                                height: 5.h,
                                                              ),
                                                              widget.withSlidingImages
                                                                  ? SizedBox(
                                                                      height:
                                                                          128.h,
                                                                      //color: Colors.red,
                                                                      child: CarouselSlider.builder(
                                                                        itemCount: widget
                                                                            .banner!
                                                                            .length,
                                                                        itemBuilder:
                                                                            (
                                                                              context,
                                                                              index,
                                                                              _,
                                                                            ) {
                                                                              // 🔧 إضافة lazy loading للصور
                                                                              bool
                                                                              isVisible =
                                                                                  index <=
                                                                                  2; // عرض أول 3 صور فقط

                                                                              return Padding(
                                                                                padding: EdgeInsets.only(
                                                                                  right: 10.w,
                                                                                  left: 10.w,
                                                                                ),
                                                                                child: Container(
                                                                                  height: 128.h,
                                                                                  width: 1.sw,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      15.0,
                                                                                    ),
                                                                                    border: Border.all(
                                                                                      width: 0.5,
                                                                                      color: const Color(
                                                                                        0xfffafafa,
                                                                                      ),
                                                                                    ),
                                                                                    boxShadow: const [
                                                                                      BoxShadow(
                                                                                        color: Color(
                                                                                          0x33000000,
                                                                                        ),
                                                                                        offset: Offset(
                                                                                          0,
                                                                                          3,
                                                                                        ),
                                                                                        blurRadius: 10,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child:
                                                                                      (widget.banner![index].filePath !=
                                                                                              null &&
                                                                                          isVisible) // 🔧 شرط الرؤية
                                                                                      ? MyCachedNetworkImage(
                                                                                          imageUrl: widget.banner![index].filePath!,
                                                                                          imageFit: BoxFit.cover,
                                                                                          width: 1.sw,
                                                                                          height: 128.h,
                                                                                          radius: 15.r,
                                                                                        )
                                                                                      : Container(
                                                                                          // 🔧 placeholder للصور غير المرئية
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors.grey[200],
                                                                                            borderRadius: BorderRadius.circular(
                                                                                              15,
                                                                                            ),
                                                                                          ),
                                                                                          child: Center(
                                                                                            child: Icon(
                                                                                              Icons.image,
                                                                                              color: Colors.grey[400],
                                                                                              size: 40.h,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                ),
                                                                              );
                                                                            },
                                                                        options: CarouselOptions(
                                                                          autoPlayInterval: const Duration(
                                                                            seconds:
                                                                                30,
                                                                          ), // 🔧 زيادة المدة لتقليل التحديثات
                                                                          autoPlayAnimationDuration: const Duration(
                                                                            milliseconds:
                                                                                300,
                                                                          ), // 🔧 تقليل مدة الحركة
                                                                          height:
                                                                              128.h,
                                                                          enableInfiniteScroll:
                                                                              false,
                                                                          viewportFraction:
                                                                              1.0, // 🔧 تغيير لـ 1.0 لتقليل الرسم الإضافي
                                                                          pauseAutoPlayInFiniteScroll:
                                                                              true, // 🔧 إيقاف في نهاية القائمة
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            25.w,
                                                                      ),
                                                                      child: Stack(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                135.h,
                                                                            width:
                                                                                1.sw,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                15.0,
                                                                              ),
                                                                              border: Border.all(
                                                                                width: 0.5,
                                                                                color: const Color(
                                                                                  0xfffafafa,
                                                                                ),
                                                                              ),
                                                                              boxShadow: const [
                                                                                BoxShadow(
                                                                                  color: Color(
                                                                                    0x33000000,
                                                                                  ),
                                                                                  offset: Offset(
                                                                                    0,
                                                                                    3,
                                                                                  ),
                                                                                  blurRadius: 10,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child: MyCachedNetworkImage(
                                                                              imageUrl: widget.boutiqueFirstBanner!,
                                                                              imageFit: BoxFit.cover,
                                                                              width: 1.sw,
                                                                              radius: 15.r,
                                                                              height: 130.h,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                htmlHeight ==
                                                                                    0
                                                                                ? 0
                                                                                : 128.h,
                                                                            width:
                                                                                1.sw,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                15.0,
                                                                              ),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  // ignore: deprecated_member_use
                                                                                  color:
                                                                                      // ignore: deprecated_member_use
                                                                                      Colors.white.withOpacity(
                                                                                        0.7,
                                                                                      ),
                                                                                  offset: const Offset(
                                                                                    0,
                                                                                    3,
                                                                                  ),
                                                                                  blurRadius: 6,
                                                                                  inset: true,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                          },
                                        )
                                      : const SliverToBoxAdapter();
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: searchVisible,
                                builder: (context, searchOpen, _) {
                                  return BlocBuilder<
                                    BoutiqueBloc,
                                    BoutiqueState
                                  >(
                                    buildWhen: (p, c) {
                                      return p
                                                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                      'withoutFilter' +
                                                      '${(widget.category ?? '')}']
                                                  ?.paginationStatus !=
                                              c
                                                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                      'withoutFilter' +
                                                      '${(widget.category ?? '')}']
                                                  ?.paginationStatus ||
                                          p.isExpandedForListingPage !=
                                              c.isExpandedForListingPage ||
                                          p.appliedFiltersByUser[key] !=
                                              c.appliedFiltersByUser[key] ||
                                          p.getProductFiltersStatus[key] !=
                                              c.getProductFiltersStatus[key] ||
                                          p
                                                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                      '${(widget.category ?? '')}']
                                                  ?.paginationStatus !=
                                              c
                                                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                      '${(widget.category ?? '')}']
                                                  ?.paginationStatus ||
                                          p.cashedOrginalBoutique !=
                                              c.cashedOrginalBoutique;
                                    },
                                    builder: (context, state) {
                                      //  String? currentAppliedFilterSllug =
                                      //     "null";
                                      isExpanded =
                                          state.isExpandedForListingPage ??
                                          false;
                                      //bool isOneProductForPrefetch = false;

                                      /*  if ((appliedFiltersByUser?.filters
                                                      ?.categories?.length ??
                                                  0) >
                                              0) {
                                            currentAppliedFilterSllug =
                                                appliedFiltersByUser?.filters
                                                    ?.categories?[0].slug;
                                          } else if ((appliedFiltersByUser
                                                      ?.filters
                                                      ?.brands
                                                      ?.length ??
                                                  0) >
                                              0) {
                                            currentAppliedFilterSllug =
                                                appliedFiltersByUser
                                                    ?.filters?.brands?[0].slug;
                                          } else if ((appliedFiltersByUser
                                                          ?.filters
                                                          ?.boutiques
                                                          ?.length ??
                                                      0) >
                                                  0 &&
                                              widget.fromSearch) {
                                            currentAppliedFilterSllug =
                                                "search";
                                          } else if ((((appliedFiltersByUser
                                                              ?.filters
                                                              ?.attributes
                                                              ?.isNullOrEmpty ??
                                                          false)
                                                      ? 0
                                                      : appliedFiltersByUser
                                                          ?.filters
                                                          ?.attributes?[0]
                                                          .options
                                                          ?.length) ??
                                                  0) >
                                              0) {
                                            currentAppliedFilterSllug =
                                                ((appliedFiltersByUser
                                                            ?.filters
                                                            ?.attributes
                                                            ?.isNullOrEmpty ??
                                                        false)
                                                    ? "null"
                                                    : appliedFiltersByUser
                                                        ?.filters
                                                        ?.attributes?[0]
                                                        .options?[0]);
                                          } else if ((appliedFiltersByUser
                                                      ?.filters
                                                      ?.colors
                                                      ?.length ??
                                                  0) >
                                              0) {
                                            currentAppliedFilterSllug =
                                                appliedFiltersByUser
                                                    ?.filters?.colors?[0];
                                          } else if (appliedFiltersByUser
                                                  ?.filters?.prices?.minPrice !=
                                              null) {
                                            currentAppliedFilterSllug =
                                                "${appliedFiltersByUser?.filters?.prices?.minPrice}-${appliedFiltersByUser?.filters?.prices?.maxPrice}";
                                          } else {
                                            currentAppliedFilterSllug = "null";
                                          }*/
                                      /* if (!isExpanded &&
                                                  (appliedFiltersByUser?.filters?.searchText?.length ?? 0) <
                                                      3 &&
                                                  ((appliedFiltersByUser?.filters?.categories?.length ?? 0) +
                                                              (appliedFiltersByUser
                                                                      ?.filters
                                                                      ?.brands
                                                                      ?.length ??
                                                                  0) +
                                                              (appliedFiltersByUser
                                                                      ?.filters
                                                                      ?.colors
                                                                      ?.length ??
                                                                  0) +
                                                              (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ??
                                                                  0) ==
                                                          1 &&
                                                      !widget.fromSearch &&
                                                      (appliedFiltersByUser?.filters?.prices?.minPrice ==
                                                          null)) ||
                                              ((appliedFiltersByUser?.filters?.categories?.length ?? 0) +
                                                          (appliedFiltersByUser
                                                                  ?.filters
                                                                  ?.brands
                                                                  ?.length ??
                                                              0) +
                                                          (appliedFiltersByUser?.filters?.colors?.length ?? 0) +
                                                          (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ?? 0) ==
                                                      0 &&
                                                  !widget.fromSearch &&
                                                  (appliedFiltersByUser?.filters?.prices?.minPrice != null))) {
                                            if (((state
                                                            .getProductListingWithFiltersPaginationWithPrefetchModels[
                                                                '${widget.boutiqueSlug}' +
                                                                    '${currentAppliedFilterSllug}' +
                                                                    '${(widget.category ?? '')}']
                                                            ?.items
                                                            .length ??
                                                        0) <
                                                    2 &&
                                                state
                                                        .getProductListingWithFiltersPaginationWithPrefetchModels[
                                                            '${widget.boutiqueSlug}' +
                                                                '${currentAppliedFilterSllug}' +
                                                                '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.success &&
                                                state
                                                        .getProductListingWithFiltersPaginationWithPrefetchModels[
                                                            '${widget.boutiqueSlug}' +
                                                                '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.success)) {
                                              isOneProductForPrefetch = true;
                                            }
                                          }*/

                                      return SliverAppBar(
                                        pinned: !isExpanded,
                                        surfaceTintColor: Colors.transparent,
                                        backgroundColor: colorScheme.white,
                                        automaticallyImplyLeading: false,
                                        titleSpacing: 0,
                                        toolbarHeight: isExpanded
                                            ? 860.h
                                            : (((state
                                                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                  '${(widget.category ?? '')}']
                                                              ?.items
                                                              .length ==
                                                          1 &&
                                                      state
                                                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                  '${(widget.category ?? '')}']
                                                              ?.paginationStatus ==
                                                          PaginationStatus
                                                              .success))) ||
                                                  (state
                                                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                  '${(widget.category ?? '')}']
                                                              ?.items
                                                              .length ==
                                                          1 &&
                                                      state
                                                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                  '${(widget.category ?? '')}']
                                                              ?.paginationStatus ==
                                                          PaginationStatus
                                                              .success)
                                            ? 35.h
                                            : state.cashedOrginalBoutique
                                            ? 115.h
                                            : state
                                                      .appliedFiltersByUser[key]
                                                      ?.filters ==
                                                  null
                                            ? 115.h
                                            : 145.h,
                                        flexibleSpace: StackedFiltersList(
                                          expandingFiltersStack:
                                              expandingFiltersStack,
                                          key: TestVariables.kTestMode
                                              ? const Key(
                                                  WidgetsKeys
                                                      .productListFilterKey,
                                                )
                                              : null,
                                          textController: controller,
                                          hideTitle: false,
                                          fromSearch: fromSearch!,
                                          searchText: controller.text.length > 2
                                              ? controller.text
                                              : null,
                                          filterPageExpanded:
                                              state.isExpandedForListingPage ??
                                              false,
                                          closeFilterPage: () {
                                            boutiqueBloc.add(
                                              AddIsExpandedForLidtingPageEvent(
                                                isExpandedForLidting: false,
                                              ),
                                            );
                                            ;
                                          },
                                          displayAppliedFiltersOnly:
                                              (state
                                                          .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                              '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                              '${(widget.category ?? '')}']
                                                          ?.items
                                                          .length ??
                                                      0) <
                                                  2 &&
                                              state
                                                      .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                          '${(widget.category ?? '')}']
                                                      ?.paginationStatus ==
                                                  PaginationStatus.success,
                                          category: widget.category,
                                          boutiqueSlug: widget.boutiqueSlug,
                                          controller: isExpanded
                                              ? scrollControllerFilter
                                              : null,
                                          onMoveToAnotherFiltersSection: (title) {
                                            timerForDisplayFilterSectionTitle
                                                ?.cancel();
                                            showTitleForFilterList.value =
                                                title;
                                            timerForDisplayFilterSectionTitle =
                                                Timer(
                                                  const Duration(seconds: 3),
                                                  () {
                                                    showTitleForFilterList
                                                            .value =
                                                        null;
                                                  },
                                                );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              isExpanded
                                  ? const SliverToBoxAdapter()
                                  : BlocBuilder<BoutiqueBloc, BoutiqueState>(
                                      buildWhen: (p, c) {
                                        bool rebuild =
                                            p
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        'withoutFilter' +
                                                        '${(widget.category ?? '')}']
                                                    ?.paginationStatus !=
                                                c
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        'withoutFilter' +
                                                        '${(widget.category ?? '')}']
                                                    ?.paginationStatus ||
                                            p.isExpandedForListingPage !=
                                                c.isExpandedForListingPage ||
                                            p.appliedFiltersByUser[key] !=
                                                c.appliedFiltersByUser[key] ||
                                            p.isGettingProductListingWithPaginationForAppearProduct !=
                                                c.isGettingProductListingWithPaginationForAppearProduct ||
                                            p.isGettingProductListingWithPagination !=
                                                c.isGettingProductListingWithPagination ||
                                            p
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        '${(widget.category ?? '')}']
                                                    ?.paginationStatus !=
                                                c
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        '${(widget.category ?? '')}']
                                                    ?.paginationStatus ||
                                            p.cashedOrginalBoutique !=
                                                c.cashedOrginalBoutique;

                                        if (rebuild) {
                                          gridViewKeyForRendering = UniqueKey();
                                        }
                                        return rebuild;
                                        // ||
                                        // (!widget.fromSearch &&
                                        //     p
                                        //             .getProductListingPaginationWithoutFiltersModel[
                                        //                 key]
                                        //             ?.paginationStatus !=
                                        //         c
                                        //             .getProductListingPaginationWithoutFiltersModel[
                                        //                 key]
                                        //             ?.paginationStatus);
                                      },
                                      builder: (context, state) {
                                        isExpanded =
                                            state.isExpandedForListingPage ??
                                            false;
                                        if (kDebugMode)
                                          print(
                                            "///DDDDDDDDDDDDDDDDDDDDDDDDD************//${(((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}'] == null || state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']!.items.isNullOrEmpty) && state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                                '${(widget.category ?? '')}']?.paginationStatus != PaginationStatus.success)) || (state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${(widget.category ?? '')}']?.paginationStatus == PaginationStatus.loading && !state.cashedOrginalBoutique)}DDD////**/*//${'${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                    '${(widget.category ?? '')}'}DDDDDDDDDDDDDDDDDDDDD${state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + 'withoutFilter'
                                                    '${(widget.category ?? '')}']?.paginationStatus}",
                                          );
                                        // String? currentAppliedFilterSllug =
                                        //     "null";
                                        /* if (!isExpanded &&
                                                  !state
                                                      .isGettingProductListingWithPaginationForAppearProduct &&
                                                  (appliedFiltersByUser?.filters?.searchText?.length ?? 0) <
                                                      3 &&
                                                  ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ?? 0) == 1 &&
                                                      !widget.fromSearch &&
                                                      (appliedFiltersByUser?.filters?.prices?.minPrice ==
                                                          null)) ||
                                              ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ?? 0) == 0 &&
                                                  !widget.fromSearch &&
                                                  !isExpanded &&
                                                  (appliedFiltersByUser?.filters?.prices?.minPrice !=
                                                      null))) {
                                            if ((appliedFiltersByUser?.filters
                                                        ?.categories?.length ??
                                                    0) >
                                                0) {
                                            ///  currentAppliedFilterSllug =
                                               //   appliedFiltersByUser?.filters
                                                 //     ?.categories?[0].slug;
                                            } else if ((appliedFiltersByUser
                                                        ?.filters
                                                        ?.brands
                                                        ?.length ??
                                                    0) >
                                                0) {
                                              currentAppliedFilterSllug =
                                                  appliedFiltersByUser?.filters
                                                      ?.brands?[0].slug;
                                            } else if ((((appliedFiltersByUser
                                                                ?.filters
                                                                ?.attributes
                                                                ?.isNullOrEmpty ??
                                                            false)
                                                        ? 0
                                                        : appliedFiltersByUser
                                                            ?.filters
                                                            ?.attributes?[0]
                                                            .options
                                                            ?.length) ??
                                                    0) >
                                                0) {
                                              currentAppliedFilterSllug =
                                                  ((appliedFiltersByUser
                                                              ?.filters
                                                              ?.attributes
                                                              ?.isNullOrEmpty ??
                                                          false)
                                                      ? "null"
                                                      : appliedFiltersByUser
                                                          ?.filters
                                                          ?.attributes?[0]
                                                          .options?[0]);
                                            } else if ((appliedFiltersByUser
                                                        ?.filters
                                                        ?.colors
                                                        ?.length ??
                                                    0) >
                                                0) {
                                              appliedFiltersByUser
                                                  ?.filters?.colors?[0];
                                            } else if (appliedFiltersByUser
                                                    ?.filters
                                                    ?.prices
                                                    ?.minPrice !=
                                                null) {
                                              currentAppliedFilterSllug =
                                                  "${appliedFiltersByUser?.filters?.prices?.minPrice}-${appliedFiltersByUser?.filters?.prices?.maxPrice}";
                                            } else {
                                              currentAppliedFilterSllug =
                                                  "null";
                                            }
                                          }*/
                                        /* if ((!isExpanded &&
                                              !state
                                                  .isGettingProductListingWithPaginationForAppearProduct &&
                                              (widget.fromSearch &&
                                                  ((appliedFiltersByUser
                                                              ?.filters
                                                              ?.boutiques
                                                              ?.length ??
                                                          0) ==
                                                      0) &&
                                                  prefsRepository
                                                      .getTagsInUrlToFilter
                                                      .isNullOrEmpty) &&
                                              (appliedFiltersByUser?.filters?.searchText?.length ?? 0) <
                                                  3 &&
                                              controller.text.length < 3 &&
                                              ((appliedFiltersByUser
                                                                  ?.filters
                                                                  ?.categories
                                                                  ?.length ??
                                                              0) +
                                                          (appliedFiltersByUser
                                                                  ?.filters
                                                                  ?.brands
                                                                  ?.length ??
                                                              0) +
                                                          (appliedFiltersByUser
                                                                  ?.filters
                                                                  ?.colors
                                                                  ?.length ??
                                                              0) +
                                                          (((appliedFiltersByUser
                                                                          ?.filters
                                                                          ?.attributes
                                                                          ?.isNullOrEmpty ??
                                                                      false)
                                                                  ? 0
                                                                  : appliedFiltersByUser
                                                                      ?.filters
                                                                      ?.attributes?[0]
                                                                      .options
                                                                      ?.length) ??
                                                              0) ==
                                                      0 &&
                                                  (appliedFiltersByUser?.filters?.prices?.minPrice == null)))) {
                                            //   currentAppliedFilterSllug = "Empty";
                                            boutiqueBloc.add(
                                                IscashedOreiginBotiqueEvent(
                                                    iscashedOreiginBotique:
                                                        true));
                                          }*/

                                        /* if (state.getProductListingWithFiltersPaginationWithPrefetchModels[
                                                      "${widget.boutiqueSlug}" +
                                                          "${currentAppliedFilterSllug}" +
                                                          "${widget.category ?? ""}"] !=
                                                  null &&
                                              (state
                                                          .getProductListingWithFiltersPaginationWithPrefetchModels[
                                                              "${widget.boutiqueSlug}" +
                                                                  "${currentAppliedFilterSllug}" +
                                                                  "${widget.category ?? ""}"]
                                                          ?.items
                                                          .length ??
                                                      0) >
                                                  0) {
                                            products = state
                                                .getProductListingWithFiltersPaginationWithPrefetchModels[
                                                    "${widget.boutiqueSlug}" +
                                                        "${currentAppliedFilterSllug}" +
                                                        "${widget.category ?? ""}"]!
                                                .items;

                                            return SliverPadding(
                                              key: TestVariables.kTestMode
                                                  ? Key(WidgetsKeys
                                                      .productsListKey)
                                                  : gridViewKeyForRendering,
                                              padding: EdgeInsets.only(
                                                  top: 10.h),
                                              sliver: SliverGrid(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 200.w / 350,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 15,
                                                ),
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  addRepaintBoundaries: true,
                                                  childCount: products.length,
                                                  (BuildContext context,
                                                      int index) {
                                                    return InkWell(
                                                      onTap: () async {
                                                        Future.delayed(
                                                          Duration(
                                                              milliseconds:
                                                                  100),
                                                        ).then(
                                                          (value) {
                                                            FirebaseAnalyticsService
                                                                .logEventForViewedProduct(
                                                              eventName:
                                                                  AnalyticsEventsConst
                                                                      .viewedProduct,
                                                              productId: products[
                                                                      index]
                                                                  .productId
                                                                  .toString(),
                                                              productName:
                                                                  products[
                                                                          index]
                                                                      .name
                                                                      .toString(),
                                                              productCategoriesId:
                                                                  products[
                                                                          index]
                                                                      .categories
                                                                      ?.map(
                                                                        (e) => e
                                                                            .id
                                                                            .toString(),
                                                                      )
                                                                      .toList(),
                                                            );
                                                          },
                                                        );
                                                        ////////////////////////////
                                                        FirebaseAnalyticsService
                                                            .logEventForSession(
                                                          eventName:
                                                              AnalyticsEventsConst
                                                                  .buttonClicked,
                                                          executedEventName:
                                                              AnalyticsExecutedEventNameConst
                                                                  .chooseProductButton,
                                                        );

                                                        // pushOverscrollRoute(
                                                        //     context: context,
                                                        //     transitionDuration : Duration(milliseconds : 250),
                                                        //     reverseTransitionDuration : Duration(milliseconds : 400),
                                                        //     child: ProductDetailsPage(
                                                        //       productItem: state
                                                        //           .getProductListingWithoutFiltersModel!
                                                        //           .data!
                                                        //           .products![index]
                                                        //     ),
                                                        //     workNormally: true,
                                                        //     withRoundedCorners: true,
                                                        //     isArabicLanguage: LanguageService.rtl,
                                                        //     dragToPopDirection: DragToPopDirection.toBottom,
                                                        //     scrollToPopOption: ScrollToPopOption.start,
                                                        //     fullscreenDialog: true);
                                                        homeBloc.add(
                                                            ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                                isStatusInitaial:
                                                                    true));

                                                        Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    300),
                                                            () => Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (ctx) =>
                                                                            ProductDetailsPage(
                                                                      productItem:
                                                                          products[
                                                                              index],
                                                                    ),
                                                                  ),
                                                                ));
                                                      },
                                                      child: _productItem(
                                                        index: index,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }*/

                                        if (((state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            'withoutFilter' +
                                                            '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.loading) &&
                                                state
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        'withoutFilter' +
                                                        '${(widget.category ?? '')}']!
                                                    .items
                                                    .isNullOrEmpty &&
                                                state.cashedOrginalBoutique) ||
                                            (state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            'withoutFilter' +
                                                            '${(widget.category ?? '')}'] ==
                                                        const PaginationModel.init() &&
                                                    state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            'withoutFilter' +
                                                            '${(widget.category ?? '')}']!
                                                        .items
                                                        .isNullOrEmpty) &&
                                                !state
                                                    .isGettingProductListingWithPagination) {
                                          return const ProductListingLoading();
                                        }
                                        if ((state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                            '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.failure &&
                                                state
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                        '${(widget.category ?? '')}']!
                                                    .items
                                                    .isNullOrEmpty) ||
                                            (state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.failure &&
                                                !state.cashedOrginalBoutique)) {
                                          return SliverToBoxAdapter(
                                            child: Center(
                                              child: MyTextWidget(
                                                "${LocaleKeys.no_internet_connected.tr()}",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        // String key = (widget
                                        //             .boutiqueSlug ??
                                        //         '') +
                                        //     (widget.category ??
                                        //         '');
                                        if ((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                        '${(widget.category ?? '')}'] ==
                                                    null ||
                                                state
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                        '${(widget.category ?? '')}']!
                                                    .items
                                                    .isNullOrEmpty) &&
                                            state
                                                    .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                        '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                            '${(widget.category ?? '')}']
                                                    ?.paginationStatus ==
                                                PaginationStatus.success) {
                                          return SliverToBoxAdapter(
                                            child: Center(
                                              child: MyTextWidget(
                                                "${LocaleKeys.no_products_found.tr()}",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        if ((((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                            '${(widget.category ?? '')}'] ==
                                                        null ||
                                                    state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                            '${(widget.category ?? '')}']!
                                                        .items
                                                        .isNullOrEmpty) &&
                                                state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                                '${(widget.category ?? '')}']
                                                        ?.paginationStatus !=
                                                    PaginationStatus
                                                        .success)) ||
                                            (state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.loading &&
                                                !state.cashedOrginalBoutique) ||
                                            (state
                                                        .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                            '${(widget.category ?? '')}']
                                                        ?.paginationStatus ==
                                                    PaginationStatus.loading) &&
                                                !state
                                                    .isGettingProductListingWithPagination) {
                                          if (kDebugMode)
                                            print(
                                              "DDDDDDDDDDDDDDDDDDDDDDDDD************//${(((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}'] == null || state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']!.items.isNullOrEmpty) && state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                                  '${(widget.category ?? '')}']?.paginationStatus != PaginationStatus.success)) || (state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${(widget.category ?? '')}']?.paginationStatus == PaginationStatus.loading && !state.cashedOrginalBoutique)}DDD${'${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                      '${(widget.category ?? '')}'}DDDDDDDDDDDDDDDDDDDDD${state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                      '${(widget.category ?? '')}']?.paginationStatus}",
                                            );
                                          return ProductListingLoading(
                                            key: TestVariables.kTestMode
                                                ? const Key(
                                                    WidgetsKeys
                                                        .boutiqueProductListingLoadingKey,
                                                  )
                                                : null,
                                          );
                                        }

                                        products = [];

                                        if (state
                                                .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                '${(widget.category ?? '')}'] !=
                                            null) {
                                          products = state
                                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                  '${(widget.category ?? '')}']!
                                              .items;
                                          if (products.isEmpty) {
                                            return SliverToBoxAdapter(
                                              child: Center(
                                                child: MyTextWidget(
                                                  "${LocaleKeys.no_products_found.tr()}",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }

                                        //                                                     else if(!widget.fromSearch){
                                        //                                                       if ((((state
                                        //                                                                       .getProductListingPaginationWithoutFiltersModel[
                                        //                                                                           key]
                                        //                                                                       ?.items
                                        //                                                                       .isNullOrEmpty ??
                                        //                                                                   true)) ||
                                        //                                                               (state.getProductListingPaginationWithoutFiltersModel[
                                        //                                                                       key] ==
                                        //                                                                   null)) &&
                                        //                                                           state.getProductListingWithFiltersPaginationModels
                                        //                                                                   ?.paginationStatus ==
                                        //                                                               PaginationStatus
                                        //                                                                   .loading) {
                                        // return ProductListingLoading();
                                        // }
                                        // products = state
                                        //     .getProductListingPaginationWithoutFiltersModel[
                                        // key]
                                        //     ?.items ??
                                        // [];
                                        //
                                        //
                                        //
                                        //                                       }

                                        return SliverPadding(
                                          key: gridViewKeyForRendering,
                                          padding: EdgeInsets.only(top: 10.h),
                                          sliver: SliverGrid(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio:
                                                      1.sw / ((392.w) * 2),
                                                  crossAxisSpacing: 10.w,
                                                  mainAxisSpacing: 15.h,
                                                ),
                                            delegate: SliverChildBuilderDelegate(
                                              addSemanticIndexes: false,

                                              addAutomaticKeepAlives: false,
                                              addRepaintBoundaries: false,
                                              childCount: products.length,
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return InkWell(
                                                  key: TestVariables.kTestMode
                                                      ? Key(
                                                          '${WidgetsKeys.productsListKey}$index',
                                                        )
                                                      : null,
                                                  onTap: () {
                                                    homeBloc.add(
                                                      const ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                        isStatusInitaial: true,
                                                      ),
                                                    );
                                                    homeBloc.add(
                                                      AddCurrentSelectedColorEvent(
                                                        currentSelectedColor: 0,
                                                        productSlug:
                                                            products[index].slug
                                                                .toString(),
                                                      ),
                                                    );

                                                    Future.delayed(
                                                      const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      () {
                                                        if (!mounted) return;
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                ProductDetailsPageNew(
                                                                  productItem:
                                                                      products[index],
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: _productItem(
                                                    index: index,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              BlocBuilder<BoutiqueBloc, BoutiqueState>(
                                buildWhen: (previous, current) =>
                                    previous
                                        .isGettingProductListingWithPagination !=
                                    current
                                        .isGettingProductListingWithPagination,
                                builder: (context, state) {
                                  if (state
                                      .isGettingProductListingWithPagination) {
                                    return SliverToBoxAdapter(
                                      child: Center(child: TrydosLoader()),
                                    );
                                  }
                                  return const SliverToBoxAdapter();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                // }),
              ),
              Positioned(
                top: 10.h,
                child: Stack(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: showTitleForFilterList,
                      builder: (context, title, _) {
                        return Visibility(
                          visible: title != null,
                          child: Stack(
                            children: [
                              Container(
                                height: 40.h,
                                width: 140.w,
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(15.r),
                                  color: const Color(0xff505050),
                                ),
                                child: Center(
                                  child: MyTextWidget(
                                    title ?? '',
                                    style: textTheme.titleLarge?.rq.copyWith(
                                      color: colorScheme.white,
                                      height: 18 / 14,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 140.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 3),
                                      blurRadius: 6,
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.16),
                                      inset: true,
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
                ),
              ),
              shadowForPanel(),
              panelWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /*  void changeVariationWhenNotAvailable(
      {required productDetail.Variation? currentVariation,
      required String productId,
      required int tapIndex,
      required List<String> sizesForEachColor,
      required productDetail.Product? product,
      required filter_products.Products products}) async {
    if (kDebugMode) print(
        "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss${currentVariation?.qty}sssssssssssssss4${currentVariation?.type}");
    changeVariationIfQtyZero = false;

    if (currentVariation?.qty != null && currentVariation?.qty == 0) {
      if (kDebugMode) print(
          "s223333333333322ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss4${currentVariation?.type}");

      currentVariation =
          product?.variation?.firstWhere((element) => (element.qty ?? 0) > 0);
      if (currentVariation!.type!.contains("-")) {
        int index = products.syncColorImages?.indexWhere((element) =>
                element.colorName ==
                (currentVariation!.type!.split("-").toList()[0])) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: index != -1 ? index : 0,
                productId: productId)));
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: (currentVariation!.type!.split("-").toList()[1]))));
      } else if ((products.syncColorImages?.length ?? 0) > 0) {
        currentVariation =
            product?.variation?.firstWhere((element) => (element.qty ?? 0) > 0);
        int index = products.syncColorImages?.indexWhere(
                (element) => element.colorName == (currentVariation!.type)) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: index != -1 ? index : 0,
                productId: productId)));
      } else {
        if (kDebugMode) print(
            "s222ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss4${currentVariation?.type}");

        currentSelectedColorAfterChangeVariant = currentSelectedColor;
        currentVariation =
            product?.variation?.firstWhere((element) => (element.qty ?? 0) > 0);
        if (kDebugMode) print(
            "s222ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss4${currentVariation?.type}");

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(
                AddCurrentColorSizeEvent(choice_1: (currentVariation!.type))));
      }
    } else {
      if (currentVariation!.type!.contains("-")) {
        homeBloc.add(AddCurrentColorSizeEvent(
            choice_1: (currentVariation.type!.split("-").toList()[1])));
      } else if (((products.syncColorImages?.length ?? 0) == 0)) {
        if (kDebugMode) print(
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaazzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz4${currentVariation.type}");
        await Future.delayed(
            Duration(milliseconds: 600),
            () => homeBloc.add(
                AddCurrentColorSizeEvent(choice_1: (currentVariation?.type))));
      }

      currentSelectedColorAfterChangeVariant = currentSelectedColor;
    }
    await Future.delayed(
        Duration(milliseconds: 1000),
        () => homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
            isChangedvariationWhenQtyZero: true)));
  }*/

  Widget shadowForPanel() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForColorImages,
      builder: (context, isShowShadowForPanel, _) {
        return !isShowShadowForPanel
            ? const SizedBox.shrink()
            : InkWell(
                onTap: () {
                  showShadowForColorImages.value = false;
                  Future.delayed(const Duration(microseconds: 300), () {
                    colorImagesPanelController.close();
                    showShadowForColorImages.value = false;
                  });
                },
                child: Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: const Color.fromRGBO(29, 29, 29, 0.6),
                ),
              );
      },
    );
  }

  Widget panelWidget() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForColorImages,
      builder: (context, isShowPanel, _) {
        return Positioned(
          bottom: 0.h,
          child: Container(
            width: 1.sw,
            height: isShowPanel ? (1.sh - 100.h) : 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
            ),
            child: SlidingUpPanel(
              controller: colorImagesPanelController,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
              onPanelClosed: () {
                showShadowForColorImages.value = false;
              },
              onPanelOpened: () {},
              minHeight: 0,
              maxHeight: (1.sh - 100.h),
              panelBuilder: (sc) => panelBuilderContent(sc),
            ),
          ),
        );
      },
    );
  }

  Widget panelBuilderContent(ScrollController sc) {
    final ValueNotifier<bool> visibleRedeem = ValueNotifier(false);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30.r)),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.w),
              height: 2.h,
              width: 40.w,
              decoration: const BoxDecoration(color: Color(0xffC4C2C2)),
            ),
            SizedBox(height: 5.h),
            ValueListenableBuilder<bool>(
              valueListenable: finishRedeem,
              builder: (context, _finishRedeem, _) => ValueListenableBuilder<int>(
                valueListenable: tapIndexToShowColorImages,
                builder: (context, _tapIndexToShowColorImages, _) =>
                    // الحدّ الأعلى مطلوب أيضاً: القائمة قد تنكمش (فلترة/تحديث)
                    // بينما المؤشّر ما يزال على عنصر قديم.
                    _tapIndexToShowColorImages < 0 ||
                        _tapIndexToShowColorImages >= products.length
                    ? const SizedBox.shrink()
                    : Expanded(
                        child: GridView.builder(
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false,
                          addSemanticIndexes: false,
                          cacheExtent: 100,
                          controller: sc,
                          itemCount: products[_tapIndexToShowColorImages]
                              .syncColorImages
                              ?.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 5.h,
                                crossAxisSpacing: 5.w,
                                childAspectRatio: 1.sw / ((392.w) * 2),
                                crossAxisCount: 2,
                              ),
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              GetIt.I<HomeBloc>().add(
                                const ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                  isStatusInitaial: true,
                                ),
                              );
                              homeBloc.add(
                                AddCurrentSelectedColorEvent(
                                  currentSelectedColor: index,
                                  productSlug:
                                      products[_tapIndexToShowColorImages].slug
                                          .toString(),
                                ),
                              );

                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  if (!mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => ProductDetailsPageNew(
                                        productItem:
                                            products[_tapIndexToShowColorImages],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: ProductColorPanal(
                              colorImages:
                                  products[_tapIndexToShowColorImages]
                                      .syncColorImages?[index]
                                      .images
                                      ?.map((e) => e.filePath ?? "")
                                      .toList() ??
                                  [],
                              visibleRedeem: visibleRedeem,
                              productItem: products[_tapIndexToShowColorImages],
                              tapIndexToAddProductToCart:
                                  tapIndexToAddProductToCart,
                              itemIndex: _tapIndexToShowColorImages,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productItem({
    //required Tuple2<int, int> slidingMode,
    required int index,
  }) {
    return /*!displayImageColors && !widget.fromSearch
        ? DelayedDisplay(
            delay: Duration(milliseconds: 300),
            child: ProductItem(
              displayImageColors: displayImageColors,
              tapIndexToAddProductToCart: tapIndexToAddProductToCart,
              key: TestVariables.kTestMode
                  ? Key('${WidgetsKeys.productInBoutiqueListKey}$index')
                  : null,
              slidingModeItem: slidingMode,
              productItem: products[index],
              itemIndex: index,
              setThisEnabled: (int index, int slideMode) {
                setThisEnabledNotifier.value = Tuple2(index, slideMode);
              },
            ))*/ ProductItem(
      productItem: products[index],
      itemIndex: index,
      tapIndexToShowColorImages: tapIndexToShowColorImages,
      showShadowForColorImages: showShadowForColorImages,
      colorImagesPanelController: colorImagesPanelController,
      finishRedeem: finishRedeem,
      displayImageColors: true,
      tapIndexToAddProductToCart: tapIndexToAddProductToCart,
      key: TestVariables.kTestMode
          ? Key('${WidgetsKeys.productInBoutiqueListKey}$index')
          : null,
      /*  slidingModeItem: slidingMode,
      productItem: products[index],
      itemIndex: index,
      setThisEnabled: (int index, int slideMode) {
        setThisEnabledNotifier.value = Tuple2(index, slideMode);
      },*/
    );
  }
}
