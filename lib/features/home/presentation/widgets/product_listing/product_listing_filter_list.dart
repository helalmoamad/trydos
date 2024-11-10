import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing;
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter_ranges.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter_slider.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/sizes_filters_list.dart';
import 'package:tuple/tuple.dart';
import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/get_product_filters_model.dart' as filter_model;
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';
import '../../manager/home_state.dart';
import 'categories_filter_list.dart';
import 'color_list_filter.dart';
import 'filters_loding_list.dart';
import 'filters_normal_list.dart';

class StackedFiltersList extends StatefulWidget {
  const StackedFiltersList(
      {super.key,
      required this.onMoveToAnotherFiltersSection,
      this.controller,
      required this.boutiqueSlug,
      required this.expandingFiltersStack,
      required this.filterPageExpanded,
      required this.displayAppliedFiltersOnly,
      this.category,
      this.searchText,
      required this.fromSearch,
      required this.textController,
      required this.closeFilterPage,
      required this.hideTitle});

  final void Function() closeFilterPage;
  final void Function(String message) onMoveToAnotherFiltersSection;
  final ScrollController? controller;
  final bool hideTitle;
  final bool filterPageExpanded;
  final bool fromSearch;
  final String? searchText;
  final ValueNotifier<int> expandingFiltersStack;
  final TextEditingController textController;
  final String boutiqueSlug;
  final String? category;
  final bool displayAppliedFiltersOnly;

  @override
  _StackedFiltersListState createState() => _StackedFiltersListState();
}

