import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

class HomePageCard2 extends StatelessWidget {
  HomePageCard2({super.key});

  final ValueNotifier<int> resizeItems = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 235,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff000000).withOpacity(0.1),
                offset: Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(AppAssets.halloweenJpg, fit: BoxFit.cover)),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
              ),
            ),
          ),
        ),
        // Positioned.fill(
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(15.0),
        //     child: BackdropFilter(
        //       filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        //       child: Container(
        //         decoration: BoxDecoration(color: Color(0xffffffff).withOpacity(0.75)),
        //       ),
        //     ),
        //   ),
        // ),
        Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                AppAssets.mangoSvg,
                height: 20,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Mango Famous Turkish Brand Best Discounts',
                style: context.textTheme.caption?.rq.copyWith(
                  color: const Color(0xff505050),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          left: 25.w,
          top: 15,
        ),
        Positioned(
          top: 65,
          left: 10,
          right: 10,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Stack(
                children: [
                  Container(
                    height: 135,
                    width: 1.sw,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                          width: 0.5, color: const Color(0xfffafafa)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33000000),
                          offset: Offset(0, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(AppAssets.halloweenJpg,
                            fit: BoxFit.cover)),
                  ),
                  Container(
                    height: 135,
                    width: 1.sw,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withOpacity(0.7),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            inset: true),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ValueListenableBuilder<int>(
            valueListenable: resizeItems,
            builder: (context, focused, _) {
              return Positioned(
                  bottom: focused != -1 ? -13.w : 10.w,
                  child: Container(
                    //color: Colors.red,
                    margin: EdgeInsets.only(left: 5),
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        resizeItems.value =
                            (details.globalPosition.dx - 40) ~/ 35.w;
                        print(resizeItems.value);
                      },
                      onLongPressUp: () {
                        resizeItems.value = -1;
                      },
                      onLongPressMoveUpdate: (details) {
                        resizeItems.value =
                            (details.globalPosition.dx - 40) ~/ 35.w;
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            height: focused != -1 ? 20.w : 10.w,
                          ),
                          SizedBox(
                            width: focused != -1 ? 340.w : 320.w,
                            height: focused != -1 ? 80 : 40,
                            child: Stack(
                                alignment: Alignment.center,
                                children: List.generate(
                                  9,
                                  (index) => AnimatedPositioned(
                                    duration: Duration(milliseconds: 100),
                                      left: index * (40.w - 5) +
                                          (focused != -1
                                              ? index == (focused + 1)
                                                  ? 20.w
                                                  : index == focused
                                                      ? 5
                                                      : index > focused
                                                          ? 20
                                                          : 0
                                              : 0),
                                      child: Transform.translate(
                                        offset: Offset(
                                            0,
                                            focused == index
                                                ? -3.w
                                                : focused != -1
                                                    ? 5.w
                                                    : 0),
                                        child: ProductItemCircle(
                                          index: index,
                                          isFocused: focused == index,
                                        ),
                                      )),
                                )),
                          ),
                          SizedBox(
                            height: focused != -1 ? 15.w : 10.w,
                          )
                        ],
                      ),
                    ),
                  ));
            }),
        Positioned(
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.manInactiveSvg,
                height: 12,
              ),
              13.horizontalSpace,
              SvgPicture.asset(
                AppAssets.womenInactiveSvg,
                height: 12,
              ),
              13.horizontalSpace,
              SvgPicture.asset(
                AppAssets.childrenInactiveSvg,
                height: 12,
              ),
            ],
          ),
          right: 18.w,
          top: 18,
        ),
      ],
    );
  }
}

class ProductItemCircle extends StatelessWidget {
  const ProductItemCircle(
      {required this.index, required this.isFocused, super.key});

  final int index;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: isFocused ? 50.w : 40.w,
              width: isFocused ? 50.w : 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withOpacity(0.16),
                    offset: Offset(0, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(180),
                  child: Image.asset(AppAssets.profileJpg, fit: BoxFit.fill)),
            ),
            Container(
              height: isFocused ? 50.w : 40.w,
              width: isFocused ? 50.w : 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      offset: Offset(0, 4),
                      blurRadius: 6,
                      inset: true),
                ],
              ),
            ),
            index == 8
                ? Container(
                    height: isFocused ? 50.w : 40.w,
                    width: isFocused ? 50.w : 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0x98000000),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x29000000),
                          offset: Offset(0, 3),
                          blurRadius: 3,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          inset: true,
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            index == 8
                ? Text(
                    'More',
                    style: context.textTheme.overline?.rq
                        .copyWith(color: Colors.white),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        if (isFocused) ...{
          Text(
            'T-Shirt',
            style: context.textTheme.caption?.rr.copyWith(
                color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.43),
          ),
          Text(
            '1100',
            style: context.textTheme.caption?.rr.copyWith(
                color: Color(0xff8E8E8E),
                fontSize: 8.sp,
                letterSpacing: 0,
                height: 1.375),
          )
        }
      ],
    );
  }
}
