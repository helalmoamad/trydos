import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';

import '../../../../../common/helper/helper_functions.dart';

class ProductDetailsChipWidget extends StatelessWidget {
  const ProductDetailsChipWidget(
      {super.key, this.withIcon = false, required this.descriptor});
  final DataDescriptor? descriptor;
  final bool withIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HelperFunctions.showDescriptionForProductDetails(context: context);
      },
      child: DottedBorder(
        radius: Radius.circular(15),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        strokeWidth: 0.5,
        color: Color(0xff707070),
        dashPattern: [3, 3],
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgNetworkWidget(
              svgUrl: descriptor!.descriptorGroup!.icon!,
              width: 20,
              height: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextWidget(
                  descriptor!.descriptorGroup!.name!,
                  style: context.textTheme.titleSmall?.rq
                      .copyWith(color: Color(0xffC4C2C2), height: 1.3),
                ),
                SizedBox(
                  height: 16,
                  child: ListView.separated(
                    itemCount: descriptor!.descriptors!.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (withIcon) ...{
                              MyTextWidget(
                                descriptor!.descriptors![index].value!,
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                        height: 1.23,
                                        color: Color(0xff505050),
                                        fontSize: 13.sp),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: SvgNetworkWidget(
                                  svgUrl: descriptor!
                                      .descriptors![index].descriptor!.icon!,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            },
                            MyTextWidget(
                              descriptor!.descriptors![index].descriptor!.name!,
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                  height: 1.23,
                                  color: Color(0xff8D8D8D),
                                  fontSize: 13.sp),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        width: 1,
                        decoration: BoxDecoration(
                            color: Color(0xff8D8D8D),
                            borderRadius: BorderRadius.circular(2)),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
