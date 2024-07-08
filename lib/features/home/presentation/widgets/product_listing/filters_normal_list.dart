import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../data/models/get_product_filters_model.dart';

class FiltersNormalList<T> extends StatefulWidget {
  const FiltersNormalList(
      {super.key, required this.filterListTitle, required this.isBrandFilter, required this.selectedFilters, required this.filters, this.addItemToAnimatedList, this.removeItemToAnimatedList});

  final bool isBrandFilter;
  final String filterListTitle;
  final ValueNotifier<List<int>> selectedFilters;
  final List<T> filters ;
  final void Function(int index)? addItemToAnimatedList;
  final void Function(int index , Brand removedItem)? removeItemToAnimatedList;

  @override
  State<FiltersNormalList> createState() => _FiltersNormalListState();
}

class _FiltersNormalListState extends State<FiltersNormalList> {

  @override
  Widget build(BuildContext context) {
    if(widget.filters.isNullOrEmpty){
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 3,
                                            offset: Offset(0, 3))
                                      ],
                                      border:
                                          Border.all(color: Color(0xffC4C2C2)),
                                    ),
                                    child: Center(
                                      child: widget.isBrandFilter
                                          ? Padding(
                                            padding:  EdgeInsets.symmetric(horizontal: 5.0),
                                            child: SvgNetworkWidget(svgUrl: widget.filters[index].image,),
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
                              widget.isBrandFilter ? widget.filters[index].name : 'T-shirt',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: context.textTheme.caption?.rq.copyWith(
                                  color: Color(0xff8E8E8E),
                                  letterSpacing: 0,
                                  height: 1.25),
                            ),
                            MyTextWidget(
                              '1100',
                              textAlign: TextAlign.center,
                              style: context.textTheme.caption?.rq.copyWith(
                                  color: Color(0xffC4C2C2),
                                  fontSize: 10.sp,
                                  letterSpacing: 0,
                                  height: 1.3),
                            )
                          ],
                        );
                      },
                      separatorBuilder: (ctx, index) => SizedBox(
                            width: 10,
                          ),
                      itemCount: widget.filters.length);
                }),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
