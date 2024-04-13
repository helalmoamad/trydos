import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

class ProductDetailsTitle extends StatelessWidget {
  const ProductDetailsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                AppAssets.mangoSvg,
                height: 18,
                width: 112,
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.eyeSvg,
                    height: 15,
                    width: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  MyTextWidget(
                    '200k',
                    style: context.textTheme.caption?.rq
                        .copyWith(color: Color(0xff505050), height: 1.26),
                  )
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 10,),
        Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              MyTextWidget(
                'Women Short Dress',
                style: context.textTheme.subtitle1?.mq.copyWith(
                    color: Color(0xff5D5C5D), height: 1.26, fontSize: 15.sp),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SvgPicture.asset(
                  AppAssets.dressSvg,
                  height: 15,
                  width: 15,
                ),
              ),
              Container(
                width: 1,
                height: 14,
                decoration: BoxDecoration(
                    color: Color(0xff8D8D8D),
                    borderRadius: BorderRadius.circular(2)
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: MyTextWidget(
                  'Denim Blue',
                  style: context.textTheme.subtitle1?.rq
                      .copyWith(color: Color(0xff404E68), height: 1.26, fontSize: 15.sp),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
