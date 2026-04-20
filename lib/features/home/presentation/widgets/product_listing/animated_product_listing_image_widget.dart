import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class AnimatedProductListingImageWidget extends StatelessWidget {
  const AnimatedProductListingImageWidget({
    super.key,
    this.width,
    this.height,
    required this.innerShadowYOffset,
    this.borderColor,
    required this.orginalHeight,
    required this.orginalWidth,
    this.withBackGroundShadow = false,
    required this.circleShape,
    required this.imageUrl,
  });

  final double? width;
  final double? height;
  final bool circleShape;
  final double orginalWidth;
  final double orginalHeight;
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
    return AnimatedSize(
      duration: const Duration(milliseconds: 7000),
      curve: Curves.fastEaseInToSlowEaseOut,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(circleShape ? 180.r : 15.r),
          ),
          border: Border.all(
            width: (width == 20 || width == 200) ? 0.5 : 1,
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
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(circleShape ? 180.r : 15.r),
          ),
          child: Stack(
            children: [
              MyCachedNetworkImage(
                ordinalHeight: orginalHeight,
                ordinalwidth: orginalWidth,
                imageUrl: imageUrl,
                width: width!,
                imageFit: BoxFit.cover,
                height: height!,
              ),
              //Image.asset(imageUrl , fit: BoxFit.cover, width: width, height: height,),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, innerShadowYOffset),
                      blurRadius: 6,
                      color: Colors.white,
                      inset: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
