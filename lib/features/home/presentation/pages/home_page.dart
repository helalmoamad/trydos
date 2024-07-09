import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/tabs_bar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/sliver_list_seprated.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/constant/widgets_key.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/my_text_widget.dart';
import '../../../story/presentation/widget/stories_list.dart';
import '../manager/home_state.dart';
import '../widgets/home_page_card2.dart';
import '../widgets/quick_offer_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  double? _previousOffset;
  double? _velocity;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    String selectedCategorySlug;
    homeBloc.add(GetHomeBoutiqesEvent(
        categorySlug: "Empty", offset: "1", getWithPagination: false));
    scrollController.addListener(() {
      int currentSelectedMainCategoryTab = appBloc.state.tabIndex;
      if (currentSelectedMainCategoryTab == -1) {
        selectedCategorySlug = "Empty";
      } else {
        selectedCategorySlug = homeBloc.state.mainCategoriesResponseModel?.data
                ?.mainCategories?[currentSelectedMainCategoryTab].slug ??
            '';
      }
      if (selectedCategorySlug == '') return;
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent *
              0.7 *
              (homeBloc
                  .state
                  .getHomeBoutiquesPaginationObjectByMainCategory[
                      selectedCategorySlug]!
                  .page))) {
        homeBloc.add(GetHomeBoutiqesEvent(
            categorySlug: selectedCategorySlug,
            offset: homeBloc
                .state
                .getHomeBoutiquesPaginationObjectByMainCategory[
                    selectedCategorySlug]!
                .page
                .toString(),
            getWithPagination: true));
      }
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return SafeArea(
        child: Padding(
      padding: HWEdgeInsets.symmetric(horizontal: 0.w),
      child: NotificationListener<ScrollUpdateNotification>(
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
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          scrollBehavior: const CupertinoScrollBehavior(),
          slivers: [
            SliverToBoxAdapter(child: 50.verticalSpace),
            SliverToBoxAdapter(
              child: 40.verticalSpace,
            ),
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  StoriesList(),
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
                            style: context.textTheme.bodyText2?.rr.copyWith(
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
                  builder: (context, homeState) {
                    //  print(homeState.getHomeSectionsPaginationObject[0]
                    //    ?.items[0].sections![0].title);

                    String? currentSlug = appState.tabIndex != -1
                        ? (homeState.mainCategoriesResponseModel?.data
                                ?.mainCategories?[appState.tabIndex].slug ??
                            "Empty")
                        : "Empty";
                    if (currentSlug == null ||
                        homeState.getHomeBoutiquesPaginationObjectByMainCategory[
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
                                0)) {
                      return sliverListSeparated(
                          key: Key(WidgetsKey.boutiquesFailureStatusKey),
                          itemBuilder: (_, index) => Padding(
                              padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                              child: TrydosShimmerLoading(
                                  width: 1.sw,
                                  logoTextWidth: 70.w,
                                  height: 235,
                                  logoTextHeight: 20)
                              //HomePageCard(showWhite: index % 2 == 0),
                              ),
                          separator: SizedBox(
                            height: 20,
                          ),
                          childCount: 10);
                    }
                    return sliverListSeparated(
                      key: Key(WidgetsKey.boutiquesSuccessStatusKey),
                      itemBuilder: (_, index) => Padding(
                          padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                          child: HomePageCard2(
                            key: Key('${WidgetsKey.boutiqueCardKey}$index'),
                            category_Slug: currentSlug,
                            withSlidingImages: homeState
                                    .getHomeBoutiquesPaginationObjectByMainCategory[
                                        currentSlug]!
                                    .items[index]
                                    .banners!
                                    .length >
                                1,
                            boutniqe: homeState
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
          ],
        ),
      ),
    ));
  }
}
