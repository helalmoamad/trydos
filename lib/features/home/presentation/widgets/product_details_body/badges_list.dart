import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

class BadgesList extends StatelessWidget {
  const BadgesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: ListView.separated(
          padding: EdgeInsets.only(left: 20),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.qualityBadgeSvg,
                  width: 12,
                  height: 12,
                ),
                SizedBox(
                  width: 5,
                ),
                MyTextWidget(
                  'Good Quality Product',
                  style: context.textTheme.caption?.rq
                      .copyWith(height: 1.27, color: Color(0xff8D8D8D)),
                )
              ],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 9,
            );
          },
          itemCount: 5),
    );
  }
}
