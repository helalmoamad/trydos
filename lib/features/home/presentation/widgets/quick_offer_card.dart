import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../core/utils/theme_state.dart';
import '../../../app/my_text_widget.dart';
import 'home_page_card2.dart';
import 'offer_time_widget.dart';

class quickOfferCard extends StatefulWidget {
  const quickOfferCard({super.key});

  @override
  State<quickOfferCard> createState() => _quickOfferCardState();
}

class _quickOfferCardState extends ThemeState<quickOfferCard> {
  final ValueNotifier<int> resizeItems = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 276,
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
              blendMode: BlendMode.overlay,
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(color: Color(0xfffafafa)),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Container(
                decoration:
                    BoxDecoration(color: Color(0xffffffff).withOpacity(0.8)),
              ),
            ),
          ),
        ),
        Positioned.fill(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25.w, top: 15),
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
                  MyTextWidget(
                    'Mango Famous Turkish Brand Best Discounts',
                    style: context.textTheme.titleMedium?.rq.copyWith(
                      color: const Color(0xff505050),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.quickOfferSvg,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextWidget('Quick Offer',
                              style: textTheme.titleLarge?.mq.copyWith(
                                color: const Color(0xff3c3c3c),
                                height: 0.85,
                              )),
                          MyTextWidget(
                              'This Offer Is For Only 4 Hours, Remaining:',
                              style: textTheme.titleSmall?.rq.copyWith(
                                color: const Color(0xff505050),
                                height: 1.3,
                              ))
                        ],
                      ),
                      Spacer(),
                      OfferTimeWidget(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
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
            ),
          ],
        )),
        ValueListenableBuilder<int>(
            valueListenable: resizeItems,
            builder: (context, focused, _) {
              return Positioned(
                  bottom: focused != -1 ? -10.w : 12.w,
                  child: Container(
                    //color: Colors.red,
                    margin: EdgeInsets.only(left: 10, right: 5),
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        resizeItems.value =
                            (details.globalPosition.dx - 40) ~/ 35.w;
                        debugPrint(resizeItems.value.toString());
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
                            height: 10.w,
                          ),
                          Transform.translate(
                            offset: Offset(10, 0),
                            child: SizedBox(
                              width: 340.w,
                              height: focused != -1 ? 100.w : 60.w,
                              child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: List.generate(
                                      9,
                                      (index) => AnimatedPositioned(
                                            left: (index * (40.w - 5.w) +
                                                (focused != -1
                                                    ? index == (focused + 1)
                                                        ? 20.w
                                                        : index == focused
                                                            ? 5.w
                                                            : index > focused
                                                                ? 20.w
                                                                : 0
                                                    : 0)),
                                            curve:
                                                Curves.fastEaseInToSlowEaseOut,
                                            bottom:
                                                focused == index ? 35.w : 10.w,
                                            duration: Duration(
                                                milliseconds: focused == index
                                                    ? 150
                                                    : 10),
                                            child: ProductItemCircle(
                                              index: index,
                                              isFocused: focused == index,
                                              imageUrl: '',
                                              name: '',
                                              countProducts: '',
                                            ),
                                          ))),
                            ),
                          ),
                          SizedBox(
                            height: 10.w,
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
