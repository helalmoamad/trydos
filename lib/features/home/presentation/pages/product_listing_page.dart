import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as geminis;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/animated_search_bar/animated_search_bar.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart'
    as productDetail;

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
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/pages/cart_page_new.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import 'package:trydos/features/search/presentation/widgets/search_with_image_related_gemini.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/svg_network_widget.dart';
import '../../data/models/get_home_boutiqes_model.dart' as boutiques;
import '../manager/homeBloc/home_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../widgets/product_listing/product_item.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../widgets/product_listing/product_listing_filter_list.dart';
import '../widgets/product_listing/product_listing_loading.dart';

class ProductListingPage extends StatefulWidget {
  final String boutiqueSlug;
  final String? category;
  final String? boutiqueIcon;
  final String? boutiqueDescription;
  final String? boutiqueFirstBanner;
  final bool withSlidingImages;
  final bool? fromNotificationCategory;
  final List<boutiques.BunnerBoutique>? banner;
  final TextEditingController? controllerFormSearchPage;
  final bool fromSearch;

  final bool fromBackground;
  final GetProductFiltersModel? getProductFiltersModel;
  final ValueNotifier<bool>? isShowPanelForVerified;

  const ProductListingPage({
    super.key,
    required this.boutiqueSlug,
    this.fromBackground = false,
    this.getProductFiltersModel,
    this.boutiqueDescription,
    this.isShowPanelForVerified,
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
  double? _previousOffset;
  final FocusNode focusNode = FocusNode();
  bool displayImageColors = false;
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);

  final ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final ValueNotifier<bool> loadingForRquestProductDetails =
      ValueNotifier(false);
  final ValueNotifier<bool> searchVisible = ValueNotifier(true);
  final ValueNotifier<bool> isShowPanelForVerified = ValueNotifier(false);
  final TextEditingController controller = TextEditingController();
  Timer? timerForDisplayFilterSectionTitle;
  final GlobalKey htmlDescriptionKey = GlobalKey();
  final ValueNotifier<double> htmlDescriptionHeight = ValueNotifier(0);
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final ValueNotifier<bool> fromSearchListing = ValueNotifier(false);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();

  final ValueNotifier<String?> productNotAvailableNotifier =
      ValueNotifier(null);
  bool isExpanded = false;
  bool changeAppearSizeForProduct = true;
  bool delayDisplay = true;
  int currentSelectedColor = -1;

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  bool? fromSearch;
  SpeechToText _speechToText = SpeechToText();

  final ValueNotifier<bool> isRecordeForSearchWithMic = ValueNotifier(false);

  bool itExpendForFirst = true;
  String key = '';
  String keyWithoutFilter = '';
  Filter? prefAppliedFilters;
  Key gridViewKeyForRenderingForTheFiveFilters = UniqueKey();
  Key gridViewKeyForRendering = UniqueKey();
  bool _speechEnabled = false;

  List<filter_products.Products> products = [];
  List<String> sizesForSearch = [
    "2xl",
    "34 eu",
    "38eu",
    "39.5eu",
    "3xl",
    "41eu",
    "42eu",
    "44eu",
    "45eu",
    "46eu",
    "4xl",
    "5xl",
    "l",
    "m",
    "s",
    "s/m",
    "xl",
    "xs",
    "xxl"
  ];
  List<String> colorsCodeForSearch = [
    "#000000",
    "#0000ff",
    "#ffff00",
    "#228b22",
    "#a52a2a",
    "#ffffff"
  ];
  List<String> colorsNameForSearch = [
    "أسود",
    "ازرق",
    "اصفر",
    "اخضر",
    "احمر",
    "ابيض"
  ];
  List<String> constWordToRemoveItFromSearch = [
    "قياس",
    "حجم",
    "لون",
    "اللون",
    "الالوان"
  ];
  void _startListening() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    await _speechToText.listen(
      listenFor: Duration(seconds: 7),
      onResult: (result) {
        if (result.recognizedWords.replaceAll(" ", "").length > 2) {
          resetSearchAfterSearchingWhileRemoveSearch = true;

          List<String>? colorsFilter = [];
          List<String> listSearchTextWithoutConstWord =
              result.recognizedWords.split(" ").toList();
          String searchText = "";
          List<String>? sizesFilter = [];

          List<String> listOfSearchText =
              result.recognizedWords.split(" ").toList();
          for (var i = 0; i < colorsNameForSearch.length; i++) {
            if (listOfSearchText.contains(colorsNameForSearch[i])) {
              colorsFilter.add(colorsCodeForSearch[i]);
              listSearchTextWithoutConstWord.remove(colorsNameForSearch[i]);
            }
          }

          for (var i = 0; i < sizesForSearch.length; i++) {
            if (listOfSearchText.contains(sizesForSearch[i])) {
              sizesFilter.add(sizesForSearch[i]);
              listSearchTextWithoutConstWord.remove(sizesForSearch[i]);
            }
          }
          for (var i = 0; i < constWordToRemoveItFromSearch.length; i++) {
            listSearchTextWithoutConstWord
                .remove(constWordToRemoveItFromSearch[i]);
          }
          listSearchTextWithoutConstWord
              .forEach((element) => searchText = searchText + " " + element);
          controller.text = result.recognizedWords;
          Filter filters = BlocProvider.of<BoutiqueBloc>(context)
                  .state
                  .choosedFiltersByUser[
                      widget.boutiqueSlug + (widget.category ?? "")]
                  ?.filters ??
              Filter();
          BlocProvider.of<BoutiqueBloc>(context).add(ChangeSelectedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              fromHomePageSearch: widget.fromSearch,
              filtersChoosedByUser: GetProductFiltersModel(
                  filters: filters.copyWithSaveOtherField(
                prices: filters.prices,
                searchText: searchText,
              ))));
          BlocProvider.of<BoutiqueBloc>(context).add(ChangeAppliedFiltersEvent(
            boutiqueSlug: widget.boutiqueSlug,
            category: widget.category,
            filtersAppliedByUser: GetProductFiltersModel(
                filters: filters.copyWithSaveOtherField(
              prices: filters.prices,
              searchText: searchText,
            )),
          ));
          BlocProvider.of<BoutiqueBloc>(context).add(
              AddSizeAndColorFilterinTextToSearchEvent(
                  sizeAndColorFilterinTextToSearch: {
                "size": sizesFilter,
                "color": colorsFilter
              }));

          BlocProvider.of<BoutiqueBloc>(context).add(
              GetProductsWithFiltersEvent(
                  offset: 1,
                  boutiqueSlug: widget.boutiqueSlug,
                  category: widget.category,
                  resetChoosedFilters: false,
                  fromSearch: widget.fromSearch,
                  searchText: searchText));
          _stopListening();
          return;
        }
      },
    );
    isRecordeForSearchWithMic.value = true;
    Future.delayed(
      Duration(seconds: 9),
      () => isRecordeForSearchWithMic.value = false,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();

    isRecordeForSearchWithMic.value = false;
  }

