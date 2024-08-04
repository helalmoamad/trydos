import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';

import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/features/search/presentation/widgets/search_Circle_boutique.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_brand.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_category.dart';

import 'package:trydos/features/search/presentation/widgets/trendig_section.dart';

import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/utils/theme_state.dart';

import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';

import '../../../app/my_cached_network_image.dart';
import '../../../home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing_model;
import '../../../home/presentation/manager/home_bloc.dart';

import '../../../home/presentation/widgets/product_listing/filters_normal_list.dart';
import '../../../home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import '../widgets/search_history.dart';
import '../widgets/search_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(
      {super.key,
      required this.buildSearchResult,
      required this.appearTrendingAndHistory,
      required this.controller});

  final TextEditingController controller;

  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ThemeState<SearchPage> {
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<bool> hideAppleyResetButtom = ValueNotifier(true);

  late final AppBloc appBloc;
  late final HomeBloc homeBloc;

  @override
  void initState() {
    BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent(
        fromHomePageSearch: true,
        boutiqueSlug: 'search',
        resetAppliesFilters: true,
        filtersChoosedByUser: null));
    widget.appearTrendingAndHistory.value = true;
    widget.controller.addListener(() {
      if (widget.controller.text.length > 2) {
        hideAppleyResetButtom.value = false;
      }
    });
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }
  String key = 'search';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) {
        appBloc.add(ChangeBasePage(0));
        appBloc.add(HideBottomNavigationBar(false));
      },
      child: Scaffold(
        backgroundColor: colorScheme.white,
        body: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            return previous.searchHistory != current.searchHistory ||
                previous.getProductFiltersStatus !=
                    current.getProductFiltersStatus ||
                previous.countOfProductExpectedByFiltering !=
                    current.countOfProductExpectedByFiltering ||
                previous.getProductListingWithFiltersPaginationModels[key]
                    ?.paginationStatus !=
                    current.getProductListingWithFiltersPaginationModels[key]
                        ?.paginationStatus;
          },
          builder: (context, state) {
            return SafeArea(
                child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    controller: scrollController,
                    scrollBehavior: const CupertinoScrollBehavior(),
                    slivers: [
                  SliverToBoxAdapter(child: 50.verticalSpace),
                  ValueListenableBuilder<int>(
                      valueListenable: widget.buildSearchResult,
                      builder: (context, value, _) {
                        return SliverMainAxisGroup(slivers: [
                          ValueListenableBuilder<bool>(
                              valueListenable: widget.appearTrendingAndHistory,
                              child: SearchHistory(
                                controller: widget.controller,
                                buildSearchResult: widget.buildSearchResult,
                                appearTrendingAndHistory:
                                    widget.appearTrendingAndHistory,
                                items: state.searchHistory ?? [],
                              ),
                              builder: (context, appear, child) {
                                return SliverToBoxAdapter(
                                  child: appear ? child! : SizedBox.shrink(),
                                );
                              }),
                          ValueListenableBuilder<bool>(
                              valueListenable: widget.appearTrendingAndHistory,
                              child: TrendingSection(),
                              builder: (context, appear, child) {
                                return SliverToBoxAdapter(
                                  child: Visibility(
                                    visible: appear,
                                    child: child!,
                                  ),
                                );
                              }),
                        ]);
                      }),
                  SliverToBoxAdapter(
                    child: SearchResult(
                      controller: widget.controller,
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: SizedBox(
                    height: state
                                .getProductListingWithFiltersPaginationModels[key] ==
                            null
                        ? 250.h
                        : state.getProductListingWithFiltersPaginationModels[key]!
                                .items.isNullOrEmpty
                            ? 250.h
                            : 150.h,
                  )),
                  if (state.getProductFiltersStatus ==
                          GetProductFiltersStatus.loading &&
                      state.getProductFiltersModel[key]?.filters == null)
                    SliverToBoxAdapter(
                        child: Center(
                      child: TrydosLoader(),
                    )),
                  if (!(state.getProductFiltersModel[key]?.filters?.brands
                          .isNullOrEmpty ??
                      true))
                    ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipBrand(
                          isLoading: state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state.getProductListingWithFiltersPaginationModels[key]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: 'Brands',
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(
                              visible: appear,
                              child: child!,
                            ),
                          );
                        }),
                  if (!(state.getProductFiltersModel[key]?.filters?.categories
                          .isNullOrEmpty ??
                      true))
                    ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipCategory(
                          isLoading: state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state.getProductListingWithFiltersPaginationModels[key]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: 'Category',
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(
                              visible: appear,
                              child: child!,
                            ),
                          );
                        }),
                  if (!(state.getProductFiltersModel[key]?.filters?.boutiques
                          .isNullOrEmpty ??
                      true))
                    ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipBoutique(
                          isLoading: state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state.getProductListingWithFiltersPaginationModels[key]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: "Boutique",
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(
                              visible: appear,
                              child: child!,
                            ),
                          );
                        }),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      Filter? filters;
                      filters = state.choosedFiltersByUser[key]?.filters;
                      if ((filters?.brands.isNullOrEmpty ?? true) &&
                          (filters?.categories.isNullOrEmpty ?? true) &&
                          (filters?.boutiques.isNullOrEmpty ?? true)) {
                        return SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 20.0),
                              child: MyTextWidget(
                                'Choosed Filters:',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyText2?.rq.copyWith(
                                    color: Colors.black,
                                    letterSpacing: 0,
                                    height: 1.25),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade300),
                              height: 30,
                              width: 1.sw,
                              child: ListView(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    if (!(filters?.categories.isNullOrEmpty ??
                                        true)) ...{
                                      Center(
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    },
                                    SizedBox(
                                        height: 28,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              filters?.categories?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                List<
                                                        product_listing_model
                                                        .Category>
                                                    newCategories =
                                                    filters?.categories ?? [];
                                                newCategories.removeAt(index);
                                                GetProductFiltersModel
                                                    newGetProductFiltersModel =
                                                    GetProductFiltersModel(
                                                        filters: filters
                                                            ?.copyWithSaveOtherField(
                                                                categories:
                                                                    newCategories));
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(
                                                        ChangeSelectedFiltersEvent(
                                                          fromHomePageSearch: true,
                                                  boutiqueSlug: key,
                                                  filtersChoosedByUser:
                                                      newGetProductFiltersModel,
                                                ));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FilterImage(
                                                    width: filters!
                                                            .categories![index]
                                                            .isSubCategory
                                                        ? 15
                                                        : 20,
                                                    height: filters
                                                            .categories![index]
                                                            .isSubCategory
                                                        ? 15
                                                        : 20,
                                                    imageUrl: filters
                                                        .categories![index]
                                                        .mostViewedProductThumbnail!
                                                        .filePath
                                                        .toString(),
                                                    withInnerShadow: true,
                                                    withBackGroundShadow: false,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    filters
                                                        .categories![index].name
                                                        .toString(),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: context
                                                        .textTheme.caption?.rq
                                                        .copyWith(
                                                            color: Color(
                                                                0xff8E8E8E),
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
                                    SizedBox(
                                      width: 5,
                                    ),
                                    if (!(filters?.boutiques.isNullOrEmpty ??
                                        true)) ...{
                                      Center(
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    },
                                    SizedBox(
                                      width: 5,
                                    ),
                                    SizedBox(
                                        height: 28,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              filters?.boutiques?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                List<Boutique> newBoutiques =
                                                    filters?.boutiques ?? [];
                                                newBoutiques.removeAt(index);
                                                GetProductFiltersModel
                                                    newGetProductFiltersModel =
                                                    GetProductFiltersModel(
                                                        filters: filters
                                                            ?.copyWithSaveOtherField(
                                                                boutiques:
                                                                    newBoutiques));
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(
                                                        ChangeSelectedFiltersEvent(
                                                          fromHomePageSearch: true,
                                                  boutiqueSlug: key,
                                                  filtersChoosedByUser:
                                                      newGetProductFiltersModel,
                                                ));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MyCachedNetworkImage(
                                                    imageUrl: filters!
                                                        .boutiques![index]
                                                        .banner!
                                                        .filePath!,
                                                    imageFit: BoxFit.cover,
                                                    height: 40,
                                                    width: 60,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                    if (!(filters?.brands.isNullOrEmpty ??
                                        true)) ...{
                                      Center(
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    },
                                    SizedBox(
                                        height: 28,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              filters?.brands?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                List<Brand> newBrands =
                                                    filters!.brands ?? [];
                                                newBrands.removeAt(index);
                                                GetProductFiltersModel
                                                    newGetProductFiltersModel =
                                                    GetProductFiltersModel(
                                                        filters: filters
                                                            .copyWithSaveOtherField(
                                                                brands:
                                                                    newBrands));
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(
                                                        ChangeSelectedFiltersEvent(
                                                          fromHomePageSearch: true,
                                                  boutiqueSlug: key,
                                                  filtersChoosedByUser:
                                                      newGetProductFiltersModel,
                                                ));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FilterImage(
                                                    width: 20,
                                                    height: 20,
                                                    imageUrl: filters!
                                                        .brands![index].image
                                                        .toString(),
                                                    isSvg: true,
                                                    withInnerShadow: true,
                                                    withBackGroundShadow: false,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    filters.brands![index].name
                                                        .toString(),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: context
                                                        .textTheme.caption?.rq
                                                        .copyWith(
                                                            color: Color(
                                                                0xff8E8E8E),
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
                                  ]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      Filter? filters;
                      filters = state.appliedFiltersByUser[key]?.filters;
                      if ((filters?.brands.isNullOrEmpty ?? true) &&
                          (filters?.categories.isNullOrEmpty ?? true) &&
                          (filters?.boutiques.isNullOrEmpty ?? true)) {
                        return SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 20.0),
                              child: MyTextWidget(
                                'Applied Filters:',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyText2?.rq.copyWith(
                                    color: Colors.black,
                                    letterSpacing: 0,
                                    height: 1.25),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade300),
                              height: 30,
                              width: 1.sw,
                              child: ListView(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    if (!(filters?.categories.isNullOrEmpty ??
                                        true)) ...{
                                      Center(
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    },
                                    SizedBox(
                                        height: 28,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              filters?.categories?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                List<
                                                        product_listing_model
                                                        .Category>
                                                    newCategories =
                                                    filters?.categories ?? [];
                                                newCategories.removeAt(index);
                                                GetProductFiltersModel
                                                    newGetProductFiltersModel =
                                                    GetProductFiltersModel(
                                                        filters: filters
                                                            ?.copyWithSaveOtherField(
                                                          prices: filters.prices,
                                                                searchText: filters.searchText,
                                                                categories:
                                                                    newCategories));
                                                homeBloc.add(
                                                    ChangeAppliedFiltersEvent(
                                                      boutiqueSlug: key,
                                                        filtersAppliedByUser:
                                                            newGetProductFiltersModel));
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(
                                                        GetProductsWithFiltersEvent(
                                                  fromSearch: true,
                                                  boutiqueSlug: key,
                                                  searchText:
                                                      widget.controller.text,
                                                  offset: 1,
                                                ));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FilterImage(
                                                    width: filters!
                                                            .categories![index]
                                                            .isSubCategory
                                                        ? 15
                                                        : 20,
                                                    height: filters
                                                            .categories![index]
                                                            .isSubCategory
                                                        ? 15
                                                        : 20,
                                                    imageUrl: filters
                                                        .categories![index]
                                                        .mostViewedProductThumbnail!
                                                        .filePath
                                                        .toString(),
                                                    withInnerShadow: true,
                                                    withBackGroundShadow: false,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    filters
                                                        .categories![index].name
                                                        .toString(),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: context
                                                        .textTheme.caption?.rq
                                                        .copyWith(
                                                            color: Color(
                                                                0xff8E8E8E),
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
                                    SizedBox(
                                      width: 5,
                                    ),
                                    if (!(filters?.boutiques.isNullOrEmpty ??
                                        true)) ...{
                                      Center(
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    },
                                    SizedBox(
                                      width: 5,
                                    ),
                                    SizedBox(
                                        height: 28,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              filters?.boutiques?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                List<Boutique> newBoutiques =
                                                    filters?.boutiques ?? [];
                                                newBoutiques.removeAt(index);
                                                GetProductFiltersModel
                                                    newGetProductFiltersModel =
                                                    GetProductFiltersModel(
                                                        filters: filters
                                                            ?.copyWithSaveOtherField(
                                                            prices: filters.prices,
                                                            searchText: filters.searchText,
                                                                boutiques:
                                                                    newBoutiques));
                                                homeBloc.add(
                                                ChangeAppliedFiltersEvent(
                                                  boutiqueSlug: key,
                                                filtersAppliedByUser:
                                                newGetProductFiltersModel));
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(GetProductsWithFiltersEvent(
                                                        fromSearch: true,
                                                        boutiqueSlug: key,
                                                        searchText: widget
                                                            .controller.text,
                                                        offset: 1,
                                                        ));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MyCachedNetworkImage(
                                                    imageUrl: filters!
                                                        .boutiques![index]
                                                        .banner!
                                                        .filePath!,
                                                    imageFit: BoxFit.cover,
                                                    height: 40,
                                                    width: 60,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                    if (!(filters?.brands.isNullOrEmpty ??
                                        true)) ...{
                                      Center(
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    },
                                    SizedBox(
                                        height: 28,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              filters?.brands?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                List<Brand> newBrands =
                                                    filters!.brands ?? [];
                                                newBrands.removeAt(index);
                                                GetProductFiltersModel
                                                    newGetProductFiltersModel =
                                                    GetProductFiltersModel(
                                                        filters: filters
                                                            .copyWithSaveOtherField(
                                                            prices: filters.prices,
                                                            searchText: filters.searchText,
                                                                brands:
                                                                    newBrands));
                                                homeBloc.add(
                                                ChangeAppliedFiltersEvent(
                                                  boutiqueSlug: key,
                                                filtersAppliedByUser:
                                                newGetProductFiltersModel));
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(GetProductsWithFiltersEvent(
                                                        fromSearch: true,
                                                        boutiqueSlug: key,
                                                        searchText: widget
                                                            .controller.text,
                                                        offset: 1,
                                                        ));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FilterImage(
                                                    width: 20,
                                                    height: 20,
                                                    imageUrl: filters!
                                                        .brands![index].image
                                                        .toString(),
                                                    isSvg: true,
                                                    withInnerShadow: true,
                                                    withBackGroundShadow: false,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    filters.brands![index].name
                                                        .toString(),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: context
                                                        .textTheme.caption?.rq
                                                        .copyWith(
                                                            color: Color(
                                                                0xff8E8E8E),
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
                                  ]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      Filter? choosedFilterToAddToIt =
                          state.choosedFiltersByUser[key]?.filters;
                      if (choosedFilterToAddToIt == null &&
                          widget.controller.text.length < 3) {
                        return SliverToBoxAdapter(child: SizedBox.shrink());
                      }

                      return SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(
                              bottom: !hideAppleyResetButtom.value ? 0 : 30,
                              left: 20,
                              right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () {
                                    widget.controller.text = '';
                                    homeBloc.add(ChangeAppliedFiltersEvent(
                                      boutiqueSlug: key,
                                      filtersAppliedByUser: state.choosedFiltersByUser[key],
                                    ));
                                    homeBloc.add(GetProductsWithFiltersEvent(
                                        offset: 1,
                                        getWithPagination: false,
                                        boutiqueSlug: key,
                                        fromSearch: true,
                                        searchText: widget.controller.text));
                                    HelperFunctions.slidingNavigation(
                                        context,
                                        ProductListingPage(
                                          searchText: widget.controller.text,
                                          boutiqueIcon: "",
                                          fromSearch: true,
                                          withSlidingImages: false,
                                          boutiqueSlug: key,
                                        ));
                                  },
                                  child: Container(
                                    height: 65,
                                    decoration: BoxDecoration(
                                        color: Color(0xffFF5F61),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: Offset(0, 3)),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyTextWidget(
                                                'Search ',
                                                style: textTheme.headline6?.rq
                                                    .copyWith(
                                                        color:
                                                            Color(0xffFEFEFE),
                                                        height: 23 / 18),
                                              ),
                                              state.countOfProductExpectedByFiltering !=
                                                      null
                                                  ? MyTextWidget(
                                                      "(${state.countOfProductExpectedByFiltering} products)",
                                                      style: textTheme
                                                          .subtitle1?.rq
                                                          .copyWith(
                                                              color: Color(
                                                                  0xffFEFEFE),
                                                              height: 23 / 18),
                                                    )
                                                  : SizedBox.shrink()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    homeBloc.add(GetProductFiltersEvent(
                                      filtersChoosedByUser: null,
                                      resetAppliesFilters: true,
                                      boutiqueSlug: key,
                                      fromHomePageSearch: true
                                    ));
                                    widget.controller.clear();
                                  },
                                  child: Container(
                                    height: 65,
                                    decoration: BoxDecoration(
                                        color: colorScheme.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: Offset(0, 3)),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                        border: Border.all(
                                            color: Color(0xff388CFF))),
                                    child: Center(
                                      child: MyTextWidget(
                                        'Reset',
                                        style: textTheme.headline6?.rq.copyWith(
                                            color: Color(0xff388CFF),
                                            height: 23 / 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ]));
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
