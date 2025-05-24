import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/features_products_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';

import 'package:trydos/features/home/presentation/widgets/sliver_list_seprated.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/request_permission_notification.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../../../story/presentation/widget/stories_list.dart';
import '../widgets/home_page_card2.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;

class HomePage extends StatefulWidget {
  final ValueNotifier<bool> isShowPanelForVerified;
  HomePage({Key? key, required this.isShowPanelForVerified}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  late BoutiqueBloc boutiqueBloc;
  late CategoryBloc categoryBloc;
  ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();
  List<filter.Products> products = [];
  final ValueNotifier<String?> productNotAvailableNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> loadingForRquestProductDetails =
      ValueNotifier(false);
  final ScrollController scrollController = ScrollController();
  int currentSelectedColor = -1;
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  Map<String, Key> reRenderingListViewKey = {};
  Map<String, int> lastIndexRequestedInEachMainCategoryForPrefetchBoutiques =
      {};
  final PanelController panelController = PanelController();
  String selectedCategorySlug = "Empty";
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  late AuthBloc authBloc;
  bool changeAppearSizeForProduct = true;
  Timer? debounce;
  /*getInitialForNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          if (HandlingMarketNotifications
              .checkIfTheNotificationIsNotRelatedToChat(initialMessage)) {
            HandlingMarketNotifications.dealWithNotificationFromMarket(
                jsonDecode(initialMessage.data['body']), true);
            return;
          }
        },
      );
    }
  }*/
  void listenToScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(
      Duration(milliseconds: 600),
      () {
        int lastIndexSeenByUser = (scrollController.position.pixels +
                scrollController.position.viewportDimension +
                235) ~/
            235;
        int currentSelectedMainCategoryTab = appBloc.state.tabIndex;

        if (currentSelectedMainCategoryTab == -1) {
          selectedCategorySlug = "Empty";
        } else {
          selectedCategorySlug = categoryBloc
                  .state
                  .mainCategoriesResponseModel
                  ?.data
                  ?.mainCategories?[currentSelectedMainCategoryTab]
                  .slug ??
              '';
        }

        if (selectedCategorySlug == '') return;
        /*  if (lastIndexRequestedInEachMainCategoryForPrefetchBoutiques[
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
      }*/
        if (scrollController.offset >=
            (scrollController.position.maxScrollExtent * 0.6)) {
          categoryBloc.add(GetHomeBoutiqesEvent(
              getWithPrefetchToStoreInMemory: false,
              getWithOutPrefetchForEachBoutiques: false,
              categorySlug: selectedCategorySlug,
              offset: categoryBloc
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
        if (scrollController.offset >=
            (scrollController.position.maxScrollExtent * 0.4)) {
          categoryBloc.prefetchBoutiques(
              selectedCategorySlug, context, lastIndexSeenByUser);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (!(prefsRepository.isRequestNotificationPermission ?? false)) {
      PermissionServices().requestNotificationPermission();
      prefsRepository.setRequestNotificationPermission(true);
    }

    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    appBloc.add(ChangeIndexForSearch(0));

    Future.delayed(Duration(seconds: 5), () {});
    boutiqueBloc.add(GetProductsWithFiltersEvent(
        boutiqueSlug: "search",
        cashedOrginalBoutique: true,
        fromSearch: true,
        getWithPagination: false,
        offset: 1));
    boutiqueBloc.add(ChangeAppliedFiltersEvent(
        boutiqueSlug: 'search',
        filtersAppliedByUser: null,
        resetAppliedFilters: true));
    boutiqueBloc.add(ChangeSelectedFiltersEvent(
      resetChoosedFilters: true,
      requestToUpdateFilters: true,
      fromHomePageSearch: true,
      boutiqueSlug: 'search',
      filtersChoosedByUser: null,
    ));

    scrollController.addListener(listenToScroll);

    String notificationTypesOfMarketFromTerminated =
        GetIt.I<PrefsRepository>().getNotificationTypeOfMarketFromTerminated ??
            "";

    if (notificationTypesOfMarketFromTerminated != "") {
      try {
        Map data = jsonDecode(notificationTypesOfMarketFromTerminated);
        HandlingMarketNotifications.dealWithNotificationFromMarket(data, true);
      } catch (e) {}
    }
    //  getInitialForNotification();
  }

/*  prefetchBoutiques(String currentSlug) {
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
  }*/

  @override
  void dispose() {
    scrollController.removeListener(listenToScroll);
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

    /* FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };*/
    bool _isLoading = false;

    Future<void> _refreshData() async {
      setState(() {
        _isLoading = true; // بدء التحميل
      });
      boutiqueBloc.add(GetProductsWithFiltersEvent(
          fromNotification: false,
          limit: 10,
          cashedOrginalBoutique: true,
          boutiqueSlug: "*featured*",
          getWithPagination: false,
          offset: 1));
      BlocProvider.of<StoryBloc>(context)
          .add(GetStoryEvent(withPaginition: false));
      categoryBloc.add(GetMainCategoriesEvent(
        getWithPrefech: false,
        context: context,
      ));
      /* homeBloc.add(
        GetHomeBoutiqesEvent(
          getWithPrefetchToStoreInMemory: false,
          getWithPagination: false,
          forRefresh: true,
          getWithPrefetchForEachBoutiques: false,
          offset: "1",
          categorySlug: selectedCategorySlug,
          context: context,
        ),
      );
*/
      // محاكاة عملية تحميل البيانات
      await Future.delayed(Duration(seconds: 4));

      setState(() {
        _isLoading = false; // إنهاء التحميل
      });
    }

    return SafeArea(
        child: Padding(
      padding: HWEdgeInsets.symmetric(horizontal: 0.w),
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.black,
        onRefresh: _refreshData,
        child: Stack(
          children: [
            // BlocBuilder<AppBloc, AppState>(
            //   builder: (context, appState) {
            //     return BlocBuilder<CategoryBloc, CategoryState>(
            //       buildWhen: (p, c) {
            //         String? currentSlug = appState.tabIndex != -1
            //             ? (c.mainCategoriesResponseModel?.data
            //                     ?.mainCategories?[appState.tabIndex].slug ??
            //                 "Empty")
            //             : "Empty";
            //         bool rebuild = (p
            //                     .getHomeBoutiquesPaginationObjectByMainCategory[
            //                         currentSlug]
            //                     ?.paginationStatus !=
            //                 c
            //                     .getHomeBoutiquesPaginationObjectByMainCategory[
            //                         currentSlug]
            //                     ?.paginationStatus ||
            //             p.currentIndexForMainCategoryEvent !=
            //                 c.currentIndexForMainCategoryEvent);

            //         return rebuild;
            //       },
            //       builder: (context, categoryState) {
            //         String? currentSlug = appState.tabIndex != -1
            //             ? (categoryState.mainCategoriesResponseModel?.data
            //                     ?.mainCategories?[appState.tabIndex].slug ??
            //                 "Empty")
            //             : "Empty";
            //         debugPrint(
            //             "..............${categoryState.getHomeBoutiquesPaginationObjectByMainCategory.keys.toList()}.................${(categoryState.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]?.items.length ?? 0)}");

            //         if ((categoryState
            //                         .getHomeBoutiquesPaginationObjectByMainCategory[
            //                             currentSlug]
            //                         ?.paginationStatus ==
            //                     PaginationStatus.loading ||
            //                 categoryState
            //                         .getHomeBoutiquesPaginationObjectByMainCategory[
            //                             currentSlug]
            //                         ?.paginationStatus ==
            //                     PaginationStatus.initial) &&
            //             (categoryState
            //                         .getHomeBoutiquesPaginationObjectByMainCategory[
            //                             currentSlug]
            //                         ?.items
            //                         .length ??
            //                     0) ==
            //                 0) {
            //           debugPrint(
            //               "1111111111999999999999999999..${(categoryState.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]?.items.length ?? 0)}");

            //           return ListView.separated(
            //             key: TestVariables.kTestMode
            //                 ? Key(WidgetsKeys.boutiquesFailureStatusKey)
            //                 : null,
            //             itemCount: 10,
            //             itemBuilder: (context, index) {
            //               return Padding(
            //                 padding: HWEdgeInsets.symmetric(horizontal: 15.w),
            //                 child: ClipRRect(
            //                   borderRadius: BorderRadius.circular(20.0),
            //                   child: Shimmer.fromColors(
            //                     baseColor: Colors.grey.shade300,
            //                     highlightColor: Colors.grey.shade100,
            //                     enabled: true,
            //                     child: Stack(
            //                       alignment: Alignment.center,
            //                       children: [
            //                         Container(
            //                             width: 1.sw,
            //                             height: 235,
            //                             decoration: BoxDecoration(
            //                               borderRadius:
            //                                   BorderRadius.circular(20.0),
            //                               boxShadow: [
            //                                 BoxShadow(
            //                                   color: const Color(0xff000000)
            //                                       .withOpacity(0.4),
            //                                   offset: Offset(0, 3),
            //                                   blurRadius: 6,
            //                                 )
            //                               ],
            //                             )),
            //                         Container(
            //                             margin: EdgeInsets.symmetric(
            //                                 horizontal: 20),
            //                             width: 1.sw,
            //                             height: 135,
            //                             decoration: BoxDecoration(
            //                               borderRadius:
            //                                   BorderRadius.circular(20.0),
            //                               boxShadow: [
            //                                 BoxShadow(
            //                                   color: const Color(0xff000000)
            //                                       .withOpacity(0.6),
            //                                   offset: Offset(0, 3),
            //                                   blurRadius: 6,
            //                                 )
            //                               ],
            //                             )),
            //                         Positioned(
            //                           bottom: 30,
            //                           child: Row(
            //                             children: List.generate(
            //                                 5,
            //                                 (index) => CircleAvatar(
            //                                       radius: 20,
            //                                     )),
            //                           ),
            //                         )
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               );
            //             },
            //             separatorBuilder: (context, index) {
            //               return SizedBox(
            //                 height: 20,
            //               );
            //             },
            //           );
            //         }
            //         return ListView.separated(
            //           itemCount: categoryState
            //                           .getHomeBoutiquesPaginationObjectByMainCategory[
            //                       currentSlug] ==
            //                   null
            //               ? 0
            //               : categoryState
            //                       .getHomeBoutiquesPaginationObjectByMainCategory[
            //                           currentSlug]!
            //                       .items
            //                       .length +
            //                   1,
            //           physics: const ClampingScrollPhysics(
            //               parent: AlwaysScrollableScrollPhysics()),
            //           key: TestVariables.kTestMode
            //               ? Key(WidgetsKeys.boutiquesSuccessStatusKey)
            //               : reRenderingListViewKey[currentSlug],
            //           controller: scrollController,
            //           itemBuilder: (context, index) {
            //             return index == 0
            //                 ? Column(
            //                     children: [
            //                       _isLoading
            //                           ? Center(
            //                               child: CircularProgressIndicator(),
            //                             ) // إظهار مؤشر التحميل
            //                           : SizedBox.shrink(),
            //                       /////////////////////////////////
            //                       SizedBox(
            //                         height: 90,
            //                       ),
            //                       /////////////////////////////////
            //                       storySection(currentLocale, context),
            //                     ],
            //                   )
            //                 : Padding(
            //                     padding:
            //                         HWEdgeInsets.symmetric(horizontal: 15.w),
            //                     child: categoryState
            //                             .getHomeBoutiquesPaginationObjectByMainCategory[
            //                                 currentSlug]!
            //                             .items[index - 1]
            //                             .banners
            //                             .isNullOrEmpty
            //                         ? SizedBox.shrink()
            //                         : HomePageCard2(
            //                             isShowPanelForVerified:
            //                                 widget.isShowPanelForVerified,
            //                             key: TestVariables.kTestMode
            //                                 ? Key(
            //                                     '${WidgetsKeys.boutiqueCardKey}${index - 1}')
            //                                 : null,
            //                             category_Slug: currentSlug,
            //                             withSlidingImages: categoryState
            //                                     .getHomeBoutiquesPaginationObjectByMainCategory[
            //                                         currentSlug]!
            //                                     .items[index - 1]
            //                                     .banners!
            //                                     .length >
            //                                 1,
            //                             boutique: categoryState
            //                                 .getHomeBoutiquesPaginationObjectByMainCategory[
            //                                     currentSlug]!
            //                                 .items[index - 1],
            //                           )

            //                     //HomePageCard(showWhite: index % 2 == 0),
            //                     );
            //           },
            //           separatorBuilder: (context, index) {
            //             return SizedBox(
            //               height: 20,
            //             );
            //           },
            //         );
            //       },
            //     );
            //   },
            // ),

            ///////////////////////////
            CustomScrollView(
              cacheExtent: 600,
              key: TestVariables.kTestMode
                  ? Key(WidgetsKeys.homepageScrollKey)
                  : null,
              controller: scrollController,
              //  physics: const ClampingScrollPhysics(),
              scrollBehavior:
                  const ScrollBehavior().copyWith(overscroll: false),
              slivers: [
                SliverToBoxAdapter(
                  child: _isLoading
                      ? Center(
                          child:
                              CircularProgressIndicator()) // إظهار مؤشر التحميل
                      : SizedBox.shrink(),
                ),
                SliverToBoxAdapter(child: 70.verticalSpace),
                SliverToBoxAdapter(
                  child: storySection(currentLocale, context),
                ),
                SliverToBoxAdapter(
                  child: FeatureProductsWidget(
                    tapIndexToAddProductToCart: tapIndexToAddProductToCart,
                  ),
                ),
                BlocBuilder<AppBloc, AppState>(
                  buildWhen: (previous, current) =>
                      previous.tabIndex != current.tabIndex,
                  builder: (context, appState) {
                    return BlocBuilder<CategoryBloc, CategoryState>(
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

                        return rebuild;
                      },
                      builder: (context, categoryState) {
                        String? currentSlug = appState.tabIndex != -1
                            ? (categoryState.mainCategoriesResponseModel?.data
                                    ?.mainCategories?[appState.tabIndex].slug ??
                                "Empty")
                            : "Empty";

                        if ((categoryState
                                        .getHomeBoutiquesPaginationObjectByMainCategory[
                                            currentSlug]
                                        ?.paginationStatus ==
                                    PaginationStatus.loading ||
                                categoryState
                                        .getHomeBoutiquesPaginationObjectByMainCategory[
                                            currentSlug]
                                        ?.paginationStatus ==
                                    PaginationStatus.initial) &&
                            (categoryState
                                        .getHomeBoutiquesPaginationObjectByMainCategory[
                                            currentSlug]
                                        ?.items
                                        .length ??
                                    0) ==
                                0) {
                          return sliverListSeparated(
                            key: TestVariables.kTestMode
                                ? Key(WidgetsKeys.boutiquesFailureStatusKey)
                                : null,
                            itemBuilder: (_, index) => Padding(
                              padding: HWEdgeInsets.symmetric(horizontal: 15.w),
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
                                                color: const Color(0xff000000)
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
                                                color: const Color(0xff000000)
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
                                  ),
                                ),
                              ),
                            ),
                            //HomePageCard(showWhite: index % 2 == 0),
                            separator: SizedBox(
                              height: 20,
                            ),
                            childCount: 10,
                          );
                        }
                        return sliverListSeparated(
                          addRepaintBoundaries: true,
                          key: TestVariables.kTestMode
                              ? Key(WidgetsKeys.boutiquesSuccessStatusKey)
                              : reRenderingListViewKey[currentSlug],
                          itemBuilder: (_, index) => Padding(
                              padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                              child: categoryState
                                      .getHomeBoutiquesPaginationObjectByMainCategory[
                                          currentSlug]!
                                      .items[index]
                                      .banners
                                      .isNullOrEmpty
                                  ? SizedBox.shrink()
                                  : HomePageCard2(
                                      isShowPanelForVerified:
                                          widget.isShowPanelForVerified,
                                      key: TestVariables.kTestMode
                                          ? Key(
                                              '${WidgetsKeys.boutiqueCardKey}$index')
                                          : null,
                                      category_Slug: currentSlug,
                                      withSlidingImages: categoryState
                                              .getHomeBoutiquesPaginationObjectByMainCategory[
                                                  currentSlug]!
                                              .items[index]
                                              .banners!
                                              .length >
                                          1,
                                      boutique: categoryState
                                          .getHomeBoutiquesPaginationObjectByMainCategory[
                                              currentSlug]!
                                          .items[index],
                                    )

                              //HomePageCard(showWhite: index % 2 == 0),
                              ),
                          separator: SizedBox(
                            height: 20,
                          ),
                          childCount: categoryState
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
                  buildWhen: (previous, current) =>
                      previous.tabIndex != current.tabIndex,
                  builder: (context, appState) {
                    return BlocBuilder<CategoryBloc, CategoryState>(
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
                                  0) >
                              9) &&
                          state
                                  .getHomeBoutiquesPaginationObjectByMainCategory[
                                      currentSlug]
                                  ?.paginationStatus ==
                              PaginationStatus.loading) {
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
            //////////////////////////////
            Positioned(
              bottom: 0,
              child: ValueListenableBuilder<bool>(
                  valueListenable: widget.isShowPanelForVerified,
                  builder: (context, _isShowPanelForVerified, _) {
                    if (_isShowPanelForVerified) {
                      if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ??
                          false)) {
                        authBloc.add(SendOtpEvent(
                            phone: prefsRepository.myPhoneNumber!,
                            isViaWhatsApp: 1));
                      }

                      ;
                      Future.delayed(
                        Duration(milliseconds: 500),
                        () => panelController.open(),
                      );
                    }
                    return !_isShowPanelForVerified
                        ? SizedBox.shrink()
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            width: 1.sh,
                            height: 1.sh / 2.7,
                            child: SlidingUpPanel(
                              minHeight: 0,
                              maxHeight: 1.sh / 2.7,
                              controller: panelController,
                              onPanelClosed: () {
                                Future.delayed(
                                    Duration(milliseconds: 300),
                                    () => widget.isShowPanelForVerified.value =
                                        false);
                              },
                              isDraggable: true,
                              panelBuilder: (sc) {
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  margin: EdgeInsets.only(top: 20),
                                  height: 200,
                                  child: Stack(children: [
                                    PageView(
                                        physics: NeverScrollableScrollPhysics(),
                                        controller: pageController,
                                        children: (prefsRepository
                                                    .isVerifiedPhonePeforeExpiredToken ??
                                                false)
                                            ? [
                                                VerifyOtp(
                                                    fromProfile: false,
                                                    navigateToProfile: () {},
                                                    fromExpired: true,
                                                    isVisWhatsApp: 1,
                                                    navigateToAddName: () {},
                                                    navigateTocartOrProfile:
                                                        () {
                                                      Future.delayed(
                                                          Duration(seconds: 1),
                                                          () => panelController
                                                              .close());
                                                    },
                                                    fromLogin: false,
                                                    onLoginFailed: () {
                                                      //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                    },
                                                    goBack: () {
                                                      // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                    },
                                                    methodIcon:
                                                        AppAssets.whatsappSvg,
                                                    phoneNumber: prefsRepository
                                                        .myPhoneNumber!),
                                              ]
                                            : [
                                                InsertPhoneTab(
                                                  fromLogin: false,
                                                  focusNode: focusNode,
                                                  moveToNextStep:
                                                      (String phoneNumber) {
                                                    this.phoneNumber =
                                                        phoneNumber.replaceAll(
                                                            ' ', '');
                                                    pageController
                                                        .animateToPage(1,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            curve: Curves
                                                                .easeInOut);
                                                    setState(() {});
                                                  },
                                                ),
                                                VerificationMethods(
                                                  phoneNumber: phoneNumber,
                                                  onChooseWhatsapp: () {
                                                    isVisWhatsApp = 1;
                                                    pageController
                                                        .animateToPage(2,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    100),
                                                            curve: Curves
                                                                .easeInOut);

                                                    if (prefsRepository
                                                            .isTimerForOtpRunning ??
                                                        false) {
                                                      showMessage(
                                                          '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}');
                                                      return;
                                                    }
                                                    authBloc.add(SendOtpEvent(
                                                        phone: phoneNumber,
                                                        isViaWhatsApp: 1));
                                                  },
                                                  goBackToPhone: () {
                                                    pageController
                                                        .animateToPage(0,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            curve: Curves
                                                                .easeInOut);
                                                  },
                                                  onChooseSms: () {
                                                    isVisWhatsApp = 0;
                                                    pageController
                                                        .animateToPage(3,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            curve: Curves
                                                                .easeInOut);
                                                    authBloc.add(SendOtpEvent(
                                                        phone: phoneNumber,
                                                        isViaWhatsApp: 0));
                                                  },
                                                ),
                                                VerifyOtp(
                                                    fromProfile: false,
                                                    navigateToProfile: () {},
                                                    fromExpired: true,
                                                    isVisWhatsApp:
                                                        isVisWhatsApp,
                                                    navigateToAddName: () {},
                                                    navigateTocartOrProfile:
                                                        () {
                                                      Future.delayed(
                                                          Duration(seconds: 1),
                                                          () => panelController
                                                              .close());
                                                    },
                                                    fromLogin: false,
                                                    onLoginFailed: () {
                                                      pageController
                                                          .animateToPage(3,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      500),
                                                              curve: Curves
                                                                  .easeInOut);
                                                    },
                                                    goBack: () {
                                                      pageController
                                                          .animateToPage(1,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      500),
                                                              curve: Curves
                                                                  .easeInOut);
                                                    },
                                                    methodIcon: isVisWhatsApp ==
                                                            1
                                                        ? AppAssets.whatsappSvg
                                                        : AppAssets.smsSvg,
                                                    phoneNumber: phoneNumber),
                                              ]),
                                    Positioned(
                                      top: 0,
                                      left: LanguageService.languageCode != "ar"
                                          ? null
                                          : 0,
                                      right:
                                          LanguageService.languageCode != "ar"
                                              ? 0
                                              : null,
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        height: 20,
                                        width: 40,
                                        child: InkWell(
                                            onTap: () =>
                                                panelController.close(),
                                            child: SvgPicture.asset(
                                              AppAssets.closeSvg,
                                              height: 15,
                                              width: 30,
                                              color: Color(0xffFF5F61),
                                            )),
                                      ),
                                    )
                                  ]),
                                );
                              },
                            ),
                          );
                  }),
            ),
            BlocBuilder<BoutiqueBloc, BoutiqueState>(
                buildWhen: (previous, current) {
              return previous
                      .getProductListingWithFiltersPaginationModels[
                          "*featured*withoutFilter"]
                      ?.paginationStatus !=
                  current
                      .getProductListingWithFiltersPaginationModels[
                          "*featured*withoutFilter"]
                      ?.paginationStatus;
            }, builder: (context, state) {
              products = state.getProductListingWithFiltersPaginationModels[
                          "*featured*withoutFilter"] ==
                      null
                  ? []
                  : state
                      .getProductListingWithFiltersPaginationModels[
                          "*featured*withoutFilter"]!
                      .items;
              return ValueListenableBuilder<int>(
                  valueListenable: tapIndexToAddProductToCart,
                  builder: (context, tapIndex, _) {
                    if (tapIndex != -1) {
                      appBloc.add(HideBottomNavigationBar(true));
                      homeBloc.add(IsChangedVariationWhenQtyZeroEvent(
                          isChangedVariationWhenQtyZero: false));

                      /* homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
                                      isChangedvariationWhenQtyZero: false));
                                  currentSelectedColorAfterChangeVariant = -1;*/
                      changeAppearSizeForProduct = true;

                      homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
                          fromListingPage: true,
                          productSlug: products[tapIndex].slug,
                          productId: products[tapIndex].productId.toString()));

                      loadingForRquestProductDetails.value = true;
                      Future.delayed(Duration(milliseconds: 600),
                          () => loadingForRquestProductDetails.value = false);
                    } else {
                      appBloc.add(HideBottomNavigationBar(false));
                      currentActiveTab.value = 0;

                      return SizedBox.shrink();
                    }
                    return ValueListenableBuilder<bool>(
                        valueListenable: loadingForRquestProductDetails,
                        builder: (context, _loadingForRquestProductDetails, _) {
                          return Positioned(
                              bottom: -20.h,
                              child: _loadingForRquestProductDetails
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      child: TrydosLoader(
                                        size: 15,
                                      ),
                                    )
                                  : Container(
                                      height: tapIndex == -1 ? 0 : 1.sh,
                                      width: 1.sw,
                                      child: BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (previous, current) =>
                                              previous.getProductDetailWithoutSimilarRelatedProductsStatus != current.getProductDetailWithoutSimilarRelatedProductsStatus ||
                                              previous.getCartOverviewStatus !=
                                                  current
                                                      .getCartOverviewStatus ||
                                              previous.currentSelectedColorForEveryProduct !=
                                                  current
                                                      .currentSelectedColorForEveryProduct ||
                                              previous.enableAddToCardAfterChangeVariantZero !=
                                                  current
                                                      .enableAddToCardAfterChangeVariantZero ||
                                              previous.isChangedvariationWhenQtyZero !=
                                                  current
                                                      .isChangedvariationWhenQtyZero ||
                                              previous.cartCollection !=
                                                  current.cartCollection,
                                          builder: (context, state) {
                                            String productId =
                                                products[tapIndex]
                                                    .productId
                                                    .toString();
                                            String productSlug =
                                                products[tapIndex]
                                                    .slug
                                                    .toString();
                                            List<String> syncColorNames = [];
                                            List<filter.SyncColorImage>
                                                syncColorImagesFromListing =
                                                products[tapIndex]
                                                        .syncColorImages ??
                                                    [];
                                            List<filter.Color>?
                                                colorsFromListing =
                                                products[tapIndex].colors ?? [];
                                            if (state
                                                    .getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                GetProductDetailWithoutSimilarRelatedProductsStatus
                                                    .success) {
                                              for (var i = 0;
                                                  i <
                                                      (products[tapIndex]
                                                              .syncColorImages
                                                              ?.length ??
                                                          0);
                                                  i++) {
                                                syncColorNames.add(
                                                    products[tapIndex]
                                                            .syncColorImages?[i]
                                                            .colorName ??
                                                        "");
                                              }
                                              state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      products[tapIndex]
                                                          .productId
                                                          .toString()]!
                                                  .product
                                                  ?.syncColorImages
                                                  ?.forEach(
                                                (element) {
                                                  if (!syncColorNames.contains(
                                                      element.colorName)) {
                                                    syncColorImagesFromListing
                                                        .add(element);
                                                  }
                                                },
                                              );

                                              state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      products[tapIndex]
                                                          .productId
                                                          .toString()]!
                                                  .product
                                                  ?.colors
                                                  ?.forEach(
                                                (element) {
                                                  if (!(syncColorNames.contains(
                                                      element.name))) {
                                                    colorsFromListing
                                                        .add(element);
                                                  }
                                                },
                                              );
                                            }

                                            currentSelectedColor =
                                                state.currentSelectedColorForEveryProduct[
                                                        productSlug] ??
                                                    (products[tapIndex]
                                                                .syncColorImages
                                                                ?.length ??
                                                            0) ~/
                                                        2;

                                            if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                                        .failure &&
                                                (prefsRepository
                                                        .isTokenExpired ??
                                                    false ||
                                                        prefsRepository
                                                                .marketToken ==
                                                            "" ||
                                                        prefsRepository
                                                                .marketToken ==
                                                            null)) {
                                              Future.delayed(
                                                Duration(seconds: 5),
                                                () {
                                                  homeBloc.add(
                                                      GetProductDatailsWithoutRelatedProductsEvent(
                                                          fromListingPage: true,
                                                          productSlug:
                                                              products[tapIndex]
                                                                  .slug,
                                                          productId:
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()));
                                                },
                                              );
                                            }
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                      GetProductDetailWithoutSimilarRelatedProductsStatus
                                                          .success &&
                                                  tapIndex != -1)) {
                                                if (state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.countryIsRestricted ==
                                                    true) {
                                                  productNotAvailableNotifier
                                                          .value =
                                                      LocaleKeys
                                                          .product_is_not_available_in_your_country
                                                          .tr();
                                                } else if (state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.availableQuantity ==
                                                    false) {
                                                  productNotAvailableNotifier
                                                          .value =
                                                      LocaleKeys
                                                          .this_product_is_not_available_in_store
                                                          .tr();
                                                } else {
                                                  productNotAvailableNotifier
                                                      .value = null;
                                                }
                                              }
                                            });
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              if (state
                                                      .getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                  GetProductDetailWithoutSimilarRelatedProductsStatus
                                                      .failure) {
                                                tapIndexToAddProductToCart
                                                    .value = -1;
                                              }
                                            });
                                            homeBloc.add(AddSizesForColorsEvent(
                                                currentColorName:
                                                    !products[tapIndex]
                                                            .colors
                                                            .isNullOrEmpty
                                                        ? products[tapIndex].colors![currentSelectedColor].name ??
                                                            ""
                                                        : "",
                                                variation: state.cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()] !=
                                                        null
                                                    ? state
                                                                .cachedProductWithoutRelatedProductsModel[
                                                                    products[tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                .product !=
                                                            null
                                                        ? state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                            .product!
                                                            .variation
                                                        : null
                                                    : null));
                                            if (productId != "" &&
                                                tapIndex != -1 &&
                                                state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                                        .success &&
                                                changeAppearSizeForProduct) {
                                              if (!state
                                                      .cachedProductWithoutRelatedProductsModel
                                                      .containsKey(productId) ||
                                                  (state.cachedProductWithoutRelatedProductsModel[
                                                              productId] !=
                                                          null
                                                      ? state
                                                                  .cachedProductWithoutRelatedProductsModel[
                                                                      productId]!
                                                                  .product !=
                                                              null
                                                          ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productId]!
                                                              .product!
                                                              .choiceOptions
                                                              .isNullOrEmpty
                                                          : true
                                                      : true)) {
                                                homeBloc.add(
                                                    AddCurrentColorSizeEvent(
                                                        choice_1: null));
                                              } else if (!(state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                          productId] !=
                                                      null
                                                  ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productId]!
                                                              .product !=
                                                          null
                                                      ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productId]!
                                                          .product!
                                                          .choiceOptions
                                                          .isNullOrEmpty
                                                      : true
                                                  : true)) {
                                                String sizeSelect = (state
                                                                .cachedProductWithoutRelatedProductsModel[
                                                                    productId]!
                                                                .product!
                                                                .choiceOptions
                                                                ?.length ??
                                                            0) ==
                                                        0
                                                    ? ""
                                                    : state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                productId]!
                                                            .product!
                                                            .choiceOptions![0]
                                                            .options?[(state
                                                                        .cachedProductWithoutRelatedProductsModel[
                                                                            productId]!
                                                                        .product
                                                                        ?.choiceOptions?[
                                                                            0]
                                                                        .options
                                                                        ?.length ??
                                                                    0) ~/
                                                                2]
                                                            .name ??
                                                        "";

                                                homeBloc.add(
                                                    AddCurrentColorSizeEvent(
                                                        choice_1: sizeSelect));
                                              }
                                              homeBloc.add(
                                                  IsChangedVariationWhenQtyZeroEvent(
                                                      isChangedVariationWhenQtyZero:
                                                          true));

                                              currentActiveTab.value = 3;
                                              Future.delayed(
                                                  Duration(milliseconds: 600),
                                                  () {
                                                panelControllerForCart.open();
                                                changeAppearSizeForProduct =
                                                    false;
                                              });
                                            }

