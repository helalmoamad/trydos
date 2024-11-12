import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:mime/mime.dart';
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
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter_products;
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/search/presentation/widgets/search_with_image_related_gemini.dart';
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
import '../manager/home_bloc.dart';
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
  final boutiques.Boutique? boutique;
  final TextEditingController? controllerFormSearchPage;
  final bool fromSearch;
  final String? searchText;

  const ProductListingPage({
    super.key,
    required this.boutiqueSlug,
    this.boutiqueDescription,
    this.controllerFormSearchPage,
    this.searchText,
    this.withSlidingImages = false,
    this.boutique,
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
  double? _previousOffset;
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ValueNotifier<bool> searchVisible = ValueNotifier(true);

  final TextEditingController controller = TextEditingController();
  Timer? timerForDisplayFilterSectionTitle;
  final GlobalKey htmlDescriptionKey = GlobalKey();
  final ValueNotifier<double> htmlDescriptionHeight = ValueNotifier(0);
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final ValueNotifier<bool> fromSearchListing = ValueNotifier(false);
  bool isExpanded = false;
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

  void _startListening() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    await _speechToText.listen(
      listenFor: Duration(seconds: 7),
      onResult: (result) {
        if (result.recognizedWords.replaceAll(" ", "").length > 2) {
          controller.text = result.recognizedWords;
          Filter filters = BlocProvider.of<HomeBloc>(context)
                  .state
                  .choosedFiltersByUser[
                      widget.boutiqueSlug + (widget.category ?? "")]
                  ?.filters ??
              Filter();
          BlocProvider.of<HomeBloc>(context).add(ChangeSelectedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              fromHomePageSearch: true,
              filtersChoosedByUser: GetProductFiltersModel(
                  filters: filters.copyWithSaveOtherField(
                prices: filters.prices,
                searchText: result.recognizedWords,
              ))));
          BlocProvider.of<HomeBloc>(context).add(ChangeAppliedFiltersEvent(
            boutiqueSlug: widget.boutiqueSlug,
            category: widget.category,
            filtersAppliedByUser: GetProductFiltersModel(
                filters: filters.copyWithSaveOtherField(
              prices: filters.prices,
              searchText: result.recognizedWords,
            )),
          ));
          BlocProvider.of<HomeBloc>(context).add(GetProductsWithFiltersEvent(
              offset: 1,
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              resetChoosedFilters: false,
              fromSearch: true,
              searchText: result.recognizedWords));
          _stopListening();
          return;
        }
      },
    );
    isRecordeForSearchWithMic.value = true;
    Future.delayed(
      Duration(seconds: 5),
      () => isRecordeForSearchWithMic.value = false,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();

    isRecordeForSearchWithMic.value = false;
  }

  @override
  void initState() {
    print("%%%%%%%%%${GetIt.I<PrefsRepository>().marketToken}*");
    print(
        "##############################//////////////////////////////////////////////////////////////////////////#${widget.boutiqueSlug}");
    itExpendForFirst = true;
    key = widget.boutiqueSlug + (widget.category ?? '');
    keyWithoutFilter = '${widget.boutiqueSlug}' +
        '${(!widget.fromSearch) ? 'withoutFilter' : ""}' +
        '${(widget.category ?? '')}';
    fromSearch = widget.fromSearch;
    searchVisible.value = false;
    if ((widget.searchText?.length ?? 0) > 2) {
      controller.text = widget.searchText!;
      resetSearchAfterSearchingWhileRemoveSearch = true;
    }
    Timer.periodic(Duration(milliseconds: 100), postFrameCallback);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
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
    if (homeBloc.state.boutiquesThatDidPrefetch[key] == true &&
        homeBloc.boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[
                key] ==
            null) {
      homeBloc.boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[key] =
          true;
      homeBloc.PrefetchProductsForFirstFiveFilter(
          boutiqueSlug: widget.boutiqueSlug,
          categorySlug: widget.category,
          filter: homeBloc.state.getProductFiltersModel[key]?.filters);
    } else if (homeBloc.state.boutiquesThatDidPrefetch[key] == null) {
      homeBloc.boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[key] =
          true;
    }

    if (!widget.fromSearch) {
      homeBloc.add(GetProductsWithFiltersEvent(
          getWithoutFilter: true,
          cashedOrginalBoutique: !widget.fromSearch,
          boutiqueSlug: widget.boutiqueSlug,
          fromSearch: widget.fromSearch,
          category: widget.category,
          searchText: widget.fromSearch ? widget.searchText : null,
          offset: 1));
    }
    scrollController.addListener(() {
      if (homeBloc.state.isExpandedForListingPage ?? false) return;
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
        if (homeBloc.state.isGettingProductListingWithPagination) return;

        if (homeBloc
            .state
            .getProductListingWithFiltersPaginationModels[
                '${widget.boutiqueSlug}' +
                    ((homeBloc.state.cashedOrginalBoutique)
                        ? 'withoutFilter'
                        : "") +
                    '${(widget.category ?? '')}']!
            .hasReachedMax) {
          return;
        }
        homeBloc.add(GetProductsWithFiltersEvent(
            limit: 10,
            cashedOrginalBoutique: !widget.fromSearch,
            boutiqueSlug: widget.boutiqueSlug,
            getWithPagination: true,
            fromSearch: widget.fromSearch,
            category: widget.category,
            searchText: widget.fromSearch ? widget.searchText : null,
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
    homeBloc.add(ReplyFromGeminiEvent(
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        homeBloc.add(ReplyFromGeminiEvent(
            fromSearch: false,
            sendRequestToGeminiStatus: SendRequestToGeminiStatus.success,
            theReplyFromGemini: ""));
        if (widget.fromSearch) {
          widget.controllerFormSearchPage?.text = controller.text;
        }

        itExpendForFirst = false;

        searchVisible.value = false;
        if (homeBloc.state.isExpandedForListingPage ?? false) {
          prefAppliedFilters =
              homeBloc.state.prefAppliedFilterForExtendFilter ?? Filter();

          // homeBloc.add(GetProductFiltersEvent(
          //     fromHomePageSearch: widget.fromSearch,
          //     cashedOrginalBoutique: false,
          //     boutiqueSlug: widget.boutiqueSlug,
          //     category: widget.category,
          //     searchText: widget.searchText,
          //     filtersChoosedByUser:
          //         GetProductFiltersModel(filters: prefAppliedFilters)));
          homeBloc.add(ChangeAppliedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersAppliedByUser:
                  GetProductFiltersModel(filters: prefAppliedFilters)));
          controller.text = prefAppliedFilters!.searchText ?? "";

          resetSearchAfterSearchingWhileRemoveSearch = false;

          homeBloc.add(
              AddIsExpandedForLidtingPageEvent(isExpandedForLidting: false));

          ////////////////////////////////////
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
          );

          return Future.value(false);
        } else {
          if (!widget.fromSearch) {
            homeBloc.add(ChangeAppliedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersAppliedByUser: null,
              resetAppliedFilters: true,
            ));
            homeBloc.add(ChangeSelectedFiltersEvent(
              fromHomePageSearch: widget.fromSearch,
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersChoosedByUser: null,
            ));
          }
          if (widget.fromSearch) {
            homeBloc.add(ChangeSelectedFiltersEvent(
              requestToUpdateFilters: false,
              fromHomePageSearch: widget.fromSearch,
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersChoosedByUser: GetProductFiltersModel(
                  filters: homeBloc.state.appliedFiltersByUser[key]?.filters),
            ));
            homeBloc.add(
              ChangeAppliedFiltersEvent(
                boutiqueSlug: widget.boutiqueSlug,
                category: widget.category,
                resetAppliedFilters: true,
              ),
            );
          }
          if (widget.fromSearch ||
              (!widget.fromSearch &&
                  homeBloc.state.cashedOrginalBoutique == true)) {
            context.pop();
          }
          ////////////////////////////////////
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
          );
        }

        return Future.value(true);
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
                              return state.hideBottomNavigationBar
                                  ? const SizedBox.shrink()
                                  : const AppBottomNavBar();
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
                        !(homeBloc.state.isExpandedForListingPage ?? false) &&
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
                        return BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (p, c) =>
                              p.isExpandedForListingPage !=
                                  c.isExpandedForListingPage ||
                              ((p.sendRequestToGeminiStatus !=
                                          c.sendRequestToGeminiStatus ||
                                      p.theReplyFromGemini !=
                                          c.theReplyFromGemini) &&
                                  c.fromSearchForSearchWithGemini == false),
                          builder: (context, state) {
                            if (state.theReplyFromGemini != "" &&
                                state.fromSearchForSearchWithGemini == false) {
                              print(
                                  "///////////////////////***********${widget.fromSearch}****##########################${widget.boutiqueSlug}");
                              controller.text = state.theReplyFromGemini ?? "";
                              Filter filters =
                                  BlocProvider.of<HomeBloc>(context)
                                          .state
                                          .choosedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                              BlocProvider.of<HomeBloc>(context).add(
                                  ChangeSelectedFiltersEvent(
                                      requestToUpdateFilters: false,
                                      boutiqueSlug: widget.boutiqueSlug,
                                      category: widget.category,
                                      fromHomePageSearch: widget.fromSearch,
                                      filtersChoosedByUser:
                                          GetProductFiltersModel(
                                              filters: filters
                                                  .copyWithSaveOtherField(
                                        prices: filters.prices,
                                        searchText: state.theReplyFromGemini,
                                      ))));
                              BlocProvider.of<HomeBloc>(context)
                                  .add(ChangeAppliedFiltersEvent(
                                boutiqueSlug: widget.boutiqueSlug,
                                category: widget.category,
                                filtersAppliedByUser: GetProductFiltersModel(
                                    filters: filters.copyWithSaveOtherField(
                                  prices: filters.prices,
                                  searchText: state.theReplyFromGemini,
                                )),
                              ));
                              BlocProvider.of<HomeBloc>(context).add(
                                  GetProductsWithFiltersEvent(
                                      offset: 1,
                                      boutiqueSlug: widget.boutiqueSlug,
                                      category: widget.category,
                                      resetChoosedFilters: false,
                                      fromSearch: widget.fromSearch,
                                      searchText: state.theReplyFromGemini));
                            }
                            print(
                                'statusssss ${state.getProductListingWithFiltersPaginationModels['women-section-67withoutFilter']?.paginationStatus}');
                            if (!(state.isExpandedForListingPage ?? false) &&
                                !itExpendForFirst) {
                              homeBloc.add(GetProductsWithFiltersEvent(
                                  cashedOrginalBoutique: fromSearch ?? false,
                                  boutiqueSlug: widget.boutiqueSlug,
                                  fromSearch: widget.fromSearch,
                                  category: widget.category,
                                  searchText: widget.fromSearch
                                      ? widget.searchText
                                      : null,
                                  offset: 1));
                            }
                            isExpanded =
                                state.isExpandedForListingPage ?? false;

                            return CustomScrollView(
                                key: TestVariables.kTestMode
                                    ? Key(WidgetsKey.productListingScrollKey)
                                    : null,
                                controller: scrollController,
                                physics: state.getProductFiltersModel[key]
                                                ?.filters?.totalSize ==
                                            0 &&
                                        isExpanded
                                    ? NeverScrollableScrollPhysics()
                                    : ClampingScrollPhysics(),
                                slivers: [
                                  SliverAppBar(
                                      pinned: true,
                                      backgroundColor: colorScheme.white,
                                      automaticallyImplyLeading: false,
                                      flexibleSpace:
                                          ValueListenableBuilder<bool>(
                                              valueListenable: searchVisible,
                                              builder:
                                                  (context, searchOpen, _) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5, left: 5),
                                                  child: TrydosAppBar(
                                                    appBarParams: AppBarParams(
                                                        onBack: () {
                                                          homeBloc.add(ReplyFromGeminiEvent(
                                                              fromSearch: false,
                                                              sendRequestToGeminiStatus:
                                                                  SendRequestToGeminiStatus
                                                                      .success,
                                                              theReplyFromGemini:
                                                                  ""));
                                                          if (widget
                                                              .fromSearch) {
                                                            widget.controllerFormSearchPage
                                                                    ?.text =
                                                                controller.text;
                                                            homeBloc.add(ChangeAppliedFiltersEvent(
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                                category: widget
                                                                    .category,
                                                                filtersAppliedByUser: GetProductFiltersModel(
                                                                    filters: homeBloc
                                                                        .state
                                                                        .appliedFiltersByUser[
                                                                            key]
                                                                        ?.filters),
                                                                resetAppliedFilters:
                                                                    false));
                                                            homeBloc.add(
                                                                ChangeSelectedFiltersEvent(
                                                              fromHomePageSearch:
                                                                  widget
                                                                      .fromSearch,
                                                              boutiqueSlug: widget
                                                                  .boutiqueSlug,
                                                              category: widget
                                                                  .category,
                                                              filtersChoosedByUser:
                                                                  GetProductFiltersModel(
                                                                      filters: homeBloc
                                                                          .state
                                                                          .appliedFiltersByUser[
                                                                              key]
                                                                          ?.filters),
                                                            ));
                                                          }
                                                          if (!widget
                                                              .fromSearch) {
                                                            homeBloc.add(
                                                                ChangeSelectedFiltersEvent(
                                                              fromHomePageSearch:
                                                                  widget
                                                                      .fromSearch,
                                                              requestToUpdateFilters:
                                                                  false,
                                                              boutiqueSlug: widget
                                                                  .boutiqueSlug,
                                                              category: widget
                                                                  .category,
                                                              filtersChoosedByUser:
                                                                  GetProductFiltersModel(
                                                                      filters: homeBloc
                                                                          .state
                                                                          .appliedFiltersByUser[
                                                                              key]
                                                                          ?.filters),
                                                            ));
                                                            homeBloc.add(ChangeAppliedFiltersEvent(
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                                category: widget
                                                                    .category,
                                                                resetAppliedFilters:
                                                                    true));
                                                          }
                                                        },
                                                        backgroundColor:
                                                            colorScheme.white,
                                                        scrolledUnderElevation:
                                                            0,
                                                        backIconColor:
                                                            Colors.black,
                                                        hasLeading:
                                                            !isExpanded &&
                                                                !searchOpen,
                                                        action: [
                                                          Spacer(),
                                                          ValueListenableBuilder<
                                                                  bool>(
                                                              valueListenable:
                                                                  displayBoutiqueIconInAppBar,
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .only(
                                                                        start: 30
                                                                            .w),
                                                                child: widget
                                                                            .boutiqueIcon !=
                                                                        null
                                                                    ? SvgNetworkWidget(
                                                                        svgUrl:
                                                                            widget.boutiqueIcon ??
                                                                                "",
                                                                        height:
                                                                            20,
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                              ),
                                                              builder: (context,
                                                                  display,
                                                                  child) {
                                                                return display
                                                                    ? child!
                                                                    : SizedBox
                                                                        .shrink();
                                                              }),
                                                          Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .only(
                                                                    end: searchOpen
                                                                        ? 10
                                                                        : 20.0),
                                                            child:
                                                                AnimatedSearchBar(
                                                              key: TestVariables
                                                                      .kTestMode
                                                                  ? Key(WidgetsKey
                                                                      .productListingSearchInputKey)
                                                                  : null,
                                                              autoFocus: false,
                                                              width: isExpanded
                                                                  ? (1.sw - 90)
                                                                  : (1.sw -
                                                                      120),
                                                              height: 40,
                                                              onClickClose: () {
                                                                if (!isExpanded &&
                                                                    controller
                                                                        .text
                                                                        .isNotEmpty) {
                                                                  Filter filters = homeBloc
                                                                          .state
                                                                          .appliedFiltersByUser[
                                                                              key]
                                                                          ?.filters ??
                                                                      Filter();
                                                                  homeBloc.add(ChangeAppliedFiltersEvent(
                                                                      boutiqueSlug:
                                                                          widget
                                                                              .boutiqueSlug,
                                                                      category:
                                                                          widget
                                                                              .category,
                                                                      filtersAppliedByUser:
                                                                          GetProductFiltersModel(
                                                                              filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                  homeBloc.add(
                                                                      GetProductsWithFiltersEvent(
                                                                    offset: 1,
                                                                    searchText:
                                                                        null,
                                                                    fromSearch:
                                                                        fromSearch,
                                                                    category: widget
                                                                        .category,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                  ));
                                                                }
                                                                if (isExpanded &&
                                                                    controller
                                                                        .text
                                                                        .isNotEmpty) {
                                                                  Filter filters = homeBloc
                                                                          .state
                                                                          .choosedFiltersByUser[
                                                                              key]
                                                                          ?.filters ??
                                                                      Filter();
                                                                  homeBloc.add(ChangeSelectedFiltersEvent(
                                                                      fromHomePageSearch:
                                                                          widget
                                                                              .fromSearch,
                                                                      boutiqueSlug:
                                                                          widget
                                                                              .boutiqueSlug,
                                                                      filtersChoosedByUser:
                                                                          GetProductFiltersModel(
                                                                              filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                }

                                                                resetSearchAfterSearchingWhileRemoveSearch =
                                                                    false;
                                                                focusNode
                                                                    .unfocus();

                                                                searchVisible
                                                                        .value =
                                                                    false;

                                                                controller
                                                                    .clear();
                                                                appBloc.add(
                                                                    HideBottomNavigationBar(
                                                                        false));
                                                                ///////////////////////////
                                                                FirebaseAnalyticsService
                                                                    .logEventForSession(
                                                                  eventName:
                                                                      AnalyticsEventsConst
                                                                          .buttonClicked,
                                                                  executedEventName:
                                                                      AnalyticsExecutedEventNameConst
                                                                          .resetCloseIconButton,
                                                                );
                                                                return false;
                                                              },
                                                              textController:
                                                                  controller,
                                                              focusNode:
                                                                  focusNode,
                                                              onSuffixTap: () {
                                                                WidgetsBinding
                                                                    .instance
                                                                    .addPostFrameCallback(
                                                                        (timeStamp) {
                                                                  searchVisible
                                                                          .value =
                                                                      true;
                                                                });
                                                              },
                                                              suffixWidget:
                                                                  Center(
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  AppAssets
                                                                      .searchOutlinedSvg,
                                                                  height: 20,
                                                                  width: 20,
                                                                  color: Color(
                                                                      0xff388CFF),
                                                                ),
                                                              ),
                                                              prefixWidget:
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            15,
                                                                        top: 10,
                                                                        bottom:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        SearchWithImageRelatedGemini.SelecteImageForSearch(
                                                                            fromSearch:
                                                                                false,
                                                                            context:
                                                                                context);
                                                                        /////////////////////////////
                                                                        FirebaseAnalyticsService
                                                                            .logEventForSession(
                                                                          eventName:
                                                                              AnalyticsEventsConst.buttonClicked,
                                                                          executedEventName:
                                                                              AnalyticsExecutedEventNameConst.searchWithImageButton,
                                                                        );
                                                                      },
                                                                      child: state.sendRequestToGeminiStatus ==
                                                                              SendRequestToGeminiStatus.loading
                                                                          ? TrydosLoader(
                                                                              size: 18,
                                                                            )
                                                                          : SvgPicture.asset(
                                                                              AppAssets.realCameraSvg,
                                                                              height: 20,
                                                                              width: 20,
                                                                            ),
                                                                    ),
                                                                    ValueListenableBuilder<
                                                                        bool>(
                                                                      valueListenable:
                                                                          isRecordeForSearchWithMic,
                                                                      builder: (context,
                                                                          recordeForSearchWithMic,
                                                                          _) {
                                                                        return InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            final status =
                                                                                await Permission.microphone.request();
                                                                            if (status !=
                                                                                PermissionStatus.granted) {
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
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                20,
                                                                            child: Icon(_speechToText.isNotListening || !recordeForSearchWithMic
                                                                                ? Icons.mic_off
                                                                                : Icons.mic),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              animationDurationInMilli:
                                                                  400,
                                                              searchDecoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: focusNode
                                                                              .hasFocus
                                                                          ? Color(
                                                                              0xffE6E6E6)
                                                                          : Color(
                                                                              0xffF8F8F8),
                                                                      width:
                                                                          0.4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              kbrBorderTextField),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: focusNode
                                                                              .hasFocus
                                                                          ? Color(
                                                                              0xffE6E6E6)
                                                                          : Color(
                                                                              0xffF8F8F8),
                                                                      width:
                                                                          0.4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              kbrBorderTextField),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: focusNode
                                                                              .hasFocus
                                                                          ? Color(
                                                                              0xffE6E6E6)
                                                                          : Color(
                                                                              0xffF8F8F8),
                                                                      width:
                                                                          0.4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              kbrBorderTextField),
                                                                ),
                                                                disabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: focusNode
                                                                              .hasFocus
                                                                          ? Color(
                                                                              0xffE6E6E6)
                                                                          : Color(
                                                                              0xffF8F8F8),
                                                                      width:
                                                                          0.4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              kbrBorderTextField),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: context
                                                                          .colorScheme
                                                                          .error,
                                                                      width:
                                                                          0.4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              kbrBorderTextField),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: context
                                                                          .colorScheme
                                                                          .error,
                                                                      width:
                                                                          0.4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              kbrBorderTextField),
                                                                ),
                                                                filled: true,
                                                                fillColor: focusNode
                                                                        .hasFocus
                                                                    ? colorScheme
                                                                        .white
                                                                    : Color(
                                                                        0xffF8F8F8),
                                                                prefixIcon:
                                                                    Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              12,
                                                                          bottom:
                                                                              12),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AppAssets
                                                                        .searchOutlinedSvg,
                                                                    height: 20,
                                                                    width: 20,
                                                                    color: Color(
                                                                        0xff388CFF),
                                                                  ),
                                                                ),
                                                                suffixIcon:
                                                                    Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      right: 15,
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          SearchWithImageRelatedGemini.SelecteImageForSearch(
                                                                              fromSearch: false,
                                                                              context: context);
                                                                          /////////////////////////////
                                                                          FirebaseAnalyticsService
                                                                              .logEventForSession(
                                                                            eventName:
                                                                                AnalyticsEventsConst.buttonClicked,
                                                                            executedEventName:
                                                                                AnalyticsExecutedEventNameConst.searchWithImageButton,
                                                                          );
                                                                        },
                                                                        child: state.sendRequestToGeminiStatus ==
                                                                                SendRequestToGeminiStatus.loading
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
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      ValueListenableBuilder<
                                                                          bool>(
                                                                        valueListenable:
                                                                            isRecordeForSearchWithMic,
                                                                        builder: (context,
                                                                            recordeForSearchWithMic,
                                                                            _) {
                                                                          return InkWell(
                                                                            onTap:
                                                                                () async {
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
                                                                            child:
                                                                                Container(
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
                                                                contentPadding:
                                                                    HWEdgeInsetsDirectional.only(
                                                                        start:
                                                                            20,
                                                                        end: 10,
                                                                        bottom:
                                                                            12,
                                                                        top:
                                                                            12),
                                                                hintText:
                                                                    'Search',
                                                                hintStyle: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.lq
                                                                    .copyWith(
                                                                        color: Color(
                                                                            0xffC4C2C2)),
                                                                labelStyle: context
                                                                    .textTheme
                                                                    .titleLarge
                                                                    ?.copyWith(
                                                                        color: context
                                                                            .colorScheme
                                                                            .hint),
                                                              ),
                                                              onChanged: (String
                                                                  text) {
                                                                if (isExpanded) {
                                                                  Filter filters = homeBloc
                                                                          .state
                                                                          .choosedFiltersByUser[
                                                                              key]
                                                                          ?.filters ??
                                                                      Filter();
                                                                  if (text.length >
                                                                      2) {
                                                                    resetSearchAfterSearchingWhileRemoveSearch =
                                                                        true;
                                                                    homeBloc.add(ChangeSelectedFiltersEvent(
                                                                        fromHomePageSearch:
                                                                            widget
                                                                                .fromSearch,
                                                                        boutiqueSlug:
                                                                            widget
                                                                                .boutiqueSlug,
                                                                        filtersChoosedByUser:
                                                                            GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: text))));
                                                                  }
                                                                  if (text.length <
                                                                          3 &&
                                                                      resetSearchAfterSearchingWhileRemoveSearch) {
                                                                    resetSearchAfterSearchingWhileRemoveSearch =
                                                                        false;
                                                                    homeBloc.add(ChangeSelectedFiltersEvent(
                                                                        fromHomePageSearch:
                                                                            widget
                                                                                .fromSearch,
                                                                        boutiqueSlug:
                                                                            widget
                                                                                .boutiqueSlug,
                                                                        filtersChoosedByUser:
                                                                            GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                  }
                                                                  return;
                                                                }
                                                                if (text.length >
                                                                    2) {
                                                                  print(
                                                                      "----------++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                                                                  resetSearchAfterSearchingWhileRemoveSearch =
                                                                      true;
                                                                  Filter filters = homeBloc
                                                                          .state
                                                                          .appliedFiltersByUser[
                                                                              key]
                                                                          ?.filters ??
                                                                      Filter();
                                                                  homeBloc.add(
                                                                      ChangeAppliedFiltersEvent(
                                                                    category: widget
                                                                        .category,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                    filtersAppliedByUser:
                                                                        GetProductFiltersModel(
                                                                            filters:
                                                                                filters.copyWithSaveOtherField(
                                                                      prices: filters
                                                                          .prices,
                                                                      searchText:
                                                                          text,
                                                                    )),
                                                                  ));
                                                                  homeBloc.add(
                                                                      GetProductsWithFiltersEvent(
                                                                    offset: 1,
                                                                    searchText:
                                                                        text,
                                                                    fromSearch:
                                                                        fromSearch,
                                                                    category: widget
                                                                        .category,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                  ));
                                                                }
                                                                if (text.length <
                                                                        3 &&
                                                                    resetSearchAfterSearchingWhileRemoveSearch) {
                                                                  resetSearchAfterSearchingWhileRemoveSearch =
                                                                      false;
                                                                  Filter filters = homeBloc
                                                                          .state
                                                                          .appliedFiltersByUser[
                                                                              key]
                                                                          ?.filters ??
                                                                      Filter();

                                                                  homeBloc.add(
                                                                      ChangeAppliedFiltersEvent(
                                                                    category: widget
                                                                        .category,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                    filtersAppliedByUser:
                                                                        GetProductFiltersModel(
                                                                            filters:
                                                                                filters.copyWithSaveOtherField(
                                                                      prices: filters
                                                                          .prices,
                                                                      searchText:
                                                                          null,
                                                                    )),
                                                                  ));
                                                                  homeBloc.add(
                                                                      GetProductFiltersEvent(
                                                                    fromHomePageSearch:
                                                                        widget
                                                                            .fromSearch,
                                                                    searchText:
                                                                        null,
                                                                    category: widget
                                                                        .category,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                  ));
                                                                  homeBloc.add(
                                                                      GetProductsWithFiltersEvent(
                                                                    offset: 1,
                                                                    searchText:
                                                                        null,
                                                                    fromSearch:
                                                                        fromSearch,
                                                                    category: widget
                                                                        .category,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                  ));
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          AnimatedSize(
                                                            curve:
                                                                Curves.easeOut,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400),
                                                            reverseDuration:
                                                                Duration(
                                                                    milliseconds:
                                                                        400),
                                                            child: Row(
                                                              children: [
                                                                isExpanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Padding(
                                                                        padding: EdgeInsetsDirectional.only(
                                                                            end: searchOpen
                                                                                ? 10
                                                                                : 20.0),
                                                                        child: SvgPicture.asset(
                                                                            AppAssets
                                                                                .sortingSvg,
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20),
                                                                      ),
                                                                BlocBuilder<
                                                                    HomeBloc,
                                                                    HomeState>(
                                                                  buildWhen:
                                                                      (p, c) {
                                                                    return (p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                                '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                                '${(widget.category ?? '')}'] !=
                                                                            c.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                                                                '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                                                                '${(widget.category ?? '')}'] ||
                                                                        p.getProductFiltersStatus[key] !=
                                                                            c.getProductFiltersStatus[
                                                                                key] ||
                                                                        p.isExpandedForListingPage !=
                                                                            c
                                                                                .isExpandedForListingPage ||
                                                                        p.cashedOrginalBoutique !=
                                                                            c.cashedOrginalBoutique);
                                                                  },
                                                                  builder:
                                                                      (context,
                                                                          state) {
                                                                    isExpanded =
                                                                        state.isExpandedForListingPage ??
                                                                            false;
                                                                    if ((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length ??
                                                                            0) ==
                                                                        1) {
                                                                      return SizedBox
                                                                          .shrink();
                                                                    }
                                                                    return Padding(
                                                                        padding: EdgeInsetsDirectional.only(
                                                                            end: searchOpen
                                                                                ? 10
                                                                                : 20.0),
                                                                        child:
                                                                            InkWell(
                                                                          key: TestVariables.kTestMode
                                                                              ? Key(WidgetsKey.filterIconKey)
                                                                              : null,
                                                                          onTap:
                                                                              () {
                                                                            if (!isExpanded) {
                                                                              prefAppliedFilters = homeBloc.state.appliedFiltersByUser[key]?.filters;
                                                                              homeBloc.add(ChangeAppliedFiltersEvent(boutiqueSlug: widget.boutiqueSlug, category: widget.category, isExpandedForListing: true, resetAppliedFilters: true));
                                                                              homeBloc.add(AddPrefAppliedFilterForExtendFilterEvent(prefAppliedFilter: prefAppliedFilters));

                                                                              homeBloc.add(ChangeSelectedFiltersEvent(fromHomePageSearch: widget.fromSearch, boutiqueSlug: widget.boutiqueSlug, category: widget.category, requestToUpdateFilters: true, isExpandedForListing: true, filtersChoosedByUser: GetProductFiltersModel(filters: prefAppliedFilters)));

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
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            AppAssets.filtersSvg,
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20,
                                                                            color: isExpanded
                                                                                ? Color(0xffFF5F61)
                                                                                : null,
                                                                          ),
                                                                        ));
                                                                  },
                                                                ),
                                                                InkWell(
                                                                    onTap: () {
                                                                      if (isExpanded) {
                                                                        prefAppliedFilters = homeBloc
                                                                            .state
                                                                            .prefAppliedFilterForExtendFilter;
                                                                        controller
                                                                            .text = prefAppliedFilters
                                                                                ?.searchText ??
                                                                            "";
                                                                        print(homeBloc
                                                                            .state
                                                                            .prefAppliedFilterForExtendFilter
                                                                            ?.brands);
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
                                                                        homeBloc
                                                                            .add(
                                                                          ChangeAppliedFiltersEvent(
                                                                            boutiqueSlug:
                                                                                widget.boutiqueSlug,
                                                                            isExpandedForListing:
                                                                                false,
                                                                            category:
                                                                                widget.category,
                                                                            filtersAppliedByUser:
                                                                                GetProductFiltersModel(filters: prefAppliedFilters),
                                                                          ),
                                                                        );
                                                                        //////////////////////////////////
                                                                        FirebaseAnalyticsService
                                                                            .logEventForSession(
                                                                          eventName:
                                                                              AnalyticsEventsConst.buttonClicked,
                                                                          executedEventName:
                                                                              AnalyticsExecutedEventNameConst.filterCloseIconButton,
                                                                        );
                                                                      }
                                                                      // تم جعل الصفحة not expanded باستخدام الأحداث السابقة لتجنب البناء المتكرر
                                                                      // homeBloc.add(
                                                                      //     AddIsExpandedForLidtingPageEvent(
                                                                      //         isExpandedForLidting:
                                                                      //         false));

                                                                      resetSearchAfterSearchingWhileRemoveSearch =
                                                                          false;
                                                                    },
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          30,
                                                                      child: Row(
                                                                          children: [
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
                                                                                    key: TestVariables.kTestMode ? Key(WidgetsKey.closeFilterPageKey) : null,
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
                                              })),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: searchVisible,
                                      builder: (context, searchOpen, _) {
                                        return !fromSearch!
                                            ? ValueListenableBuilder<double>(
                                                valueListenable:
                                                    htmlDescriptionHeight,
                                                builder: (context, htmlHeight,
                                                    child) {
                                                  return isExpanded
                                                      ? SliverToBoxAdapter()
                                                      : SliverAppBar(
                                                          pinned: false,
                                                          collapsedHeight:
                                                              180 + htmlHeight,
                                                          backgroundColor:
                                                              colorScheme.white,
                                                          automaticallyImplyLeading:
                                                              false,
                                                          flexibleSpace: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Column(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          widget.boutiqueIcon != null
                                                                              ? SvgNetworkWidget(
                                                                                  svgUrl: widget.boutiqueIcon ?? "",
                                                                                  height: 20,
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          SvgPicture
                                                                              .asset(
                                                                            AppAssets.verifiedBadgeSvg,
                                                                            height:
                                                                                15,
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          SvgPicture
                                                                              .asset(
                                                                            AppAssets.starBadgeSvg,
                                                                            height:
                                                                                15,
                                                                            width:
                                                                                15,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Html(
                                                                          key:
                                                                              htmlDescriptionKey,
                                                                          shrinkWrap:
                                                                              true,
                                                                          data: widget.boutiqueDescription ??
                                                                              '',
                                                                          style: {
                                                                            "body":
                                                                                Style(margin: Margins.all(0)),
                                                                            "p":
                                                                                Style(
                                                                              margin: Margins.all(0),
                                                                            ),
                                                                          }),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      widget.withSlidingImages
                                                                          ? Container(
                                                                              height: 135,
                                                                              //color: Colors.red,
                                                                              child: CarouselSlider.builder(
                                                                                  itemCount: widget.boutique!.banners!.length,
                                                                                  itemBuilder: (context, index, _) {
                                                                                    return Padding(
                                                                                      padding: EdgeInsets.only(
                                                                                        right: 10,
                                                                                        left: 10,
                                                                                      ),
                                                                                      child: Container(
                                                                                        height: 135,
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
                                                                                              imageUrl: widget.boutique!.banners![index].filePath!,
                                                                                              imageFit: BoxFit.cover,
                                                                                              width: 1.sw,
                                                                                              height: 155,
                                                                                            )),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  options: CarouselOptions(
                                                                                    autoPlay: true,
                                                                                    autoPlayInterval: Duration(seconds: 6),
                                                                                    autoPlayAnimationDuration: Duration(seconds: 1),
                                                                                    initialPage: 0,
                                                                                    height: 155,
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
                                                                                          height: 135,
                                                                                        )),
                                                                                  ),
                                                                                  Container(
                                                                                    height: htmlHeight == 0 ? 0 : 135,
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
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ])
                                                              ]),
                                                        );
                                                })
                                            : SliverToBoxAdapter();
                                      }),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: searchVisible,
                                      builder: (context, searchOpen, _) {
                                        return BlocBuilder<HomeBloc, HomeState>(
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
                                                p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${(widget.category ?? '')}']?.paginationStatus !=
                                                    c
                                                        .getProductListingWithFiltersPaginationModels[
                                                            '${widget.boutiqueSlug}' +
                                                                '${(widget.category ?? '')}']
                                                        ?.paginationStatus ||
                                                p.cashedOrginalBoutique !=
                                                    c.cashedOrginalBoutique;
                                          },
                                          builder: (context, state) {
                                            String? currentAppliedFilterSllug =
                                                "null";
                                            isExpanded = state
                                                    .isExpandedForListingPage ??
                                                false;
                                            bool isOneProductForPrefetch =
                                                false;

                                            GetProductFiltersModel?
                                                appliedFiltersByUser =
                                                state.appliedFiltersByUser[key];
                                            if ((appliedFiltersByUser?.filters
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
                                                  appliedFiltersByUser?.filters
                                                      ?.brands?[0].slug;
                                            } else if ((appliedFiltersByUser
                                                            ?.filters
                                                            ?.boutiques
                                                            ?.length ??
                                                        0) >
                                                    0 &&
                                                widget.fromSearch) {
                                              currentAppliedFilterSllug =
                                                  "search";
                                            } else if ((appliedFiltersByUser
                                                        ?.filters
                                                        ?.attributes?[0]
                                                        .options
                                                        ?.length ??
                                                    0) >
                                                0) {
                                              currentAppliedFilterSllug =
                                                  appliedFiltersByUser
                                                      ?.filters
                                                      ?.attributes?[0]
                                                      .options?[0];
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
                                                                (appliedFiltersByUser?.filters?.attributes?[0].options?.length ??
                                                                    0) ==
                                                            1 &&
                                                        !widget.fromSearch &&
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
                                                            (appliedFiltersByUser?.filters?.attributes?[0].options?.length ?? 0) ==
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
                                                      PaginationStatus
                                                          .success)) {
                                                isOneProductForPrefetch = true;
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
                                                            (currentAppliedFilterSllug ==
                                                                    "null" &&
                                                                state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length ==
                                                                    1 &&
                                                                state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.paginationStatus ==
                                                                    PaginationStatus
                                                                        .success)
                                                        ? 35
                                                        : currentAppliedFilterSllug !=
                                                                "null"
                                                            ? 145
                                                            : 115,
                                                flexibleSpace:
                                                    StackedFiltersList(
                                                        expandingFiltersStack:
                                                            expandingFiltersStack,
                                                        key: TestVariables.kTestMode
                                                            ? Key(WidgetsKey
                                                                .productListFilterKey)
                                                            : null,
                                                        textController:
                                                            controller,
                                                        hideTitle: false,
                                                        fromSearch: fromSearch!,
                                                        searchText: controller.text.length > 2
                                                            ? controller.text
                                                            : widget.searchText,
                                                        filterPageExpanded:
                                                            state.isExpandedForListingPage ??
                                                                false,
                                                        closeFilterPage: () {
                                                          homeBloc.add(
                                                              AddIsExpandedForLidtingPageEvent(
                                                                  isExpandedForLidting:
                                                                      false));
                                                          ;
                                                        },
                                                        displayAppliedFiltersOnly:
                                                            (state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.items.length ?? 0) < 2 &&
                                                                state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' + '${(widget.category ?? '')}']?.paginationStatus ==
                                                                    PaginationStatus
                                                                        .success,
                                                        category: widget.category,
                                                        boutiqueSlug: widget.boutiqueSlug,
                                                        controller: isExpanded ? scrollController : null,
                                                        onMoveToAnotherFiltersSection: (title) {
                                                          timerForDisplayFilterSectionTitle
                                                              ?.cancel();
                                                          showTitleForFilterList
                                                              .value = title;
                                                          timerForDisplayFilterSectionTitle =
                                                              Timer(
                                                                  Duration(
                                                                      seconds:
                                                                          3),
                                                                  () {
                                                            showTitleForFilterList
                                                                .value = null;
                                                          });
                                                        }));
                                          },
                                        );
                                      }),
                                  isExpanded
                                      ? SliverToBoxAdapter()
                                      : BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (p, c) {
                                            bool rebuild = p
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
                                                p.isGettingProductListingWithPaginationForAppearProduct !=
                                                    c
                                                        .isGettingProductListingWithPaginationForAppearProduct ||
                                                p.isGettingProductListingWithPagination !=
                                                    c
                                                        .isGettingProductListingWithPagination ||
                                                p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${(widget.category ?? '')}']?.paginationStatus !=
                                                    c.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${(widget.category ?? '')}']
                                                        ?.paginationStatus ||
                                                p.cashedOrginalBoutique != c.cashedOrginalBoutique;

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
                                            print(
                                                "***************************************************${state.cashedOrginalBoutique}");
                                            isExpanded = state
                                                    .isExpandedForListingPage ??
                                                false;
                                            GetProductFiltersModel?
                                                appliedFiltersByUser =
                                                state.appliedFiltersByUser[key];
                                            String? currentAppliedFilterSllug =
                                                "null";
                                            if (!isExpanded &&
                                                    !state
                                                        .isGettingProductListingWithPaginationForAppearProduct &&
                                                    (appliedFiltersByUser?.filters?.searchText?.length ?? 0) <
                                                        3 &&
                                                    ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (appliedFiltersByUser?.filters?.attributes?[0].options?.length ?? 0) == 1 &&
                                                        !widget.fromSearch &&
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
                                                            (appliedFiltersByUser?.filters?.attributes?[0].options?.length ??
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
                                              } else if ((appliedFiltersByUser
                                                          ?.filters
                                                          ?.attributes?[0]
                                                          .options
                                                          ?.length ??
                                                      0) >
                                                  0) {
                                                currentAppliedFilterSllug =
                                                    appliedFiltersByUser
                                                        ?.filters
                                                        ?.attributes?[0]
                                                        .options?[0];
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
                                                (appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3 &&
                                                controller.text.length < 3 &&
                                                ((appliedFiltersByUser?.filters?.categories?.length ?? 0) + (appliedFiltersByUser?.filters?.brands?.length ?? 0) + (appliedFiltersByUser?.filters?.colors?.length ?? 0) + (appliedFiltersByUser?.filters?.attributes?[0].options?.length ?? 0) == 0 && (appliedFiltersByUser?.filters?.prices?.minPrice == null)))) {
                                              currentAppliedFilterSllug =
                                                  "Empty";
                                              homeBloc.add(
                                                  IscashedOreiginBotiqueEvent(
                                                      iscashedOreiginBotique:
                                                          true));
                                            }

                                            List<filter_products.Products>
                                                products = [];

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
                                                key: TestVariables.kTestMode
                                                    ? Key(WidgetsKey
                                                        .productsListKey)
                                                    : gridViewKeyForRendering,
                                                padding: const EdgeInsets.only(
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
                                                    childCount: products.length,
                                                    (BuildContext context,
                                                        int index) {
                                                      return InkWell(
                                                        onTap: () async {
                                                          Future.delayed(
                                                              Duration(
                                                                  milliseconds:
                                                                      100), () {
                                                            print("${prefsRepository.myMarketId.toString()}" +
                                                                "55555555555555555555555555555555555555555");
                                                            print("${prefsRepository.myMarketName.toString()}" +
                                                                "554${GetIt.I<PrefsRepository>().serverTime}4555554444${prefsRepository.countryIso.toString()}444444444${LanguageService.languageCode == 'ar' ? 'ae' : LanguageService.languageCode}444444444444${GetIt.I<PrefsRepository>().currentEvent}44444444444444444444444444445555555555555555555555");
                                                          });

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
                                                                    .id
                                                                    .toString(),
                                                                productName: products[
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
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (ctx) =>
                                                                  ProductDetailsPage(
                                                                productItem:
                                                                    products[
                                                                        index],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: ProductItem(
                                                          key: TestVariables
                                                                  .kTestMode
                                                              ? Key(
                                                                  '${WidgetsKey.productInBoutiqueListKey}$index')
                                                              : null,
                                                          slidingModeItem:
                                                              slidingMode,
                                                          productItem:
                                                              products[index],
                                                          itemIndex: index,
                                                          setThisEnabled: (int
                                                                  index,
                                                              int slideMode) {
                                                            setThisEnabledNotifier
                                                                    .value =
                                                                Tuple2(index,
                                                                    slideMode);
                                                          },
                                                        ),
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
                                                        .isNullOrEmpty)) {
                                              print(
                                                  "11111111111111111111111111${state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + 'withoutFilter' + '${(widget.category ?? '')}']?.paginationStatus}//${state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + 'withoutFilter' + '${(widget.category ?? '')}']!.items.isNullOrEmpty}////////////////////////////////////---------------------------------");

                                              return ProductListingLoading();
                                            }
                                            if ((state
                                                            .getProductListingWithFiltersPaginationModels[
                                                                '${widget.boutiqueSlug}' +
                                                                    'withoutFilter' +
                                                                    '${(widget.category ?? '')}']
                                                            ?.paginationStatus ==
                                                        PaginationStatus
                                                            .failure &&
                                                    state
                                                        .getProductListingWithFiltersPaginationModels[
                                                            '${widget.boutiqueSlug}' +
                                                                'withoutFilter' +
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
                                                    "No Internet Connected",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              );
                                            }
                                            print(
                                                'fcfcfcfcfcsfasfafas1132132142141');
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
                                                    PaginationStatus.success) {
                                              return SliverToBoxAdapter(
                                                child: Center(
                                                  child: MyTextWidget(
                                                    "No Products Found",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (((state.getProductListingWithFiltersPaginationModels[
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
                                                            .success) ||
                                                (state
                                                            .getProductListingWithFiltersPaginationModels[
                                                                '${widget.boutiqueSlug}' +
                                                                    '${(widget.category ?? '')}']
                                                            ?.paginationStatus ==
                                                        PaginationStatus
                                                            .loading &&
                                                    !state
                                                        .cashedOrginalBoutique)) {
                                              print(
                                                  "//////////////////////////////////////---------------------------------");
                                              return ProductListingLoading(
                                                key: TestVariables.kTestMode
                                                    ? Key(WidgetsKey
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
                                                      "No Products Found",
                                                      style: TextStyle(
                                                          color: Colors.black,
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
                                            //                                             }
                                            return SliverPadding(
                                              key: TestVariables.kTestMode
                                                  ? Key(WidgetsKey
                                                      .productsListKey)
                                                  : gridViewKeyForRendering,
                                              padding: const EdgeInsets.only(
                                                  top: 10),
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
                                                  childCount: products.length,
                                                  (BuildContext context,
                                                      int index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Future.delayed(
                                                          Duration(
                                                              milliseconds:
                                                                  100),
                                                          () {
                                                            print("${prefsRepository.myMarketId.toString()}" +
                                                                "55555555555555555555555555555555555555555");
                                                            print("${prefsRepository.myMarketName.toString()}" +
                                                                "554${GetIt.I<PrefsRepository>().serverTime}4555554444${prefsRepository.countryIso.toString()}444444444${LanguageService.languageCode == 'ar' ? 'ae' : LanguageService.languageCode}444444444444${GetIt.I<PrefsRepository>().currentEvent}44444444444444444444444444445555555555555555555555");
                                                          },
                                                        );
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
                                                                  .id
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
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (ctx) =>
                                                                    ProductDetailsPage(
                                                                      productItem:
                                                                          products[
                                                                              index],
                                                                    )));
                                                      },
                                                      child: ProductItem(
                                                        key: TestVariables
                                                                .kTestMode
                                                            ? Key(
                                                                '${WidgetsKey.productInBoutiqueListKey}$index')
                                                            : null,
                                                        slidingModeItem:
                                                            slidingMode,
                                                        productItem:
                                                            products[index],
                                                        itemIndex: index,
                                                        setThisEnabled:
                                                            (int index,
                                                                int slideMode) {
                                                          setThisEnabledNotifier
                                                                  .value =
                                                              Tuple2(index,
                                                                  slideMode);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  BlocBuilder<HomeBloc, HomeState>(
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
              )
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
      key: TestVariables.kTestMode ? Key(WidgetsKey.productsListKey) : null,
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
                print(
                    '/////////// Go to details  /////// ${products[index].categories?[0].name} ///////');
                Future.delayed(
                  Duration(milliseconds: 100),
                ).then(
                  (value) {
                    FirebaseAnalyticsService.logEventForViewedProduct(
                      eventName: AnalyticsEventsConst.viewedProduct,
                      productId: products[index].id.toString(),
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

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ProductDetailsPage(
                      productItem: products[index],
                    ),
                  ),
                );
              },
              child: ProductItem(
                key: TestVariables.kTestMode
                    ? Key('${WidgetsKey.productInBoutiqueListKey}$index')
                    : null,
                slidingModeItem: slidingMode,
                productItem: products[index],
                itemIndex: index,
                setThisEnabled: (int index, int slideMode) {
                  setThisEnabledNotifier.value = Tuple2(index, slideMode);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
