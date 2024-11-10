import 'dart:developer';
import 'dart:math';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/sliver_list_seprated.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../../../story/presentation/widget/stories_list.dart';
import '../manager/home_state.dart';
import '../widgets/home_page_card2.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  final ScrollController scrollController = ScrollController();
  Map<String, Key> reRenderingListViewKey = {};
  Map<String, int> lastIndexRequestedInEachMainCategoryForPrefetchBoutiques =
      {};
  String selectedCategorySlug = "Empty";
  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);

    appBloc.add(ChangeIndexForSearch(0));
    homeBloc.add(GetProductsWithFiltersEvent(
        boutiqueSlug: "search",
        cashedOrginalBoutique: true,
        fromSearch: true,
        getWithPagination: false,
        offset: 1));
    homeBloc.add(ChangeAppliedFiltersEvent(
        boutiqueSlug: 'search',
        filtersAppliedByUser: null,
        resetAppliedFilters: true));
    homeBloc.add(ChangeSelectedFiltersEvent(
      resetChoosedFilters: true,
      requestToUpdateFilters: true,
      fromHomePageSearch: true,
      boutiqueSlug: 'search',
      filtersChoosedByUser: null,
    ));

    scrollController.addListener(() {
      int lastIndexSeenByUser = (scrollController.position.pixels +
              scrollController.position.viewportDimension +
              235) ~/
          235;

      int currentSelectedMainCategoryTab = appBloc.state.tabIndex;

      if (currentSelectedMainCategoryTab == -1) {
        selectedCategorySlug = "Empty";
      } else {
        selectedCategorySlug = homeBloc.state.mainCategoriesResponseModel?.data
                ?.mainCategories?[currentSelectedMainCategoryTab].slug ??
            '';
      }

      if (selectedCategorySlug == '') return;
      if (lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
              selectedCategorySlug] ==
          null) {
        lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
            selectedCategorySlug] = -1;
      }
      if (lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
              selectedCategorySlug] !=
          lastIndexSeenByUser) {
        // prefetchBoutiques(selectedCategorySlug);
        lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
            selectedCategorySlug] = lastIndexSeenByUser;
      }
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.7)) {
        homeBloc.add(GetHomeBoutiqesEvent(
            getWithPrefetchForBoutiques: false,
            categorySlug: selectedCategorySlug,
            offset: homeBloc
                    .state
                    .getHomeBoutiquesPaginationObjectByMainCategory[
                        selectedCategorySlug]!
                    .offset ??
                "",
            context: context,
            getWithPagination: true));
      }
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
    });
    super.initState();
  }

  prefetchBoutiques(String currentSlug) {
    for (int i = 0;
        i <
            min(
                (lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
                        currentSlug] ??
                    0),
                (homeBloc
                        .state
                        .getHomeBoutiquesPaginationObjectByMainCategory[
                            currentSlug]
                        ?.items
                        .length ??
                    0));
        i++) {
      String slug = homeBloc
          .state
          .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
          .items[i]
          .slug
          .toString();
      if (homeBloc.state.boutiquesThatDidPrefetch[slug] != true) {
        debugPrint('///////// Prefetch Boutique Slug : $slug /////////');

        List<String> categorySlugs = [];

        homeBloc
            .state
            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
            .items[i]
            .childCategoriesForProductIds
            ?.forEach(
          (element) {
            categorySlugs.add(element.categorySlug ?? "");
          },
        );

        homeBloc.add(GetProductWithFiltersWithoutCancelingPreviousEvents(
            getWithoutFilter: true,
            context: context,
            categorySlugs: categorySlugs,
            cashedOrginalBoutique: true,
            fromHomePageSearch: false,
            boutiqueSlug: slug,
            category: null,
            searchText: null));
      } else {
        debugPrint('/////////Did Prefetch For Boutique Slug : $slug /////////');
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.homeScreen,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    bool _isLoading = false;

    Future<void> _refreshData() async {
      setState(() {
        _isLoading = true; // بدء التحميل
      });
      BlocProvider.of<StoryBloc>(context).add(GetStoryEvent());
      homeBloc.add(GetMainCategoriesEvent(
        getWithPrefech: false,
        context: context,
      ));
      homeBloc.add(
        GetHomeBoutiqesEvent(
          getWithPagination: false,
          getWithPrefetchForBoutiques: false,
          offset: "1",
          categorySlug: selectedCategorySlug,
          context: context,
        ),
      );

      // محاكاة عملية تحميل البيانات
      await Future.delayed(Duration(seconds: 4));

      setState(() {
        _isLoading = false; // إنهاء التحميل
      });
    }

    return SafeArea(
        child: Padding(
      padding: HWEdgeInsets.symmetric(horizontal: 0.w),
      child: NotificationListener<ScrollUpdateNotification>(
        // onNotification: (notification) {
        //   if (notification.metrics.axis == Axis.horizontal) return false;
        //   final currentOffset = notification.metrics.pixels;
        //   if (_previousOffset != null) {
        //     final distance = (currentOffset - _previousOffset!).abs();
        //     final time =
        //         notification.dragDetails?.sourceTimeStamp?.inMilliseconds ??
        //             0.000001;
        //     _velocity = distance / time;
        //     if (scrollController.position.pixels <= 80) {
        //       _previousOffset = currentOffset;
        //       return true;
        //     }
        //     if (_velocity! <= (1.5e-8) && _velocity! >= (1.42e-8)) {
        //       appBloc.add(ShowOrHideBars(true));
        //     } else {
        //       appBloc.add(ShowOrHideBars(false));
        //     }
        //   }
        //   debugPrint(_velocity.toString());
        //   _previousOffset = currentOffset;
        //   return true;
        // },
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: _refreshData,
          child: CustomScrollView(
            key: TestVariables.kTestMode
                ? Key(WidgetsKey.homepageScrollKey)
                : null,
            controller: scrollController,
            physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            scrollBehavior: const CupertinoScrollBehavior(),
            slivers: [
              SliverToBoxAdapter(
                child: _isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator()) // إظهار مؤشر التحميل
                    : SizedBox.shrink(),
              ),
              SliverToBoxAdapter(child: 50.verticalSpace),
              SliverToBoxAdapter(
                child: 40.verticalSpace,
              ),
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    StoriesList(), // height 220
                    Positioned(
                        top: 0,
                        right: currentLocale.languageCode == "ar" ? 30 : null,
                        left: currentLocale.languageCode == "ar" ? null : 30,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.storyFilmSvg,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            MyTextWidget(
                              LocaleKeys.story.tr(),
                              style: context.textTheme.titleLarge?.rr.copyWith(
                                  height: 0.86, color: Color(0xff3C3C3C)),
                            )
                          ],
                        ))
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: 5.verticalSpace,
              ),
              BlocBuilder<AppBloc, AppState>(
                builder: (context, appState) {
                  return BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (p, c) {
                      String? currentSlug = appState.tabIndex != -1
                          ? (c.mainCategoriesResponseModel?.data
                                  ?.mainCategories?[appState.tabIndex].slug ??
                              "Empty")
                          : "Empty";
                      bool rebuild = (p
                                  .getHomeBoutiquesPaginationObjectByMainCategory[
                                      currentSlug]
                                  ?.paginationStatus !=
                              c
                                  .getHomeBoutiquesPaginationObjectByMainCategory[
                                      currentSlug]
                                  ?.paginationStatus ||
                          p.currentIndexForMainCategoryEvent !=
                              c.currentIndexForMainCategoryEvent);
                      if (!p.reRequestTheseBoutiques.containsKey(currentSlug) &&
                          c.reRequestTheseBoutiques[currentSlug] == true) {
                        reRenderingListViewKey[currentSlug] = UniqueKey();
                      }
                      return rebuild;
                    },
                    builder: (context, homeState) {
                      String? currentSlug = appState.tabIndex != -1
                          ? (homeState.mainCategoriesResponseModel?.data
                                  ?.mainCategories?[appState.tabIndex].slug ??
                              "Empty")
                          : "Empty";
                      if (homeState.boutiquesForEveryMainCategoryThatDidPrefetch[
                                  currentSlug] !=
                              true &&
                          (homeState.getHomeBoutiquesPaginationObjectByMainCategory[
                                      currentSlug] ==
                                  null ||
                              ((homeState
                                              .getHomeBoutiquesPaginationObjectByMainCategory[
                                                  currentSlug]
                                              ?.paginationStatus ==
                                          PaginationStatus.loading ||
                                      homeState
                                              .getHomeBoutiquesPaginationObjectByMainCategory[
                                                  currentSlug]
                                              ?.paginationStatus ==
                                          PaginationStatus.initial) &&
                                  (homeState
                                              .getHomeBoutiquesPaginationObjectByMainCategory[
                                                  currentSlug]
                                              ?.items
                                              .length ??
                                          0) ==
                                      0))) {
                        return sliverListSeparated(
                            key: TestVariables.kTestMode
                                ? Key(WidgetsKey.boutiquesFailureStatusKey)
                                : null,
                            itemBuilder: (_, index) => Padding(
                                padding:
                                    HWEdgeInsets.symmetric(horizontal: 15.w),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      enabled: true,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                              width: 1.sw,
                                              height: 235,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xff000000)
                                                            .withOpacity(0.4),
                                                    offset: Offset(0, 3),
                                                    blurRadius: 6,
                                                  )
                                                ],
                                              )),
                                          Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              width: 1.sw,
                                              height: 135,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xff000000)
                                                            .withOpacity(0.6),
                                                    offset: Offset(0, 3),
                                                    blurRadius: 6,
                                                  )
                                                ],
                                              )),
                                          Positioned(
                                            bottom: 30,
                                            child: Row(
                                              children: List.generate(
                                                  5,
                                                  (index) => CircleAvatar(
                                                        radius: 20,
                                                      )),
                                            ),
                                          )
                                        ],
                                      )),
                                )),
                            //HomePageCard(showWhite: index % 2 == 0),
                            separator: SizedBox(
                              height: 20,
                            ),
                            childCount: 10);
                      }
                      return sliverListSeparated(
                        key: TestVariables.kTestMode
                            ? Key(WidgetsKey.boutiquesSuccessStatusKey)
                            : reRenderingListViewKey[currentSlug],
                        itemBuilder: (_, index) => Padding(
                            padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                            child: HomePageCard2(
                              key: TestVariables.kTestMode
                                  ? Key('${WidgetsKey.boutiqueCardKey}$index')
                                  : null,
                              category_Slug: currentSlug,
                              withSlidingImages: homeState
                                      .getHomeBoutiquesPaginationObjectByMainCategory[
                                          currentSlug]!
                                      .items[index]
                                      .banners!
                                      .length >
                                  1,
                              boutique: homeState
                                  .getHomeBoutiquesPaginationObjectByMainCategory[
                                      currentSlug]!
                                  .items[index],
                            )

                            //HomePageCard(showWhite: index % 2 == 0),
                            ),
                        separator: SizedBox(
                          height: 20,
                        ),
                        childCount: homeState
                                .getHomeBoutiquesPaginationObjectByMainCategory[
                                    currentSlug]
                                ?.items
                                .length ??
                            0,
                      );
                    },
                  );
                },
              ),
              SliverToBoxAdapter(
                child: 20.verticalSpace,
              ),
              BlocBuilder<AppBloc, AppState>(
                builder: (context, appState) {
                  return BlocBuilder<HomeBloc, HomeState>(buildWhen: (p, c) {
                    String? currentSlug = appState.tabIndex != -1
                        ? (c.mainCategoriesResponseModel?.data
                                ?.mainCategories?[appState.tabIndex].slug ??
                            "Empty")
                        : "Empty";
                    bool rebuild = (p
                                .getHomeBoutiquesPaginationObjectByMainCategory[
                                    currentSlug]
                                ?.paginationStatus !=
                            c
                                .getHomeBoutiquesPaginationObjectByMainCategory[
                                    currentSlug]
                                ?.paginationStatus ||
                        p.currentIndexForMainCategoryEvent !=
                            c.currentIndexForMainCategoryEvent);
                    return rebuild;
                  }, builder: (context, state) {
                    String? currentSlug = appState.tabIndex != -1
                        ? (state.mainCategoriesResponseModel?.data
                                ?.mainCategories?[appState.tabIndex].slug ??
                            "Empty")
                        : "Empty";
                    if (((state
                                    .getHomeBoutiquesPaginationObjectByMainCategory[
                                        currentSlug]
                                    ?.items
                                    .length ??
                                0) !=
                            0) &&
                        state
                                .getHomeBoutiquesPaginationObjectByMainCategory[
                                    currentSlug]
                                ?.paginationStatus ==
                            PaginationStatus.loading &&
                        state.isGettingProductListingWithPagination) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: TrydosLoader(),
                        ),
                      );
                    }
                    return SliverToBoxAdapter();
                  });
                },
              ),
              SliverToBoxAdapter(
                child: 20.verticalSpace,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
