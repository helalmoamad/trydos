import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter_ranges.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter_slider.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/sizes_filters_list.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
import 'package:tuple/tuple.dart';
import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/get_product_filters_model.dart' as filter_model;
import '../../manager/homeBloc/home_bloc.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'categories_filter_list.dart';
import 'color_list_filter.dart';
import 'filters_loding_list.dart';
import 'filters_normal_list.dart';

class StackedFiltersList extends StatefulWidget {
  const StackedFiltersList({
    super.key,
    required this.onMoveToAnotherFiltersSection,
    this.controller,
    required this.boutiqueSlug,
    required this.expandingFiltersStack,
    required this.filterPageExpanded,
    required this.displayAppliedFiltersOnly,
    this.category,
    this.searchText,
    required this.fromSearch,
    required this.textController,
    required this.closeFilterPage,
    required this.hideTitle,
  });

  final void Function() closeFilterPage;
  final void Function(String message) onMoveToAnotherFiltersSection;
  final ScrollController? controller;
  final bool hideTitle;
  final bool filterPageExpanded;
  final bool fromSearch;

  final String? searchText;
  final ValueNotifier<int> expandingFiltersStack;
  final TextEditingController textController;
  final String boutiqueSlug;
  final String? category;
  final bool displayAppliedFiltersOnly;

  @override
  _StackedFiltersListState createState() => _StackedFiltersListState();
}

