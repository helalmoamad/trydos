import 'dart:ui' as ui;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/rendering.dart' as rendering;
import 'package:flutter/services.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';

class HomePageCard2 extends cupertino.StatefulWidget {
  HomePageCard2({super.key, this.withSlidingImages = false});

  final bool withSlidingImages;

  @override
  cupertino.State<HomePageCard2> createState() => _HomePageCard2State();
}

class _HomePageCard2State extends cupertino.State<HomePageCard2> {
  final ValueNotifier<int> resizeItems = ValueNotifier(-1);

  late AutoScrollController autoScrollController;
  late ScrollController scrollController;

  @override
  void initState() {
    autoScrollController = AutoScrollController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductListingPage(),));
          },
          child: Stack(
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
                    filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0,),
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
                        Text(
                          'Mango Famous Turkish Brand Best Discounts',
                          style: context.textTheme.caption?.rq.copyWith(
                            color: const Color(0xff505050),
                          ),
                        ),
                        if (!widget.withSlidingImages)
                          SizedBox(
                            height: 10,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: widget.withSlidingImages ? 0 : 10,
                        right: widget.withSlidingImages ? 0 : 10),
                    child: widget.withSlidingImages
                        ? cupertino.Container(
                            //color: Colors.red,
                            child: CarouselSlider.builder(
                                itemCount: 5,
                                itemBuilder: (context, index, _) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, top: 10, bottom: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 155,
                                          width: 1.sw,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.0),
                                            border: Border.all(
                                                width: 0.5,
                                                color: const Color(0xfffafafa)),
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
                                              child: Image.asset(
                                                  AppAssets.halloweenJpg,
                                                  fit: BoxFit.cover)),
                                        ),
                                        Container(
                                          height: 155,
                                          width: 1.sw,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.0),
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      Colors.white.withOpacity(0.7),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 6,
                                                  inset: true),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  initialPage: 0,
                                  height: 155,
                                  enableInfiniteScroll: false,
                                  viewportFraction: 0.95,
                                )
                            ))
                        : Stack(
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
                  )
                ],
              )),
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
          ),
        ),
        ValueListenableBuilder<int>(
            valueListenable: resizeItems,
            builder: (context, focused, _) {
              return GestureDetector(
                onPanDown: (details) {
                  HapticFeedback.vibrate();
                  resizeItems.value = (details.globalPosition.dx - 40) ~/ 35.w;
                },
                onPanEnd: (details) {
                  resizeItems.value = -1;
                },
                onPanUpdate: (details) {
                  int prev = resizeItems.value;
                  resizeItems.value =
                      (details.globalPosition.dx - 40) ~/ 35.w;
                  if(prev != resizeItems.value){
                    HapticFeedback.vibrate();
                  }
                },
                child: Column(
                  children: [
                    SizedBox(
                      height:  10.w,
                    ),
                    Transform.translate(
                      offset: Offset(10 , 0),
                      child: SizedBox(
                        width: 340.w,
                        height: focused != -1 ? 100.w : 60.w,
                        child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: List.generate(
                                9,
                                    (index) => AnimatedPositioned(
                                  left: ( index * (40.w - 5.w) +
                                      (focused != -1
                                          ? index == (focused + 1)
                                          ? 20.w
                                          : index == focused
                                          ? 5.w
                                          : index > focused
                                          ? 20.w
                                          : 0
                                          : 0)),
                                  curve: Curves.fastEaseInToSlowEaseOut,
                                  bottom: focused == index ? 35.w : 10.w,
                                  duration: Duration(milliseconds: focused == index ? 150 : 10),
                                  child: ProductItemCircle(
                                    index: index,
                                    isFocused: focused == index,
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height:  10.w,
                    )
                  ],
                ),
              );
            }),
      ],
    );
  }
}

class ProductItemCircle extends StatelessWidget {
  const ProductItemCircle(
      {required this.index,
      required this.isFocused,
      super.key});

  final int index;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFocused ? 50.w : 40.w,
      height: isFocused ? 80.w : 40.w,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 150),
            opacity: isFocused ? 1 : 0,
            curve: Curves.easeInOut,
            child: Transform.translate(
              offset: Offset(0 , isFocused ? 35.w : 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
              ]),
            ),
          ),
          AnimatedScale(
            duration: Duration(milliseconds: 200),
            scale: isFocused ? 1.25 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 40.w,
                  width:  40.w,
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
                  height:  40.w,
                  width:   40.w,
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
                  height:  40.w,
                  width:   40.w,
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
          )
        ],
      ),
    );
  }
}
