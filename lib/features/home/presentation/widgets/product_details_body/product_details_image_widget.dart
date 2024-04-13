
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
class ProductDetailsImageWidget extends StatelessWidget {
  const ProductDetailsImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: UniqueKey(),
          height: 464,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
                width: 0.5,
                color: context.colorScheme.white),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.black.withOpacity(0.1),
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                  'assets/images/details.jpg',
                  fit: BoxFit.cover)),
        ),
        Container(
          height: 464,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                  color: context.colorScheme.white,
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  inset: true),
            ],
          ),
        ),
      ],
    );
  }
}
