import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_event.dart';

class FiltersNormalList<T> extends StatefulWidget {
  const FiltersNormalList(
      {super.key,
      required this.filterListTitle,
      this.hideTitle = false,
      required this.isBrandFilter,
      required this.selectedFilters,
      required this.filters,
      this.addItemToAnimatedList,
      this.removeItemToAnimatedList,
      required this.boutiqueSlug,
      this.category});

  final bool isBrandFilter;
  final String filterListTitle;
  final ValueNotifier<List<int>> selectedFilters;
  final List<T> filters;

  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;
  final void Function(int index)? addItemToAnimatedList;
  final void Function(int index, Brand removedItem)? removeItemToAnimatedList;

  @override
  State<FiltersNormalList> createState() => _FiltersNormalListState();
}

class _FiltersNormalListState extends State<FiltersNormalList> {
  @override
  Widget build(BuildContext context) {
    if (widget.filters.isNullOrEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.hideTitle ? 0 : 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.hideTitle) ...{
            Row(
              children: [
                FilterSelectedMark(width: 20, height: 20),
                SizedBox(
                  width: 10,
                ),
                MyTextWidget(
                  widget.filterListTitle,
                  style: context.textTheme.caption?.rq
                      .copyWith(color: Color(0xff505050), height: 15 / 12),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.registerInfoSvg,
                  color: Color(0xffD3D3D3),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
          },
          SizedBox(
            height: 105,
            child: ValueListenableBuilder<List<int>>(
                valueListenable: widget.selectedFilters,
                builder: (context, selected, child) {
                  return ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (selected.contains(index)) {
                                  dynamic removed = widget.filters[index];
                                  int removedIndex = selected.indexWhere(
                                      (element) => element == index);
                                  widget.selectedFilters.value.remove(index);
                                  widget.removeItemToAnimatedList
                                      ?.call(removedIndex, removed);
                                } else {
                                  if (widget.hideTitle) {
                                    String keyOfChoosedFilters =
                                        widget.boutiqueSlug +
                                            (widget.category ?? '');
                                    dynamic item = widget.filters[index];
                                    Filter? prevChoosedFilters =
                                        BlocProvider.of<HomeBloc>(context)
                                            .state
                                            .choosedFiltersInEachBoutiqueModel[
                                                keyOfChoosedFilters]
                                            ?.filters;
                                    if (prevChoosedFilters == null) {
                                      prevChoosedFilters = Filter();
                                    }
                                    prevChoosedFilters =
                                        prevChoosedFilters.copyWithSaveOtherField(
                                            brands: !widget.isBrandFilter
                                                ? prevChoosedFilters.brands
                                                : prevChoosedFilters
                                                        .brands.isNullOrEmpty
                                                    ? [item]
                                                    : [
                                                        ...prevChoosedFilters
                                                            .brands!,
                                                        item
                                                      ]);
                                    BlocProvider.of<HomeBloc>(context).add(
                                        GetProductsWithFiltersEvent(
                                            boutiqueSlug: widget.boutiqueSlug,
                                            filtersChoosedByUser:
                                                GetProductFiltersModel(
                                                    filters:
                                                        prevChoosedFilters),
                                            category: widget.category,
                                            offset: 1));
                                    return;
                                  }
                                  widget.selectedFilters.value.add(index);
                                  widget.addItemToAnimatedList?.call(
                                      widget.selectedFilters.value.length - 1);
                                }
                                widget.selectedFilters.notifyListeners();
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 3,
                                            offset: Offset(0, 3))
                                      ],
                                      border:
                                          Border.all(color: Color(0xffC4C2C2)),
                                    ),
                                    child: Center(
                                      child: widget.isBrandFilter
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                              child: SvgNetworkWidget(
                                                svgUrl:
                                                    widget.filters[index].image,
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  ),
                                  Visibility(
                                      visible: selected.contains(index),
                                      child: FilterSelectedMark(
                                          width: 20, height: 20))
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            MyTextWidget(
                              widget.isBrandFilter
                                  ? widget.filters[index].name
                                  : 'T-shirt',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: context.textTheme.caption?.rq.copyWith(
                                  color: Color(0xff8E8E8E),
                                  letterSpacing: 0,
                                  height: 1.25),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (ctx, index) => SizedBox(
                            width: 10,
                          ),
                      itemCount: widget.filters.length);
                }),
          ),
          SizedBox(height: !widget.hideTitle ? 20 : 0),
        ],
      ),
    );
  }
}
