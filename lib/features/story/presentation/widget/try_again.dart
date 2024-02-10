import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/my_text_widget.dart';

class TryAgainWidget extends StatelessWidget {
  final Function tryAgain;

  const TryAgainWidget({required this.tryAgain, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        ElevatedButton(onPressed: tryAgain.call(), child: MyTextWidget('Try Again'))
      ],
    ));
  }
}
