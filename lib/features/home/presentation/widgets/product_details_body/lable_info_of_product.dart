import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class lableInfoProduct extends StatelessWidget {
  const lableInfoProduct({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 10.h, left: 20.w, right: 20.w),
      child: SizedBox(
        height: 14.h,
        width: 1.sw,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SvgPicture.asset(AppAssets.bestPriceSvg),
            MyTextWidget(
              " ! ${LocaleKeys.best_price.tr()}",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              " Last ` Days ",
              style: context.textTheme.titleMedium?.rq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "!",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(AppAssets.trendingSvg, height: 14.h, width: 14.w),
            MyTextWidget(
              "Trend ",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xffFF641A),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "Color ",
              style: context.textTheme.titleMedium?.rq.copyWith(
                height: 1.3,
                color: const Color(0xffFF641A),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "!",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xffFF641A),
                fontSize: 11.sp,
              ),
            ),
            SizedBox(width: 12.w),
            SvgPicture.asset(AppAssets.bestSellSvg),
            MyTextWidget(
              " ${LocaleKeys.best_sell.tr()} ",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xff513AAF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "Last Week ",
              style: context.textTheme.titleMedium?.rq.copyWith(
                height: 1.3,
                color: const Color(0xff513AAF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "!",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xff513AAF),
                fontSize: 11.sp,
              ),
            ),
            SizedBox(width: 12.w),
            SvgPicture.asset(
              AppAssets.fastPackingManIconSvg,
              // ignore: deprecated_member_use
              color: const Color(0xff388CFF),
              width: 14.w,
              height: 14.h,
            ),
            MyTextWidget(
              " ${LocaleKeys.fast_packing.tr()} ",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "${LocaleKeys.today_shipping_if_buy_before.tr()} ",
              style: context.textTheme.titleMedium?.rq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "13:00",
              style: context.textTheme.titleMedium?.bq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
            MyTextWidget(
              "${LocaleKeys.today.tr()} ",
              style: context.textTheme.titleMedium?.rq.copyWith(
                height: 1.3,
                color: const Color(0xff388CFF),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
