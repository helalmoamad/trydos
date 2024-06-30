import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

class FiltersNormalList extends StatefulWidget {
  const FiltersNormalList(
      {super.key, required this.filterListTitle, required this.isBrandFilter, required this.selectedFilters});

  final bool isBrandFilter;
  final String filterListTitle;
  final ValueNotifier<List<int>> selectedFilters;

  @override
  State<FiltersNormalList> createState() => _FiltersNormalListState();
}

class _FiltersNormalListState extends State<FiltersNormalList> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
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
                                  widget.selectedFilters.value.remove(index);
                                } else {
                                  widget.selectedFilters.value.add(index);
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
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: SvgPicture.asset(AppAssets.mangoSvg),
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
                              'T-shirt',
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
                      itemCount: 10);
                }),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
