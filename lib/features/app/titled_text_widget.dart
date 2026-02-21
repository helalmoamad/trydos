import 'package:flutter/material.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
class TitledTextWidget extends StatelessWidget {
  const TitledTextWidget({Key? key , required this.title , required this.body , this.maxLines}) : super(key: key);

  final String title;
  final String body;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: title, style: context.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w700, color: context.colorScheme.tertiary)),
          TextSpan(
              text: '$body\n',
              style: context.textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w400,
              )),
        ],
      ),
    );
  }
}

