import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';


class ColorsListFilter extends StatefulWidget {
  const ColorsListFilter(
      {super.key , this.hideTitle = false , required this.selectedFilters, required this.colors, this.addItemToAnimatedList, this.removeItemToAnimatedList, required this.boutiqueSlug, this.category});

  final ValueNotifier<List<int>> selectedFilters;
  final List<String> colors ;
  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;
  final void Function(int index)? addItemToAnimatedList;
  final void Function(int index , String removedItem)? removeItemToAnimatedList;

  @override
  State<ColorsListFilter> createState() => _ColorsListFilterState();
}

class _ColorsListFilterState extends State<ColorsListFilter> {

  @override
  Widget build(BuildContext context) {
    if(widget.colors.isNullOrEmpty){
      return SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.hideTitle ? 0 : 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(!widget.hideTitle)...{
            Row(
              children: [
                FilterSelectedMark(width: 20, height: 20),
                SizedBox(
                  width: 10,
                ),
                MyTextWidget(
                  'Filter By Color',
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
                                if (widget.hideTitle) {
                                  String keyOfChoosedFilters =
                                      widget.boutiqueSlug +
                                          (widget.category ?? '');
                                  String color = widget.colors[index];
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
                                          colors:  prevChoosedFilters
                                              .colors.isNullOrEmpty
                                              ? [color]
                                              : [
                                            ...prevChoosedFilters
                                                .colors!,
                                            color
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
                                if (selected.contains(index)) {
                                  String removed = widget.colors[index];
                                  int removedIndex = selected.indexWhere((element) => element == index);
                                  widget.selectedFilters.value.remove(index);
                                  widget.removeItemToAnimatedList?.call(removedIndex , removed);
                                } else {
                                  widget.selectedFilters.value.add(index);
                                  widget.addItemToAnimatedList?.call(widget.selectedFilters.value.length - 1);
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
                                      color: Color(int.parse('0xff${widget.colors[index].substring(1)}')),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 3,
                                            offset: Offset(0, 3))
                                      ],
                                      border:
                                      Border.all(color: Color(0xffC4C2C2)),
                                    ),
                                  ),
                                  Visibility(
                                      visible: selected.contains(index),
                                      child: FilterSelectedMark(
                                          width: 20, height: 20))
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (ctx, index) => SizedBox(
                        width: 10,
                      ),
                      itemCount: widget.colors.length);
                }),
          ),
          SizedBox(height: !widget.hideTitle ? 20 : 0),
        ],
      ),
    );
  }
}
