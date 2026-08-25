import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';

import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';

import '../../../data/models/get_product_filters_model.dart';
import 'package:trydos/common/helper/dev_log.dart';

import '../../../data/models/get_product_listing_with_filters_model.dart'
    hide Color;

class CategoriesFilterList extends StatelessWidget {
  const CategoriesFilterList({
    super.key,
    required this.expandingFiltersStack,
    required this.workWithChoosedFilter,
    required this.boutiqueSlug,
    required this.filterss,
    this.category,
    required this.scaleTheTopItemInFiltersStack,
    this.fromSearch = false,
    this.controller,
  });

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
    BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    String key = boutiqueSlug + (category ?? '');
    if (kDebugMode)
      devLog(
        "##############################################################${key}",
      );
    if (fromSearch) {
      key = boutiqueSlug;
    }
    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
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
          expandingFiltersStack.value = -1;
        }
        devLog("eeee<${filters.categories?.length ?? 0}");

        return ListView.builder(
          scrollDirection: Axis.horizontal,

          addSemanticIndexes: false,

          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filters.categories?.length ?? 0,
          itemBuilder: (ctx, index) {
            if (!workWithChoosedFilter
                ? ((appliedFilters?.categories?.isNullOrEmpty ?? true)
                      ? false
                      : appliedFilters!.categories!.any(
                          (element) =>
                              element.id == filters.categories![index].id,
                        ))
                : ((choosedFilters?.categories?.isNullOrEmpty ?? true)
                      ? false
                      : choosedFilters!.categories!.any(
                          (element) =>
                              element.id == filters.categories![index].id,
                        ))) {
              expandingFiltersStack.value = index;
            }
            bool isChildCategorySlug = false;
            if (!(filters.categories![index].subCategories?.isNullOrEmpty ??
                true)) {
              List<SubCategory> subCategories = List.from(
                filters.categories![index].subCategories ?? [],
              );
              filters.categories![index].subCategories!.forEach((element) {
                subCategories.addAll(
                  element.childes?.map(
                        (e) => e.copyWith(isSubSubCategory: true),
                      ) ??
                      [],
                );
              });

              subCategories = subCategories.toSet().toList().reversed.toList();
              List<String> subCategoriesslugs = [];
              subCategories.forEach((element) {
                subCategoriesslugs.add(element.slug ?? "");
              });
              subCategories.removeWhere(
                (element) =>
                    subCategoriesslugs.contains(element.slug) &&
                    element.isSubSubCategory == false,
              );
              if (!(filters.categories?[index].isSubCategory ?? false)) {
                subCategories.forEach((elements) {
                  if (!(workWithChoosedFilter)) {
                    if (boutiqueBloc
                            .state
                            .appliedFiltersByUser[key]
                            ?.filters
                            ?.categories
                            ?.any(
                              (element) => (element.slug == elements.slug),
                            ) ??
                        false) {
                      isChildCategorySlug = true;
                    }
                  } else {
                    if (boutiqueBloc
                            .state
                            .choosedFiltersByUser[key]
                            ?.filters
                            ?.categories
                            ?.any(
                              (element) => (element.slug == elements.slug),
                            ) ??
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
                  devLog("${(currentExpandedIndex == index)}");
                  devLog("///////////////");
                  devLog("${isChildCategorySlug}");
                  return AnimatedContainer(
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsetsDirectional.only(end: 5.w),
                    width:
                        (currentExpandedIndex == index) || isChildCategorySlug
                        ? (75.w + subCategories.length * 55.w)
                        : 80.w,
                    height: 70.h,
                    child: Stack(
                      children: [
                        ...List.generate(
                          subCategories.length,
                          (innerIndex) => AnimatedPositionedDirectional(
                            curve: Curves.fastEaseInToSlowEaseOut,
                            duration: const Duration(milliseconds: 300),
                            top:
                                (currentExpandedIndex == index ||
                                    isChildCategorySlug)
                                ? subCategories[innerIndex].isSubSubCategory ??
                                          false
                                      ? 35.h
                                      : (20.h)
                                : (20.h) / 2,
                            end:
                                currentExpandedIndex == index ||
                                    isChildCategorySlug
                                ? innerIndex * 55.w
                                : innerIndex >= (subCategories.length - 2)
                                ? (innerIndex - 1) * 4.w
                                : 0,
                            child:
                                subCategories[innerIndex].flatPhotoPath != null
                                ? FilterCircleWidget(
                                    isSubSubCategory:
                                        subCategories[innerIndex]
                                            .isSubSubCategory ??
                                        false,
                                    width:
                                        subCategories[innerIndex]
                                                .isSubSubCategory ??
                                            false
                                        ? 35.w
                                        : 50.w,
                                    height:
                                        subCategories[innerIndex]
                                                .isSubSubCategory ??
                                            false
                                        ? 35.h
                                        : 50.h,
                                    originalWidth: double.tryParse(
                                      subCategories[innerIndex]
                                          .flatPhotoPath!
                                          .originalWidth
                                          .toString(),
                                    ),
                                    originalHeight: double.tryParse(
                                      subCategories[innerIndex]
                                          .flatPhotoPath!
                                          .originalHeight
                                          .toString(),
                                    ),
                                    categoryName: subCategories[innerIndex].name
                                        .toString(),
                                    imageUrl: subCategories[innerIndex]
                                        .flatPhotoPath!
                                        .filePath
                                        .toString(),
                                    withBackGroundShadow: innerIndex != 0,
                                    displayFilterMark: !workWithChoosedFilter
                                        ? ((appliedFilters
                                                      ?.categories
                                                      ?.isNullOrEmpty ??
                                                  true)
                                              ? false
                                              : appliedFilters!.categories!.any(
                                                  (element) =>
                                                      element.slug ==
                                                      subCategories[innerIndex]
                                                          .slug,
                                                ))
                                        : ((choosedFilters
                                                      ?.categories
                                                      ?.isNullOrEmpty ??
                                                  true)
                                              ? false
                                              : choosedFilters!.categories!.any(
                                                  (element) =>
                                                      element.slug ==
                                                      subCategories[innerIndex]
                                                          .slug,
                                                )),
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
                                            [],
                                      );

                                      if (add) {
                                        FirebaseAnalyticsService.logEventForSession(
                                          eventName:
                                              AnalyticsEventsConst.APPLY_FILTER,
                                          extraParams: {
                                            'filter_type': "category",
                                            'filter_value':
                                                subCategories[innerIndex]
                                                    .name ??
                                                "",
                                            'screen_name': GlobalScreenConst
                                                .PRODUCT_LISTING_SCREEN,
                                          },
                                          executedEventName:
                                              AnalyticsButtonsEventNameConst
                                                  .applyFilterButton,
                                        );
                                        // FirebaseAnalyticsService
                                        //     .logEventForSession(
                                        //   eventName: AnalyticsEventsConst
                                        //       .buttonClicked,
                                        //   executedEventName:
                                        //       AnalyticsButtonsEventNameConst
                                        //           .addFilterButton,
                                        // );
                                        //////////////////////////////
                                        // expandingFiltersStack.value =
                                        //   innerIndex;
                                        Category category = Category(
                                          slug: subCategories[innerIndex].slug,
                                          isSubCategory: true,
                                          id: subCategories[innerIndex].id,
                                          name: subCategories[innerIndex].name,
                                          flatPhotoPath:
                                              subCategories[innerIndex]
                                                  .flatPhotoPath,
                                        );
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
                                              filters.categories?[index].slug,
                                        );
                                        if (subCategories[innerIndex]
                                                .isSubSubCategory ??
                                            false) {
                                          categoryParent = [];
                                        }
                                        prevChoosedOrAppliedFilterToAddToIt =
                                            prevChoosedOrAppliedFilterToAddToIt
                                                .copyWithSaveOtherField(
                                                  prices:
                                                      prevChoosedOrAppliedFilterToAddToIt
                                                          .prices,
                                                  searchText: controller != null
                                                      ? controller!
                                                                    .text
                                                                    .length >
                                                                2
                                                            ? controller?.text
                                                            : null
                                                      : null,
                                                  categories:
                                                      categoryParent
                                                          .isNullOrEmpty
                                                      ? [category]
                                                      : [
                                                          ...categoryParent!,
                                                          category,
                                                        ],
                                                );
                                      } else {
                                        // FirebaseAnalyticsService
                                        //     .logEventForSession(
                                        //   eventName: AnalyticsEventsConst
                                        //       .buttonClicked,
                                        //   executedEventName:
                                        //       AnalyticsButtonsEventNameConst
                                        //           .resetByTapOnFilterButton,
                                        // );
                                        //////////////////////////////
                                        categories.removeWhere(
                                          ((element) =>
                                              element.id ==
                                              subCategories[innerIndex].id),
                                        );

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
                                                      ? controller!
                                                                    .text
                                                                    .length >
                                                                2
                                                            ? controller?.text
                                                            : null
                                                      : null,
                                                  categories: categories,
                                                );
                                      }
                                      if (!workWithChoosedFilter) {
                                        boutiqueBloc.add(
                                          ChangeAppliedFiltersEvent(
                                            category: category,
                                            boutiqueSlug: boutiqueSlug,
                                            filtersAppliedByUser:
                                                GetProductFiltersModel(
                                                  filters:
                                                      prevChoosedOrAppliedFilterToAddToIt,
                                                ),
                                          ),
                                        );
                                        boutiqueBloc.add(
                                          GetProductsWithFiltersEvent(
                                            searchText: controller?.text,
                                            fromSearch: fromSearch,
                                            boutiqueSlug: boutiqueSlug,
                                            category: category,
                                            offset: 1,
                                          ),
                                        );
                                      } else {
                                        boutiqueBloc.add(
                                          ChangeSelectedFiltersEvent(
                                            fromHomePageSearch: fromSearch,
                                            category: category,
                                            boutiqueSlug: boutiqueSlug,
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                  filters:
                                                      prevChoosedOrAppliedFilterToAddToIt,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    paddingValue:
                                        (currentExpandedIndex == index) ||
                                            isChildCategorySlug
                                        ? 3
                                        : 0,
                                    borderColor: const Color(0xff1D1D1D),
                                    isExpanded:
                                        (currentExpandedIndex == index) ||
                                        isChildCategorySlug,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: scaleTheTopItemInFiltersStack,
                          builder: (context, scale, _) {
                            return filters.categories![index].flatPhotoPath !=
                                    null
                                ? FilterCircleWidget(
                                    key: TestVariables.kTestMode == false
                                        ? null
                                        : Key(
                                            '${WidgetsKeys.categoryCircleWithSubProductListingFilterKey}$index',
                                          ),
                                    width: 70.w,
                                    height: 70.h,
                                    borderColor: const Color(0xff1D1D1D),
                                    isTopItem: true,
                                    originalWidth: double.tryParse(
                                      filters
                                          .categories![index]
                                          .flatPhotoPath!
                                          .originalWidth
                                          .toString(),
                                    ),
                                    originalHeight: double.tryParse(
                                      filters
                                          .categories![index]
                                          .flatPhotoPath!
                                          .originalHeight
                                          .toString(),
                                    ),
                                    categoryName: filters
                                        .categories![index]
                                        .name
                                        .toString(),
                                    imageUrl: filters
                                        .categories![index]
                                        .flatPhotoPath!
                                        .filePath
                                        .toString(),
                                    scale: scale,
                                    paddingValue: 2,
                                    isExpanded: (currentExpandedIndex == index),
                                    displayFilterMark: ((!workWithChoosedFilter
                                        ? ((appliedFilters
                                                      ?.categories
                                                      ?.isNullOrEmpty ??
                                                  true)
                                              ? false
                                              : appliedFilters!.categories!.any(
                                                  (element) =>
                                                      (element.slug ==
                                                      filters
                                                          .categories![index]
                                                          .slug),
                                                ))
                                        : ((choosedFilters
                                                      ?.categories
                                                      ?.isNullOrEmpty ??
                                                  true)
                                              ? false
                                              : choosedFilters!.categories!.any(
                                                  (element) =>
                                                      element.slug ==
                                                      filters
                                                          .categories![index]
                                                          .slug,
                                                )))),
                                    addOrRemoveSpecificFilter: (bool add) {
                                      if (kDebugMode)
                                        devLog(
                                          "addOrRemoveSpecificFilter${add}",
                                        );
                                      if (appliedFilters?.categories == null &&
                                          choosedFilters?.categories == null) {
                                        expandingFiltersStack.value = -1;
                                      } else if (!workWithChoosedFilter
                                          ? ((appliedFilters
                                                        ?.categories
                                                        ?.isNullOrEmpty ??
                                                    true)
                                                ? false
                                                : appliedFilters!.categories!.any(
                                                    (element) =>
                                                        element.id ==
                                                        filters
                                                            .categories![index]
                                                            .id,
                                                  ))
                                          : ((choosedFilters
                                                        ?.categories
                                                        ?.isNullOrEmpty ??
                                                    true)
                                                ? false
                                                : choosedFilters!.categories!.any(
                                                    (element) =>
                                                        element.id ==
                                                        filters
                                                            .categories![index]
                                                            .id,
                                                  ))) {
                                        if (kDebugMode)
                                          devLog(
                                            "111111111111111111111111111111qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq",
                                          );
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
                                            [],
                                      );

                                      if (add) {
                                        FirebaseAnalyticsService.logEventForSession(
                                          eventName:
                                              AnalyticsEventsConst.APPLY_FILTER,
                                          extraParams: {
                                            'filter_type': "category",
                                            'filter_value':
                                                filters
                                                    .categories![index]
                                                    .name ??
                                                "",
                                            'screen_name': GlobalScreenConst
                                                .PRODUCT_LISTING_SCREEN,
                                          },
                                          executedEventName:
                                              AnalyticsButtonsEventNameConst
                                                  .applyFilterButton,
                                        );
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
                                                  searchText: controller != null
                                                      ? controller!
                                                                    .text
                                                                    .length >
                                                                2
                                                            ? controller?.text
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
                                                          category,
                                                        ],
                                                );
                                      } else {
                                        // FirebaseAnalyticsService
                                        //     .logEventForSession(
                                        //   eventName: AnalyticsEventsConst
                                        //       .buttonClicked,
                                        //   executedEventName:
                                        //       AnalyticsButtonsEventNameConst
                                        //           .resetByTapOnFilterButton,
                                        // );
                                        ///////////////////////////////////////
                                        expandingFiltersStack.value = -1;
                                        categories.removeWhere(
                                          ((element) =>
                                              element.slug ==
                                              filters.categories![index].slug),
                                        );

                                        categories.removeWhere(
                                          ((element) => subCategories.any(
                                            (sub) => sub.id == element.id,
                                          )),
                                        );
                                        prevChoosedOrAppliedFilterToAddToIt =
                                            prevChoosedOrAppliedFilterToAddToIt!
                                                .copyWithSaveOtherField(
                                                  searchText: controller != null
                                                      ? controller!
                                                                    .text
                                                                    .length >
                                                                2
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
                                        if (kDebugMode)
                                          devLog(
                                            "dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
                                          );

                                        boutiqueBloc.add(
                                          ChangeAppliedFiltersEvent(
                                            category: category,
                                            boutiqueSlug: boutiqueSlug,
                                            filtersAppliedByUser:
                                                GetProductFiltersModel(
                                                  filters:
                                                      prevChoosedOrAppliedFilterToAddToIt,
                                                ),
                                          ),
                                        );

                                        boutiqueBloc.add(
                                          GetProductsWithFiltersEvent(
                                            searchText: controller?.text,
                                            fromSearch: fromSearch,
                                            boutiqueSlug: boutiqueSlug,
                                            category: category,
                                            offset: 1,
                                          ),
                                        );
                                      } else {
                                        boutiqueBloc.add(
                                          ChangeSelectedFiltersEvent(
                                            fromHomePageSearch: fromSearch,
                                            category: category,
                                            boutiqueSlug: boutiqueSlug,
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                  filters:
                                                      prevChoosedOrAppliedFilterToAddToIt,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return filters.categories![index].flatPhotoPath != null
                  ? FilterCircleWidget(
                      key: TestVariables.kTestMode == false
                          ? null
                          : Key(
                              '${WidgetsKeys.categoryCircleWithOutSubProductListingFilterKey}$index',
                            ),
                      width: 70.w,
                      height: 70.h,
                      borderColor: const Color(0xff1D1D1D),
                      imageUrl: filters
                          .categories![index]
                          .flatPhotoPath!
                          .filePath
                          .toString(),
                      categoryName: filters.categories![index].name.toString(),
                      displayFilterMark:
                          isChildCategorySlug || !workWithChoosedFilter
                          ? ((appliedFilters?.categories?.isNullOrEmpty ?? true)
                                ? false
                                : appliedFilters!.categories!.any(
                                    (element) =>
                                        element.slug ==
                                        filters.categories![index].slug,
                                  ))
                          : ((choosedFilters?.categories?.isNullOrEmpty ?? true)
                                ? false
                                : choosedFilters!.categories!.any(
                                    (element) =>
                                        element.slug ==
                                        filters.categories![index].slug,
                                  )),
                      addOrRemoveSpecificFilter: (bool add) {
                        Filter? prevChoosedOrAppliedFilterToAddToIt =
                            !workWithChoosedFilter
                            ? state.appliedFiltersByUser[key]?.filters
                            : state.choosedFiltersByUser[key]?.filters;
                        List<Category>? categories = List.of(
                          prevChoosedOrAppliedFilterToAddToIt?.categories ?? [],
                        );
                        if (add) {
                          FirebaseAnalyticsService.logEventForSession(
                            eventName: AnalyticsEventsConst.APPLY_FILTER,
                            extraParams: {
                              'filter_type': "category",
                              'filter_value':
                                  filters.categories![index].name ?? "",
                              'screen_name':
                                  GlobalScreenConst.PRODUCT_LISTING_SCREEN,
                            },
                            executedEventName: AnalyticsButtonsEventNameConst
                                .applyFilterButton,
                          );
                          Category category = filters.categories![index];
                          if (prevChoosedOrAppliedFilterToAddToIt == null) {
                            prevChoosedOrAppliedFilterToAddToIt = Filter();
                          }
                          prevChoosedOrAppliedFilterToAddToIt =
                              prevChoosedOrAppliedFilterToAddToIt
                                  .copyWithSaveOtherField(
                                    prices: prevChoosedOrAppliedFilterToAddToIt
                                        .prices,
                                    searchText: controller != null
                                        ? controller!.text.length > 2
                                              ? controller?.text
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
                                            category,
                                          ],
                                  );
                        } else {
                          // FirebaseAnalyticsService.logEventForSession(
                          //   eventName: AnalyticsEventsConst.buttonClicked,
                          //   executedEventName: AnalyticsButtonsEventNameConst
                          //       .resetByTapOnFilterButton,
                          // );
                          ////////////////////////////
                          categories.removeWhere(
                            ((element) =>
                                element.id == filters.categories![index].id),
                          );
                          prevChoosedOrAppliedFilterToAddToIt =
                              prevChoosedOrAppliedFilterToAddToIt!
                                  .copyWithSaveOtherField(
                                    prices: prevChoosedOrAppliedFilterToAddToIt
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
                          boutiqueBloc.add(
                            ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt,
                              ),
                            ),
                          );
                          boutiqueBloc.add(
                            GetProductsWithFiltersEvent(
                              searchText: controller?.text,
                              fromSearch: fromSearch,
                              boutiqueSlug: boutiqueSlug,
                              category: category,
                              offset: 1,
                            ),
                          );
                        } else {
                          boutiqueBloc.add(
                            ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt,
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
