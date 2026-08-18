import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart' show LocaleKeys;
import 'package:trydos/service/language_service.dart';

class ProductDetailsImageWidget extends StatelessWidget {
  const ProductDetailsImageWidget({
    super.key,
    this.width,
    this.imageUrl,
    this.withBackGroundShadow = true,
    this.withInnerShadow = true,
    this.borderRadius,
    this.borderColor,
    this.imageFit,
    this.imageHeight,
    this.isRedeem = false,
    this.productId,
    this.flashDealEndDate,
    this.lableNames,
    this.orginalHeight,
    this.index = -1,
    this.blurRadius = 10,
    this.imageWidth,
    this.visibleRedeemNotifier,
    this.orginalWidth,
    this.isFlashDealEnded,
    this.visibleFlashDeal,
    this.height,
    this.visibleRedeem,
    this.radius,
  });

  final double? width;

  final List<String>? lableNames;

  final DateTime? flashDealEndDate;
  final bool? isRedeem;

  final bool? isFlashDealEnded;
  final bool? visibleRedeem;
  final int? productId;
  final int index;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final double? blurRadius;
  final double? orginalWidth;
  final double? orginalHeight;
  final double? radius;
  final String? imageUrl;
  final BoxFit? imageFit;
  final ValueNotifier<bool>? visibleRedeemNotifier;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool withBackGroundShadow;
  final ValueNotifier<bool>? visibleFlashDeal;
  final bool withInnerShadow;

