import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:tuple/tuple.dart';

import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../search/presentation/widgets/close_circle.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_state.dart';

class PriceFilter extends StatefulWidget {
  const PriceFilter({
    super.key,
    required this.pricesFiltersRanges,
    this.hideTitle = false,
    required this.pricrSymbol,
    required this.lowerAndUpperBound,
    this.boutiqueSlug,
    this.category,
    required this.decimalPoint,
    required this.minPrice,
    required this.pricrRate,
    required this.exchangeRate,
    required this.maxPrice,
    this.searchText,
    required this.fromHomeSearch,
  });

  final bool hideTitle;
  final double minPrice;
  final String? searchText;
  final double exchangeRate;
  final double pricrRate;
  final double maxPrice;
  final Prices pricesFiltersRanges;
  final String pricrSymbol;
  final String? boutiqueSlug;
  final bool fromHomeSearch;
  final String? category;
  final ValueNotifier<Tuple2<double, double>> lowerAndUpperBound;
  final int decimalPoint;

  @override
  State<PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends State<PriceFilter> {
  late final HomeBloc homeBloc;
  String key = '';
  @override
  void initState() {
    key = widget.boutiqueSlug! + (widget.category ?? '');
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.pricesFiltersRanges.maxPrice! -
            widget.pricesFiltersRanges!.minPrice!) <
        1) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: widget.hideTitle ? 0 : 30.0, end: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.hideTitle ? 80 : 110,
            width: 1.sw - 50,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 20,
                  child: CustomPaint(
                    size: Size(1.sw - 50, 0),
                    painter: RPSCustomPainter(
                        points: List.generate(
                            widget.pricesFiltersRanges.priceRanges?.length ??
                                0 + 1,
                            (index) => Offset(
                                index *
                                    (1.sw - 50) /
                                    widget.pricesFiltersRanges.priceRanges!
                                        .length,
                                index == 0
                                    ? 0
                                    : -widget.pricesFiltersRanges
                                        .priceRanges![index - 1].count!
                                        .toDouble()))),
                  ),
                ),
                Container(
                    //color: Colors.white,
                    height: 40,
                    width: 1.sw - 50,
                    child: FlutterSlider(
                      minimumDistance: 1,
                      values: [
                        (widget.pricesFiltersRanges.minPrice! *
                            widget.pricrRate),
                        (widget.pricesFiltersRanges.maxPrice! *
                            widget.pricrRate),
                      ],
                      step: FlutterSliderStep(
                        step: (widget.pricesFiltersRanges.maxPrice! *
                                widget.pricrRate) /
                            100,
                      ),
                      selectByTap: false,
                      trackBar: FlutterSliderTrackBar(
                          activeTrackBarHeight: 1,
                          inactiveTrackBarHeight: 1,
                          activeTrackBar: BoxDecoration(
                            color: Color(0xff5D5C5D),
                          ),
                          inactiveTrackBar: BoxDecoration(
                            color: Color(0xff5D5C5D),
                          )),
                      handlerWidth: 40,
                      handlerHeight: 40,
                      centeredOrigin: false,
                      rightHandler: FlutterSliderHandler(
                          decoration: BoxDecoration(),
                          child: ValueListenableBuilder<Tuple2<double, double>>(
                              valueListenable: widget.lowerAndUpperBound,
                              builder: (context, filterData, _) {
                                return Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: filterData.item2 <
                                              (widget.pricesFiltersRanges
                                                      .maxPrice! *
                                                  widget.pricrRate)
                                          ? Color(0xffFF5F61)
                                          : Colors.white,
                                      border: Border.all(
                                          width: 0.5, color: Color(0xffC4C2C2)),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 3,
                                            offset: Offset(0, 3),
                                            color:
                                                Colors.black.withOpacity(0.05))
                                      ]),
                                );
                              })),
                      handler: FlutterSliderHandler(
                          decoration: BoxDecoration(),
                          child: ValueListenableBuilder<Tuple2<double, double>>(
                              valueListenable: widget.lowerAndUpperBound,
                              builder: (context, filterData, _) {
                                return Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: filterData.item1 >
                                              (widget.pricesFiltersRanges
                                                      .minPrice! *
                                                  widget.pricrRate)
                                          ? Color(0xffFF5F61)
                                          : Colors.white,
                                      border: Border.all(
                                          width: 0.5, color: Color(0xffC4C2C2)),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 3,
                                            offset: Offset(0, 3),
                                            color:
                                                Colors.black.withOpacity(0.05))
                                      ]),
                                );
                              })),
                      rangeSlider: true,
                      max: (widget.pricesFiltersRanges.maxPrice! *
                          widget.pricrRate),
                      min: (widget.pricesFiltersRanges.minPrice! *
                          widget.pricrRate),
                      handlerAnimation: FlutterSliderHandlerAnimation(
                          scale: 1, duration: Duration(milliseconds: 0)),
                      tooltip: FlutterSliderTooltip(
                          alwaysShowTooltip: false,
                          disabled: true,
                          disableAnimation: true),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        print('ssssssss');
                        widget.lowerAndUpperBound.value =
                            Tuple2(lowerValue, upperValue);
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        Filter filter =
                            homeBloc.state.choosedFiltersByUser[key]?.filters ??
                                Filter();
                        homeBloc.add(ChangeSelectedFiltersEvent(
                          boutiqueSlug: widget.boutiqueSlug!,
                          requestToUpdateFilters: true,
                          fromHomePageSearch: widget.fromHomeSearch,
                          category: widget.category,
                          filtersChoosedByUser: GetProductFiltersModel(
                              filters: filter.copyWithSaveOtherField(
                                  searchText: widget.searchText,
                                  prices: Prices(
                                      maxPrice:
                                          upperValue / widget.exchangeRate,
                                      minPrice:
                                          lowerValue / widget.exchangeRate,
                                      currencySymbol: widget.pricrSymbol))),
                        ));
                      },
                    )),
                Positioned(
                    top: widget.hideTitle ? 10 : 40,
                    left: 0,
                    child: ValueListenableBuilder<Tuple2<double, double>>(
                        valueListenable: widget.lowerAndUpperBound,
                        builder: (context, filterData, _) {
                          return Row(
                            children: [
                              MyTextWidget(
                                'Min ${filterData.item1.toStringAsFixed(widget.decimalPoint)} ',
                                style: textTheme.titleMedium?.rq.copyWith(
                                    color: filterData.item1 >
                                            (widget.pricesFiltersRanges
                                                    .minPrice! *
                                                widget.pricrRate)
                                        ? Color(0xffFF5F61)
                                        : Color(0xff505050)),
                              ),
                              MyTextWidget(
                                widget.pricrSymbol,
                                style: textTheme.titleMedium?.rq.copyWith(
                                    color: filterData.item1 >
                                            widget.pricesFiltersRanges
                                                    .minPrice! *
                                                widget.pricrRate
                                        ? Color(0xffFF5F61)
                                        : Color(0xff505050)),
                              ),
                            ],
                          );
                        })),
                Positioned(
                    right: 0,
                    top: widget.hideTitle ? 10 : 40,
                    child: ValueListenableBuilder<Tuple2<double, double>>(
                        valueListenable: widget.lowerAndUpperBound,
                        builder: (context, filterData, _) {
                          return Row(
                            children: [
                              MyTextWidget(
                                'Max ${filterData.item2.toStringAsFixed(widget.decimalPoint)} ',
                                style: textTheme.titleMedium?.rq.copyWith(
                                    color: filterData.item2 <
                                            widget.pricesFiltersRanges
                                                    .maxPrice! *
                                                widget.pricrRate
                                        ? Color(0xffFF5F61)
                                        : Color(0xff505050)),
                              ),
                              MyTextWidget(
                                widget.pricrSymbol,
                                style: textTheme.titleMedium?.rq.copyWith(
                                    color: filterData.item2 <
                                            widget.pricesFiltersRanges
                                                    .maxPrice! *
                                                widget.pricrRate
                                        ? Color(0xffFF5F61)
                                        : Color(0xff505050)),
                              ),
                            ],
                          );
                        })),
                if (!widget.hideTitle)
                  Positioned(
                    top: 0,
                    left: 0,
                    width: 1.sw - 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilterSelectedMark(width: 20, height: 20),
                            SizedBox(
                              width: 10,
                            ),
                            MyTextWidget(
                              'Filter By Price',
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                  color: Color(0xff505050), height: 15 / 12),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              AppAssets.registerInfoSvg,
                              color: Color(0xffD3D3D3),
                            ),
                            BlocBuilder<HomeBloc, HomeState>(
                                builder: (context, state) {
                              if (state.getProductFiltersStatus[key] ==
                                  GetProductFiltersStatus.loading) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    TrydosLoader(
                                      size: 20,
                                    ),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            })
                          ],
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  final List<Offset> points;

  RPSCustomPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xfff8f8f8).withOpacity(1.0)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (var point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close(); // Connect the last point to the first point to close the polygon
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
