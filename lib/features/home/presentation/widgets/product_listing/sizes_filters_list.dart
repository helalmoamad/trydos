import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';

import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../data/models/get_product_filters_model.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class SizesFiltersList extends StatefulWidget {
  const SizesFiltersList({
    super.key,
    this.hideTitle = false,
    required this.attribute,
    required this.boutiqueSlug,
    this.category,
    this.searchText,
    required this.fromHomeSearch,
  });

  final Attribute attribute;

  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;
  final bool fromHomeSearch;
  final String? searchText;

  @override
  State<SizesFiltersList> createState() => _SizesFiltersListState();
}

class _SizesFiltersListState extends State<SizesFiltersList> {
  late final ValueNotifier<int> currentIndexInSizes;
  String key = '';
  Timer? debounce;
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    scrollController.addListener(() {
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
    currentIndexInSizes = ValueNotifier(
      (widget.attribute.options?.length ?? 0) ~/ 2,
    );
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.hideTitle ? 0 : 25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.hideTitle) ...{
            Row(
              children: [
                FilterSelectedMark(width: 20.w, height: 20.h),
                SizedBox(width: 10.w),
                MyTextWidget(
                  '${LocaleKeys.filter_by.tr()} ${LocaleKeys.sizes.tr()}',
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
                BlocBuilder<BoutiqueBloc, BoutiqueState>(
                  builder: (context, state) {
                    if (state.getProductFiltersStatus[key] ==
                        GetProductFiltersStatus.loading) {
                      return Row(
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
            height: 70.h,
            child: ValueListenableBuilder<int>(
              valueListenable: currentIndexInSizes,
              builder: (context, currentIndex, _) {
                return ListView.separated(
                  controller: scrollController,

                  addRepaintBoundaries: false,
                  itemCount: widget.attribute.options?.length ?? 0,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (ctx, index) => SizedBox(width: 10.w),
                  itemBuilder: (ctx, index) {
                    BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(
                      context,
                    );
                    bool isSelected = widget.hideTitle
                        ? ((boutiqueBloc
                                      .state
                                      .appliedFiltersByUser[key]
                                      ?.filters
                                      ?.attributes
                                      ?.isNullOrEmpty ??
                                  true)
                              ? false
                              : boutiqueBloc
                                        .state
                                        .appliedFiltersByUser[key]!
                                        .filters!
                                        .attributes![0]
                                        .options
                                        ?.any(
                                          (element) =>
                                              element ==
                                              widget.attribute.options?[index],
                                        ) ??
                                    false)
                        : ((boutiqueBloc
                                      .state
                                      .choosedFiltersByUser[key]
                                      ?.filters
                                      ?.attributes
                                      ?.isNullOrEmpty ??
                                  true)
                              ? false
                              : boutiqueBloc
                                        .state
                                        .choosedFiltersByUser[key]!
                                        .filters!
                                        .attributes![0]
                                        .options
                                        ?.any(
                                          (element) =>
                                              element ==
                                              widget.attribute.options?[index],
                                        ) ??
                                    false);
                    return Stack(
                      children: [
                        GestureDetector(
                          key: TestVariables.kTestMode == false
                              ? null
                              : Key(
                                  '${WidgetsKeys.sizeCircleProductListingFilterKey}$index',
                                ),
                          onTap: () {
                            Filter? prevChoosedOrAppliedFilterToAddToIt =
                                widget.hideTitle
                                ? boutiqueBloc
                                      .state
                                      .appliedFiltersByUser[key]
                                      ?.filters
                                : boutiqueBloc
                                      .state
                                      .choosedFiltersByUser[key]
                                      ?.filters;
                            List<Attribute>? sizes = List.of(
                              prevChoosedOrAppliedFilterToAddToIt?.attributes ??
                                  [],
                            );
                            if (!isSelected) {
                              FirebaseAnalyticsService.logEventForSession(
                                eventName: AnalyticsEventsConst.APPLY_FILTER,
                                extraParams: {
                                  'filter_type': "size",
                                  'filter_value':
                                      widget.attribute.options![index],
                                  'screen_name':
                                      GlobalScreenConst.PRODUCT_LISTING_SCREEN,
                                },
                                executedEventName:
                                    AnalyticsButtonsEventNameConst
                                        .applyFilterButton,
                              );
                              String size = widget.attribute.options![index];
                              if (prevChoosedOrAppliedFilterToAddToIt == null) {
                                prevChoosedOrAppliedFilterToAddToIt = Filter();
                              }
                              prevChoosedOrAppliedFilterToAddToIt =
                                  prevChoosedOrAppliedFilterToAddToIt
                                      .copyWithSaveOtherField(
                                        prices:
                                            prevChoosedOrAppliedFilterToAddToIt
                                                .prices,
                                        searchText:
                                            prevChoosedOrAppliedFilterToAddToIt
                                                .searchText,
                                        attributes:
                                            prevChoosedOrAppliedFilterToAddToIt
                                                .attributes
                                                .isNullOrEmpty
                                            ? [
                                                Attribute(
                                                  id: widget.attribute.id,
                                                  name: widget.attribute.name,
                                                  options: [size],
                                                ),
                                              ]
                                            : [
                                                prevChoosedOrAppliedFilterToAddToIt
                                                    .attributes![0]
                                                    .copyWith(
                                                      options: [
                                                        ...prevChoosedOrAppliedFilterToAddToIt
                                                                .attributes![0]
                                                                .options ??
                                                            [],
                                                        size,
                                                      ],
                                                    ),
                                              ],
                                      );
                            } else {
                              if (kDebugMode) print('reset size');
                              // FirebaseAnalyticsService.logEventForSession(
                              //   eventName: AnalyticsEventsConst.buttonClicked,
                              //   executedEventName:
                              //       AnalyticsButtonsEventNameConst
                              //           .resetByTapOnFilterButton,
                              // );
                              ////////////////////////////////////
                              List<String> options = List.of(
                                sizes[0].options ?? [],
                              );
                              options.removeWhere(
                                ((element) =>
                                    element ==
                                    widget.attribute.options![index]),
                              );
                              sizes[0] = sizes[0].copyWith(options: options);
                              prevChoosedOrAppliedFilterToAddToIt =
                                  prevChoosedOrAppliedFilterToAddToIt!
                                      .copyWithSaveOtherField(
                                        searchText:
                                            prevChoosedOrAppliedFilterToAddToIt
                                                .searchText,
                                        prices:
                                            prevChoosedOrAppliedFilterToAddToIt
                                                .prices,
                                        attributes: sizes,
                                      );
                              if (sizes[0].options!.length == 0) {
                                prevChoosedOrAppliedFilterToAddToIt =
                                    prevChoosedOrAppliedFilterToAddToIt
                                        .changeAttributesAndSaveOthers();
                              }
                            }
                            if (widget.hideTitle) {
                              boutiqueBloc.add(
                                ChangeAppliedFiltersEvent(
                                  category: widget.category,
                                  boutiqueSlug: widget.boutiqueSlug,
                                  filtersAppliedByUser: GetProductFiltersModel(
                                    filters:
                                        prevChoosedOrAppliedFilterToAddToIt,
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
                              boutiqueBloc.add(
                                ChangeSelectedFiltersEvent(
                                  fromHomePageSearch: widget.fromHomeSearch,
                                  category: widget.category,
                                  boutiqueSlug: widget.boutiqueSlug,
                                  filtersChoosedByUser: GetProductFiltersModel(
                                    filters:
                                        prevChoosedOrAppliedFilterToAddToIt,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 70.h,
                            width: 70.w,
                            child: DottedBorder(
                              radius: Radius.circular(180.r),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 0.5,
                              color: isSelected
                                  ? const Color(0xffFF5F61)
                                  : const Color(0xff6B6B6B),
                              dashPattern: const [3, 3],
                              child: Center(
                                child: Text(
                                  widget.attribute.options![index],
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      // index == currentIndex
                                      //     ? textTheme.titleLarge?.bq.copyWith(
                                      //   height: 1.3,
                                      //   fontSize: 15.sp,
                                      //   color: const Color(0xff5D5C5D),
                                      // )
                                      //     :
                                      textTheme.titleLarge?.mq.copyWith(
                                        height: 1.3,
                                        fontSize: 15.sp,
                                        color: const Color(0xff5D5C5D),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isSelected,
                          child: FilterSelectedMark(width: 20.w, height: 20.h),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
