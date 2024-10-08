import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:trydos/features/app/my_cached_network_image.dart';

class ProductDetailsImageWidget extends StatelessWidget {
  const ProductDetailsImageWidget(
      {super.key,
      this.width,
      this.imageUrl,
      this.withBackGroundShadow = true,
      this.withInnerShadow = true,
      this.borderRadius,
      this.borderColor,
      this.imageFit,
      this.imageHeight,
      this.orginalHeight,
      this.imageWidth,
      this.orginalWidth,
      this.height,
      this.radius});

  final double? width;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final double? orginalWidth;
  final double? orginalHeight;
  final double? radius;
  final String? imageUrl;
  final BoxFit? imageFit;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool withBackGroundShadow;

  final bool withInnerShadow;

  @override
  Widget build(BuildContext context) {
    print(imageUrl);
    return Stack(
      children: [
        Container(
          height: (height ?? 464),
          width: (width ?? 320),
          decoration: BoxDecoration(
            borderRadius:
                borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
            border: Border.all(
                width: 0.5, color: borderColor ?? context.colorScheme.white),
            boxShadow: withBackGroundShadow
                ? [
                    BoxShadow(
                      color: context.colorScheme.black.withOpacity(0.1),
                      offset: Offset(0, 0),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
              borderRadius:
                  borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              child: imageUrl?.contains('assets') ?? true
                  ? Image.asset('assets/images/address2.png',
                      fit: imageFit ?? BoxFit.cover)
                  : MyCachedNetworkImage(
                      ordinalHeight: orginalHeight,
                      ordinalwidth: orginalWidth,
                      imageUrl: imageUrl!,
                      imageWidth: imageWidth,
                      imageHeight: imageHeight,
                      height: height ?? 464,
                      width: width ?? 320,
                      imageFit: imageFit ?? BoxFit.cover,
                    )),
        ),
        Container(
          height: (height ?? 464),
          width: (width ?? 320),
          decoration: BoxDecoration(
            borderRadius:
                borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
            boxShadow: withInnerShadow
                ? [
                    BoxShadow(
                        color: context.colorScheme.white,
                        offset: Offset(0, 3),
                        blurRadius: 6,
                        inset: true),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}