  @override
  void initState() {
    print("%%%%%%%%%${GetIt.I<PrefsRepository>().marketToken}0*");
    print("%%%%%%%%%${GetIt.I<PrefsRepository>().getFcmTokens}*");
    Future.delayed(Duration(seconds: 3), () {
      displayImageColors = true;
      delayDisplay = false;
    });
    itExpendForFirst = true;
    key = widget.boutiqueSlug + (widget.category ?? '');
    keyWithoutFilter = '${widget.boutiqueSlug}' +
        '${(!widget.fromSearch) ? 'withoutFilter' : ""}' +
        '${(widget.category ?? '')}';
    fromSearch = widget.fromSearch;
    searchVisible.value = false;
    if ((widget.controllerFormSearchPage?.text.length ?? 0) > 2) {
      controller.text = widget.controllerFormSearchPage?.text ?? "";
      resetSearchAfterSearchingWhileRemoveSearch = true;
    }
    Timer.periodic(Duration(milliseconds: 100), postFrameCallback);
    appBloc = BlocProvider.of<AppBloc>(context);
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
        isChangedvariationWhenQtyZero: false));
    homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
        isChangedvariationWhenQtyZero: false));
    boutiqueBloc.add(AddSizeAndColorFilterinTextToSearchEvent(
        sizeAndColorFilterinTextToSearch: {}));
    appBloc.add(HideBottomNavigationBar(false));
    appBloc.add(ShowOrHideBars(true));
    appBloc.add(ChangeIndexForSearch(1));
    // if (!widget.fromSearch) {
    //   homeBloc.add(GetProductsWithoutFiltersEvent(
    //     boutiqueSlug: widget.boutiqueSlug!,
    //     category: widget.category,
    //     offset: 1,
    //   ));
    // }
    // if (!widget.fromSearch) {
    //   homeBloc.add(GetProductFiltersEvent(
    //       getProductsFilterPreFetch: true,
    //       getWithoutFilter: true,
    //       cashedOrginalBoutique: true,
    //       fromHomePageSearch: widget.fromSearch,
    //       boutiqueSlug: widget.boutiqueSlug,
    //       category: widget.category,
    //       searchText: widget.fromSearch ? widget.searchText : null));
    // }
    if (boutiqueBloc.state.boutiquesThatDidPrefetch[key] == true &&
        homeBloc.boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[
                key] ==
            null) {
      homeBloc.boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[key] =
          true;
      boutiqueBloc.PrefetchProductsForFirstFiveFilter(
          boutiqueSlug: widget.boutiqueSlug,
          categorySlug: widget.category,
          filter: boutiqueBloc.state.getProductFiltersModel[key]?.filters);
    } else if (boutiqueBloc.state.boutiquesThatDidPrefetch[key] == null) {
      homeBloc.boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[key] =
          true;
    }
    if (widget.fromNotificationCategory ?? false) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          boutiqueBloc.add(ChangeAppliedFiltersEvent(
            boutiqueSlug: "search",
            resetAppliedFilters: true,
          ));
          boutiqueBloc.add(ChangeAppliedFiltersEvent(
              boutiqueSlug: "search",
              filtersAppliedByUser: widget.getProductFiltersModel));
          boutiqueBloc.add(GetProductsWithFiltersEvent(
              fromNotification: widget.fromNotificationCategory,
              boutiqueSlug: "search",
              offset: 1,
              fromSearch: true));
        },
      );
    }

    scrollController.addListener(() {
      if (boutiqueBloc.state.isExpandedForListingPage ?? false) return;
      // if (scrollController.position.pixels <= 80) {
      //   debugPrint(scrollController.position.pixels.toString());
      //   appBloc.add(ShowOrHideBars(true));
      // }
      // else if(filterPageExpanded.value){
      //   scrollController.jumpTo(80);
      // }
      if (setThisEnabledNotifier.value.item1 != -1) {
        setThisEnabledNotifier.value = Tuple2(-1, -1);
      }
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.7)) {
        if (boutiqueBloc.state.isGettingProductListingWithPagination) return;

        if (boutiqueBloc
            .state
            .getProductListingWithFiltersPaginationModels[
                '${widget.boutiqueSlug}' +
                    ((boutiqueBloc.state.cashedOrginalBoutique)
                        ? 'withoutFilter'
                        : "") +
                    '${(widget.category ?? '')}']!
            .hasReachedMax) {
          return;
        }
        boutiqueBloc.add(GetProductsWithFiltersEvent(
            context: context,
            fromNotification: widget.fromNotificationCategory,
            limit: 10,
            cashedOrginalBoutique: !widget.fromSearch,
            boutiqueSlug: widget.boutiqueSlug,
            getWithPagination: true,
            fromSearch: widget.fromSearch,
            category: widget.category,
            searchText: controller.text,
            offset: 2));
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.productListingScreen,
    );

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    appBloc.add(HideBottomNavigationBar(false));
    if (!widget.fromSearch) {
      appBloc.add(ChangeIndexForSearch(0));
    }
    _speechToText.cancel();
    focusNode.dispose();
    appBloc.add(ShowOrHideBars(true));
    scrollController.dispose();
    categoryBloc.add(ReplyFromGeminiEvent(
        fromSearch: false,
        sendRequestToGeminiStatus: SendRequestToGeminiStatus.success,
        theReplyFromGemini: ""));
    super.dispose();
  }

  void postFrameCallback(timer) {
    var context = htmlDescriptionKey.currentContext;
    if (context == null || htmlDescriptionHeight.value > 0) return;
    timer.cancel();
    htmlDescriptionHeight.value = context.size!.height;
  }

  bool resetSearchAfterSearchingWhileRemoveSearch = false;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return WillPopScope(
      onWillPop: () async {
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

        categoryBloc.add(ReplyFromGeminiEvent(
            fromSearch: false,
            sendRequestToGeminiStatus: SendRequestToGeminiStatus.success,
            theReplyFromGemini: ""));
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
          boutiqueBloc.add(ChangeAppliedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersAppliedByUser:
                  GetProductFiltersModel(filters: prefAppliedFilters)));
          controller.text = prefAppliedFilters!.searchText ?? "";

          resetSearchAfterSearchingWhileRemoveSearch = false;

          boutiqueBloc.add(
              AddIsExpandedForLidtingPageEvent(isExpandedForLidting: false));

          ////////////////////////////////////
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
          );
          return Future.value(false);
        } else {
          Navigator.of(context).pop();

          if (widget.fromSearch) {
            boutiqueBloc.add(ChangeSelectedFiltersEvent(
              requestToUpdateFilters: true,
              fromHomePageSearch: widget.fromSearch,
              boutiqueSlug: widget.boutiqueSlug,
              filtersChoosedByUser: GetProductFiltersModel(
                  filters:
                      boutiqueBloc.state.appliedFiltersByUser[key]?.filters),
            ));

            boutiqueBloc.add(
              ChangeAppliedFiltersEvent(
                boutiqueSlug: widget.boutiqueSlug,
                category: widget.category,
                resetAppliedFilters: true,
              ),
            );
          }

          ////////////////////////////////////
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
          );
        }

        return Future.value(false);
      },
      child: SafeArea(
        child: Material(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Scaffold(
                backgroundColor: Color(0xffF8F8F8),
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
                                  : AppBottomNavBar(
                                      isShowPanelForVerified:
                                          widget.isShowPanelForVerified ??
                                              isShowPanelForVerified);
                            });
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                body: NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.axis == Axis.horizontal)
                      return false;
                    final currentOffset = notification.metrics.pixels;
                    if (currentOffset >= 50 &&
                        !(boutiqueBloc.state.isExpandedForListingPage ??
                            false) &&
                        !widget.fromSearch &&
                        widget.boutiqueIcon != "") {
                      displayBoutiqueIconInAppBar.value = true;
                    } else {
                      displayBoutiqueIconInAppBar.value = false;
                    }
                    if (_previousOffset != null) {
                      // final distance = (currentOffset - _previousOffset!).abs();
                      // final time = notification
                      //     .dragDetails?.sourceTimeStamp?.inMilliseconds ??
                      //     0.000001;
                      // _velocity = distance / time;
                      (currentOffset - _previousOffset!).abs();
                      if (scrollController.position.pixels <= 80) {
                        _previousOffset = currentOffset;
                        return true;
                      }
                      // if (_velocity! <= (1.5e-8) && _velocity! >= (1.42e-8)) {
                      //   appBloc.add(ShowOrHideBars(true));
                      // } else {
                      //   appBloc.add(ShowOrHideBars(false));
                      // }
                    }
                    _previousOffset = currentOffset;
                    return true;
                  },
                  child: ValueListenableBuilder<Tuple2<int, int>>(
                      valueListenable: setThisEnabledNotifier,
                      builder: (context, slidingMode, _) {
                        return BlocBuilder<BoutiqueBloc, BoutiqueState>(
                            buildWhen: (p, c) =>
                                p.isExpandedForListingPage !=
                                c.isExpandedForListingPage,
                            builder: (context, homeState) {
                              return BlocBuilder<CategoryBloc, CategoryState>(
                                buildWhen: (p, c) => ((p
                                                .sendRequestToGeminiStatus !=
                                            c.sendRequestToGeminiStatus ||
                                        p.theReplyFromGemini !=
                                            c.theReplyFromGemini) &&
                                    c.fromSearchForSearchWithGemini == false),
                                builder: (context, state) {
                                  if ((state.theReplyFromGemini ?? "") != "" &&
                                      state.fromSearchForSearchWithGemini ==
                                          false) {
                                    List<String>? colorsFilter = [];
                                    List<String>
                                        listSearchTextWithoutConstWord = state
                                            .theReplyFromGemini!
                                            .split(" ")
                                            .toList();
                                    String searchText = "";
                                    List<String>? sizesFilter = [];
                                    List<String> listOfSearchText = state
                                        .theReplyFromGemini!
                                        .split(" ")
                                        .toList();
                                    for (var i = 0;
                                        i < colorsNameForSearch.length;
                                        i++) {
                                      if (listOfSearchText
                                          .contains(colorsNameForSearch[i])) {
                                        colorsFilter
                                            .add(colorsCodeForSearch[i]);
                                        listSearchTextWithoutConstWord
                                            .remove(colorsNameForSearch[i]);
                                      }
                                    }

                                    for (var i = 0;
                                        i < sizesForSearch.length;
                                        i++) {
                                      if (listOfSearchText
                                          .contains(sizesForSearch[i])) {
                                        sizesFilter.add(sizesForSearch[i]);
                                        listSearchTextWithoutConstWord
                                            .remove(sizesForSearch[i]);
                                      }
                                    }
                                    for (var i = 0;
                                        i <
                                            constWordToRemoveItFromSearch
                                                .length;
                                        i++) {
                                      listSearchTextWithoutConstWord.remove(
                                          constWordToRemoveItFromSearch[i]);
                                    }
                                    listSearchTextWithoutConstWord.forEach(
                                        (element) => searchText =
                                            searchText + " " + element);

                                    controller.text =
                                        state.theReplyFromGemini ?? "";
                                    Filter filters =
                                        BlocProvider.of<BoutiqueBloc>(context)
                                                .state
                                                .choosedFiltersByUser['search']
                                                ?.filters ??
                                            Filter();
                                    BlocProvider.of<BoutiqueBloc>(context).add(
                                        ChangeSelectedFiltersEvent(
                                            requestToUpdateFilters: false,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            category: widget.category,
                                            fromHomePageSearch:
                                                widget.fromSearch,
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                    filters: filters
                                                        .copyWithSaveOtherField(
                                              prices: filters.prices,
                                              searchText: searchText,
                                            ))));
                                    BlocProvider.of<BoutiqueBloc>(context)
                                        .add(ChangeAppliedFiltersEvent(
                                      boutiqueSlug: widget.boutiqueSlug,
                                      category: widget.category,
                                      filtersAppliedByUser:
                                          GetProductFiltersModel(
                                              filters: filters
                                                  .copyWithSaveOtherField(
                                        prices: filters.prices,
                                        searchText: searchText,
                                      )),
                                    ));
                                    boutiqueBloc.add(
                                        AddSizeAndColorFilterinTextToSearchEvent(
                                            sizeAndColorFilterinTextToSearch: {
                                          "size": sizesFilter,
                                          "color": colorsFilter
                                        }));

                                    BlocProvider.of<BoutiqueBloc>(context).add(
                                        GetProductsWithFiltersEvent(
                                            offset: 1,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            category: widget.category,
                                            resetChoosedFilters: false,
                                            fromSearch: widget.fromSearch,
                                            searchText: searchText));
                                  }
                                  if (!(homeState.isExpandedForListingPage ??
                                          false) &&
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
                                  }
                                  isExpanded =
                                      homeState.isExpandedForListingPage ??
                                          false;

                                  return CustomScrollView(
                                      key: TestVariables.kTestMode
                                          ? Key(WidgetsKeys
                                              .productListingScrollKey)
                                          : null,
                                      controller: scrollController,
                                      physics: homeState
                                                      .getProductFiltersModel[
                                                          key]
                                                      ?.filters
                                                      ?.totalSize ==
                                                  0 &&
                                              isExpanded
                                          ? NeverScrollableScrollPhysics()
                                          : ClampingScrollPhysics(),
                                      slivers: [
                                        ValueListenableBuilder<int>(
                                            valueListenable:
                                                tapIndexToAddProductToCart,
                                            builder: (context, tapIndex, _) {
                                              return SliverAppBar(
                                                  pinned: true,
                                                  backgroundColor:
                                                      colorScheme.white,
                                                  automaticallyImplyLeading:
                                                      false,
                                                  flexibleSpace:
                                                      ValueListenableBuilder<
                                                              bool>(
                                                          valueListenable:
                                                              searchVisible,
                                                          builder: (context,
                                                              searchOpen, _) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 5,
                                                                      left: 5),
                                                              child: tapIndex !=
                                                                      -1
                                                                  ? TrydosAppBar(
                                                                      appBarParams: AppBarParams(
                                                                          scrolledUnderElevation: 0,
                                                                          backIconColor: Colors.black,
                                                                          action: [
                                                                            LanguageService.rtl
                                                                                ? Spacer()
                                                                                : SizedBox.shrink(),
                                                                            Padding(
                                                                              padding: const EdgeInsetsDirectional.only(end: 10.0),
                                                                              child: BlocBuilder<HomeBloc, HomeState>(
                                                                                buildWhen: (previous, current) => previous.getProductDetailWithoutSimilarRelatedProductsStatus != current.getProductDetailWithoutSimilarRelatedProductsStatus || previous.updateItemInCartStatus != current.updateItemInCartStatus || previous.addItemInCartStatus != current.addItemInCartStatus || previous.deleteItemInCartStatus != current.deleteItemInCartStatus || previous.getCartItemsStatus != current.getCartItemsStatus,
                                                                                builder: (context, state) {
                                                                                  int qtyItemsInCart = 0;
                                                                                  state.cartCollection?.forEach(
                                                                                    (element) {
                                                                                      qtyItemsInCart = qtyItemsInCart + (element.quantity ?? 0);
                                                                                    },
                                                                                  );

                                                                                  return Container(
                                                                                    alignment: Alignment.center,
                                                                                    height: 40,
                                                                                    width: LanguageService.languageCode != "ar" ? 40 : 50,
                                                                                    child: InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.of(context).push(
                                                                                            MaterialPageRoute(
                                                                                              builder: (context) => CartPage(
                                                                                                fromeFilters: true,
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                          //////////////////////////////
                                                                                          FirebaseAnalyticsService.logEventForSession(
                                                                                            eventName: AnalyticsEventsConst.buttonClicked,
                                                                                            executedEventName: AnalyticsExecutedEventNameConst.showShoppingBagButton,
                                                                                          );
                                                                                        },
                                                                                        child: Stack(children: [
                                                                                          Positioned(
                                                                                            child: SvgPicture.asset(AppAssets.bagsSvg),
                                                                                            right: LanguageService.languageCode != "ar" ? 0 : null,
                                                                                            left: LanguageService.languageCode == "ar" ? 0 : null,
                                                                                            bottom: 5,
                                                                                          ),
                                                                                          Positioned(
                                                                                            child: Container(
                                                                                              width: (qtyItemsInCart > 0) ? 15 : 0,
                                                                                              alignment: Alignment.center,
                                                                                              height: (qtyItemsInCart > 0) ? 15 : 0,
                                                                                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                                                                              child: MyTextWidget(
                                                                                                (qtyItemsInCart > 0) ? "${qtyItemsInCart}" : "",
                                                                                                maxLines: 1,
                                                                                                style: textTheme.titleSmall?.ra.copyWith(fontSize: 12, color: Colors.white, letterSpacing: 0.28),
                                                                                              ),
                                                                                            ),
                                                                                            top: 0,
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
                                                                    )
                                                                  : TrydosAppBar(
                                                                      appBarParams: AppBarParams(
                                                                          onBack: () {
                                                                            FocusScope.of(context).unfocus();
                                                                            try {
                                                                              if (panelControllerForCart.isPanelOpen) {
                                                                                panelControllerForCart.close();
                                                                                return;
                                                                              }
                                                                            } catch (e) {}
                                                                            if (widget.fromBackground) {
                                                                              context.go(GRouter.config.kRootRoute);
                                                                            }
                                                                            categoryBloc.add(ReplyFromGeminiEvent(
                                                                                fromSearch: false,
                                                                                sendRequestToGeminiStatus: SendRequestToGeminiStatus.success,
                                                                                theReplyFromGemini: ""));
                                                                            if (widget.fromSearch) {
                                                                              widget.controllerFormSearchPage?.text = controller.text;
                                                                              boutiqueBloc.add(ChangeAppliedFiltersEvent(boutiqueSlug: widget.boutiqueSlug, category: widget.category, filtersAppliedByUser: GetProductFiltersModel(filters: boutiqueBloc.state.appliedFiltersByUser[key]?.filters), resetAppliedFilters: false));
                                                                              boutiqueBloc.add(ChangeSelectedFiltersEvent(
                                                                                fromHomePageSearch: widget.fromSearch,
                                                                                boutiqueSlug: widget.boutiqueSlug,
                                                                                category: widget.category,
                                                                                filtersChoosedByUser: GetProductFiltersModel(filters: boutiqueBloc.state.appliedFiltersByUser[key]?.filters),
                                                                              ));
                                                                            }
                                                                          },
                                                                          backgroundColor: colorScheme.white,
                                                                          scrolledUnderElevation: 0,
                                                                          backIconColor: Colors.black,
                                                                          hasLeading: !isExpanded && !searchOpen,
                                                                          action: [
                                                                            Spacer(),
                                                                            ValueListenableBuilder<bool>(
                                                                                valueListenable: displayBoutiqueIconInAppBar,
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.only(start: 30.w),
                                                                                  child: widget.boutiqueIcon != null
                                                                                      ? SvgNetworkWidget(
                                                                                          svgUrl: widget.boutiqueIcon ?? "",
                                                                                          height: 20,
                                                                                        )
                                                                                      : SizedBox.shrink(),
                                                                                ),
                                                                                builder: (context, display, child) {
                                                                                  return display ? child! : SizedBox.shrink();
                                                                                }),
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.only(end: searchOpen ? 10 : 20.0),
                                                                              child: AnimatedSearchBar(
                                                                                key: TestVariables.kTestMode ? Key(WidgetsKeys.productListingSearchInputKey) : null,
                                                                                autoFocus: false,
                                                                                width: isExpanded ? (1.sw - 90) : (1.sw - 120),
                                                                                height: 40,
                                                                                onClickClose: () {
                                                                                  boutiqueBloc.add(AddSizeAndColorFilterinTextToSearchEvent(sizeAndColorFilterinTextToSearch: {}));

                                                                                  if (!isExpanded && controller.text.isNotEmpty) {
                                                                                    Filter filters = boutiqueBloc.state.appliedFiltersByUser[key]?.filters ?? Filter();
                                                                                    boutiqueBloc.add(ChangeAppliedFiltersEvent(boutiqueSlug: widget.boutiqueSlug, category: widget.category, filtersAppliedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                                    boutiqueBloc.add(GetProductsWithFiltersEvent(
                                                                                      offset: 1,
                                                                                      searchText: null,
                                                                                      fromSearch: fromSearch,
                                                                                      category: widget.category,
                                                                                      boutiqueSlug: widget.boutiqueSlug,
                                                                                    ));
                                                                                  }
                                                                                  if (isExpanded && controller.text.isNotEmpty) {
                                                                                    Filter filters = boutiqueBloc.state.choosedFiltersByUser[key]?.filters ?? Filter();
                                                                                    boutiqueBloc.add(ChangeSelectedFiltersEvent(fromHomePageSearch: widget.fromSearch, boutiqueSlug: widget.boutiqueSlug, filtersChoosedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                                  }

                                                                                  resetSearchAfterSearchingWhileRemoveSearch = false;
                                                                                  FocusScope.of(context).unfocus();

                                                                                  searchVisible.value = false;

                                                                                  controller.clear();
                                                                                  appBloc.add(HideBottomNavigationBar(false));
                                                                                  ///////////////////////////
                                                                                  FirebaseAnalyticsService.logEventForSession(
                                                                                    eventName: AnalyticsEventsConst.buttonClicked,
                                                                                    executedEventName: AnalyticsExecutedEventNameConst.resetCloseIconButton,
                                                                                  );
                                                                                  return false;
                                                                                },
                                                                                textController: controller,
                                                                                focusNode: focusNode,
                                                                                onSuffixTap: () {
                                                                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                                                                    searchVisible.value = true;
                                                                                  });
                                                                                },
                                                                                suffixWidget: Center(
                                                                                  child: SvgPicture.asset(
                                                                                    AppAssets.searchOutlinedSvg,
                                                                                    height: 20,
                                                                                    width: 20,
                                                                                    color: Color(0xff388CFF),
                                                                                  ),
                                                                                ),
                                                                                prefixWidget: Padding(
                                                                                  padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      InkWell(
                                                                                        onTap: () async {
                                                                                          SearchWithImageRelatedGemini.SelecteImageForSearch(fromSearch: false, context: context);
                                                                                          /////////////////////////////
                                                                                          FirebaseAnalyticsService.logEventForSession(
                                                                                            eventName: AnalyticsEventsConst.buttonClicked,
                                                                                            executedEventName: AnalyticsExecutedEventNameConst.searchWithImageButton,
                                                                                          );
                                                                                        },
                                                                                        child: state.sendRequestToGeminiStatus == SendRequestToGeminiStatus.loading
                                                                                            ? TrydosLoader(
                                                                                                size: 18,
                                                                                              )
                                                                                            : SvgPicture.asset(
                                                                                                AppAssets.realCameraSvg,
                                                                                                height: 20,
                                                                                                width: 20,
                                                                                              ),
                                                                                      ),
                                                                                      ValueListenableBuilder<bool>(
                                                                                        valueListenable: isRecordeForSearchWithMic,
                                                                                        builder: (context, recordeForSearchWithMic, _) {
                                                                                          return InkWell(
                                                                                            onTap: () async {
                                                                                              final status = await Permission.microphone.request();
                                                                                              if (status != PermissionStatus.granted) {
                                                                                                return;
                                                                                              }
                                                                                              if (_speechToText.isNotListening) {
                                                                                                _startListening();
                                                                                                /////////////////////////////
                                                                                                FirebaseAnalyticsService.logEventForSession(
                                                                                                  eventName: AnalyticsEventsConst.buttonClicked,
                                                                                                  executedEventName: AnalyticsExecutedEventNameConst.searchWithVoiceButton,
                                                                                                );
                                                                                              } else {
                                                                                                _stopListening();
                                                                                              }
                                                                                            },
                                                                                            child: Container(
                                                                                              width: 20,
                                                                                              child: Icon(_speechToText.isNotListening || !recordeForSearchWithMic ? Icons.mic_off : Icons.mic),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                animationDurationInMilli: 400,
                                                                                searchDecoration: InputDecoration(
                                                                                  border: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: focusNode.hasFocus ? Color(0xffE6E6E6) : Color(0xffF8F8F8), width: 0.4),
                                                                                    borderRadius: BorderRadius.circular(kbrBorderTextField),
                                                                                  ),
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: focusNode.hasFocus ? Color(0xffE6E6E6) : Color(0xffF8F8F8), width: 0.4),
                                                                                    borderRadius: BorderRadius.circular(kbrBorderTextField),
                                                                                  ),
                                                                                  enabledBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: focusNode.hasFocus ? Color(0xffE6E6E6) : Color(0xffF8F8F8), width: 0.4),
                                                                                    borderRadius: BorderRadius.circular(kbrBorderTextField),
                                                                                  ),
                                                                                  disabledBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: focusNode.hasFocus ? Color(0xffE6E6E6) : Color(0xffF8F8F8), width: 0.4),
                                                                                    borderRadius: BorderRadius.circular(kbrBorderTextField),
                                                                                  ),
                                                                                  errorBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: context.colorScheme.error, width: 0.4),
                                                                                    borderRadius: BorderRadius.circular(kbrBorderTextField),
                                                                                  ),
                                                                                  focusedErrorBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: context.colorScheme.error, width: 0.4),
                                                                                    borderRadius: BorderRadius.circular(kbrBorderTextField),
                                                                                  ),
                                                                                  filled: true,
                                                                                  fillColor: focusNode.hasFocus ? colorScheme.white : Color(0xffF8F8F8),
                                                                                  prefixIcon: Padding(
                                                                                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                                                                                    child: SvgPicture.asset(
                                                                                      AppAssets.searchOutlinedSvg,
                                                                                      height: 20,
                                                                                      width: 20,
                                                                                      color: Color(0xff388CFF),
                                                                                    ),
                                                                                  ),
                                                                                  suffixIcon: Padding(
                                                                                    padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        InkWell(
                                                                                          onTap: () async {
                                                                                            SearchWithImageRelatedGemini.SelecteImageForSearch(fromSearch: false, context: context);
                                                                                            /////////////////////////////
                                                                                            FirebaseAnalyticsService.logEventForSession(
                                                                                              eventName: AnalyticsEventsConst.buttonClicked,
                                                                                              executedEventName: AnalyticsExecutedEventNameConst.searchWithImageButton,
                                                                                            );
                                                                                          },
                                                                                          child: state.sendRequestToGeminiStatus == SendRequestToGeminiStatus.loading
                                                                                              ? TrydosLoader(
                                                                                                  size: 18,
                                                                                                )
                                                                                              : SvgPicture.asset(
                                                                                                  AppAssets.realCameraSvg,
                                                                                                  height: 20,
                                                                                                  width: 20,
                                                                                                ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 20,
                                                                                        ),
                                                                                        ValueListenableBuilder<bool>(
                                                                                          valueListenable: isRecordeForSearchWithMic,
                                                                                          builder: (context, recordeForSearchWithMic, _) {
                                                                                            return InkWell(
                                                                                              onTap: () async {
                                                                                                final status = await Permission.microphone.request();
                                                                                                if (status != PermissionStatus.granted) {
                                                                                                  return;
                                                                                                }
                                                                                                if (_speechToText.isNotListening) {
                                                                                                  _startListening();
                                                                                                  /////////////////////////////
                                                                                                  FirebaseAnalyticsService.logEventForSession(
                                                                                                    eventName: AnalyticsEventsConst.buttonClicked,
                                                                                                    executedEventName: AnalyticsExecutedEventNameConst.searchWithVoiceButton,
                                                                                                  );
                                                                                                } else {
                                                                                                  _stopListening();
                                                                                                }
                                                                                              },
                                                                                              child: Container(
                                                                                                width: 20,
                                                                                                child: Icon(_speechToText.isNotListening || !recordeForSearchWithMic ? Icons.mic_off : Icons.mic),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  //context.colorScheme.white,
                                                                                  contentPadding: HWEdgeInsetsDirectional.only(start: 20, end: 10, bottom: 12, top: 12),
                                                                                  hintText: '${LocaleKeys.search.tr()}',
                                                                                  hintStyle: context.textTheme.bodyMedium?.lq.copyWith(color: Color(0xffC4C2C2)),
                                                                                  labelStyle: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.hint),
                                                                                ),
                                                                                onChanged: (String text) {
                                                                                  List<String>? colorsFilter = [];
                                                                                  List<String> listSearchTextWithoutConstWord = text.split(" ").toList();
                                                                                  String searchText = "";
                                                                                  List<String>? sizesFilter = [];

                                                                                  if (isExpanded) {
                                                                                    Filter filters = boutiqueBloc.state.choosedFiltersByUser[key]?.filters ?? Filter();
                                                                                    if (text.length > 2) {
                                                                                      List<String> listOfSearchText = text.split(" ").toList();
                                                                                      for (var i = 0; i < colorsNameForSearch.length; i++) {
                                                                                        if (listOfSearchText.contains(colorsNameForSearch[i])) {
                                                                                          colorsFilter.add(colorsCodeForSearch[i]);
                                                                                          listSearchTextWithoutConstWord.remove(colorsNameForSearch[i]);
                                                                                        }
                                                                                      }

                                                                                      for (var i = 0; i < sizesForSearch.length; i++) {
                                                                                        if (listOfSearchText.contains(sizesForSearch[i])) {
                                                                                          sizesFilter.add(sizesForSearch[i]);
                                                                                          listSearchTextWithoutConstWord.remove(sizesForSearch[i]);
                                                                                        }
                                                                                      }
                                                                                      for (var i = 0; i < constWordToRemoveItFromSearch.length; i++) {
                                                                                        listSearchTextWithoutConstWord.remove(constWordToRemoveItFromSearch[i]);
                                                                                      }
                                                                                      listSearchTextWithoutConstWord.forEach((element) => searchText = searchText + " " + element);
                                                                                      resetSearchAfterSearchingWhileRemoveSearch = true;
                                                                                      boutiqueBloc.add(ChangeSelectedFiltersEvent(fromHomePageSearch: widget.fromSearch, boutiqueSlug: widget.boutiqueSlug, filtersChoosedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: searchText))));
                                                                                    }
                                                                                    if (text.length < 3 && resetSearchAfterSearchingWhileRemoveSearch) {
                                                                                      resetSearchAfterSearchingWhileRemoveSearch = false;
                                                                                      boutiqueBloc.add(ChangeSelectedFiltersEvent(fromHomePageSearch: widget.fromSearch, boutiqueSlug: widget.boutiqueSlug, filtersChoosedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                                    }
                                                                                    return;
                                                                                  }
                                                                                  if (text.length > 2) {
                                                                                    boutiqueBloc.add(AddSizeAndColorFilterinTextToSearchEvent(sizeAndColorFilterinTextToSearch: {}));

                                                                                    List<String> listOfSearchText = text.split(" ").toList();
                                                                                    for (var i = 0; i < colorsNameForSearch.length; i++) {
                                                                                      if (listOfSearchText.contains(colorsNameForSearch[i])) {
                                                                                        colorsFilter.add(colorsCodeForSearch[i]);
                                                                                        listSearchTextWithoutConstWord.remove(colorsNameForSearch[i]);
                                                                                      }
                                                                                    }

                                                                                    for (var i = 0; i < sizesForSearch.length; i++) {
                                                                                      if (listOfSearchText.contains(sizesForSearch[i])) {
                                                                                        sizesFilter.add(sizesForSearch[i]);
                                                                                        listSearchTextWithoutConstWord.remove(sizesForSearch[i]);
                                                                                      }
                                                                                    }
                                                                                    for (var i = 0; i < constWordToRemoveItFromSearch.length; i++) {
                                                                                      listSearchTextWithoutConstWord.remove(constWordToRemoveItFromSearch[i]);
                                                                                    }
                                                                                    listSearchTextWithoutConstWord.forEach((element) => searchText = searchText + " " + element);
                                                                                    resetSearchAfterSearchingWhileRemoveSearch = true;
                                                                                    Filter filters = boutiqueBloc.state.appliedFiltersByUser[key]?.filters ?? Filter();

                                                                                    boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                                                                      category: widget.category,
                                                                                      boutiqueSlug: widget.boutiqueSlug,
                                                                                      filtersAppliedByUser: GetProductFiltersModel(
                                                                                          filters: filters.copyWithSaveOtherField(
                                                                                        prices: filters.prices,
                                                                                        searchText: searchText,
                                                                                      )),
                                                                                    ));
                                                                                    boutiqueBloc.add(AddSizeAndColorFilterinTextToSearchEvent(sizeAndColorFilterinTextToSearch: {
                                                                                      "size": sizesFilter,
                                                                                      "color": colorsFilter
                                                                                    }));
                                                                                    boutiqueBloc.add(GetProductsWithFiltersEvent(
                                                                                      offset: 1,
                                                                                      searchText: searchText,
                                                                                      fromSearch: fromSearch,
                                                                                      category: widget.category,
                                                                                      boutiqueSlug: widget.boutiqueSlug,
                                                                                    ));
                                                                                  }
                                                                                  if (text.length < 3 && resetSearchAfterSearchingWhileRemoveSearch) {
                                                                                    resetSearchAfterSearchingWhileRemoveSearch = false;
                                                                                    Filter filters = boutiqueBloc.state.appliedFiltersByUser[key]?.filters ?? Filter();

                                                                                    boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                                                                      category: widget.category,
                                                                                      boutiqueSlug: widget.boutiqueSlug,
                                                                                      filtersAppliedByUser: GetProductFiltersModel(
                                                                                          filters: filters.copyWithSaveOtherField(
                                                                                        prices: filters.prices,
                                                                                        searchText: null,
                                                                                      )),
                                                                                    ));
                                                                                    boutiqueBloc.add(GetProductFiltersEvent(
                                                                                      fromHomePageSearch: widget.fromSearch,
                                                                                      searchText: null,
                                                                                      category: widget.category,
                                                                                      boutiqueSlug: widget.boutiqueSlug,
                                                                                    ));
                                                                                    boutiqueBloc.add(GetProductsWithFiltersEvent(
                                                                                      offset: 1,
                                                                                      searchText: null,
                                                                                      fromSearch: fromSearch,
                                                                                      category: widget.category,
                                                                                      boutiqueSlug: widget.boutiqueSlug,
                                                                                    ));
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ),
                                                                            AnimatedSize(
                                                                              curve: Curves.easeOut,
                                                                              duration: Duration(milliseconds: 400),
                                                                              reverseDuration: Duration(milliseconds: 400),
                                                                              child: Row(
                                                                                children: [
                                                                                  isExpanded
                                                                                      ? SizedBox.shrink()
                                                                                      : Padding(
                                                                                          padding: EdgeInsetsDirectional.only(end: searchOpen ? 10 : 20.0),
                                                                                          child: SvgPicture.asset(AppAssets.sortingSvg, width: 20, height: 20),
                                                                                        ),
                                                                                  BlocBuilder<BoutiqueBloc, BoutiqueState>(
                                                                                    buildWhen: (p, c) {
                                                                                      return (p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${homeState.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}'] != c.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${homeState.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}'] || p.getProductFiltersStatus[key] != c.getProductFiltersStatus[key] || p.isExpandedForListingPage != c.isExpandedForListingPage || p.cashedOrginalBoutique != c.cashedOrginalBoutique);
                                                                                    },
                                                                                    builder: (context, state) {
                                                                                      isExpanded = state.isExpandedForListingPage ?? false;
                                                                                      if ((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length ?? 0) == 1) {
                                                                                        return SizedBox.shrink();
                                                                                      }
                                                                                      return Padding(
                                                                                          padding: EdgeInsetsDirectional.only(end: searchOpen ? 10 : 20.0),
                                                                                          child: InkWell(
                                                                                            key: TestVariables.kTestMode ? Key(WidgetsKeys.filterIconKey) : null,
                                                                                            onTap: () {
                                                                                              if (!isExpanded) {
                                                                                                prefAppliedFilters = boutiqueBloc.state.appliedFiltersByUser[key]?.filters;
                                                                                                boutiqueBloc.add(ChangeAppliedFiltersEvent(boutiqueSlug: widget.boutiqueSlug, category: widget.category, isExpandedForListing: true, resetAppliedFilters: true));
                                                                                                boutiqueBloc.add(AddPrefAppliedFilterForExtendFilterEvent(prefAppliedFilter: prefAppliedFilters));

                                                                                                boutiqueBloc.add(ChangeSelectedFiltersEvent(fromHomePageSearch: widget.fromSearch, boutiqueSlug: widget.boutiqueSlug, category: widget.category, requestToUpdateFilters: true, isExpandedForListing: true, filtersChoosedByUser: GetProductFiltersModel(filters: prefAppliedFilters)));

                                                                                                resetSearchAfterSearchingWhileRemoveSearch = false;
                                                                                                // تم جعل الصفحة expanded باستخدام الأحداث السابقة لتجنب البناء المتكرر
                                                                                                // homeBloc
                                                                                                //     .add(
                                                                                                //     AddIsExpandedForLidtingPageEvent(
                                                                                                //         isExpandedForLidting: true));
                                                                                                /////////////////////////////////////////
                                                                                                FirebaseAnalyticsService.logEventForSession(
                                                                                                  eventName: AnalyticsEventsConst.buttonClicked,
                                                                                                  executedEventName: AnalyticsExecutedEventNameConst.productListingFilterIconButton,
                                                                                                );
                                                                                                /////////////////////////////////////////
                                                                                                FirebaseAnalyticsService.logScreen(
                                                                                                  screen: AnalyticsScreensConst.productListingFilterScreen,
                                                                                                );
                                                                                              }
                                                                                            },
                                                                                            child: SvgPicture.asset(
                                                                                              AppAssets.filtersSvg,
                                                                                              width: 20,
                                                                                              height: 20,
                                                                                              color: isExpanded ? Color(0xffFF5F61) : null,
                                                                                            ),
                                                                                          ));
                                                                                    },
                                                                                  ),
                                                                                  InkWell(
                                                                                      onTap: () {
                                                                                        if (isExpanded) {
                                                                                          prefAppliedFilters = boutiqueBloc.state.prefAppliedFilterForExtendFilter;
                                                                                          controller.text = prefAppliedFilters?.searchText ?? "";

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
                                                                                              boutiqueSlug: widget.boutiqueSlug,
                                                                                              isExpandedForListing: false,
                                                                                              category: widget.category,
                                                                                              filtersAppliedByUser: GetProductFiltersModel(filters: prefAppliedFilters),
                                                                                            ),
                                                                                          );
                                                                                          //////////////////////////////////
                                                                                          FirebaseAnalyticsService.logEventForSession(
                                                                                            eventName: AnalyticsEventsConst.buttonClicked,
                                                                                            executedEventName: AnalyticsExecutedEventNameConst.filterCloseIconButton,
                                                                                          );
                                                                                        }
                                                                                        // تم جعل الصفحة not expanded باستخدام الأحداث السابقة لتجنب البناء المتكرر
                                                                                        // homeBloc.add(
                                                                                        //     AddIsExpandedForLidtingPageEvent(
                                                                                        //         isExpandedForLidting:
                                                                                        //         false));

                                                                                        resetSearchAfterSearchingWhileRemoveSearch = false;
                                                                                      },
                                                                                      child: SizedBox(
                                                                                        height: 30,
                                                                                        child: Row(children: [
                                                                                          SizedBox(
                                                                                              width: searchOpen
                                                                                                  ? 0
                                                                                                  : !isExpanded
                                                                                                      ? 10.0
                                                                                                      : 12.5),
                                                                                          !isExpanded
                                                                                              ? SvgPicture.asset(
                                                                                                  AppAssets.shareSvg,
                                                                                                  width: 20,
                                                                                                  height: 20,
                                                                                                  color: Color(0xff3C3C3C),
                                                                                                )
                                                                                              : SvgPicture.asset(
                                                                                                  key: TestVariables.kTestMode ? Key(WidgetsKeys.closeFilterPageKey) : null,
                                                                                                  AppAssets.closeSvg,
                                                                                                  width: 15,
                                                                                                  height: 15,
                                                                                                  color: Color(0xffFF5F61),
                                                                                                ),
                                                                                          SizedBox(width: !isExpanded ? 10.0 : 12.5)
                                                                                        ]),
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                          withShadow: false),
                                                                    ),
                                                            );
                                                          }));
                                            }),
                                        ValueListenableBuilder<bool>(
                                            valueListenable: searchVisible,
                                            builder: (context, searchOpen, _) {
                                              return !fromSearch!
                                                  ? ValueListenableBuilder<
                                                          double>(
                                                      valueListenable:
                                                          htmlDescriptionHeight,
                                                      builder: (context,
                                                          htmlHeight, child) {
                                                        return isExpanded
                                                            ? SliverToBoxAdapter()
                                                            : SliverAppBar(
                                                                pinned: false,
                                                                collapsedHeight:
                                                                    180 +
                                                                        htmlHeight,
                                                                backgroundColor:
                                                                    colorScheme
                                                                        .white,
                                                                automaticallyImplyLeading:
                                                                    false,
                                                                flexibleSpace: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      DelayedDisplay(
                                                                        delay: Duration(
                                                                            milliseconds:
                                                                                600),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Column(children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                widget.boutiqueIcon != null
                                                                                    ? SvgNetworkWidget(
                                                                                        svgUrl: widget.boutiqueIcon ?? "",
                                                                                        height: 20,
                                                                                      )
                                                                                    : SizedBox.shrink(),
                                                                                SizedBox(
                                                                                  width: 8,
                                                                                ),
                                                                                SvgPicture.asset(
                                                                                  AppAssets.verifiedBadgeSvg,
                                                                                  height: 15,
                                                                                  width: 15,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 8,
                                                                                ),
                                                                                SvgPicture.asset(
                                                                                  AppAssets.starBadgeSvg,
                                                                                  height: 15,
                                                                                  width: 15,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Html(key: htmlDescriptionKey, shrinkWrap: true, data: widget.boutiqueDescription ?? '', style: {
                                                                              "body": Style(margin: Margins.all(0)),
                                                                              "p": Style(
                                                                                margin: Margins.all(0),
                                                                              ),
                                                                            }),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            widget.withSlidingImages
                                                                                ? Container(
                                                                                    height: 128,
                                                                                    //color: Colors.red,
                                                                                    child: CarouselSlider.builder(
                                                                                        itemCount: widget.banner!.length,
                                                                                        itemBuilder: (context, index, _) {
                                                                                          return Padding(
                                                                                            padding: EdgeInsets.only(
                                                                                              right: 10,
                                                                                              left: 10,
                                                                                            ),
                                                                                            child: Container(
                                                                                              height: 128,
                                                                                              width: 1.sw,
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(15.0),
                                                                                                border: Border.all(width: 0.5, color: const Color(0xfffafafa)),
                                                                                                boxShadow: [
                                                                                                  BoxShadow(
                                                                                                    color: const Color(0x33000000),
                                                                                                    offset: Offset(0, 3),
                                                                                                    blurRadius: 10,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                              child: ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                                  child: MyCachedNetworkImage(
                                                                                                    imageUrl: widget.banner![index].filePath!,
                                                                                                    imageFit: BoxFit.cover,
                                                                                                    width: 1.sw,
                                                                                                    height: 128,
                                                                                                  )),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                        options: CarouselOptions(
                                                                                          autoPlay: true,
                                                                                          autoPlayInterval: Duration(seconds: 6),
                                                                                          autoPlayAnimationDuration: Duration(seconds: 1),
                                                                                          initialPage: 0,
                                                                                          height: 128,
                                                                                          enableInfiniteScroll: false,
                                                                                          viewportFraction: 0.85,
                                                                                        )))
                                                                                : Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                                                                    child: Stack(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: htmlHeight == 0 ? 0 : 135,
                                                                                          width: 1.sw,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                                            border: Border.all(width: 0.5, color: const Color(0xfffafafa)),
                                                                                            boxShadow: [
                                                                                              BoxShadow(
                                                                                                color: const Color(0x33000000),
                                                                                                offset: Offset(0, 3),
                                                                                                blurRadius: 10,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          child: ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(15),
                                                                                              child: MyCachedNetworkImage(
                                                                                                imageUrl: widget.boutiqueFirstBanner!,
                                                                                                imageFit: BoxFit.cover,
                                                                                                width: 1.sw,
                                                                                                height: 130,
                                                                                              )),
                                                                                        ),
                                                                                        Container(
                                                                                          height: htmlHeight == 0 ? 0 : 128,
                                                                                          width: 1.sw,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                                            boxShadow: [
                                                                                              BoxShadow(color: Colors.white.withOpacity(0.7), offset: Offset(0, 3), blurRadius: 6, inset: true),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                          ]),
                                                                        ),
                                                                      )
                                                                    ]),
                                                              );
                                                      })
                                                  : SliverToBoxAdapter();
                                            }),
                                        ValueListenableBuilder<bool>(
                                            valueListenable: searchVisible,
                                            builder: (context, searchOpen, _) {
                                              return BlocBuilder<BoutiqueBloc,
                                                  BoutiqueState>(
                                                buildWhen: (p, c) {
                                                  return p
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      'withoutFilter' +
                                                                      '${(widget.category ?? '')}']
                                                              ?.paginationStatus !=
                                                          c
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      'withoutFilter' +
                                                                      '${(widget.category ?? '')}']
                                                              ?.paginationStatus ||
                                                      p.isExpandedForListingPage !=
                                                          c
                                                              .isExpandedForListingPage ||
                                                      p.appliedFiltersByUser[key] !=
                                                          c.appliedFiltersByUser[
                                                              key] ||
                                                      p.getProductFiltersStatus[key] !=
                                                          c.getProductFiltersStatus[
                                                              key] ||
                                                      p
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${(widget.category ?? '')}']
                                                              ?.paginationStatus !=
                                                          c
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${(widget.category ?? '')}']
                                                              ?.paginationStatus ||
                                                      p.cashedOrginalBoutique !=
                                                          c.cashedOrginalBoutique;
                                                },
                                                builder: (context, state) {
                                                  String?
                                                      currentAppliedFilterSllug =
                                                      "null";
                                                  isExpanded = state
                                                          .isExpandedForListingPage ??
                                                      false;
                                                  bool isOneProductForPrefetch =
                                                      false;

                                                  GetProductFiltersModel?
                                                      appliedFiltersByUser =
                                                      state.appliedFiltersByUser[
                                                          key];
                                                  if ((appliedFiltersByUser
                                                              ?.filters
                                                              ?.categories
                                                              ?.length ??
                                                          0) >
                                                      0) {
                                                    currentAppliedFilterSllug =
                                                        appliedFiltersByUser
                                                            ?.filters
                                                            ?.categories?[0]
                                                            .slug;
                                                  } else if ((appliedFiltersByUser
                                                              ?.filters
                                                              ?.brands
                                                              ?.length ??
                                                          0) >
                                                      0) {
                                                    currentAppliedFilterSllug =
                                                        appliedFiltersByUser
                                                            ?.filters
                                                            ?.brands?[0]
                                                            .slug;
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
                                                                  ?.attributes?[
                                                                      0]
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
                                                            ?.filters
                                                            ?.colors?[0];
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
                                                  if (!isExpanded &&
                                                          (appliedFiltersByUser
                                                                      ?.filters
                                                                      ?.searchText
                                                                      ?.length ??
                                                                  0) <
                                                              3 &&
                                                          ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ?? 0) == 1 &&
                                                              !widget
                                                                  .fromSearch &&
                                                              (appliedFiltersByUser
                                                                      ?.filters
                                                                      ?.prices
                                                                      ?.minPrice ==
                                                                  null)) ||
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
                                                                  (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ??
                                                                      0) ==
                                                              0 &&
                                                          !widget.fromSearch &&
                                                          (appliedFiltersByUser
                                                                  ?.filters
                                                                  ?.prices
                                                                  ?.minPrice !=
                                                              null))) {
                                                    if (((state
                                                                    .getProductListingWithFiltersPaginationWithPrefetchModels['${widget.boutiqueSlug}' +
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
                                                            PaginationStatus
                                                                .success &&
                                                        state
                                                                .getProductListingWithFiltersPaginationWithPrefetchModels[
                                                                    '${widget.boutiqueSlug}' +
                                                                        '${(widget.category ?? '')}']
                                                                ?.paginationStatus ==
                                                            PaginationStatus
                                                                .success)) {
                                                      isOneProductForPrefetch =
                                                          true;
                                                    }
                                                  }

                                                  return SliverAppBar(
                                                      pinned: !isExpanded,
                                                      surfaceTintColor:
                                                          Colors.transparent,
                                                      backgroundColor:
                                                          colorScheme.white,
                                                      automaticallyImplyLeading:
                                                          false,
                                                      titleSpacing: 0,
                                                      toolbarHeight: isExpanded
                                                          ? 860
                                                          : (currentAppliedFilterSllug != "null" && (isOneProductForPrefetch || (!isOneProductForPrefetch && state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length == 1 && state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.paginationStatus == PaginationStatus.success))) ||
                                                                  (currentAppliedFilterSllug == "null" &&
                                                                      state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length ==
                                                                          1 &&
                                                                      state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.paginationStatus ==
                                                                          PaginationStatus
                                                                              .success)
                                                              ? 35
                                                              : currentAppliedFilterSllug !=
                                                                      "null"
                                                                  ? 145
                                                                  : widget
                                                                          .fromSearch
                                                                      ? 145
                                                                      : controller.text.length >
                                                                              2
                                                                          ? 145
                                                                          : 115,
                                                      flexibleSpace:
                                                          StackedFiltersList(
                                                              expandingFiltersStack:
                                                                  expandingFiltersStack,
                                                              key: TestVariables
                                                                      .kTestMode
                                                                  ? Key(WidgetsKeys
                                                                      .productListFilterKey)
                                                                  : null,
                                                              textController:
                                                                  controller,
                                                              hideTitle: false,
                                                              fromSearch:
                                                                  fromSearch!,
                                                              searchText: controller.text.length > 2
                                                                  ? controller
                                                                      .text
                                                                  : null,
                                                              filterPageExpanded:
                                                                  state.isExpandedForListingPage ?? false,
                                                              closeFilterPage: () {
                                                                boutiqueBloc.add(
                                                                    AddIsExpandedForLidtingPageEvent(
                                                                        isExpandedForLidting:
                                                                            false));
                                                                ;
                                                              },
                                                              displayAppliedFiltersOnly: (state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length ?? 0) < 2 && state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.paginationStatus == PaginationStatus.success,
                                                              category: widget.category,
                                                              boutiqueSlug: widget.boutiqueSlug,
                                                              controller: isExpanded ? scrollController : null,
                                                              onMoveToAnotherFiltersSection: (title) {
                                                                timerForDisplayFilterSectionTitle
                                                                    ?.cancel();
                                                                showTitleForFilterList
                                                                        .value =
                                                                    title;
                                                                timerForDisplayFilterSectionTitle = Timer(
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                                    () {
                                                                  showTitleForFilterList
                                                                          .value =
                                                                      null;
                                                                });
                                                              }));
                                                },
                                              );
                                            }),
                                        isExpanded
                                            ? SliverToBoxAdapter()
                                            : BlocBuilder<BoutiqueBloc,
                                                BoutiqueState>(
                                                buildWhen: (p, c) {
                                                  bool rebuild = p
                                                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                  'withoutFilter' +
                                                                  '${(widget.category ?? '')}']
                                                              ?.paginationStatus !=
                                                          c
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      'withoutFilter' +
                                                                      '${(widget.category ?? '')}']
                                                              ?.paginationStatus ||
                                                      p.isExpandedForListingPage !=
                                                          c
                                                              .isExpandedForListingPage ||
                                                      p.appliedFiltersByUser[key] !=
                                                          c.appliedFiltersByUser[
                                                              key] ||
                                                      p.isGettingProductListingWithPaginationForAppearProduct !=
                                                          c
                                                              .isGettingProductListingWithPaginationForAppearProduct ||
                                                      p.isGettingProductListingWithPagination !=
                                                          c
                                                              .isGettingProductListingWithPagination ||
                                                      p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${(widget.category ?? '')}']?.paginationStatus !=
                                                          c
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${(widget.category ?? '')}']
                                                              ?.paginationStatus ||
                                                      p.cashedOrginalBoutique !=
                                                          c.cashedOrginalBoutique;

                                                  if (rebuild) {
                                                    gridViewKeyForRendering =
                                                        UniqueKey();
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
                                                  isExpanded = state
                                                          .isExpandedForListingPage ??
                                                      false;
                                                  GetProductFiltersModel?
                                                      appliedFiltersByUser =
                                                      state.appliedFiltersByUser[
                                                          key];
                                                  String?
                                                      currentAppliedFilterSllug =
                                                      "null";
                                                  if (!isExpanded &&
                                                          !state
                                                              .isGettingProductListingWithPaginationForAppearProduct &&
                                                          (appliedFiltersByUser?.filters?.searchText?.length ?? 0) <
                                                              3 &&
                                                          ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ?? 0) == 1 &&
                                                              !widget
                                                                  .fromSearch &&
                                                              (appliedFiltersByUser
                                                                      ?.filters
                                                                      ?.prices
                                                                      ?.minPrice ==
                                                                  null)) ||
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
                                                              0 &&
                                                          !widget.fromSearch &&
                                                          !isExpanded &&
                                                          (appliedFiltersByUser
                                                                  ?.filters
                                                                  ?.prices
                                                                  ?.minPrice !=
                                                              null))) {
                                                    if ((appliedFiltersByUser
                                                                ?.filters
                                                                ?.categories
                                                                ?.length ??
                                                            0) >
                                                        0) {
                                                      currentAppliedFilterSllug =
                                                          appliedFiltersByUser
                                                              ?.filters
                                                              ?.categories?[0]
                                                              .slug;
                                                    } else if ((appliedFiltersByUser
                                                                ?.filters
                                                                ?.brands
                                                                ?.length ??
                                                            0) >
                                                        0) {
                                                      currentAppliedFilterSllug =
                                                          appliedFiltersByUser
                                                              ?.filters
                                                              ?.brands?[0]
                                                              .slug;
                                                    } else if ((((appliedFiltersByUser
                                                                        ?.filters
                                                                        ?.attributes
                                                                        ?.isNullOrEmpty ??
                                                                    false)
                                                                ? 0
                                                                : appliedFiltersByUser
                                                                    ?.filters
                                                                    ?.attributes?[
                                                                        0]
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
                                                                  ?.attributes?[
                                                                      0]
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
                                                  } else if ((!isExpanded &&
                                                      !state.isGettingProductListingWithPaginationForAppearProduct &&
                                                      (widget.fromSearch && ((appliedFiltersByUser?.filters?.boutiques?.length ?? 0) == 0)) &&
                                                      (appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3 &&
                                                      controller.text.length < 3 &&
                                                      ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ?? 0) == 0 && (appliedFiltersByUser?.filters?.prices?.minPrice == null)))) {
                                                    currentAppliedFilterSllug =
                                                        "Empty";
                                                    boutiqueBloc.add(
                                                        IscashedOreiginBotiqueEvent(
                                                            iscashedOreiginBotique:
                                                                true));
                                                  }

                                                  if (state.getProductListingWithFiltersPaginationWithPrefetchModels[
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
                                                      key: TestVariables
                                                              .kTestMode
                                                          ? Key(WidgetsKeys
                                                              .productsListKey)
                                                          : gridViewKeyForRendering,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      sliver: SliverGrid(
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          childAspectRatio:
                                                              200.w / 350,
                                                          crossAxisSpacing: 10,
                                                          mainAxisSpacing: 15,
                                                        ),
                                                        delegate:
                                                            SliverChildBuilderDelegate(
                                                          childCount:
                                                              products.length,
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
                                                                      productName: products[
                                                                              index]
                                                                          .name
                                                                          .toString(),
                                                                      productCategoriesId: products[
                                                                              index]
                                                                          .categories
                                                                          ?.map(
                                                                            (e) =>
                                                                                e.id.toString(),
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
                                                                    () =>
                                                                        Navigator.of(context)
                                                                            .push(
                                                                          MaterialPageRoute(
                                                                            builder: (ctx) =>
                                                                                ProductDetailsPage(
                                                                              productItem: products[index],
                                                                            ),
                                                                          ),
                                                                        ));
                                                              },
                                                              child: _productItem(
                                                                  index: index,
                                                                  slidingMode:
                                                                      slidingMode),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  if (((state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          'withoutFilter' +
                                                                          '${(widget.category ?? '')}']
                                                                  ?.paginationStatus ==
                                                              PaginationStatus
                                                                  .loading) &&
                                                          state
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      'withoutFilter' +
                                                                      '${(widget.category ?? '')}']!
                                                              .items
                                                              .isNullOrEmpty &&
                                                          state
                                                              .cashedOrginalBoutique) ||
                                                      (state.getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          'withoutFilter' +
                                                                          '${(widget.category ?? '')}'] ==
                                                                  PaginationModel
                                                                      .init() &&
                                                              state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          'withoutFilter' +
                                                                          '${(widget.category ?? '')}']!
                                                                  .items
                                                                  .isNullOrEmpty) &&
                                                          !state
                                                              .isGettingProductListingWithPagination) {
                                                    return ProductListingLoading();
                                                  }
                                                  if ((state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                          '${(widget.category ?? '')}']
                                                                  ?.paginationStatus ==
                                                              PaginationStatus
                                                                  .failure &&
                                                          state
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                      '${(widget.category ?? '')}']!
                                                              .items
                                                              .isNullOrEmpty) ||
                                                      (state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          '${(widget.category ?? '')}']
                                                                  ?.paginationStatus ==
                                                              PaginationStatus
                                                                  .failure &&
                                                          !state
                                                              .cashedOrginalBoutique)) {
                                                    return SliverToBoxAdapter(
                                                      child: Center(
                                                        child: MyTextWidget(
                                                          "${LocaleKeys.no_internet_connected.tr()}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  // String key = (widget
                                                  //             .boutiqueSlug ??
                                                  //         '') +
                                                  //     (widget.category ??
                                                  //         '');
                                                  if ((state.getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                      '${(widget.category ?? '')}'] ==
                                                              null ||
                                                          state
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                      '${(widget.category ?? '')}']!
                                                              .items
                                                              .isNullOrEmpty) &&
                                                      state
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}'
                                                                          '${(widget.category ?? '')}']
                                                              ?.paginationStatus ==
                                                          PaginationStatus
                                                              .success) {
                                                    return SliverToBoxAdapter(
                                                      child: Center(
                                                        child: MyTextWidget(
                                                          "${LocaleKeys.no_products_found.tr()}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  if ((((state.getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                          '${(widget.category ?? '')}'] ==
                                                                  null ||
                                                              state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                          '${(widget.category ?? '')}']!
                                                                  .items
                                                                  .isNullOrEmpty) &&
                                                          state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}}'
                                                                              '${(widget.category ?? '')}']
                                                                  ?.paginationStatus !=
                                                              PaginationStatus
                                                                  .success)) ||
                                                      (state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      '${widget.boutiqueSlug}' +
                                                                          '${(widget.category ?? '')}']
                                                                  ?.paginationStatus ==
                                                              PaginationStatus
                                                                  .loading &&
                                                          currentAppliedFilterSllug ==
                                                              "null" &&
                                                          !state
                                                              .cashedOrginalBoutique) ||
                                                      ((state
                                                                          .getProductListingWithFiltersPaginationWithPrefetchModels["${widget.boutiqueSlug}" +
                                                                              "${currentAppliedFilterSllug}" +
                                                                              "${widget.category ?? ""}"]
                                                                          ?.items
                                                                          .length ??
                                                                      0) ==
                                                                  0 &&
                                                              currentAppliedFilterSllug !=
                                                                  "null" &&
                                                              state
                                                                      .getProductListingWithFiltersPaginationModels[
                                                                          '${widget.boutiqueSlug}' +
                                                                              '${(widget.category ?? '')}']
                                                                      ?.paginationStatus ==
                                                                  PaginationStatus
                                                                      .loading) &&
                                                          !state
                                                              .isGettingProductListingWithPagination) {
                                                    return ProductListingLoading(
                                                      key: TestVariables
                                                              .kTestMode
                                                          ? Key(WidgetsKeys
                                                              .boutiqueProductListingLoadingKey)
                                                          : null,
                                                    );
                                                  }

                                                  products = [];

                                                  if (state.getProductListingWithFiltersPaginationModels[
                                                          '${widget.boutiqueSlug}' +
                                                              '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                              '${(widget.category ?? '')}'] !=
                                                      null) {
                                                    products = state
                                                        .getProductListingWithFiltersPaginationModels[
                                                            '${widget.boutiqueSlug}' +
                                                                '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                '${(widget.category ?? '')}']!
                                                        .items;
                                                    if (products.isEmpty) {
                                                      return SliverToBoxAdapter(
                                                        child: Center(
                                                          child: MyTextWidget(
                                                            "${LocaleKeys.no_products_found.tr()}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18),
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
                                                    key: TestVariables.kTestMode
                                                        ? Key(WidgetsKeys
                                                            .productsListKey)
                                                        : gridViewKeyForRendering,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    sliver: SliverGrid(
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        childAspectRatio:
                                                            200.w / 350,
                                                        crossAxisSpacing: 10,
                                                        mainAxisSpacing: 15,
                                                      ),
                                                      delegate:
                                                          SliverChildBuilderDelegate(
                                                        childCount:
                                                            products.length,
                                                        (BuildContext context,
                                                            int index) {
                                                          return InkWell(
                                                            onTap: () {
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
                                                                        products[index]
                                                                            .name
                                                                            .toString(),
                                                                    productCategoriesId: products[
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
                                                                      .push(MaterialPageRoute(
                                                                          builder: (ctx) => ProductDetailsPage(
                                                                                productItem: products[index],
                                                                              ))));
                                                            },
                                                            child: _productItem(
                                                                index: index,
                                                                slidingMode:
                                                                    slidingMode),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                        BlocBuilder<BoutiqueBloc,
                                                BoutiqueState>(
                                            buildWhen: (previous, current) =>
                                                previous
                                                    .isGettingProductListingWithPagination !=
                                                current
                                                    .isGettingProductListingWithPagination,
                                            builder: (context, state) {
                                              if (state
                                                  .isGettingProductListingWithPagination) {
                                                return SliverToBoxAdapter(
                                                  child: Center(
                                                    child: TrydosLoader(),
                                                  ),
                                                );
                                              }
                                              return SliverToBoxAdapter();
                                            })
                                      ]);
                                },
                              );
                            });
                      }),
                ),
              ),
              Positioned(
                top: 10,
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
                                  height: 40,
                                  width: 140,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x19000000),
                                          offset: Offset(0, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                      color: Color(0xff505050)),
                                  child: Center(
                                    child: MyTextWidget(
                                      title ?? '',
                                      style: textTheme.titleLarge?.rq.copyWith(
                                          color: colorScheme.white,
                                          height: 18 / 14),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 140,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                        color: Colors.white.withOpacity(0.16),
                                        inset: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                  ],
                ),
              ),
              ValueListenableBuilder<int>(
                  valueListenable: tapIndexToAddProductToCart,
                  builder: (context, tapIndex, _) {
                    if (tapIndex != -1) {
                      homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
                          isChangedvariationWhenQtyZero: false));

                      /* homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
                          isChangedvariationWhenQtyZero: false));
                      currentSelectedColorAfterChangeVariant = -1;*/
                      changeAppearSizeForProduct = true;

                      homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
                          fromListingPage: true,
                          productSlug: products[tapIndex].slug,
                          productId: products[tapIndex].productId.toString()));

                      loadingForRquestProductDetails.value = true;
                      Future.delayed(Duration(milliseconds: 600),
                          () => loadingForRquestProductDetails.value = false);
                    } else {
                      currentActiveTab.value = 0;

                      return SizedBox.shrink();
                    }
                    return ValueListenableBuilder<bool>(
                        valueListenable: loadingForRquestProductDetails,
                        builder: (context, _loadingForRquestProductDetails, _) {
                          return Positioned(
                              bottom: -20.h,
                              child: _loadingForRquestProductDetails
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      child: TrydosLoader(
                                        size: 15,
                                      ),
                                    )
                                  : Container(
                                      height: tapIndex == -1 ? 0 : 1.sh,
                                      width: 1.sw,
                                      child: BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (previous, current) =>
                                              previous.currentSelectedColorForEveryProduct != current.currentSelectedColorForEveryProduct ||
                                              previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                                  current
                                                      .getProductDetailWithoutSimilarRelatedProductsStatus ||
                                              previous.getCartOverviewStatus !=
                                                  current
                                                      .getCartOverviewStatus ||
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
                                            String productId =
                                                products[tapIndex]
                                                    .productId
                                                    .toString();

                                            currentSelectedColor =
                                                state.currentSelectedColorForEveryProduct[
                                                        productId] ??
                                                    (products[tapIndex]
                                                                .syncColorImages
                                                                ?.length ??
                                                            0) ~/
                                                        2;

                                            if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                                        .failure &&
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
                                                Duration(seconds: 5),
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
                                                                  .toString()));
                                                },
                                              );
                                            }
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                      GetProductDetailWithoutSimilarRelatedProductsStatus
                                                          .success &&
                                                  tapIndex != -1)) {
                                                if (state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.countryIsRestricted ==
                                                    true) {
                                                  productNotAvailableNotifier
                                                          .value =
                                                      LocaleKeys
                                                          .product_is_not_available_in_your_country
                                                          .tr();
                                                } else if (state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.availableQuantity ==
                                                    false) {
                                                  productNotAvailableNotifier
                                                          .value =
                                                      LocaleKeys
                                                          .this_product_is_not_available_in_store
                                                          .tr();
                                                } else {
                                                  productNotAvailableNotifier
                                                      .value = null;
                                                }
                                              }
                                            });
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              if (state
                                                      .getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                  GetProductDetailWithoutSimilarRelatedProductsStatus
                                                      .failure) {
                                                tapIndexToAddProductToCart
                                                    .value = -1;
                                              }
                                            });
                                            homeBloc.add(AddSizesForColorsEvent(
                                                currentColorName:
                                                    !products[tapIndex]
                                                            .colors
                                                            .isNullOrEmpty
                                                        ? products[tapIndex].colors![currentSelectedColor].name ??
                                                            ""
                                                        : "",
                                                variation: state.cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()] !=
                                                        null
                                                    ? state
                                                                .cachedProductWithoutRelatedProductsModel[
                                                                    products[tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                .product !=
                                                            null
                                                        ? state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                            .product!
                                                            .variation
                                                        : null
                                                    : null));
                                            if (productId != "" &&
                                                tapIndex != -1 &&
                                                state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                                        .success &&
                                                changeAppearSizeForProduct) {
                                              if (!state
                                                      .cachedProductWithoutRelatedProductsModel
                                                      .containsKey(productId) ||
                                                  (state.cachedProductWithoutRelatedProductsModel[
                                                              productId] !=
                                                          null
                                                      ? state
                                                                  .cachedProductWithoutRelatedProductsModel[
                                                                      productId]!
                                                                  .product !=
                                                              null
                                                          ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productId]!
                                                              .product!
                                                              .choiceOptions
                                                              .isNullOrEmpty
                                                          : true
                                                      : true)) {
                                                homeBloc.add(
                                                    AddCurrentColorSizeEvent(
                                                        choice_1: null));
                                              } else if (!(state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                          productId] !=
                                                      null
                                                  ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productId]!
                                                              .product !=
                                                          null
                                                      ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productId]!
                                                          .product!
                                                          .choiceOptions
                                                          .isNullOrEmpty
                                                      : true
                                                  : true)) {
                                                String sizeSelect = (state
                                                                .cachedProductWithoutRelatedProductsModel[
                                                                    productId]!
                                                                .product!
                                                                .choiceOptions
                                                                ?.length ??
                                                            0) ==
                                                        0
                                                    ? ""
                                                    : state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                productId]!
                                                            .product!
                                                            .choiceOptions![0]
                                                            .options?[(state
                                                                        .cachedProductWithoutRelatedProductsModel[
                                                                            productId]!
                                                                        .product
                                                                        ?.choiceOptions?[
                                                                            0]
                                                                        .options
                                                                        ?.length ??
                                                                    0) ~/
                                                                2]
                                                            .name ??
                                                        "";

                                                homeBloc.add(
                                                    AddCurrentColorSizeEvent(
                                                        choice_1: sizeSelect));
                                              }
                                              homeBloc.add(
                                                  IsChangedvariationWhenQtyZeroEvent(
                                                      isChangedvariationWhenQtyZero:
                                                          true));
                                              /*   String currentSelectedColorName =
                                                  ((products[tapIndex]
                                                                  .colors
                                                                  ?.length ??
                                                              0) >
                                                          0)
                                                      ? products[tapIndex]
                                                              .colors![
                                                                  currentSelectedColor]
                                                              .name ??
                                                          ""
                                                      : "";
                                          String currentVariantType =
                                                  "${currentSelectedColorName != "" ? currentSelectedColorName : ""}" +
                                                      "${(state.currentColorSizeForCart?["size"] != null && (state.cachedProductWithoutRelatedProductsModel[productId]?.product?.choiceOptions?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["size"] != "") && (currentSelectedColorName != "") ? "-" : ""}" +
                                                      "${(state.currentColorSizeForCart?["size"] != null && (state.cachedProductWithoutRelatedProductsModel[productId]?.product?.choiceOptions?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["size"] != "") ? "${state.currentColorSizeForCart?["size"]}" : ""}";

                                                productDetail.Variation?
                                                currentVariation = state
                                                      .cachedProductWithoutRelatedProductsModel[
                                                          productId]
                                                      ?.product
                                                      ?.variation
                                                      ?.firstWhere(
                                                (element) => element.type!
                                                    .contains(
                                                        currentVariantType),
                                                orElse: () {
                                                  return productDetail
                                                      .Variation(
                                                          variantNotifyForUser:
                                                              false);
                                                },
                                              );*/

                                              /* changeVariationWhenNotAvailable(
                                                  sizesForEachColor:
                                                      state.sizesForEachColor ??
                                                          [],
                                                  products: products[tapIndex],
                                                  tapIndex: tapIndex,
                                                  currentVariation:
                                                      currentVariation,
                                                  product: state
                                                      .cachedProductWithoutRelatedProductsModel[
                                                          productId]
                                                      ?.product,
                                                  productId: productId);*/
                                              currentActiveTab.value = 3;
                                              Future.delayed(
                                                  Duration(milliseconds: 600),
                                                  () {
                                                panelControllerForCart.open();
                                                changeAppearSizeForProduct =
                                                    false;
                                              });
                                            }

                                            return state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                        GetProductDetailWithoutSimilarRelatedProductsStatus
                                                            .loading ||
                                                    state.enableAddToCardAfterChangeVariantZero !=
                                                        EnableAddToCardAfterChangeVariantZero
                                                            .success
                                                ? Container(
                                                    width: 1.sw,
                                                    height: 1.sh,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.3),
                                                    child: TrydosLoader(
                                                      size: 25,
                                                    ),
                                                  )
                                                : ProductDetailsBottomSheet(
                                                    isGetFullProductDetails:
                                                        false,
                                                    productNotAvailableNotifier:
                                                        productNotAvailableNotifier,
                                                    currentActiveTab:
                                                        currentActiveTab,
                                                    qtyForproductWithoutVariant:
                                                        state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.availableQuantity,
                                                    collectedAfterOrdering: state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.collectedAfterOrdering ==
                                                        1,
                                                    tapIndexToAddProductToCart:
                                                        tapIndexToAddProductToCart,
                                                    fromListingPage: true,
                                                    productIdForCashData:
                                                        products[tapIndex]
                                                            .productId
                                                            .toString(),
                                                    panelController:
                                                        panelControllerForCart,
                                                    productSlugForTopic: state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.slugEnTopic ??
                                                        "",
                                                    productDescription: HtmlParser
                                                            .parseHTML(products[
                                                                        tapIndex]
                                                                    .details ??
                                                                "")
                                                        .text,
                                                    countOfPieces: state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()] !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product !=
                                                                null
                                                            ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product!
                                                                    .countOfPieces ??
                                                                0
                                                            : 0
                                                        : 0,
                                                    addToBagButtonShapeNotifier:
                                                        addToBagButtonShapeNotifier,
                                                    currentColornum: products[
                                                                tapIndex]
                                                            .colors
                                                            .isNullOrEmpty
                                                        ? ''
                                                        : products[tapIndex]
                                                                .colors![
                                                                    currentSelectedColor]
                                                                .color ??
                                                            "",
                                                    boutiqueIcon: state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                products[tapIndex]
                                                                    .productId
                                                                    .toString()] !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product !=
                                                                null
                                                            ? state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                            .productId
                                                                            .toString()]!
                                                                        .product!
                                                                        .boutique !=
                                                                    null
                                                                ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique!.icon !=
                                                                        null
                                                                    ? state
                                                                            .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
                                                                            .product!
                                                                            .boutique!
                                                                            .icon!
                                                                            .filePath ??
                                                                        ""
                                                                    : ""
                                                                : ""
                                                            : ""
                                                        : "",
                                                    boutiqueId: state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()] !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product !=
                                                                null
                                                            ? state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                            .productId
                                                                            .toString()]!
                                                                        .product!
                                                                        .boutique !=
                                                                    null
                                                                ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product!
                                                                    .boutique!
                                                                    .id!
                                                                : 0
                                                            : 0
                                                        : 0,
                                                    currentColorName: products[
                                                                tapIndex]
                                                            .colors
                                                            .isNullOrEmpty
                                                        ? ''
                                                        : products[tapIndex]
                                                                .colors![
                                                                    currentSelectedColor]
                                                                .name ??
                                                            "",
                                                    productItem:
                                                        products[tapIndex],
                                                    currentColor:
                                                        currentSelectedColor,
                                                    maxAllowedToAddCart: state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.maxAllowedQty ??
                                                        "0",
                                                  );
                                          }),
                                    ));
                        });
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductList({
    required List<productListingModel.Products> products,
    required Tuple2<int, int> slidingMode,
  }) {
    return SliverPadding(
      key: TestVariables.kTestMode ? Key(WidgetsKeys.productsListKey) : null,
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 200.w / 350,
          crossAxisSpacing: 10,
          mainAxisSpacing: 15,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: products.length,
          (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Future.delayed(
                  Duration(milliseconds: 100),
                ).then(
                  (value) {
                    FirebaseAnalyticsService.logEventForViewedProduct(
                      eventName: AnalyticsEventsConst.viewedProduct,
                      productId: products[index].productId.toString(),
                      productName: products[index].name.toString(),
                      productCategoriesId: products[index]
                          .categories
                          ?.map(
                            (e) => e.id.toString(),
                          )
                          .toList(),
                    );
                  },
                );
                ////////////////////////////
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.buttonClicked,
                  executedEventName:
                      AnalyticsExecutedEventNameConst.chooseProductButton,
                );

                homeBloc.add(ChangeStatusOFGetProductsDetailsToSuccessEvent(
                    isStatusInitaial: true));

                Future.delayed(
                    Duration(milliseconds: 300),
                    () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ProductDetailsPage(
                              productItem: products[index],
                            ),
                          ),
                        ));
              },
              child: _productItem(index: index, slidingMode: slidingMode),
            );
          },
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
    print(
        "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss${currentVariation?.qty}sssssssssssssss4${currentVariation?.type}");
    changeVariationIfQtyZero = false;

    if (currentVariation?.qty != null && currentVariation?.qty == 0) {
      print(
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
        print(
            "s222ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss4${currentVariation?.type}");

        currentSelectedColorAfterChangeVariant = currentSelectedColor;
        currentVariation =
            product?.variation?.firstWhere((element) => (element.qty ?? 0) > 0);
        print(
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
        print(
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
  Widget _productItem(
      {required Tuple2<int, int> slidingMode, required int index}) {
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
            ))*/
        ProductItem(
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
    );
  }
}
