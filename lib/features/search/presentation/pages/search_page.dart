import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
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

import '../../../../core/utils/theme_state.dart';

import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';

import '../../../home/presentation/manager/home_bloc.dart';

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
  final ValueNotifier<List<int>> selectBoutiqueSearch = ValueNotifier([]);
  final ValueNotifier<List<int>> selectBrandSearch = ValueNotifier([]);

  final ValueNotifier<List<int>> selectCategorySearch = ValueNotifier([]);

  late final AppBloc appBloc;
  late final HomeBloc homeBloc;
  @override
  void initState() {
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
          buildWhen: (previous, current) =>
              previous.searchHistory != current.searchHistory ||
              previous.getProductFiltersStatus !=
                  current.getProductFiltersStatus ||
              previous.countOfProductExpectedByFiltering !=
                  current.countOfProductExpectedByFiltering ||
              previous.selectedBoutiqueBrandCategorySlugsForSearch.values !=
                  current.selectedBoutiqueBrandCategorySlugsForSearch.values,
          builder: (context, state) {
            print(state.getProductFiltersStatus);
            hideAppleyResetButtom.value = state
                    .selectedBoutiqueBrandCategorySlugsForSearch.values
                    .toList()
                    .any((element) => !element.isEmpty) ||
                state.boutiques!.any((element) => element.isSelected!) ||
                state.categories!.any((element) => element.isSelected) ||
                state.brands!.any((element) => element.isSelected!) ||
                widget.controller.text.length > 2;
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
                                .getProductListingWithFiltersPaginationModels ==
                            null
                        ? 250.h
                        : state.getProductListingWithFiltersPaginationModels!
                                .items.isNullOrEmpty
                            ? 250.h
                            : 150.h,
                  )),
                  ValueListenableBuilder<bool>(
                      valueListenable: widget.appearTrendingAndHistory,
                      child: SearchChipBrand(
                        isLoading: state.getProductFiltersStatus ==
                            GetProductFiltersStatus.loading,
                        controller: widget.controller,
                        selectedBrand: selectBrandSearch,
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
                  ValueListenableBuilder<bool>(
                      valueListenable: widget.appearTrendingAndHistory,
                      child: SearchChipcategory(
                        isLoading: state.getProductFiltersStatus ==
                            GetProductFiltersStatus.loading,
                        controller: widget.controller,
                        selectedCategory: selectCategorySearch,
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
                  ValueListenableBuilder<bool>(
                      valueListenable: widget.appearTrendingAndHistory,
                      child: SearchChipBoutique(
                        isLoading: state.getProductFiltersStatus ==
                            GetProductFiltersStatus.loading,
                        controller: widget.controller,
                        selectedBoutique: selectBoutiqueSearch,
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
                  ValueListenableBuilder<bool>(
                      valueListenable: hideAppleyResetButtom,
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          Filter? AppliedFilterToAddToIt =
                              homeBloc.state.appliedFiltersByUser?.filters;
                          if (AppliedFilterToAddToIt == null) {
                            AppliedFilterToAddToIt = Filter();
                          }

                          AppliedFilterToAddToIt =
                              AppliedFilterToAddToIt.copyWithSaveOtherField(
                            categories: state.categories!
                                .where((element) => element.isSelected == true)
                                .toList(),
                            boutiques: state.boutiques!
                                .where((element) => element.isSelected == true)
                                .toList(),
                            brands: state.brands!
                                .where((element) => element.isSelected == true)
                                .toList(),
                            searchText: widget.controller.text,
                          );

                          return Container(
                            margin: EdgeInsets.only(
                                bottom: !hideAppleyResetButtom.value ? 0 : 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    homeBloc.add(GetProductsWithFiltersEvent(
                                        filtersAppliedByUser:
                                            GetProductFiltersModel(
                                                filters:
                                                    AppliedFilterToAddToIt),
                                        offset: 1,
                                        getWithPagination: false,
                                        fromSearch: true,
                                        searchText: widget.controller.text));
                                    HelperFunctions.slidingNavigation(
                                        context,
                                        ProductListingPage(
                                          searchText: widget.controller.text,
                                          boutiqueIcon: "",
                                          fromSearch: true,
                                          withSlidingImages: false,
                                          boutiqueSlug: '',
                                        ));
                                  },
                                  child: Container(
                                    width: 200,
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
                                          child: MyTextWidget(
                                            'Search',
                                            style: textTheme.headline6?.rq
                                                .copyWith(
                                                    color: Color(0xffFEFEFE),
                                                    height: 23 / 18),
                                          ),
                                        ),
                                        Positioned(
                                            right: 20,
                                            top: 10,
                                            child: Container(
                                                width: 30,
                                                height: 30,
                                                child: state.getProductFiltersStatus ==
                                                            GetProductFiltersStatus
                                                                .success &&
                                                        state.countOfProductExpectedByFiltering !=
                                                            0
                                                    ? MyTextWidget(
                                                        "(${state.countOfProductExpectedByFiltering})")
                                                    : SizedBox.shrink())),
                                        state.getProductFiltersStatus ==
                                                GetProductFiltersStatus.loading
                                            ? Positioned(
                                                right: 40,
                                                top: 28,
                                                child: Container(
                                                    width: 15,
                                                    height: 15,
                                                    child: Center(
                                                      child: TrydosLoader(
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    )))
                                            : SizedBox.shrink()
                                      ],
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        selectBoutiqueSearch.value = [];
                                        selectBrandSearch.value = [];
                                        selectCategorySearch.value = [];
                                        homeBloc.add(GetProductFiltersEvent());
                                        widget.controller.clear();
                                      },
                                      child: Container(
                                        width: 150,
                                        height: 65,
                                        decoration: BoxDecoration(
                                            color: colorScheme.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                              )
                                            ],
                                            border: Border.all(
                                                color: Color(0xff388CFF))),
                                        child: Center(
                                          child: MyTextWidget(
                                            'Reset',
                                            style: textTheme.headline6?.rq
                                                .copyWith(
                                                    color: Color(0xff388CFF),
                                                    height: 23 / 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      builder: (context, hide, child) {
                        return SliverToBoxAdapter(
                          child: Visibility(
                            visible: hide,
                            child: child!,
                          ),
                        );
                      }),
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
