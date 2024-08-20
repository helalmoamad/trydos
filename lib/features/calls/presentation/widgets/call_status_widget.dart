import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';

import '../../../app/my_text_widget.dart';

class CallStatusWidget extends StatefulWidget {
  const CallStatusWidget(
      {Key? key,
      required this.text,
      required this.iconUrl,
      required this.textColor})
      : super(key: key);
  final String text;
  final String iconUrl;
  final Color textColor;

  @override
  State<CallStatusWidget> createState() => _CallStatusWidgetState();
}

class _CallStatusWidgetState extends ThemeState<CallStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: HWEdgeInsetsDirectional.only(start: 15.w),
          child: SvgPicture.asset(
            widget.iconUrl,
            width: 25.sp,
            height: 25.sp,
          ),
        ),
        10.verticalSpace,
        MyTextWidget(
          widget.text,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.lr.copyWith(color: widget.textColor),
        )
      ],
    );
  }
}
