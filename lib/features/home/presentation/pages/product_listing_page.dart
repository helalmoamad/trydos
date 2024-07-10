import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter_products;
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/constant/widgets_key.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/svg_network_widget.dart';
import '../manager/home_bloc.dart';
import '../widgets/product_listing/product_item.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import '../widgets/product_listing/product_listing_filter_list.dart';

class ProductListingPage extends StatefulWidget {
  final String boutiqueSlug;
  final String? category;
  final String? boutiqueIcon;
  final String boutiqueDescription;
  final String boutiqueFirstBanner;

  const ProductListingPage({
    super.key,
    required this.boutiqueSlug,
    required this.boutiqueDescription,
    required this.boutiqueFirstBanner,
    this.category,
    this.boutiqueIcon,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  double? _previousOffset;
  Timer? timerForDisplayFilterSectionTitle;
  final GlobalKey htmlDescriptionKey = GlobalKey();
  final ValueNotifier<double> htmlDescriptionHeight = ValueNotifier(0);
  double? _velocity;
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final ValueNotifier<bool> filterPageExpanded = ValueNotifier(false);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<List<Tuple3<int, int?, double>>> selectedFiltersNotifier =
      ValueNotifier([]);
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 100), postFrameCallback);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetProductsWithoutFiltersEvent(
      boutiqueSlug: widget.boutiqueSlug,
      category: widget.category,
      offset: 1,
    ));
    homeBloc.add(GetProductFiltersEvent(
      boutiqueSlug: widget.boutiqueSlug,
      category: widget.category,
    ));
    scrollController.addListener(() {
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
      // else if(filterPageExpanded.value){
      //   scrollController.jumpTo(80);
      // }
      if (setThisEnabledNotifier.value.item1 != -1) {
        setThisEnabledNotifier.value = Tuple2(-1, -1);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    appBloc.add(ShowOrHideBars(true));
    scrollController.dispose();
    super.dispose();
  }

  Key gridViewKeyForRendering = UniqueKey();

  void postFrameCallback(timer) {
    var context = htmlDescriptionKey.currentContext;
    if (context == null || htmlDescriptionHeight.value > 0) return;
    timer.cancel();
    htmlDescriptionHeight.value = context.size!.height;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Scaffold(
              backgroundColor: Color(0xffF8F8F8),
              bottomNavigationBar: BlocBuilder<AppBloc, AppState>(
                  buildWhen: (p, c) => p.showBars != c.showBars,
                  builder: (context, state) {
                    if (state.showBars == true) {
                      return const AppBottomNavBar();
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
              body: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.horizontal)
                    return false;
                  final currentOffset = notification.metrics.pixels;
                  if (currentOffset >= 50) {
                    displayBoutiqueIconInAppBar.value = true;
                  } else {
                    displayBoutiqueIconInAppBar.value = false;
                  }
                  if (_previousOffset != null) {
                    final distance = (currentOffset - _previousOffset!).abs();
                    final time = notification
                            .dragDetails?.sourceTimeStamp?.inMilliseconds ??
                        0.000001;
                    _velocity = distance / time;
                    if (scrollController.position.pixels <= 80) {
                      _previousOffset = currentOffset;
                      return true;
                    }
                    if (_velocity! <= (1.5e-8) && _velocity! >= (1.42e-8)) {
                      appBloc.add(ShowOrHideBars(true));
                    } else {
                      appBloc.add(ShowOrHideBars(false));
                    }
                  }
                  _previousOffset = currentOffset;
                  return true;
                },
                child: ValueListenableBuilder<Tuple2<int, int>>(
                    valueListenable: setThisEnabledNotifier,
                    builder: (context, slidingMode, _) {
                      return ValueListenableBuilder<bool>(
                          valueListenable: filterPageExpanded,
                          builder: (context, isExpanded, _) {
                            return CustomScrollView(
                                controller: scrollController,
                                physics: ClampingScrollPhysics(),
                                slivers: [
                                  SliverAppBar(
                                    pinned: true,
                                    backgroundColor: colorScheme.white,
                                    automaticallyImplyLeading: false,
                                    flexibleSpace: TrydosAppBar(
                                      appBarParams: AppBarParams(
                                          backgroundColor: colorScheme.white,
                                          scrolledUnderElevation: 0,
                                          backIconColor: Colors.black,
                                          action: [
                                            ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    displayBoutiqueIconInAppBar,
                                                builder: (context, display, _) {
                                                  return widget.boutiqueIcon !=
                                                          null
                                                      ? Visibility(
                                                          visible: display,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .only(
                                                                        start: 30
                                                                            .w),
                                                            child:
                                                                SvgNetworkWidget(
                                                              svgUrl: widget
                                                                  .boutiqueIcon!,
                                                              height: 20,
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox.shrink();
                                                }),
                                            Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(end: 30.0),
                                              child: SvgPicture.asset(
                                                AppAssets
                                                    .searchOutlinedReversedSvg,
                                                width: 20,
                                                height: 20,
                                              ),
                                            ),
                                            isExpanded
                                                ? SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .only(end: 30.0),
                                                    child: SvgPicture.asset(
                                                        AppAssets.sortingSvg,
                                                        width: 20,
                                                        height: 20),
                                                  ),
                                            Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(end: 30.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    //scrollController.animateTo(180 + htmlDescriptionHeight.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                    // Future.delayed(Duration(milliseconds: 200) , (){
                                                    int length =
                                                        selectedFiltersNotifier
                                                            .value.length;
                                                    selectedFiltersNotifier
                                                        .value
                                                        .clear();
                                                    _clearAllItemsFromAnimatedList(
                                                        length);
                                                    selectedFiltersNotifier
                                                        .notifyListeners();
                                                    filterPageExpanded.value =
                                                        true;
                                                    // scrollController.jumpTo(0);
                                                    //});
                                                  },
                                                  child: SvgPicture.asset(
                                                    AppAssets.filtersSvg,
                                                    width: 20,
                                                    height: 20,
                                                    color: isExpanded
                                                        ? Color(0xffFF5F61)
                                                        : null,
                                                  ),
                                                )),
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      end: !isExpanded
                                                          ? 10.0
                                                          : 25),
                                              child: !isExpanded
                                                  ? SvgPicture.asset(
                                                      AppAssets.shareSvg,
                                                      width: 20,
                                                      height: 20,
                                                      color: Color(0xff3C3C3C),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        filterPageExpanded
                                                            .value = false;
                                                      },
                                                      child: SvgPicture.asset(
                                                        AppAssets.closeSvg,
                                                        width: 15,
                                                        height: 15,
                                                        color:
                                                            Color(0xffFF5F61),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                          withShadow: false),
                                    ),
                                  ),
                                  ValueListenableBuilder<double>(
                                      valueListenable: htmlDescriptionHeight,
                                      builder: (context, htmlHeight, child) {
                                        return SliverAppBar(
                                          pinned: false,
                                          collapsedHeight: 180 + htmlHeight,
                                          backgroundColor: colorScheme.white,
                                          automaticallyImplyLeading: false,
                                          flexibleSpace: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (widget.boutiqueIcon !=
                                                          null)
                                                        SvgNetworkWidget(
                                                          svgUrl: widget
                                                              .boutiqueIcon!,
                                                          height: 20,
                                                        ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      SvgPicture.asset(
                                                        AppAssets
                                                            .verifiedBadgeSvg,
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      SvgPicture.asset(
                                                        AppAssets.starBadgeSvg,
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Html(
                                                      key: htmlDescriptionKey,
                                                      shrinkWrap: true,
                                                      data: widget
                                                          .boutiqueDescription,
                                                      style: {
                                                        "body": Style(
                                                            margin:
                                                                Margins.all(0)),
                                                        "p": Style(
                                                          margin:
                                                              Margins.all(0),
                                                        ),
                                                      }),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 25.0),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          height:
                                                              htmlHeight == 0
                                                                  ? 0
                                                                  : 135,
                                                          width: 1.sw,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                            border: Border.all(
                                                                width: 0.5,
                                                                color: const Color(
                                                                    0xfffafafa)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: const Color(
                                                                    0x33000000),
                                                                offset: Offset(
                                                                    0, 3),
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child:
                                                                  MyCachedNetworkImage(
                                                                imageUrl: widget
                                                                    .boutiqueFirstBanner,
                                                                imageFit: BoxFit
                                                                    .cover,
                                                                width: 1.sw,
                                                                height: 135,
                                                              )),
                                                        ),
                                                        Container(
                                                          height:
                                                              htmlHeight == 0
                                                                  ? 0
                                                                  : 135,
                                                          width: 1.sw,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.7),
                                                                  offset:
                                                                      Offset(
                                                                          0, 3),
                                                                  blurRadius: 6,
                                                                  inset: true),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ])
                                              ]),
                                        );
                                      }),
                                  ValueListenableBuilder<
                                          List<Tuple3<int, int?, double>>>(
                                      valueListenable: selectedFiltersNotifier,
                                      builder: (context, filters, _) {
                                        return SliverAppBar(
                                            pinned: isExpanded ? false : true,
                                            surfaceTintColor:
                                                Colors.transparent,
                                            backgroundColor: colorScheme.white,
                                            automaticallyImplyLeading: false,
                                            titleSpacing: 0,
                                            toolbarHeight: isExpanded
                                                ? 860
                                                : selectedFiltersNotifier
                                                        .value.isNotEmpty
                                                    ? 145
                                                    : 115,
                                            title: StackedFiltersList(
                                                isExpanded: isExpanded,
                                                closeFilterPage: () {
                                                  filterPageExpanded.value =
                                                      false;
                                                },
                                                category: widget.category,
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                controller: isExpanded
                                                    ? scrollController
                                                    : null,
                                                listKey: listKey,
                                                selectedFiltersNotifier:
                                                    selectedFiltersNotifier,
                                                onMoveToAnotherFiltersSection:
                                                    (_) {}));
                                      }),
                                  isExpanded
                                      ? SliverToBoxAdapter()
                                      : BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (p, c) {
                                            String key = widget.boutiqueSlug +
                                                (widget.category ?? '');
                                            if (p
                                                    .getProductListingPaginationWithoutFiltersModel[
                                                        key]
                                                    ?.items !=
                                                c
                                                    .getProductListingPaginationWithoutFiltersModel[
                                                        key]
                                                    ?.items) {
                                              gridViewKeyForRendering =
                                                  UniqueKey();
                                            }
                                            return p.getProductsWithFiltersStatus !=
                                                    c
                                                        .getProductsWithFiltersStatus ||
                                                (p
                                                        .getProductListingPaginationWithoutFiltersModel[
                                                            key]
                                                        ?.paginationStatus !=
                                                    c
                                                        .getProductListingPaginationWithoutFiltersModel[
                                                            key]
                                                        ?.paginationStatus);
                                          },
                                          builder: (context, state) {
                                            if (state
                                                    .getProductsWithFiltersStatus ==
                                                GetProductsWithFiltersStatus
                                                    .loading) {
                                              return SliverToBoxAdapter(
                                                child: Center(
                                                  child: TrydosLoader(),
                                                ),
                                              );
                                            }
                                            List<filter_products.Products>
                                                products;
                                            String key = widget.boutiqueSlug +
                                                (widget.category ?? '');
                                            if (state
                                                    .getProductListingWithFiltersModel !=
                                                null) {
                                              products = state
                                                      .getProductListingWithFiltersModel!
                                                      .data
                                                      ?.products ??
                                                  [];
                                            } else {
                                              if ((state
                                                              .getProductListingPaginationWithoutFiltersModel[
                                                                  key]
                                                              ?.paginationStatus ==
                                                          PaginationStatus
                                                              .loading &&
                                                      (state
                                                              .getProductListingPaginationWithoutFiltersModel[
                                                                  key]
                                                              ?.items
                                                              .isNullOrEmpty ??
                                                          true)) ||
                                                  (state.getProductListingPaginationWithoutFiltersModel[
                                                          key] ==
                                                      null)) {
                                                return SliverToBoxAdapter(
                                                  child: Center(
                                                    child: TrydosLoader(),
                                                  ),
                                                );
                                              }
                                              products = state
                                                      .getProductListingPaginationWithoutFiltersModel[
                                                          key]
                                                      ?.items ??
                                                  [];
                                            }
                                            return SliverPadding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              sliver: SliverGrid(
                                                key: gridViewKeyForRendering,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 200.w / 350,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 15,
                                                ),
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  childCount: products.length,
                                                  (BuildContext context,
                                                      int index) {
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    100), () {
                                                          print("${prefsRepository.myMarketId.toString()}" +
                                                              "55555555555555555555555555555555555555555");
                                                          print("${prefsRepository.myMarketName.toString()}" +
                                                              "554${GetIt.I<PrefsRepository>().serverTime}4555554444${prefsRepository.countryIso.toString()}444444444${LanguageService.languageCode == 'ar' ? 'ae' : LanguageService.languageCode}444444444444${GetIt.I<PrefsRepository>().currentEvent}44444444444444444444444444445555555555555555555555");
                                                        });
                                                        await FirebaseAnalytics
                                                            .instance
                                                            .logEvent(
                                                                name:
                                                                    'button_clicked',
                                                                parameters: {
                                                              "time_stamp": DateTime
                                                                      .now()
                                                                  .toUtc()
                                                                  .add(Duration(
                                                                      minutes:
                                                                          GetIt.I<PrefsRepository>().getdurtion ??
                                                                              0))
                                                                  .toString(),
                                                              "previous_event_button_name":
                                                                  GetIt.I<PrefsRepository>()
                                                                      .currentEvent,
                                                              "device_language":
                                                                  LanguageService
                                                                              .languageCode ==
                                                                          'ar'
                                                                      ? 'ae'
                                                                      : LanguageService
                                                                          .languageCode,
                                                              "country_name":
                                                                  GetIt.I<PrefsRepository>()
                                                                      .countryIso,
                                                              'userID':
                                                                  prefsRepository
                                                                      .myMarketId
                                                                      .toString(),
                                                              'user_name':
                                                                  prefsRepository
                                                                      .myMarketName
                                                                      .toString(),
                                                              'clicked_button_name':
                                                                  'i love you Ahmad',
                                                              "session_id": GetIt.I<
                                                                      PrefsRepository>()
                                                                  .sessionId,
                                                            });
                                                        await GetIt.I<
                                                                PrefsRepository>()
                                                            .setCurrentEvent(
                                                                "i loveddssssssssssss44444444444444444ssssssssssssss you Ahmad in past");

                                                        // pushOverscrollRoute(
                                                        //     context: context,
                                                        //     transitionDuration : Duration(milliseconds : 250),
                                                        //     reverseTransitionDuration : Duration(milliseconds : 400),
                                                        //     child: ProductDetailsPage(
                                                        //       productItem: state
                                                        //           .getProductListingWithoutFiltersModel!
                                                        //           .data!
                                                        //           .products![index]
                                                        //     ),
                                                        //     workNormally: true,
                                                        //     withRoundedCorners: true,
                                                        //     isArabicLanguage: LanguageService.rtl,
                                                        //     dragToPopDirection: DragToPopDirection.toBottom,
                                                        //     scrollToPopOption: ScrollToPopOption.start,
                                                        //     fullscreenDialog: true);
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (ctx) =>
                                                                    ProductDetailsPage(
                                                                      productItem:
                                                                          products[
                                                                              index],
                                                                    )));
                                                      },
                                                      child: ProductItem(
                                                        slidingModeItem:
                                                            slidingMode,
                                                        productItem:
                                                            products[index],
                                                        itemIndex: index,
                                                        setThisEnabled:
                                                            (int index,
                                                                int slideMode) {
                                                          setThisEnabledNotifier
                                                                  .value =
                                                              Tuple2(index,
                                                                  slideMode);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ]);
                          });
                    }),
              ),
            ),
            Positioned(
              top: 10,
              child: Stack(
                children: [
                  ValueListenableBuilder<String?>(
                      valueListenable: showTitleForFilterList,
                      builder: (context, title, _) {
                        return Visibility(
                          visible: title != null,
                          child: Stack(
                            children: [
                              Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x19000000),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xff505050)),
                                child: Center(
                                  child: MyTextWidget(
                                    title ?? '',
                                    style: textTheme.bodyText2?.rq.copyWith(
                                        color: colorScheme.white,
                                        height: 18 / 14),
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 40,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                      color: Colors.white.withOpacity(0.16),
                                      inset: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _clearAllItemsFromAnimatedList(int length) {
    for (var i = 0; i < length; i++) {
      listKey.currentState!.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return Container();
      });
    }
  }
}
