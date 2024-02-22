import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetMoreOptionsContent extends StatelessWidget {
  const ProductDetailsSheetMoreOptionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MaterialScrollBehavior(),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          10.verticalSpace,
          MyTextWidget('More Options',
              textAlign: TextAlign.center,
              style: context.textTheme.subtitle1?.mq.copyWith(
                color: Color(0xff505050),
              )),
          Spacer()
        ],
      ),
    );
  }
}
