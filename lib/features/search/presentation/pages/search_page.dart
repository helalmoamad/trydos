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
import '../../../../common/test_utils/test_var.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../home/presentation/manager/home_bloc.dart';
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
    BlocProvider.of<HomeBloc>(context).add(ChangeSelectedFiltersEvent(
        fromHomePageSearch: true,
        boutiqueSlug: 'search',
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

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.homeSearchScreen,
    );

    super.didChangeDependencies();
  }

  String key = 'search';

  @override
  void dispose() {
    homeBloc.add(ChangeAppliedFiltersEvent(
        boutiqueSlug: 'search',
        filtersAppliedByUser: null,
        resetAppliedFilters: true));
    homeBloc.add(ChangeSelectedFiltersEvent(
      fromHomePageSearch: true,
      boutiqueSlug: 'search',
      filtersChoosedByUser: null,
    ));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) {
        widget.controller.clear();
        appBloc.add(ChangeBasePage(0));
        homeBloc.add(ResetAllSelectedAppliedFilterEvent());
        appBloc.add(HideBottomNavigationBar(false));
        ///////////////////////////////
        FirebaseAnalyticsService.logEventForSession(
          eventName: AnalyticsEventsConst.buttonClicked,
          executedEventName: AnalyticsExecutedEventNameConst.backAppButton,
        );
      },
      child: Scaffold(
        backgroundColor: colorScheme.white,
        body: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            return previous.searchHistory != current.searchHistory ||
                previous.getProductFiltersStatus[key] !=
                    current.getProductFiltersStatus[key] ||
                previous.cashedOrginalBoutique !=
                    current.cashedOrginalBoutique ||
                previous.countOfProductExpectedByFiltering?.values !=
                    current.countOfProductExpectedByFiltering?.values ||
                previous
                        .getProductListingWithFiltersPaginationModels['search' +
                            (current.cashedOrginalBoutique
                                ? 'withoutFilter'
                                : "")]
                        ?.paginationStatus !=
                    current
                        .getProductListingWithFiltersPaginationModels['search' +
                            (current.cashedOrginalBoutique
                                ? 'withoutFilter'
                                : "")]
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
                    height: state.getProductListingWithFiltersPaginationModels[
                                'search' +
                                    (state.cashedOrginalBoutique
                                        ? 'withoutFilter'
                                        : "")] ==
                            null
                        ? 250.h
                        : state
                                .getProductListingWithFiltersPaginationModels[
                                    'search' +
                                        (state.cashedOrginalBoutique
                                            ? 'withoutFilter'
                                            : "")]!
                                .items
                                .isNullOrEmpty
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
                              GetProductFiltersStatus.loading,
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
                              GetProductFiltersStatus.loading,
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
                              GetProductFiltersStatus.loading,
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
                      return SliverToBoxAdapter(
                        child: ((state.choosedFiltersByUser[key]?.filters
                                            ?.attributes?.isNullOrEmpty ??
                                        true) &&
                                    (state.choosedFiltersByUser[key]?.filters
                                            ?.colors?.isNullOrEmpty ??
                                        true) &&
                                    (state.choosedFiltersByUser[key]?.filters
                                            ?.brands?.isNullOrEmpty ??
                                        true) &&
                                    (state.choosedFiltersByUser[key]?.filters
                                            ?.boutiques?.isNullOrEmpty ??
                                        true) &&
                                    (state.choosedFiltersByUser[key]?.filters
                                            ?.categories?.isNullOrEmpty ??
                                        true) &&
                                    ((state.appliedFiltersByUser[key]?.filters
                                                ?.searchText?.isEmpty ??
                                            true) ||
                                        (state.appliedFiltersByUser[key]?.filters?.searchText?.length ?? 0) < 2) &&
                                    (state.choosedFiltersByUser[key]?.filters?.prices?.maxPrice == null) &&
                                    (state.choosedFiltersByUser[key]?.filters?.prices?.minPrice == null)) &&
                                widget.controller.text.length < 3
                            ? SizedBox.shrink()
                            : Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade300),
                                height: 30,
                                width: 1.sw,
                                child: choosedOrAppliedFiltersWidget(
                                  controller: widget.controller,
                                  boutiqueSlug: 'search',
                                  context: context,
                                  choosedFilter: true,
                                  fromSearch: true,
                                ),
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
                              top: 20,
                              right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () {
                                    Filter filters = state
                                            .choosedFiltersByUser[key]
                                            ?.filters ??
                                        Filter();
                                    String text = widget.controller.text;

                                    homeBloc.add(ChangeAppliedFiltersEvent(
                                      boutiqueSlug: key,
                                      filtersAppliedByUser:
                                          GetProductFiltersModel(
                                              filters: filters
                                                  .copyWithSaveOtherField(
                                                      searchText: text,
                                                      prices: filters.prices)),
                                    ));
                                    homeBloc.add(GetProductsWithFiltersEvent(
                                        offset: 1,
                                        boutiqueSlug: key,
                                        fromSearch: true,
                                        searchText: text));
                                    HelperFunctions.slidingNavigation(
                                      context,
                                      ProductListingPage(
                                        controllerFormSearchPage:
                                            widget.controller,
                                        searchText: text,
                                        boutiqueIcon: "",
                                        fromSearch: true,
                                        withSlidingImages: false,
                                        boutiqueSlug: key,
                                      ),
                                    );
                                    /////////////////////////////////
                                    FirebaseAnalyticsService.logEventForSession(
                                      eventName:
                                          AnalyticsEventsConst.buttonClicked,
                                      executedEventName:
                                          AnalyticsExecutedEventNameConst
                                              .applyHomeSearchResultButton,
                                    );
                                  },
                                  child: Container(
                                    height: 65,
                                    key: TestVariables.kTestMode
                                        ? Key(WidgetsKey
                                            .searchButtonInSearchPageKey)
                                        : null,
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
                                                style: textTheme.bodyLarge?.rq
                                                    .copyWith(
                                                        color:
                                                            Color(0xffFEFEFE),
                                                        height: 23 / 18),
                                              ),
                                              state.countOfProductExpectedByFiltering?[
                                                          'search'] !=
                                                      null
                                                  ? MyTextWidget(
                                                      "(${state.countOfProductExpectedByFiltering?['search']} products)",
                                                      style: textTheme
                                                          .bodyMedium?.rq
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
                                    homeBloc.add(ChangeAppliedFiltersEvent(
                                        boutiqueSlug: key,
                                        filtersAppliedByUser: null,
                                        resetAppliedFilters: true));
                                    homeBloc.add(ChangeSelectedFiltersEvent(
                                      boutiqueSlug: key,
                                      fromHomePageSearch: true,
                                      filtersChoosedByUser: null,
                                    ));
                                    widget.controller.clear();
                                    /////////////////////////////////
                                    FirebaseAnalyticsService.logEventForSession(
                                      eventName:
                                          AnalyticsEventsConst.buttonClicked,
                                      executedEventName:
                                          AnalyticsExecutedEventNameConst
                                              .resetHomeSearchButton,
                                    );
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
                                        style: textTheme.bodyLarge?.rq.copyWith(
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

  int get numberOfFields => 1;
}
