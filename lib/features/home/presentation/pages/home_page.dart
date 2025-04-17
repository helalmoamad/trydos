import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
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
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/sliding_up_panel_for_reels.dart';
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
import '../manager/homeBloc/home_state.dart';
import '../widgets/home_page_card2.dart';

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
  final ScrollController scrollController = ScrollController();
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

  @override
  void initState() {
    if (!(prefsRepository.isRequestNotificationPermission ?? false)) {
      PermissionServices().requestNotificationPermission();
      prefsRepository.setRequestNotificationPermission(true);
    }

    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
    Future.delayed(Duration(seconds: 20), () {
      homeBloc.add(GetNotificationTypeProductEvent());
      homeBloc.add(GetFirebaseSettingForNotificationEvent());
      homeBloc.add(GetPopularSearchItemEvent());
    });
    appBloc.add(ChangeIndexForSearch(0));

    Future.delayed(Duration(seconds: 7), () {});
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

    scrollController.addListener(() {
      int lastIndexSeenByUser = (scrollController.position.pixels +
              scrollController.position.viewportDimension +
              235) ~/
          235;
      print(lastIndexSeenByUser);
      int currentSelectedMainCategoryTab = appBloc.state.tabIndex;

      if (currentSelectedMainCategoryTab == -1) {
        selectedCategorySlug = "Empty";
      } else {
        selectedCategorySlug = categoryBloc.state.mainCategoriesResponseModel
                ?.data?.mainCategories?[currentSelectedMainCategoryTab].slug ??
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
            getWithPrefetchForEachBoutiques: false,
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
      categoryBloc.prefetchBoutiques(
          selectedCategorySlug, context, lastIndexSeenByUser);
    });

    String notificationTypesOfMarketFromTerminated =
        GetIt.I<PrefsRepository>().getNotificationTypeOfMarketFromTerminated ??
            "";

    if (notificationTypesOfMarketFromTerminated != "") {
      Map data = jsonDecode(notificationTypesOfMarketFromTerminated);
      HandlingMarketNotifications.dealWithNotificationFromMarket(data, true);
    }
    //  getInitialForNotification();
    super.initState();
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
    };
    bool _isLoading = false;

    Future<void> _refreshData() async {
      setState(() {
        _isLoading = true; // بدء التحميل
      });
      BlocProvider.of<StoryBloc>(context).add(GetStoryEvent());
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
          child: Stack(
            children: [
              CustomScrollView(
                key: TestVariables.kTestMode
                    ? Key(WidgetsKeys.homepageScrollKey)
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
                        StoriesList(
                          isShowPanelForVerified: widget.isShowPanelForVerified,
                        ), // height 220
                        Positioned(
                            top: 0,
                            right:
                                currentLocale.languageCode == "ar" ? 30 : null,
                            left:
                                currentLocale.languageCode == "ar" ? null : 30,
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
                                  style: context.textTheme.titleLarge?.rr
                                      .copyWith(
                                          height: 0.86,
                                          color: Color(0xff3C3C3C)),
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
                      return BlocBuilder<CategoryBloc, CategoryState>(
                        buildWhen: (p, c) {
                          String? currentSlug = appState.tabIndex != -1
                              ? (c
                                      .mainCategoriesResponseModel
                                      ?.data
                                      ?.mainCategories?[appState.tabIndex]
                                      .slug ??
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
                              ? (categoryState
                                      .mainCategoriesResponseModel
                                      ?.data
                                      ?.mainCategories?[appState.tabIndex]
                                      .slug ??
                                  "Empty")
                              : "Empty";
                          print(
                              "..............${categoryState.getHomeBoutiquesPaginationObjectByMainCategory.keys.toList()}.................${(categoryState.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]?.items.length ?? 0)}");

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
                            print(
                                "111111111111111111111111999999999999999999999999999999999999999999999..${(categoryState.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]?.items.length ?? 0)}");
                            return sliverListSeparated(
                              key: TestVariables.kTestMode
                                  ? Key(WidgetsKeys.boutiquesFailureStatusKey)
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
                            key: TestVariables.kTestMode
                                ? Key(WidgetsKeys.boutiquesSuccessStatusKey)
                                : reRenderingListViewKey[currentSlug],
                            itemBuilder: (_, index) => Padding(
                                padding:
                                    HWEdgeInsets.symmetric(horizontal: 15.w),
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
              Positioned(
                bottom: 0,
                child: ValueListenableBuilder<bool>(
                    valueListenable: widget.isShowPanelForVerified,
                    builder: (context, _isShowPanelForVerified, _) {
                      if (_isShowPanelForVerified) {
                        if ((prefsRepository
                                .isVerifiedPhonePeforeExpiredToken ??
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
                                      Duration(milliseconds: 100),
                                      () => widget.isShowPanelForVerified
                                          .value = false);
                                },
                                isDraggable: true,
                                panelBuilder: (sc) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    margin: EdgeInsets.only(top: 20),
                                    height: 200,
                                    child: Stack(children: [
                                      PageView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
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
                                                        panelController.close();
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
                                                      phoneNumber:
                                                          prefsRepository
                                                              .myPhoneNumber!),
                                                ]
                                              : [
                                                  InsertPhoneTab(
                                                    fromLogin: false,
                                                    focusNode: focusNode,
                                                    moveToNextStep:
                                                        (String phoneNumber) {
                                                      this.phoneNumber =
                                                          phoneNumber
                                                              .replaceAll(
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
                                                      print(
                                                          "###################33333#${isVisWhatsApp}");
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
                                                        panelController.close();
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
                                                      methodIcon:
                                                          isVisWhatsApp == 1
                                                              ? AppAssets
                                                                  .whatsappSvg
                                                              : AppAssets
                                                                  .smsSvg,
                                                      phoneNumber: phoneNumber),
                                                ]),
                                      Positioned(
                                        top: 0,
                                        left:
                                            LanguageService.languageCode != "ar"
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
              )
            ],
          ),
        ),
      ),
    ));
  }
}
