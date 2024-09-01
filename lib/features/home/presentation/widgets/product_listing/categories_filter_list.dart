import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../data/models/get_product_filters_model.dart';
import '../../../data/models/get_product_listing_with_filters_model.dart';
import '../../manager/home_event.dart';

class CategoriesFilterList extends StatelessWidget {
  CategoriesFilterList(
      {super.key,
      required this.expandingFiltersStack,
      required this.workWithChoosedFilter,
      required this.boutiqueSlug,
      this.category,
      required this.scaleTheTopItemInFiltersStack,
      this.fromSearch = false,
      this.controller});

  final ValueNotifier<int> expandingFiltersStack;
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack;
  final bool workWithChoosedFilter;
  final bool fromSearch;
  final TextEditingController? controller;
  final String boutiqueSlug;
  final String? category;

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
    String key = boutiqueSlug + (category ?? '');
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        Filter filters = state.getProductFiltersModel[key]?.filters != null
            ? state.getProductFiltersModel[key]?.filters ?? Filter()
            : Filter();
        Filter? choosedFilters = state.choosedFiltersByUser[key]?.filters;
        Filter? appliedFilters = state.appliedFiltersByUser[key]?.filters;
        print(filters.categories?.length ?? 0);

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filters.categories?.length ?? 0,
          itemBuilder: (ctx, index) {
            bool isChildCategorySlug = false;
            if (!(filters.categories?[index].isSubCategory ?? false)) {
              filters.categories?[index].subCategories?.forEach((elements) {
                if (!(workWithChoosedFilter)) {
                  if (homeBloc
                          .state.appliedFiltersByUser[key]?.filters?.categories
                          ?.any((element) => (element.slug == elements.slug)) ??
                      false) {
                    isChildCategorySlug = true;
                  }
                } else {
                  if (homeBloc
                          .state.choosedFiltersByUser[key]?.filters?.categories
                          ?.any((element) => (element.slug == elements.slug)) ??
                      false) {
                    isChildCategorySlug = true;
                  }
                }
                ;
              });
            }
            if (!(filters.categories![index].subCategories?.isNullOrEmpty ??
                true))
              return ValueListenableBuilder<int>(
                  valueListenable: expandingFiltersStack,
                  builder: (context, currentExpandedIndex, child) {
                    return AnimatedContainer(
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsetsDirectional.only(end: 5),
                      width: (currentExpandedIndex == index) ||
                              isChildCategorySlug
                          ? (75 +
                              filters.categories![index].subCategories!.length *
                                  55)
                          : 80.0,
                      height: 70.0,
                      child: Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: [
                          ...List.generate(
                            filters.categories![index].subCategories!.length,
                            (innerIndex) => AnimatedPositionedDirectional(
                                curve: Curves.fastEaseInToSlowEaseOut,
                                duration: Duration(milliseconds: 300),
                                top: (currentExpandedIndex == index)
                                    ? (70 - 50)
                                    : (70 - 50) / 2,
                                end: (currentExpandedIndex == index)
                                    ? innerIndex * 30
                                    : innerIndex >=
                                            (filters.categories![index]
                                                    .subCategories!.length -
                                                2)
                                        ? (innerIndex - 1) * 3
                                        : 0,
                                child: filters
                                            .categories![index]
                                            .subCategories![innerIndex]
                                            .mostViewedProductThumbnail !=
                                        null
                                    ? FilterCircleWidget(
                                        isSvg: false,
                                        width: 50,
                                        height: 50,
                                        categoryName: filters.categories![index]
                                            .subCategories![innerIndex].name
                                            .toString(),
                                        imageUrl: filters
                                            .categories![index]
                                            .subCategories![innerIndex]
                                            .mostViewedProductThumbnail!
                                            .filePath
                                            .toString(),
                                        withBackGroundShadow: innerIndex != 0,
                                        displayFilterMark: !workWithChoosedFilter
                                            ? ((appliedFilters?.categories
                                                        ?.isNullOrEmpty ??
                                                    true)
                                                ? false
                                                : appliedFilters!.categories!
                                                    .any((element) =>
                                                        element.id ==
                                                        filters
                                                            .categories![index]
                                                            .subCategories![
                                                                innerIndex]
                                                            .id))
                                            : ((choosedFilters?.categories
                                                        ?.isNullOrEmpty ??
                                                    true)
                                                ? false
                                                : choosedFilters!.categories!
                                                    .any((element) =>
                                                        element.id ==
                                                        filters
                                                            .categories![index]
                                                            .subCategories![
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
                                            expandingFiltersStack.value =
                                                innerIndex;
                                            Category category = Category(
                                                slug: filters
                                                    .categories![index]
                                                    .subCategories![innerIndex]
                                                    .slug,
                                                isSubCategory: true,
                                                id: filters
                                                    .categories![index]
                                                    .subCategories![innerIndex]
                                                    .id,
                                                name: filters
                                                    .categories![index]
                                                    .subCategories![innerIndex]
                                                    .name,
                                                flatPhotoPath: filters
                                                    .categories![index]
                                                    .subCategories![innerIndex]
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
                                            categories.removeWhere(((element) =>
                                                element.id ==
                                                filters
                                                    .categories![index]
                                                    .subCategories![innerIndex]
                                                    .id));
                                            bool mustDeleteParentCategory =
                                                categories.any(((element) =>
                                                    filters.categories![index]
                                                        .subCategories!
                                                        .any((sub) =>
                                                            sub.id ==
                                                            element.id)));
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
                                            print(
                                                "***************dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

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
                                return filters.categories![index].mostViewedProductThumbnail !=
                                        null
                                    ? FilterCircleWidget(
                                        isSvg: false,
                                        width: 70,
                                        height: 70,
                                        categoryName: filters
                                            .categories![index].name
                                            .toString(),
                                        imageUrl: filters
                                            .categories![index]
                                            .mostViewedProductThumbnail!
                                            .filePath
                                            .toString(),
                                        scale: scale,
                                        paddingValue: 0,
                                        isExpanded:
                                            (currentExpandedIndex == index),
                                        displayFilterMark: (isChildCategorySlug ||
                                            (!workWithChoosedFilter
                                                ? ((appliedFilters?.categories?.isNullOrEmpty ?? true)
                                                    ? false
                                                    : appliedFilters!.categories!.any((element) =>
                                                        element.id ==
                                                        filters
                                                            .categories![index]
                                                            .id))
                                                : ((choosedFilters?.categories
                                                            ?.isNullOrEmpty ??
                                                        true)
                                                    ? false
                                                    : choosedFilters!.categories!
                                                        .any((element) => element.id == filters.categories![index].id)))),
                                        addOrRemoveSpecificFilter: (bool add) {
                                          if (appliedFilters?.categories ==
                                                  null &&
                                              choosedFilters?.categories ==
                                                  null) {
                                            expandingFiltersStack.value = 0;
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
                                            expandingFiltersStack.value = -1;
                                            categories.removeWhere(((element) =>
                                                element.id ==
                                                filters.categories![index].id));

                                            categories.removeWhere(((element) =>
                                                filters.categories![index]
                                                    .subCategories!
                                                    .any((sub) =>
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
            else {
              return filters.categories![index].mostViewedProductThumbnail !=
                      null
                  ? FilterCircleWidget(
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
                          print(
                              "qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqdddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

                          homeBloc.add(ChangeAppliedFiltersEvent(
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersAppliedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt),
                          ));
                          homeBloc.add(GetProductsWithFiltersEvent(
                              searchText: controller?.text,
                              fromSearch: fromSearch,
                              boutiqueSlug: boutiqueSlug,
                              category: category,
                              offset: 1));
                        } else {
                          homeBloc.add(ChangeSelectedFiltersEvent(
                            fromHomePageSearch: fromSearch,
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersChoosedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt),
                          ));
                        }
                      })
                  : SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