                                            return state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                        GetProductDetailWithoutSimilarRelatedProductsStatus
                                                            .loading ||
                                                    state.enableAddToCardAfterChangeVariantZero !=
                                                        EnableAddToCardAfterChangeVariantZero
                                                            .success
                                                ? Container(
                                                    width: 1.sw,
                                                    height: 1.sh,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.3),
                                                    child: TrydosLoader(
                                                      size: 25,
                                                    ),
                                                  )
                                                : ProductDetailsBottomSheet(
                                                    isGetFullProductDetails:
                                                        false,
                                                    productNotAvailableNotifier:
                                                        productNotAvailableNotifier,
                                                    currentActiveTab:
                                                        currentActiveTab,
                                                    qtyForproductWithoutVariant:
                                                        state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.availableQuantity,
                                                    collectedAfterOrdering: state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.collectedAfterOrdering ==
                                                        1,
                                                    tapIndexToAddProductToCart:
                                                        tapIndexToAddProductToCart,
                                                    fromListingPage: true,
                                                    productIdForCashData:
                                                        products[tapIndex]
                                                            .productId
                                                            .toString(),
                                                    panelController:
                                                        panelControllerForCart,
                                                    productSlugForTopic: state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.slug ??
                                                        "",
                                                    productDescription: HtmlParser
                                                            .parseHTML(products[
                                                                        tapIndex]
                                                                    .details ??
                                                                "")
                                                        .text,
                                                    countOfPieces: state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()] !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product !=
                                                                null
                                                            ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product!
                                                                    .countOfPieces ??
                                                                0
                                                            : 0
                                                        : 0,
                                                    addToBagButtonShapeNotifier:
                                                        addToBagButtonShapeNotifier,
                                                    currentColornum: products[
                                                                tapIndex]
                                                            .colors
                                                            .isNullOrEmpty
                                                        ? ''
                                                        : products[tapIndex]
                                                                .colors![
                                                                    currentSelectedColor]
                                                                .color ??
                                                            "",
                                                    boutiqueIcon: state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                products[tapIndex]
                                                                    .productId
                                                                    .toString()] !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product !=
                                                                null
                                                            ? state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                            .productId
                                                                            .toString()]!
                                                                        .product!
                                                                        .boutique !=
                                                                    null
                                                                ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique!.icon !=
                                                                        null
                                                                    ? state
                                                                            .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
                                                                            .product!
                                                                            .boutique!
                                                                            .icon!
                                                                            .filePath ??
                                                                        ""
                                                                    : ""
                                                                : ""
                                                            : ""
                                                        : "",
                                                    boutiqueId: state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()] !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product !=
                                                                null
                                                            ? state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                            .productId
                                                                            .toString()]!
                                                                        .product!
                                                                        .boutique !=
                                                                    null
                                                                ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product!
                                                                    .boutique!
                                                                    .id!
                                                                : 0
                                                            : 0
                                                        : 0,
                                                    currentColorName: products[
                                                                tapIndex]
                                                            .colors
                                                            .isNullOrEmpty
                                                        ? ''
                                                        : products[tapIndex]
                                                                .colors![
                                                                    currentSelectedColor]
                                                                .name ??
                                                            "",
                                                    productItem:
                                                        products[tapIndex]
                                                            .copyWith(
                                                      availableQuantity: state
                                                                  .cachedProductWithoutRelatedProductsModel[products[
                                                                      tapIndex]
                                                                  .productId
                                                                  .toString()] ==
                                                              null
                                                          ? 0
                                                          : state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  products[
                                                                          tapIndex]
                                                                      .productId
                                                                      .toString()]!
                                                              .product
                                                              ?.availableQuantity,
                                                      choiceOptions: state
                                                                  .cachedProductWithoutRelatedProductsModel[products[
                                                                      tapIndex]
                                                                  .productId
                                                                  .toString()] ==
                                                              null
                                                          ? []
                                                          : state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  products[
                                                                          tapIndex]
                                                                      .productId
                                                                      .toString()]!
                                                              .product
                                                              ?.choiceOptions,
                                                      colors: colorsFromListing,
                                                      images: state.cachedProductWithoutRelatedProductsModel[
                                                                  products[
                                                                          tapIndex]
                                                                      .productId
                                                                      .toString()] ==
                                                              null
                                                          ? []
                                                          : state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  products[
                                                                          tapIndex]
                                                                      .productId
                                                                      .toString()]!
                                                              .product
                                                              ?.images,
                                                      syncColorImages:
                                                          syncColorImagesFromListing,
                                                    ),
                                                    currentColor:
                                                        currentSelectedColor,
                                                    maxAllowedToAddCart: state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]
                                                            ?.product
                                                            ?.maxAllowedQty ??
                                                        "0",
                                                  );
                                          }),
                                    ));
                        });
                  });
            })
          ],
        ),
      ),
    ));
  }

  Widget storySection(Locale currentLocale, BuildContext context) {
    return Stack(
      children: [
        StoriesList(
          isShowPanelForVerified: widget.isShowPanelForVerified,
        ), // height 220
        Positioned(
          top: 0,
          right: currentLocale.languageCode == "ar" ? 10 : null,
          left: currentLocale.languageCode == "ar" ? null : 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
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
                style: context.textTheme.titleLarge?.rr
                    .copyWith(height: 0.86, color: Color(0xff3C3C3C)),
              )
            ],
          ),
        )
      ],
    );
  }
}
