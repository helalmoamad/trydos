import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:tuple/tuple.dart';

import '../../../../../core/utils/theme_state.dart';
import 'my_gallery3d_widget.dart';

class ProductListing3DSlider extends StatefulWidget {
  const ProductListing3DSlider(
      {super.key,
      required this.setThisEnabled,
      required this.slidingModeItem,
      required this.itemIndex});

  final Tuple2<int, int> slidingModeItem;
  final void Function(int, int) setThisEnabled;
  final int itemIndex;

  @override
  State<ProductListing3DSlider> createState() => _ProductListing3DSliderState();
}

class _ProductListing3DSliderState extends ThemeState<ProductListing3DSlider> {
  final ValueNotifier<Map<int, int>> indicator = ValueNotifier({
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
  });
  final ValueNotifier<Tuple2<List<String>, List<String>>> firstSliderItems =
      ValueNotifier(Tuple2([
    'assets/images/product_listing_images/bl1.jpg',
    'assets/images/product_listing_images/p1.jpg',
    'assets/images/product_listing_images/g1.jpg',
  ], [
    'assets/images/product_listing_images/y2.jpg',
    'assets/images/product_listing_images/b1.jpg',
    'assets/images/product_listing_images/o1.jpg',
    'assets/images/product_listing_images/r1.jpg',
    'assets/images/product_listing_images/g1.jpg',
    'assets/images/product_listing_images/bl1.jpg',
    'assets/images/product_listing_images/p1.jpg',
    'assets/images/product_listing_images/y2.jpg',
    'assets/images/product_listing_images/b1.jpg',
    'assets/images/product_listing_images/o1.jpg',
    'assets/images/product_listing_images/r1.jpg',
  ]));
  List<String> images = [
    'assets/images/product_listing_images/bl1.jpg',
    'assets/images/product_listing_images/p1.jpg',
    'assets/images/product_listing_images/y2.jpg',
    'assets/images/product_listing_images/b1.jpg',
    'assets/images/product_listing_images/o1.jpg',
    'assets/images/product_listing_images/r1.jpg',
    'assets/images/product_listing_images/g1.jpg',
    'assets/images/product_listing_images/bl1.jpg',
    'assets/images/product_listing_images/p1.jpg',
    'assets/images/product_listing_images/y2.jpg',
    'assets/images/product_listing_images/b1.jpg',
    'assets/images/product_listing_images/o1.jpg',
    'assets/images/product_listing_images/r1.jpg',
    'assets/images/product_listing_images/g1.jpg',
  ];

  List<Color> colors = [
    Colors.blue,
    Colors.pink,
    Colors.yellow,
    Colors.black,
    Colors.deepOrangeAccent,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.yellow,
    Colors.black,
    Colors.deepOrangeAccent,
    Colors.red,
    Colors.green,
  ];
  int prevIndexForThreeImages = 0;

  final Gallery3DController gallery3dController = Gallery3DController(
      itemCount: 3,
      primaryshiftingOffsetDivision: 2.6,
      // 9 -> 2.8
      autoLoop: false,
      minScale: 0.7,
      scrollTime: 50);