class _StackedFiltersListState extends State<StackedFiltersList> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack = ValueNotifier(
    false,
  );

  final ValueNotifier<int> currentActiveSection = ValueNotifier(0);
  late AutoScrollController autoScrollController;
  ValueNotifier<Tuple2<double, double>>? lowerAndUpperPrices;

  int lastSectionDisplayed = 0;
  double? minPrice;
  double? maxPrice;
  String currencySymbol = '';
  late BoutiqueBloc boutiqueBloc;
  double exchangeRate = 0.0;
  filter_model.Filter? filters;
  bool isExpanded = false;

  String key = '';
  Timer? debounce;
  @override
  void initState() {
    key = widget.boutiqueSlug + (widget.category ?? '');
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    autoScrollController = AutoScrollController();
    autoScrollController.addListener(() {
      try {
        if (debounce?.isActive ?? false) {
          debounce!.cancel();
        }
        debounce = Timer(const Duration(milliseconds: 600), () {
          if (autoScrollController.offset >=
              (autoScrollController.position.maxScrollExtent * 0.6)) {
            boutiqueBloc.add(
              GetFiltersWithPaginatioEvent(
                fromHomePageSearch: true,
                searchText: widget.searchText,
                category: widget.category,
                boutiqueSlug: widget.boutiqueSlug,
              ),
            );
          }
        });
      } catch (e) {}
    });
    super.initState();
  }

  @override
  void dispose() {
    autoScrollController.dispose();
    lowerAndUpperPrices?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    /*FlutterError.onError = (FlutterErrorDetails error) {
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
    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
      buildWhen: (previous, current) =>
          previous.appliedFiltersByUser[key] !=
              current.appliedFiltersByUser[key] ||
          previous.choosedFiltersByUser[key] !=
              current.choosedFiltersByUser[key] ||
          previous.isExpandedForListingPage !=
              current.isExpandedForListingPage ||
          previous.getProductFiltersStatus[key] !=
              current.getProductFiltersStatus[key] ||
          previous
                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                      'withoutFilter' +
                      '${(widget.category ?? '')}']
                  ?.paginationStatus !=
              current
                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                      'withoutFilter' +
                      '${(widget.category ?? '')}']
                  ?.paginationStatus ||
          previous
                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                      '${(widget.category ?? '')}']
                  ?.paginationStatus !=
              current
                  .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                      '${(widget.category ?? '')}']
                  ?.paginationStatus ||
          previous.cashedOrginalBoutique != current.cashedOrginalBoutique,
      builder: (context, state) {
        isExpanded = state.isExpandedForListingPage ?? false;
        if ((state.getProductFiltersStatus[key] ==
                GetProductFiltersStatus.loading &&
            state.getProductFiltersStatus[key] == null)) {
          return FiltersLoadingListPage(countOfListInPage: isExpanded ? 6 : 1);
        }
        if (state.getProductFiltersModel[key]?.filters?.totalSize == 0 &&
            isExpanded) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: 150.h),
                state.getProductFiltersStatus[key] ==
                        GetProductFiltersStatus.loading
                    ? Center(child: TrydosLoader(size: 20.h))
                    : Center(
                        child: MyTextWidget(
                          "${LocaleKeys.no_filters_found.tr()}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                SizedBox(height: 100.h),
                Container(
                  width: 200.w,
                  child: InkWell(
                    onTap: () {
                      widget.textController.text = "";
                      if (lowerAndUpperPrices != null) {
                        lowerAndUpperPrices!.value = Tuple2(
                          minPrice!,
                          maxPrice!,
                        );
                      }

                      boutiqueBloc.add(
                        AddPrefAppliedFilterForExtendFilterEvent(
                          prefAppliedFilter: Filter(),
                        ),
                      );
                      boutiqueBloc.add(
                        ChangeAppliedFiltersEvent(
                          resetAppliedFilters: true,
                          boutiqueSlug: widget.boutiqueSlug,
                          category: widget.category,
                        ),
                      );

                      boutiqueBloc.add(
                        ChangeSelectedFiltersEvent(
                          fromHomePageSearch: widget.fromSearch,
                          boutiqueSlug: widget.boutiqueSlug,
                          category: widget.category,
                          resetChoosedFilters: true,
                        ),
                      );
                      boutiqueBloc.add(
                        GetProductsWithFiltersEvent(
                          fromSearch: widget.fromSearch,
                          boutiqueSlug: widget.boutiqueSlug,
                          cashedOrginalBoutique: true,
                          category: widget.category,
                          offset: 1,
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 65.h,
                          decoration: BoxDecoration(
                            color: colorScheme.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                                inset: true,
                              ),
                            ],
                            border: Border.all(color: const Color(0xff388CFF)),
                          ),
                          child: Center(
                            child: MyTextWidget(
                              '${LocaleKeys.reset.tr()}',
                              style: textTheme.bodyLarge?.rq.copyWith(
                                color: const Color(0xff388CFF),
                                height: 23 / 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        // if (state.getProductFiltersStatus == GetProductFiltersStatus.failure) {
        //   return Center(child: TryAgainWidget(tryAgain: () {
        //     BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent());
        //   }));
        // }
        if ((state.getProductFiltersModel[key]?.filters == null &&
            state.cashedOrginalBoutique &&
            state.appliedFiltersByUser[key] == null)) {
          return const SizedBox.shrink();
        }
        //GetProductFiltersModel? appliedFiltersByUser =
        // state.appliedFiltersByUser[key];
        //String? currentAppliedFilterSllug = "Empty";
        /*   if (!isExpanded &&
              (appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3) {
            if ((appliedFiltersByUser?.filters?.categories?.length ?? 0) > 0) {
              currentAppliedFilterSllug =
                  appliedFiltersByUser?.filters?.categories?[0].slug;
            } else if ((appliedFiltersByUser?.filters?.brands?.length ?? 0) >
                0) {
              currentAppliedFilterSllug =
                  appliedFiltersByUser?.filters?.brands?[0].slug;
            } else if ((((appliedFiltersByUser
                                ?.filters?.attributes?.isNullOrEmpty ??
                            false)
                        ? 0
                        : appliedFiltersByUser
                            ?.filters?.attributes?[0].options?.length) ??
                    0) >
                0) {
              currentAppliedFilterSllug =
                  appliedFiltersByUser?.filters?.attributes?[0].options?[0];
            } else if ((appliedFiltersByUser?.filters?.colors?.length ?? 0) >
                0) {
              appliedFiltersByUser?.filters?.colors?[0];
            } else if (appliedFiltersByUser?.filters?.prices?.minPrice !=
                null) {
              currentAppliedFilterSllug =
                  "${appliedFiltersByUser?.filters?.prices?.minPrice}-${appliedFiltersByUser?.filters?.prices?.maxPrice}";
            } else {
              currentAppliedFilterSllug = "Empty";
            }
          }*/
        /*  if ((appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3 &&
              !isExpanded &&
              (((appliedFiltersByUser?.filters?.categories?.length ?? 0) +
                              (appliedFiltersByUser?.filters?.brands?.length ??
                                  0) +
                              (appliedFiltersByUser?.filters?.colors?.length ??
                                  0) +
                              (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ??
                                  0) ==
                          1 &&
                      !widget.fromSearch &&
                      !isExpanded &&
                      (appliedFiltersByUser?.filters?.prices?.minPrice ==
                          null)) ||
                  ((appliedFiltersByUser?.filters?.categories?.length ?? 0) +
                              (appliedFiltersByUser?.filters?.brands?.length ??
                                  0) +
                              (appliedFiltersByUser?.filters?.colors?.length ??
                                  0) +
                              (((appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ?? false) ? 0 : appliedFiltersByUser?.filters?.attributes?[0].options?.length) ??
                                  0) ==
                          0 &&
                      !widget.fromSearch &&
                      (appliedFiltersByUser?.filters?.prices?.minPrice !=
                          null))) &&
              (state.getProductListingWithFiltersPaginationWithPrefetchModels["${widget.boutiqueSlug}" + "${currentAppliedFilterSllug}" + "${widget.category ?? ""}"]?.paginationStatus ==
                  PaginationStatus.success)) {
            filters = (state
                            .getProductListingWithFiltersPaginationWithPrefetchModels[
                                '${widget.boutiqueSlug}' +
                                    '${currentAppliedFilterSllug}' +
                                    '${(widget.category ?? '')}']
                            ?.items
                            .length ??
                        0) ==
                    1
                ? filter_model.Filter()
                : state
                        .getProductFiltersWithPrefetchModel[
                            '${widget.boutiqueSlug}' +
                                '${currentAppliedFilterSllug}' +
                                '${(widget.category ?? '')}']
                        ?.filters ??
                    filter_model.Filter();
          } else*/
        /*   if (((!widget.fromSearch &&
                  !isExpanded &&
                  (appliedFiltersByUser?.filters?.prices?.minPrice == null))) &&
              currentAppliedFilterSllug == "Empty" &&
              state
                      .getProductFiltersWithPrefetchModel[
                          '${widget.boutiqueSlug}' +
                              'Empty' +
                              '${(widget.category ?? '')}']
                      ?.filters !=
                  null &&
              (state
                      .getProductListingWithFiltersPaginationWithPrefetchModels[
                          "${widget.boutiqueSlug}" +
                              "Empty" +
                              "${widget.category ?? ""}"]
                      ?.paginationStatus ==
                  PaginationStatus.success)) {
            if ((appliedFiltersByUser?.filters?.searchText?.length ?? 0) < 3) {
              filters = (state
                              .getProductListingWithFiltersPaginationWithPrefetchModels[
                                  '${widget.boutiqueSlug}' +
                                      'Empty' +
                                      '${(widget.category ?? '')}']
                              ?.items
                              .length ??
                          0) ==
                      1
                  ? filter_model.Filter()
                  : state
                      .getProductFiltersWithPrefetchModel[
                          '${widget.boutiqueSlug}' +
                              'Empty' +
                              '${(widget.category ?? '')}']
                      ?.filters;
            }*/
        /* if {
              filters = (state
                              .getProductFiltersModel['${widget.boutiqueSlug}' +
                                  '${(widget.category ?? '')}']
                              ?.filters
                              ?.totalSize ??
                          0) ==
                      1
                  ? filter_model.Filter()
                  : state
                      .getProductFiltersModel['${widget.boutiqueSlug}' +
                          '${(widget.category ?? '')}']
                      ?.filters;
            }
          }*/
        else {
          filters =
              (state
                              .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                                  '${(widget.category ?? '')}']
                              ?.items
                              .length ??
                          0) ==
                      1 &&
                  !isExpanded &&
                  state
                          .getProductListingWithFiltersPaginationModels['${widget.boutiqueSlug}' +
                              '${state.cashedOrginalBoutique ? 'withoutFilter' : ""}' +
                              '${(widget.category ?? '')}']
                          ?.paginationStatus ==
                      PaginationStatus.success &&
                  state.getProductFiltersStatus[key] ==
                      GetProductFiltersStatus.success
              ? filter_model.Filter()
              : state.getProductFiltersModel[key]?.filters ??
                    filter_model.Filter();
        }

        if (filters?.prices != null) {
          exchangeRate =
              BlocProvider.of<HomeBloc>(context)
                  .state
                  .getCurrencyForCountryModel
                  ?.data
                  ?.currency
                  ?.exchangeRate ??
              1;
          currencySymbol =
              BlocProvider.of<HomeBloc>(
                context,
              ).state.getCurrencyForCountryModel?.data?.currency?.symbol ??
              '\$';
          minPrice = (filters?.prices!.minPrice ?? 0) * exchangeRate;
          maxPrice = (filters?.prices!.maxPrice ?? 0) * exchangeRate;
          lowerAndUpperPrices = ValueNotifier(Tuple2(minPrice!, maxPrice!));
        }
        int countOfFilters = 0;
        List<String> titleOfFilterSection = [];
        if (filters == null) {
          filters = Filter();
        }
        if (!filters!.categories.isNullOrEmpty) {
          countOfFilters++;
          titleOfFilterSection.add(
            '${LocaleKeys.view_by.tr()} ${LocaleKeys.categories.tr()}',
          );
        }
        if (!filters!.brands.isNullOrEmpty) {
          countOfFilters++;
          titleOfFilterSection.add(
            '${LocaleKeys.view_by.tr()} ${LocaleKeys.Brands.tr()}',
          );
        }
        if (!filters!.attributes.isNullOrEmpty) {
          if (!filters!.attributes![0].options.isNullOrEmpty) {
            countOfFilters++;
            titleOfFilterSection.add(
              '${LocaleKeys.view_by.tr()} ${LocaleKeys.sizes.tr()}',
            );
          }
        }
        if (!filters!.colors.isNullOrEmpty) {
          countOfFilters++;
          titleOfFilterSection.add(
            '${LocaleKeys.view_by.tr()} ${LocaleKeys.colors.tr()}',
          );
        }
        if (filters!.prices != null) {
          countOfFilters++;
          titleOfFilterSection.add(
            '${LocaleKeys.view_by.tr()} ${LocaleKeys.prices.tr()}',
          );
        }
        if (countOfFilters == 0 &&
            state.appliedFiltersByUser[key] == null &&
            state.cashedOrginalBoutique) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            if (countOfFilters != 0) ...{
              if (isExpanded) ...{
                !filters!.categories.isNullOrEmpty
                    ? Padding(
                        padding: EdgeInsetsDirectional.only(start: 25.w),
                        child: Row(
                          key: TestVariables.kTestMode
                              ? const Key(WidgetsKeys.filterByCategoryHeadKey)
                              : null,
                          children: [
                            FilterSelectedMark(width: 20.w, height: 20.h),
                            SizedBox(width: 10.w),
                            MyTextWidget(
                              '${LocaleKeys.filter_by.tr()} ${LocaleKeys.categories.tr()}',
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff505050),
                                height: 15 / 12,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            SvgPicture.asset(
                              AppAssets.registerInfoSvg,
                              // ignore: deprecated_member_use
                              color: const Color(0xffD3D3D3),
                            ),
                            if (state.getProductFiltersStatus[key] ==
                                GetProductFiltersStatus.loading)
                              Row(
                                key: TestVariables.kTestMode
                                    ? const Key(
                                        WidgetsKeys.getCategoriesLoadingKey,
                                      )
                                    : null,
                                children: [
                                  SizedBox(width: 5.w),
                                  TrydosLoader(size: 20.h),
                                ],
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(height: 10.h),
              },
              if ((widget.displayAppliedFiltersOnly && !isExpanded)) ...{
                const SizedBox.shrink(),
              },
              if ((!widget.displayAppliedFiltersOnly && !isExpanded) ||
                  isExpanded) ...{
                SizedBox(
                  height: 110.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: isExpanded ? 20.w : 15.w),
                      Visibility(
                        visible: !isExpanded,
                        child: InkWell(
                          onTap: () {
                            currentActiveSection.value =
                                currentActiveSection.value ==
                                    (countOfFilters - 1)
                                ? 0
                                : (currentActiveSection.value + 1);
                            autoScrollController.scrollToIndex(
                              2 * currentActiveSection.value,
                              duration: const Duration(milliseconds: 200),
                              preferPosition: AutoScrollPosition.begin,
                            );
                            widget.onMoveToAnotherFiltersSection.call(
                              titleOfFilterSection[currentActiveSection.value],
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 35.w),
                            child: ValueListenableBuilder<int>(
                              valueListenable: currentActiveSection,
                              builder: (context, currentActive, _) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 8.h,
                                      child: ListView.builder(
                                        itemCount: countOfFilters,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (ctx, index) {
                                          return Row(
                                            children: [
                                              Container(
                                                height: 8.h,
                                                width: 8.w,
                                                decoration: BoxDecoration(
                                                  color: currentActive == index
                                                      ? const Color(0xff505050)
                                                      : null,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xff505050,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width:
                                                    index !=
                                                        (countOfFilters - 1)
                                                    ? 2
                                                    : 0,
                                                color: Colors.transparent,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      /*
                 key: Key('$index-section'),
                                      onVisibilityChanged: (visibilityInfo) {
                                        if (autoScrollController.hasClients &&
                                            autoScrollController.position
                                                    .userScrollDirection ==
                                                rendring.ScrollDirection.idle) {
                                          return;
                                        }
                                        if (isExpanded) return;
                                        double visiblePercentage =
                                            visibilityInfo.visibleFraction *
                                                100;
                                        if (visiblePercentage == 0) {
                                          if ((int.parse(visibilityInfo.key
                                                  .toString()[3]) !=
                                              (2 *
                                                  currentActiveSection
                                                      .value))) {
                                            return;
                                          }
                                          int sectionIndex = -1;
                                          // scroll to the right
                                          if (autoScrollController.hasClients &&
                                              autoScrollController.position
                                                      .userScrollDirection ==
                                                  rendring.ScrollDirection
                                                      .reverse) {
                                            sectionIndex = (int.parse(
                                                        visibilityInfo.key
                                                            .toString()[3]) +
                                                    2) ~/
                                                2;
                                          } else {
                                            sectionIndex = (int.parse(
                                                        visibilityInfo.key
                                                            .toString()[3]) -
                                                    2) ~/
                                                2;
                                          }
                                          currentActiveSection.value =
                                              max(0, sectionIndex);
                                          widget.onMoveToAnotherFiltersSection
                                              .call(titleOfFilterSection[
                                                  currentActiveSection.value]);
                                        }
                                      },
                 */
                      ScrollConfiguration(
                        key: TestVariables.kTestMode
                            ? const Key(WidgetsKeys.filterPageScrollKey)
                            : null,
                        behavior: const CupertinoScrollBehavior(),
                        child: Expanded(
                          child: InViewNotifierList(
                            key: TestVariables.kTestMode == false
                                ? null
                                : const Key(
                                    WidgetsKeys.productListingFilterListKey,
                                  ),
                            isInViewPortCondition:
                                (
                                  double deltaTop,
                                  double deltaBottom,
                                  double vpWidth,
                                ) {
                                  return deltaTop <= (0.5 * vpWidth) &&
                                      deltaBottom >= (0.7 * vpWidth);
                                },
                            controller: autoScrollController,
                            itemCount: isExpanded ? 1 : 2 * countOfFilters - 1,
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                              left: LanguageService.rtl ? 0 : 5.w,
                              right: !LanguageService.rtl ? 0 : 5.w,
                            ),
                            builder: (ctx, index) {
                              if (index & 1 == 0)
                                return InViewNotifierWidget(
                                  id: 'id-$index',
                                  builder:
                                      (
                                        BuildContext context,
                                        bool isInView,
                                        Widget? child,
                                      ) {
                                        if (isInView &&
                                            currentActiveSection.value !=
                                                (index ~/ 2)) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((
                                                timeStamp,
                                              ) {
                                                currentActiveSection.value =
                                                    index ~/ 2;
                                                widget
                                                    .onMoveToAnotherFiltersSection
                                                    .call(
                                                      titleOfFilterSection[index ~/
                                                          2],
                                                    );
                                              });
                                        }
                                        return child!;
                                      },
                                  child: AutoScrollTag(
                                    key: ValueKey(
                                      '${DateTime.now()}index $index',
                                    ),
                                    controller: autoScrollController,
                                    index: index,
                                    child:
                                        index == 0 &&
                                            titleOfFilterSection[index ~/ 2] ==
                                                '${LocaleKeys.view_by.tr()} ${LocaleKeys.categories.tr()}'
                                        ? CategoriesFilterList(
                                            filterss: filters ?? Filter(),
                                            key:
                                                TestVariables.kTestMode == false
                                                ? null
                                                : const Key(
                                                    WidgetsKeys
                                                        .categoriesProductListingFilterListKey,
                                                  ),
                                            boutiqueSlug: widget.boutiqueSlug,
                                            fromSearch: widget.fromSearch,
                                            expandingFiltersStack:
                                                widget.expandingFiltersStack,
                                            scaleTheTopItemInFiltersStack:
                                                scaleTheTopItemInFiltersStack,
                                            controller: widget.textController,
                                            workWithChoosedFilter: isExpanded,
                                            category: widget.category,
                                          )
                                        : index <= 2 &&
                                              titleOfFilterSection[index ~/
                                                      2] ==
                                                  '${LocaleKeys.view_by.tr()} ${LocaleKeys.Brands.tr()}'
                                        ? FiltersNormalList(
                                            key:
                                                TestVariables.kTestMode == false
                                                ? null
                                                : const Key(
                                                    WidgetsKeys
                                                        .brandsProductListingFilterListKey,
                                                  ),
                                            hideTitle: true,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            fromHomeSearch: widget.fromSearch,
                                            searchText: widget.searchText,
                                            category: widget.category,
                                            filterListTitle:
                                                '${LocaleKeys.filter_by.tr()} ${LocaleKeys.Brands.tr()}',
                                            isBrandFilter: true,
                                            filters: filters!.brands ?? [],
                                          )
                                        : index <= 4 &&
                                              titleOfFilterSection[index ~/
                                                      2] ==
                                                  '${LocaleKeys.view_by.tr()} ${LocaleKeys.sizes.tr()}'
                                        ? SizesFiltersList(
                                            key:
                                                TestVariables.kTestMode == false
                                                ? null
                                                : const Key(
                                                    WidgetsKeys
                                                        .sizesProductListingFilterListKey,
                                                  ),
                                            hideTitle: true,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            fromHomeSearch: widget.fromSearch,
                                            searchText: widget.searchText,
                                            category: widget.category,
                                            attribute: filters!.attributes![0],
                                          )
                                        : index <= 6 &&
                                              titleOfFilterSection[index ~/
                                                      2] ==
                                                  '${LocaleKeys.view_by.tr()} ${LocaleKeys.colors.tr()}'
                                        ? ColorsListFilter(
                                            key:
                                                TestVariables.kTestMode == false
                                                ? null
                                                : const Key(
                                                    WidgetsKeys
                                                        .colorsProductListingFilterListKey,
                                                  ),
                                            hideTitle: true,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            fromHomeSearch: widget.fromSearch,
                                            searchText: widget.searchText,
                                            category: widget.category,
                                            colors: filters!.colors ?? [],
                                          )
                                        : PriceFiltersRangesList(
                                            exchangeRate:
                                                BlocProvider.of<HomeBloc>(
                                                      context,
                                                    )
                                                    .state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!,
                                            key:
                                                TestVariables.kTestMode == false
                                                ? null
                                                : const Key(
                                                    WidgetsKeys
                                                        .pricesProductListingFilterListKey,
                                                  ),
                                            decimalPoint:
                                                BlocProvider.of<HomeBloc>(
                                                      context,
                                                    )
                                                    .state
                                                    .startingSetting
                                                    ?.decimalPointSettings ??
                                                2,
                                            fromHomeSearch: widget.fromSearch,
                                            searchText: widget.searchText,
                                            boutiqueSlug: widget.boutiqueSlug,
                                            currencySymbol: currencySymbol,
                                            category: widget.category,
                                            priceRanges:
                                                filters!.prices?.priceRanges ??
                                                [],
                                          ),
                                  ),
                                );
                              return Container(
                                margin: EdgeInsetsDirectional.only(
                                  top: 10.h,
                                  end: 10.w,
                                  start:
                                      (index - 1) == 0 &&
                                          titleOfFilterSection[0] ==
                                              '${LocaleKeys.view_by.tr()} ${LocaleKeys.categories.tr()}'
                                      ? 0
                                      : 10.w,
                                  bottom: 45.h,
                                ),
                                width: 0.5,
                                color: const Color(0xff707070),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              },
              if (isExpanded) ...{
                SizedBox(height: 10.h),
                !filters!.brands.isNullOrEmpty
                    ? FiltersNormalList(
                        filterListTitle:
                            '${LocaleKeys.filter_by.tr()} ${LocaleKeys.Brands.tr()}',
                        boutiqueSlug: widget.boutiqueSlug,
                        fromHomeSearch: widget.fromSearch,
                        searchText: widget.searchText,
                        category: widget.category,
                        isBrandFilter: true,
                        filters: filters!.brands ?? [],
                      )
                    : const SizedBox.shrink(),
                !filters!.colors.isNullOrEmpty
                    ? ColorsListFilter(
                        boutiqueSlug: widget.boutiqueSlug,
                        fromHomeSearch: widget.fromSearch,
                        searchText: widget.searchText,
                        category: widget.category,
                        colors: filters!.colors ?? [],
                      )
                    : const SizedBox.shrink(),
                FiltersNormalList(
                  filterListTitle:
                      '${LocaleKeys.filter_by.tr()} ${LocaleKeys.offer.tr()}',
                  boutiqueSlug: widget.boutiqueSlug,
                  fromHomeSearch: widget.fromSearch,
                  searchText: widget.searchText,
                  category: widget.category,
                  isBrandFilter: false,
                  filters: const [],
                ),
                if (filters!.prices != null)
                  PriceFilter(
                    exchangeRate: BlocProvider.of<HomeBloc>(context)
                        .state
                        .getCurrencyForCountryModel!
                        .data!
                        .currency!
                        .exchangeRate!,
                    pricrRate: BlocProvider.of<HomeBloc>(context)
                        .state
                        .getCurrencyForCountryModel!
                        .data!
                        .currency!
                        .exchangeRate!,
                    hideTitle: widget.hideTitle,
                    fromHomeSearch: widget.fromSearch,
                    searchText: widget.searchText,
                    maxPrice: maxPrice!,
                    minPrice: minPrice!,
                    lowerAndUpperBound: lowerAndUpperPrices!,
                    decimalPoint:
                        BlocProvider.of<HomeBloc>(
                          context,
                        ).state.startingSetting?.decimalPointSettings ??
                        2,
                    boutiqueSlug: widget.boutiqueSlug,
                    category: widget.category,
                    pricrSymbol: currencySymbol,
                    pricesFiltersRanges: filters!.prices!,
                  ),
                if (!filters!.attributes.isNullOrEmpty)
                  SizesFiltersList(
                    fromHomeSearch: widget.fromSearch,
                    searchText: widget.searchText,
                    boutiqueSlug: widget.boutiqueSlug,
                    category: widget.category,
                    attribute: filters!.attributes![0],
                  ),
              },
            },
            if (!isExpanded) ...{
              Container(
                padding: EdgeInsets.only(
                  top:
                      (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.attributes
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.colors
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.brands
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.boutiques
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
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
                              (GetIt.I<PrefsRepository>()
                                  .getTagsInUrlToFilter
                                  .isNullOrEmpty) ||
                              (state
                                          .appliedFiltersByUser[key]
                                          ?.filters
                                          ?.searchText
                                          ?.length ??
                                      0) <
                                  2) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.prices
                                  ?.maxPrice ==
                              null) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.prices
                                  ?.minPrice ==
                              null)
                      ? 0
                      : 5.h,
                ),
                color: const Color(0xffF8F8F8),
                child: Container(
                  width: 1.sw,
                  height:
                      (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.attributes
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.colors
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.brands
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.boutiques
                                  ?.isNullOrEmpty ??
                              true) &&
                          (state
                                  .appliedFiltersByUser[key]
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
                          (GetIt.I<PrefsRepository>()
                              .getTagsInUrlToFilter
                              .isNullOrEmpty) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.prices
                                  ?.maxPrice ==
                              null) &&
                          (state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.prices
                                  ?.minPrice ==
                              null)
                      ? 0
                      : 30.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.only(left: 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xffEFEFEF),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: choosedOrAppliedFiltersWidget(
                    controller: widget.textController,
                    boutiqueSlug: widget.boutiqueSlug,
                    context: context,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    category: widget.category,
                    choosedFilter: isExpanded,
                    fromSearch: widget.fromSearch,
                    lowerAndUpperPrices: lowerAndUpperPrices,
                  ),
                ),
              ),
            },
            if (countOfFilters != 0 ||
                state.choosedFiltersByUser[key] != null) ...{
              if (isExpanded) ...{
                SizedBox(height: 20.h),
                Column(
                  children: [
                    ValueListenableBuilder<Tuple2<double, double>>(
                      valueListenable:
                          lowerAndUpperPrices ??
                          ValueNotifier(const Tuple2(-1, -1)),
                      builder: (context, _, __) {
                        return Container(
                          width: 1.sw,
                          height:
                              (!((state
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
                                      (state
                                              .choosedFiltersByUser[key]
                                              ?.filters
                                              ?.searchText
                                              ?.isEmpty ??
                                          true) &&
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
                                          null)) ||
                                  (lowerAndUpperPrices != null &&
                                      (lowerAndUpperPrices!.value.item1 >
                                              minPrice! ||
                                          lowerAndUpperPrices!.value.item2 <
                                              maxPrice!)))
                              ? 65.h
                              : 0,
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: colorScheme.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5.h,
                                ).copyWith(left: 10.w),
                                child: MyTextWidget(
                                  '${LocaleKeys.the_products_will_be_shown_as_below.tr()}',
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff505050),
                                        height: 15 / 12,
                                      ),
                                ),
                              ),
                              Container(
                                width: 1.sw,
                                height:
                                    (!((state
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
                                                        .choosedFiltersByUser[key]
                                                        ?.filters
                                                        ?.searchText
                                                        ?.isEmpty ??
                                                    true) ||
                                                (state
                                                            .choosedFiltersByUser[key]
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
                                                null)) ||
                                        !(GetIt.I<PrefsRepository>()
                                            .getTagsInUrlToFilter
                                            .isNullOrEmpty) ||
                                        (lowerAndUpperPrices != null &&
                                            (lowerAndUpperPrices!.value.item1 >
                                                    minPrice! ||
                                                lowerAndUpperPrices!
                                                        .value
                                                        .item2 <
                                                    maxPrice!)))
                                    ? 30.h
                                    : 0,
                                padding: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEFEFEF),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: SizedBox(
                                  height: 18.h,
                                  child: choosedOrAppliedFiltersWidget(
                                    controller: widget.textController,
                                    boutiqueSlug: widget.boutiqueSlug,
                                    context: context,
                                    minPrice: minPrice,
                                    maxPrice: maxPrice,
                                    category: widget.category,
                                    choosedFilter: isExpanded,
                                    fromSearch: widget.fromSearch,
                                    lowerAndUpperPrices: lowerAndUpperPrices,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    ValueListenableBuilder<Tuple2<double, double>>(
                      valueListenable:
                          lowerAndUpperPrices ??
                          ValueNotifier(const Tuple2(-1, -1)),
                      builder: (context, _, __) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            children: [
                              if (state.choosedFiltersByUser[key] != null ||
                                  (lowerAndUpperPrices != null &&
                                      (lowerAndUpperPrices!.value.item1 >
                                              minPrice! ||
                                          lowerAndUpperPrices!.value.item2 <
                                              maxPrice!))) ...{
                                Expanded(
                                  flex: 5,
                                  child: InkWell(
                                    key: TestVariables.kTestMode
                                        ? const Key(
                                            WidgetsKeys.applayFilterButtonKey,
                                          )
                                        : null,
                                    onTap: () {
                                      List<filter_model.Brand>? brands = [
                                        ...state
                                                .appliedFiltersByUser[key]
                                                ?.filters
                                                ?.brands ??
                                            [],
                                        ...state
                                                .choosedFiltersByUser[key]
                                                ?.filters
                                                ?.brands ??
                                            [],
                                      ];
                                      List<product_listing.Category>?
                                      categories = [
                                        ...state
                                                .appliedFiltersByUser[key]
                                                ?.filters
                                                ?.categories ??
                                            [],
                                        ...state
                                                .choosedFiltersByUser[key]
                                                ?.filters
                                                ?.categories ??
                                            [],
                                      ];
                                      List<filter_model.Boutique>? boutiques = [
                                        ...state
                                                .appliedFiltersByUser[key]
                                                ?.filters
                                                ?.boutiques ??
                                            [],
                                        ...state
                                                .choosedFiltersByUser[key]
                                                ?.filters
                                                ?.boutiques ??
                                            [],
                                      ];
                                      List<String>? colors = [
                                        ...state
                                                .appliedFiltersByUser[key]
                                                ?.filters
                                                ?.colors ??
                                            [],
                                        ...state
                                                .choosedFiltersByUser[key]
                                                ?.filters
                                                ?.colors ??
                                            [],
                                      ];
                                      Prices prices =
                                          state
                                              .choosedFiltersByUser[key]
                                              ?.filters
                                              ?.prices ??
                                          Prices();
                                      List<String> options = [];
                                      int? id;
                                      String? name;
                                      if (!(state
                                              .appliedFiltersByUser[key]
                                              ?.filters
                                              ?.attributes
                                              ?.isNullOrEmpty ??
                                          true)) {
                                        id = state
                                            .appliedFiltersByUser[key]!
                                            .filters!
                                            .attributes![0]
                                            .id;
                                        name = state
                                            .appliedFiltersByUser[key]!
                                            .filters!
                                            .attributes![0]
                                            .name;
                                        options.addAll(
                                          state
                                                  .appliedFiltersByUser[key]!
                                                  .filters!
                                                  .attributes![0]
                                                  .options ??
                                              [],
                                        );
                                      }
                                      if (!(state
                                              .choosedFiltersByUser[key]
                                              ?.filters
                                              ?.attributes
                                              ?.isNullOrEmpty ??
                                          true)) {
                                        id = state
                                            .choosedFiltersByUser[key]!
                                            .filters!
                                            .attributes![0]
                                            .id;
                                        name = state
                                            .choosedFiltersByUser[key]!
                                            .filters!
                                            .attributes![0]
                                            .name;
                                        options.addAll(
                                          state
                                                  .choosedFiltersByUser[key]!
                                                  .filters!
                                                  .attributes![0]
                                                  .options ??
                                              [],
                                        );
                                      }
                                      /* filter_model.Prices? prices;
                                      if ((lowerAndUpperPrices != null &&
                                          (lowerAndUpperPrices!.value.item1 /
                                                      exchangeRate >
                                                  minPrice! ||
                                              lowerAndUpperPrices!.value.item2 /
                                                      exchangeRate <
                                                  maxPrice!))) {
                                        prices = filter_model.Prices(
                                          minPrice:
                                              lowerAndUpperPrices!.value.item1 /
                                                  exchangeRate,
                                          maxPrice:
                                              lowerAndUpperPrices!.value.item2 /
                                                  exchangeRate,
                                        );
                                      }-*/
                                      boutiqueBloc.add(
                                        ChangeAppliedFiltersEvent(
                                          category: widget.category,
                                          boutiqueSlug: widget.boutiqueSlug,
                                          filtersAppliedByUser:
                                              filter_model.GetProductFiltersModel(
                                                filters: filter_model.Filter(
                                                  brands: brands,
                                                  categories: categories,
                                                  boutiques: boutiques,
                                                  searchText: widget
                                                      .textController
                                                      .text,
                                                  attributes: options.isEmpty
                                                      ? null
                                                      : [
                                                          filter_model.Attribute(
                                                            id: id,
                                                            name: name,
                                                            options: options,
                                                          ),
                                                        ],
                                                  colors: colors,
                                                  prices: prices,
                                                ),
                                              ),
                                        ),
                                      );
                                      //////////////////////////////////////////
                                      // FirebaseAnalyticsService
                                      //     .logEventForSession(
                                      //   eventName: AnalyticsEventsConst
                                      //       .buttonClicked,
                                      //   executedEventName:
                                      //       AnalyticsButtonsEventNameConst
                                      //           .applyFilterButton,
                                      // );

                                      //////////////////////////
                                      boutiqueBloc.add(
                                        GetProductsWithFiltersEvent(
                                          fromChoosed: true,
                                          fromSearch: widget.fromSearch,
                                          searchText:
                                              widget.textController.text,
                                          boutiqueSlug: widget.boutiqueSlug,
                                          category: widget.category,
                                          offset: 1,
                                        ),
                                      );
                                      widget.closeFilterPage.call();
                                    },
                                    child: Container(
                                      height: 54.h,
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
                                            color: Colors.white
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                            inset: true,
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
                                            if (state
                                                    .countOfProductExpectedByFiltering?[widget
                                                    .boutiqueSlug] !=
                                                null) ...{
                                              MyTextWidget(
                                                '( ${LocaleKeys.number_of_products.tr()} ${state.countOfProductExpectedByFiltering?[widget.boutiqueSlug]})',
                                                style: textTheme.bodyMedium?.mq
                                                    .copyWith(
                                                      fontSize: 12.sp,
                                                      color: const Color(
                                                        0xffFEFEFE,
                                                      ),
                                                      height: 1.2,
                                                    ),
                                              ),
                                            },
                                            MyTextWidget(
                                              ' ${LocaleKeys.apply.tr()}   ',
                                              style: textTheme.bodyLarge?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xffFEFEFE,
                                                    ),
                                                    height: 23 / 18,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5.w),
                              },
                              ValueListenableBuilder<Tuple2<double, double>>(
                                valueListenable:
                                    lowerAndUpperPrices ??
                                    ValueNotifier(const Tuple2(-1, -1)),
                                builder: (context, _, __) {
                                  return BlocBuilder<
                                    BoutiqueBloc,
                                    BoutiqueState
                                  >(
                                    builder: (context, state) {
                                      if (state.choosedFiltersByUser[key] ==
                                              null &&
                                          (lowerAndUpperPrices == null ||
                                              (lowerAndUpperPrices != null &&
                                                  (lowerAndUpperPrices!
                                                              .value
                                                              .item1 ==
                                                          minPrice! &&
                                                      lowerAndUpperPrices!
                                                              .value
                                                              .item2 ==
                                                          maxPrice!)))) {
                                        return const SizedBox.shrink();
                                      }
                                      return Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          onTap: () {
                                            widget.textController.text = "";
                                            if (lowerAndUpperPrices != null) {
                                              lowerAndUpperPrices!.value =
                                                  Tuple2(minPrice!, maxPrice!);
                                            }
                                            boutiqueBloc.add(
                                              AddPrefAppliedFilterForExtendFilterEvent(
                                                prefAppliedFilter: Filter(),
                                              ),
                                            );
                                            boutiqueBloc.add(
                                              ChangeAppliedFiltersEvent(
                                                resetAppliedFilters: true,
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                category: widget.category,
                                              ),
                                            );

                                            boutiqueBloc.add(
                                              ChangeSelectedFiltersEvent(
                                                fromHomePageSearch:
                                                    widget.fromSearch,
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                category: widget.category,
                                                resetChoosedFilters: true,
                                              ),
                                            );
                                            boutiqueBloc.add(
                                              GetProductsWithFiltersEvent(
                                                fromSearch: widget.fromSearch,
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                cashedOrginalBoutique: true,
                                                category: widget.category,
                                                offset: 1,
                                              ),
                                            );
                                            //////////////////////////////////////////
                                            // FirebaseAnalyticsService
                                            //     .logEventForSession(
                                            //   eventName:
                                            //       AnalyticsEventsConst
                                            //           .buttonClicked,
                                            //   executedEventName:
                                            //       AnalyticsButtonsEventNameConst
                                            //           .resetButton,
                                            // );
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 54.h,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          // ignore: deprecated_member_use
                                                          .withOpacity(0.1),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white
                                                          // ignore: deprecated_member_use
                                                          .withOpacity(0.4),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                      inset: true,
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xff388CFF,
                                                    ),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: MyTextWidget(
                                                    key: TestVariables.kTestMode
                                                        ? const Key(
                                                            WidgetsKeys
                                                                .resetFiltersKey,
                                                          )
                                                        : null,
                                                    '${LocaleKeys.reset.tr()}',
                                                    style: textTheme
                                                        .bodyLarge
                                                        ?.rq
                                                        .copyWith(
                                                          color: const Color(
                                                            0xff388CFF,
                                                          ),
                                                          height: 23 / 18,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              },
            },
          ],
        );
      },
    );
  }
}

Widget choosedOrAppliedFiltersWidget({
  required BuildContext context,
  final TextEditingController? controller,
  required String boutiqueSlug,
  String? category,
  bool choosedFilter = true,
  ValueNotifier<Tuple2<double, double>>? lowerAndUpperPrices,
  bool fromSearch = false,
  double? minPrice,
  double? maxPrice,
}) {
  String key = boutiqueSlug + (category ?? '');
  BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
  return BlocBuilder<BoutiqueBloc, BoutiqueState>(
    buildWhen: (p, c) =>
        p.choosedFiltersByUser[key]?.filters !=
            c.choosedFiltersByUser[key]?.filters ||
        p.appliedFiltersByUser[key]?.filters !=
            c.appliedFiltersByUser[key]?.filters,
    builder: (context, state) {
      filter_model.Filter? filters;
      filter_model.Filter? filtersForSearchText;
      if ((state.choosedFiltersByUser[key]?.filters?.searchText?.length ?? 0) >
          0) {
        filtersForSearchText = state.choosedFiltersByUser[key]?.filters;
      } else {
        filtersForSearchText = state.appliedFiltersByUser[key]?.filters;
      }

      if (choosedFilter) {
        filters = state.choosedFiltersByUser[key]?.filters;
      } else {
        filters = state.appliedFiltersByUser[key]?.filters;
      }
      String currencySymbol =
          BlocProvider.of<HomeBloc>(
            context,
          ).state.getCurrencyForCountryModel?.data?.currency?.symbol ??
          '\$';
      if (filters == null &&
          (!fromSearch && lowerAndUpperPrices == null) &&
          GetIt.I<PrefsRepository>().getTagsInUrlToFilter.isNullOrEmpty) {
        boutiqueBloc.add(
          const IscashedOreiginBotiqueEvent(iscashedOreiginBotique: true),
        );
        return const SizedBox.shrink();
      }
      if ((filters?.brands.isNullOrEmpty ?? true) &&
          (filters?.categories.isNullOrEmpty ?? true) &&
          filters?.prices == null &&
          (controller?.value == null && choosedFilter && fromSearch) &&
          (filters?.colors.isNullOrEmpty ?? true) &&
          (filters?.boutiques.isNullOrEmpty ?? true) &&
          (filters?.attributes.isNullOrEmpty ?? true) &&
          GetIt.I<PrefsRepository>().getTagsInUrlToFilter.isNullOrEmpty) {
        if ((!fromSearch && lowerAndUpperPrices == null && choosedFilter))
          boutiqueBloc.add(
            const IscashedOreiginBotiqueEvent(iscashedOreiginBotique: true),
          );
        return const SizedBox.shrink();
      }
      if ((filters?.brands.isNullOrEmpty ?? true) &&
          (filters?.categories.isNullOrEmpty ?? true) &&
          (filters?.prices?.minPrice == null ||
              filters?.prices?.minPrice == null) &&
          (controller!.text.length < 3) &&
          (filters?.colors.isNullOrEmpty ?? true) &&
          (filters?.boutiques.isNullOrEmpty ?? true) &&
          (filters?.attributes.isNullOrEmpty ?? true) &&
          GetIt.I<PrefsRepository>().getTagsInUrlToFilter.isNullOrEmpty) {
        boutiqueBloc.add(
          const IscashedOreiginBotiqueEvent(iscashedOreiginBotique: true),
        );
        return const SizedBox.shrink();
      }
      double exchangeRate =
          BlocProvider.of<HomeBloc>(
            context,
          ).state.getCurrencyForCountryModel?.data?.currency?.exchangeRate ??
          1;
      Widget widget = SizedBox(
        height: 25.h,
        width: 30.w,
        child: ListView(
          key: TestVariables.kTestMode == false
              ? null
              : const Key(WidgetsKeys.appliedFiltersProductListingKey),
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            if (!choosedFilter)
              InkWell(
                key: TestVariables.kTestMode == false
                    ? null
                    : const Key(
                        WidgetsKeys.appliedFiltersProductListingCloseKey,
                      ),
                onTap: () {
                  GetIt.I<PrefsRepository>().setTagsInUrlToFilter([]);

                  controller?.clear();
                  boutiqueBloc.add(
                    AddPrefAppliedFilterForExtendFilterEvent(
                      prefAppliedFilter: Filter(),
                    ),
                  );
                  boutiqueBloc.add(
                    ChangeAppliedFiltersEvent(
                      category: category,
                      resetAppliedFilters: true,
                      boutiqueSlug: boutiqueSlug,
                    ),
                  );
                  boutiqueBloc.add(
                    GetProductsWithFiltersEvent(
                      fromSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      cashedOrginalBoutique: true,
                      category: category,
                      offset: 1,
                    ),
                  );

                  boutiqueBloc.add(
                    ChangeSelectedFiltersEvent(
                      requestToUpdateFilters: false,
                      boutiqueSlug: boutiqueSlug,
                      category: category,
                      resetChoosedFilters: true,
                      fromHomePageSearch: fromSearch,
                    ),
                  );
                  boutiqueBloc.add(
                    GetFiltersEvent(
                      fromHomePageSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      cashedOrginalBoutique: true,
                      category: fromSearch ? null : category,
                    ),
                  );
                  ///////////////////////////////
                  // FirebaseAnalyticsService.logEventForSession(
                  //   eventName: AnalyticsEventsConst.buttonClicked,
                  //   executedEventName:
                  //       AnalyticsButtonsEventNameConst.resetCloseIconButton,
                  // );
                },
                child: Center(
                  child: Row(
                    children: [
                      SizedBox(width: 10.w),
                      SvgPicture.asset(
                        AppAssets.closeSvg,

                        height: 15.h,
                        // ignore: deprecated_member_use
                        color: const Color(0xffFF5F61),
                      ),
                      SizedBox(width: 10.w),
                    ],
                  ),
                ),
              ),
            if (choosedFilter)
              InkWell(
                key: TestVariables.kTestMode == false
                    ? null
                    : const Key(
                        WidgetsKeys.appliedFiltersProductListingCloseKey,
                      ),
                onTap: () {
                  GetIt.I<PrefsRepository>().setTagsInUrlToFilter([]);
                  controller?.clear();
                  boutiqueBloc.add(
                    ChangeAppliedFiltersEvent(
                      category: category,
                      resetAppliedFilters: true,
                      boutiqueSlug: boutiqueSlug,
                    ),
                  );
                  boutiqueBloc.add(
                    ChangeSelectedFiltersEvent(
                      category: category,
                      resetChoosedFilters: true,
                      boutiqueSlug: boutiqueSlug,
                      fromHomePageSearch: fromSearch,
                    ),
                  );

                  boutiqueBloc.add(
                    GetProductsWithFiltersEvent(
                      fromSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      cashedOrginalBoutique: true,
                      category: category,
                      offset: 1,
                    ),
                  );
                  ///////////////////////////////
                  // FirebaseAnalyticsService.logEventForSession(
                  //   eventName: AnalyticsEventsConst.buttonClicked,
                  //   executedEventName:
                  //       AnalyticsButtonsEventNameConst.resetCloseIconButton,
                  // );
                },
                child: Center(
                  child: Row(
                    children: [
                      SizedBox(width: 5.w),
                      SvgPicture.asset(
                        AppAssets.closeSvg,

                        height: 15.h,
                        // ignore: deprecated_member_use
                        color: const Color(0xffFF5F61),
                      ),
                      SizedBox(width: 5.w),
                    ],
                  ),
                ),
              ),
            if (choosedFilter)
              Center(
                child: MyTextWidget(
                  '${LocaleKeys.choosed.tr()}: ',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.bq.copyWith(
                    color: const Color(0xffFF5F61),
                    letterSpacing: 0,
                    height: 1.h,
                  ),
                ),
              )
            else
              Center(
                child: MyTextWidget(
                  '${LocaleKeys.applied.tr()}: ',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.bq.copyWith(
                    color: const Color(0xffFF5F61),
                    letterSpacing: 0,
                    height: 1.25,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            if ((filtersForSearchText?.searchText?.length ?? 0) > 0) ...{
              (filtersForSearchText?.searchText?.replaceAll(" ", "").length ??
                          0) >
                      1
                  ? Center(
                      child: FilterSelectedMark(width: 15.w, height: 15.h),
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                width:
                    (filtersForSearchText?.searchText
                                ?.replaceAll(" ", "")
                                .length ??
                            0) >
                        1
                    ? 10
                    : 0,
              ),
              SizedBox(
                height: 28.h,
                child: InkWell(
                  onTap: () {
                    Filter? filter = state.appliedFiltersByUser[key]?.filters;

                    controller?.clear();

                    if (choosedFilter) {
                      filter = state.choosedFiltersByUser[key]?.filters;
                      boutiqueBloc.add(
                        ChangeSelectedFiltersEvent(
                          fromHomePageSearch: fromSearch,
                          category: category,
                          boutiqueSlug: boutiqueSlug,
                          filtersChoosedByUser:
                              filter_model.GetProductFiltersModel(
                                filters: filter!.copyWithSaveOtherField(
                                  prices: filter.prices,
                                ),
                              ),
                        ),
                      );
                      boutiqueBloc.add(
                        GetProductsWithFiltersEvent(
                          resetChoosedFilters: false,
                          fromChoosed: true,
                          fromSearch: fromSearch,
                          boutiqueSlug: boutiqueSlug,
                          category: category,
                          offset: 1,
                        ),
                      );
                    } else {
                      boutiqueBloc.add(
                        ChangeAppliedFiltersEvent(
                          category: category,
                          boutiqueSlug: boutiqueSlug,
                          filtersAppliedByUser:
                              filter_model.GetProductFiltersModel(
                                filters: filter!.copyWithSaveOtherField(
                                  prices: filter.prices,
                                ),
                              ),
                        ),
                      );
                      boutiqueBloc.add(
                        GetProductsWithFiltersEvent(
                          fromSearch: fromSearch,
                          boutiqueSlug: boutiqueSlug,
                          category: category,
                          offset: 1,
                        ),
                      );
                    }
                  },
                  child: Center(
                    child:
                        (filtersForSearchText?.searchText
                                    ?.replaceAll(" ", "")
                                    .length ??
                                0) >
                            0
                        ? MyTextWidget(
                            filtersForSearchText!.searchText!,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                              color: const Color(0xff8E8E8E),
                              letterSpacing: 0,
                              height: 1.25,
                              fontSize: 13.sp,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
            },
            if (!(GetIt.I<PrefsRepository>()
                .getTagsInUrlToFilter
                .isNullOrEmpty)) ...{
              SizedBox(
                height: 28.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      GetIt.I<PrefsRepository>().getTagsInUrlToFilter?.length,
                  itemBuilder: (ctx, index) {
                    return Center(
                      child: InkWell(
                        onTap: () {
                          GetIt.I<PrefsRepository>().setTagsInUrlToFilter([]);
                          filter_model.GetProductFiltersModel
                          newGetProductFiltersModel =
                              filter_model.GetProductFiltersModel(
                                filters: filters,
                              );
                          if (choosedFilter) {
                            BlocProvider.of<BoutiqueBloc>(context).add(
                              ChangeSelectedFiltersEvent(
                                fromHomePageSearch: fromSearch,
                                category: category,
                                boutiqueSlug: boutiqueSlug,
                                filtersChoosedByUser: newGetProductFiltersModel,
                              ),
                            );

                            return;
                          }

                          boutiqueBloc.add(
                            ChangeAppliedFiltersEvent(
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersAppliedByUser: newGetProductFiltersModel,
                            ),
                          );
                          BlocProvider.of<BoutiqueBloc>(context).add(
                            GetProductsWithFiltersEvent(
                              searchText: controller?.text,
                              fromSearch: fromSearch,
                              boutiqueSlug: boutiqueSlug,
                              category: category,
                              offset: 1,
                            ),
                          );
                        },
                        child: MyTextWidget(
                          " # ${GetIt.I<PrefsRepository>().getTagsInUrlToFilter?[index]}",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color.fromARGB(255, 86, 60, 201),
                            letterSpacing: 0,
                            height: 1.25,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            },
            SizedBox(width: 15.w),
            if (!(filters?.boutiques.isNullOrEmpty ?? true)) ...{
              Center(
                child: FilterSelectedMark(width: 15.w, height: 15.h),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                height: 28.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters?.boutiques?.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        List<filter_model.Boutique> newBoutiques = List.of(
                          filters?.boutiques ?? [],
                        );
                        newBoutiques.removeAt(index);
                        filter_model.GetProductFiltersModel
                        newGetProductFiltersModel =
                            filter_model.GetProductFiltersModel(
                              filters: filters?.copyWithSaveOtherField(
                                prices: filters.prices,
                                searchText: filters.searchText,
                                boutiques: newBoutiques,
                              ),
                            );
                        if (choosedFilter) {
                          BlocProvider.of<BoutiqueBloc>(context).add(
                            ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser: newGetProductFiltersModel,
                            ),
                          );

                          return;
                        }

                        boutiqueBloc.add(
                          ChangeAppliedFiltersEvent(
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersAppliedByUser: newGetProductFiltersModel,
                          ),
                        );
                        BlocProvider.of<BoutiqueBloc>(context).add(
                          GetProductsWithFiltersEvent(
                            searchText: controller?.text,
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            category: category,
                            offset: 1,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyCachedNetworkImage(
                            //                  progressIndicatorBuilderWidget:
                            //SizedBox.shrink(),
                            imageUrl:
                                filters!.boutiques![index].banner!.filePath!,
                            imageFit: BoxFit.cover,
                            height: choosedFilter ? 40.h : 30.h,
                            width: 60.w,
                            circleDimensions: 8,
                            logoTextHeight: 5.h,
                          ),
                          SizedBox(width: 5.w),
                          MyTextWidget(
                            key: TestVariables.kTestMode
                                ? const Key(
                                    WidgetsKeys.appliedFiltersBoutiqueNameKey,
                                  )
                                : null,
                            filters.boutiques![index].name.toString(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                              color: const Color(0xff8E8E8E),
                              letterSpacing: 0,
                              height: 1.25,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(width: 15.w),
                        ],
                      ),
                    );
                  },
                ),
              ),
            },
            if (!(filters?.categories.isNullOrEmpty ?? true)) ...{
              Center(
                child: FilterSelectedMark(width: 15.w, height: 15.h),
              ),
              SizedBox(width: 5.w),
            },
            SizedBox(
              height: 28.h,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: filters?.categories?.length ?? 0,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      List<String> categories = filters!.categories!
                          .map((e) => e.id.toString())
                          .toList();
                      List<product_listing.Category> newCategories = List.of(
                        filters.categories ?? [],
                      );
                      newCategories.removeAt(index);
                      categories.removeAt(index);
                      filter_model.GetProductFiltersModel
                      newGetProductFiltersModel =
                          filter_model.GetProductFiltersModel(
                            filters: filters.copyWithSaveOtherField(
                              prices: filters.prices,
                              searchText: filters.searchText,
                              categories: newCategories,
                            ),
                          );
                      if (choosedFilter) {
                        BlocProvider.of<BoutiqueBloc>(context).add(
                          ChangeSelectedFiltersEvent(
                            fromHomePageSearch: fromSearch,
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersChoosedByUser: newGetProductFiltersModel,
                          ),
                        );
                        return;
                      }
                      boutiqueBloc.add(
                        ChangeAppliedFiltersEvent(
                          category: category,
                          boutiqueSlug: boutiqueSlug,
                          filtersAppliedByUser: newGetProductFiltersModel,
                        ),
                      );
                      BlocProvider.of<BoutiqueBloc>(context).add(
                        GetProductsWithFiltersEvent(
                          searchText: controller?.text,
                          fromSearch: fromSearch,
                          boutiqueSlug: boutiqueSlug,
                          category: category,
                          offset: 1,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterImage(
                          isSvg: true,
                          width: filters!.categories![index].isSubCategory
                              ? 15.w
                              : 20.w,
                          height: filters.categories![index].isSubCategory
                              ? 15.h
                              : 20.h,
                          imageUrl: filters
                              .categories![index]
                              .flatPhotoPath!
                              .filePath
                              .toString(),
                          withInnerShadow: true,
                          withBackGroundShadow: false,
                        ),
                        SizedBox(width: 5.w),
                        MyTextWidget(
                          filters.categories![index].name.toString(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff8E8E8E),
                            letterSpacing: 0,
                            height: 1.25,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!(filters?.brands.isNullOrEmpty ?? true)) ...{
              Center(
                child: FilterSelectedMark(width: 15.w, height: 15.h),
              ),
              SizedBox(width: 10.w),
            },
            SizedBox(
              height: 28.h,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: filters?.brands?.length ?? 0,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      List<filter_model.Brand> newBrands = List.of(
                        filters!.brands ?? [],
                      );
                      newBrands.removeAt(index);
                      filter_model.GetProductFiltersModel
                      newGetProductFiltersModel =
                          filter_model.GetProductFiltersModel(
                            filters: filters.copyWithSaveOtherField(
                              prices: filters.prices,
                              searchText: filters.searchText,
                              brands: newBrands,
                            ),
                          );
                      if (choosedFilter) {
                        BlocProvider.of<BoutiqueBloc>(context).add(
                          ChangeSelectedFiltersEvent(
                            fromHomePageSearch: fromSearch,
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersChoosedByUser: newGetProductFiltersModel,
                          ),
                        );
                        return;
                      }
                      boutiqueBloc.add(
                        ChangeAppliedFiltersEvent(
                          category: category,
                          boutiqueSlug: boutiqueSlug,
                          filtersAppliedByUser: newGetProductFiltersModel,
                        ),
                      );
                      BlocProvider.of<BoutiqueBloc>(context).add(
                        GetProductsWithFiltersEvent(
                          searchText: controller?.text,
                          fromSearch: fromSearch,
                          boutiqueSlug: boutiqueSlug,
                          category: category,
                          offset: 1,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterImage(
                          width: 20.w,
                          height: 20.h,
                          imageUrl: filters!.brands![index].icon!.filePath
                              .toString(),
                          isSvg: true,
                          withInnerShadow: true,
                          withBackGroundShadow: false,
                        ),
                        SizedBox(width: 5.w),
                        MyTextWidget(
                          filters.brands![index].name.toString(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff8E8E8E),
                            letterSpacing: 0,
                            height: 1.25,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!(filters?.attributes.isNullOrEmpty ?? true)) ...{
              Center(
                child: FilterSelectedMark(width: 15.w, height: 15.h),
              ),
              SizedBox(width: 10.w),
            },
            SizedBox(
              height: 28.h,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: filters?.attributes.isNullOrEmpty ?? true
                    ? 0
                    : filters?.attributes![0].options?.length ?? 0,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      List<String>? options = List.of(
                        filters!.attributes![0].options ?? [],
                      );
                      options.removeAt(index);
                      filter_model.GetProductFiltersModel
                      newGetProductFiltersModel =
                          filter_model.GetProductFiltersModel(
                            filters: filters.copyWithSaveOtherField(
                              prices: filters.prices,
                              searchText: filters.searchText,
                              attributes: options.isNullOrEmpty
                                  ? []
                                  : [
                                      filters.attributes![0].copyWith(
                                        options: options,
                                      ),
                                    ],
                            ),
                          );
                      if (choosedFilter) {
                        BlocProvider.of<BoutiqueBloc>(context).add(
                          ChangeSelectedFiltersEvent(
                            fromHomePageSearch: fromSearch,
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersChoosedByUser: newGetProductFiltersModel,
                          ),
                        );
                        return;
                      }
                      boutiqueBloc.add(
                        ChangeAppliedFiltersEvent(
                          category: category,
                          boutiqueSlug: boutiqueSlug,
                          filtersAppliedByUser: newGetProductFiltersModel,
                        ),
                      );
                      BlocProvider.of<BoutiqueBloc>(context).add(
                        GetProductsWithFiltersEvent(
                          searchText: controller?.text,
                          fromSearch: fromSearch,
                          boutiqueSlug: boutiqueSlug,
                          category: category,
                          offset: 1,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 5.w),
                        MyTextWidget(
                          filters!.attributes![0].options![index].toString(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff8E8E8E),
                            letterSpacing: 0,
                            height: 1.25,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!(filters?.colors.isNullOrEmpty ?? true)) ...{
              Center(
                child: FilterSelectedMark(width: 15.w, height: 15.h),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                height: 28.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters?.colors?.length ?? 0,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        List<String>? colors = List.of(filters!.colors ?? []);
                        colors.removeAt(index);
                        filter_model.GetProductFiltersModel
                        newGetProductFiltersModel =
                            filter_model.GetProductFiltersModel(
                              filters: filters.copyWithSaveOtherField(
                                prices: filters.prices,
                                searchText: filters.searchText,
                                colors: colors,
                              ),
                            );
                        if (choosedFilter) {
                          BlocProvider.of<BoutiqueBloc>(context).add(
                            ChangeSelectedFiltersEvent(
                              fromHomePageSearch: fromSearch,
                              category: category,
                              boutiqueSlug: boutiqueSlug,
                              filtersChoosedByUser: newGetProductFiltersModel,
                            ),
                          );
                          return;
                        }
                        boutiqueBloc.add(
                          ChangeAppliedFiltersEvent(
                            category: category,
                            boutiqueSlug: boutiqueSlug,
                            filtersAppliedByUser: newGetProductFiltersModel,
                          ),
                        );
                        BlocProvider.of<BoutiqueBloc>(context).add(
                          GetProductsWithFiltersEvent(
                            searchText: controller?.text,
                            fromSearch: fromSearch,
                            boutiqueSlug: boutiqueSlug,
                            category: category,
                            offset: 1,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 5.w),
                          Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                int.parse(
                                  '0xff${filters!.colors![index].substring(1)}',
                                ),
                              ),
                              border: Border.all(
                                color: const Color(0xffC4C2C2),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                        ],
                      ),
                    );
                  },
                ),
              ),
            },
            if (filters?.prices?.minPrice != null ||
                filters?.prices?.maxPrice != null ||
                (choosedFilter &&
                    lowerAndUpperPrices != null &&
                    (lowerAndUpperPrices.value.item1 > minPrice! ||
                        lowerAndUpperPrices.value.item2 < maxPrice!))) ...{
              Center(
                child: FilterSelectedMark(width: 15.w, height: 15.h),
              ),
              SizedBox(width: 10.w),
              InkWell(
                onTap: () {
                  filter_model.GetProductFiltersModel
                  newGetProductFiltersModel =
                      filter_model.GetProductFiltersModel(
                        filters: filters!.copyWithSaveOtherField(
                          searchText: filters.searchText,
                        ),
                      );
                  if (choosedFilter) {
                    BlocProvider.of<BoutiqueBloc>(context).add(
                      ChangeSelectedFiltersEvent(
                        fromHomePageSearch: fromSearch,
                        category: category,
                        boutiqueSlug: boutiqueSlug,
                        filtersChoosedByUser: newGetProductFiltersModel,
                      ),
                    );
                    return;
                  }
                  boutiqueBloc.add(
                    ChangeAppliedFiltersEvent(
                      category: category,
                      boutiqueSlug: boutiqueSlug,
                      filtersAppliedByUser: newGetProductFiltersModel,
                    ),
                  );
                  BlocProvider.of<BoutiqueBloc>(context).add(
                    GetProductsWithFiltersEvent(
                      searchText: controller?.text,
                      fromSearch: fromSearch,
                      boutiqueSlug: boutiqueSlug,
                      category: category,
                      offset: 1,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5.w),
                    MyTextWidget(
                      filters?.prices?.minPrice != null ||
                              filters?.prices?.maxPrice != null
                          ? '${currencySymbol} '
                          : "",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        color: const Color(0xff8E8E8E),
                        letterSpacing: 0,
                        height: 1.25,
                        fontSize: 13.sp,
                      ),
                    ),
                    MyTextWidget(
                      filters?.prices?.minPrice != null
                          ? '${(filters!.prices!.minPrice! * exchangeRate).toStringAsFixed((BlocProvider.of<HomeBloc>(context).state.startingSetting?.decimalPointSettings ?? 2).round()).toString()} / '
                          : '${lowerAndUpperPrices!.value.item1.toStringAsFixed((BlocProvider.of<HomeBloc>(context).state.startingSetting?.decimalPointSettings ?? 2).round())} / ',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        color: const Color(0xff8E8E8E),
                        letterSpacing: 0,
                        height: 1.25,
                        fontSize: 13.sp,
                      ),
                    ),
                    MyTextWidget(
                      filters?.prices?.maxPrice != null
                          ? '${(filters!.prices!.maxPrice! * exchangeRate).toStringAsFixed((BlocProvider.of<HomeBloc>(context).state.startingSetting?.decimalPointSettings ?? 2).round()).toString()} '
                          : '${lowerAndUpperPrices!.value.item2.toStringAsFixed(((BlocProvider.of<HomeBloc>(context).state.startingSetting?.decimalPointSettings ?? 2).round()))}  ',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        color: const Color(0xff8E8E8E),
                        letterSpacing: 0,
                        height: 1.25,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
            },
            /*    state
                          .getProductListingWithFiltersPaginationModels[
                              '${boutiqueSlug}' +
                                  '${state.cashedOrginalBoutique ? 'withoutFilter' : ''}' +
                                  '${(category ?? '')}']
                          ?.paginationStatus ==
                      PaginationStatus.loading
                  ? TrydosLoader(
                      size: 20,
                    )
                  : SizedBox.shrink()*/
          ],
        ),
      );

      return widget;

      /* return Container(
          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.shade300),
          height: 30.h,
          width: 1.sw,
          child: widget);*/
    },
  );
}

class FilterCircleWidget extends StatefulWidget {
  const FilterCircleWidget({
    super.key,
    this.isExpanded = true,
    this.isSvg = false,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.categoryName,
    required this.addOrRemoveSpecificFilter,
    this.withBackGroundShadow = true,
    this.paddingValue = 10,
    this.isSubSubCategory = false,
    this.scale = false,
    this.isTopItem = false,
    this.markWidth = 20,
    this.markHeight = 20,
    this.borderColor,
    this.originalHeight,
    this.originalWidth,
    this.expandStackedItemsFunction,
    required this.displayFilterMark,
  });

  final bool isTopItem;
  final Color? borderColor;
  final bool isExpanded;
  final bool isSvg;
  final double width;
  final double markWidth;
  final double paddingValue;
  final double? originalHeight;
  final double? originalWidth;
  final double height;
  final double markHeight;
  final bool? isSubSubCategory;
  final bool withBackGroundShadow;
  final bool scale;
  final bool displayFilterMark;
  final void Function(bool add) addOrRemoveSpecificFilter;
  final void Function()? expandStackedItemsFunction;
  final String imageUrl;
  final String categoryName;

  @override
  State<FilterCircleWidget> createState() => _FilterCircleWidgetState();
}

class _FilterCircleWidgetState extends State<FilterCircleWidget> {
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(end: widget.paddingValue),
      child: Container(
        width: widget.isSubSubCategory! ? widget.width + 22.w : null,
        height: widget.isSubSubCategory! ? widget.height + 22.h : null,
        child: Column(
          children: [
            Column(
              children: [
                InkWell(
                  onTap: () => widget.addOrRemoveSpecificFilter.call(
                    !widget.displayFilterMark,
                  ),
                  child: Stack(
                    children: [
                      AnimatedScale(
                        curve: Curves.fastEaseInToSlowEaseOut,
                        scale: widget.scale ? 0.92 : 1,
                        duration: const Duration(milliseconds: 100),
                        child: FilterImage(
                          isSvg: widget.isSvg,
                          imageUrl: widget.imageUrl,
                          width: widget.width,
                          height: widget.height,
                          originalWidth: widget.originalWidth,
                          originalHeight: widget.originalHeight,
                          borderColor: widget.displayFilterMark
                              ? const Color(0xffFF5F61)
                              : widget.borderColor,
                          withBackGroundShadow:
                              !widget.displayFilterMark &&
                              widget.withBackGroundShadow,
                          withInnerShadow: !widget.scale,
                        ),
                      ),
                      Visibility(
                        visible: widget.displayFilterMark,
                        child: FilterSelectedMark(
                          width: widget.markWidth,
                          height: widget.markHeight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isExpanded || widget.isTopItem) ...{
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: widget.width,
                    child: MyTextWidget(
                      widget.categoryName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        color: const Color(0xff8E8E8E),
                        letterSpacing: 0,
                        height: 1.25,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                },
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterImage extends StatelessWidget {
  const FilterImage({
    super.key,
    required this.width,
    required this.height,
    required this.withInnerShadow,
    required this.withBackGroundShadow,
    this.borderColor,
    this.originalWidth,
    this.originalHeight,
    this.isSvg = false,
    required this.imageUrl,
  });

  final double? originalWidth;
  final double? originalHeight;
  final double width;
  final double height;
  final bool isSvg;
  final bool withInnerShadow;
  final bool withBackGroundShadow;
  final Color? borderColor;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(180.r)),
        border: borderColor != null
            ? Border.all(width: 0.5, color: borderColor!)
            : null,
        boxShadow: withBackGroundShadow
            ? [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.6),
                  offset: const Offset(0, 3),
                  blurRadius: 3,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(180.r)),
        child: Stack(
          children: [
            isSvg
                ? mediaServerIsS3
                      ? MyCachedNetworkImage(
                          imageUrl: imageUrl,
                          height: height,
                          imageFit: BoxFit.contain,
                          width: width,
                        )
                      : SvgNetworkWidget(
                          svgUrl: imageUrl,
                          //height: height,
                          width: width,
                        )
                : imageUrl.contains('assets')
                ? Image.asset(
                    imageUrl,
                    width: width,
                    fit: BoxFit.cover,
                    height: height,
                  )
                : MyCachedNetworkImage(
                    //     progressIndicatorBuilderWidget:
                    //           const SizedBox.shrink(),
                    imageUrl: imageUrl,
                    width: width,
                    imageFit: BoxFit.contain,
                    height: height,
                  ),
            //Image.asset(imageUrl , fit: BoxFit.cover, width: width, height: height,),
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                boxShadow: withInnerShadow
                    ? [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.5),
                          inset: true,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSelectedMark extends StatelessWidget {
  const FilterSelectedMark({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                offset: Offset(0, 3),
                blurRadius: 3,
              ),
            ],
            borderRadius: BorderRadius.circular(180.r),
            color: const Color(0xffFF5F61),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.filtersSvg,
              // ignore: deprecated_member_use
              color: Colors.white,
              height: height / 2,
            ),
          ),
        ),
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(180.r),
            border: Border.all(color: const Color(0xffFF5F61)),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 6,
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.7),
                inset: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
