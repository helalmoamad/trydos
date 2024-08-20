/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/data/models/get_product_filters_model.dart';
import '../../../home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing;
import '../../../home/presentation/widgets/product_listing/categories_filter_list.dart';

class SearchChipCategory extends StatefulWidget {
  final String title;
  final bool isLoading;
  final TextEditingController controller;

  const SearchChipCategory(
      {Key? key,
      required this.title,
      required this.controller,
      required this.isLoading})
      : super(key: key);

  @override
  State<SearchChipCategory> createState() => _SearchChipCategoryState();
}

class _SearchChipCategoryState extends State<SearchChipCategory> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedCategorySlugs = [];

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String key = 'search';
        Filter filters = state.getProductFiltersModel[key]?.filters ?? Filter();
        int visible = filters.categories?.length ?? 0;
        return visible > 0
            ? Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xffC4C2C2), width: 0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyTextWidget(
                            widget.title,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                                color: Color(0xff505050), height: 15 / 12),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          widget.isLoading
                              ? Container(
                                  width: 15,
                                  height: 15,
                                  child: Center(
                                    child: TrydosLoader(
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ))
                              : SizedBox.shrink(),
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.backArrowArabic,
                            matchTextDirection: true,
                            color: Color(0xffC4C2C2),
                            width: 10,
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 90,
                      child: ScrollConfiguration(
                          behavior: CupertinoScrollBehavior(),
                          child: CategoriesFilterList(
                            controller: widget.controller,
                            boutiqueSlug: 'search',
                            fromSearch: true,
                            expandingFiltersStack: expandingFiltersStack,
                            scaleTheTopItemInFiltersStack:
                                scaleTheTopItemInFiltersStack,
                            workWithChoosedFilter: true,
                          )),
                    ),
                  ],
                ))
            : SizedBox.shrink();
      },
    );
  }
}*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/string.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/svg_network_widget.dart';

import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/data/models/get_product_filters_model.dart';
import '../../../home/data/models/get_product_listing_with_filters_model.dart'
    as Categories;
import '../../../home/presentation/widgets/product_listing/product_listing_filter_list.dart';

class SearchChipCategory extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isLoading;
  const SearchChipCategory(
      {Key? key,
      required this.title,
      required this.controller,
      required this.isLoading})
      : super(key: key);

  @override
  State<SearchChipCategory> createState() => _SearchChipCategoryState();
}

