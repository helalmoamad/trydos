import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import '../../../common/constant/design/assets_provider.dart';
import '../../../common/constant/design/constant_design.dart';
import '../../../common/constant/widgets_key.dart';
import '../../../core/utils/responsive_padding.dart';
import '../../home/data/models/get_product_filters_model.dart';
import '../../home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing;
import '../../home/presentation/manager/home_bloc.dart';
import '../../home/presentation/manager/home_state.dart';
import '../animated_search_bar/animated_search_bar.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';
import '../my_text_widget.dart';

class TabsBar extends StatefulWidget {
  const TabsBar({
    Key? key,
    required this.buildSearchResult,
    required this.appearTrendingAndHistory,
    required this.controller,
  }) : super(key: key);
  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;
  final TextEditingController controller;

  @override
  State<TabsBar> createState() => _TabsBarState();
}

class _TabsBarState extends State<TabsBar> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  int? categoryIndexTap;
  @override
  void initState() {
    widget.appearTrendingAndHistory.value = true;
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  final FocusNode focusNode = FocusNode();
  bool resetSearchAfterSearchingWhileRemoveSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (oldState, newState) =>
                oldState.getMainCategoriesStatus ==
                    GetMainCategoriesStatus.loading &&
                newState.getMainCategoriesStatus ==
                    GetMainCategoriesStatus.success,
            builder: (context, homeState) {
              if (homeState.mainCategoriesResponseModel == null) {
                return Container(
                  width: 1.sw,
                  height: 55.h,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: colorScheme.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1a000000),
                        offset: Offset(0, 0),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                      key: Key(WidgetsKey.mainCategoriesTabNullKey),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                          5,
                          (index) => TrydosLoader(
                                size: 15.sp,
                              ))),
                );
              }
              return BlocBuilder<AppBloc, AppState>(
                  buildWhen: (oldState, newState) =>
                      oldState.tabIndex != newState.tabIndex,
                  builder: (context, state) {
                    return Container(
                        width: 1.sw,
                        height: 55.h,
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: colorScheme.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1a000000),
                              offset: Offset(0, 0),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BlocBuilder<AppBloc, AppState>(
                                  buildWhen: (p, c) =>
                                      p.currentIndex != c.currentIndex ||
                                      p.currentIndexForSearch !=
                                          c.currentIndexForSearch,
                                  builder: (context, state) {
                                    return AnimatedSearchBar(
                                      autoFocus: true,
                                      onFieldSubmitted: (text) {
                                        if (text.replaceAll(" ", "").length >
                                            2) {
                                          widget.buildSearchResult.value =
                                              text.length;
                                          widget.appearTrendingAndHistory
                                              .value = true;

                                          homeBloc.add(
                                              AddSearchTextToHistoryEvent(
                                                  searchTitle: text));
                                        }
                                      },
                                      width: 1.sw,
                                      height: 40,
                                      onClickClose: () {
                                        if (widget.controller.text.length > 0) {
                                          Filter filters = homeBloc
                                                  .state
                                                  .choosedFiltersByUser[
                                                      'search']
                                                  ?.filters ??
                                              Filter();
                                          Filter appliedFilters = homeBloc
                                                  .state
                                                  .appliedFiltersByUser[
                                                      'search']
                                                  ?.filters ??
                                              Filter();
                                          homeBloc
                                              .add(ChangeAppliedFiltersEvent(
                                            boutiqueSlug: 'search',
                                            filtersAppliedByUser:
                                                GetProductFiltersModel(
                                                    filters: appliedFilters
                                                        .copyWithSaveOtherField(
                                              prices: appliedFilters.prices,
                                              searchText: null,
                                            )),
                                          ));
                                          homeBloc
                                              .add(ChangeSelectedFiltersEvent(
                                            boutiqueSlug: 'search',
                                            fromHomePageSearch: true,
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                    filters: filters
                                                        .copyWithSaveOtherField(
                                                            prices:
                                                                filters.prices,
                                                            searchText: null)),
                                          ));
                                          widget.buildSearchResult.value = 0;
                                          widget.controller.clear();
                                          resetSearchAfterSearchingWhileRemoveSearch =
                                              false;
                                          widget.appearTrendingAndHistory
                                              .value = true;
                                          return true;
                                        } else {
                                          appBloc.add(ChangeBasePage(0));
                                          appBloc.add(
                                              HideBottomNavigationBar(false));
                                        }
                                        return false;
                                      },
                                      textController: widget.controller,
                                      focusNode: focusNode,
                                      onSuffixTap: () {
                                        widget.buildSearchResult.value = 1;
                                        widget.appearTrendingAndHistory.value =
                                            true;

                                        Future.delayed(
                                            Duration(milliseconds: 300), () {
                                          appBloc.add(ChangeBasePage(4));
                                          appBloc.add(
                                              HideBottomNavigationBar(true));
                                        });
                                      },
                                      suffixWidget: Center(
                                        child: SvgPicture.asset(
                                          AppAssets.searchOutlinedSvg,
                                          height: 20,
                                          width: 40,
                                          color: Color(0xff388CFF),
                                        ),
                                      ),
                                      prefixWidget: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15, top: 10, bottom: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppAssets.realCameraSvg,
                                              height: 20,
                                              width: 20,
                                            ),
                                            SvgPicture.asset(
                                              AppAssets.microphoneSvg,
                                              height: 20,
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      animationDurationInMilli: 400,
                                      searchDecoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: context.colorScheme.error,
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: context.colorScheme.error,
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        filled: true,
                                        fillColor: focusNode.hasFocus
                                            ? colorScheme.white
                                            : Color(0xffF8F8F8),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 12),
                                          child: SvgPicture.asset(
                                            AppAssets.searchOutlinedSvg,
                                            height: 20,
                                            width: 40,
                                            color: Color(0xff388CFF),
                                          ),
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 10, bottom: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.realCameraSvg,
                                                height: 20,
                                                width: 20,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              SvgPicture.asset(
                                                AppAssets.microphoneSvg,
                                                height: 20,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        //context.colorScheme.white,
                                        contentPadding:
                                            HWEdgeInsetsDirectional.only(
                                                start: 20,
                                                end: 10,
                                                bottom: 12,
                                                top: 12),
                                        hintText: 'Search',
                                        hintStyle: context
                                            .textTheme.subtitle1?.lq
                                            .copyWith(color: Color(0xffC4C2C2)),
                                        labelStyle: context.textTheme.bodyText2
                                            ?.copyWith(
                                                color:
                                                    context.colorScheme.hint),
                                      ),
                                      onChanged: (String text) {
                                        if (text.length > 2) {
                                          resetSearchAfterSearchingWhileRemoveSearch =
                                              true;
                                          Filter filters = homeBloc
                                                  .state
                                                  .choosedFiltersByUser[
                                                      'search']
                                                  ?.filters ??
                                              Filter();

                                          homeBloc.add(
                                              GetProductsWithFiltersEvent(
                                                  fromChoosed: true,
                                                  offset: 1,
                                                  boutiqueSlug: 'search',
                                                  resetChoosedFilters: false,
                                                  fromSearch: true,
                                                  searchText: text));

                                          homeBloc.add(GetProductFiltersEvent(
                                            fromHomePageSearch: true,
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                    filters: filters
                                                        .copyWithSaveOtherField(
                                              prices: filters.prices,
                                              searchText: text,
                                            )),
                                            searchText: text,
                                            boutiqueSlug: 'search',
                                          ));

                                          widget.buildSearchResult.value =
                                              text.length;
                                        }
                                        if (text.length < 1 &&
                                            resetSearchAfterSearchingWhileRemoveSearch) {
                                          resetSearchAfterSearchingWhileRemoveSearch =
                                              false;
                                          Filter filters = homeBloc
                                                  .state
                                                  .choosedFiltersByUser[
                                                      'search']
                                                  ?.filters ??
                                              Filter();

                                          homeBloc.add(GetProductFiltersEvent(
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                    filters: filters
                                                        .copyWithSaveOtherField(
                                              prices: filters.prices,
                                              searchText: null,
                                            )),
                                            fromHomePageSearch: true,
                                            searchText: null,
                                            boutiqueSlug: 'search',
                                          ));
                                        }
                                      },
                                      hideTrendingAndHistory:
                                          widget.appearTrendingAndHistory,
                                    );
                                  },
                                ),
                                BlocBuilder<AppBloc, AppState>(
                                  buildWhen: (p, c) =>
                                      p.currentIndex != c.currentIndex,
                                  builder: (context, state) {
                                    if (state.currentIndex != 4) {
                                      return SizedBox(
                                        width: 1.sw,
                                        child: Row(
                                            key: Key(WidgetsKey
                                                .mainCategoriesTabKey),
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: List.generate(
                                              (homeState
                                                      .mainCategoriesResponseModel
                                                      ?.data
                                                      ?.mainCategories
                                                      ?.length ??
                                                  0),
                                              (index) {
                                                MainCategory mainCategory =
                                                    homeState
                                                        .mainCategoriesResponseModel!
                                                        .data!
                                                        .mainCategories![index];
                                                return Padding(
                                                    padding:
                                                        HWEdgeInsetsDirectional
                                                            .only(end: 15.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (categoryIndexTap !=
                                                            index) {
                                                          appBloc.add(
                                                              ChangeTab(index));
                                                          homeBloc.add(GetHomeBoutiqesEvent(
                                                              getWithPagination:
                                                                  false,
                                                              offset: "1",
                                                              categorySlug: homeState
                                                                  .mainCategoriesResponseModel!
                                                                  .data!
                                                                  .mainCategories![
                                                                      index]
                                                                  .slug!));
                                                          categoryIndexTap =
                                                              index;
                                                        } else {
                                                          categoryIndexTap = -1;
                                                          appBloc.add(
                                                              ChangeTab(-1));
                                                          homeBloc.add(
                                                              GetHomeBoutiqesEvent(
                                                                  categorySlug:
                                                                      "Empty",
                                                                  offset: "1",
                                                                  getWithPagination:
                                                                      false));
                                                        }

                                                        /* appBloc.add(ChangeTab(index));
                                                          BlocProvider.of<HomeBloc>(context).add(
                                                                        GetHomeSectionsEvent(
                                                                            mainCategory.slug.toString()));*/

                                                        /*   homeBloc.add(
                                                  GetProductsWithoutFiltersEvent(
                                                      offset: 1,
                                                      category: homeState
                                                          .mainCategoriesResponseModel!
                                                          .data!
                                                          .mainCategories![index]
                                                          .slug!,
                                                      selectedProssesType:
                                                          'category'));*/
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SvgNetworkWidget(
                                                                svgUrl: mainCategory
                                                                    .flatPhotoPath!
                                                                    .filePath
                                                                    .toString(),
                                                                height: 20,
                                                                color: categoryIndexTap ==
                                                                        index
                                                                    ? Colors
                                                                        .black
                                                                    : Color(
                                                                        0xffC4C2C2),
                                                              ),
                                                              4.verticalSpace,
                                                              MyTextWidget(
                                                                mainCategory
                                                                    .name
                                                                    .toString(),
                                                                maxLines: 1,
                                                                style: textTheme.overline?.lr.copyWith(
                                                                    letterSpacing:
                                                                        0,
                                                                    color: state.tabIndex !=
                                                                            index
                                                                        ? Color(
                                                                            0xffC4C2C2)
                                                                        : Color(
                                                                            0xff505050)),
                                                              ),
                                                            ],
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            left: 0,
                                                            child: Visibility(
                                                                visible:
                                                                    categoryIndexTap ==
                                                                        index,
                                                                child:
                                                                    FilterSelectedMark(
                                                                        width:
                                                                            12,
                                                                        height:
                                                                            12)),
                                                          )
                                                        ],
                                                      ),
                                                    ));
                                              },
                                            )),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                )
                              ]),
                        ));
                  });
            }));
  }
}
