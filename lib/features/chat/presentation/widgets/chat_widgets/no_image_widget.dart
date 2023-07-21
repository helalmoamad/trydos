
import 'package:flutter/material.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

class NoImageWidget extends StatelessWidget {
  const NoImageWidget({required this.name , Key? key}) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
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
