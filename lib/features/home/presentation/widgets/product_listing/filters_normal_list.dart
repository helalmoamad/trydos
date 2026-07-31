import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';

import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../data/models/get_product_filters_model.dart';

class FiltersNormalList<T> extends StatefulWidget {
  const FiltersNormalList({
    super.key,
    required this.filterListTitle,
    this.hideTitle = false,
    required this.isBrandFilter,
    required this.filters,
    this.searchText,
    required this.fromHomeSearch,
    required this.boutiqueSlug,
    this.category,
  });

  final bool isBrandFilter;
  final String filterListTitle;
  final List<T> filters;
  final bool fromHomeSearch;
  final String? searchText;
  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;

  @override
  State<FiltersNormalList> createState() => _FiltersNormalListState();
}

class _FiltersNormalListState extends State<FiltersNormalList> {
  String key = '';
  Timer? debounce;
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    scrollController.addListener(() {
      if (kDebugMode) print("FFFFFFFFFFFFF");
      try {
        if (debounce?.isActive ?? false) {
          debounce!.cancel();
        }
        debounce = Timer(const Duration(milliseconds: 600), () {
          if (scrollController.offset >=
              (scrollController.position.maxScrollExtent * 0.6)) {
            BlocProvider.of<BoutiqueBloc>(context).add(
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
    key = widget.boutiqueSlug + (widget.category ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    if (widget.filters.isNullOrEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.hideTitle ? 0 : 25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.hideTitle) ...{
            Row(
              key: TestVariables.kTestMode
                  ? const Key(WidgetsKeys.filterByBrandHeadKey)
                  : null,
              children: [
                FilterSelectedMark(width: 20.w, height: 20.h),
                SizedBox(width: 10.w),
                MyTextWidget(
                  widget.filterListTitle,
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    color: const Color(0xff505050),
                    height: (15 / 12),
                  ),
                ),
                SizedBox(width: 5.w),
                SvgPicture.asset(
                  AppAssets.registerInfoSvg,
                  // ignore: deprecated_member_use
                  color: const Color(0xffD3D3D3),
                ),
                BlocBuilder<BoutiqueBloc, BoutiqueState>(
                  builder: (context, state) {
                    if (state.getProductFiltersStatus[key] ==
                        GetProductFiltersStatus.loading) {
                      return Row(
                        key: TestVariables.kTestMode
                            ? const Key(WidgetsKeys.getBrandsLoadingKey)
                            : null,
                        children: [
                          SizedBox(width: 5.w),
                          TrydosLoader(size: 20.h),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            SizedBox(height: 10.h),
          },
          SizedBox(
            height: 110.h,
            child: ListView.separated(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              controller: scrollController,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(
                  context,
                );
                bool isSelected = widget.hideTitle
                    ? widget.isBrandFilter
                          ? (boutiqueBloc
                                    .state
                                    .appliedFiltersByUser[key]
                                    ?.filters
                                    ?.brands
                                    ?.any(
                                      (element) =>
                                          element.id ==
                                          widget.filters[index].id,
                                    ) ??
                                false)
                          : false
                    : widget.isBrandFilter
                    ? (boutiqueBloc
                              .state
                              .choosedFiltersByUser[key]
                              ?.filters
                              ?.brands
                              ?.any(
                                (element) =>
                                    element.id == widget.filters[index].id,
                              ) ??
                          false)
                    : false;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Filter? prevChoosedOrAppliedFilterToAddToIt =
                            widget.hideTitle
                            ? boutiqueBloc
                                  .state
                                  .appliedFiltersByUser[key]
                                  ?.filters
                                  ?.copyWithSaveOtherField(
                                    prices: boutiqueBloc
                                        .state
                                        .appliedFiltersByUser[key]
                                        ?.filters
                                        ?.prices,
                                    searchText: boutiqueBloc
                                        .state
                                        .appliedFiltersByUser[key]
                                        ?.filters
                                        ?.searchText,
                                  )
                            : boutiqueBloc
                                  .state
                                  .choosedFiltersByUser[key]
                                  ?.filters;
                        List<Brand>? brands = List.of(
                          prevChoosedOrAppliedFilterToAddToIt?.brands ?? [],
                        );
                        if (!isSelected) {
                          FirebaseAnalyticsService.logEventForSession(
                            eventName: AnalyticsEventsConst.APPLY_FILTER,
                            extraParams: {
                              'filter_type': "brand",
                              'filter_value': widget.filters[index].name ?? "",
                              'screen_name':
                                  GlobalScreenConst.PRODUCT_LISTING_SCREEN,
                            },
                            executedEventName: AnalyticsButtonsEventNameConst
                                .applyFilterButton,
                          );
                          dynamic item = widget.filters[index];
                          if (prevChoosedOrAppliedFilterToAddToIt == null) {
                            prevChoosedOrAppliedFilterToAddToIt = Filter();
                          }
                          prevChoosedOrAppliedFilterToAddToIt =
                              prevChoosedOrAppliedFilterToAddToIt
                                  .copyWithSaveOtherField(
                                    prices: prevChoosedOrAppliedFilterToAddToIt
                                        .prices,
                                    searchText:
                                        prevChoosedOrAppliedFilterToAddToIt
                                            .searchText,
                                    brands: !widget.isBrandFilter
                                        ? prevChoosedOrAppliedFilterToAddToIt
                                              .brands
                                        : prevChoosedOrAppliedFilterToAddToIt
                                              .brands
                                              .isNullOrEmpty
                                        ? [item]
                                        : [
                                            ...prevChoosedOrAppliedFilterToAddToIt
                                                .brands!,
                                            item,
                                          ],
                                  );
                        } else {
                          // FirebaseAnalyticsService.logEventForSession(
                          //   eventName: AnalyticsEventsConst.buttonClicked,
                          //   executedEventName:
                          //       AnalyticsButtonsEventNameConst
                          //           .resetByTapOnFilterButton,
                          // );
                          /////////////////////////////////////
                          if (widget.isBrandFilter) {
                            brands.removeWhere(
                              ((element) =>
                                  element.id == widget.filters[index].id),
                            );
                          }
                          prevChoosedOrAppliedFilterToAddToIt =
                              prevChoosedOrAppliedFilterToAddToIt
                                  ?.copyWithSaveOtherField(
                                    brands: brands,
                                    searchText:
                                        prevChoosedOrAppliedFilterToAddToIt
                                            .searchText,
                                    prices: prevChoosedOrAppliedFilterToAddToIt
                                        .prices,
                                  );
                        }
                        if (widget.hideTitle) {
                          boutiqueBloc.add(
                            ChangeAppliedFiltersEvent(
                              category: widget.category,
                              boutiqueSlug: widget.boutiqueSlug,
                              filtersAppliedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt,
                              ),
                            ),
                          );
                          boutiqueBloc.add(
                            GetProductsWithFiltersEvent(
                              fromSearch: widget.fromHomeSearch,
                              searchText: widget.searchText,
                              boutiqueSlug: widget.boutiqueSlug,
                              category: widget.category,
                              offset: 1,
                            ),
                          );
                        } else {
                          if (kDebugMode)
                            print(
                              'dwwdwdwqe32e23e ${boutiqueBloc.state.prefAppliedFilterForExtendFilter?.brands}',
                            );
                          boutiqueBloc.add(
                            ChangeSelectedFiltersEvent(
                              fromHomePageSearch: widget.fromHomeSearch,
                              category: widget.category,
                              boutiqueSlug: widget.boutiqueSlug,
                              filtersChoosedByUser: GetProductFiltersModel(
                                filters: prevChoosedOrAppliedFilterToAddToIt,
                              ),
                            ),
                          );
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            key: TestVariables.kTestMode == false
                                ? null
                                : Key(
                                    '${WidgetsKeys.brandCircleProductListingFilterKey}$index',
                                  ),
                            width: 70.w,
                            height: 70.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xffFF5F61)
                                    : const Color(0xffC4C2C2),
                              ),
                            ),
                            child: Center(
                              child: widget.isBrandFilter
                                  ? widget.filters[index].icon != null
                                        ? widget
                                                      .filters[index]
                                                      .icon!
                                                      .filePath !=
                                                  null
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5.0,
                                                      ),
                                                  child: MyCachedNetworkImage(
                                                    imageUrl: widget
                                                        .filters[index]
                                                        .icon!
                                                        .filePath!,
                                                    height: 72.h,
                                                    imageFit: BoxFit.contain,
                                                    width: 70.w,
                                                  ),
                                                )
                                              : const SizedBox.shrink()
                                        : const SizedBox.shrink()
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          Visibility(
                            visible: isSelected,
                            child: FilterSelectedMark(
                              width: 20.w,
                              height: 20.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),
                    MyTextWidget(
                      key: TestVariables.kTestMode == false
                          ? null
                          : Key(
                              '${WidgetsKeys.brandProductListingFilterNameKey}$index',
                            ),
                      widget.isBrandFilter ? widget.filters[index].name : '',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        color: const Color(0xff8E8E8E),
                        letterSpacing: 0,
                        height: 1.25,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (ctx, index) => SizedBox(width: 10.w),
              itemCount: widget.filters.length,
            ),
          ),
          SizedBox(height: !widget.hideTitle ? 20.h : 0),
        ],
      ),
    );
  }
}
