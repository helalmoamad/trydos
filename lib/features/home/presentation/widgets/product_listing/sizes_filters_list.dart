import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';

class SizesFiltersList extends StatefulWidget {
  const SizesFiltersList({
    super.key,
    required this.selectedFilters,
    this.hideTitle = false,
    required this.attribute,
    this.addItemToAnimatedList,
    this.removeItemToAnimatedList,
    required this.boutiqueSlug,
    this.category,
  });

  final ValueNotifier<List<int>> selectedFilters;
  final Attribute attribute;

  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;
  final void Function(int index)? addItemToAnimatedList;

  final void Function(int removedIndex, String removedItem)?
      removeItemToAnimatedList;

  @override
  State<SizesFiltersList> createState() => _SizesFiltersListState();
}

class _SizesFiltersListState extends State<SizesFiltersList> {
  final CarouselController carouselController = CarouselController();
  late final ValueNotifier<int> currentIndexInSizes;

  @override
  void initState() {
    currentIndexInSizes =
        ValueNotifier((widget.attribute.options?.length ?? 0) ~/ 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          },
          SizedBox(
            height: 70,
            child: ValueListenableBuilder<List<int>>(
                valueListenable: widget.selectedFilters,
                builder: (context, selected, child) {
                  return ValueListenableBuilder<int>(
                      valueListenable: currentIndexInSizes,
                      builder: (context, currentIndex, _) {
                        return ListView.separated(
                          itemCount: widget.attribute.options?.length ?? 0,
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
                                    if (selected.contains(index)) {
                                      String removed =
                                          widget.attribute.options![index];
                                      int removedIndex = selected.indexWhere(
                                          (element) => element == index);
                                      widget.selectedFilters.value
                                          .remove(index);
                                      widget.removeItemToAnimatedList
                                          ?.call(removedIndex, removed);
                                    } else {
                                      if (widget.hideTitle) {
                                        String keyOfChoosedFilters =
                                            widget.boutiqueSlug +
                                                (widget.category ?? '');
                                        String size =
                                            widget.attribute.options![index];
                                        Filter? prevChoosedFilters = BlocProvider
                                                .of<HomeBloc>(context)
                                            .state
                                            .choosedFiltersInEachBoutiqueModel[
                                                keyOfChoosedFilters]
                                            ?.filters;
                                        if (prevChoosedFilters == null) {
                                          prevChoosedFilters = Filter();
                                        }
                                        prevChoosedFilters =
                                            prevChoosedFilters.copyWith(
                                          attributes: prevChoosedFilters
                                                  .attributes.isNullOrEmpty
                                              ? [
                                                  Attribute(
                                                      id: widget.attribute.id,
                                                      name:
                                                          widget.attribute.name,
                                                      options: [size])
                                                ]
                                              : [
                                                  prevChoosedFilters
                                                      .attributes![0]
                                                      .copyWith(options: [
                                                    ...prevChoosedFilters
                                                            .attributes![0]
                                                            .options ??
                                                        [],
                                                    size
                                                  ])
                                                ],
                                        );
                                        BlocProvider.of<HomeBloc>(context).add(
                                            GetProductsWithFiltersEvent(
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
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
                                          widget.selectedFilters.value.length -
                                              1);
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
                                            widget.attribute.options![index],
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                // index == currentIndex
                                                //     ? textTheme.bodyText2?.bq.copyWith(
                                                //   height: 1.3,
                                                //   fontSize: 15.sp,
                                                //   color: const Color(0xff5D5C5D),
                                                // )
                                                //     :
                                                textTheme.bodyText2?.mq
                                                    .copyWith(
                                              height: 1.3,
                                              fontSize: 15.sp,
                                              color: const Color(0xff5D5C5D),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                Visibility(
                                    visible: selected.contains(index),
                                    child: FilterSelectedMark(
                                        width: 20, height: 20))
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
