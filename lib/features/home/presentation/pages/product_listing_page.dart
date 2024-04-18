import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';

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
  const ProductListingPage({super.key});

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

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetProductsWithoutFiltersEvent(category: 'رجالي_36'));
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
                buildWhen: (p, c) =>
                    p.getProductsWithoutFiltersStatus !=
                    c.getProductsWithoutFiltersStatus,
                builder: (context, state) {
                  if (state.getProductsWithoutFiltersStatus ==
                      GetProductsWithoutFiltersStatus.loading) {
                    return Center(
                      child: TrydosLoader(),
                    );
                  }
                  if (state.getProductsWithoutFiltersStatus ==
                      GetProductsWithoutFiltersStatus.failure) {
                    return Center(
                      child: ElevatedButton(
                          onPressed: () {
                            homeBloc.add(GetProductsWithoutFiltersEvent(
                                category: 'رجالي_36'));
                          },
                          child: MyTextWidget(LocaleKeys.try_again.tr())),
                    );
                  }
                  return ValueListenableBuilder<Tuple2<int, int>>(
                      valueListenable: setThisEnabledNotifier,
                      builder: (context, slidingMode, _) {
                        return GridView.count(
                          crossAxisCount: 2,
                          controller: scrollController,
                          padding: const EdgeInsets.only(top: 50),
                          childAspectRatio: 200.w / 350,
                          crossAxisSpacing: 10,
                          primary: false,
                          mainAxisSpacing: 15,
                          children: List.generate(
                              state.getProductListingWithoutFiltersModel!.data!
                                      .products?.length ??
                                  0,
                              (index) => InkWell(
                                    onTap: () {
                                      pushOverscrollRoute(
                                          context: context,
                                          transitionDuration : Duration(milliseconds : 250),
                                          reverseTransitionDuration : Duration(milliseconds : 400),
                                          child: ProductDetailsPage(
                                            productId: state
                                                .getProductListingWithoutFiltersModel!
                                                .data!
                                                .products![index]
                                                .id
                                                .toString(),
                                          ),
                                          workNormally: true,
                                          withRoundedCorners: true,
                                          isArabicLanguage: LanguageService.rtl,
                                          dragToPopDirection: DragToPopDirection.toBottom,
                                          scrollToPopOption: ScrollToPopOption.start,
                                          fullscreenDialog: true);
                                    },
                                    child: Hero(
                                      tag: state
                                          .getProductListingWithoutFiltersModel!
                                          .data!
                                          .products![index]
                                          .id
                                          .toString(),
                                      child: ProductItem(
                                        slidingModeItem: slidingMode,
                                        productItem: state
                                            .getProductListingWithoutFiltersModel!
                                            .data!
                                            .products![index],
                                        itemIndex: index,
                                        setThisEnabled:
                                            (int index, int slideMode) {
                                          setThisEnabledNotifier.value =
                                              Tuple2(index, slideMode);
                                        },
                                      ),
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
