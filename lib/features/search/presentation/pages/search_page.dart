import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart'
    as listing_page;
import 'package:trydos/features/search/presentation/widgets/search_Circle_boutique.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_brand.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_category.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_related_category.dart';
import 'package:trydos/features/search/presentation/widgets/trendig_section.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/test_utils/test_var.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../home/presentation/manager/homeBloc/home_bloc.dart';
import '../../../home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import '../widgets/search_history.dart';
import '../widgets/search_result.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.buildSearchResult,
    required this.appearTrendingAndHistory,
    required this.isShowPanelForVerified,
    required this.controller,
  });

  final TextEditingController controller;

  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;
  final ValueNotifier<bool> isShowPanelForVerified;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ThemeState<SearchPage> {
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<bool> hideAppleyResetButtom = ValueNotifier(true);

  late final AppBloc appBloc;
  late final BoutiqueBloc boutiqueBloc;
  late final HomeBloc homeBloc;
  @override
  void initState() {
    LastPagesTracker.push('SearchPage');
    BlocProvider.of<BoutiqueBloc>(context).add(
      ChangeSelectedFiltersEvent(
        fromHomePageSearch: true,
        boutiqueSlug: 'search',
      ),
    );
    widget.appearTrendingAndHistory.value = true;
    widget.controller.addListener(() {
      if (widget.controller.text.length > 2) {
        hideAppleyResetButtom.value = false;
      }
    });

    appBloc = BlocProvider.of<AppBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    super.initState();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AnalyticsButtonsEventNameConst.HOME_SEARCH_BUTTON,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.SEARCH_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  String key = 'search';

  @override
  void dispose() {
    boutiqueBloc.add(
      ChangeAppliedFiltersEvent(
        boutiqueSlug: 'search',
        resetAppliedFilters: true,
      ),
    );
    boutiqueBloc.add(
      ChangeSelectedFiltersEvent(
        fromHomePageSearch: true,
        boutiqueSlug: 'search',
      ),
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Scaffold(
      backgroundColor: colorScheme.white,
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          return previous.searchHistory != current.searchHistory ||
              previous.popularSearchTerm?.length !=
                  current.popularSearchTerm?.length;
        },
        builder: (context, homeState) {
          return BlocBuilder<BoutiqueBloc, BoutiqueState>(
            buildWhen: (previous, current) {
              return previous.getProductFiltersStatus[key] !=
                      current.getProductFiltersStatus[key] ||
                  previous
                          .getProductListingWithFiltersPaginationModels[key]
                          ?.paginationStatus !=
                      current
                          .getProductListingWithFiltersPaginationModels[key]
                          ?.paginationStatus ||
                  previous.cashedOrginalBoutique !=
                      current.cashedOrginalBoutique ||
                  previous.countOfProductExpectedByFiltering?.values !=
                      current.countOfProductExpectedByFiltering?.values ||
                  previous.choosedFiltersByUser[key] !=
                      current.choosedFiltersByUser[key] ||
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
                        return SliverMainAxisGroup(
                          slivers: [
                            ValueListenableBuilder<bool>(
                              valueListenable: widget.appearTrendingAndHistory,
                              child: SearchHistory(
                                controller: widget.controller,
                                buildSearchResult: widget.buildSearchResult,
                                appearTrendingAndHistory:
                                    widget.appearTrendingAndHistory,
                                items: homeState.searchHistory ?? [],
                              ),
                              builder: (context, appear, child) {
                                return SliverToBoxAdapter(
                                  child: appear
                                      ? child!
                                      : const SizedBox.shrink(),
                                );
                              },
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: widget.appearTrendingAndHistory,
                              child: TrendingSection(
                                controller: widget.controller,
                                buildSearchResult: widget.buildSearchResult,
                                appearTrendingAndHistory:
                                    widget.appearTrendingAndHistory,
                                popularSearchTerms:
                                    homeState.popularSearchTerm ?? [],
                              ),
                              builder: (context, appear, child) {
                                return SliverToBoxAdapter(
                                  child: Visibility(
                                    visible: appear,
                                    child: child!,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: SearchResult(controller: widget.controller),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            state.getProductListingWithFiltersPaginationModels['search' +
                                    (state.cashedOrginalBoutique
                                        ? 'withoutFilter'
                                        : "")] ==
                                null
                            ? 250.h
                            : state
                                  .getProductListingWithFiltersPaginationModels['search' +
                                      (state.cashedOrginalBoutique
                                          ? 'withoutFilter'
                                          : "")]!
                                  .items
                                  .isNullOrEmpty
                            ? 250.h
                            : 150.h,
                      ),
                    ),
                    if (state.getProductFiltersStatus ==
                            GetProductFiltersStatus.loading &&
                        state.getProductFiltersModel[key]?.filters == null)
                      SliverToBoxAdapter(child: Center(child: TrydosLoader())),
                    if (!(state
                            .getProductFiltersModel[key]
                            ?.filters
                            ?.brands
                            .isNullOrEmpty ??
                        true))
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipBrand(
                          isLoading:
                              state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state
                                      .getProductListingWithFiltersPaginationModels[[
                                        'search' +
                                            (state.cashedOrginalBoutique
                                                ? 'withoutFilter'
                                                : ""),
                                      ]]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: LocaleKeys.Brands.tr(),
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(visible: appear, child: child!),
                          );
                        },
                      ),
                    if (!(state
                            .getProductFiltersModel[key]
                            ?.filters
                            ?.categories
                            .isNullOrEmpty ??
                        true))
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipCategory(
                          isLoading:
                              state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state
                                      .getProductListingWithFiltersPaginationModels[[
                                        'search' +
                                            (state.cashedOrginalBoutique
                                                ? 'withoutFilter'
                                                : ""),
                                      ]]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: LocaleKeys.categories.tr(),
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(visible: appear, child: child!),
                          );
                        },
                      ),

                    if (!(state
                            .getProductFiltersModel[key]
                            ?.filters
                            ?.relatedCategories
                            .isNullOrEmpty ??
                        true))
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipRelatedCategory(
                          isLoading:
                              state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state
                                      .getProductListingWithFiltersPaginationModels[[
                                        'search' +
                                            (state.cashedOrginalBoutique
                                                ? 'withoutFilter'
                                                : ""),
                                      ]]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: LocaleKeys.related_categories.tr(),
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(visible: appear, child: child!),
                          );
                        },
                      ),
                    if (!(state
                            .getProductFiltersModel[key]
                            ?.filters
                            ?.boutiques
                            .isNullOrEmpty ??
                        true))
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.appearTrendingAndHistory,
                        child: SearchChipBoutique(
                          isLoading:
                              state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading ||
                              state
                                      .getProductListingWithFiltersPaginationModels[[
                                        'search' +
                                            (state.cashedOrginalBoutique
                                                ? 'withoutFilter'
                                                : ""),
                                      ]]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading,
                          controller: widget.controller,
                          title: LocaleKeys.boutiques.tr(),
                        ),
                        builder: (context, appear, child) {
                          return SliverToBoxAdapter(
                            child: Visibility(visible: appear, child: child!),
                          );
                        },
                      ),
                    BlocBuilder<BoutiqueBloc, BoutiqueState>(
                      builder: (context, state) {
                        return SliverToBoxAdapter(
                          child:
                              ((state
                                              .choosedFiltersByUser[key]
                                              ?.filters
                                              ?.attributes
                                              ?.isNullOrEmpty ??
                                          true) &&
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
                                      ((state
                                                  .appliedFiltersByUser[key]
                                                  ?.filters
                                                  ?.searchText
                                                  ?.isEmpty ??
                                              true) ||
                                          (state
                                                      .appliedFiltersByUser[key]
                                                      ?.filters
                                                      ?.searchText
                                                      ?.length ??
                                                  0) <
                                              2) &&
                                      (state
                                              .choosedFiltersByUser[key]
                                              ?.filters
                                              ?.prices
                                              ?.maxPrice ==
                                          null) &&
                                      (state
                                              .choosedFiltersByUser[key]
                                              ?.filters
                                              ?.prices
                                              ?.minPrice ==
                                          null)) &&
                                  widget.controller.text.length < 3
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: EdgeInsets.all(5.h),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade300,
                                  ),
                                  height: 30.h,
                                  width: 1.sw,
                                  child: choosedOrAppliedFiltersWidget(
                                    controller: widget.controller,
                                    boutiqueSlug: 'search',
                                    context: context,
                                    fromSearch: true,
                                  ),
                                ),
                        );
                      },
                    ),
                    BlocBuilder<BoutiqueBloc, BoutiqueState>(
                      builder: (context, state) {
                        Filter? choosedFilterToAddToIt =
                            state.choosedFiltersByUser[key]?.filters;
                        if (choosedFilterToAddToIt == null &&
                            widget.controller.text.length < 3) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }
                        return SliverToBoxAdapter(
                          child: Container(
                            width: 300.w,
                            margin: EdgeInsets.only(
                              bottom: !hideAppleyResetButtom.value ? 0 : 30.h,
                              left: 20.w,
                              top: 20.h,
                              right: 20.w,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: () {
                                      Filter filters =
                                          state
                                              .choosedFiltersByUser[key]
                                              ?.filters ??
                                          Filter();
                                      String text = widget.controller.text;

                                      boutiqueBloc.add(
                                        ChangeAppliedFiltersEvent(
                                          boutiqueSlug: key,
                                          filtersAppliedByUser:
                                              GetProductFiltersModel(
                                                filters: filters
                                                    .copyWithSaveOtherField(
                                                      searchText:
                                                          (text.length) > 2
                                                          ? text
                                                          : null,
                                                      prices: filters.prices,
                                                    ),
                                              ),
                                        ),
                                      );
                                      boutiqueBloc.add(
                                        GetProductsWithFiltersEvent(
                                          offset: 1,
                                          boutiqueSlug: key,
                                          fromSearch: true,
                                          searchText: (text.length) > 2
                                              ? text
                                              : null,
                                        ),
                                      );
                                      homeBloc.add(
                                        const IsChangedVariationWhenQtyZeroEvent(
                                          isChangedVariationWhenQtyZero: false,
                                        ),
                                      );
                                      homeBloc.add(
                                        const IsChangedVariationWhenQtyZeroEvent(
                                          isChangedVariationWhenQtyZero: false,
                                        ),
                                      );

                                      boutiqueBloc.add(
                                        AddSizeAndColorFilterinTextToSearchEvent(
                                          sizeAndColorFilterinTextToSearch:
                                              const {},
                                        ),
                                      );
                                      appBloc.add(
                                        HideBottomNavigationBar(false),
                                      );
                                      appBloc.add(ShowOrHideBars(true));
                                      appBloc.add(ChangeIndexForSearch(1));

                                      Future.delayed(
                                        const Duration(milliseconds: 600),
                                        () => HelperFunctions.slidingNavigation(
                                          context,
                                          listing_page.ProductListingPage(
                                            isShowPanelForVerified:
                                                widget.isShowPanelForVerified,
                                            controllerFormSearchPage:
                                                widget.controller,
                                            boutiqueIcon: "",
                                            fromSearch: true,
                                            boutiqueSlug: key,
                                          ),
                                        ),
                                      );
                                      /////////////////////////////////
                                      // FirebaseAnalyticsService
                                      //     .logEventForSession(
                                      //   eventName: AnalyticsEventsConst
                                      //       .buttonClicked,
                                      //   executedEventName:
                                      //       AnalyticsButtonsEventNameConst
                                      //           .applyHomeSearchResultButton,
                                      // );
                                    },
                                    child: Container(
                                      height: 65.h,
                                      width: 300.w,
                                      key: TestVariables.kTestMode
                                          ? const Key(
                                              WidgetsKeys
                                                  .searchButtonInSearchPageKey,
                                            )
                                          : null,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffFF5F61),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                          BoxShadow(
                                            color:
                                                // ignore: deprecated_member_use
                                                Colors.white.withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyTextWidget(
                                              '${LocaleKeys.search.tr()} ',
                                              style: textTheme.bodyLarge?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xffFEFEFE,
                                                    ),
                                                    height: (23 / 18).h,
                                                    fontSize: 16.sp,
                                                  ),
                                            ),
                                            state.countOfProductExpectedByFiltering?['search'] !=
                                                    null
                                                ? MyTextWidget(
                                                    "(${LocaleKeys.number_of_products.tr()} ${state.countOfProductExpectedByFiltering?['search']})",
                                                    style: textTheme
                                                        .bodyMedium
                                                        ?.rq
                                                        .copyWith(
                                                          fontSize: 12.sp,
                                                          color: const Color(
                                                            0xffFEFEFE,
                                                          ),
                                                          height: 1.2,
                                                        ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      boutiqueBloc.add(
                                        ChangeAppliedFiltersEvent(
                                          boutiqueSlug: key,
                                          resetAppliedFilters: true,
                                        ),
                                      );
                                      boutiqueBloc.add(
                                        ChangeSelectedFiltersEvent(
                                          boutiqueSlug: key,
                                          fromHomePageSearch: true,
                                        ),
                                      );
                                      widget.controller.clear();
                                      /////////////////////////////////
                                      // FirebaseAnalyticsService
                                      //     .logEventForSession(
                                      //   eventName: AnalyticsEventsConst
                                      //       .buttonClicked,
                                      //   executedEventName:
                                      //       AnalyticsButtonsEventNameConst
                                      //           .resetHomeSearchButton,
                                      // );
                                    },
                                    child: Container(
                                      height: 65.h,
                                      decoration: BoxDecoration(
                                        color: colorScheme.white,
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                          BoxShadow(
                                            color:
                                                // ignore: deprecated_member_use
                                                Colors.white.withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: const Color(0xff388CFF),
                                        ),
                                      ),
                                      child: Center(
                                        child: MyTextWidget(
                                          '${LocaleKeys.reset.tr()}',
                                          style: textTheme.bodyLarge?.rq
                                              .copyWith(
                                                color: const Color(0xff388CFF),
                                                height: (23 / 18).h,
                                                fontSize: 16.sp,
                                              ),
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  int get numberOfFields => 1;
}