  @override
  Widget build(BuildContext context) {
    final double boxHeight = height ?? 464.h;
    final double boxWidth = width ?? 320.w;

    // كان نفس التعبير مكرّراً في الصندوق والـ ClipRRect
    final BorderRadiusGeometry effectiveBorderRadius = index == 0
        ? BorderRadius.only(
            bottomRight: LanguageService.languageCode != "ar"
                ? Radius.circular(0.r)
                : Radius.circular(15.r),
            topRight: LanguageService.languageCode != "ar"
                ? Radius.circular(0.r)
                : Radius.circular(15.r),
            topLeft: LanguageService.languageCode == "ar"
                ? Radius.circular(0.r)
                : Radius.circular(15.r),
            bottomLeft: LanguageService.languageCode == "ar"
                ? Radius.circular(0.r)
                : Radius.circular(15.r),
          )
        : borderRadius ?? BorderRadius.circular((radius ?? 30.r));

    // ارتفاع التوهّج الأبيض على الحافة العليا: الإزاحة 3 + نصف قطر الضبابية 6،
    // وهي المنطقة نفسها التي كان يرسمها الظل الداخلي السابق.
    final double glowStop = (9 / boxHeight).clamp(0.0, 1.0);

    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 4.0,
      child: Stack(
        children: [
          Container(
            height: boxHeight,
            width: boxWidth,
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                width: 0.5,
                color: borderColor ?? context.colorScheme.white,
              ),
              boxShadow: withBackGroundShadow
                  ? [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: context.colorScheme.black.withOpacity(0.01),
                        blurRadius: blurRadius ?? 10,
                      ),
                    ]
                  : null,
            ),
            // التوهّج الأبيض فوق الصورة. كان صندوقاً ثانياً في الـ Stack يحمل
            // BoxShadow(inset: true) من flutter_inset_box_shadow، وهي تنفّذه
            // بـ drawDRRect مع MaskFilter.blur — خارج المسار السريع في Impeller
            // ⇒ نسيج خارج الشاشة وgaussian بمرورين لكل عنصر في كل إطار داخل
            // القائمة الأفقية. التدرّج يعطي الشكل نفسه برسمة واحدة بلا ضبابية،
            // وفي foregroundDecoration فيوفّر أيضاً RenderObject كاملاً.
            foregroundDecoration: withInnerShadow
                ? BoxDecoration(
                    borderRadius: effectiveBorderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colorScheme.white,
                        // withAlpha(0) لا Colors.transparent: الأخير أسود شفاف
                        // فينتج حافة رمادية عند الاستيفاء
                        context.colorScheme.white.withAlpha(0),
                      ],
                      stops: [0.0, glowStop],
                    ),
                  )
                : null,
            child: ClipRRect(
              borderRadius: effectiveBorderRadius,
              // رابط فارغ ⇒ لا شيء. كان الشرط `?? true` يعرض صورة العنوان
              // (address2.png) بمساحة الصندوق كاملة — وهو ما يظهر كوميض عريض
              // في الأقسام التي تُبنى قبل وصول بياناتها (الريلز، صور المشترين).
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? const SizedBox.shrink()
                  : imageUrl!.contains('assets')
                  // كان يعرض address2.png دائماً متجاهلاً الرابط الممرَّر
                  ? Image.asset(imageUrl!, fit: imageFit ?? BoxFit.cover)
                  : MyCachedNetworkImage(
                      ordinalHeight: orginalHeight,
                      ordinalwidth: orginalWidth,
                      imageUrl: imageUrl!,
                      radius: index != -1 ? 0 : 12.r,
                      imageWidth: imageWidth,
                      imageHeight: imageHeight,
                      height: boxHeight,
                      width: boxWidth,
                      imageFit: BoxFit.fitWidth,
                    ),
            ),
          ),
          index != 0
              ? const SizedBox.shrink()
              : Positioned(
                  bottom: 0,
                  right: LanguageService.languageCode != "ar" ? null : 0,
                  left: LanguageService.languageCode == "ar" ? null : 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 25.w,
                        height: 25.h,
                        decoration: BoxDecoration(
                          color: const Color(0xff513AAF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.r),
                            bottomRight: Radius.circular(
                              LanguageService.languageCode == "ar" ? 15.r : 6.r,
                            ),
                            bottomLeft: Radius.circular(
                              LanguageService.languageCode != "ar" ? 15.r : 6.r,
                            ),
                            topRight: Radius.circular(6.r),
                          ),
                        ),
                      ),
                      SvgPicture.asset(AppAssets.malekanSvg),
                    ],
                  ),
                ),
          (flashDealEndDate == null) || index != 0
              ? const SizedBox.shrink()
              : !(isFlashDealEnded ?? true)
              ? Positioned(
                  left: 4,
                  right: 4,
                  top: 0,
                  child: Transform(
                    transform: Matrix4.skewX(-0.4), // انحراف بسيط للشكل
                    child: Container(
                      margin: EdgeInsets.only(
                        left: LanguageService.languageCode != "ar" ? 1 : 170.w,
                        right: LanguageService.languageCode == "ar" ? 1 : 170.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffFF6200)),
                        color: const Color(0xffFFF3E8),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      height: 20.h,
                      child: Transform(
                        transform: Matrix4.skewX(0.4), // انحراف بسيط للشكل
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            SvgPicture.asset(
                              AppAssets.flashDealSvg,
                              height: 12.h,
                              // ignore: deprecated_member_use
                              color: const Color(0xffFF6200),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${LocaleKeys.flash_deal.tr()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: const Color(0xffFF6200),
                                letterSpacing: 0.18,
                                fontSize: 9.sp,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(width: 2),
                            FlashDealCountdownTimerWidget(
                              visibleFlashDeal: visibleFlashDeal,
                              endDateTime: flashDealEndDate ?? DateTime.now(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          visibleRedeem == true && index == 0
              ? Positioned(
                  left: 4.w,
                  right: 4.w,
                  top: 0,
                  child: Transform(
                    transform: Matrix4.skewX(-0.4), // انحراف بسيط للشكل
                    child: Container(
                      width: 150.w,
                      margin: EdgeInsets.only(
                        left: LanguageService.languageCode != "ar" ? 1 : 130.w,
                        right: LanguageService.languageCode == "ar" ? 1 : 130.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffFF6200)),
                        color: const Color(0xffFFF3E8),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      height: 20.h,
                      child: Transform(
                        transform: Matrix4.skewX(0.4), // انحراف بسيط للشكل
                        child: Row(
                          children: [
                            SizedBox(width: 8.w),
                            SvgPicture.asset(AppAssets.redeemClockSvg),
                            SizedBox(width: 3.w),
                            Text(
                              LocaleKeys.luck.tr(),
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                fontSize: 9.sp,
                                color: const Color(0xffFF6200),
                              ),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              " ${LocaleKeys.add_to_bag_within.tr()} ",
                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                fontSize: 9.sp,
                                color: const Color(0xffFF6200),
                              ),
                            ),
                            SecondsCountdown(
                              denyStopTimer: true,
                              productId: productId.toString(),
                              //   finishRedeem: widget.finishRedeem,
                              visibleRedeem: visibleRedeemNotifier!,
                              endTime:
                                  GetIt.I<PrefsRepository>()
                                      .getRedeemDateForProduct(
                                        productId.toString(),
                                      ) ??
                                  DateTime.now(),
                            ),
                            Text(
                              " ${LocaleKeys.seconds.tr()} ",
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                fontSize: 9.sp,
                                color: const Color(0xffFF6200),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          ((visibleRedeem == true || !(isFlashDealEnded ?? true)) && index == 0)
              ? Positioned(
                  left: LanguageService.languageCode == "ar" ? null : 35.w,
                  right: LanguageService.languageCode != "ar" ? null : 35.w,
                  top: 80.h,
                  child: Container(
                    width: 97.w,
                    height: 20.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 76.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.r),
                            ),
                            color: const Color(0xff1D1D1D),
                          ),
                          child: Text(
                            "${LocaleKeys.only_this_piece.tr()}",
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              fontSize: 9.sp,
                              color: const Color(0xffFFFFFF),
                            ),
                          ),
                        ),
                        Container(
                          width: 15.w,
                          height: 15.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffFFFFFF)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.r),
                            ),
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
