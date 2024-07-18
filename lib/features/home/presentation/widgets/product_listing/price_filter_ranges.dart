import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';

class PriceFiltersRangesList extends StatefulWidget {
  const PriceFiltersRangesList({
    super.key,
    required this.boutiqueSlug,
    this.category,
    required this.currencySymbol,
    required this.priceRanges,
    required this.exchangeRate,
  });

  final String boutiqueSlug;
  final String currencySymbol;
  final double exchangeRate;
  final List<PriceRange> priceRanges;
  final String? category;

  @override
  State<PriceFiltersRangesList> createState() => _PriceFiltersRangesListState();
}

class _PriceFiltersRangesListState extends State<PriceFiltersRangesList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.priceRanges.isNullOrEmpty) {
      return SizedBox.shrink();
    }
    return SizedBox(
        height: 70,
        child: ListView.separated(
          itemCount: widget.priceRanges.length ?? 0,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (ctx, index) => SizedBox(
            width: 10,
          ),
          itemBuilder: (ctx, index) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
                    Filter? prevChoosedOrAppliedFilterToAddToIt =
                        homeBloc.state.appliedFiltersByUser?.filters;
                    if (prevChoosedOrAppliedFilterToAddToIt == null) {
                      prevChoosedOrAppliedFilterToAddToIt = Filter();
                    }
                    if (prevChoosedOrAppliedFilterToAddToIt.prices == null) {
                      prevChoosedOrAppliedFilterToAddToIt =
                          prevChoosedOrAppliedFilterToAddToIt
                              .copyWithSaveOtherField(
                                  prices: Prices(
                                      currencySymbol: widget.currencySymbol,
                                      minPrice:
                                          widget.priceRanges[index].minPrice,
                                      maxPrice:
                                          widget.priceRanges[index].maxPrice));
                    } else if (prevChoosedOrAppliedFilterToAddToIt
                                .prices!.minPrice !=
                            widget.priceRanges[index].minPrice ||
                        prevChoosedOrAppliedFilterToAddToIt.prices!.maxPrice !=
                            widget.priceRanges[index].maxPrice) {
                      prevChoosedOrAppliedFilterToAddToIt =
                          prevChoosedOrAppliedFilterToAddToIt
                              .copyWithSaveOtherField(
                                  prices: Prices(
                                      currencySymbol: widget.currencySymbol,
                                      minPrice:
                                          widget.priceRanges[index].minPrice,
                                      maxPrice:
                                          widget.priceRanges[index].maxPrice));
                    } else {
                      prevChoosedOrAppliedFilterToAddToIt =
                          prevChoosedOrAppliedFilterToAddToIt
                              .copyWithSaveOtherField(prices: null);
                    }
                    homeBloc.add(GetProductsWithFiltersEvent(
                        boutiqueSlug: widget.boutiqueSlug,
                        filtersAppliedByUser: GetProductFiltersModel(
                            filters: prevChoosedOrAppliedFilterToAddToIt),
                        category: widget.category,
                        offset: 1));
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 20),
                    child: DottedBorder(
                        radius: Radius.circular(180),
                        borderType: BorderType.RRect,
                        strokeCap: StrokeCap.square,
                        strokeWidth: 0.5,
                        color: Color(0xff6B6B6B),
                        padding: EdgeInsets.all(8),
                        dashPattern: [3, 3],
                        child: Center(
                          child: Text(
                            '${(widget.priceRanges[index].minPrice! * widget.exchangeRate).toStringAsFixed(2)} - ${(widget.priceRanges[index].maxPrice! * widget.exchangeRate).toStringAsFixed(2)} ${widget.currencySymbol}',
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: textTheme.bodyText2?.mq.copyWith(
                              height: 1.3,
                              fontSize: 15.sp,
                              color: const Color(0xff5D5C5D),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
