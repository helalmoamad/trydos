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
  final int decimalPoint;

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
    if (widget.priceRanges.isNullOrEmpty) {
      return SizedBox.shrink();
    }
    return SizedBox(
        height: 70,
        child: ListView.separated(
          itemCount: widget.priceRanges.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (ctx, index) => SizedBox(
            width: 10,
          ),
          itemBuilder: (ctx, index) {
            HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
            bool isSelected = (homeBloc.state.appliedFiltersByUser[key]?.filters
                        ?.prices?.minPrice ==
                    widget.priceRanges[index].maxPrice) &&
                (homeBloc.state.appliedFiltersByUser[key]?.filters?.prices
                        ?.maxPrice ==
                    widget.priceRanges[index].minPrice);
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    print('tab on price');
                    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
                    Filter? prevChoosedOrAppliedFilterToAddToIt =
                        homeBloc.state.appliedFiltersByUser[key]?.filters;
                    if (prevChoosedOrAppliedFilterToAddToIt == null) {
                      prevChoosedOrAppliedFilterToAddToIt = Filter();
                    }
                    if (prevChoosedOrAppliedFilterToAddToIt.prices == null) {
                      prevChoosedOrAppliedFilterToAddToIt =
                          prevChoosedOrAppliedFilterToAddToIt
                              .copyWithSaveOtherField(
                                  searchText:
                                      prevChoosedOrAppliedFilterToAddToIt
                                          .searchText,
                                  prices: Prices(
                                      currencySymbol: widget.currencySymbol,
                                      minPrice:
                                          widget.priceRanges[index].minPrice,
                                      maxPrice:
                                          widget.priceRanges[index].maxPrice));
                    } else if (prevChoosedOrAppliedFilterToAddToIt
                                .prices!.minPrice !=
                            widget.priceRanges[index].maxPrice ||
                        prevChoosedOrAppliedFilterToAddToIt.prices!.maxPrice !=
                            widget.priceRanges[index].minPrice) {
                      print(
                          "*********************************************************************");
                      prevChoosedOrAppliedFilterToAddToIt =
                          prevChoosedOrAppliedFilterToAddToIt
                              .copyWithSaveOtherField(
                                  searchText:
                                      prevChoosedOrAppliedFilterToAddToIt
                                          .searchText,
                                  prices: Prices(
                                      currencySymbol: widget.currencySymbol,
                                      minPrice:
                                          widget.priceRanges[index].minPrice,
                                      maxPrice:
                                          widget.priceRanges[index].maxPrice));
                    } else {
                      print(
                          "*********************************************************************");
                      prevChoosedOrAppliedFilterToAddToIt =
                          prevChoosedOrAppliedFilterToAddToIt
                              .copyWithSaveOtherField(
                                  prices: null,
                                  searchText:
                                      prevChoosedOrAppliedFilterToAddToIt
                                          .searchText);
                    }
                    homeBloc.add(ChangeAppliedFiltersEvent(
                      category: widget.category,
                      boutiqueSlug: widget.boutiqueSlug,
                      filtersAppliedByUser: GetProductFiltersModel(
                          filters: prevChoosedOrAppliedFilterToAddToIt),
                    ));
                    homeBloc.add(GetProductsWithFiltersEvent(
                        fromSearch: widget.fromHomeSearch,
                        searchText: widget.searchText,
                        boutiqueSlug: widget.boutiqueSlug,
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
                        color:
                            isSelected ? Color(0xffFF5F61) : Color(0xff6B6B6B),
                        padding: EdgeInsets.all(8),
                        dashPattern: [3, 3],
                        child: Center(
                          child: Text(
                            '${(widget.priceRanges[index].minPrice! * widget.exchangeRate).toStringAsFixed(widget.decimalPoint)} - ${(widget.priceRanges[index].maxPrice! * widget.exchangeRate).toStringAsFixed(2)} ${widget.currencySymbol}',
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: textTheme.titleLarge?.mq.copyWith(
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