class _StackedFiltersListState extends State<StackedFiltersList> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);

  final ValueNotifier<int> currentActiveSection = ValueNotifier(0);
  late AutoScrollController autoScrollController;
  ValueNotifier<Tuple2<double, double>>? lowerAndUpperPrices;

  int lastSectionDisplayed = 0;
  double? minPrice;
  double? maxPrice;
  String currencySymbol = '';
  late HomeBloc homeBloc;
  double exchangeRate = 0.0;
  filter_model.Filter? filters;
  bool isExpanded = false;

  String key = '';

  @override
  void initState() {
    key = widget.boutiqueSlug + (widget.category ?? '');
    homeBloc = BlocProvider.of<HomeBloc>(context);

    autoScrollController = AutoScrollController();

    super.initState();
  }

  @override
  void dispose() {
    lowerAndUpperPrices?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.appliedFiltersByUser[key] !=
                current.appliedFiltersByUser[key] ||
            previous.choosedFiltersByUser[key] !=
                current.choosedFiltersByUser[key] ||
            previous.isExpandedForListingPage !=
                current.isExpandedForListingPage ||
            previous.getProductFiltersStatus[key] !=
                current.getProductFiltersStatus[key] ||
            previous
                    .getProductListingWithFiltersPaginationModels[
                        '${widget.boutiqueSlug}' +
                            'withoutFilter' +
                            '${(widget.category ?? '')}']
                    ?.paginationStatus !=
                current
                    .getProductListingWithFiltersPaginationModels[
                        '${widget.boutiqueSlug}' +
                            'withoutFilter' +
                            '${(widget.category ?? '')}']
                    ?.paginationStatus ||
            previous.getProductListingStatus !=
                current.getProductListingStatus ||
            previous.cashedOrginalBoutique != current.cashedOrginalBoutique,
        builder: (context, state) {
          isExpanded = state.isExpandedForListingPage ?? false;
          print('//////// isExpanded : $isExpanded ///////////');
          if ((state.getProductFiltersStatus[key] ==
                  GetProductFiltersStatus.loading &&
              state.getProductFiltersStatus[key] == null)) {
            return FiltersLoadingListPage(
              countOfListInPage: isExpanded ? 6 : 1,
            );
          }
          if (state.getProductFiltersModel[key]?.filters?.totalSize == 0 &&
              isExpanded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  state.getProductFiltersStatus[key] ==
                          GetProductFiltersStatus.loading
                      ? Center(
                          child: TrydosLoader(
                            size: 20,
                          ),
                        )
                      : Center(
                          child: MyTextWidget(
                            "No Filters Found",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                  SizedBox(
                    height: 100,
                  ),
                  Container(
                    width: 200,
                    child: InkWell(
                      onTap: () {
                        widget.textController.text = "";
                        if (lowerAndUpperPrices != null) {
                          lowerAndUpperPrices!.value =
                              Tuple2(minPrice!, maxPrice!);
                        }

                        homeBloc.add(AddPrefAppliedFilterForExtendFilterEvent(
                            prefAppliedFilter: Filter()));
                        homeBloc.add(ChangeAppliedFiltersEvent(
                          resetAppliedFilters: true,
                          boutiqueSlug: widget.boutiqueSlug,
                          category: widget.category,
                        ));

                        homeBloc.add(ChangeSelectedFiltersEvent(
                            fromHomePageSearch: widget.fromSearch,
                            boutiqueSlug: widget.boutiqueSlug,
                            category: widget.category,
                            resetChoosedFilters: true,
                            filtersChoosedByUser: null));
                        homeBloc.add(GetProductsWithFiltersEvent(
                          fromSearch: widget.fromSearch,
                          boutiqueSlug: widget.boutiqueSlug,
                          cashedOrginalBoutique: true,
                          searchText: null,
                          category: widget.category,
                          offset: 1,
                        ));
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 65,
                            decoration: BoxDecoration(
                                color: colorScheme.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: Offset(0, 3)),
                                  BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                      inset: true)
                                ],
                                border: Border.all(color: Color(0xff388CFF))),
                            child: Center(
                              child: MyTextWidget(
                                'Reset',
                                style: textTheme.bodyLarge?.rq.copyWith(
                                    color: Color(0xff388CFF), height: 23 / 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // if (state.getProductFiltersStatus == GetProductFiltersStatus.failure) {
          //   return Center(child: TryAgainWidget(tryAgain: () {
          //     BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent());
          //   }));
          // }
          if ((state.getProductFiltersModel[key]?.filters == null &&
              state.cashedOrginalBoutique &&
              state.appliedFiltersByUser[key] == null)) {
            print('ssss ${state.choosedFiltersByUser}');
            return SizedBox.shrink();
          }
          GetProductFiltersModel? appliedFiltersByUser =
              state.appliedFiltersByUser[key];
          String? currentAppliedFilterSllug = "Empty";

          if (!isExpanded &&
              (appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3) {
            currentAppliedFilterSllug;
            if ((appliedFiltersByUser?.filters?.categories?.length ?? 0) > 0) {
              currentAppliedFilterSllug =
                  appliedFiltersByUser?.filters?.categories?[0].slug;
            } else if ((appliedFiltersByUser?.filters?.brands?.length ?? 0) >
                0) {
              currentAppliedFilterSllug =
                  appliedFiltersByUser?.filters?.brands?[0].slug;
            } else if ((appliedFiltersByUser
                        ?.filters?.attributes?[0].options?.length ??
                    0) >
                0) {
              currentAppliedFilterSllug =
                  appliedFiltersByUser?.filters?.attributes?[0].options?[0];
            } else if ((appliedFiltersByUser?.filters?.colors?.length ?? 0) >
                0) {
              appliedFiltersByUser?.filters?.colors?[0];
            } else if (appliedFiltersByUser?.filters?.prices?.minPrice !=
                null) {
              currentAppliedFilterSllug =
                  "${appliedFiltersByUser?.filters?.prices?.minPrice}-${appliedFiltersByUser?.filters?.prices?.maxPrice}";
            } else {
              currentAppliedFilterSllug = "Empty";
            }
          }
          if ((appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3 &&
              !isExpanded &&
              (((appliedFiltersByUser?.filters?.categories?.length ?? 0) +
                              (appliedFiltersByUser?.filters?.brands?.length ??
                                  0) +
                              (appliedFiltersByUser?.filters?.colors?.length ??
                                  0) +
                              (appliedFiltersByUser?.filters?.attributes?[0].options?.length ??
                                  0) ==
                          1 &&
                      !widget.fromSearch &&
                      !isExpanded &&
                      (appliedFiltersByUser?.filters?.prices?.minPrice ==
                          null)) ||
                  ((appliedFiltersByUser?.filters?.categories?.length ?? 0) +
                              (appliedFiltersByUser?.filters?.brands?.length ??
                                  0) +
                              (appliedFiltersByUser?.filters?.colors?.length ??
                                  0) +
                              (appliedFiltersByUser?.filters?.attributes?[0]
                                      .options?.length ??
                                  0) ==
                          0 &&
                      !widget.fromSearch &&
                      (appliedFiltersByUser?.filters?.prices?.minPrice !=
                          null))) &&
              (state.getProductListingWithFiltersPaginationWithPrefetchModels["${widget.boutiqueSlug}" + "${currentAppliedFilterSllug}" + "${widget.category ?? ""}"]?.paginationStatus ==
                  PaginationStatus.success)) {
            filters = (state
                            .getProductListingWithFiltersPaginationWithPrefetchModels[
                                '${widget.boutiqueSlug}' +
                                    '${currentAppliedFilterSllug}' +
                                    '${(widget.category ?? '')}']
                            ?.items
                            .length ??
                        0) ==
                    1
                ? filter_model.Filter()
                : state
                        .getProductFiltersWithPrefetchModel[
                            '${widget.boutiqueSlug}' +
                                '${currentAppliedFilterSllug}' +
                                '${(widget.category ?? '')}']
                        ?.filters ??
                    filter_model.Filter();
          } else if (((!widget.fromSearch &&
                  !isExpanded &&
                  (appliedFiltersByUser?.filters?.prices?.minPrice == null))) &&
              currentAppliedFilterSllug == "Empty" &&
              state.getProductFiltersWithPrefetchModel['${widget.boutiqueSlug}' + 'Empty' + '${(widget.category ?? '')}']?.filters != null &&
              (state.getProductListingWithFiltersPaginationWithPrefetchModels["${widget.boutiqueSlug}" + "Empty" + "${widget.category ?? ""}"]?.paginationStatus == PaginationStatus.success)) {
            print(
                "*************************************888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888");

            filters = (state
                            .getProductListingWithFiltersPaginationWithPrefetchModels[
                                '${widget.boutiqueSlug}' +
                                    'Empty' +
                                    '${(widget.category ?? '')}']
                            ?.items
                            .length ??
                        0) ==
                    1
                ? filter_model.Filter()
                : state
                    .getProductFiltersWithPrefetchModel[
                        '${widget.boutiqueSlug}' +
                            'Empty' +
                            '${(widget.category ?? '')}']
                    ?.filters;
          } else {
            print(
                "8888888888888888888888888888888888888888888888888${state.cashedOrginalBoutique}88888888888888888888888888888888888888888888888888888888888888888888888888888");
            filters = (state
                                .getProductListingWithFiltersPaginationModels[
                                    '${widget.boutiqueSlug}' +
                                        '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                        '${(widget.category ?? '')}']
                                ?.items
                                .length ??
                            0) ==
                        1 &&
                    !isExpanded &&
                    state
                            .getProductListingWithFiltersPaginationModels[
                                '${widget.boutiqueSlug}' +
                                    '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                    '${(widget.category ?? '')}']
                            ?.paginationStatus ==
                        PaginationStatus.success &&
                    state.getProductFiltersStatus[key] ==
                        GetProductFiltersStatus.success
                ? filter_model.Filter()
                : state.getProductFiltersModel[key]?.filters ??
                    filter_model.Filter();
          }

          if (filters?.prices != null) {
            exchangeRate = state
                    .getCurrencyForCountryModel?.data?.currency?.exchangeRate ??
                1;
            currencySymbol =
                state.getCurrencyForCountryModel?.data?.currency?.symbol ??
                    '\$';
            minPrice = (filters?.prices!.minPrice ?? 0) * exchangeRate;
            maxPrice = (filters?.prices!.maxPrice ?? 0) * exchangeRate;
            lowerAndUpperPrices = ValueNotifier(Tuple2(minPrice!, maxPrice!));
          }
          int countOfFilters = 0;
          List<String> titleOfFilterSection = [];
          if (filters == null) {
            filters = Filter();
          }
          if (!filters!.categories.isNullOrEmpty) {
            countOfFilters++;
            titleOfFilterSection.add('View By Categories');
          }
          if (!filters!.brands.isNullOrEmpty) {
            countOfFilters++;
            titleOfFilterSection.add('View By Brands');
          }
          if (!filters!.attributes.isNullOrEmpty) {
            if (!filters!.attributes![0].options.isNullOrEmpty) {
              countOfFilters++;
              titleOfFilterSection.add('View By Sizes');
            }
          }
          if (!filters!.colors.isNullOrEmpty) {
            countOfFilters++;
            titleOfFilterSection.add('View By Colors');
          }
          if (filters!.prices != null) {
            countOfFilters++;
            titleOfFilterSection.add('View By Price');
          }
          if (countOfFilters == 0 &&
              state.appliedFiltersByUser[key] == null &&
              state.cashedOrginalBoutique) {
            return SizedBox.shrink();
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (countOfFilters != 0) ...{
                if (isExpanded) ...{
                  !filters!.categories.isNullOrEmpty
                      ? Padding(
                          padding: EdgeInsetsDirectional.only(start: 25),
                          child: Row(
                            key: TestVariables.kTestMode
                                ? Key(WidgetsKey.filterByCategoryHeadKey)
                                : null,
                            children: [
                              FilterSelectedMark(width: 20, height: 20),
                              SizedBox(
                                width: 10,
                              ),
                              MyTextWidget(
                                'Filter By Category',
                                style: context.textTheme.titleMedium?.rq
                                    .copyWith(
                                        color: Color(0xff505050),
                                        height: 15 / 12),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              SvgPicture.asset(
                                AppAssets.registerInfoSvg,
                                color: Color(0xffD3D3D3),
                              ),
                              if (state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading)
                                Row(
                                  key: TestVariables.kTestMode
                                      ? Key(WidgetsKey.getCategoriesLoadingKey)
                                      : null,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    TrydosLoader(
                                      size: 20,
                                    ),
                                  ],
                                )
                            ],
                          ))
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 10,
                  )
                },
                if ((widget.displayAppliedFiltersOnly && !isExpanded)) ...{
                  SizedBox.shrink()
                },
                if ((!widget.displayAppliedFiltersOnly && !isExpanded) ||
                    isExpanded) ...{
                  SizedBox(
                    height: 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: isExpanded ? 20 : 15,
                        ),
                        Visibility(
                          visible: !isExpanded,
                          child: InkWell(
                            onTap: () {
                              currentActiveSection.value =
                                  currentActiveSection.value ==
                                          (countOfFilters - 1)
                                      ? 0
                                      : (currentActiveSection.value + 1);
                              autoScrollController.scrollToIndex(
                                  2 * currentActiveSection.value,
                                  duration: Duration(milliseconds: 200),
                                  preferPosition: AutoScrollPosition.begin);
                              widget.onMoveToAnotherFiltersSection.call(
                                  titleOfFilterSection[
                                      currentActiveSection.value]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 35.0),
                              child: ValueListenableBuilder<int>(
                                  valueListenable: currentActiveSection,
                                  builder: (context, currentActive, _) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 8,
                                          child: ListView.builder(
                                              itemCount: countOfFilters,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (ctx, index) {
                                                return Row(
                                                  children: [
                                                    Container(
                                                      height: 8,
                                                      width: 8,
                                                      decoration: BoxDecoration(
                                                          color: currentActive ==
                                                                  index
                                                              ? Color(
                                                                  0xff505050)
                                                              : null,
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xff505050))),
                                                    ),
                                                    Container(
                                                      width: index !=
                                                              (countOfFilters -
                                                                  1)
                                                          ? 2
                                                          : 0,
                                                      color: Colors.transparent,
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        /*
                 key: Key('$index-section'),
                                      onVisibilityChanged: (visibilityInfo) {
                                        if (autoScrollController.hasClients &&
                                            autoScrollController.position
                                                    .userScrollDirection ==
                                                rendring.ScrollDirection.idle) {
                                          return;
                                        }
                                        if (isExpanded) return;
                                        double visiblePercentage =
                                            visibilityInfo.visibleFraction *
                                                100;
                                        if (visiblePercentage == 0) {
                                          if ((int.parse(visibilityInfo.key
                                                  .toString()[3]) !=
                                              (2 *
                                                  currentActiveSection
                                                      .value))) {
                                            return;
                                          }
                                          int sectionIndex = -1;
                                          // scroll to the right
                                          if (autoScrollController.hasClients &&
                                              autoScrollController.position
                                                      .userScrollDirection ==
                                                  rendring.ScrollDirection
                                                      .reverse) {
                                            sectionIndex = (int.parse(
                                                        visibilityInfo.key
                                                            .toString()[3]) +
                                                    2) ~/
                                                2;
                                          } else {
                                            sectionIndex = (int.parse(
                                                        visibilityInfo.key
                                                            .toString()[3]) -
                                                    2) ~/
                                                2;
                                          }
                                          currentActiveSection.value =
                                              max(0, sectionIndex);
                                          widget.onMoveToAnotherFiltersSection
                                              .call(titleOfFilterSection[
                                                  currentActiveSection.value]);
                                        }
                                      },
                 */
                        ScrollConfiguration(
                          key: TestVariables.kTestMode
                              ? Key(WidgetsKey.filterPageScrollKey)
                              : null,
                          behavior: CupertinoScrollBehavior(),
                          child: Expanded(
                            child: InViewNotifierList(
                                key: TestVariables.kTestMode == false
                                    ? null
                                    : Key(
                                        WidgetsKey.productListingFilterListKey),
                                isInViewPortCondition: (double deltaTop,
                                    double deltaBottom, double vpWidth) {
                                  print(
                                      'fucjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj $deltaTop $deltaBottom $vpWidth');
                                  return deltaTop <= (0.5 * vpWidth) &&
                                      deltaBottom >= (0.7 * vpWidth);
                                },
                                controller: autoScrollController,
                                itemCount:
                                    isExpanded ? 1 : 2 * countOfFilters - 1,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: EdgeInsets.only(
                                    left: LanguageService.rtl ? 0 : 5,
                                    right: !LanguageService.rtl ? 0 : 5),
                                builder: (ctx, index) {
                                  if (index & 1 == 0)
                                    return InViewNotifierWidget(
                                      id: 'id-$index',
                                      builder: (BuildContext context,
                                          bool isInView, Widget? child) {
                                        if (isInView &&
                                            currentActiveSection.value !=
                                                (index ~/ 2)) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback(
                                                  (timeStamp) {
                                            currentActiveSection.value =
                                                index ~/ 2;
                                            widget.onMoveToAnotherFiltersSection
                                                .call(titleOfFilterSection[
                                                    index ~/ 2]);
                                          });
                                        }
                                        return child!;
                                      },
                                      child: AutoScrollTag(
                                        key: ValueKey(
                                            '${DateTime.now()}index $index'),
                                        controller: autoScrollController,
                                        index: index,
                                        child: index == 0 &&
                                                titleOfFilterSection[
                                                        index ~/ 2] ==
                                                    'View By Categories'
                                            ? CategoriesFilterList(
                                                filterss: filters ?? Filter(),
                                                key: TestVariables.kTestMode ==
                                                        false
                                                    ? null
                                                    : Key(WidgetsKey
                                                        .categoriesProductListingFilterListKey),
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                fromSearch: widget.fromSearch,
                                                expandingFiltersStack: widget
                                                    .expandingFiltersStack,
                                                scaleTheTopItemInFiltersStack:
                                                    scaleTheTopItemInFiltersStack,
                                                workWithChoosedFilter:
                                                    isExpanded,
                                                category: widget.category,
                                              )
                                            : index <= 2 &&
                                                    titleOfFilterSection[
                                                            index ~/ 2] ==
                                                        'View By Brands'
                                                ? FiltersNormalList(
                                                    key: TestVariables
                                                                .kTestMode ==
                                                            false
                                                        ? null
                                                        : Key(WidgetsKey
                                                            .brandsProductListingFilterListKey),
                                                    hideTitle: true,
                                                    boutiqueSlug:
                                                        widget.boutiqueSlug,
                                                    fromHomeSearch:
                                                        widget.fromSearch,
                                                    searchText:
                                                        widget.searchText,
                                                    category: widget.category,
                                                    filterListTitle:
                                                        'Filter By Brand',
                                                    isBrandFilter: true,
                                                    filters:
                                                        filters!.brands ?? [],
                                                  )
                                                : index <= 4 &&
                                                        titleOfFilterSection[
                                                                index ~/ 2] ==
                                                            'View By Sizes'
                                                    ? SizesFiltersList(
                                                        key: TestVariables
                                                                    .kTestMode ==
                                                                false
                                                            ? null
                                                            : Key(WidgetsKey
                                                                .sizesProductListingFilterListKey),
                                                        hideTitle: true,
                                                        boutiqueSlug:
                                                            widget.boutiqueSlug,
                                                        fromHomeSearch:
                                                            widget.fromSearch,
                                                        searchText:
                                                            widget.searchText,
                                                        category:
                                                            widget.category,
                                                        attribute: filters!
                                                            .attributes![0],
                                                      )
                                                    : index <= 6 &&
                                                            titleOfFilterSection[
                                                                    index ~/
                                                                        2] ==
                                                                'View By Colors'
                                                        ? ColorsListFilter(
                                                            key: TestVariables
                                                                        .kTestMode ==
                                                                    false
                                                                ? null
                                                                : Key(WidgetsKey
                                                                    .colorsProductListingFilterListKey),
                                                            hideTitle: true,
                                                            boutiqueSlug: widget
                                                                .boutiqueSlug,
                                                            fromHomeSearch:
                                                                widget
                                                                    .fromSearch,
                                                            searchText: widget
                                                                .searchText,
                                                            category:
                                                                widget.category,
                                                            colors: filters!
                                                                    .colors ??
                                                                [],
                                                          )
                                                        : PriceFiltersRangesList(
                                                            exchangeRate: state
                                                                .getCurrencyForCountryModel!
                                                                .data!
                                                                .currency!
                                                                .exchangeRate!,
                                                            key: TestVariables
                                                                        .kTestMode ==
                                                                    false
                                                                ? null
                                                                : Key(WidgetsKey
                                                                    .pricesProductListingFilterListKey),
                                                            decimalPoint: state
                                                                    .startingSetting
                                                                    ?.decimalPointSetting ??
                                                                2,
                                                            fromHomeSearch:
                                                                widget
                                                                    .fromSearch,
                                                            searchText: widget
                                                                .searchText,
                                                            boutiqueSlug: widget
                                                                .boutiqueSlug,
                                                            currencySymbol:
                                                                currencySymbol,
                                                            category:
                                                                widget.category,
                                                            priceRanges: filters!
                                                                    .prices
                                                                    ?.priceRanges ??
                                                                [],
                                                          ),
                                      ),
                                    );
                                  return Container(
                                    margin: EdgeInsetsDirectional.only(
                                        top: 10,
                                        end: 10,
                                        start: (index - 1) == 0 &&
                                                titleOfFilterSection[0] ==
                                                    'View By Categories'
                                            ? 0
                                            : 10,
                                        bottom: 45),
                                    width: 0.5,
                                    color: Color(0xff707070),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                },
                if (isExpanded) ...{
                  SizedBox(
                    height: 10,
                  ),
                  !filters!.brands.isNullOrEmpty
                      ? FiltersNormalList(
                          filterListTitle: 'Filter By Brand',
                          boutiqueSlug: widget.boutiqueSlug,
                          fromHomeSearch: widget.fromSearch,
                          searchText: widget.searchText,
                          category: widget.category,
                          isBrandFilter: true,
                          filters: filters!.brands ?? [],
                        )
                      : SizedBox.shrink(),
                  !filters!.colors.isNullOrEmpty
                      ? ColorsListFilter(
                          boutiqueSlug: widget.boutiqueSlug,
                          fromHomeSearch: widget.fromSearch,
                          searchText: widget.searchText,
                          category: widget.category,
                          colors: filters!.colors ?? [],
                        )
                      : SizedBox.shrink(),
                  FiltersNormalList(
                    filterListTitle: 'Filter By Offer',
                    boutiqueSlug: widget.boutiqueSlug,
                    fromHomeSearch: widget.fromSearch,
                    searchText: widget.searchText,
                    category: widget.category,
                    isBrandFilter: false,
                    filters: [],
                  ),
                  if (filters!.prices != null)
                    PriceFilter(
                      exchangeRate: state.getCurrencyForCountryModel!.data!
                          .currency!.exchangeRate!,
                      pricrRate: state.getCurrencyForCountryModel!.data!
                          .currency!.exchangeRate!,
                      hideTitle: widget.hideTitle,
                      fromHomeSearch: widget.fromSearch,
                      searchText: widget.searchText,
                      maxPrice: maxPrice!,
                      minPrice: minPrice!,
                      lowerAndUpperBound: lowerAndUpperPrices!,
                      decimalPoint:
                          state.startingSetting?.decimalPointSetting ?? 2,
                      boutiqueSlug: widget.boutiqueSlug,
                      category: widget.category,
                      pricrSymbol: currencySymbol,
                      pricesFiltersRanges: filters!.prices!,
                    ),
                  if (!filters!.attributes.isNullOrEmpty)
                    SizesFiltersList(
                      fromHomeSearch: widget.fromSearch,
                      searchText: widget.searchText,
                      boutiqueSlug: widget.boutiqueSlug,
                      category: widget.category,
                      attribute: filters!.attributes![0],
                    ),
                },
              },
              if (!isExpanded) ...{
                Container(
                  padding: EdgeInsets.only(
                      top: (state.appliedFiltersByUser[key]?.filters?.attributes
                                      ?.isNullOrEmpty ??
                                  true) &&
                              (state.appliedFiltersByUser[key]?.filters?.colors
                                      ?.isNullOrEmpty ??
                                  true) &&
                              (state.appliedFiltersByUser[key]?.filters?.brands
                                      ?.isNullOrEmpty ??
                                  true) &&
                              (state.appliedFiltersByUser[key]?.filters
                                      ?.boutiques?.isNullOrEmpty ??
                                  true) &&
                              (state.appliedFiltersByUser[key]?.filters
                                      ?.categories?.isNullOrEmpty ??
                                  true) &&
                              ((state.appliedFiltersByUser[key]?.filters?.searchText?.isEmpty ??
                                      true) ||
                                  (state.appliedFiltersByUser[key]?.filters?.searchText?.length ?? 0) < 2) &&
                              (state.appliedFiltersByUser[key]?.filters?.prices?.maxPrice == null) &&
                              (state.appliedFiltersByUser[key]?.filters?.prices?.minPrice == null)
                          ? 0
                          : 5),
                  color: Color(0xffF8F8F8),
                  child: Container(
                    width: 1.sw,
                    height: (state.appliedFiltersByUser[key]?.filters
                                    ?.attributes?.isNullOrEmpty ??
                                true) &&
                            (state.appliedFiltersByUser[key]?.filters?.colors
                                    ?.isNullOrEmpty ??
                                true) &&
                            (state.appliedFiltersByUser[key]?.filters?.brands
                                    ?.isNullOrEmpty ??
                                true) &&
                            (state.appliedFiltersByUser[key]?.filters?.boutiques
                                    ?.isNullOrEmpty ??
                                true) &&
                            (state.appliedFiltersByUser[key]?.filters
                                    ?.categories?.isNullOrEmpty ??
                                true) &&
                            ((state.appliedFiltersByUser[key]?.filters
                                        ?.searchText?.isEmpty ??
                                    true) ||
                                (state.appliedFiltersByUser[key]?.filters
                                            ?.searchText?.length ??
                                        0) <
                                    2) &&
                            (state.appliedFiltersByUser[key]?.filters?.prices
                                    ?.maxPrice ==
                                null) &&
                            (state.appliedFiltersByUser[key]?.filters?.prices
                                    ?.minPrice ==
                                null)
                        ? 0
                        : 30,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        color: Color(0xffEFEFEF),
                        borderRadius: BorderRadius.circular(10)),
                    child: choosedOrAppliedFiltersWidget(
                        controller: widget.textController,
                        boutiqueSlug: widget.boutiqueSlug,
                        context: context,
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                        category: widget.category,
                        choosedFilter: isExpanded,
                        fromSearch: widget.fromSearch,
                        lowerAndUpperPrices: lowerAndUpperPrices),
                  ),
                ),
              },
              if (countOfFilters != 0 ||
                  state.choosedFiltersByUser[key] != null) ...{
                if (isExpanded) ...{
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      ValueListenableBuilder<Tuple2<double, double>>(
                          valueListenable: lowerAndUpperPrices ??
                              ValueNotifier(Tuple2(-1, -1)),
                          builder: (context, _, __) {
                            return Container(
                              width: 1.sw,
                              height: (!((state.choosedFiltersByUser[key]?.filters?.attributes?.isNullOrEmpty ?? true) &&
                                          (state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.colors
                                                  ?.isNullOrEmpty ??
                                              true) &&
                                          (state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.brands
                                                  ?.isNullOrEmpty ??
                                              true) &&
                                          (state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.boutiques
                                                  ?.isNullOrEmpty ??
                                              true) &&
                                          (state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.categories
                                                  ?.isNullOrEmpty ??
                                              true) &&
                                          (state.choosedFiltersByUser[key]?.filters?.searchText?.isEmpty ??
                                              true) &&
                                          (state.choosedFiltersByUser[key]?.filters?.prices?.maxPrice ==
                                              null) &&
                                          (state.choosedFiltersByUser[key]?.filters?.prices?.minPrice ==
                                              null)) ||
                                      (lowerAndUpperPrices != null &&
                                          (lowerAndUpperPrices!.value.item1 > minPrice! ||
                                              lowerAndUpperPrices!.value.item2 < maxPrice!)))
                                  ? 55
                                  : 0,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: colorScheme.white,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 6,
                                        offset: Offset(0, 0),
                                        color: Colors.black.withOpacity(0.1))
                                  ],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)
                                        .copyWith(left: 10),
                                    child: MyTextWidget(
                                      'The Products Will Be Shown As Below',
                                      style: context.textTheme.titleMedium?.rq
                                          .copyWith(
                                              color: Color(0xff505050),
                                              height: 15 / 12),
                                    ),
                                  ),
                                  Container(
                                    width: 1.sw,
                                    height: (!((state.choosedFiltersByUser[key]?.filters?.attributes?.isNullOrEmpty ?? true) &&
                                                (state.choosedFiltersByUser[key]
                                                        ?.filters?.colors?.isNullOrEmpty ??
                                                    true) &&
                                                (state.choosedFiltersByUser[key]
                                                        ?.filters?.brands?.isNullOrEmpty ??
                                                    true) &&
                                                (state.choosedFiltersByUser[key]
                                                        ?.filters?.boutiques?.isNullOrEmpty ??
                                                    true) &&
                                                (state.choosedFiltersByUser[key]
                                                        ?.filters?.categories?.isNullOrEmpty ??
                                                    true) &&
                                                ((state.choosedFiltersByUser[key]?.filters?.searchText?.isEmpty ?? true) ||
                                                    (state.choosedFiltersByUser[key]?.filters?.searchText?.length ?? 0) <
                                                        2) &&
                                                (state.choosedFiltersByUser[key]
                                                        ?.filters?.prices?.maxPrice ==
                                                    null) &&
                                                (state.choosedFiltersByUser[key]
                                                        ?.filters?.prices?.minPrice ==
                                                    null)) ||
                                            (lowerAndUpperPrices != null &&
                                                (lowerAndUpperPrices!.value.item1 > minPrice! ||
                                                    lowerAndUpperPrices!.value.item2 <
                                                        maxPrice!)))
                                        ? 30
                                        : 0,
                                    padding: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0xffEFEFEF),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: SizedBox(
                                        height: 15,
                                        child: choosedOrAppliedFiltersWidget(
                                            controller: widget.textController,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            context: context,
                                            minPrice: minPrice,
                                            maxPrice: maxPrice,
                                            category: widget.category,
                                            choosedFilter: isExpanded,
                                            fromSearch: widget.fromSearch,
                                            lowerAndUpperPrices:
                                                lowerAndUpperPrices)),
                                  ),
                                ],
                              ),
                            );
                          }),
                      SizedBox(
                        height: 10,
                      ),
                      ValueListenableBuilder<Tuple2<double, double>>(
                          valueListenable: lowerAndUpperPrices ??
                              ValueNotifier(Tuple2(-1, -1)),
                          builder: (context, _, __) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  if (state.choosedFiltersByUser[key] != null ||
                                      (lowerAndUpperPrices != null &&
                                          (lowerAndUpperPrices!.value.item1 >
                                                  minPrice! ||
                                              lowerAndUpperPrices!.value.item2 <
                                                  maxPrice!))) ...{
                                    Expanded(
                                      flex: 5,
                                      child: InkWell(
                                        key: TestVariables.kTestMode
                                            ? Key(WidgetsKey
                                                .applayFilterButtonKey)
                                            : null,
                                        onTap: () {
                                          List<filter_model.Brand>? brands = [
                                            ...state.appliedFiltersByUser[key]
                                                    ?.filters?.brands ??
                                                [],
                                            ...state.choosedFiltersByUser[key]
                                                    ?.filters?.brands ??
                                                []
                                          ];
                                          List<product_listing.Category>?
                                              categories = [
                                            ...state.appliedFiltersByUser[key]
                                                    ?.filters?.categories ??
                                                [],
                                            ...state.choosedFiltersByUser[key]
                                                    ?.filters?.categories ??
                                                []
                                          ];
                                          List<filter_model.Boutique>?
                                              boutiques = [
                                            ...state.appliedFiltersByUser[key]
                                                    ?.filters?.boutiques ??
                                                [],
                                            ...state.choosedFiltersByUser[key]
                                                    ?.filters?.boutiques ??
                                                []
                                          ];
                                          List<String>? colors = [
                                            ...state.appliedFiltersByUser[key]
                                                    ?.filters?.colors ??
                                                [],
                                            ...state.choosedFiltersByUser[key]
                                                    ?.filters?.colors ??
                                                []
                                          ];
                                          Prices prices = state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.prices ??
                                              Prices();
                                          List<String> options = [];
                                          int? id;
                                          String? name;
                                          if (!(state
                                                  .appliedFiltersByUser[key]
                                                  ?.filters
                                                  ?.attributes
                                                  ?.isNullOrEmpty ??
                                              true)) {
                                            id = state
                                                .appliedFiltersByUser[key]!
                                                .filters!
                                                .attributes![0]
                                                .id;
                                            name = state
                                                .appliedFiltersByUser[key]!
                                                .filters!
                                                .attributes![0]
                                                .name;
                                            options.addAll(state
                                                    .appliedFiltersByUser[key]!
                                                    .filters!
                                                    .attributes![0]
                                                    .options ??
                                                []);
                                          }
                                          if (!(state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.attributes
                                                  ?.isNullOrEmpty ??
                                              true)) {
                                            id = state
                                                .choosedFiltersByUser[key]!
                                                .filters!
                                                .attributes![0]
                                                .id;
                                            name = state
                                                .choosedFiltersByUser[key]!
                                                .filters!
                                                .attributes![0]
                                                .name;
                                            options.addAll(state
                                                    .choosedFiltersByUser[key]!
                                                    .filters!
                                                    .attributes![0]
                                                    .options ??
                                                []);
                                          }
                                          /* filter_model.Prices? prices;
                                      if ((lowerAndUpperPrices != null &&
                                          (lowerAndUpperPrices!.value.item1 /
                                                      exchangeRate >
                                                  minPrice! ||
                                              lowerAndUpperPrices!.value.item2 /
                                                      exchangeRate <
                                                  maxPrice!))) {
                                        prices = filter_model.Prices(
                                          minPrice:
                                              lowerAndUpperPrices!.value.item1 /
                                                  exchangeRate,
                                          maxPrice:
                                              lowerAndUpperPrices!.value.item2 /
                                                  exchangeRate,
                                        );
                                      }-*/
                                          print(
                                              "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

                                          homeBloc.add(
                                              ChangeAppliedFiltersEvent(
                                                  category: widget.category,
                                                  boutiqueSlug: widget
                                                      .boutiqueSlug,
                                                  filtersAppliedByUser: filter_model
                                                      .GetProductFiltersModel(
                                                          filters: filter_model
                                                              .Filter(
                                                                  brands:
                                                                      brands,
                                                                  categories:
                                                                      categories,
                                                                  boutiques:
                                                                      boutiques,
                                                                  searchText: widget
                                                                      .textController
                                                                      .text,
                                                                  attributes:
                                                                      options
                                                                              .isEmpty
                                                                          ? null
                                                                          : [
                                                                              filter_model.Attribute(
                                                                                id: id,
                                                                                name: name,
                                                                                options: options,
                                                                              ),
                                                                            ],
                                                                  colors:
                                                                      colors,
                                                                  prices:
                                                                      prices))));
                                          //////////////////////////////////////////
                                          FirebaseAnalyticsService
                                              .logEventForSession(
                                            eventName: AnalyticsEventsConst
                                                .buttonClicked,
                                            executedEventName:
                                                AnalyticsExecutedEventNameConst
                                                    .applyFilterButton,
                                          );

                                          //////////////////////////
                                          homeBloc.add(
                                            GetProductsWithFiltersEvent(
                                              fromChoosed: true,
                                              fromSearch: widget.fromSearch,
                                              searchText:
                                                  widget.textController.text,
                                              boutiqueSlug: widget.boutiqueSlug,
                                              category: widget.category,
                                              offset: 1,
                                            ),
                                          );
                                          print(
                                              "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
                                          widget.closeFilterPage.call();
                                          print(
                                              "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
                                        },
                                        child: Container(
                                          height: 65,
                                          decoration: BoxDecoration(
                                              color: Color(0xffFF5F61),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3)),
                                                BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.4),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                    inset: true)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (state.countOfProductExpectedByFiltering?[
                                                        widget.boutiqueSlug] !=
                                                    null) ...{
                                                  MyTextWidget(
                                                    '(${state.countOfProductExpectedByFiltering?[widget.boutiqueSlug]}  products)',
                                                    style: textTheme
                                                        .bodyMedium?.mq
                                                        .copyWith(
                                                            color: Color(
                                                                0xffFEFEFE),
                                                            height: 23 / 18),
                                                  ),
                                                },
                                                MyTextWidget(
                                                  ' Apply   ',
                                                  style: textTheme.bodyLarge?.rq
                                                      .copyWith(
                                                          color:
                                                              Color(0xffFEFEFE),
                                                          height: 23 / 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  },
                                  ValueListenableBuilder<
                                          Tuple2<double, double>>(
                                      valueListenable: lowerAndUpperPrices ??
                                          ValueNotifier(Tuple2(-1, -1)),
                                      builder: (context, _, __) {
                                        return BlocBuilder<HomeBloc, HomeState>(
                                          builder: (context, state) {
                                            if (state.choosedFiltersByUser[
                                                        key] ==
                                                    null &&
                                                (lowerAndUpperPrices == null ||
                                                    (lowerAndUpperPrices !=
                                                            null &&
                                                        (lowerAndUpperPrices!
                                                                    .value
                                                                    .item1 ==
                                                                minPrice! &&
                                                            lowerAndUpperPrices!
                                                                    .value
                                                                    .item2 ==
                                                                maxPrice!)))) {
                                              return SizedBox.shrink();
                                            }
                                            return Expanded(
                                              flex: 2,
                                              child: InkWell(
                                                onTap: () {
                                                  widget.textController.text =
                                                      "";
                                                  if (lowerAndUpperPrices !=
                                                      null) {
                                                    lowerAndUpperPrices!.value =
                                                        Tuple2(minPrice!,
                                                            maxPrice!);
                                                  }
                                                  print(
                                                      "ddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
                                                  homeBloc.add(
                                                      AddPrefAppliedFilterForExtendFilterEvent(
                                                          prefAppliedFilter:
                                                              Filter()));
                                                  homeBloc.add(
                                                      ChangeAppliedFiltersEvent(
                                                    resetAppliedFilters: true,
                                                    boutiqueSlug:
                                                        widget.boutiqueSlug,
                                                    category: widget.category,
                                                  ));

                                                  homeBloc.add(
                                                      ChangeSelectedFiltersEvent(
                                                          fromHomePageSearch:
                                                              widget.fromSearch,
                                                          boutiqueSlug: widget
                                                              .boutiqueSlug,
                                                          category:
                                                              widget.category,
                                                          resetChoosedFilters:
                                                              true,
                                                          filtersChoosedByUser:
                                                              null));
                                                  homeBloc.add(
                                                      GetProductsWithFiltersEvent(
                                                    fromSearch:
                                                        widget.fromSearch,
                                                    boutiqueSlug:
                                                        widget.boutiqueSlug,
                                                    cashedOrginalBoutique: true,
                                                    searchText: null,
                                                    category: widget.category,
                                                    offset: 1,
                                                  ));
                                                  //////////////////////////////////////////
                                                  FirebaseAnalyticsService
                                                      .logEventForSession(
                                                    eventName:
                                                        AnalyticsEventsConst
                                                            .buttonClicked,
                                                    executedEventName:
                                                        AnalyticsExecutedEventNameConst
                                                            .resetButton,
                                                  );
                                                },
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 65,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              colorScheme.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 6,
                                                                offset: Offset(
                                                                    0, 3)),
                                                            BoxShadow(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.4),
                                                                blurRadius: 6,
                                                                offset: Offset(
                                                                    0, 3),
                                                                inset: true)
                                                          ],
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xff388CFF))),
                                                      child: Center(
                                                        child: MyTextWidget(
                                                          key: TestVariables
                                                                  .kTestMode
                                                              ? Key(WidgetsKey
                                                                  .resetFiltersKey)
                                                              : null,
                                                          'Reset',
                                                          style: textTheme
                                                              .bodyLarge?.rq
                                                              .copyWith(
                                                                  color: Color(
                                                                      0xff388CFF),
                                                                  height:
                                                                      23 / 18),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                ],
                              ),
                            );
                          }),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  )
                }
              }
            ],
          );
        });
  }
}

Widget choosedOrAppliedFiltersWidget({
  required BuildContext context,
  final TextEditingController? controller,
  required String boutiqueSlug,
  String? category,
  bool choosedFilter = true,
  ValueNotifier<Tuple2<double, double>>? lowerAndUpperPrices,
  bool fromSearch = false,
  double? minPrice,
  double? maxPrice,
}) {
  String key = boutiqueSlug + (category ?? '');
  HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
  return BlocBuilder<HomeBloc, HomeState>(
    buildWhen: (p, c) =>
        p.choosedFiltersByUser[key]?.filters !=
            c.choosedFiltersByUser[key]?.filters ||
        p.appliedFiltersByUser[key]?.filters !=
            c.appliedFiltersByUser[key]?.filters,
    builder: (context, state) {
      filter_model.Filter? filters;
      filter_model.Filter? filtersForSearchText;
      if ((state.choosedFiltersByUser[key]?.filters?.searchText?.length ?? 0) >
          0) {
        filtersForSearchText = state.choosedFiltersByUser[key]?.filters;
      } else {
        filtersForSearchText = state.appliedFiltersByUser[key]?.filters;
      }

      if (choosedFilter) {
        filters = state.choosedFiltersByUser[key]?.filters;
      } else {
        filters = state.appliedFiltersByUser[key]?.filters;
      }
      String currencySymbol =
          state.getCurrencyForCountryModel?.data?.currency?.symbol ?? '\$';
      if (filters == null && (!fromSearch && lowerAndUpperPrices == null)) {
        return SizedBox.shrink();
      }
      if ((filters?.brands.isNullOrEmpty ?? true) &&
          (filters?.categories.isNullOrEmpty ?? true) &&
          filters?.prices == null &&
          (controller?.value == null && choosedFilter && fromSearch) &&
          (filters?.colors.isNullOrEmpty ?? true) &&
          (filters?.boutiques.isNullOrEmpty ?? true) &&
          (filters?.attributes.isNullOrEmpty ?? true)) {
        if ((!fromSearch && lowerAndUpperPrices == null && choosedFilter))
          return SizedBox.shrink();
      }
      if ((filters?.brands.isNullOrEmpty ?? true) &&
          (filters?.categories.isNullOrEmpty ?? true) &&
          (filters?.prices?.minPrice == null ||
              filters?.prices?.minPrice == null) &&
          (controller!.text.length < 3) &&
          (filters?.colors.isNullOrEmpty ?? true) &&
          (filters?.boutiques.isNullOrEmpty ?? true) &&
          (filters?.attributes.isNullOrEmpty ?? true)) {
        return SizedBox.shrink();
      }
      double exchangeRate =
          state.getCurrencyForCountryModel?.data?.currency?.exchangeRate ?? 1;
      Widget widget = SizedBox(
        height: 23,
        width: 30,
        child: ListView(
            key: TestVariables.kTestMode == false
                ? null
                : Key(WidgetsKey.appliedFiltersProductListingKey),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              if (!choosedFilter)
                InkWell(
                  key: TestVariables.kTestMode == false
                      ? null
                      : Key(WidgetsKey.appliedFiltersProductListingCloseKey),
                  onTap: () {
                    controller?.clear();
                    homeBloc.add(AddPrefAppliedFilterForExtendFilterEvent(
                        prefAppliedFilter: Filter()));
                    homeBloc.add(ChangeAppliedFiltersEvent(
                      category: category,
                      resetAppliedFilters: true,
                      boutiqueSlug: boutiqueSlug,
                    ));
                    homeBloc.add(GetProductsWithFiltersEvent(
                      resetChoosedFilters: true,
                      fromSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      cashedOrginalBoutique: true,
                      searchText: null,
                      category: category,
                      offset: 1,
                    ));

                    homeBloc.add(ChangeSelectedFiltersEvent(
                      requestToUpdateFilters: false,
                      boutiqueSlug: boutiqueSlug,
                      resetChoosedFilters: true,
                      fromHomePageSearch: fromSearch,
                    ));
                    homeBloc.add(GetProductFiltersEvent(
                      fromHomePageSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      cashedOrginalBoutique: true,
                      searchText: null,
                      category: category,
                    ));
                    ///////////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.resetCloseIconButton,
                    );
                  },
                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset(
                          AppAssets.closeSvg,
                          width: 15,
                          height: 15,
                          color: Color(0xffFF5F61),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              if (choosedFilter)
                InkWell(
                  key: TestVariables.kTestMode == false
                      ? null
                      : Key(WidgetsKey.appliedFiltersProductListingCloseKey),
                  onTap: () {
                    controller?.clear();
                    homeBloc.add(ChangeAppliedFiltersEvent(
                      category: category,
                      resetAppliedFilters: true,
                      boutiqueSlug: boutiqueSlug,
                    ));
                    homeBloc.add(ChangeSelectedFiltersEvent(
                      category: category,
                      requestToUpdateFilters: true,
                      resetChoosedFilters: true,
                      boutiqueSlug: boutiqueSlug,
                      fromHomePageSearch: fromSearch,
                    ));

                    homeBloc.add(
                      GetProductsWithFiltersEvent(
                        fromSearch: fromSearch,
                        boutiqueSlug: boutiqueSlug,
                        cashedOrginalBoutique: true,
                        searchText: null,
                        category: category,
                        offset: 1,
                      ),
                    );
                    ///////////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName:
                          AnalyticsExecutedEventNameConst.resetCloseIconButton,
                    );
                  },
                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset(
                          AppAssets.closeSvg,
                          width: 15,
                          height: 15,
                          color: Color(0xffFF5F61),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              if (choosedFilter)
                Center(
                  child: MyTextWidget(
                    'Choosed: ',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.bq.copyWith(
                        color: Color(0xffFF5F61),
                        letterSpacing: 0,
                        height: 1.25),
                  ),
                )
              else
                Center(
                  child: MyTextWidget(
                    'Applied: ',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.bq.copyWith(
                        color: Color(0xffFF5F61),
                        letterSpacing: 0,
                        height: 1.25),
                  ),
                ),
              if ((filtersForSearchText?.searchText?.length ?? 0) > 0) ...{
                (filtersForSearchText?.searchText?.replaceAll(" ", "").length ??
                            0) >
                        1
                    ? Center(child: FilterSelectedMark(width: 15, height: 15))
                    : SizedBox.shrink(),
                SizedBox(
                  width: (filtersForSearchText?.searchText
                                  ?.replaceAll(" ", "")
                                  .length ??
                              0) >
                          1
                      ? 10
                      : 0,
                ),
                SizedBox(
                    height: 28,
                    child: InkWell(
                      onTap: () {
                        Filter? filter =
                            state.appliedFiltersByUser[key]?.filters;

                        controller?.clear();

                        if (choosedFilter) {
                          filter = state.choosedFiltersByUser[key]?.filters;
                          homeBloc.add(ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser:
                                  filter_model.GetProductFiltersModel(
                                      filters: filter!.copyWithSaveOtherField(
                                searchText: null,
                                prices: filter.prices,
                              ))));
                          homeBloc.add(GetProductsWithFiltersEvent(
                            resetChoosedFilters: false,
                            fromChoosed: true,
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            searchText: null,
                            category: category,
                            offset: 1,
                          ));
                        } else {
                          homeBloc.add(ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser:
                                  filter_model.GetProductFiltersModel(
                                      filters: filter!.copyWithSaveOtherField(
                                searchText: null,
                                prices: filter.prices,
                              ))));
                          homeBloc.add(GetProductsWithFiltersEvent(
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            searchText: null,
                            category: category,
                            offset: 1,
                          ));
                        }
                      },
                      child: Center(
                        child: (filtersForSearchText?.searchText
                                        ?.replaceAll(" ", "")
                                        .length ??
                                    0) >
                                0
                            ? MyTextWidget(
                                filtersForSearchText!.searchText!,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium?.rq
                                    .copyWith(
                                        color: Color(0xff8E8E8E),
                                        letterSpacing: 0,
                                        height: 1.25),
                              )
                            : SizedBox.shrink(),
                      ),
                    )),
                SizedBox(
                  width: 15,
                ),
              },
              if (!(filters?.boutiques.isNullOrEmpty ?? true)) ...{
                Center(child: FilterSelectedMark(width: 15, height: 15)),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                    height: 28,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: filters?.boutiques?.length,
                      itemBuilder: (ctx, index) {
                        return InkWell(
                          onTap: () {
                            print(
                                "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");

                            List<filter_model.Boutique> newBoutiques =
                                List.of(filters?.boutiques ?? []);
                            newBoutiques.removeAt(index);
                            filter_model.GetProductFiltersModel
                                newGetProductFiltersModel =
                                filter_model.GetProductFiltersModel(
                                    filters: filters?.copyWithSaveOtherField(
                                        prices: filters.prices,
                                        searchText: filters.searchText,
                                        boutiques: newBoutiques));
                            if (choosedFilter) {
                              BlocProvider.of<HomeBloc>(context)
                                  .add(ChangeSelectedFiltersEvent(
                                fromHomePageSearch: fromSearch,
                                category: category,
                                requestToUpdateFilters: true,
                                boutiqueSlug: boutiqueSlug,
                                filtersChoosedByUser: newGetProductFiltersModel,
                              ));

                              return;
                            }

                            homeBloc.add(ChangeAppliedFiltersEvent(
                                category: category,
                                boutiqueSlug: boutiqueSlug,
                                filtersAppliedByUser:
                                    newGetProductFiltersModel));
                            BlocProvider.of<HomeBloc>(context)
                                .add(GetProductsWithFiltersEvent(
                              searchText: controller?.text,
                              fromSearch: fromSearch,
                              boutiqueSlug: boutiqueSlug,
                              category: category,
                              offset: 1,
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyCachedNetworkImage(
                                imageUrl: filters!
                                    .boutiques![index].banner!.filePath!,
                                imageFit: BoxFit.cover,
                                height: choosedFilter ? 40 : 30,
                                width: 60,
                                circleDimensions: 8,
                                logoTextHeight: 5,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              MyTextWidget(
                                key: TestVariables.kTestMode
                                    ? Key(WidgetsKey
                                        .appliedFiltersBoutiqueNameKey)
                                    : null,
                                filters.boutiques![index].name.toString(),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium?.rq
                                    .copyWith(
                                        color: Color(0xff8E8E8E),
                                        letterSpacing: 0,
                                        height: 1.25),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        );
                      },
                    )),
              },
              if (!(filters?.categories.isNullOrEmpty ?? true)) ...{
                Center(child: FilterSelectedMark(width: 15, height: 15)),
                SizedBox(
                  width: 5,
                ),
              },
              SizedBox(
                  height: 28,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters?.categories?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          List<String> categories = filters!.categories!
                              .map((e) => e.id.toString())
                              .toList();
                          List<product_listing.Category> newCategories =
                              List.of(filters.categories ?? []);
                          newCategories.removeAt(index);
                          categories.removeAt(index);
                          filter_model.GetProductFiltersModel
                              newGetProductFiltersModel =
                              filter_model.GetProductFiltersModel(
                                  filters: filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText: filters.searchText,
                                      categories: newCategories));
                          if (choosedFilter) {
                            BlocProvider.of<HomeBloc>(context)
                                .add(ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser: newGetProductFiltersModel,
                            ));
                            return;
                          }
                          homeBloc.add(ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser: newGetProductFiltersModel));
                          BlocProvider.of<HomeBloc>(context)
                              .add(GetProductsWithFiltersEvent(
                            searchText: controller?.text,
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            category: category,
                            offset: 1,
                          ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilterImage(
                              isSvg: true,
                              width: filters!.categories![index].isSubCategory
                                  ? 15
                                  : 20,
                              height: filters.categories![index].isSubCategory
                                  ? 15
                                  : 20,
                              imageUrl: filters
                                  .categories![index].flatPhotoPath!.filePath
                                  .toString(),
                              withInnerShadow: true,
                              withBackGroundShadow: false,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            MyTextWidget(
                              filters.categories![index].name.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                  color: Color(0xff8E8E8E),
                                  letterSpacing: 0,
                                  height: 1.25),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  )),
              if (!(filters?.brands.isNullOrEmpty ?? true)) ...{
                Center(child: FilterSelectedMark(width: 15, height: 15)),
                SizedBox(
                  width: 10,
                ),
              },
              SizedBox(
                  height: 28,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters?.brands?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          List<filter_model.Brand> newBrands =
                              List.of(filters!.brands ?? []);
                          newBrands.removeAt(index);
                          filter_model.GetProductFiltersModel
                              newGetProductFiltersModel =
                              filter_model.GetProductFiltersModel(
                                  filters: filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText: filters.searchText,
                                      brands: newBrands));
                          if (choosedFilter) {
                            BlocProvider.of<HomeBloc>(context)
                                .add(ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser: newGetProductFiltersModel,
                            ));
                            return;
                          }
                          homeBloc.add(ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser: newGetProductFiltersModel));
                          BlocProvider.of<HomeBloc>(context)
                              .add(GetProductsWithFiltersEvent(
                            searchText: controller?.text,
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            category: category,
                            offset: 1,
                          ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilterImage(
                              width: 20,
                              height: 20,
                              imageUrl: filters!.brands![index].icon!.filePath
                                  .toString(),
                              isSvg: true,
                              withInnerShadow: true,
                              withBackGroundShadow: false,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            MyTextWidget(
                              filters.brands![index].name.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                  color: Color(0xff8E8E8E),
                                  letterSpacing: 0,
                                  height: 1.25),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  )),
              if (!(filters?.attributes.isNullOrEmpty ?? true)) ...{
                Center(child: FilterSelectedMark(width: 15, height: 15)),
                SizedBox(
                  width: 10,
                ),
              },
              SizedBox(
                  height: 28,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters?.attributes.isNullOrEmpty ?? true
                        ? 0
                        : filters?.attributes![0].options?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          List<String>? options =
                              List.of(filters!.attributes![0].options ?? []);
                          options.removeAt(index);
                          filter_model.GetProductFiltersModel
                              newGetProductFiltersModel =
                              filter_model.GetProductFiltersModel(
                                  filters: filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText: filters.searchText,
                                      attributes: options.isNullOrEmpty
                                          ? []
                                          : [
                                              filters.attributes![0]
                                                  .copyWith(options: options)
                                            ]));
                          if (choosedFilter) {
                            BlocProvider.of<HomeBloc>(context)
                                .add(ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser: newGetProductFiltersModel,
                            ));
                            return;
                          }
                          homeBloc.add(ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser: newGetProductFiltersModel));
                          BlocProvider.of<HomeBloc>(context)
                              .add(GetProductsWithFiltersEvent(
                            searchText: controller?.text,
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            category: category,
                            offset: 1,
                          ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            MyTextWidget(
                              filters!.attributes![0].options![index]
                                  .toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                  color: Color(0xff8E8E8E),
                                  letterSpacing: 0,
                                  height: 1.25),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  )),
              if (!(filters?.colors.isNullOrEmpty ?? true)) ...{
                Center(child: FilterSelectedMark(width: 15, height: 15)),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                    height: 28,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: filters?.colors?.length ?? 0,
                      itemBuilder: (ctx, index) {
                        return InkWell(
                          onTap: () {
                            List<String>? colors =
                                List.of(filters!.colors ?? []);
                            colors.removeAt(index);
                            filter_model.GetProductFiltersModel
                                newGetProductFiltersModel =
                                filter_model.GetProductFiltersModel(
                                    filters: filters.copyWithSaveOtherField(
                                        prices: filters.prices,
                                        searchText: filters.searchText,
                                        colors: colors));
                            if (choosedFilter) {
                              BlocProvider.of<HomeBloc>(context)
                                  .add(ChangeSelectedFiltersEvent(
                                fromHomePageSearch: fromSearch,
                                category: category,
                                boutiqueSlug: boutiqueSlug,
                                filtersChoosedByUser: newGetProductFiltersModel,
                              ));
                              return;
                            }
                            homeBloc.add(ChangeAppliedFiltersEvent(
                                category: category,
                                boutiqueSlug: boutiqueSlug,
                                filtersAppliedByUser:
                                    newGetProductFiltersModel));
                            BlocProvider.of<HomeBloc>(context)
                                .add(GetProductsWithFiltersEvent(
                              searchText: controller?.text,
                              fromSearch: fromSearch,
                              boutiqueSlug: boutiqueSlug,
                              category: category,
                              offset: 1,
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(int.parse(
                                      '0xff${filters!.colors![index].substring(1)}')),
                                  border: Border.all(color: Color(0xffC4C2C2)),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        );
                      },
                    )),
              },
              if (filters?.prices?.minPrice != null ||
                  filters?.prices?.maxPrice != null ||
                  (choosedFilter &&
                      lowerAndUpperPrices != null &&
                      (lowerAndUpperPrices.value.item1 > minPrice! ||
                          lowerAndUpperPrices.value.item2 < maxPrice!))) ...{
                Center(child: FilterSelectedMark(width: 15, height: 15)),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    filter_model.GetProductFiltersModel
                        newGetProductFiltersModel =
                        filter_model.GetProductFiltersModel(
                            filters: filters!.copyWithSaveOtherField(
                                prices: null, searchText: filters.searchText));
                    if (choosedFilter) {
                      BlocProvider.of<HomeBloc>(context)
                          .add(ChangeSelectedFiltersEvent(
                        fromHomePageSearch: fromSearch,
                        category: category,
                        boutiqueSlug: boutiqueSlug,
                        filtersChoosedByUser: newGetProductFiltersModel,
                      ));
                      return;
                    }
                    homeBloc.add(ChangeAppliedFiltersEvent(
                        category: category,
                        boutiqueSlug: boutiqueSlug,
                        filtersAppliedByUser: newGetProductFiltersModel));
                    BlocProvider.of<HomeBloc>(context)
                        .add(GetProductsWithFiltersEvent(
                      searchText: controller?.text,
                      fromSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      category: category,
                      offset: 1,
                    ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        filters?.prices?.minPrice != null ||
                                filters?.prices?.maxPrice != null
                            ? '${currencySymbol} '
                            : "",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.rq.copyWith(
                            color: Color(0xff8E8E8E),
                            letterSpacing: 0,
                            height: 1.25),
                      ),
                      MyTextWidget(
                        filters?.prices?.minPrice != null
                            ? '${(filters!.prices!.minPrice! * exchangeRate).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2).toString()} / '
                            : '${lowerAndUpperPrices!.value.item1.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} / ',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.rq.copyWith(
                            color: Color(0xff8E8E8E),
                            letterSpacing: 0,
                            height: 1.25),
                      ),
                      MyTextWidget(
                        filters?.prices?.maxPrice != null
                            ? '${(filters!.prices!.maxPrice! * exchangeRate).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2).toString()} '
                            : '${lowerAndUpperPrices!.value.item2.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.rq.copyWith(
                            color: Color(0xff8E8E8E),
                            letterSpacing: 0,
                            height: 1.25),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                )
              },
              /*    state
                          .getProductListingWithFiltersPaginationModels[
                              '${boutiqueSlug}' +
                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ''}' +
                                  '${(category ?? '')}']
                          ?.paginationStatus ==
                      PaginationStatus.loading
                  ? TrydosLoader(
                      size: 20,
                    )
                  : SizedBox.shrink()*/
            ]),
      );
      if (fromSearch || !fromSearch) {
        return widget;
      }
      return Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade300),
          height: 30,
          width: 1.sw,
          child: widget);
    },
  );
}

class FilterCircleWidget extends StatefulWidget {
  const FilterCircleWidget(
      {super.key,
      this.isExpanded = true,
      this.isSvg = false,
      required this.imageUrl,
      required this.width,
      required this.height,
      required this.categoryName,
      required this.addOrRemoveSpecificFilter,
      this.withBackGroundShadow = true,
      this.paddingValue = 10,
      this.isSubSubCategory = false,
      this.scale = false,
      this.isTopItem = false,
      this.markWidth = 20,
      this.markHeight = 20,
      this.borderColor,
      this.originalHeight,
      this.originalWidth,
      this.expandStackedItemsFunction,
      required this.displayFilterMark});

  final bool isTopItem;
  final Color? borderColor;
  final bool isExpanded;
  final bool isSvg;
  final double width;
  final double markWidth;
  final double paddingValue;
  final double? originalHeight;
  final double? originalWidth;
  final double height;
  final double markHeight;
  final bool? isSubSubCategory;
  final bool withBackGroundShadow;
  final bool scale;
  final bool displayFilterMark;
  final void Function(bool add) addOrRemoveSpecificFilter;
  final void Function()? expandStackedItemsFunction;
  final String imageUrl;
  final String categoryName;

  @override
  State<FilterCircleWidget> createState() => _FilterCircleWidgetState();
}

class _FilterCircleWidgetState extends State<FilterCircleWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: widget.paddingValue),
      child: Container(
        width: widget.isSubSubCategory! ? widget.width + 22 : null,
        height: widget.isSubSubCategory! ? widget.height + 22 : null,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => widget.addOrRemoveSpecificFilter
                      .call(!widget.displayFilterMark),
                  child: Stack(
                    children: [
                      AnimatedScale(
                        curve: Curves.fastEaseInToSlowEaseOut,
                        scale: widget.scale ? 0.92 : 1,
                        duration: Duration(milliseconds: 100),
                        child: FilterImage(
                          isSvg: widget.isSvg,
                          imageUrl: widget.imageUrl,
                          width: widget.width,
                          height: widget.height,
                          originalWidth: widget.originalWidth,
                          originalHeight: widget.originalHeight,
                          borderColor: widget.displayFilterMark
                              ? Color(0xffFF5F61)
                              : widget.borderColor,
                          withBackGroundShadow: !widget.displayFilterMark &&
                              widget.withBackGroundShadow,
                          withInnerShadow: !widget.scale,
                        ),
                      ),
                      Visibility(
                          visible: widget.displayFilterMark,
                          child: FilterSelectedMark(
                              width: widget.markWidth,
                              height: widget.markHeight))
                    ],
                  ),
                ),
                if (widget.isExpanded || widget.isTopItem) ...{
                  SizedBox(height: 5),
                  SizedBox(
                    width: widget.width,
                    child: MyTextWidget(
                      widget.categoryName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                          color: Color(0xff8E8E8E),
                          letterSpacing: 0,
                          height: 1.25),
                    ),
                  ),
                }
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterImage extends StatelessWidget {
  const FilterImage(
      {super.key,
      required this.width,
      required this.height,
      required this.withInnerShadow,
      required this.withBackGroundShadow,
      this.borderColor,
      this.originalWidth,
      this.originalHeight,
      this.isSvg = false,
      required this.imageUrl});

  final double? originalWidth;
  final double? originalHeight;
  final double width;
  final double height;
  final bool isSvg;
  final bool withInnerShadow;
  final bool withBackGroundShadow;
  final Color? borderColor;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(180.0)),
          border: borderColor != null
              ? Border.all(width: 0.5, color: borderColor!)
              : null,
          boxShadow: withBackGroundShadow
              ? [
                  BoxShadow(
                    color: Color(0x19000000),
                    offset: Offset(0, 3),
                    blurRadius: 3,
                  ),
                ]
              : null),
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(180.0)),
          child: Stack(
            children: [
              isSvg
                  ? SvgNetworkWidget(svgUrl: imageUrl)
                  : imageUrl.contains('assets')
                      ? Image.asset(imageUrl,
                          width: width, fit: BoxFit.cover, height: height)
                      : MyCachedNetworkImage(
                          imageUrl: imageUrl,
                          width: width,
                          ordinalwidth: originalWidth,
                          ordinalHeight: originalHeight,
                          imageFit: BoxFit.cover,
                          height: height),
              //Image.asset(imageUrl , fit: BoxFit.cover, width: width, height: height,),
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  boxShadow: withInnerShadow
                      ? [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            color: Colors.white.withOpacity(0.5),
                            inset: true,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          )),
    );
  }
}

class FilterSelectedMark extends StatelessWidget {
  const FilterSelectedMark(
      {super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x19000000),
                  offset: Offset(0, 3),
                  blurRadius: 3,
                ),
              ],
              borderRadius: BorderRadius.circular(180),
              color: Color(0xffFF5F61)),
          child: Center(
              child: SvgPicture.asset(
            AppAssets.filtersSvg,
            color: Colors.white,
            height: height / 2,
          )),
        ),
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(180),
            border: Border.all(width: 1, color: Color(0xffFF5F61)),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 6,
                color: Colors.white.withOpacity(0.7),
                inset: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
