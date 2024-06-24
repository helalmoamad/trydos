import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/app_widgets/tabs_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/svg_network_widget.dart';
import '../../../story/presentation/pages/story_collection.dart';
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

  double? _velocity;
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetProductsWithoutFiltersEvent(
      boutiqueSlug: widget.boutiqueSlug,
      category: widget.category,
      offset: 1,
    ));
    scrollController.addListener(() {
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Scaffold(
              backgroundColor: Color(0xffF4F4F4),
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    backgroundColor: colorScheme.white,
                    scrolledUnderElevation: 0,
                    backIconColor: Colors.black,
                    action: [
                      ValueListenableBuilder<bool>(
                          valueListenable: displayBoutiqueIconInAppBar,
                          builder: (context, display, _) {
                            return widget.boutiqueIcon != null
                                ? Visibility(
                                    visible: display,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 30.w),
                                      child: SvgNetworkWidget(
                                        svgUrl: widget.boutiqueIcon!,
                                        height: 20,
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink();
                          }),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 30.0),
                        child: SvgPicture.asset(
                          AppAssets.searchOutlinedReversedSvg,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 30.0),
                        child: SvgPicture.asset(AppAssets.sortingSvg,
                            width: 20, height: 20),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 30.0),
                        child: SvgPicture.asset(
                          AppAssets.filtersSvg,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10.0),
                        child: SvgPicture.asset(
                          AppAssets.shareSvg,
                          width: 20,
                          height: 20,
                          color: Color(0xff3C3C3C),
                        ),
                      ),
                    ],
                    withShadow: false),
              ),
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
                child: BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) {
                    String key = widget.boutiqueSlug + (widget.category ?? '');
                    if (p.getProductListingPaginationWithoutFiltersModel[key]
                            ?.items !=
                        c.getProductListingPaginationWithoutFiltersModel[key]
                            ?.items) {
                      gridViewKeyForRendering = UniqueKey();
                    }
                    return p.getProductListingPaginationWithoutFiltersModel[key]
                            ?.paginationStatus !=
                        c.getProductListingPaginationWithoutFiltersModel[key]
                            ?.paginationStatus;
                  },
                  builder: (context, state) {
                    String key = widget.boutiqueSlug + (widget.category ?? '');
                    if ((state
                                    .getProductListingPaginationWithoutFiltersModel[
                                        key]
                                    ?.paginationStatus ==
                                PaginationStatus.loading &&
                            (state
                                    .getProductListingPaginationWithoutFiltersModel[
                                        key]
                                    ?.items
                                    .isNullOrEmpty ??
                                true)) ||
                        (state.getProductListingPaginationWithoutFiltersModel[
                                key] ==
                            null)) {
                      return Center(
                        child: TrydosLoader(),
                      );
                    }
                    if (state.getProductListingStatus ==
                            GetProductsWithoutFiltersStatus.failure &&
                        state
                            .getProductListingPaginationWithoutFiltersModel[
                                key]!
                            .items
                            .isNullOrEmpty) {
                      return Center(
                        child: ElevatedButton(
                            onPressed: () {
                              homeBloc.add(GetProductsWithoutFiltersEvent(
                                boutiqueSlug: widget.boutiqueSlug,
                                category: widget.category,
                                offset: 1,
                              ));
                            },
                            child: MyTextWidget(LocaleKeys.try_again.tr())),
                      );
                    }
                    return ValueListenableBuilder<Tuple2<int, int>>(
                        valueListenable: setThisEnabledNotifier,
                        builder: (context, slidingMode, _) {
                          return SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            offset: Offset(0, 0),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.boutiqueIcon != null)
                                                SvgNetworkWidget(
                                                  svgUrl: widget.boutiqueIcon!,
                                                  height: 20,
                                                ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SvgPicture.asset(
                                                AppAssets.verifiedBadgeSvg,
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
                                            shrinkWrap: true,
                                            data: widget.boutiqueDescription,
                                            style: {
                                              "body":
                                                  Style(margin: Margins.all(0)),
                                              "p": Style(
                                                maxLines: 1,
                                                margin: Margins.all(0),
                                              ),
                                            },
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 135,
                                                  width: 1.sw,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    border: Border.all(
                                                        width: 0.5,
                                                        color: const Color(
                                                            0xfffafafa)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                            0x33000000),
                                                        offset: Offset(0, 3),
                                                        blurRadius: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child:
                                                          MyCachedNetworkImage(
                                                        imageUrl: widget
                                                            .boutiqueFirstBanner,
                                                        imageFit: BoxFit.cover,
                                                        width: 1.sw,
                                                        height: 135,
                                                      )),
                                                ),
                                                Container(
                                                  height: 135,
                                                  width: 1.sw,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.7),
                                                          offset: Offset(0, 3),
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
                                          StackedFiltersList(
                                            onMoveToAnotherFiltersSection:
                                                (String message) {
                                              timerForDisplayFilterSectionTitle
                                                  ?.cancel();
                                              showTitleForFilterList.value =
                                                  message;
                                              timerForDisplayFilterSectionTitle =
                                                  Timer(Duration(seconds: 3),
                                                      () {
                                                showTitleForFilterList.value =
                                                    null;
                                              });
                                            },
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GridView.count(
                                    key: gridViewKeyForRendering,
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    childAspectRatio: 200.w / 350,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 15,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: List.generate(
                                        state
                                            .getProductListingPaginationWithoutFiltersModel[
                                                key]!
                                            .items
                                            .length,
                                        (index) => GestureDetector(
                                              onTap: () async {
                                                Future.delayed(
                                                    Duration(milliseconds: 100),
                                                    () {
                                                  print("${prefsRepository.myMarketId.toString()}" +
                                                      "55555555555555555555555555555555555555555");
                                                  print("${prefsRepository.myMarketName.toString()}" +
                                                      "554${GetIt.I<PrefsRepository>().serverTime}4555554444${prefsRepository.countryIso.toString()}444444444${LanguageService.languageCode == 'ar' ? 'ae' : LanguageService.languageCode}444444444444${GetIt.I<PrefsRepository>().currentEvent}44444444444444444444444444445555555555555555555555");
                                                });
                                                await FirebaseAnalytics.instance
                                                    .logEvent(
                                                        name: 'button_clicked',
                                                        parameters: {
                                                      "time_stamp": DateTime
                                                              .now()
                                                          .toUtc()
                                                          .add(Duration(
                                                              minutes: GetIt.I<
                                                                          PrefsRepository>()
                                                                      .getdurtion ??
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
                                                      "country_name": GetIt.I<
                                                              PrefsRepository>()
                                                          .countryIso,
                                                      'userID': prefsRepository
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
                                                await GetIt.I<PrefsRepository>()
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
                                                              productItem: state
                                                                  .getProductListingPaginationWithoutFiltersModel[
                                                                      key]!
                                                                  .items[index],
                                                            )));
                                              },
                                              child: ProductItem(
                                                slidingModeItem: slidingMode,
                                                productItem: state
                                                    .getProductListingPaginationWithoutFiltersModel[
                                                        key]!
                                                    .items[index],
                                                itemIndex: index,
                                                setThisEnabled:
                                                    (int index, int slideMode) {
                                                  setThisEnabledNotifier.value =
                                                      Tuple2(index, slideMode);
                                                },
                                              ),
                                            )),
                                  ),
                                ],
                              ));
                        });
                  },
                ),
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
}
