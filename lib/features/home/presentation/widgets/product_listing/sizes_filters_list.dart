import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

class SizesFiltersList extends StatefulWidget {
  const SizesFiltersList({
    super.key, required this.selectedFilters, required this.sizes,
  });
  final ValueNotifier<List<int>> selectedFilters;
  final List<String> sizes ;
  @override
  State<SizesFiltersList> createState() => _SizesFiltersListState();
}

class _SizesFiltersListState extends State<SizesFiltersList> {
  final CarouselController carouselController = CarouselController();
  late final ValueNotifier<int> currentIndexInSizes ;

  @override
  void initState() {
    currentIndexInSizes = ValueNotifier(widget.sizes.length ~/ 2);
    super.initState();
  }

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
                'Filter By Size',
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
            height: 70,
            child: ValueListenableBuilder<List<int>>(
                valueListenable: widget.selectedFilters,
                builder: (context, selected, child) {
                  return ValueListenableBuilder<int>(
                      valueListenable: currentIndexInSizes,
                      builder: (context, currentIndex, _) {
                        return ListView.separated(
                            itemCount: widget.sizes.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (ctx , index)=> SizedBox(width: 10,),
                            itemBuilder: (ctx, index) {
                              return Stack(
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
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: DottedBorder(
                                          radius: Radius.circular(180),
                                          borderType: BorderType.RRect,
                                          strokeCap: StrokeCap.round,
                                          strokeWidth: 0.5,
                                          color: Color(0xff6B6B6B),
                                          dashPattern: [3, 3],
                                          child: Center(
                                            child: Text(
                                              widget.sizes[index],
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                              // index == currentIndex
                                              //     ? textTheme.bodyText2?.bq.copyWith(
                                              //   height: 1.3,
                                              //   fontSize: 15.sp,
                                              //   color: const Color(0xff5D5C5D),
                                              // )
                                              //     :
                                              textTheme.bodyText2?.mq.copyWith(
                                                height: 1.3,
                                                fontSize: 15.sp,
                                                color: const Color(0xff5D5C5D),
                                              ),
                                            ),
                                          )
                                        ),
                                      ),),
                                  Visibility(
                                      visible: selected.contains(index),
                                      child: FilterSelectedMark(width: 20, height: 20))
                                ],
                              );
                            },
                            );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
