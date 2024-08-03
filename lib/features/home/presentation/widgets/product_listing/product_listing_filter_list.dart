import 'dart:math';

import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/rendering.dart' as rendring;
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
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as categoriess;
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter_ranges.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter_slider.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/sizes_filters_list.dart';
import 'package:tuple/tuple.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/get_product_filters_model.dart' as filter_model;
import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';
import '../../manager/home_state.dart';
import 'color_list_filter.dart';
import 'filters_loding_list.dart';
import 'filters_normal_list.dart';

class StackedFiltersList extends StatefulWidget {
  const StackedFiltersList(
      {super.key,
      required this.onMoveToAnotherFiltersSection,
      this.controller,
      required this.boutiqueSlug,
      required this.filterPageExpanded,
      required this.displayAppliedFiltersOnly,
      this.category,
      this.searchText,
      required this.fromSearch,
      required this.closeFilterPage});

  final void Function() closeFilterPage;
  final void Function(String message) onMoveToAnotherFiltersSection;
  final ScrollController? controller;
  final ValueNotifier<bool> filterPageExpanded;
  final bool fromSearch;
  final String? searchText;
  final String boutiqueSlug;
  final String? category;
  final bool displayAppliedFiltersOnly;

  @override
  _StackedFiltersListState createState() => _StackedFiltersListState();
}

