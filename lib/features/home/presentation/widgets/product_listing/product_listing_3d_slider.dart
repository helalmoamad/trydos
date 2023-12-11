import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';

import 'my_gallery3d_widget.dart';
class ProductListing3DSlider extends StatefulWidget {
  const ProductListing3DSlider({super.key});

  @override
  State<ProductListing3DSlider> createState() => _ProductListing3DSliderState();
}

class _ProductListing3DSliderState extends State<ProductListing3DSlider> {
  final ValueNotifier<int> slidingMode = ValueNotifier(0);
  final ValueNotifier<int> indicator = ValueNotifier(4);
  List<Color> colors = [
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.grey,
    Colors.blue,
    Colors.brown,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.pink,
    // Colors.green,
    // Colors.yellow,
    // Colors.red,
    // Colors.purple,
    // Colors.pink,
    // Colors.black,
    // Colors.grey,
    // Colors.blue,
    // Colors.brown,
    // Colors.white,
  ];
  final Gallery3DController gallery3dController = Gallery3DController(
      itemCount: 14,
      primaryshiftingOffsetDivision: 2.5, // 9 -> 2.8
      autoLoop: false,
      minScale: 0.7,
      scrollTime: 200);
  final Gallery3DController gallery3dControllerForCircles = Gallery3DController(
      itemCount: 14,
      autoLoop: false,
      minScale: 0.4,
      primaryshiftingOffsetDivision: 1.6, // 9 -> 2.5
      scrollTime: 200);
  int prevIndexInFirstSlider = 0;
  int prevIndexInSecondSlider = 0;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error){
      print(error);
    };
    return ValueListenableBuilder<int>(
        valueListenable: slidingMode,
        builder: (context, slideModeIndex, child) {
          return Positioned(
            top: slideModeIndex == 0 ? 2 : 0,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  slideModeIndex != 0
                      ? Directionality(
                    textDirection: TextDirection.ltr,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if(slideModeIndex == 2 )...{
                                  SizedBox(
                                    height: 40 ,
                                    width: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx , index){
                                      return Container(
                                        width: 30,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.5),
                                              offset: Offset(0 , 3),
                                              inset: true,
                                              blurRadius: 6,
                                            )
                                          ],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(width: 0.5, color: Colors.grey.shade400),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Stack(
                                            children: [
                                              Image.asset('assets/image.png' , height: 40 ,
                                                width: 30, fit: BoxFit.cover,),
                                              Container(
                                                height: 40 ,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withOpacity(0.5),
                                                      offset: Offset(0 , 3),
                                                      inset: true,
                                                      blurRadius: 6,
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: 9,
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      separatorBuilder: (ctx,index){
                                      if(index == 8)return SizedBox.shrink();
                                      return SizedBox(width: 2,);
                                      },
                                    ),
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                              } else const SizedBox.shrink(),
                              MyGallery3DWidget(
                                gallery3dController: gallery3dController,
                                itemWidth: 170,
                                galleryHeight: 246,
                                onItemChanged: (int index){

                                  // if((prevIndexInFirstSlider < index && index != 2) || (prevIndexInFirstSlider == 2 && index ==0)) {
                                  //   prevIndexInSecondSlider = gallery3dControllerForCircles.animateToNext();
                                  // }else{
                                  //   prevIndexInSecondSlider = gallery3dControllerForCircles.animateToPrev();
                                  // }
                                  if((prevIndexInFirstSlider < index && (index - prevIndexInFirstSlider) != 8) || (prevIndexInFirstSlider == 8 && index ==0)) {
                                    gallery3dControllerForCircles.animateTo(index , false);
                                  }else{
                                    gallery3dControllerForCircles.animateTo(index , true);
                                  }
                                  setState(() {
                                    prevIndexInSecondSlider = index;
                                    prevIndexInFirstSlider = index;
                                  });
                                },
                                galleryWidth: 200,
                                radius: 15,
                                itemCount: 9,
                              ),
                              if( slideModeIndex == 1)...{
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  'Color',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 12,
                                    color: colors[prevIndexInSecondSlider],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Gallery3D(
                                    controller: gallery3dControllerForCircles,
                                    width: 200,
                                    changingPagesScrollOffset: 0.1,
                                    isClip: false,
                                    // ellipseHeight: 80,
                                    // currentIndex: currentIndex,
                                    onItemChanged: (index) {
                                      if ((prevIndexInSecondSlider < index &&
                                          (index - prevIndexInFirstSlider) !=
                                              8) ||
                                          (prevIndexInSecondSlider == 8 &&
                                              index == 0)) {
                                        gallery3dController.animateTo(
                                            index, false);
                                      } else {
                                        gallery3dController.animateTo(
                                            index, true);
                                      }
                                      setState(() {
                                        prevIndexInSecondSlider = index;
                                      });
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
                                    itemConfig: const GalleryItemConfig(
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
                                        ]
                                    ),
                                    onClickItem: (index) {
                                      //if (kDebugMode) print("currentIndex:$index");
                                    },
                                    itemBuilder: (context, index) {
                                      // return Container(
                                      //   color: colors[index],
                                      // );
                                      return ProductListingImageWidget(
                                        width: 35,
                                        height: 35,
                                        innerShadowYOffset: 4,
                                        borderColor: index ==
                                            prevIndexInSecondSlider
                                            ? colors[prevIndexInSecondSlider]
                                            : Colors.white,
                                        circleShape: true,);
                                    })
                              }
                            ],
                          ),
                      )
                      : Directionality(
                    textDirection: TextDirection.ltr,
                        child: Stack(
                          alignment: Alignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  slidingMode.value = 1;
                                },
                                child:  SizedBox(
                                  height: 290,
                                  width: 200,
                                  child: CarouselSlider.builder(
                                      itemCount: 9,
                                      options: CarouselOptions(
                                        initialPage: 4,
                                        height: 290,
                                        onPageChanged: (page , reason ){
                                          indicator.value  = page ;
                                        },
                                        enableInfiniteScroll: false,
                                        viewportFraction: 1,
                                      ),
                                      itemBuilder: (context , index , _){
                                    return const ProductListingImageWidget(
                                      width: 200,
                                      height: 290,
                                      circleShape: false,
                                      innerShadowYOffset: 3,
                                    );
                                  }),
                                )
                              ),
                              Positioned(
                                bottom: 0,
                                child: slideModeIndex == 0
                                    ? Transform.translate(
                                      offset: const Offset(0, 6),
                                      child: Gallery3D(
                                        changingPagesScrollOffset: 0.1,
                                        controller: Gallery3DController(
                                            itemCount: 14,
                                            autoLoop: false,
                                            minScale: 0.4,
                                            primaryshiftingOffsetDivision: 1,
                                            scrollTime: 200),
                                        width: 70,
                                        height: 20,
                                        isClip: false,
                                        // ellipseHeight: 80,
                                        // currentIndex: currentIndex,
                                        onItemChanged: (index) {



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
                                        itemConfig: const GalleryItemConfig(
                                          width: 20,
                                          height: 25,
                                          radius: 180,
                                          isShowTransformMask: false,
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0x19000000),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ]
                                        ),
                                        onClickItem: (index) {
                                          //if (kDebugMode) print("currentIndex:$index");
                                        },
                                        itemBuilder: (context, index) {
                                          // return Container(
                                          //   color: colors[index],
                                          // );
                                          return  ProductListingImageWidget(height: 20,width: 20,innerShadowYOffset: 4,borderColor: index == prevIndexInSecondSlider ? colors[prevIndexInSecondSlider] : Colors.white, circleShape: true,);
                                        },
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                              ),
                              Positioned(
                                top: 5,
                                child: InkWell(
                                  onTap: (){
                                    slidingMode.value =  2;
                                  },
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: indicator,
                                    builder: (context , pageIndex , _) {
                                      return Row(children: List.generate(9, (index) {
                                        return Container(
                                          margin: EdgeInsets.only(right: index != (9-1) ? 2 : 0),
                                          width: index <= (9~/2) ? (index * 2 + 2) : ((index - ((index - 4) * 2)) * 2 + 2).abs().toDouble(),
                                          height: index <= (9~/2) ? (index * 2 + 2) : ((index - ((index - 4) * 2)) * 2 + 2).abs().toDouble(),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(180),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x33000000),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            gradient: index == pageIndex ? LinearGradient(
                                                colors: [
                                                  Color(0xfff53c3c),
                                                  Color(0xffff9696),
                                                ],
                                                stops: [0 , 1]
                                            ) : null,
                                            border: Border.all(width: 0.3, color: const Color(0xff3c3c3c)),
                                          ),
                                        );
                                      }),);
                                    }
                                  ),
                                ),
                              )
                            ],
                          ),
                      ),
                  InkWell(
                    onTap: (){
                      slidingMode.value = 0;
                    },
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
                              'assets/mango.svg',
                              height: 7,
                              width: 44,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  '1',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 10,
                                    color: Color(0xff5d5d5d),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/bag.svg',
                                  height: 10,
                                  width: 10,
                                ),
                                const Flexible(
                                  child: Text(
                                    'Amazing blue night dress Long can gift to anyone',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 10,
                                      color: Color(0xff3c3c3c),
                                    ),
                                  ),
                                ),
                              ],
                            ),])
                          ),
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
                                const Row(
                                  children: [
                                    Text(
                                      '100',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 12,
                                        color: Color(0xff3c3c3c),
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      softWrap: false,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      '90',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 12,
                                        color: Color(0xff3c3c3c),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      softWrap: false,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      'USD',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 10,
                                        color: Color(0xff5d5d5d),
                                        fontWeight: FontWeight.w300,
                                      ),
                                      softWrap: false,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Buy',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 10,
                                        color: Color(0xff414141),
                                        fontWeight: FontWeight.w300,
                                        height: 1.4,
                                      ),
                                      textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false),
                                      softWrap: false,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SvgPicture.asset(
                                      'assets/bag.svg',
                                      height: 10,
                                      width: 10,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],)
              ),
            );
        });
  }
}
