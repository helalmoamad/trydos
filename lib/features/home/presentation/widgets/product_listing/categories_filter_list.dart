import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/object.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../data/models/get_product_filters_model.dart';
import '../../../data/models/get_product_listing_with_filters_model.dart';
import '../../manager/home_event.dart';

class CategoriesFilterList extends StatelessWidget {
  CategoriesFilterList(
      {super.key,
      required this.expandingFiltersStack,
      required this.workWithChoosedFilter,
      required this.boutiqueSlug,
      required this.filterss,
      this.category,
      required this.scaleTheTopItemInFiltersStack,
      this.fromSearch = false,
      this.controller});

  final ValueNotifier<int> expandingFiltersStack;
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack;
  final bool workWithChoosedFilter;
  final bool fromSearch;
  final Filter filterss;
  final TextEditingController? controller;
  final String boutiqueSlug;
  final String? category;

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);

    String key = boutiqueSlug + (category ?? '');

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.appliedFiltersByUser[key] !=
              current.appliedFiltersByUser[key] ||
          previous.choosedFiltersByUser[key] !=
              current.choosedFiltersByUser[key] ||
          previous.isExpandedForListingPage !=
              current.isExpandedForListingPage ||
          previous.getProductFiltersStatus[key] !=
              current.getProductFiltersStatus[key],
      builder: (context, state) {
        Filter filters = filterss;
        Filter? choosedFilters = state.choosedFiltersByUser[key]?.filters;
        Filter? appliedFilters = state.appliedFiltersByUser[key]?.filters;
        if (((choosedFilters?.categories?.length ?? 0) == 0) &&
            (appliedFilters?.categories?.length ?? 0) == 0) {
          print(
              "---------------+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
          expandingFiltersStack.value = -1;
        }
        print(filters.categories?.length ?? 0);

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filters.categories?.length ?? 0,
          itemBuilder: (ctx, index) {
            if (!workWithChoosedFilter
                ? ((appliedFilters?.categories?.isNullOrEmpty ?? true)
                    ? false
                    : appliedFilters!.categories!.any((element) =>
                        element.id == filters.categories![index].id))
                : ((choosedFilters?.categories?.isNullOrEmpty ?? true)
                    ? false
                    : choosedFilters!.categories!.any((element) =>
                        element.id == filters.categories![index].id))) {
              expandingFiltersStack.value = index;
            }
            bool isChildCategorySlug = false;
            if (!(filters.categories![index].subCategories?.isNullOrEmpty ??
                true)) {
              List<SubCategory> subCategories =
                  List.from(filters.categories![index].subCategories ?? []);
              filters.categories![index].subCategories!.forEach(
                (element) {
                  subCategories.addAll(element.childes?.map(
                        (e) => e.copyWith(
                          isSubSubCategory: true,
                        ),
                      ) ??
                      []);
                },
              );

              subCategories = subCategories.toSet().toList().reversed.toList();
              List<String> subCategoriesslugs = [];
              subCategories.forEach(
                (element) {
                  subCategoriesslugs.add(element.slug ?? "");
                },
              );
              subCategories.removeWhere(
                (element) =>
                    subCategoriesslugs.contains(element.slug) &&
                    element.isSubSubCategory == false,
              );
              if (!(filters.categories?[index].isSubCategory ?? false)) {
                subCategories?.forEach((elements) {
                  if (!(workWithChoosedFilter)) {
                    if (homeBloc.state.appliedFiltersByUser[key]?.filters
                            ?.categories
                            ?.any(
                                (element) => (element.slug == elements.slug)) ??
                        false) {
                      isChildCategorySlug = true;
                    }
                  } else {
                    if (homeBloc.state.choosedFiltersByUser[key]?.filters
                            ?.categories
                            ?.any(
                                (element) => (element.slug == elements.slug)) ??
                        false) {
                      isChildCategorySlug = true;
                    }
                  }
                  ;
                });
              }

              return ValueListenableBuilder<int>(
                  valueListenable: expandingFiltersStack,
                  builder: (context, currentExpandedIndex, child) {
                    print("${(currentExpandedIndex == index)}");
                    print("///////////////");
                    print("${isChildCategorySlug}");
                    return AnimatedContainer(
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsetsDirectional.only(end: 5),
                      width:
                          (currentExpandedIndex == index) || isChildCategorySlug
                              ? (75 + subCategories!.length * 55)
                              : 80.0,
                      height: 70.0,
                      child: Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: [
                          ...List.generate(
                            subCategories!.length,
                            (innerIndex) => AnimatedPositionedDirectional(
                                curve: Curves.fastEaseInToSlowEaseOut,
                                duration: Duration(milliseconds: 300),
                                top: (currentExpandedIndex == index ||
                                        isChildCategorySlug)
                                    ? subCategories![innerIndex]
                                                .isSubSubCategory ??
                                            false
                                        ? 35
                                        : (70 - 50)
                                    : (70 - 50) / 2,
                                end: currentExpandedIndex == index ||
                                        isChildCategorySlug
                                    ? innerIndex * 55
                                    : innerIndex >= (subCategories!.length - 2)
                                        ? (innerIndex - 1) * 3
                                        : 0,
                                child: subCategories[innerIndex]
                                            .mostViewedProductThumbnail !=
                                        null
                                    ? FilterCircleWidget(
                                        isSubSubCategory:
                                            subCategories![innerIndex]
                                                    .isSubSubCategory ??
                                                false,
                                        isSvg: false,
                                        width: subCategories![innerIndex]
                                                    .isSubSubCategory ??
                                                false
                                            ? 35
                                            : 50,
                                        height: subCategories![innerIndex]
                                                    .isSubSubCategory ??
                                                false
                                            ? 35
                                            : 50,
                                        originalWidth: double.tryParse(
                                            subCategories![innerIndex]
                                                .mostViewedProductThumbnail!
                                                .originalWidth
                                                .toString()),
                                        originalHeight: double.tryParse(
                                            subCategories[innerIndex]
                                                .mostViewedProductThumbnail!
                                                .originalHeight
                                                .toString()),
                                        categoryName: subCategories[innerIndex]
                                            .name
                                            .toString(),
                                        imageUrl: subCategories![innerIndex]
                                            .mostViewedProductThumbnail!
                                            .filePath
                                            .toString(),
                                        withBackGroundShadow: innerIndex != 0,
                                        displayFilterMark:
                                            !workWithChoosedFilter
                                                ? ((appliedFilters?.categories
                                                            ?.isNullOrEmpty ??
                                                        true)
                                                    ? false
                                                    : appliedFilters!
                                                        .categories!
                                                        .any((element) =>
                                                            element.id ==
                                                            subCategories![
                                                                    innerIndex]
                                                                .id))
                                                : ((choosedFilters?.categories
                                                            ?.isNullOrEmpty ??
                                                        true)
                                                    ? false
                                                    : choosedFilters!
                                                        .categories!
                                                        .any((element) =>
                                                            element.id ==
                                                            subCategories![
                                                                    innerIndex]
                                                                .id)),
                                        addOrRemoveSpecificFilter: (bool add) {
                                          scaleTheTopItemInFiltersStack.value =
                                              (currentExpandedIndex == index);

                                          Filter?
                                              prevChoosedOrAppliedFilterToAddToIt =
                                              !workWithChoosedFilter
                                                  ? state
                                                      .appliedFiltersByUser[key]
                                                      ?.filters
                                                  : state
                                                      .choosedFiltersByUser[key]
                                                      ?.filters;
                                          List<Category>? categories = List.of(
                                              prevChoosedOrAppliedFilterToAddToIt
                                                      ?.categories ??
                                                  []);

                                          if (add) {
                                            FirebaseAnalyticsService
                                                .logEventForSession(
                                              eventName: AnalyticsEventsConst
                                                  .buttonClicked,
                                              executedEventName:
                                                  AnalyticsExecutedEventNameConst
                                                      .addFilterButton,
                                            );
                                            //////////////////////////////
                                            // expandingFiltersStack.value =
                                            //   innerIndex;
                                            Category category = Category(
                                                slug: subCategories![innerIndex]
                                                    .slug,
                                                isSubCategory: true,
                                                id: subCategories![innerIndex]
                                                    .id,
                                                name: subCategories![innerIndex]
                                                    .name,
                                                flatPhotoPath:
                                                    subCategories![innerIndex]
                                                        .flatPhotoPath);
                                            if (prevChoosedOrAppliedFilterToAddToIt ==
                                                null) {
                                              prevChoosedOrAppliedFilterToAddToIt =
                                                  Filter();
                                            }
                                            List<Category>? categoryParent =
                                                prevChoosedOrAppliedFilterToAddToIt
                                                    .categories;
                                            categoryParent?.removeWhere(
                                                (element) =>
                                                    element.slug ==
                                                    filters.categories?[index]
                                                        .slug);
                                            prevChoosedOrAppliedFilterToAddToIt =
                                                prevChoosedOrAppliedFilterToAddToIt
                                                    .copyWithSaveOtherField(
                                                        prices:
                                                            prevChoosedOrAppliedFilterToAddToIt
                                                                .prices,
                                                        searchText: controller !=
                                                                null
                                                            ? controller!.text
                                                                        .length >
                                                                    2
                                                                ? controller
                                                                    ?.text
                                                                : null
                                                            : null,
                                                        categories: categoryParent
                                                                .isNullOrEmpty
                                                            ? [category]
                                                            : [
                                                                ...categoryParent!,
                                                                category
                                                              ]);
                                          } else {
                                            FirebaseAnalyticsService
                                                .logEventForSession(
                                              eventName: AnalyticsEventsConst
                                                  .buttonClicked,
                                              executedEventName:
                                                  AnalyticsExecutedEventNameConst
                                                      .resetByTapOnFilterButton,
                                            );
                                            //////////////////////////////
                                            categories.removeWhere(((element) =>
                                                element.id ==
                                                subCategories![innerIndex].id));
                                            bool mustDeleteParentCategory =
                                                categories.any(((element) =>
                                                    subCategories!.any((sub) =>
                                                        sub.id == element.id)));
                                            /*    if (mustDeleteParentCategory) {
                                      prevChoosedOrAppliedFilterToAddToIt
                                          .categories!
                                          .removeWhere(((element) =>
                                              element.id ==
                                              filters.categories![index].id));
                                    }*/
                                            prevChoosedOrAppliedFilterToAddToIt =
                                                prevChoosedOrAppliedFilterToAddToIt!
                                                    .copyWithSaveOtherField(
                                              prices:
                                                  prevChoosedOrAppliedFilterToAddToIt
                                                      .prices,
                                              searchText: controller != null
                                                  ? controller!.text.length > 2
                                                      ? controller?.text
                                                      : null
                                                  : null,
                                              categories: categories,
                                            );
                                          }
                                          if (!workWithChoosedFilter) {
                                            homeBloc
                                                .add(ChangeAppliedFiltersEvent(
                                              category: category,
                                              boutiqueSlug: boutiqueSlug,
                                              filtersAppliedByUser:
                                                  GetProductFiltersModel(
                                                      filters:
                                                          prevChoosedOrAppliedFilterToAddToIt),
                                            ));
                                            homeBloc.add(
                                                GetProductsWithFiltersEvent(
                                                    searchText:
                                                        controller?.text,
                                                    fromSearch: fromSearch,
                                                    boutiqueSlug: boutiqueSlug,
                                                    category: category,
                                                    offset: 1));
                                          } else {
                                            homeBloc
                                                .add(ChangeSelectedFiltersEvent(
                                              fromHomePageSearch: fromSearch,
                                              category: category,
                                              boutiqueSlug: boutiqueSlug,
                                              filtersChoosedByUser:
                                                  GetProductFiltersModel(
                                                      filters:
                                                          prevChoosedOrAppliedFilterToAddToIt),
                                            ));
                                          }
                                        },
                                        paddingValue:
                                            (currentExpandedIndex == index) ||
                                                    isChildCategorySlug
                                                ? 3
                                                : 0,
                                        borderColor: context.colorScheme.white,
                                        isExpanded:
                                            (currentExpandedIndex == index) ||
                                                isChildCategorySlug,
                                      )
                                    : SizedBox.shrink()),
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: scaleTheTopItemInFiltersStack,
                              builder: (context, scale, _) {
                                return filters.categories![index]
                                            .mostViewedProductThumbnail !=
                                        null
                                    ? FilterCircleWidget(
                                        key: TestVariables.kTestMode == false
                                            ? null
                                            : Key(
                                                '${WidgetsKey.categoryCircleWithSubProductListingFilterKey}$index'),
                                        isSvg: false,
                                        width: 70,
                                        height: 70,
                                        isTopItem: true,
                                        originalWidth: double.tryParse(filters
                                            .categories![index]
                                            .mostViewedProductThumbnail!
                                            .originalWidth
                                            .toString()),
                                        originalHeight: double.tryParse(filters
                                            .categories![index]
                                            .mostViewedProductThumbnail!
                                            .originalHeight
                                            .toString()),
                                        categoryName: filters.categories![index].name
                                            .toString(),
                                        imageUrl: filters
                                            .categories![index]
                                            .mostViewedProductThumbnail!
                                            .filePath
                                            .toString(),
                                        scale: scale,
                                        paddingValue: 2,
                                        isExpanded: (currentExpandedIndex == index),
                                        displayFilterMark: (isChildCategorySlug || (!workWithChoosedFilter ? ((appliedFilters?.categories?.isNullOrEmpty ?? true) ? false : appliedFilters!.categories!.any((element) => element.id == filters.categories![index].id)) : ((choosedFilters?.categories?.isNullOrEmpty ?? true) ? false : choosedFilters!.categories!.any((element) => element.id == filters.categories![index].id)))),
                                        addOrRemoveSpecificFilter: (bool add) {
                                          if (appliedFilters?.categories ==
                                                  null &&
                                              choosedFilters?.categories ==
                                                  null) {
                                            expandingFiltersStack.value = -1;
                                          } else if (!workWithChoosedFilter
                                              ? ((appliedFilters?.categories
                                                          ?.isNullOrEmpty ??
                                                      true)
                                                  ? false
                                                  : appliedFilters!.categories!
                                                      .any((element) =>
                                                          element.id ==
                                                          filters
                                                              .categories![
                                                                  index]
                                                              .id))
                                              : ((choosedFilters?.categories
                                                          ?.isNullOrEmpty ??
                                                      true)
                                                  ? false
                                                  : choosedFilters!.categories!
                                                      .any((element) =>
                                                          element.id ==
                                                          filters
                                                              .categories![
                                                                  index]
                                                              .id))) {
                                            print(
                                                "111111111111111111111111111111qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
                                            expandingFiltersStack.value = index;
                                          }
                                          scaleTheTopItemInFiltersStack.value =
                                              currentExpandedIndex == index;
                                          Filter?
                                              prevChoosedOrAppliedFilterToAddToIt =
                                              !workWithChoosedFilter
                                                  ? state
                                                      .appliedFiltersByUser[key]
                                                      ?.filters
                                                  : state
                                                      .choosedFiltersByUser[key]
                                                      ?.filters;
                                          List<Category>? categories = List.of(
                                              prevChoosedOrAppliedFilterToAddToIt
                                                      ?.categories ??
                                                  []);

                                          if (add) {
                                            FirebaseAnalyticsService
                                                .logEventForSession(
                                              eventName: AnalyticsEventsConst
                                                  .buttonClicked,
                                              executedEventName:
                                                  AnalyticsExecutedEventNameConst
                                                      .addFilterButton,
                                            );
                                            //////////////////////////////
                                            Category category =
                                                filters.categories![index];
                                            if (prevChoosedOrAppliedFilterToAddToIt ==
                                                null) {
                                              prevChoosedOrAppliedFilterToAddToIt =
                                                  Filter();
                                            }
                                            prevChoosedOrAppliedFilterToAddToIt =
                                                prevChoosedOrAppliedFilterToAddToIt
                                                    .copyWithSaveOtherField(
                                                        prices:
                                                            prevChoosedOrAppliedFilterToAddToIt
                                                                .prices,
                                                        searchText: controller !=
                                                                null
                                                            ? controller!.text
                                                                        .length >
                                                                    2
                                                                ? controller
                                                                    ?.text
                                                                : null
                                                            : null,
                                                        categories:
                                                            prevChoosedOrAppliedFilterToAddToIt
                                                                    .categories
                                                                    .isNullOrEmpty
                                                                ? [category]
                                                                : [
                                                                    ...prevChoosedOrAppliedFilterToAddToIt
                                                                        .categories!,
                                                                    category
                                                                  ]);
                                          } else {
                                            FirebaseAnalyticsService
                                                .logEventForSession(
                                              eventName: AnalyticsEventsConst
                                                  .buttonClicked,
                                              executedEventName:
                                                  AnalyticsExecutedEventNameConst
                                                      .resetByTapOnFilterButton,
                                            );
                                            ///////////////////////////////////////
                                            expandingFiltersStack.value = -1;
                                            categories.removeWhere(((element) =>
                                                element.id ==
                                                filters.categories![index].id));

                                            categories.removeWhere(((element) =>
                                                subCategories!.any((sub) =>
                                                    sub.id == element.id)));
                                            prevChoosedOrAppliedFilterToAddToIt =
                                                prevChoosedOrAppliedFilterToAddToIt!
                                                    .copyWithSaveOtherField(
                                              searchText: controller != null
                                                  ? controller!.text.length > 2
                                                      ? controller?.text
                                                      : null
                                                  : null,
                                              prices:
                                                  prevChoosedOrAppliedFilterToAddToIt
                                                      .prices,
                                              categories: categories,
                                            );
                                          }
                                          if (!workWithChoosedFilter) {
                                            print(
                                                "dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");

                                            homeBloc
                                                .add(ChangeAppliedFiltersEvent(
                                              category: category,
                                              boutiqueSlug: boutiqueSlug,
                                              filtersAppliedByUser:
                                                  GetProductFiltersModel(
                                                      filters:
                                                          prevChoosedOrAppliedFilterToAddToIt),
                                            ));

                                            homeBloc.add(
                                                GetProductsWithFiltersEvent(
                                                    searchText:
                                                        controller?.text,
                                                    fromSearch: fromSearch,
                                                    boutiqueSlug: boutiqueSlug,
                                                    category: category,
                                                    offset: 1));
                                          } else {
                                            homeBloc
                                                .add(ChangeSelectedFiltersEvent(
                                              fromHomePageSearch: fromSearch,
                                              category: category,
                                              boutiqueSlug: boutiqueSlug,
                                              filtersChoosedByUser:
                                                  GetProductFiltersModel(
                                                      filters:
                                                          prevChoosedOrAppliedFilterToAddToIt),
                                            ));
                                          }
                                        })
                                    : SizedBox.shrink();
                              }),
                        ],
                      ),
                    );
                  });
            } else {
              return filters.categories![index].mostViewedProductThumbnail !=
                      null
                  ? FilterCircleWidget(
                      key: TestVariables.kTestMode == false
                          ? null
                          : Key(
                              '${WidgetsKey.categoryCircleWithOutSubProductListingFilterKey}$index'),
                      isSvg: false,
                      width: 65,
                      height: 65,
                      imageUrl: filters.categories![index]
                          .mostViewedProductThumbnail!.filePath
                          .toString(),
                      categoryName: filters.categories![index].name.toString(),
                      withBackGroundShadow: true,
                      displayFilterMark: isChildCategorySlug ||
                              !workWithChoosedFilter
                          ? ((appliedFilters?.categories?.isNullOrEmpty ?? true)
                              ? false
                              : appliedFilters!.categories!.any((element) =>
                                  element.id == filters.categories![index].id))
                          : ((choosedFilters?.categories?.isNullOrEmpty ?? true)
                              ? false
                              : choosedFilters!.categories!.any((element) =>
                                  element.id == filters.categories![index].id)),
                      addOrRemoveSpecificFilter: (bool add) {
                        Filter? prevChoosedOrAppliedFilterToAddToIt =
                            !workWithChoosedFilter
                                ? state.appliedFiltersByUser[key]?.filters
                                : state.choosedFiltersByUser[key]?.filters;
                        List<Category>? categories = List.of(
                            prevChoosedOrAppliedFilterToAddToIt?.categories ??
                                []);
                        if (add) {
                          FirebaseAnalyticsService.logEventForSession(
                            eventName: AnalyticsEventsConst.buttonClicked,
                            executedEventName:
                                AnalyticsExecutedEventNameConst.addFilterButton,
                          );
                          //////////////////////////////
                          Category category = filters.categories![index];
                          if (prevChoosedOrAppliedFilterToAddToIt == null) {
                            prevChoosedOrAppliedFilterToAddToIt = Filter();
                          }
                          prevChoosedOrAppliedFilterToAddToIt =
                              prevChoosedOrAppliedFilterToAddToIt
                                  .copyWithSaveOtherField(
                                      prices:
                                          prevChoosedOrAppliedFilterToAddToIt
                                              .prices,
                                      searchText: controller != null
                                          ? controller!.text.length > 2
                                              ? controller?.text
                                              : null
                                          : null,
                                      categories:
                                          prevChoosedOrAppliedFilterToAddToIt
                                                  .categories.isNullOrEmpty
                                              ? [category]
                                              : [
                                                  ...prevChoosedOrAppliedFilterToAddToIt
                                                      .categories!,
                                                  category
                                                ]);
                        } else {
                          FirebaseAnalyticsService.logEventForSession(
                            eventName: AnalyticsEventsConst.buttonClicked,
                            executedEventName: AnalyticsExecutedEventNameConst
                                .resetByTapOnFilterButton,
                          );
                          ////////////////////////////
                          categories.removeWhere(((element) =>
                              element.id == filters.categories![index].id));
                          prevChoosedOrAppliedFilterToAddToIt =
                              prevChoosedOrAppliedFilterToAddToIt!
                                  .copyWithSaveOtherField(
                            prices: prevChoosedOrAppliedFilterToAddToIt.prices,
                            searchText: controller != null
                                ? controller!.text.length > 2
                                    ? controller?.text
                                    : null
                                : null,
                            categories: categories,
                          );
                        }
                        if (!workWithChoosedFilter) {
                          homeBloc.add(
                            ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser: GetProductFiltersModel(
                                  filters: prevChoosedOrAppliedFilterToAddToIt),
                            ),
                          );
                          homeBloc.add(
                            GetProductsWithFiltersEvent(
                              searchText: controller?.text,
                              fromSearch: fromSearch,
                              boutiqueSlug: boutiqueSlug,
                              category: category,
                              offset: 1,
                            ),
                          );
                        } else {
                          homeBloc.add(ChangeSelectedFiltersEvent(
                            fromHomePageSearch: fromSearch,
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersChoosedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt),
                          ));
                        }
                      },
                    )
                  : SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
