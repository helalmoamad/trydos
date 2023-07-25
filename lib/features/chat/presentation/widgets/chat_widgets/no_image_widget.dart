
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

class NoImageWidget extends StatelessWidget {
  const NoImageWidget({required this.name ,required this.width , required this.height, Key? key}) : super(key: key);
  final String name;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ,
      height: height,
      decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        gradient: const LinearGradient(
          colors: [
            Color(0xffacffe9),
            Color(0xff80baff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      ),
      child: Center(
        child: Text(name,style: context.textTheme.subtitle1?.br.copyWith(
          color: const Color(0xff6638FF),
          letterSpacing: 0.18,
          height: 1.33
        ),),
      ),
    );
  }
}
