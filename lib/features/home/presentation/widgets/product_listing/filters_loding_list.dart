import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class FiltersLoadingListPage extends StatefulWidget {
  const FiltersLoadingListPage({super.key, required this.countOfListInPage});

  final int countOfListInPage;

  @override
  State<FiltersLoadingListPage> createState() => _FiltersLoadingListPageState();
}

class _FiltersLoadingListPageState extends State<FiltersLoadingListPage> {
  List<String> titles = [
    '${LocaleKeys.categories.tr()}',
    '${LocaleKeys.Brands.tr()}',
    '${LocaleKeys.colors.tr()}',
    '${LocaleKeys.offer.tr()}',
    '${LocaleKeys.sizes.tr()}',
    '${LocaleKeys.prices.tr()}',
  ];

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        addRepaintBoundaries: false,
        itemCount: widget.countOfListInPage,
        padding: EdgeInsetsDirectional.only(start: 15.w),
        shrinkWrap: true,
        itemBuilder: (ctx, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Center(child: SvgPicture.asset(AppAssets.filtersSvg)),
                  SizedBox(width: 10.w),
                  Text('${LocaleKeys.filter_by.tr()} ${titles[index]}'),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 70.h,
                child: index == 5
                    ? FlutterSlider(
                        values: const [1, 1000],
                        max: 1000,
                        min: 1,
                        disabled: true,
                        handlerWidth: 40.w,
                        handlerHeight: 40.h,
                        handler: FlutterSliderHandler(),
                        rightHandler: FlutterSliderHandler(),
                        rangeSlider: true,
                      )
                    : ListView.separated(
                        addRepaintBoundaries: false,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (ctx, index) {
                          return SizedBox(width: 10.w);
                        },
                        itemBuilder: (ctx, index) {
                          return CircleAvatar(radius: 35.r);
                        },
                        itemCount: 6,
                      ),
              ),
              SizedBox(height: 20.h),
            ],
          );
        },
      ),
    );
  }
}
