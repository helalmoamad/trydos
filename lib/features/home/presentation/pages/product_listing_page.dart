import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart' as icon;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/animated_search_bar/animated_search_bar.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter_products;
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_search.dart';
import 'package:trydos/features/search/presentation/pages/search_listing_page.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/constant/widgets_key.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/svg_network_widget.dart';
import '../../data/models/get_home_boutiqes_model.dart' as boutique;
import '../manager/home_bloc.dart';
import '../widgets/product_listing/product_item.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import '../widgets/product_listing/product_listing_filter_list.dart';
import '../widgets/product_listing/product_listing_loading.dart';

class ProductListingPage extends StatefulWidget {
  final String boutiqueSlug;
  final String? category;
  final String? boutiqueIcon;
  final String? boutiqueDescription;
  final String? boutiqueFirstBanner;
  final bool withSlidingImages;
  final boutique.Boutique? boutniqe;
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
    this.boutniqe,
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

  final ValueNotifier<bool> hideTrendingAndHistory = ValueNotifier(false);
  final ValueNotifier<bool> searchVisible = ValueNotifier(true);

  final TextEditingController controller = TextEditingController();
  Timer? timerForDisplayFilterSectionTitle;
  final GlobalKey htmlDescriptionKey = GlobalKey();
  final ValueNotifier<double> htmlDescriptionHeight = ValueNotifier(0);
  double? _velocity;
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final ValueNotifier<bool> fromSearchListing = ValueNotifier(false);
  final ValueNotifier<bool> filterPageExpanded = ValueNotifier(false);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  bool? fromSearch;
  bool itExpendForFirst = true;
  String key = '';
  Filter? prefAppliedFilters;
  @override
  void initState() {
    itExpendForFirst = true;
    key = widget.boutiqueSlug + (widget.category ?? '');
    fromSearch = widget.fromSearch;
    searchVisible.value = false;
    if ((widget.searchText?.length ?? 0) > 2) {
      controller.text = widget.searchText!;
      resetSearchAfterSearchingWhileRemoveSearch = true;
    }
    Timer.periodic(Duration(milliseconds: 100), postFrameCallback);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);

