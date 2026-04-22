import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class BadgesList extends StatelessWidget {
  final List<Label>? lable;
  const BadgesList({super.key, required this.lable});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return lable.isNullOrEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 14,
            child: ListView.separated(
              padding: EdgeInsets.only(right: 20.w, left: 20.w),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    SvgPicture.network(
                      lable![index].icon!.filePath!,
                      width: 12.w,
                      height: 12.h,
                    ),
                    SizedBox(width: 5.w),
                    MyTextWidget(
                      lable![index].label!,
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        height: 1.27,
                        color: const Color(0xff8D8D8D),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(width: 9.w);
              },
              itemCount: lable!.length,
            ),
          );
  }
}
