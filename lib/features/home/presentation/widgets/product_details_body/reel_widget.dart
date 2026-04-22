import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../app/trydos_favorite_buton.dart';

class ReelWidget extends StatelessWidget {
  const ReelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Column(
      children: [
        Stack(
          children: [
            ProductDetailsImageWidget(
              height: 595.h,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.r),
                topLeft: Radius.circular(30.r),
              ),
              width: 1.sw,
              withBackGroundShadow: false,
              withInnerShadow: false,
              imageFit: BoxFit.fill,
            ),
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TrydosFavoriteButton(),
                  SizedBox(height: 25.h),
                  SvgPicture.asset(
                    AppAssets.shareSvg,
                    // ignore: deprecated_member_use
                    color: const Color(0xff505050),
                  ),
                  SizedBox(height: 25.h),
                  SvgPicture.asset(AppAssets.moreOptionSvg),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: 1.sw,
          padding: EdgeInsets.only(left: 10.w, top: 20.h, right: 10.w),
          decoration: BoxDecoration(
            color: const Color(0xfff8f8f8),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30.r),
              bottomLeft: Radius.circular(30.r),
            ),
          ),
          height: 110.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30.r),
                    bottomLeft: Radius.circular(30.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x29000000),
                      offset: Offset(0, 3.h),
                      blurRadius: 6.h,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20.r)),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: Image.asset(
                          AppAssets.profileJpg,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.5),
                              inset: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyTextWidget(
                          'Yxxx Oxxx',
                          style: context.textTheme.bodySmall?.rq.copyWith(
                            color: const Color(0xff969696),
                          ),
                        ),
                        MyTextWidget(
                          '18 feb',
                          style: context.textTheme.titleSmall?.rq.copyWith(
                            color: const Color(0xff8D8D8D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Flexible(
                      child: MyTextWidget(
                        '${LocaleKeys.amazing_product_buy_it_and_saw.tr()}',
                        style: context.textTheme.bodySmall?.rq.copyWith(
                          color: const Color(0xff5D5C5D),
                        ),
                        maxLines: 5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(AppAssets.favoriteSvg, height: 15.h),
                        SizedBox(width: 5.w),
                        MyTextWidget(
                          '110k',
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff8D8D8D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
