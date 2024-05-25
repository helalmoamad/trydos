import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';

import '../../../../core/data/model/pagination_model.dart';
import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/app_widgets/tabs_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_text_widget.dart';
import '../../../story/presentation/pages/story_collection.dart';
import '../manager/home_bloc.dart';
import '../widgets/product_listing/product_item.dart';

class ProductListingPage extends StatefulWidget {
  final String boutiqueSlug;
  final String? category;

  const ProductListingPage({
    super.key,
    required this.boutiqueSlug,
    this.category,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  double? _previousOffset;

  double? _velocity;
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            if (notification.metrics.axis == Axis.horizontal) return false;
            final currentOffset = notification.metrics.pixels;
            if (_previousOffset != null) {
              final distance = (currentOffset - _previousOffset!).abs();
              final time =
                  notification.dragDetails?.sourceTimeStamp?.inMilliseconds ??
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
            debugPrint(_velocity.toString());
            _previousOffset = currentOffset;
            return true;
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (p, c) {
                  String key = widget.boutiqueSlug + (widget.category ?? '');
                  return p.getProductListingPaginationWithoutFiltersModel[key]
                          ?.paginationStatus !=
                      c.getProductListingPaginationWithoutFiltersModel[key]
                          ?.paginationStatus;
                },
                builder: (context, state) {
                  String key = widget.boutiqueSlug + (widget.category ?? '');
                  if ((state.getProductListingPaginationWithoutFiltersModel[key]
                              ?.paginationStatus ==
                          PaginationStatus.loading) ||
                      (state.getProductListingPaginationWithoutFiltersModel[
                              key] ==
                          null)) {
                    return Center(
                      child: TrydosLoader(),
                    );
                  }
                  if (state.getProductListingStatus ==
                      GetProductsWithoutFiltersStatus.failure) {
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
                        return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          controller: scrollController,
                          padding: const EdgeInsets.only(top: 50),
                          childAspectRatio: 200.w / 350,
                          crossAxisSpacing: 10,
                          primary: false,
                          mainAxisSpacing: 15,
                          physics: const ClampingScrollPhysics(),
                          children: List.generate(
                              state
                                  .getProductListingPaginationWithoutFiltersModel[
                                      key]!
                                  .items
                                  .length,
                              (index) => GestureDetector(
                                    onTap: () async {
                                      Future.delayed(
                                          Duration(milliseconds: 100), () {
                                        print("${prefsRepository.myMarketId.toString()}" +
                                            "55555555555555555555555555555555555555555");
                                        print("${prefsRepository.myMarketName.toString()}" +
                                            "554${GetIt.I<PrefsRepository>().serverTime}4555554444${prefsRepository.countryIso.toString()}444444444${LanguageService.languageCode == 'ar' ? 'ae' : LanguageService.languageCode}444444444444${GetIt.I<PrefsRepository>().currentEvent}44444444444444444444444444445555555555555555555555");
                                      });
                                      await FirebaseAnalytics.instance.logEvent(
                                          name: 'button_clicked',
                                          parameters: {
                                            "time_stamp": DateTime.now()
                                                .toUtc()
                                                .add(Duration(
                                                    minutes:
                                                        GetIt.I<PrefsRepository>()
                                                                .getdurtion ??
                                                            0))
                                                .toString(),
                                            "previous_event_button_name":
                                                GetIt.I<PrefsRepository>()
                                                    .currentEvent,
                                            "device_language": LanguageService
                                                        .languageCode ==
                                                    'ar'
                                                ? 'ae'
                                                : LanguageService.languageCode,
                                            "country_name":
                                                GetIt.I<PrefsRepository>()
                                                    .countryIso,
                                            'userID': prefsRepository.myMarketId
                                                .toString(),
                                            'user_name': prefsRepository
                                                .myMarketName
                                                .toString(),
                                            'clicked_button_name':
                                                'i love you Ahmad',
                                            "session_id":
                                                GetIt.I<PrefsRepository>()
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
                                      HelperFunctions.slidingNavigation(
                                          context,
                                          ProductDetailsPage(
                                            productItem: state
                                                .getProductListingPaginationWithoutFiltersModel[
                                                    key]!
                                                .items[index],
                                          ));
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
                        );
                      });
                },
              ),
              BlocBuilder<AppBloc, AppState>(
                  buildWhen: (p, c) => p.showBars != c.showBars,
                  builder: (context, state) {
                    if (state.showBars == true) {
                      return const TabsBar();
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