    // if (!widget.fromSearch) {
    //   homeBloc.add(GetProductsWithoutFiltersEvent(
    //     boutiqueSlug: widget.boutiqueSlug!,
    //     category: widget.category,
    //     offset: 1,
    //   ));
    // }
    if (!widget.fromSearch) {
      homeBloc.add(GetProductFiltersEvent(
          cashedOrginalBoutique: true,
          fromHomePageSearch: widget.fromSearch,
          boutiqueSlug: widget.boutiqueSlug,
          category: widget.category,
          searchText: widget.fromSearch ? widget.searchText : null));
    }
    if (!widget.fromSearch) {
      homeBloc.add(GetProductsWithFiltersEvent(
          cashedOrginalBoutique: !widget.fromSearch,
          boutiqueSlug: widget.boutiqueSlug,
          fromSearch: widget.fromSearch,
          category: widget.category,
          searchText: widget.fromSearch ? widget.searchText : null,
          offset: 1));
    }
    scrollController.addListener(() {
      if (filterPageExpanded.value) return;
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
      // else if(filterPageExpanded.value){
      //   scrollController.jumpTo(80);
      // }
      if (setThisEnabledNotifier.value.item1 != -1) {
        setThisEnabledNotifier.value = Tuple2(-1, -1);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    appBloc.add(HideBottomNavigationBar(false));
    appBloc.add(ChangeIndexForSearch(1));
    focusNode.dispose();
    appBloc.add(ShowOrHideBars(true));
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hideTrendingAndHistory.value =
            controller.text.length > 0 ? true : false;
      }
    });
    super.didChangeDependencies();
  }

  Key gridViewKeyForRendering = UniqueKey();

  void postFrameCallback(timer) {
    var context = htmlDescriptionKey.currentContext;
    if (context == null || htmlDescriptionHeight.value > 0) return;
    timer.cancel();
    htmlDescriptionHeight.value = context.size!.height;
  }

  bool resetSearchAfterSearchingWhileRemoveSearch = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.controllerFormSearchPage?.text = controller.text;
        itExpendForFirst = false;

        searchVisible.value = false;
        if (filterPageExpanded.value) {
          prefAppliedFilters =
              homeBloc.state.prefAppliedFilterForExtendFilter ?? Filter();
          homeBloc.add(ChangeAppliedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersAppliedByUser:
                  GetProductFiltersModel(filters: prefAppliedFilters)));
          homeBloc.add(GetProductFiltersEvent(
              fromHomePageSearch: widget.fromSearch,
              cashedOrginalBoutique: false,
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              searchText: widget.searchText,
              filtersChoosedByUser:
                  GetProductFiltersModel(filters: prefAppliedFilters)));

          resetSearchAfterSearchingWhileRemoveSearch = false;

          filterPageExpanded.value = false;

          return Future.value(false);
        } else {
          if (!widget.fromSearch) {
            homeBloc.add(ChangeAppliedFiltersEvent(
                boutiqueSlug: widget.boutiqueSlug,
                category: widget.category,
                filtersAppliedByUser: null,
                resetAppliedFilters: true));
            homeBloc.add(ChangeSelectedFiltersEvent(
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersChoosedByUser: null,
            ));
          }
          if (widget.fromSearch) {
            homeBloc.add(ChangeSelectedFiltersEvent(
              requestToUpdateFilters: false,
              boutiqueSlug: widget.boutiqueSlug,
              category: widget.category,
              filtersChoosedByUser: GetProductFiltersModel(
                  filters: homeBloc.state.appliedFiltersByUser[key]?.filters),
            ));
            homeBloc.add(ChangeAppliedFiltersEvent(
                boutiqueSlug: widget.boutiqueSlug,
                category: widget.category,
                resetAppliedFilters: true));
          }
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
                        return const AppBottomNavBar();
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
                        !filterPageExpanded.value &&
                        !widget.fromSearch &&
                        widget.boutiqueIcon != "") {
                      displayBoutiqueIconInAppBar.value = true;
                    } else {
                      displayBoutiqueIconInAppBar.value = false;
                    }
                    if (_previousOffset != null) {
                      final distance = (currentOffset - _previousOffset!).abs();
                      final time = notification
                              .dragDetails?.sourceTimeStamp?.inMilliseconds ??
                          0.000001;
                      _velocity = distance / time;
                      if (scrollController.position.pixels <= 80) {
                        _previousOffset = currentOffset;
                        return true;
                      }
                      if (_velocity! <= (1.5e-8) && _velocity! >= (1.42e-8)) {
                        appBloc.add(ShowOrHideBars(true));
                      } else {
                        appBloc.add(ShowOrHideBars(false));
                      }
                    }
                    _previousOffset = currentOffset;
                    return true;
                  },
                  child: ValueListenableBuilder<Tuple2<int, int>>(
                      valueListenable: setThisEnabledNotifier,
                      builder: (context, slidingMode, _) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: filterPageExpanded,
                            builder: (context, isExpanded, _) {
                              if (!filterPageExpanded.value &&
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
                              return CustomScrollView(
                                  controller: scrollController,
                                  physics: ClampingScrollPhysics(),
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
                                                      appBarParams:
                                                          AppBarParams(
                                                              onBack: () {
                                                                if (widget
                                                                    .fromSearch) {
                                                                  widget.controllerFormSearchPage
                                                                          ?.text =
                                                                      controller
                                                                          .text;
                                                                  homeBloc.add(ChangeAppliedFiltersEvent(
                                                                      boutiqueSlug: widget
                                                                          .boutiqueSlug,
                                                                      category:
                                                                          widget
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
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                    category: widget
                                                                        .category,
                                                                    filtersChoosedByUser: GetProductFiltersModel(
                                                                        filters: homeBloc
                                                                            .state
                                                                            .appliedFiltersByUser[key]
                                                                            ?.filters),
                                                                  ));
                                                                }
                                                                if (!widget
                                                                    .fromSearch) {
                                                                  homeBloc.add(
                                                                      ChangeSelectedFiltersEvent(
                                                                    requestToUpdateFilters:
                                                                        false,
                                                                    boutiqueSlug:
                                                                        widget
                                                                            .boutiqueSlug,
                                                                    category: widget
                                                                        .category,
                                                                    filtersChoosedByUser: GetProductFiltersModel(
                                                                        filters: homeBloc
                                                                            .state
                                                                            .appliedFiltersByUser[key]
                                                                            ?.filters),
                                                                  ));
                                                                  homeBloc.add(ChangeAppliedFiltersEvent(
                                                                      boutiqueSlug:
                                                                          widget
                                                                              .boutiqueSlug,
                                                                      category:
                                                                          widget
                                                                              .category,
                                                                      resetAppliedFilters:
                                                                          true));
                                                                }
                                                              },
                                                              backgroundColor:
                                                                  colorScheme
                                                                      .white,
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
                                                                      padding:
                                                                      EdgeInsetsDirectional.only(start: 30.w),
                                                                      child:
                                                                      SvgNetworkWidget(
                                                                        svgUrl:
                                                                        widget.boutiqueIcon ?? "",
                                                                        height:
                                                                        20,
                                                                      ),
                                                                    ),
                                                                    builder:
                                                                        (context,
                                                                            display,
                                                                            child) {
                                                                      return display ? child! : SizedBox.shrink();
                                                                    }),
                                                                Padding(
                                                                  padding:
                                                                       EdgeInsetsDirectional
                                                                          .only(
                                                                           end: searchOpen ? 10 :  20.0),
                                                                  child:
                                                                      AnimatedSearchBar(
                                                                    key: WidgetsKey
                                                                            .kTestMode
                                                                        ? Key(WidgetsKey
                                                                            .productListingSearchInputKey)
                                                                        : null,
                                                                    autoFocus:
                                                                        false,
                                                                    width:
                                                                        isExpanded ? (1.sw -
                                                                            90) : (1.sw -
                                                                            120),
                                                                    height: 40,
                                                                    onClickClose:
                                                                        () {
                                                                      if (!isExpanded &&
                                                                          controller
                                                                              .text
                                                                              .isNotEmpty) {
                                                                        Filter
                                                                            filters =
                                                                            homeBloc.state.appliedFiltersByUser[key]?.filters ??
                                                                                Filter();
                                                                        homeBloc.add(ChangeAppliedFiltersEvent(
                                                                            boutiqueSlug:
                                                                                widget.boutiqueSlug,
                                                                            category: widget.category,
                                                                            filtersAppliedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                        homeBloc
                                                                            .add(GetProductsWithFiltersEvent(
                                                                          offset:
                                                                              1,
                                                                          searchText:
                                                                              null,
                                                                          fromSearch:
                                                                              fromSearch,
                                                                          category:
                                                                              widget.category,
                                                                          boutiqueSlug:
                                                                              widget.boutiqueSlug,
                                                                        ));
                                                                      }
                                                                      if (isExpanded &&
                                                                          controller
                                                                              .text
                                                                              .isNotEmpty) {
                                                                        Filter
                                                                            filters =
                                                                            homeBloc.state.choosedFiltersByUser[key]?.filters ??
                                                                                Filter();
                                                                        homeBloc.add(ChangeSelectedFiltersEvent(
                                                                            boutiqueSlug:
                                                                                widget.boutiqueSlug,
                                                                            filtersChoosedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
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
                                                                      return false;
                                                                    },
                                                                    textController:
                                                                        controller,
                                                                    focusNode:
                                                                        focusNode,
                                                                    onSuffixTap:
                                                                        () {
                                                                      WidgetsBinding
                                                                          .instance
                                                                          .addPostFrameCallback(
                                                                              (timeStamp) {
                                                                        searchVisible.value =
                                                                            true;
                                                                      });
                                                                    },
                                                                    suffixWidget:
                                                                        Center(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AppAssets
                                                                            .searchOutlinedSvg,
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                        color: Color(
                                                                            0xff388CFF),
                                                                      ),
                                                                    ),
                                                                    prefixWidget:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          SvgPicture
                                                                              .asset(
                                                                            AppAssets.realCameraSvg,
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                20,
                                                                          ),
                                                                          SvgPicture
                                                                              .asset(
                                                                            AppAssets.microphoneSvg,
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                20,
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
                                                                            color: focusNode.hasFocus
                                                                                ? Color(0xffE6E6E6)
                                                                                : Color(0xffF8F8F8),
                                                                            width: 0.4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(kbrBorderTextField),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: focusNode.hasFocus
                                                                                ? Color(0xffE6E6E6)
                                                                                : Color(0xffF8F8F8),
                                                                            width: 0.4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(kbrBorderTextField),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: focusNode.hasFocus
                                                                                ? Color(0xffE6E6E6)
                                                                                : Color(0xffF8F8F8),
                                                                            width: 0.4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(kbrBorderTextField),
                                                                      ),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: focusNode.hasFocus
                                                                                ? Color(0xffE6E6E6)
                                                                                : Color(0xffF8F8F8),
                                                                            width: 0.4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(kbrBorderTextField),
                                                                      ),
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                context.colorScheme.error,
                                                                            width: 0.4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(kbrBorderTextField),
                                                                      ),
                                                                      focusedErrorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                context.colorScheme.error,
                                                                            width: 0.4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(kbrBorderTextField),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor: focusNode.hasFocus
                                                                          ? colorScheme
                                                                              .white
                                                                          : Color(
                                                                              0xffF8F8F8),
                                                                      prefixIcon:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                12,
                                                                            bottom:
                                                                                12),
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AppAssets
                                                                              .searchOutlinedSvg,
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                          color:
                                                                              Color(0xff388CFF),
                                                                        ),
                                                                      ),
                                                                      suffixIcon:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                15,
                                                                            top:
                                                                                10,
                                                                            bottom:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              AppAssets.realCameraSvg,
                                                                              height: 20,
                                                                              width: 20,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 20,
                                                                            ),
                                                                            SvgPicture.asset(
                                                                              AppAssets.microphoneSvg,
                                                                              height: 20,
                                                                              width: 20,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      //context.colorScheme.white,
                                                                      contentPadding: HWEdgeInsetsDirectional.only(
                                                                          start:
                                                                              20,
                                                                          end:
                                                                              10,
                                                                          bottom:
                                                                              12,
                                                                          top:
                                                                              12),
                                                                      hintText:
                                                                          'Search',
                                                                      hintStyle: context
                                                                          .textTheme
                                                                          .subtitle1
                                                                          ?.lq
                                                                          .copyWith(
                                                                              color: Color(0xffC4C2C2)),
                                                                      labelStyle: context
                                                                          .textTheme
                                                                          .bodyText2
                                                                          ?.copyWith(
                                                                              color: context.colorScheme.hint),
                                                                    ),
                                                                    onChanged:
                                                                        (String
                                                                            text) {
                                                                      if (isExpanded) {
                                                                        Filter
                                                                            filters =
                                                                            homeBloc.state.choosedFiltersByUser[key]?.filters ??
                                                                                Filter();
                                                                        if (text.length >
                                                                            2) {
                                                                          resetSearchAfterSearchingWhileRemoveSearch =
                                                                              true;
                                                                          homeBloc.add(ChangeSelectedFiltersEvent(
                                                                              boutiqueSlug: widget.boutiqueSlug,
                                                                              filtersChoosedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: text))));
                                                                        }
                                                                        if (text.length <
                                                                                3 &&
                                                                            resetSearchAfterSearchingWhileRemoveSearch) {
                                                                          resetSearchAfterSearchingWhileRemoveSearch =
                                                                              false;
                                                                          homeBloc.add(ChangeSelectedFiltersEvent(
                                                                              boutiqueSlug: widget.boutiqueSlug,
                                                                              filtersChoosedByUser: GetProductFiltersModel(filters: filters.copyWithSaveOtherField(prices: filters.prices, searchText: null))));
                                                                        }
                                                                        return;
                                                                      }
                                                                      if (text.length >
                                                                          2) {
                                                                        resetSearchAfterSearchingWhileRemoveSearch =
                                                                            true;
                                                                        Filter
                                                                            filters =
                                                                            homeBloc.state.appliedFiltersByUser[key]?.filters ??
                                                                                Filter();
                                                                        homeBloc
                                                                            .add(ChangeAppliedFiltersEvent(
                                                                          category:
                                                                              widget.category,
                                                                          boutiqueSlug:
                                                                              widget.boutiqueSlug,
                                                                          filtersAppliedByUser: GetProductFiltersModel(
                                                                              filters: filters.copyWithSaveOtherField(
                                                                            prices:
                                                                                filters.prices,
                                                                            searchText:
                                                                                text,
                                                                          )),
                                                                        ));
                                                                        homeBloc
                                                                            .add(GetProductsWithFiltersEvent(
                                                                          offset:
                                                                              1,
                                                                          searchText:
                                                                              text,
                                                                          fromSearch:
                                                                              fromSearch,
                                                                          category:
                                                                              widget.category,
                                                                          boutiqueSlug:
                                                                              widget.boutiqueSlug,
                                                                        ));
                                                                      }
                                                                      if (text.length <
                                                                              3 &&
                                                                          resetSearchAfterSearchingWhileRemoveSearch) {
                                                                        resetSearchAfterSearchingWhileRemoveSearch =
                                                                            false;
                                                                        Filter
                                                                            filters =
                                                                            homeBloc.state.appliedFiltersByUser[key]?.filters ??
                                                                                Filter();
                                                                        homeBloc
                                                                            .add(ChangeAppliedFiltersEvent(
                                                                          category:
                                                                              widget.category,
                                                                          boutiqueSlug:
                                                                              widget.boutiqueSlug,
                                                                          filtersAppliedByUser: GetProductFiltersModel(
                                                                              filters: filters.copyWithSaveOtherField(
                                                                            prices:
                                                                                filters.prices,
                                                                            searchText:
                                                                                null,
                                                                          )),
                                                                        ));
                                                                        homeBloc
                                                                            .add(GetProductFiltersEvent(
                                                                          fromHomePageSearch:
                                                                              fromSearch ?? false,
                                                                          searchText:
                                                                              null,
                                                                          category:
                                                                              widget.category,
                                                                          boutiqueSlug:
                                                                              widget.boutiqueSlug,
                                                                        ));
                                                                      }
                                                                    },
                                                                    hideTrendingAndHistory:
                                                                        hideTrendingAndHistory,
                                                                  ),
                                                                ),
                                                                AnimatedSize(
                                                                  curve: Curves.easeOut,
                                                                  duration: Duration(milliseconds: 400),
                                                                  reverseDuration: Duration(milliseconds: 400),
                                                                  child: Row(
                                                                    children: [
                                                                      isExpanded
                                                                          ? SizedBox
                                                                              .shrink()
                                                                          : Padding(
                                                                              padding:
                                                                                   EdgeInsetsDirectional.only(end: searchOpen ? 10 :  20.0),
                                                                              child: SvgPicture.asset(AppAssets.sortingSvg,
                                                                                  width: 20,
                                                                                  height: 20),
                                                                            ),
                                                                      BlocBuilder<
                                                                          HomeBloc,
                                                                          HomeState>(
                                                                        buildWhen: (p,c){
                                                                          return (p.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${p.cashedOrginalBoutique ? 'withoutFilter' : p.idForRequest}' + '${(widget.category ?? '')}']?.items.length) != (c.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${c.cashedOrginalBoutique ? 'withoutFilter' : c.idForRequest}' + '${(widget.category ?? '')}']?.items.length
                                                                          );
                                                                        },
                                                                        builder:
                                                                            (context,
                                                                                state) {
                                                                          if ((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' + '${(widget.category ?? '')}']?.items.length ??
                                                                                  0) ==
                                                                              1) {
                                                                            return SizedBox
                                                                                .shrink();
                                                                          }
                                                                          return Padding(
                                                                              padding:
                                                                                   EdgeInsetsDirectional.only(end: searchOpen ? 10 :  20.0),
                                                                              child: InkWell(
                                                                                onTap: () {

                                                                                  if (!filterPageExpanded.value) {
                                                                                    filterPageExpanded.value = true;
                                                                                    controller.clear();
                                                                                    resetSearchAfterSearchingWhileRemoveSearch = false;
                                                                                    prefAppliedFilters = homeBloc.state.appliedFiltersByUser[key]?.filters;
                                                                                    homeBloc.add(AddPrefAppliedFilterForExtendFilterEvent(prefAppliedFilter: prefAppliedFilters));
                                                                                    homeBloc.add(ChangeSelectedFiltersEvent(boutiqueSlug: widget.boutiqueSlug, category: widget.category, requestToUpdateFilters: true, filtersChoosedByUser: GetProductFiltersModel(filters: homeBloc.state.appliedFiltersByUser[key]?.filters)));
                                                                                    homeBloc.add(ChangeAppliedFiltersEvent(boutiqueSlug: widget.boutiqueSlug, category: widget.category, resetAppliedFilters: true));
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
                                                                          onTap:
                                                                              () {
                                                                                filterPageExpanded.value =
                                                                                false;
                                                                                controller.clear();
                                                                                resetSearchAfterSearchingWhileRemoveSearch =
                                                                                false;

                                                                            if (isExpanded) {
                                                                              homeBloc.add(ChangeAppliedFiltersEvent(
                                                                                  boutiqueSlug: widget.boutiqueSlug,
                                                                                  category: widget.category,
                                                                                  filtersAppliedByUser: GetProductFiltersModel(filters: prefAppliedFilters)));
                                                                              homeBloc.add(GetProductFiltersEvent(
                                                                                  fromHomePageSearch: widget.fromSearch,
                                                                                  cashedOrginalBoutique: false,
                                                                                  boutiqueSlug: widget.boutiqueSlug,
                                                                                  category: widget.category,
                                                                                  searchText: widget.searchText,
                                                                                  filtersChoosedByUser: GetProductFiltersModel(filters: prefAppliedFilters)));
                                                                            }
                                                                          },
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Row(children: [
                                                                                  SizedBox(width: !isExpanded ? 10.0 : 12.5),
                                                                              !isExpanded
                                                                                  ? SvgPicture.asset(
                                                                                      AppAssets.shareSvg,
                                                                                      width: 20,
                                                                                      height: 20,
                                                                                      color: Color(0xff3C3C3C),
                                                                                    )
                                                                                  : SvgPicture.asset(
                                                                                    AppAssets.closeSvg,
                                                                                    width: 15,
                                                                                    height: 15,
                                                                                    color: Color(0xffFF5F61),
                                                                                  ),
                                                                              SizedBox(width: !isExpanded ? 10.0 : 12.5)
                                                                            ]),                                                                          )),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                              withShadow:
                                                                  false),
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
                                                                  Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            SvgNetworkWidget(
                                                                              svgUrl: widget.boutiqueIcon ?? "",
                                                                              height: 20,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            SvgPicture.asset(
                                                                              AppAssets.verifiedBadgeSvg,
                                                                              height: 15,
                                                                              width: 15,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            SvgPicture.asset(
                                                                              AppAssets.starBadgeSvg,
                                                                              height: 15,
                                                                              width: 15,
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
                                                                            data:
                                                                                widget.boutiqueDescription,
                                                                            style: {
                                                                              "body": Style(margin: Margins.all(0)),
                                                                              "p": Style(
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
                                                                                    itemCount: widget.boutniqe!.banners!.length,
                                                                                    itemBuilder: (context, index, _) {
                                                                                      return Padding(
                                                                                        padding: EdgeInsets.only(
                                                                                          right: 10,
                                                                                          left: 10,
                                                                                        ),
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            Container(
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
                                                                                                    imageUrl: widget.boutniqe!.banners![index].filePath!,
                                                                                                    imageFit: BoxFit.cover,
                                                                                                    width: 1.sw,
                                                                                                    height: 155,
                                                                                                  )),
                                                                                            ),
                                                                                            Container(
                                                                                              height: 155,
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
                                          return BlocBuilder<HomeBloc,
                                              HomeState>(
                                            builder: (context, state) {
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
                                                      : (state.getProductFiltersModel[key]?.filters == null &&
                                                              state.getProductFiltersStatus[key] !=
                                                                  GetProductFiltersStatus
                                                                      .loading)
                                                          ? 35
                                                          : state.appliedFiltersByUser[key] !=
                                                                  null
                                                              ? ((state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' + '${(widget.category ?? '')}']?.items.length ?? 1) == 1 &&
                                                                      state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' + '${(widget.category ?? '')}']?.paginationStatus ==
                                                                          PaginationStatus
                                                                              .success)
                                                                  ? 35
                                                                  : 145
                                                              : 115,
                                                  flexibleSpace:
                                                      StackedFiltersList(
                                                          key: WidgetsKey.kTestMode
                                                              ? Key(WidgetsKey
                                                                  .productListFilterKey)
                                                              : null,
                                                          textController:
                                                              controller,
                                                          hideTitle: false,
                                                          fromSearch:
                                                              fromSearch!,
                                                          searchText: controller.text.length > 2
                                                              ? controller.text
                                                              : widget
                                                                  .searchText,
                                                          filterPageExpanded:
                                                              filterPageExpanded,
                                                          closeFilterPage: () {
                                                            filterPageExpanded
                                                                .value = false;
                                                          },
                                                          displayAppliedFiltersOnly:
                                                              state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' + '${(widget.category ?? '')}']?.items.length == 1 && state.getProductFiltersStatus[key] == GetProductFiltersStatus.success && state.getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' + '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' + '${(widget.category ?? '')}']?.paginationStatus == PaginationStatus.success,
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
                                                          .cashedOrginalBoutique !=
                                                      c.cashedOrginalBoutique ||
                                                  p.idForRequest !=
                                                      c.idForRequest ||
                                                  p
                                                          .getProductListingWithFiltersPaginationModels[
                                                              '${widget.boutiqueSlug}' +
                                                                  '${c.cashedOrginalBoutique ? 'withoutFilter' : c.idForRequest}' +
                                                                  '${(widget.category ?? '')}']
                                                          ?.paginationStatus !=
                                                      c
                                                          .getProductListingWithFiltersPaginationModels[
                                                              '${widget.boutiqueSlug}' +
                                                                  '${c.cashedOrginalBoutique ? 'withoutFilter' : c.idForRequest}' +
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
                                              print('fcfcfcfcfcsfasfafas');
                                              // String key = (widget
                                              //             .boutiqueSlug ??
                                              //         '') +
                                              //     (widget.category ??
                                              //         '');
                                              if ((state.getProductListingWithFiltersPaginationModels[
                                                              '${widget.boutiqueSlug}' +
                                                                  'withoutFilter' +
                                                                  '${(widget.category ?? '')}'] ==
                                                          null &&
                                                      !widget.fromSearch) &&
                                                  state
                                                          .getProductListingWithFiltersPaginationModels[
                                                              '${widget.boutiqueSlug}' +
                                                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}'
                                                                      '${(widget.category ?? '')}']
                                                          ?.paginationStatus ==
                                                      PaginationStatus
                                                          .success) {
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
                                              if ((((state.getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      'withoutFilter' +
                                                                      '${(widget.category ?? '')}'] ==
                                                              null ||
                                                          state
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      'withoutFilter' +
                                                                      '${(widget.category ?? '')}']!
                                                              .items
                                                              .isNullOrEmpty) &&
                                                      state
                                                              .getProductListingWithFiltersPaginationModels[
                                                                  '${widget.boutiqueSlug}' +
                                                                      '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}'
                                                                          '${(widget.category ?? '')}']
                                                              ?.paginationStatus ==
                                                          PaginationStatus
                                                              .loading &&
                                                      !widget.fromSearch) ||
                                                  state
                                                          .getProductListingWithFiltersPaginationModels[
                                                              '${widget.boutiqueSlug}' +
                                                                  "${state.idForRequest}"
                                                                      '${(widget.category ?? '')}']
                                                          ?.paginationStatus ==
                                                      PaginationStatus
                                                          .loading)) {
                                                return ProductListingLoading(
                                                  key: WidgetsKey.kTestMode
                                                      ? Key(WidgetsKey
                                                          .boutiqueProductListingLoadingKey)
                                                      : null,
                                                );
                                              }

                                              List<filter_products.Products>
                                                  products = [];

                                              if (state.getProductListingWithFiltersPaginationModels[
                                                      '${widget.boutiqueSlug}' +
                                                          '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' +
                                                          '${(widget.category ?? '')}'] !=
                                                  null) {
                                                products = state
                                                    .getProductListingWithFiltersPaginationModels[
                                                        '${widget.boutiqueSlug}' +
                                                            '${state.cashedOrginalBoutique ? 'withoutFilter' : state.idForRequest}' +
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
                                              //                                                     }
                                              return SliverPadding(
                                                key: WidgetsKey.kTestMode
                                                    ? Key(WidgetsKey
                                                        .productsListKey)
                                                    : null,
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                sliver: SliverGrid(
                                                  key: gridViewKeyForRendering,
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
                                                          await FirebaseAnalytics
                                                              .instance
                                                              .logEvent(
                                                                  name:
                                                                      'button_clicked',
                                                                  parameters: {
                                                                "time_stamp": DateTime
                                                                        .now()
                                                                    .toUtc()
                                                                    .add(Duration(
                                                                        minutes:
                                                                            GetIt.I<PrefsRepository>().getdurtion ??
                                                                                0))
                                                                    .toString(),
                                                                "previous_event_button_name":
                                                                    GetIt.I<PrefsRepository>()
                                                                        .currentEvent,
                                                                "device_language":
                                                                    LanguageService.languageCode ==
                                                                            'ar'
                                                                        ? 'ae'
                                                                        : LanguageService
                                                                            .languageCode,
                                                                "country_name":
                                                                    GetIt.I<PrefsRepository>()
                                                                        .countryIso,
                                                                'userID': prefsRepository
                                                                    .myMarketId
                                                                    .toString(),
                                                                'user_name':
                                                                    prefsRepository
                                                                        .myMarketName
                                                                        .toString(),
                                                                'clicked_button_name':
                                                                    'i love you Ahmad',
                                                                "session_id": GetIt.I<
                                                                        PrefsRepository>()
                                                                    .sessionId,
                                                              });
                                                          await GetIt.I<
                                                                  PrefsRepository>()
                                                              .setCurrentEvent(
                                                                  "i loveddssssssssssss44444444444444444ssssssssssssss you Ahmad in past");

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
                                                                            products[index],
                                                                      )));
                                                        },
                                                        child: ProductItem(
                                                          key: WidgetsKey
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
                                            },
                                          )
                                  ]);
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
                                      style: textTheme.bodyText2?.rq.copyWith(
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
}
