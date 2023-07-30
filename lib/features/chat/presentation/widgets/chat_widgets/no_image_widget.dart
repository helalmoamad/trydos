import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

class NoImageWidget extends StatelessWidget {
  const NoImageWidget(
      {required this.name,
      required this.width,
      required this.textStyle,
      this.isTyping = false,
      this.withImageShadow = false,
      this.radius = 12,
      required this.height,
      Key? key})
      : super(key: key);
  final String name;
  final double width;
  final double height;
  final bool isTyping;
  final bool withImageShadow;
  final double radius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          boxShadow: isTyping
              ? [
                  BoxShadow(
                      color: const Color(0xff007CFF).withOpacity(0.16),
                      offset: const Offset(0, 3),
                      blurRadius: 6)
                ]
              : withImageShadow
                  ? [
                      BoxShadow(
                        color: context.colorScheme.black.withOpacity(0.16),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
          border: isTyping
              ? Border.all(color: const Color(0xff007CFF), width: 1)
              : null,
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            colors: [
              Color(0xffacffe9),
              Color(0xff80baff),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
      child: Center(
        child: Text(
          name,
          style: textStyle
        ),
      ),
    );
  }
}
