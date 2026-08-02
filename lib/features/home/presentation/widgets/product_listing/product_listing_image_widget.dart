import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

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
    this.radius = 12,
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

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(circleShape ? 180.r : 15.r),
        ),
        border: Border.all(
          width: (width == 20.w || width == 200.w) ? 0.5.w : 1.w,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          imageUrl.contains('assets')
              ? Image.asset(
                  imageUrl,
                  width: width!,
                  fit: BoxFit.cover,
                  height: height!,
                )
              : MyCachedNetworkImage(
                  //       progressIndicatorBuilderWidget:
                  //           ((width ?? 0) > 50) ? null : SizedBox.shrink(),
                  imageUrl: imageUrl,
                  width: width!,
                  ordinalwidth: orginalWidth,
                  ordinalHeight: orginalHeight,
                  imageHeight: imageHeight,
                  imageWidth: imageWidth,
                  radius: circleShape ? 180.r : radius,
                  imageFit: BoxFit.contain,
                  innerShadowYOffset: innerShadowYOffset,
                  withInnerShadow: true,
                  height: height!,
                ),
          //Image.asset(imageUrl , fit: BoxFit.cover, width: width, height: height,),
        ],
      ),
    );
  }
}
