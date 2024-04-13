import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import '../../../../../core/utils/responsive_padding.dart';

class ProductDetailsDescriptionWidget extends StatefulWidget {
  ProductDetailsDescriptionWidget({super.key});

  @override
  State<ProductDetailsDescriptionWidget> createState() => _ProductDetailsDescriptionWidgetState();
}

class _ProductDetailsDescriptionWidgetState extends State<ProductDetailsDescriptionWidget> {
  final ValueNotifier<bool> readMoreNotifier = ValueNotifier(true);

   String text = 'Short Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knit Short Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knitshort Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knitshort Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knitshort Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knitshort Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Short Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knitshort Fitted Dress In Knit Fabric With A High Neck And Short Sleeves. Short Fitted Dress In Knit';
   String twoLines ='';

   @override
  void initState() {
    int index = 4 * ((1.sw.w - 40) ~/ 13.sp) - 12;
    while(text[index] != ' ' && index > 0){
      index--;
    }
    twoLines = text.substring(0 ,index + 1);
    text = text.substring(0 , text.lastIndexOf(' ') + 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: readMoreNotifier,
        builder: (context, readMore, child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
                maxLines: readMore ? 2 : 12,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(children: [
                  TextSpan(
                    text: readMore ? twoLines : text,
                    style: context.textTheme.bodyText2?.rq
                        .copyWith(height: 1.23, color: Color(0xff8D8D8D) , fontSize: 13.sp),
                  ),
                  TextSpan(
                      text: !readMore ? "Read Less..." : "Read More...",
                      style: context.textTheme.bodyText2?.rq
                          .copyWith(height: 1.23, color: Color(0xff388CFF), fontSize: 13.sp),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          readMoreNotifier.value = !readMoreNotifier.value;
                        }),
                ])),
          );
        });
  }
}
