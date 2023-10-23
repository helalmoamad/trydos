import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class test extends StatelessWidget {
  const test({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(


      body: Stack
        (
        alignment: Alignment.bottomCenter,

        children: [
          Container(
            color: Colors.amberAccent,
            width: 20.w,
            height: 100.h,
          ),
        ],
      ),
    );
  }
}
