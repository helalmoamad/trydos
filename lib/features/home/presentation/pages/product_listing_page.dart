import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter_products;
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_search.dart';
import 'package:trydos/features/search/presentation/pages/search_listing_page.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/svg_network_widget.dart';
import '../../data/models/get_home_boutiqes_model.dart';
import '../manager/home_bloc.dart';
import '../widgets/product_listing/product_item.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import '../widgets/product_listing/product_listing_filter_list.dart';

class ProductListingPage extends StatefulWidget {
  final String boutiqueSlug;
  final String? category;
  final String? boutiqueIcon;
  final String? boutiqueDescription;
  final String? boutiqueFirstBanner;
  final bool withSlidingImages;
  final Boutique? boutniqe;
  final bool fromSearch;
  final String? searchText;

  const ProductListingPage({
    super.key,
    required this.boutiqueSlug,
    this.boutiqueDescription,
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
  final ValueNotifier<int> buildSearchResult = ValueNotifier(0);
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
  final ValueNotifier<bool> filterPageExpanded = ValueNotifier(false);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    searchVisible.value = false;
    Timer.periodic(Duration(milliseconds: 100), postFrameCallback);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    if (!widget.fromSearch) {
      homeBloc.add(GetProductsWithoutFiltersEvent(
        boutiqueSlug: widget.boutiqueSlug,
        category: widget.category,
        offset: 1,
      ));
    }
    homeBloc.add(GetProductFiltersEvent(
        fromSearch: widget.fromSearch,
        boutiqueSlug: widget.boutiqueSlug,
        category: widget.category,
        searchText: widget.fromSearch ? widget.searchText : null));
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
    homeBloc.add(ChangeSelectedFiltersEvent(
        boutiqueSlug: widget.boutiqueSlug,
        category: widget.category,
        filtersChoosedByUser: null));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            WillPopScope(
              onWillPop: () async {
                searchVisible.value = false;
                if (filterPageExpanded.value) {
                  filterPageExpanded.value = false;
                  return Future.value(false);
                }
                return Future.value(true);
              },
              child: Scaffold(
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
                              return CustomScrollView(
                                  controller: scrollController,
                                  physics: ClampingScrollPhysics(),
                                  slivers: [
                                    SliverAppBar(
                                      pinned: true,
                                      backgroundColor: colorScheme.white,
                                      automaticallyImplyLeading: false,
                                      flexibleSpace: ValueListenableBuilder<bool>(
                                          valueListenable: searchVisible,
                                          builder: (context , searchOpen , _) {
                                            return TrydosAppBar(
                                        appBarParams: AppBarParams(
                                            backgroundColor: colorScheme.white,
                                            scrolledUnderElevation: 0,
                                            backIconColor: Colors.black,
                                            hasLeading: !isExpanded && !searchOpen,
                                            action: [
                                               ValueListenableBuilder<bool>(
                                                      valueListenable:
                                                          displayBoutiqueIconInAppBar,
                                                      builder:
                                                          (context, display, _) {
                                                        return Visibility(
                                                          visible: display && !searchOpen,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .only(
                                                                        start:
                                                                            30.w),
                                                            child: SvgNetworkWidget(
                                                              svgUrl: widget
                                                                      .boutiqueIcon ??
                                                                  "",
                                                              height: 20,
                                                            ),
                                                          ),
                                                        );
                                                }
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(end: 20.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    searchVisible.value =
                                                        !searchVisible
                                                            .value;
                                                    focusNode.unfocus();
                                                  },
                                                  child: BlocBuilder<HomeBloc,
                                                      HomeState>(
                                                    builder: (context, state) {
                                                      Filter?
                                                          prevChoosedOrAppliedFilter =
                                                          homeBloc
                                                              .state
                                                              .appliedFiltersByUser
                                                              ?.filters;
                                                      return AnimatedSearchBar(
                                                        onFieldSubmitted:
                                                            (text) {
                                                          if (text.length > 2) {
                                                            searchVisible
                                                                    .value =
                                                                !searchVisible
                                                                    .value;
                                                          }
                                                        },
                                                        width: 1.sw - 20,
                                                        height: 40,
                                                        onClickClose: () {
                                                          if (controller
                                                                  .text.length >
                                                              0) {
                                                            controller.clear();
                                                          } else {
                                                            searchVisible
                                                                    .value =
                                                                false;
                                                            appBloc.add(
                                                                HideBottomNavigationBar(
                                                                    false));
                                                          }
                                                        },
                                                        textController:
                                                            controller,
                                                        focusNode: focusNode,
                                                        onSuffixTap: () {
                                                          searchVisible.value = true;
                                                          controller.text = "";
                                                        },
                                                        suffixWidget: Center(
                                                          child:
                                                              SvgPicture.asset(
                                                            AppAssets
                                                                .searchOutlinedSvg,
                                                            height: 20,
                                                            width: 20,
                                                            color: Color(
                                                                0xff388CFF),
                                                          ),
                                                        ),
                                                        prefixWidget: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 15,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .realCameraSvg,
                                                                height: 20,
                                                                width: 20,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .microphoneSvg,
                                                                height: 20,
                                                                width: 20,
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
                                                                width: 0.4),
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
                                                                width: 0.4),
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
                                                                width: 0.4),
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
                                                                width: 0.4),
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
                                                                width: 0.4),
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
                                                                width: 0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        kbrBorderTextField),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                          focusNode.hasFocus
                                                              ? colorScheme.white
                                                              : Color(0xffF8F8F8),
                                                          prefixIcon: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 12,
                                                                    bottom: 12),
                                                            child: SvgPicture
                                                                .asset(
                                                              AppAssets
                                                                  .searchOutlinedSvg,
                                                              height: 20,
                                                              width: 20,
                                                              color: Color(
                                                                  0xff388CFF),
                                                            ),
                                                          ),
                                                          suffixIcon: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 15,
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  AppAssets
                                                                      .realCameraSvg,
                                                                  height: 20,
                                                                  width: 20,
                                                                ),
                                                                SizedBox(
                                                                  width: 20,
                                                                ),
                                                                SvgPicture
                                                                    .asset(
                                                                  AppAssets
                                                                      .microphoneSvg,
                                                                  height: 20,
                                                                  width: 20,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          //context.colorScheme.white,
                                                          contentPadding:
                                                              HWEdgeInsetsDirectional
                                                                  .only(
                                                                      start: 20,
                                                                      end: 10,
                                                                      bottom:
                                                                          12,
                                                                      top: 12),
                                                          hintText: 'Search',
                                                          hintStyle: context
                                                              .textTheme
                                                              .subtitle1
                                                              ?.lq
                                                              .copyWith(
                                                                  color: Color(
                                                                      0xffC4C2C2)),
                                                          labelStyle: context
                                                              .textTheme
                                                              .bodyText2
                                                              ?.copyWith(
                                                                  color: context
                                                                      .colorScheme
                                                                      .hint),
                                                        ),
                                                        onChanged:
                                                            (String text) {
                                                          //  buildSearchResult.value = text.length;
                                                          if (text.length > 2) {
                                                            homeBloc.add(
                                                                GetProductsWithFiltersEvent(
                                                              filtersAppliedByUser:
                                                                  GetProductFiltersModel(
                                                                      filters:
                                                                          prevChoosedOrAppliedFilter),
                                                              fromSearch: widget
                                                                  .fromSearch,
                                                              category: widget
                                                                  .category,
                                                              offset: 1,
                                                              getWithPagination:
                                                                  false,
                                                              searchText: text,
                                                              boutiqueSlug: widget
                                                                  .boutiqueSlug,
                                                            ));
                                                          }
                                                        },
                                                        hideTrendingAndHistory:
                                                            hideTrendingAndHistory,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                             searchOpen ? SizedBox.shrink() : Row(
                                               children: [
                                                 isExpanded
                                                     ? SizedBox.shrink()
                                                     : Padding(
                                                   padding:
                                                   const EdgeInsetsDirectional
                                                       .only(end: 20.0),
                                                   child: SvgPicture.asset(
                                                       AppAssets.sortingSvg,
                                                       width: 20,
                                                       height: 20),
                                                 ),
                                                 Padding(
                                                     padding:
                                                     const EdgeInsetsDirectional
                                                         .only(end: 20.0),
                                                     child: GestureDetector(
                                                       onTap: () {
                                                         filterPageExpanded.value =
                                                         true;
                                                       },
                                                       child: SvgPicture.asset(
                                                         AppAssets.filtersSvg,
                                                         width: 20,
                                                         height: 20,
                                                         color: isExpanded
                                                             ? Color(0xffFF5F61)
                                                             : null,
                                                       ),
                                                     )),
                                                 GestureDetector(
                                                     onTap: () {
                                                       if (isExpanded)
                                                         filterPageExpanded.value =
                                                         false;
                                                     },
                                                     child: SizedBox(
                                                       height: 30,
                                                       child: Row(children: [
                                                         !isExpanded
                                                             ? SvgPicture.asset(
                                                           AppAssets
                                                               .shareSvg,
                                                           width: 20,
                                                           height: 20,
                                                           color: Color(
                                                               0xff3C3C3C),
                                                         )
                                                             : GestureDetector(
                                                           child: SvgPicture
                                                               .asset(
                                                             AppAssets
                                                                 .closeSvg,
                                                             width: 15,
                                                             height: 15,
                                                             color: Color(
                                                                 0xffFF5F61),
                                                           ),
                                                         ),
                                                         SizedBox(
                                                             width: !isExpanded
                                                                 ? 10.0
                                                                 : 25)
                                                       ]),
                                                     )),
                                               ],
                                             )
                                            ],
                                            withShadow: false),
                                      );})
                                    ),
                                    ValueListenableBuilder<bool>(
                                        valueListenable: searchVisible,
                                        builder: (context, searchOpen, _) {
                                          return !widget.fromSearch
                                              ? searchOpen
                                                  ? SliverToBoxAdapter()
                                                  : ValueListenableBuilder<
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
                                                                      Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.min,
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
                                                                              height: 5,
                                                                            ),
                                                                            Html(key: htmlDescriptionKey, shrinkWrap: true, data: widget.boutiqueDescription, style: {
                                                                              "body": Style(margin: Margins.all(0)),
                                                                              "p": Style(
                                                                                margin: Margins.all(0),
                                                                              ),
                                                                            }),
                                                                            SizedBox(
                                                                              height: 10,
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
                                                                              height: 10,
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
                                          return searchOpen && !isExpanded
                                              ? SliverToBoxAdapter()
                                              : BlocBuilder<HomeBloc,
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
                                                        toolbarHeight:
                                                            isExpanded
                                                                ? 860
                                                                : (state.getProductFiltersModel?.filters == null &&
                                                                        state.getProductFiltersStatus !=
                                                                            GetProductFiltersStatus
                                                                                .loading)
                                                                    ? 35
                                                                    : state.appliedFiltersByUser !=
                                                                            null
                                                                        ? (state.getProductListingWithFiltersPaginationModels?.items.length ?? 1) ==
                                                                                1
                                                                            ? 35
                                                                            : 145
                                                                        : 115,
                                                        flexibleSpace:
                                                            StackedFiltersList(
                                                                fromSearch: widget
                                                                    .fromSearch,
                                                                searchText: controller.text.length >
                                                                        2
                                                                    ? controller
                                                                        .text
                                                                    : widget
                                                                        .searchText,
                                                                filterPageExpanded:
                                                                    filterPageExpanded,
                                                                closeFilterPage:
                                                                    () {
                                                                  filterPageExpanded
                                                                          .value =
                                                                      false;
                                                                },
                                                                displayAppliedFiltersOnly:
                                                                    (state.getProductListingWithFiltersPaginationModels?.items.length ??
                                                                            1) ==
                                                                        1,
                                                                category: widget
                                                                    .category,
                                                                boutiqueSlug: widget
                                                                    .boutiqueSlug,
                                                                controller:
                                                                    isExpanded
                                                                        ? scrollController
                                                                        : null,
                                                                onMoveToAnotherFiltersSection:
                                                                    (title) {
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
                                    ValueListenableBuilder<bool>(
                                        valueListenable: searchVisible,
                                        builder: (context, searchOpen, _) {
                                          return isExpanded
                                              ? SliverToBoxAdapter()
                                              : searchOpen
                                                  ? SearchListingPage(
                                                      buildSearchResult:
                                                          buildSearchResult,
                                                      hideTrendingAndHistory:
                                                          hideTrendingAndHistory,
                                                      controller: controller)
                                                  : BlocBuilder<HomeBloc,
                                                      HomeState>(
                                                      buildWhen: (p, c) {
                                                        String key = widget
                                                                .boutiqueSlug +
                                                            (widget.category ??
                                                                '');
                                                        if (p
                                                                .getProductListingPaginationWithoutFiltersModel[
                                                                    key]
                                                                ?.items
                                                                .length !=
                                                            c
                                                                .getProductListingPaginationWithoutFiltersModel[
                                                                    key]
                                                                ?.items
                                                                .length) {
                                                          gridViewKeyForRendering =
                                                              UniqueKey();
                                                        }
                                                        return p.getProductListingWithFiltersPaginationModels
                                                                    ?.paginationStatus !=
                                                                c.getProductListingWithFiltersPaginationModels
                                                                    ?.paginationStatus ||
                                                            (p
                                                                    .getProductListingPaginationWithoutFiltersModel[
                                                                        key]
                                                                    ?.paginationStatus !=
                                                                c
                                                                    .getProductListingPaginationWithoutFiltersModel[
                                                                        key]
                                                                    ?.paginationStatus);
                                                      },
                                                      builder:
                                                          (context, state) {
                                                        String key = widget
                                                                .boutiqueSlug +
                                                            (widget.category ??
                                                                '');
                                                        if (state
                                                                .getProductListingWithFiltersPaginationModels
                                                                ?.paginationStatus ==
                                                            PaginationStatus
                                                                .loading) {
                                                          return SliverPadding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10),
                                                            sliver: SliverGrid(
                                                              key:
                                                                  gridViewKeyForRendering,
                                                              gridDelegate:
                                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                childAspectRatio:
                                                                    200.w / 350,
                                                                crossAxisSpacing:
                                                                    10,
                                                                mainAxisSpacing:
                                                                    15,
                                                              ),
                                                              delegate:
                                                                  SliverChildBuilderDelegate(
                                                                childCount: 4,
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                                  return Container(
                                                                      child: Shimmer
                                                                          .fromColors(
                                                                        baseColor:
                                                                            Colors.grey[200]!,
                                                                        highlightColor:
                                                                            Colors.grey[100]!,
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              Color(0xffF8F8F8),
                                                                        ),
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                234,
                                                                                236,
                                                                                238),
                                                                            width:
                                                                                0.3),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(15),
                                                                          topRight:
                                                                              Radius.circular(5),
                                                                          bottomLeft:
                                                                              Radius.circular(15),
                                                                          bottomRight:
                                                                              Radius.circular(5),
                                                                        ),
                                                                      ));
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        List<
                                                            filter_products
                                                            .Products> products;
                                                        if (state.getProductListingWithFiltersPaginationModels !=
                                                                null &&
                                                            state
                                                                .getProductListingWithFiltersPaginationModels!
                                                                .items
                                                                .isNotEmpty) {
                                                          products = state
                                                              .getProductListingWithFiltersPaginationModels!
                                                              .items;
                                                        } else {
                                                          if ((state
                                                                          .getProductListingPaginationWithoutFiltersModel[
                                                                              key]
                                                                          ?.paginationStatus ==
                                                                      PaginationStatus
                                                                          .loading &&
                                                                  (state
                                                                          .getProductListingPaginationWithoutFiltersModel[
                                                                              key]
                                                                          ?.items
                                                                          .isNullOrEmpty ??
                                                                      true)) ||
                                                              (state.getProductListingPaginationWithoutFiltersModel[
                                                                      key] ==
                                                                  null)) {
                                                            return SliverPadding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              sliver:
                                                                  SliverGrid(
                                                                key:
                                                                    gridViewKeyForRendering,
                                                                gridDelegate:
                                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                                  crossAxisCount:
                                                                      2,
                                                                  childAspectRatio:
                                                                      200.w /
                                                                          350,
                                                                  crossAxisSpacing:
                                                                      10,
                                                                  mainAxisSpacing:
                                                                      15,
                                                                ),
                                                                delegate:
                                                                    SliverChildBuilderDelegate(
                                                                  childCount: 8,
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                    return ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0),
                                                                      child: Shimmer.fromColors(
                                                                          baseColor: Colors.grey.shade300,
                                                                          highlightColor: Colors.grey.shade100,
                                                                          enabled: true,
                                                                          child: Stack(
                                                                            children: [
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: const Color(0xff000000).withOpacity(0.4),
                                                                                    offset: Offset(0, 3),
                                                                                    blurRadius: 6,
                                                                                  )
                                                                                ],
                                                                              )),
                                                                              Container(
                                                                                  height: 275,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                                    boxShadow: [
                                                                                      BoxShadow(
                                                                                        color: const Color(0xff000000).withOpacity(0.6),
                                                                                        offset: Offset(0, 3),
                                                                                        blurRadius: 6,
                                                                                      )
                                                                                    ],
                                                                                  )),
                                                                              Positioned(
                                                                                bottom: 70,
                                                                                left: 60.w,
                                                                                child: SizedBox(
                                                                                  width: 100.w,
                                                                                  child: Stack(
                                                                                    alignment: Alignment.center,
                                                                                    children: List.generate(
                                                                                        5,
                                                                                        (index) => Positioned(
                                                                                              left: index == 0
                                                                                                  ? 0
                                                                                                  : index == 2
                                                                                                      ? 15
                                                                                                      : null,
                                                                                              right: index == 1
                                                                                                  ? 0
                                                                                                  : index == 3
                                                                                                      ? 15
                                                                                                      : null,
                                                                                              child: CircleAvatar(
                                                                                                radius: index == 4
                                                                                                    ? 20
                                                                                                    : index < 2
                                                                                                        ? 12
                                                                                                        : 15,
                                                                                              ),
                                                                                            )),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          products = state
                                                                  .getProductListingPaginationWithoutFiltersModel[
                                                                      key]
                                                                  ?.items ??
                                                              [];
                                                        }
                                                        return SliverPadding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10),
                                                          sliver: SliverGrid(
                                                            key:
                                                                gridViewKeyForRendering,
                                                            gridDelegate:
                                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 2,
                                                              childAspectRatio:
                                                                  200.w / 350,
                                                              crossAxisSpacing:
                                                                  10,
                                                              mainAxisSpacing:
                                                                  15,
                                                            ),
                                                            delegate:
                                                                SliverChildBuilderDelegate(
                                                              childCount:
                                                                  products
                                                                      .length,
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                                return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                100),
                                                                        () {
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
                                                                          "time_stamp": DateTime.now()
                                                                              .toUtc()
                                                                              .add(Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0))
                                                                              .toString(),
                                                                          "previous_event_button_name":
                                                                              GetIt.I<PrefsRepository>().currentEvent,
                                                                          "device_language": LanguageService.languageCode == 'ar'
                                                                              ? 'ae'
                                                                              : LanguageService.languageCode,
                                                                          "country_name":
                                                                              GetIt.I<PrefsRepository>().countryIso,
                                                                          'userID': prefsRepository
                                                                              .myMarketId
                                                                              .toString(),
                                                                          'user_name': prefsRepository
                                                                              .myMarketName
                                                                              .toString(),
                                                                          'clicked_button_name':
                                                                              'i love you Ahmad',
                                                                          "session_id":
                                                                              GetIt.I<PrefsRepository>().sessionId,
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
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(
                                                                            builder: (ctx) => ProductDetailsPage(
                                                                                  productItem: products[index],
                                                                                )));
                                                                  },
                                                                  child:
                                                                      ProductItem(
                                                                    slidingModeItem:
                                                                        slidingMode,
                                                                    productItem:
                                                                        products[
                                                                            index],
                                                                    itemIndex:
                                                                        index,
                                                                    setThisEnabled:
                                                                        (int index,
                                                                            int slideMode) {
                                                                      setThisEnabledNotifier
                                                                              .value =
                                                                          Tuple2(
                                                                              index,
                                                                              slideMode);
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                        }),
                                  ]);
                            });
                      }),
                ),
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
    );
  }
}
