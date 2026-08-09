import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

class ProductListingImageWidget extends StatelessWidget {
  const ProductListingImageWidget({
    super.key,
    this.width,
    this.height,
    this.imageHeight,
    this.imageWidth,
    this.orginalHeight,
    this.orginalWidth,
    required this.innerShadowYOffset,
    this.borderColor,
    this.radius = 15,
    this.imageFit = BoxFit.contain,
    this.withBackGroundShadow = false,
    required this.circleShape,
    required this.imageUrl,
  });

  final double? imageWidth;
  final double? imageHeight;
  final double? width;
  final double? height;
  final double radius;
  final bool circleShape;
  final double? orginalWidth;
  final double? orginalHeight;
  final bool withBackGroundShadow;
  final double innerShadowYOffset;
  final Color? borderColor;
  final String imageUrl;

  /// كان `contain` مثبّتاً: الصورة لا تملأ الإطار فتظهر أشرطة فارغة حين
  /// تختلف نسبة أبعادها عن نسبة الصندوق (كما في مصغّرات الألوان).
  final BoxFit imageFit;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
        // كان 15.r ثابتاً فيتجاهل radius الممرَّر، فلا تطابق زوايا الإطار
        // زوايا الصورة بداخله (6 مقابل 15 في مصغّرات الألوان)
        borderRadius: BorderRadius.all(
          Radius.circular(circleShape ? 180.r : radius),
        ),
        border: Border.all(
          // الحدّ الأبيض زخرفي فيكفيه شعرة (0.5)، أمّا الحدّ الملوّن الصريح
          // (إطار الاسترداد البرتقالي) فرسالة للمستخدم ويجب أن يُرى
          width: borderColor != null
              ? 1.2.w
              : ((width == 20.w || width == 200.w) ? 0.5.w : 1.w),
          color: borderColor ?? const Color(0xffffffff),
        ),
        boxShadow: withBackGroundShadow
            ? [
                const BoxShadow(
                  color: Color(0x19000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      // كان Stack بابن واحد — أُزيل لتقليل طبقة رسم/تخطيط بلا فائدة
      child: imageUrl.contains('assets')
          ? Image.asset(
              imageUrl,
              width: width!,
              fit: BoxFit.cover,
              height: height!,
            )
          : MyCachedNetworkImage(
              imageUrl: imageUrl,
              width: width!,
              ordinalwidth: orginalWidth,
              ordinalHeight: orginalHeight,
              imageHeight: imageHeight,
              imageWidth: imageWidth,
              radius: circleShape ? 180.r : radius,
              imageFit: imageFit,
              innerShadowYOffset: innerShadowYOffset,
              withInnerShadow: true,
              height: height!,
            ),
    );
  }
}
