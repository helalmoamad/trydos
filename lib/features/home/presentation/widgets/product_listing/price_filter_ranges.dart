import 'package:flutter/foundation.dart' hide Category;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../common/test_utils/test_var.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../data/models/get_product_filters_model.dart';

class PriceFiltersRangesList extends StatefulWidget {
  const PriceFiltersRangesList({
    super.key,
    required this.boutiqueSlug,
    this.category,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.priceRanges,
    this.searchText,
    required this.fromHomeSearch,
    required this.decimalPoint,
  });

  final String boutiqueSlug;
  final String currencySymbol;
  final List<PriceRange> priceRanges;
  final String? category;
  final bool fromHomeSearch;
  final String? searchText;
  final double exchangeRate;
  final double decimalPoint;

  @override
  State<PriceFiltersRangesList> createState() => _PriceFiltersRangesListState();
}

class _PriceFiltersRangesListState extends State<PriceFiltersRangesList> {
  String key = '';

  @override
  void initState() {
    key = widget.boutiqueSlug + (widget.category ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    if (widget.priceRanges.isNullOrEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 70.h,
      child: ListView.separated(
        addRepaintBoundaries: false,
        itemCount: widget.priceRanges.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (ctx, index) => SizedBox(width: 10.w),
        itemBuilder: (ctx, index) {
          BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
          bool isSelected =
              (boutiqueBloc
                      .state
                      .appliedFiltersByUser[key]
                      ?.filters
                      ?.prices
                      ?.minPrice ==
                  widget.priceRanges[index].maxPrice) &&
              (boutiqueBloc
                      .state
                      .appliedFiltersByUser[key]
                      ?.filters
                      ?.prices
                      ?.maxPrice ==
                  widget.priceRanges[index].minPrice);
          return Stack(
            children: [
              GestureDetector(
                key: TestVariables.kTestMode == false
                    ? null
                    : Key(
                        '${WidgetsKeys.priceCircleProductListingFilterKey}$index',
                      ),
                onTap: () {
                  FirebaseAnalyticsService.logEventForSession(
                    eventName: AnalyticsEventsConst.APPLY_FILTER,
                    extraParams: {
                      'filter_type': "price",
                      'filter_value':
                          '${widget.priceRanges[index].minPrice} - ${widget.priceRanges[index].maxPrice}',
                      'screen_name': GlobalScreenConst.PRODUCT_LISTING_SCREEN,
                    },
                    executedEventName:
                        AnalyticsButtonsEventNameConst.applyFilterButton,
                  );
                  Filter? prevChoosedOrAppliedFilterToAddToIt =
                      boutiqueBloc.state.appliedFiltersByUser[key]?.filters;
                  if (prevChoosedOrAppliedFilterToAddToIt == null) {
                    prevChoosedOrAppliedFilterToAddToIt = Filter();
                  }
                  if (prevChoosedOrAppliedFilterToAddToIt.prices == null) {
                    prevChoosedOrAppliedFilterToAddToIt =
                        prevChoosedOrAppliedFilterToAddToIt
                            .copyWithSaveOtherField(
                              searchText: prevChoosedOrAppliedFilterToAddToIt
                                  .searchText,
                              prices: Prices(
                                currencySymbol: widget.currencySymbol,
                                minPrice: widget.priceRanges[index].minPrice,
                                maxPrice: widget.priceRanges[index].maxPrice,
                              ),
                            );
                  } else if (prevChoosedOrAppliedFilterToAddToIt
                              .prices!
                              .minPrice !=
                          widget.priceRanges[index].maxPrice ||
                      prevChoosedOrAppliedFilterToAddToIt.prices!.maxPrice !=
                          widget.priceRanges[index].minPrice) {
                    if (kDebugMode)
                      print(
                        "*********************************************************************",
                      );
                    prevChoosedOrAppliedFilterToAddToIt =
                        prevChoosedOrAppliedFilterToAddToIt
                            .copyWithSaveOtherField(
                              searchText: prevChoosedOrAppliedFilterToAddToIt
                                  .searchText,
                              prices: Prices(
                                currencySymbol: widget.currencySymbol,
                                minPrice: widget.priceRanges[index].minPrice,
                                maxPrice: widget.priceRanges[index].maxPrice,
                              ),
                            );
                  } else {
                    if (kDebugMode)
                      print(
                        "*********************************************************************",
                      );
                    prevChoosedOrAppliedFilterToAddToIt =
                        prevChoosedOrAppliedFilterToAddToIt
                            .copyWithSaveOtherField(
                              searchText: prevChoosedOrAppliedFilterToAddToIt
                                  .searchText,
                            );
                  }
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
                },
                child: Container(
                  height: 50.h,
                  margin: EdgeInsets.only(top: 20.h),
                  child: DottedBorder(
                    radius: Radius.circular(180.r),
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.square,
                    strokeWidth: 0.5,
                    color: isSelected
                        ? const Color(0xffFF5F61)
                        : const Color(0xff6B6B6B),
                    padding: EdgeInsets.all(8.r),
                    dashPattern: [3.r, 3.r],
                    child: Center(
                      child: Text(
                        LanguageService.rtl
                            ? ' ${widget.currencySymbol} ${(widget.priceRanges[index].maxPrice! * widget.exchangeRate).toStringAsFixed(widget.decimalPoint.round())} - ${(widget.priceRanges[index].minPrice! * widget.exchangeRate).toStringAsFixed(2)}'
                            : '${(widget.priceRanges[index].minPrice! * widget.exchangeRate).toStringAsFixed(widget.decimalPoint.round())} - ${(widget.priceRanges[index].maxPrice! * widget.exchangeRate).toStringAsFixed(2)} ${widget.currencySymbol}',
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: textTheme.titleLarge?.mq.copyWith(
                          height: 1.3,
                          fontSize: 15.sp,
                          color: const Color(0xff5D5C5D),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