class _StackedFiltersListState extends State<StackedFiltersList> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ValueNotifier<int> currentActiveSection = ValueNotifier(0);
  late AutoScrollController autoScrollController;
  ValueNotifier<Tuple2<double, double>>? lowerAndUpperPrices;

  int lastSectionDisplayed = 0;
  double? minPrice;
  double? maxPrice;
  double exchangeRate = 0.0;
  String currencySymbol = '';
  late HomeBloc homeBloc;
  bool isExpanded = false;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    isExpanded = widget.filterPageExpanded.value;
    widget.filterPageExpanded.addListener(() {
      isExpanded = widget.filterPageExpanded.value;
    });
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
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      print('ddqdqddq ${state.getProductFiltersModel}');
      print('ddqdqddq ${state.choosedFiltersByUser}');
      if (state.getProductFiltersModel?.filters == null) {
        return FiltersLoadingListPage(
          countOfListInPage: isExpanded ? 6 : 1,
        );
      }
      // if (state.getProductFiltersStatus == GetProductFiltersStatus.failure) {
      //   return Center(child: TryAgainWidget(tryAgain: () {
      //     BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent());
      //   }));
      // }
      if ((state.getProductFiltersModel?.filters == null &&
              state.appliedFiltersByUser == null) ||
          state.getCurrencyForCountryModel == null) {
        return SizedBox.shrink();
      }
      filter_model.Filter filters =
          state.getProductFiltersModel!.filters ?? filter_model.Filter();
      filter_model.Filter? choosedFilters = state.choosedFiltersByUser?.filters;
      if (filters.prices != null) {
        exchangeRate =
            state.getCurrencyForCountryModel?.data?.currency?.exchangeRate ?? 1;
        currencySymbol =
            state.getCurrencyForCountryModel?.data?.currency?.symbol ?? '\$';
        minPrice = filters.prices!.minPrice! * exchangeRate;
        maxPrice = filters.prices!.maxPrice! * exchangeRate;
        lowerAndUpperPrices = ValueNotifier(Tuple2(minPrice!, maxPrice!));
      }
      int countOfFilters = 0;
      List<String> titleOfFilterSection = [];
      if (!filters.categories.isNullOrEmpty) {
        countOfFilters++;
        titleOfFilterSection.add('View By Categories');
      }
      if (!filters.brands.isNullOrEmpty) {
        countOfFilters++;
        titleOfFilterSection.add('View By Brands');
      }
      if (!filters.attributes.isNullOrEmpty) {
        if (!filters.attributes![0].options.isNullOrEmpty) {
          countOfFilters++;
          titleOfFilterSection.add('View By Sizes');
        }
      }
      if (!filters.colors.isNullOrEmpty) {
        countOfFilters++;
        titleOfFilterSection.add('View By Colors');
      }
      if (filters.prices != null) {
        countOfFilters++;
        titleOfFilterSection.add('View By Price');
      }
      if (countOfFilters == 0 && state.appliedFiltersByUser == null) {
        return SizedBox.shrink();
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (countOfFilters != 0) ...{
            if (isExpanded) ...{
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 25),
                  child: Row(
                    children: [
                      FilterSelectedMark(width: 20, height: 20),
                      SizedBox(
                        width: 10,
                      ),
                      MyTextWidget(
                        'Filter By Category',
                        style: context.textTheme.caption?.rq.copyWith(
                            color: Color(0xff505050), height: 15 / 12),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SvgPicture.asset(
                        AppAssets.registerInfoSvg,
                        color: Color(0xffD3D3D3),
                      )
                    ],
                  )),
              SizedBox(
                height: 10,
              )
            },
            if (!widget.displayAppliedFiltersOnly) ...{
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
                      child: GestureDetector(
                        onTap: () {
                          currentActiveSection.value =
                              currentActiveSection.value == (countOfFilters - 1)
                                  ? 0
                                  : (currentActiveSection.value + 1);
                          autoScrollController.scrollToIndex(
                              2 * currentActiveSection.value,
                              duration: Duration(milliseconds: 200),
                              preferPosition: AutoScrollPosition.begin);
                          widget.onMoveToAnotherFiltersSection.call(
                              titleOfFilterSection[currentActiveSection.value]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 35.0),
                          child: ValueListenableBuilder<int>(
                              valueListenable: currentActiveSection,
                              builder: (context, currentActive, _) {
                                return SizedBox(
                                  height: 8,
                                  child: ListView.builder(
                                      itemCount: countOfFilters,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx, index) {
                                        return Row(
                                          children: [
                                            Container(
                                              height: 8,
                                              width: 8,
                                              decoration: BoxDecoration(
                                                  color: currentActive == index
                                                      ? Color(0xff505050)
                                                      : null,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color:
                                                          Color(0xff505050))),
                                            ),
                                            Container(
                                              width:
                                                  index != (countOfFilters - 1)
                                                      ? 2
                                                      : 0,
                                              color: Colors.transparent,
                                            ),
                                          ],
                                        );
                                      }),
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
                      behavior: CupertinoScrollBehavior(),
                      child: Expanded(
                        child: InViewNotifierList(
                            isInViewPortCondition: (double deltaTop,
                                double deltaBottom, double vpWidth) {
                              print(
                                  'fucjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj $deltaTop $deltaBottom $vpWidth');
                              return deltaTop <= (0.5 * vpWidth) &&
                                  deltaBottom >= (0.7 * vpWidth);
                            },
                            controller: autoScrollController,
                            itemCount: isExpanded ? 1 : 2 * countOfFilters - 1,
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
                                  builder: (BuildContext context, bool isInView,
                                      Widget? child) {
                                    if (isInView &&
                                        currentActiveSection.value !=
                                            (index ~/ 2)) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((timeStamp) {
                                        currentActiveSection.value = index ~/ 2;
                                        widget.onMoveToAnotherFiltersSection
                                            .call(titleOfFilterSection[
                                                index ~/ 2]);
                                      });
                                    }
                                    return child!;
                                  },
                                  child: AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: autoScrollController,
                                    index: index,
                                    child: index == 0 &&
                                            titleOfFilterSection[index ~/ 2] ==
                                                'View By Categories'
                                        ? ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                filters.categories?.length ?? 0,
                                            itemBuilder: (ctx, index) {
                                              if (!filters.categories![index]
                                                  .subCategories.isNullOrEmpty)
                                                return ValueListenableBuilder<
                                                        int>(
                                                    valueListenable:
                                                        expandingFiltersStack,
                                                    builder: (context,
                                                        currentExpandedIndex,
                                                        child) {
                                                      return AnimatedContainer(
                                                        curve: Curves
                                                            .fastEaseInToSlowEaseOut,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        margin:
                                                            EdgeInsetsDirectional
                                                                .only(end: 5),
                                                        width: currentExpandedIndex ==
                                                                index
                                                            ? (75 +
                                                                filters
                                                                        .categories![
                                                                            index]
                                                                        .subCategories!
                                                                        .length *
                                                                    55)
                                                            : 80.0,
                                                        height: 70.0,
                                                        child: Stack(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                          children: [
                                                            ...List.generate(
                                                              filters
                                                                  .categories![
                                                                      index]
                                                                  .subCategories!
                                                                  .length,
                                                              (innerIndex) =>
                                                                  AnimatedPositionedDirectional(
                                                                      curve: Curves
                                                                          .fastEaseInToSlowEaseOut,
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      top: currentExpandedIndex == index
                                                                          ? (70 -
                                                                              50)
                                                                          : (70 - 50) /
                                                                              2,
                                                                      end: currentExpandedIndex ==
                                                                              index
                                                                          ? innerIndex *
                                                                              55
                                                                          : innerIndex >= (filters.categories![index].subCategories!.length - 2)
                                                                              ? (innerIndex - 1) * 3
                                                                              : 0,
                                                                      child: FilterCircleWidget(
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        categoryName: filters
                                                                            .categories![index]
                                                                            .subCategories![innerIndex]
                                                                            .name
                                                                            .toString(),
                                                                        imageUrl: filters
                                                                            .categories![index]
                                                                            .subCategories![innerIndex]
                                                                            .mostViewedProductThumbnail!
                                                                            .filePath
                                                                            .toString(),
                                                                        withBackGroundShadow:
                                                                            innerIndex !=
                                                                                0,
                                                                        displayFilterMark: !isExpanded
                                                                            ? false
                                                                            : ((choosedFilters?.categories?.isNullOrEmpty ?? true)
                                                                                ? false
                                                                                : choosedFilters!.categories!.any((element) => element.id == filters.categories![index].subCategories![innerIndex].id)),
                                                                        addOrRemoveSpecificFilter:
                                                                            (bool
                                                                                add) {
                                                                          filter_model
                                                                              .Filter?
                                                                              prevChoosedOrAppliedFilterToAddToIt =
                                                                              !isExpanded ? state.appliedFiltersByUser?.filters : state.choosedFiltersByUser?.filters;
                                                                          categoriess.Category category = categoriess.Category(
                                                                              isSubCategory: true,
                                                                              id: filters.categories![index].subCategories![innerIndex].id,
                                                                              name: filters.categories![index].subCategories![innerIndex].name,
                                                                              mostViewedProductThumbnail: filters.categories![index].subCategories![innerIndex].mostViewedProductThumbnail);
                                                                          if (!isExpanded ||
                                                                              add) {
                                                                            if (prevChoosedOrAppliedFilterToAddToIt ==
                                                                                null) {
                                                                              prevChoosedOrAppliedFilterToAddToIt = filter_model.Filter();
                                                                            }
                                                                            prevChoosedOrAppliedFilterToAddToIt = prevChoosedOrAppliedFilterToAddToIt.copyWithSaveOtherField(
                                                                                prices: prevChoosedOrAppliedFilterToAddToIt
                                                                                    .prices,
                                                                                categories: prevChoosedOrAppliedFilterToAddToIt.categories.isNullOrEmpty
                                                                                    ? [
                                                                                        category
                                                                                      ]
                                                                                    : [
                                                                                        ...prevChoosedOrAppliedFilterToAddToIt.categories!,
                                                                                        category
                                                                                      ]);
                                                                            if (!isExpanded) {
                                                                              homeBloc.add(GetProductsWithFiltersEvent(boutiqueSlug: widget.boutiqueSlug, filtersAppliedByUser: filter_model.GetProductFiltersModel(filters: prevChoosedOrAppliedFilterToAddToIt), category: widget.category, offset: 1));
                                                                            } else {
                                                                              homeBloc.add(ChangeSelectedFiltersEvent(
                                                                                category: widget.category,
                                                                                boutiqueSlug: widget.boutiqueSlug,
                                                                                filtersChoosedByUser: filter_model.GetProductFiltersModel(filters: prevChoosedOrAppliedFilterToAddToIt),
                                                                              ));
                                                                            }
                                                                            return;
                                                                          } else {
                                                                            prevChoosedOrAppliedFilterToAddToIt!.categories!.removeWhere(((element) =>
                                                                                element.id ==
                                                                                filters.categories![index].subCategories![innerIndex].id));
                                                                            bool
                                                                                mustDeleteParentCategory =
                                                                                !prevChoosedOrAppliedFilterToAddToIt.categories!.any(((element) => filters.categories![index].subCategories!.any((sub) => sub.id == element.id)));
                                                                            if (mustDeleteParentCategory) {
                                                                              prevChoosedOrAppliedFilterToAddToIt.categories!.removeWhere(((element) => element.id == filters.categories![index].id));
                                                                            }
                                                                            prevChoosedOrAppliedFilterToAddToIt =
                                                                                prevChoosedOrAppliedFilterToAddToIt.copyWithSaveOtherField(
                                                                              prices: prevChoosedOrAppliedFilterToAddToIt.prices,
                                                                              categories: prevChoosedOrAppliedFilterToAddToIt.categories,
                                                                            );
                                                                            homeBloc.add(ChangeSelectedFiltersEvent(
                                                                              category: widget.category,
                                                                              boutiqueSlug: widget.boutiqueSlug,
                                                                              filtersChoosedByUser: filter_model.GetProductFiltersModel(filters: prevChoosedOrAppliedFilterToAddToIt),
                                                                            ));
                                                                          }
                                                                        },
                                                                        paddingValue: currentExpandedIndex ==
                                                                                index
                                                                            ? 5
                                                                            : 0,
                                                                        borderColor:
                                                                            colorScheme.white,
                                                                        isExpanded:
                                                                            currentExpandedIndex ==
                                                                                index,
                                                                      )),
                                                            ),
                                                            ValueListenableBuilder<
                                                                    bool>(
                                                                valueListenable:
                                                                    scaleTheTopItemInFiltersStack,
                                                                builder:
                                                                    (context,
                                                                        scale,
                                                                        _) {
                                                                  return FilterCircleWidget(
                                                                      width: 70,
                                                                      height:
                                                                          70,
                                                                      categoryName:
                                                                          filters
                                                                              .categories![
                                                                                  index]
                                                                              .name
                                                                              .toString(),
                                                                      imageUrl: filters
                                                                          .categories![
                                                                              index]
                                                                          .mostViewedProductThumbnail!
                                                                          .filePath
                                                                          .toString(),
                                                                      scale:
                                                                          scale,
                                                                      paddingValue:
                                                                          0,
                                                                      isExpanded:
                                                                          currentExpandedIndex ==
                                                                              index,
                                                                      displayFilterMark: !isExpanded
                                                                          ? false
                                                                          : ((choosedFilters?.categories?.isNullOrEmpty ?? true)
                                                                              ? false
                                                                              : choosedFilters!.categories!.any((element) => element.id == filters.categories![index].id)),
                                                                      addOrRemoveSpecificFilter: (bool add) {
                                                                        categoriess
                                                                            .Category
                                                                            category =
                                                                            filters.categories![index];
                                                                        filter_model
                                                                            .Filter?
                                                                            prevChoosedOrAppliedFilterToAddToIt =
                                                                            !isExpanded
                                                                                ? state.appliedFiltersByUser?.filters
                                                                                : state.choosedFiltersByUser?.filters;
                                                                        if (!isExpanded ||
                                                                            add) {
                                                                          if (prevChoosedOrAppliedFilterToAddToIt ==
                                                                              null) {
                                                                            prevChoosedOrAppliedFilterToAddToIt =
                                                                                filter_model.Filter();
                                                                          }
                                                                          prevChoosedOrAppliedFilterToAddToIt = prevChoosedOrAppliedFilterToAddToIt.copyWithSaveOtherField(
                                                                              prices: prevChoosedOrAppliedFilterToAddToIt
                                                                                  .prices,
                                                                              categories: prevChoosedOrAppliedFilterToAddToIt.categories.isNullOrEmpty
                                                                                  ? [
                                                                                      category
                                                                                    ]
                                                                                  : [
                                                                                      ...prevChoosedOrAppliedFilterToAddToIt.categories!,
                                                                                      category
                                                                                    ]);
                                                                          if (!isExpanded) {
                                                                            homeBloc.add(GetProductsWithFiltersEvent(
                                                                                boutiqueSlug: widget.boutiqueSlug,
                                                                                filtersAppliedByUser: filter_model.GetProductFiltersModel(filters: prevChoosedOrAppliedFilterToAddToIt),
                                                                                category: widget.category,
                                                                                offset: 1));
                                                                          } else {
                                                                            homeBloc.add(ChangeSelectedFiltersEvent(
                                                                              category: widget.category,
                                                                              boutiqueSlug: widget.boutiqueSlug,
                                                                              filtersChoosedByUser: filter_model.GetProductFiltersModel(filters: prevChoosedOrAppliedFilterToAddToIt),
                                                                            ));
                                                                          }
                                                                        } else {
                                                                          prevChoosedOrAppliedFilterToAddToIt!.categories!.removeWhere(((element) =>
                                                                              element.id ==
                                                                              filters.categories![index].id));
                                                                          prevChoosedOrAppliedFilterToAddToIt.categories!.removeWhere(((element) => filters
                                                                              .categories![index]
                                                                              .subCategories!
                                                                              .any((sub) => sub.id == element.id)));
                                                                          prevChoosedOrAppliedFilterToAddToIt =
                                                                              prevChoosedOrAppliedFilterToAddToIt.copyWithSaveOtherField(
                                                                            prices:
                                                                                prevChoosedOrAppliedFilterToAddToIt.prices,
                                                                            categories:
                                                                                prevChoosedOrAppliedFilterToAddToIt.categories,
                                                                          );
                                                                          homeBloc
                                                                              .add(ChangeSelectedFiltersEvent(
                                                                            category:
                                                                                widget.category,
                                                                            boutiqueSlug:
                                                                                widget.boutiqueSlug,
                                                                            filtersChoosedByUser:
                                                                                filter_model.GetProductFiltersModel(filters: prevChoosedOrAppliedFilterToAddToIt),
                                                                          ));
                                                                        }
                                                                      });
                                                                }),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              else {
                                                return FilterCircleWidget(
                                                    width: 70,
                                                    height: 70,
                                                    imageUrl: filters
                                                        .categories![index]
                                                        .mostViewedProductThumbnail!
                                                        .filePath
                                                        .toString(),
                                                    categoryName: filters
                                                        .categories![index].name
                                                        .toString(),
                                                    withBackGroundShadow: true,
                                                    displayFilterMark: !isExpanded
                                                        ? false
                                                        : ((choosedFilters
                                                                    ?.categories
                                                                    ?.isNullOrEmpty ??
                                                                true)
                                                            ? false
                                                            : choosedFilters!
                                                                .categories!
                                                                .any((element) =>
                                                                    element
                                                                        .id ==
                                                                    filters
                                                                        .categories![
                                                                            index]
                                                                        .id)),
                                                    addOrRemoveSpecificFilter:
                                                        (bool add) {
                                                      categoriess.Category
                                                          category =
                                                          filters.categories![
                                                              index];
                                                      filter_model.Filter?
                                                          prevChoosedOrAppliedFilterToAddToIt =
                                                          !isExpanded
                                                              ? state
                                                                  .appliedFiltersByUser
                                                                  ?.filters
                                                              : state
                                                                  .choosedFiltersByUser
                                                                  ?.filters;
                                                      if (!isExpanded || add) {
                                                        if (prevChoosedOrAppliedFilterToAddToIt ==
                                                            null) {
                                                          prevChoosedOrAppliedFilterToAddToIt =
                                                              filter_model
                                                                  .Filter();
                                                        }
                                                        prevChoosedOrAppliedFilterToAddToIt =
                                                            prevChoosedOrAppliedFilterToAddToIt.copyWithSaveOtherField(
                                                                prices:
                                                                    prevChoosedOrAppliedFilterToAddToIt
                                                                        .prices,
                                                                categories: prevChoosedOrAppliedFilterToAddToIt
                                                                        .categories
                                                                        .isNullOrEmpty
                                                                    ? [category]
                                                                    : [
                                                                        ...prevChoosedOrAppliedFilterToAddToIt
                                                                            .categories!,
                                                                        category
                                                                      ]);
                                                        if (!isExpanded) {
                                                          homeBloc.add(GetProductsWithFiltersEvent(
                                                              boutiqueSlug: widget
                                                                  .boutiqueSlug,
                                                              filtersAppliedByUser:
                                                                  filter_model
                                                                      .GetProductFiltersModel(
                                                                          filters:
                                                                              prevChoosedOrAppliedFilterToAddToIt),
                                                              category: widget
                                                                  .category,
                                                              offset: 1));
                                                        } else {
                                                          homeBloc.add(
                                                              ChangeSelectedFiltersEvent(
                                                            category:
                                                                widget.category,
                                                            boutiqueSlug: widget
                                                                .boutiqueSlug,
                                                            filtersChoosedByUser:
                                                                filter_model
                                                                    .GetProductFiltersModel(
                                                                        filters:
                                                                            prevChoosedOrAppliedFilterToAddToIt),
                                                          ));
                                                        }
                                                        return;
                                                      } else {
                                                        prevChoosedOrAppliedFilterToAddToIt!
                                                            .categories!
                                                            .removeWhere(((element) =>
                                                                element.id ==
                                                                filters
                                                                    .categories![
                                                                        index]
                                                                    .id));
                                                        prevChoosedOrAppliedFilterToAddToIt =
                                                            prevChoosedOrAppliedFilterToAddToIt
                                                                .copyWithSaveOtherField(
                                                          prices:
                                                              prevChoosedOrAppliedFilterToAddToIt
                                                                  .prices,
                                                          categories:
                                                              prevChoosedOrAppliedFilterToAddToIt
                                                                  .categories,
                                                        );
                                                        homeBloc.add(
                                                            ChangeSelectedFiltersEvent(
                                                          category:
                                                              widget.category,
                                                          boutiqueSlug: widget
                                                              .boutiqueSlug,
                                                          filtersChoosedByUser:
                                                              filter_model
                                                                  .GetProductFiltersModel(
                                                                      filters:
                                                                          prevChoosedOrAppliedFilterToAddToIt),
                                                        ));
                                                      }
                                                    });
                                              }
                                            },
                                          )
                                        : index <= 2 &&
                                                titleOfFilterSection[
                                                        index ~/ 2] ==
                                                    'View By Brands'
                                            ? FiltersNormalList(
                                                hideTitle: true,
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                fromSearch: widget.fromSearch,
                                                searchText: widget.searchText,
                                                category: widget.category,
                                                filterListTitle:
                                                    'Filter By Brand',
                                                isBrandFilter: true,
                                                filters: filters.brands ?? [],
                                              )
                                            : index <= 4 &&
                                                    titleOfFilterSection[
                                                            index ~/ 2] ==
                                                        'View By Sizes'
                                                ? SizesFiltersList(
                                                    hideTitle: true,
                                                    boutiqueSlug:
                                                        widget.boutiqueSlug,
                                                    fromSearch:
                                                        widget.fromSearch,
                                                    searchText:
                                                        widget.searchText,
                                                    category: widget.category,
                                                    attribute:
                                                        filters.attributes![0],
                                                  )
                                                : index <= 6 &&
                                                        titleOfFilterSection[
                                                                index ~/ 2] ==
                                                            'View By Colors'
                                                    ? ColorsListFilter(
                                                        hideTitle: true,
                                                        boutiqueSlug:
                                                            widget.boutiqueSlug,
                                                        fromSearch:
                                                            widget.fromSearch,
                                                        searchText:
                                                            widget.searchText,
                                                        category:
                                                            widget.category,
                                                        colors:
                                                            filters.colors ??
                                                                [],
                                                      )
                                                    : PriceFiltersRangesList(
                                                        exchangeRate:
                                                            exchangeRate,
                                                        decimalPoint: state
                                                                .startingSetting
                                                                ?.decimalPointSetting ??
                                                            2,
                                                        fromSearch:
                                                            widget.fromSearch,
                                                        searchText:
                                                            widget.searchText,
                                                        boutiqueSlug:
                                                            widget.boutiqueSlug,
                                                        currencySymbol:
                                                            currencySymbol,
                                                        category:
                                                            widget.category,
                                                        priceRanges: filters
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
              FiltersNormalList(
                filterListTitle: 'Filter By Brand',
                boutiqueSlug: widget.boutiqueSlug,
                fromSearch: widget.fromSearch,
                searchText: widget.searchText,
                category: widget.category,
                isBrandFilter: true,
                filters: filters.brands ?? [],
              ),
              ColorsListFilter(
                boutiqueSlug: widget.boutiqueSlug,
                fromSearch: widget.fromSearch,
                searchText: widget.searchText,
                category: widget.category,
                colors: filters.colors ?? [],
              ),
              FiltersNormalList(
                filterListTitle: 'Filter By Offer',
                boutiqueSlug: widget.boutiqueSlug,
                fromSearch: widget.fromSearch,
                searchText: widget.searchText,
                category: widget.category,
                isBrandFilter: false,
                filters: [],
              ),
              if (filters.prices != null)
                PriceFilter(
                  lowerAndUpperBound: lowerAndUpperPrices!,
                  decimalPoint: state.startingSetting?.decimalPointSetting ?? 2,
                  pricrRate: exchangeRate,
                  boutiqueSlug: widget.boutiqueSlug,
                  category: widget.category,
                  pricrSymbol: currencySymbol,
                  pricesFiltersRanges: filters.prices!,
                ),
              if (!filters.attributes.isNullOrEmpty)
                SizesFiltersList(
                  fromSearch: widget.fromSearch,
                  searchText: widget.searchText,
                  boutiqueSlug: widget.boutiqueSlug,
                  category: widget.category,
                  attribute: filters.attributes![0],
                ),
            },
          },
          if (!isExpanded) ...{
            Container(
              padding: EdgeInsets.only(
                  top: state.appliedFiltersByUser != null ? 5 : 0),
              color: Color(0xffF8F8F8),
              child: Container(
                width: 1.sw,
                height: state.appliedFiltersByUser != null ? 30 : 0,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                    color: Color(0xffEFEFEF),
                    borderRadius: BorderRadius.circular(10)),
                child: choosedOrAppliedFiltersWidget(),
              ),
            ),
          },
          if (countOfFilters != 0 ||  state.choosedFiltersByUser != null) ...{
            if (isExpanded) ...{
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  ValueListenableBuilder<Tuple2<double, double>>(
                      valueListenable:
                          lowerAndUpperPrices ?? ValueNotifier(Tuple2(-1, -1)),
                      builder: (context, _, __) {
                        return Container(
                          width: 1.sw,
                          height: (state.choosedFiltersByUser != null ||
                                  (lowerAndUpperPrices != null &&
                                      (lowerAndUpperPrices!.value.item1 >
                                              minPrice! ||
                                          lowerAndUpperPrices!.value.item2 <
                                              maxPrice!)))
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
                                  style: context.textTheme.caption?.rq.copyWith(
                                      color: Color(0xff505050),
                                      height: 15 / 12),
                                ),
                              ),
                              Container(
                                width: 1.sw,
                                height: (state.choosedFiltersByUser != null ||
                                        (lowerAndUpperPrices != null &&
                                            (lowerAndUpperPrices!.value.item1 >
                                                    minPrice! ||
                                                lowerAndUpperPrices!
                                                        .value.item2 <
                                                    maxPrice!)))
                                    ? 30
                                    : 0,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xffEFEFEF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: SizedBox(
                                    height: 15,
                                    child: choosedOrAppliedFiltersWidget()),
                              ),
                            ],
                          ),
                        );
                      }),
                  SizedBox(
                    height: 10,
                  ),
                  ValueListenableBuilder<Tuple2<double, double>>(
                      valueListenable:
                          lowerAndUpperPrices ?? ValueNotifier(Tuple2(-1, -1)),
                      builder: (context, _, __) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              if (state.choosedFiltersByUser != null ||
                                  (lowerAndUpperPrices != null &&
                                      (lowerAndUpperPrices!.value.item1 >
                                              minPrice! ||
                                          lowerAndUpperPrices!.value.item2 <
                                              maxPrice!))) ...{
                                Expanded(
                                  flex: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      List<filter_model.Brand>? brands = [
                                        ...state.appliedFiltersByUser?.filters
                                                ?.brands ??
                                            [],
                                        ...state.choosedFiltersByUser?.filters
                                                ?.brands ??
                                            []
                                      ];
                                      List<categoriess.Category>? categories = [
                                        ...state.appliedFiltersByUser?.filters
                                                ?.categories ??
                                            [],
                                        ...state.choosedFiltersByUser?.filters
                                                ?.categories ??
                                            []
                                      ];
                                      List<String>? colors = [
                                        ...state.appliedFiltersByUser?.filters
                                                ?.colors ??
                                            [],
                                        ...state.choosedFiltersByUser?.filters
                                                ?.colors ??
                                            []
                                      ];
                                      List<String> options = [];
                                      int? id;
                                      String? name;
                                      if (!(state.appliedFiltersByUser?.filters
                                              ?.attributes?.isNullOrEmpty ??
                                          true)) {
                                        id = state.appliedFiltersByUser!
                                            .filters!.attributes![0].id;
                                        name = state.appliedFiltersByUser!
                                            .filters!.attributes![0].name;
                                        options.addAll(state
                                                .appliedFiltersByUser!
                                                .filters!
                                                .attributes![0]
                                                .options ??
                                            []);
                                      }
                                      if (!(state.choosedFiltersByUser?.filters
                                              ?.attributes?.isNullOrEmpty ??
                                          true)) {
                                        id = state.choosedFiltersByUser!
                                            .filters!.attributes![0].id;
                                        name = state.choosedFiltersByUser!
                                            .filters!.attributes![0].name;
                                        options.addAll(state
                                                .choosedFiltersByUser!
                                                .filters!
                                                .attributes![0]
                                                .options ??
                                            []);
                                      }
                                      filter_model.Prices? prices;
                                      if ((lowerAndUpperPrices != null &&
                                          (lowerAndUpperPrices!.value.item1 >
                                                  minPrice! ||
                                              lowerAndUpperPrices!.value.item2 <
                                                  maxPrice!))) {
                                        prices = filter_model.Prices(
                                          minPrice:
                                              lowerAndUpperPrices!.value.item1 /
                                                  exchangeRate,
                                          maxPrice:
                                              lowerAndUpperPrices!.value.item2 /
                                                  exchangeRate,
                                        );
                                      }
                                      widget.closeFilterPage.call();
                                      homeBloc.add(GetProductsWithFiltersEvent(
                                        boutiqueSlug: widget.boutiqueSlug,
                                        category: widget.category,
                                        filtersAppliedByUser:
                                            filter_model.GetProductFiltersModel(
                                                filters: filter_model.Filter(
                                                    brands: brands,
                                                    categories: categories,
                                                    attributes: options.isEmpty
                                                        ? null
                                                        : [
                                                            filter_model
                                                                .Attribute(
                                                              id: id,
                                                              name: name,
                                                              options: options,
                                                            ),
                                                          ],
                                                    colors: colors,
                                                    prices: prices)),
                                        offset: 1,
                                      ));
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if(state.countOfProductExpectedByFiltering != null)...{
                                              MyTextWidget(
                                                '${state.countOfProductExpectedByFiltering}- ',
                                                style: textTheme.subtitle2?.mq
                                                    .copyWith(
                                                    color: Color(0xffFEFEFE),
                                                    height: 23 / 18),
                                              ),
                                            },
                                            MyTextWidget(
                                              'Apply',
                                              style: textTheme.headline6?.rq
                                                  .copyWith(
                                                      color: Color(0xffFEFEFE),
                                                      height: 23 / 18),
                                            ),
                                            if(state.getProductFiltersStatus == GetProductFiltersStatus.loading)...{
                                              SizedBox(width: 5,),
                                              TrydosLoader(size: 20,),
                                            }
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
                              ValueListenableBuilder<Tuple2<double, double>>(
                                  valueListenable: lowerAndUpperPrices ??
                                      ValueNotifier(Tuple2(-1, -1)),
                                  builder: (context, _, __) {
                                    return BlocBuilder<HomeBloc, HomeState>(
                                      builder: (context, state) {
                                        if (state.choosedFiltersByUser ==
                                                    null &&
                                            (lowerAndUpperPrices == null ||
                                            (lowerAndUpperPrices != null &&
                                                (lowerAndUpperPrices!
                                                            .value.item1 ==
                                                        minPrice! &&
                                                    lowerAndUpperPrices!
                                                            .value.item2 ==
                                                        maxPrice!)))) {
                                          return SizedBox.shrink();
                                        }
                                        return Expanded(
                                          flex: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (lowerAndUpperPrices != null) {
                                                lowerAndUpperPrices!.value =
                                                    Tuple2(
                                                        minPrice!, maxPrice!);
                                              }
                                              if (state.choosedFiltersByUser !=
                                                  null) {
                                                homeBloc.add(
                                                    ChangeSelectedFiltersEvent(
                                                        boutiqueSlug:
                                                            widget.boutiqueSlug,
                                                        category:
                                                            widget.category,
                                                        resetChoosedFilters: true,
                                                        filtersChoosedByUser:
                                                            null));
                                              }
                                            },
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 65,
                                                  decoration: BoxDecoration(
                                                      color: colorScheme.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 6,
                                                            offset:
                                                                Offset(0, 3)),
                                                        BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.4),
                                                            blurRadius: 6,
                                                            offset:
                                                                Offset(0, 3),
                                                            inset: true)
                                                      ],
                                                      border: Border.all(
                                                          color: Color(
                                                              0xff388CFF))),
                                                  child: Center(
                                                    child: MyTextWidget(
                                                      'Reset',
                                                      style: textTheme
                                                          .headline6?.rq
                                                          .copyWith(
                                                              color: Color(
                                                                  0xff388CFF),
                                                              height: 23 / 18),
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

  BlocBuilder<HomeBloc, HomeState> choosedOrAppliedFiltersWidget() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        filter_model.Filter? filters;
        if (isExpanded) {
          filters = state.choosedFiltersByUser?.filters;
        } else {
          filters = state.appliedFiltersByUser?.filters;
        }
        if (filters == null && (lowerAndUpperPrices == null && isExpanded)) {
          return SizedBox.shrink();
        }

        if ((filters?.brands.isNullOrEmpty ?? true) &&
            (filters?.categories.isNullOrEmpty ?? true) &&
            filters?.prices == null &&
            (filters?.colors.isNullOrEmpty ?? true) &&
            (lowerAndUpperPrices == null && isExpanded) &&
            (filters?.attributes.isNullOrEmpty ?? true)) {
          return SizedBox.shrink();
        }
        return SizedBox(
          height: 15,
          child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                if (!isExpanded)
                  GestureDetector(
                    onTap: () {
                      homeBloc.add(GetProductsWithFiltersEvent(
                          boutiqueSlug: widget.boutiqueSlug,
                          category: widget.category,
                          offset: 1,
                          filtersAppliedByUser: null));
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
                if (!(filters?.categories.isNullOrEmpty ?? true)) ...{
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
                      itemCount: filters?.categories?.length ?? 0,
                      itemBuilder: (ctx, index) {
                        return GestureDetector(
                          onTap: () {
                            List<String> categories = filters!.categories!
                                .map((e) => e.id.toString())
                                .toList();
                            List<categoriess.Category> newCategories =
                                filters.categories ?? [];
                            newCategories.removeAt(index);
                            categories.removeAt(index);
                            filter_model.GetProductFiltersModel
                                newGetProductFiltersModel =
                                filter_model.GetProductFiltersModel(
                                    filters: filters.copyWithSaveOtherField(
                                        prices: filters.prices,
                                        categories: newCategories));
                            if (isExpanded) {
                              BlocProvider.of<HomeBloc>(context)
                                  .add(ChangeSelectedFiltersEvent(
                                category: widget.category,
                                boutiqueSlug: widget.boutiqueSlug,
                                filtersChoosedByUser: newGetProductFiltersModel,
                              ));
                              return;
                            }
                            BlocProvider.of<HomeBloc>(context)
                                .add(GetProductsWithFiltersEvent(
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              offset: 1,
                              filtersAppliedByUser: newGetProductFiltersModel,
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilterImage(
                                width: filters!.categories![index].isSubCategory
                                    ? 15
                                    : 20,
                                height: filters.categories![index].isSubCategory
                                    ? 15
                                    : 20,
                                imageUrl: filters.categories![index]
                                    .mostViewedProductThumbnail!.filePath
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
                                style: context.textTheme.caption?.rq.copyWith(
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
                        return GestureDetector(
                          onTap: () {
                            List<filter_model.Brand> newBrands =
                                filters!.brands ?? [];
                            newBrands.removeAt(index);
                            filter_model.GetProductFiltersModel
                                newGetProductFiltersModel =
                                filter_model.GetProductFiltersModel(
                                    filters: filters.copyWithSaveOtherField(
                                        prices: filters.prices,
                                        brands: newBrands));
                            if (isExpanded) {
                              BlocProvider.of<HomeBloc>(context)
                                  .add(ChangeSelectedFiltersEvent(
                                category: widget.category,
                                boutiqueSlug: widget.boutiqueSlug,
                                filtersChoosedByUser: newGetProductFiltersModel,
                              ));
                              return;
                            }
                            BlocProvider.of<HomeBloc>(context).add(
                                GetProductsWithFiltersEvent(
                                    boutiqueSlug: widget.boutiqueSlug,
                                    category: widget.category,
                                    offset: 1,
                                    filtersAppliedByUser:
                                        newGetProductFiltersModel));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilterImage(
                                width: 20,
                                height: 20,
                                imageUrl:
                                    filters!.brands![index].image.toString(),
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
                                style: context.textTheme.caption?.rq.copyWith(
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
                          : filters!.attributes![0].options?.length ?? 0,
                      itemBuilder: (ctx, index) {
                        return GestureDetector(
                          onTap: () {
                            List<String>? options =
                                filters!.attributes![0].options;
                            options?.removeAt(index);
                            filter_model.GetProductFiltersModel
                                newGetProductFiltersModel =
                                filter_model.GetProductFiltersModel(
                                    filters: filters.copyWithSaveOtherField(
                                        prices: filters.prices,
                                        attributes: options.isNullOrEmpty
                                            ? []
                                            : [
                                                filters.attributes![0]
                                                    .copyWith(options: options)
                                              ]));
                            if (isExpanded) {
                              BlocProvider.of<HomeBloc>(context)
                                  .add(ChangeSelectedFiltersEvent(
                                category: widget.category,
                                boutiqueSlug: widget.boutiqueSlug,
                                filtersChoosedByUser: newGetProductFiltersModel,
                              ));
                              return;
                            }
                            BlocProvider.of<HomeBloc>(context)
                                .add(GetProductsWithFiltersEvent(
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              offset: 1,
                              filtersAppliedByUser: newGetProductFiltersModel,
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
                                style: context.textTheme.caption?.rq.copyWith(
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
                          return GestureDetector(
                            onTap: () {
                              List<String>? colors = filters!.colors;
                              colors?.removeAt(index);
                              filter_model.GetProductFiltersModel
                                  newGetProductFiltersModel =
                                  filter_model.GetProductFiltersModel(
                                      filters: filters.copyWithSaveOtherField(
                                          prices: filters.prices,
                                          colors: colors));
                              if (isExpanded) {
                                BlocProvider.of<HomeBloc>(context)
                                    .add(ChangeSelectedFiltersEvent(
                                  category: widget.category,
                                  boutiqueSlug: widget.boutiqueSlug,
                                  filtersChoosedByUser:
                                      newGetProductFiltersModel,
                                ));
                                return;
                              }
                              BlocProvider.of<HomeBloc>(context)
                                  .add(GetProductsWithFiltersEvent(
                                boutiqueSlug: widget.boutiqueSlug,
                                category: widget.category,
                                offset: 1,
                                filtersAppliedByUser: newGetProductFiltersModel,
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
                                    border:
                                        Border.all(color: Color(0xffC4C2C2)),
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
                if (filters?.prices != null ||
                    (isExpanded &&
                        lowerAndUpperPrices != null &&
                        (lowerAndUpperPrices!.value.item1 > minPrice! ||
                            lowerAndUpperPrices!.value.item2 < maxPrice!))) ...{
                  Center(child: FilterSelectedMark(width: 15, height: 15)),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      filter_model.GetProductFiltersModel
                          newGetProductFiltersModel =
                          filter_model.GetProductFiltersModel(
                              filters: filters!
                                  .copyWithSaveOtherField(prices: null));
                      if (isExpanded) {
                        BlocProvider.of<HomeBloc>(context)
                            .add(ChangeSelectedFiltersEvent(
                          category: widget.category,
                          boutiqueSlug: widget.boutiqueSlug,
                          filtersChoosedByUser: newGetProductFiltersModel,
                        ));
                        return;
                      }
                      BlocProvider.of<HomeBloc>(context).add(
                          GetProductsWithFiltersEvent(
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              offset: 1,
                              filtersAppliedByUser: newGetProductFiltersModel));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        MyTextWidget(
                          '${currencySymbol} ',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.caption?.rq.copyWith(
                              color: Color(0xff8E8E8E),
                              letterSpacing: 0,
                              height: 1.25),
                        ),
                        MyTextWidget(
                          filters?.prices != null
                              ? '${(filters!.prices!.minPrice! * exchangeRate).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2).toString()} / '
                              : '${lowerAndUpperPrices!.value.item1.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} / ',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.caption?.rq.copyWith(
                              color: Color(0xff8E8E8E),
                              letterSpacing: 0,
                              height: 1.25),
                        ),
                        MyTextWidget(
                          filters?.prices != null
                              ? '${(filters!.prices!.maxPrice! * exchangeRate).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}'
                              : '${lowerAndUpperPrices!.value.item2.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.caption?.rq.copyWith(
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
                }
              ]),
        );
      },
    );
  }
}

class FilterCircleWidget extends StatefulWidget {
  const FilterCircleWidget(
      {super.key,
      this.isExpanded = true,
      required this.imageUrl,
      required this.width,
      required this.height,
      required this.categoryName,
      required this.addOrRemoveSpecificFilter,
      this.withBackGroundShadow = true,
      this.paddingValue = 10,
      this.scale = false,
      this.markWidth = 20,
      this.markHeight = 20,
      this.borderColor,
      this.expandStackedItemsFunction,
      required this.displayFilterMark});

  final Color? borderColor;
  final bool isExpanded;
  final double width;
  final double markWidth;
  final double paddingValue;
  final double height;
  final double markHeight;
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
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => widget.addOrRemoveSpecificFilter
                    .call(!widget.displayFilterMark),
                child: Stack(
                  children: [
                    AnimatedScale(
                      curve: Curves.fastEaseInToSlowEaseOut,
                      scale: widget.scale ? 0.92 : 1,
                      duration: Duration(milliseconds: 100),
                      child: FilterImage(
                        imageUrl: widget.imageUrl,
                        width: widget.width,
                        height: widget.height,
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
                            width: widget.markWidth, height: widget.markHeight))
                  ],
                ),
              ),
              if (widget.isExpanded) ...{
                SizedBox(height: 5),
                MyTextWidget(
                  widget.categoryName,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption?.rq.copyWith(
                      color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
                ),
              }
            ],
          ),
        ],
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
      this.isSvg = false,
      required this.imageUrl});

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