class _SearchChipCategoryState extends State<SearchChipCategory> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedCaregorySlugs = [];
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String key = 'search';
        Filter filters = state.getProductFiltersModel[key]?.filters ?? Filter();
        int visible = filters.categories?.length ?? 0;
        return visible > 0
            ? Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xffC4C2C2), width: 0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyTextWidget(
                            widget.title,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                                color: Color(0xff505050), height: 15 / 12),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          widget.isLoading
                              ? Container(
                                  width: 15,
                                  height: 15,
                                  child: Center(
                                    child: TrydosLoader(
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ))
                              : SizedBox.shrink(),
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.backArrowArabic,
                            matchTextDirection: true,
                            color: Color(0xffC4C2C2),
                            width: 10,
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      child: ScrollConfiguration(
                        behavior: CupertinoScrollBehavior(),
                        child: ListView.separated(
                            controller: scrollController,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              bool isChildCategorySlug = false;
                              filters.categories?[index]?.subCategories
                                  ?.forEach((elements) {
                                if (homeBloc.state.choosedFiltersByUser[key]
                                        ?.filters?.categories
                                        ?.any((element) =>
                                            (element.slug == elements.slug)) ??
                                    false) {
                                  isChildCategorySlug = true;
                                }
                                ;
                              });
                              bool isSelected = homeBloc
                                      .state
                                      .choosedFiltersByUser[key]
                                      ?.filters
                                      ?.categories
                                      ?.any((element) => (element.id ==
                                          filters.categories?[index].id)) ??
                                  false;
                              return Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Filter? prevChoosedFilterToAddToIt =
                                          homeBloc
                                              .state
                                              .choosedFiltersByUser[key]
                                              ?.filters;
                                      if (prevChoosedFilterToAddToIt == null) {
                                        prevChoosedFilterToAddToIt = Filter();
                                      }
                                      if (isSelected || isChildCategorySlug) {
                                        List<Categories.Category> category =
                                            prevChoosedFilterToAddToIt
                                                    .categories ??
                                                [];
                                        Categories.Category? categoryForSub =
                                            !category.isNullOrEmpty ||
                                                    category != []
                                                ? category.firstWhere(
                                                    (element) =>
                                                        element.id ==
                                                        filters
                                                            .categories?[index]
                                                            .id,
                                                    orElse: () =>
                                                        Categories.Category(),
                                                  )
                                                : Categories.Category();
                                        List<Categories.SubCategory>?
                                            subCategory =
                                            categoryForSub.subCategories;

                                        category.removeWhere((element) =>
                                            element.id ==
                                            filters.categories?[index].id);
                                        subCategory?.forEach((elements) {
                                          category.removeWhere((element) =>
                                              element.id == elements.id);
                                        });
                                        if (isChildCategorySlug) {
                                          category = [];
                                        }

                                        prevChoosedFilterToAddToIt =
                                            prevChoosedFilterToAddToIt
                                                .copyWithSaveOtherField(
                                          searchText:
                                              widget.controller.text.length > 2
                                                  ? widget.controller.text
                                                  : null,
                                          categories: category,
                                        );
                                      } else {
                                        prevChoosedFilterToAddToIt =
                                            prevChoosedFilterToAddToIt
                                                .copyWithSaveOtherField(
                                                    searchText: widget
                                                                .controller
                                                                .text
                                                                .length >
                                                            2
                                                        ? widget.controller.text
                                                        : null,
                                                    categories: [
                                              ...prevChoosedFilterToAddToIt
                                                      .categories ??
                                                  [],
                                              filters.categories![index]
                                            ]);
                                      }
                                      homeBloc.add(ChangeSelectedFiltersEvent(
                                          fromHomePageSearch: true,
                                          boutiqueSlug: key,
                                          filtersChoosedByUser:
                                              GetProductFiltersModel(
                                                  filters:
                                                      prevChoosedFilterToAddToIt)));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Color(0xffF8F8F8),
                                              border: Border.all(
                                                  color: isSelected ||
                                                          isChildCategorySlug
                                                      ? Color(0xffFF5F61)
                                                      : Color(0xffF8F8F8))),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          child: Row(
                                            children: [
                                              Center(
                                                  child: MyTextWidget(
                                                filters
                                                    .categories![index].name!,
                                                style: context
                                                    .textTheme.titleLarge?.rq
                                                    .copyWith(
                                                        height: 12 / 14,
                                                        color:
                                                            Color(0xff8D8D8D)),
                                              )),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: filters
                                                            .categories?[index]
                                                            .flatPhotoPath
                                                            ?.filePath !=
                                                        null
                                                    ? SvgNetworkWidget(
                                                        svgUrl: filters
                                                            .categories![index]
                                                            .flatPhotoPath!
                                                            .filePath!,
                                                        height: 15,
                                                      )
                                                    : SizedBox.shrink(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                            visible: isSelected ||
                                                isChildCategorySlug,
                                            child: FilterSelectedMark(
                                                width: 12, height: 12))
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: isSelected || isChildCategorySlug,
                                    child: SizedBox(
                                      height: 40,
                                      child: ScrollConfiguration(
                                        behavior: CupertinoScrollBehavior(),
                                        child: ListView.separated(
                                            controller: scrollController,
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, indexs) {
                                              bool isSubSelected = homeBloc
                                                      .state
                                                      .choosedFiltersByUser[key]
                                                      ?.filters
                                                      ?.categories
                                                      ?.any((element) =>
                                                          element.id ==
                                                          filters
                                                              .categories?[
                                                                  index]
                                                              .subCategories?[
                                                                  indexs]
                                                              .id) ??
                                                  false;
                                              return InkWell(
                                                onTap: () {
                                                  Filter?
                                                      prevChoosedFilterToAddToIt =
                                                      homeBloc
                                                          .state
                                                          .choosedFiltersByUser[
                                                              key]
                                                          ?.filters;
                                                  if (prevChoosedFilterToAddToIt ==
                                                      null) {
                                                    prevChoosedFilterToAddToIt =
                                                        Filter();
                                                  }
                                                  if (isSubSelected) {
                                                    List<Categories.Category>
                                                        subCategory =
                                                        prevChoosedFilterToAddToIt
                                                                .categories ??
                                                            [];
                                                    subCategory.removeWhere(
                                                        (element) =>
                                                            element.id ==
                                                            filters
                                                                .categories?[
                                                                    index]
                                                                .subCategories?[
                                                                    indexs]
                                                                .id);
                                                    prevChoosedFilterToAddToIt =
                                                        prevChoosedFilterToAddToIt
                                                            .copyWithSaveOtherField(
                                                      searchText: widget
                                                                  .controller
                                                                  .text
                                                                  .length >
                                                              2
                                                          ? widget
                                                              .controller.text
                                                          : null,
                                                      categories: subCategory,
                                                    );
                                                  } else {
                                                    List<Categories.Category>?
                                                        categoryParent =
                                                        prevChoosedFilterToAddToIt
                                                            .categories;
                                                    categoryParent?.removeWhere(
                                                        (element) =>
                                                            element.slug ==
                                                            filters
                                                                .categories?[
                                                                    index]
                                                                .slug);
                                                    prevChoosedFilterToAddToIt =
                                                        prevChoosedFilterToAddToIt
                                                            .copyWithSaveOtherField(
                                                                searchText: widget
                                                                            .controller
                                                                            .text
                                                                            .length >
                                                                        2
                                                                    ? widget
                                                                        .controller
                                                                        .text
                                                                    : null,
                                                                categories: [
                                                          ...categoryParent ??
                                                              [],
                                                          Categories.Category(
                                                              isSelected: true,
                                                              name: filters
                                                                  .categories?[
                                                                      index]
                                                                  .subCategories?[
                                                                      indexs]
                                                                  .name,
                                                              flatPhotoPath: filters
                                                                  .categories?[
                                                                      index]
                                                                  .subCategories?[
                                                                      indexs]
                                                                  .flatPhotoPath,
                                                              id: filters
                                                                  .categories?[
                                                                      index]
                                                                  .subCategories?[
                                                                      indexs]
                                                                  .id,
                                                              slug: filters
                                                                  .categories?[
                                                                      index]
                                                                  .subCategories?[
                                                                      indexs]
                                                                  .slug)
                                                        ]);
                                                  }
                                                  homeBloc.add(
                                                      ChangeSelectedFiltersEvent(
                                                          fromHomePageSearch:
                                                              true,
                                                          boutiqueSlug: key,
                                                          filtersChoosedByUser:
                                                              GetProductFiltersModel(
                                                                  filters:
                                                                      prevChoosedFilterToAddToIt)));
                                                },
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color:
                                                              Color(0xffF8F8F8),
                                                          border: Border.all(
                                                              color: isSubSelected
                                                                  ? Color(
                                                                      0xffFF5F61)
                                                                  : Color(
                                                                      0xffF8F8F8))),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0,
                                                              horizontal: 0),
                                                      child: Row(
                                                        children: [
                                                          Center(
                                                              child:
                                                                  MyTextWidget(
                                                            filters
                                                                .categories![
                                                                    index]
                                                                .subCategories![
                                                                    indexs]
                                                                .name!,
                                                            style: context
                                                                .textTheme
                                                                .titleLarge
                                                                ?.rq
                                                                .copyWith(
                                                                    height:
                                                                        12 / 14,
                                                                    color: Color(
                                                                        0xff8D8D8D)),
                                                          )),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            child: filters
                                                                        .categories![
                                                                            index]
                                                                        .subCategories![
                                                                            indexs]
                                                                        .flatPhotoPath
                                                                        ?.filePath !=
                                                                    null
                                                                ? SvgNetworkWidget(
                                                                    svgUrl: filters
                                                                        .categories![
                                                                            index]
                                                                        .subCategories![
                                                                            indexs]
                                                                        .flatPhotoPath!
                                                                        .filePath!,
                                                                    height: 15,
                                                                  )
                                                                : SizedBox
                                                                    .shrink(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Visibility(
                                                        visible: isSubSelected,
                                                        child:
                                                            FilterSelectedMark(
                                                                width: 12,
                                                                height: 12))
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return SizedBox(
                                                width: 10,
                                              );
                                            },
                                            itemCount: filters
                                                    .categories![index]
                                                    .subCategories
                                                    ?.length ??
                                                0),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: 10,
                              );
                            },
                            itemCount: filters.categories?.length ?? 0),
                      ),
                    ),
                  ],
                ))
            : SizedBox.shrink();
      },
    );
  }
}
