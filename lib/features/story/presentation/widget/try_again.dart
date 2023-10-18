import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TryAgainWidget extends StatelessWidget {
  Function tryAgain;

  TryAgainWidget({required this.tryAgain, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        ElevatedButton(onPressed: tryAgain.call(), child: Text('Try Again'))
      ],
    ));
  }
}
