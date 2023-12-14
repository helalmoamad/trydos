import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
class ProductListingImageWidget extends StatelessWidget {
  const ProductListingImageWidget({super.key, this.width, this.height, required this.innerShadowYOffset, this.borderColor, required this.circleShape, required this.imageUrl});

  final double? width;
  final double? height;
  final bool circleShape;
  final double innerShadowYOffset;
  final Color? borderColor;
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration:  BoxDecoration(
        borderRadius:  BorderRadius.all(Radius.circular(circleShape ? 180.0 : 15)),
        border: Border.all(width: (width == 20 || width == 200) ? 0.5 : 1, color: borderColor ??  const Color(0xffffffff)),

      ),
      child: ClipRRect(
          borderRadius:  BorderRadius.all(Radius.circular(circleShape ? 180.0 : 15)),
          child: Stack(
            children: [
              Image.asset(imageUrl , fit: BoxFit.fill, width: width,
                height: height,),
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  boxShadow:  [
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
          )),
    );
  }
}