  final Gallery3DController gallery3dControllerForCircles = Gallery3DController(
      itemCount: 14,
      autoLoop: false,
      minScale: 0.4,
      primaryshiftingOffsetDivision: 1.6,
      // 9 -> 2.5
      scrollTime: 50);
  final Gallery3DController gallery3dControllerForTinyCircles =
      Gallery3DController(
          itemCount: 14,
          autoLoop: false,
          minScale: 0.4,
          primaryshiftingOffsetDivision: 1,
          // 9 -> 2.5
          scrollTime: 50);
  final ValueNotifier<int> currentColorIndex = ValueNotifier(0);
  int prevIndexInFirstSlider = 0;
  int prevIndexInSecondSlider = 0;
  int slideModeIndex = 0;
  final CarouselController carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    slideModeIndex = widget.itemIndex == widget.slidingModeItem.item1
        ? widget.slidingModeItem.item2
        : 0;
    FlutterError.onError = (error) {
      print(error);
    };
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    slideModeIndex != 0
                        ? Directionality(
                            textDirection: TextDirection.ltr,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (slideModeIndex == 2) ...{
                                  SizedBox(
                                    height: 45,
                                    width: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (ctx, index) {
                                        return InkWell(
                                          onTap: () {
                                            gallery3dController.animateTo(
                                                index, false);
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  offset: Offset(0, 3),
                                                  inset: true,
                                                  blurRadius: 6,
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 0.5,
                                                  color: Colors.grey.shade400),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Stack(
                                                children: [
                                                  Image.asset(
                                                    images[
                                                        prevIndexInFirstSlider],
                                                    height: 40,
                                                    width: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                          offset: Offset(0, 3),
                                                          inset: true,
                                                          blurRadius: 6,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: 9,
                                      padding: EdgeInsets.only(left: 5, top: 5),
                                      separatorBuilder: (ctx, index) {
                                        if (index == 8)
                                          return SizedBox.shrink();
                                        return SizedBox(
                                          width: 2,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                } else
                                  const SizedBox.shrink(),
                                ValueListenableBuilder<
                                        Tuple2<List<String>, List<String>>>(
                                    valueListenable: firstSliderItems,
                                    builder: (context, sliderData, child) {
                                      return Transform.translate(
                                        offset: Offset(-5, 0),
                                        child: MyGallery3DWidget(
                                        //  key: ValueKey('gallery3dController${widget.itemIndex}'),
                                          gallery3dController:
                                              gallery3dController,
                                          itemWidth: 170,
                                          threeImages: sliderData.item1,
                                          onItemClick: (index) {
                                            widget.setThisEnabled.call(-1, -1);
                                          },
                                          images: sliderData.item2,
                                          showProductSides: slideModeIndex == 2,
                                          currentProduct:
                                              prevIndexInFirstSlider,
                                          galleryHeight: 246,
                                          onItemChanged: (int index) {
                                            bool scrollToLeft = false;
                                            if ((prevIndexForThreeImages == 0 &&
                                                    index == 2) ||
                                                (prevIndexForThreeImages == 2 &&
                                                    index == 1) ||
                                                (prevIndexForThreeImages == 1 &&
                                                    index == 0)) {
                                              scrollToLeft = true;
                                                updateImagesInFirstSlider(true,
                                                    calledFromOnChanged: true);
                                            } else {
                                                updateImagesInFirstSlider(false,
                                                    calledFromOnChanged: true);
                                            }
                                            prevIndexForThreeImages = index;
                                            if (slideModeIndex != 2 &&
                                                !scrollToLeft) {
                                              prevIndexInSecondSlider =
                                                  prevIndexInFirstSlider =
                                                      (gallery3dControllerForCircles
                                                                      .currentIndex +
                                                                  1) ==
                                                              images.length
                                                          ? 0
                                                          : (gallery3dControllerForCircles
                                                                  .currentIndex +
                                                              1);
                                              gallery3dControllerForCircles
                                                  .animateTo(
                                                      prevIndexInFirstSlider,
                                                      false);
                                            } else if (slideModeIndex != 2) {
                                              prevIndexInSecondSlider =
                                                  prevIndexInFirstSlider =
                                                      (gallery3dControllerForCircles
                                                                      .currentIndex -
                                                                  1) <
                                                              0
                                                          ? images.length - 1
                                                          : (gallery3dControllerForCircles
                                                                  .currentIndex -
                                                              1);
                                              gallery3dControllerForCircles
                                                  .animateTo(
                                                      prevIndexInFirstSlider,
                                                      true);
                                            }
                                            currentColorIndex.value =
                                                prevIndexInFirstSlider;
                                          },
                                          galleryWidth: 200,
                                          radius: 15,
                                          itemCount: 3,
                                        ),
                                      );
                                    }),
                                if (slideModeIndex == 1) ...{
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  ValueListenableBuilder<int>(
                                    valueListenable: currentColorIndex,
                                    builder: (context, currentIndex, _) {
                                      return Text(
                                        'Color',
                                        textAlign: TextAlign.center,
                                        style: textTheme.caption?.mq.copyWith(
                                          color: colors[currentIndex],
                                        ),
                                      );
                                    },
                                  ),
                                  Gallery3D(
                                   // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                      controller: gallery3dControllerForCircles,
                                      width: 200.w,
                                      height: null,
                                      changingPagesScrollOffset: 0.1,
                                      isClip: false,
                                      onItemChanged: (index) {
                                        if (slideModeIndex != 2 &&
                                            ((prevIndexInSecondSlider < index &&
                                                    (index -
                                                            prevIndexInSecondSlider) !=
                                                        8) ||
                                                (prevIndexInSecondSlider == 8 &&
                                                    index == 0))) {
                                          updateImagesInFirstSlider(false);
                                          gallery3dController.animateTo(
                                              index, false);
                                        } else if (slideModeIndex != 2) {
                                          updateImagesInFirstSlider(true);
                                          gallery3dController.animateTo(
                                              index, true);
                                        }
                                        if (slideModeIndex != 2) {
                                          prevIndexInFirstSlider = index;
                                          prevIndexInSecondSlider = index;
                                          currentColorIndex.value =
                                              prevIndexInFirstSlider;
                                        }
                                        // if((prevIndexInSecondSlider < index && index != 17) || (prevIndexInSecondSlider == 17 && index ==0)) {
                                        //  prevIndexInFirstSlider =  gallery3dController.animateToNext();
                                        // }else{
                                        //   print('index: $index');
                                        //   print('prevIndexInFirstSlider: $prevIndexInSecondSlider');
                                        //   prevIndexInFirstSlider =  gallery3dController.animateToPrev();
                                        // }
                                        // setState(() {
                                        //   prevIndexInSecondSlider = index;
                                        // });

                                        // scroll to right
                                        // setState(() {
                                        //   if ((prevIndex == 0 && index == 2) ||
                                        //       (prevIndex == 2 && index == 1) ||
                                        //       (prevIndex == 1 && index == 0)) {
                                        //     Color middleColorFromThree =
                                        //         threeColors[index - 1 < 0 ? 2 : (index - 1)];
                                        //     threeColors[index - 1 < 0 ? 2 : (index - 1)] =
                                        //         leftColors.first;
                                        //     leftColors.removeAt(0);
                                        //     leftColors.add(middleColorFromThree);
                                        //   } else {
                                        //     Color middleColorFromThree =
                                        //         threeColors[index + 1 > 2 ? 0 : (index + 1)];
                                        //     threeColors[index + 1 > 2 ? 0 : (index + 1)] =
                                        //         leftColors.last;
                                        //     leftColors.removeLast();
                                        //     leftColors.insert(0, middleColorFromThree);
                                        //   }
                                        //   prevIndex = index;
                                        // });
                                      },
                                      itemConfig: GalleryItemConfig(
                                          width: 35,
                                          height: 35,
                                          radius: 180,
                                          isShowTransformMask: false,
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0x19000000),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ]),
                                      onClickItem: (index) {},
                                      itemBuilder: (context, index) {
                                        return ProductListingImageWidget(
                                          width: 35,
                                          height: 35,
                                          imageUrl: images[index],
                                          innerShadowYOffset: 4,
                                          borderColor: index ==
                                                  prevIndexInFirstSlider
                                              ? colors[prevIndexInFirstSlider]
                                              : Colors.white,
                                          circleShape: true,
                                        );
                                      }),
                                }
                              ],
                            ),
                          )
                        : Directionality(
                            textDirection: TextDirection.ltr,
                            child: SizedBox(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 290,
                                    width: 200,
                                    child: CarouselSlider.builder(
                                        itemCount: 9,
                                        carouselController: carouselController,
                                        options: CarouselOptions(
                                          initialPage: prevIndexInFirstSlider,
                                          height: 290,
                                          onPageChanged: (page, reason) {
                                            indicator.value[
                                                prevIndexInFirstSlider] = page;
                                            indicator.notifyListeners();
                                          },
                                          enableInfiniteScroll: false,
                                          viewportFraction: 1,
                                        ),
                                        itemBuilder: (context, index, _) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                slideModeIndex = 0;
                                              });
                                            },
                                            child: ProductListingImageWidget(
                                              width: 200,
                                              imageUrl: images[
                                                  prevIndexInFirstSlider],
                                              height: 290,
                                              circleShape: false,
                                              innerShadowYOffset: 3,
                                            ),
                                          );
                                        }),
                                  ),
                                  Positioned(
                                    top: 5,
                                    child: InkWell(
                                      onTap: () {
                                        widget.setThisEnabled
                                            .call(widget.itemIndex, 2);
                                        // setState(() {
                                        //   slideModeIndex = 2;
                                        // });
                                      },
                                      child:
                                          ValueListenableBuilder<Map<int, int>>(
                                              valueListenable: indicator,
                                              builder: (context, page, _) {
                                                return Row(
                                                  children:
                                                      List.generate(9, (index) {
                                                    return Container(
                                                      margin: EdgeInsets.only(
                                                          right:
                                                              index != (9 - 1)
                                                                  ? 2
                                                                  : 0),
                                                      width: index <= (9 ~/ 2)
                                                          ? (index * 2 + 2)
                                                          : ((index - ((index - 4) * 2)) *
                                                                      2 +
                                                                  2)
                                                              .abs()
                                                              .toDouble(),
                                                      height: index <= (9 ~/ 2)
                                                          ? (index * 2 + 2)
                                                          : ((index - ((index - 4) * 2)) *
                                                                      2 +
                                                                  2)
                                                              .abs()
                                                              .toDouble(),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(180),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(
                                                                0x33000000),
                                                            offset:
                                                                Offset(0, 3),
                                                            blurRadius: 6,
                                                          ),
                                                        ],
                                                        gradient: index ==
                                                                page[
                                                                    prevIndexInFirstSlider]
                                                            ? LinearGradient(
                                                                colors: [
                                                                    Color(
                                                                        0xfff53c3c),
                                                                    Color(
                                                                        0xffff9696),
                                                                  ],
                                                                stops: [
                                                                    0,
                                                                    1
                                                                  ])
                                                            : null,
                                                        border: Border.all(
                                                            width: 0.3,
                                                            color: const Color(
                                                                0xff3c3c3c)),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              }),
                                    ),
                                  ),
                                  slideModeIndex == 0
                                      ? Positioned(
                                          bottom: 0,
                                          child: Transform.translate(
                                            offset: Offset(0, 6),
                                            child: Gallery3D(
                                                // key: ValueKey('gallery3dControllerForTinyCircles${widget.itemIndex}'),
                                                controller:
                                                    gallery3dControllerForTinyCircles,
                                                width: 70.w,
                                                height: 20,
                                                changingPagesScrollOffset: 0.1,
                                                isClip: false,
                                                itemConfig: GalleryItemConfig(
                                                    width: 20,
                                                    height: 25,
                                                    radius: 180,
                                                    isShowTransformMask: false,
                                                    shadows: [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x19000000),
                                                        offset: Offset(0, 3),
                                                        blurRadius: 6,
                                                      ),
                                                    ]),
                                                onClickItem: (index) {},
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      if (slideModeIndex == 0) {
                                                        widget.setThisEnabled.call(widget.itemIndex, 1);
                                                        return;
                                                      }
                                                      // gallery3dControllerForCircles
                                                      //     .animateTo(
                                                      //         index, false);
                                                      // gallery3dController
                                                      //     .animateTo(
                                                      //         index, false);
                                                      // setState(() {
                                                      //   prevIndexInSecondSlider =
                                                      //       index;
                                                      //   prevIndexInFirstSlider =
                                                      //       index;
                                                      // });
                                                    },
                                                    child:
                                                        ProductListingImageWidget(
                                                      width: 20,
                                                      height: 20,
                                                      imageUrl: images[index],
                                                      innerShadowYOffset: 4,
                                                      borderColor: index ==
                                                              prevIndexInFirstSlider
                                                          ? colors[
                                                              prevIndexInFirstSlider]
                                                          : Colors.white,
                                                      circleShape: true,
                                                    ),
                                                  );
                                                }),
                                          ))
                                      : const SizedBox.shrink()
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 200,
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AppAssets.mangoSvg,
                                height: 10,
                                color: Color(0xff1A171B),
                                width: 169.w,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('1',
                                      style: textTheme.overline?.mq.copyWith(
                                        color: Color(0xff5d5d5d),
                                      )),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, 1),
                                    child: SvgPicture.asset(
                                      AppAssets.dressSvg,
                                      height: 10,
                                      width: 10,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Flexible(
                                    child: Text(
                                        'Amazing blue night dress Long can gift to anyone',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.overline?.rq.copyWith(
                                          color: Color(0xff3c3c3c),
                                        )),
                                  ),
                                ],
                              ),
                            ])),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '100',
                                style: textTheme.caption?.lq.copyWith(
                                  color: Color(0xff3c3c3c),
                                  decoration: TextDecoration.lineThrough,
                                  height: 0,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                '90',
                                style: textTheme.caption?.bq.copyWith(
                                  color: Color(0xff3c3c3c),
                                  height: 0,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                'USD',
                                style: textTheme.overline?.lq.copyWith(
                                  color: Color(0xff5D5D5D),
                                  height: 0,
                                ),
                                softWrap: false,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Buy',
                                style: textTheme.overline?.lq.copyWith(
                                  color: Color(0xff414141),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              SvgPicture.asset(
                                AppAssets.bagSvg,
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void updateImagesInFirstSlider(bool isScrollLeft,
      {bool calledFromOnChanged = false}) {
    int index = 0;
    List<String> threeImages = firstSliderItems.value.item1;
    List<String> images = firstSliderItems.value.item2;
    if (isScrollLeft) {
      index = calledFromOnChanged
          ? gallery3dController.currentIndex
          : (gallery3dController.currentIndex - 1) < 0
              ? 2
              : (gallery3dController.currentIndex - 1);
      String middleImageFromThree =
          threeImages[index - 1 < 0 ? 2 : (index - 1)];
      threeImages[index - 1 < 0 ? 2 : (index - 1)] = images.last;
      images.removeLast();
      images.insert(0, middleImageFromThree);
    } else {
      index = calledFromOnChanged
          ? gallery3dController.currentIndex
          : (gallery3dController.currentIndex + 1) > 2
              ? 0
              : (gallery3dController.currentIndex + 1);
      String middleImageFromThree =
          threeImages[index + 1 > 2 ? 0 : (index + 1)];
      threeImages[index + 1 > 2 ? 0 : (index + 1)] = images.first;
      images.removeAt(0);
      images.add(middleImageFromThree);
    }
    firstSliderItems.value = Tuple2(threeImages, images);
  }
}
