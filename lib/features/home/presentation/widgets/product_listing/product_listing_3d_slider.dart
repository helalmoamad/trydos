import 'dart:math';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as listing;
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:tuple/tuple.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../../../../core/utils/theme_state.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';
import 'my_gallery3d_widget.dart';

class ProductListing3DSlider extends StatefulWidget {
  const ProductListing3DSlider(
      {super.key,
      required this.setThisEnabled,
      required this.slidingModeItem,
      required this.itemIndex,
      required this.productItem,
      required this.currentChosenColor});

  final Tuple2<int, int> slidingModeItem;
  final void Function(int, int) setThisEnabled;
  final int itemIndex;
  final productListingModel.Products productItem;
  final ValueNotifier<int> currentChosenColor;

  @override
  State<ProductListing3DSlider> createState() => _ProductListing3DSliderState();
}

class _ProductListing3DSliderState extends ThemeState<ProductListing3DSlider> {
  late ValueNotifier<Map<int, int>> indicatorForProductImages;

  late final ValueNotifier<Tuple2<List<String>, List<String>>>
      threeColorsSlider, threeImagesSlider;

  //     ValueNotifier(Tuple2([
  //   'assets/images/product_listing_images/b1.jpg',
  //   'assets/images/product_listing_images/o1.jpg',
  //   //we take the element in the middle  and (middle -1) and (middle +1) and
  //   //all elements before (middle -1) we put them after (middle +1)
  //   'assets/images/product_listing_images/y2.jpg',
  // ], [
  //   'assets/images/product_listing_images/r1.jpg',
  //   'assets/images/product_listing_images/g1.jpg',
  //   'assets/images/product_listing_images/bl1.jpg',
  //   'assets/images/product_listing_images/p1.jpg',
  // ]));
  List<String> images = [];
  List<double> orginalWidth = [];
  List<double> orginalHeigh = [];
  // = [
  //   'assets/images/product_listing_images/bl1.jpg',
  //   'assets/images/product_listing_images/p1.jpg',
  //   'assets/images/product_listing_images/y2.jpg',
  //   'assets/images/product_listing_images/b1.jpg',
  //   'assets/images/product_listing_images/o1.jpg',
  //   'assets/images/product_listing_images/r1.jpg',
  //   'assets/images/product_listing_images/g1.jpg',
  //   'assets/images/product_listing_images/bl1.jpg',
  //   'assets/images/product_listing_images/p1.jpg',
  //   'assets/images/product_listing_images/y2.jpg',
  //   'assets/images/product_listing_images/b1.jpg',
  //   'assets/images/product_listing_images/o1.jpg',
  //   'assets/images/product_listing_images/r1.jpg',
  //   'assets/images/product_listing_images/g1.jpg',
  // ];
  int prevIndexForThreeImages = 0, prevIndexForThreeColors = 0;
  late final Gallery3DController gallery3dControllerForColors;

  late final Gallery3DController gallery3dControllerForProductImages;

  late final Gallery3DController
      gallery3dControllerForProductImagesTrackingIndex;

  Gallery3DController? gallery3dControllerForCircles;

  late final ValueNotifier<int> currentColorIndex;

  late int prevIndexInFirstSlider;
  late HomeBloc homeBloc;
  late int prevIndexInSecondSlider;
  int slideModeIndex = 0;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  List<productListingModel.SyncColorImage>? syncColorImageList;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    syncColorImageList = widget.productItem.syncColorImages;
    syncColorImageList?.removeWhere((element) => element.images.isNullOrEmpty);
    syncColorImageList = [
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
      ...((syncColorImageList?.length ?? 0) == 1
          ? (syncColorImageList ?? [])
          : [])
    ];

    Map<int, int> indicatorValues = {0: 0};
    for (int i = 1; i < syncColorImageList!.length; i++) {
      indicatorValues[i] = 0;
    }
    indicatorForProductImages = ValueNotifier(indicatorValues);
    images =
        syncColorImageList?.map((e) => e.images![0].filePath!).toList() ?? [];
    orginalHeigh = syncColorImageList
            ?.map((e) => double.parse(e.images![0].originalHeight!))
            .toList() ??
        [];
    orginalWidth = syncColorImageList
            ?.map((e) => double.parse(e.images![0].originalWidth!))
            .toList() ??
        [];
    if (!images.isNullOrEmpty && images.length > 3) {
      List<String> copyOfImages = List.of(images), threeImages;
      threeImages = images
          .getRange(images.length ~/ 4 - 1, images.length ~/ 4 + 2)
          .toList();
      threeImages.add(threeImages.removeAt(0));

      copyOfImages.removeRange(images.length ~/ 4 - 1, images.length ~/ 4 + 2);
      copyOfImages.addAll(copyOfImages.getRange(0, images.length ~/ 4 - 1));
      copyOfImages.removeRange(0, images.length ~/ 4 - 1);
      threeColorsSlider = ValueNotifier(Tuple2(threeImages, copyOfImages));
    } else {
      threeColorsSlider = ValueNotifier(Tuple2(images, []));
    }
    List<listing.Thumbnail> lists = widget.productItem.images ?? [];
    List<String> list = [];
    lists.forEach((element) {
      list.add(element.filePath!);
    });
    list = [...list, ...list];
    if (list.length == 2) {
      list.add(list[0]);
    }
    List<String> threeImages = [];
    threeImages.add(list.removeAt(0));
    threeImages.add(list.removeAt(0));
    threeImages.add(list.removeAt(list.length - 1));
    threeImagesSlider = ValueNotifier(Tuple2(threeImages, list));
    prevIndexInFirstSlider =
        prevIndexInSecondSlider = syncColorImageList!.length ~/ 4;
    currentColorIndex = ValueNotifier(prevIndexInFirstSlider);
    gallery3dControllerForColors = Gallery3DController(
        itemCount: 3,
        primaryshiftingOffsetDivision: 2.6,
        autoLoop: false,
        minScale: 0.7,
        initialIndex: 0,
        scrollTime: 50);
    gallery3dControllerForProductImages = Gallery3DController(
        itemCount: 3,
        primaryshiftingOffsetDivision: 2.6,
        autoLoop: false,
        minScale: 0.7,
        initialIndex: 0,
        scrollTime: 50);
    gallery3dControllerForProductImagesTrackingIndex = Gallery3DController(
        itemCount: max(3, (widget.productItem.images?.length ?? 0) * 2),
        primaryshiftingOffsetDivision: 2.6,
        autoLoop: false,
        minScale: 0.7,
        currentIndex: 0,
        initialIndex: 0,
        scrollTime: 1);
    homeBloc.add(AddCurrentSelectedColorEvent(
        currentSelectedColor: syncColorImageList!.length ~/ 4,
        productId: widget.productItem.id.toString()));
    gallery3dControllerForCircles =
        syncColorImageList.isNullOrEmpty || syncColorImageList!.length < 3
            ? null
            : Gallery3DController(
                itemCount: syncColorImageList!.length,
                autoLoop: false,
                minScale: (syncColorImageList!.length) == 4
                    ? 0.7
                    : (syncColorImageList!.length) <= 8
                        ? 0.6
                        : 0.4,
                initialIndex: syncColorImageList!.length ~/ 4,
                primaryshiftingOffsetDivision: (syncColorImageList!.length) == 4
                    ? 4.5
                    : (syncColorImageList!.length) <= 8
                        ? 2.8
                        : 1.6,
                scrollTime: 1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    slideModeIndex = widget.itemIndex == widget.slidingModeItem.item1
        ? widget.slidingModeItem.item2
        : 0;

    FlutterError.onError = (error) {
      debugPrint(error.toString());
    };
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.transparent,
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
                                      width: 200.w,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemBuilder: (ctx, index) {
                                          return InkWell(
                                            onTap: () {
                                              gallery3dControllerForColors
                                                  .animateTo(index, false);
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
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Stack(
                                                  children: [
                                                    MyCachedNetworkImage(
                                                      ordinalHeight: syncColorImageList
                                                              .isNullOrEmpty
                                                          ? double.parse(widget
                                                              .productItem
                                                              .images![index]
                                                              .originalHeight!)
                                                          : double.parse(
                                                              syncColorImageList![
                                                                      prevIndexInSecondSlider]
                                                                  .images![
                                                                      index]
                                                                  .originalHeight!),
                                                      ordinalwidth: syncColorImageList
                                                              .isNullOrEmpty
                                                          ? double.parse(widget
                                                              .productItem
                                                              .images![index]
                                                              .originalWidth!)
                                                          : double.parse(
                                                              syncColorImageList![
                                                                      prevIndexInSecondSlider]
                                                                  .images![
                                                                      index]
                                                                  .originalWidth!),
                                                      imageUrl: syncColorImageList
                                                              .isNullOrEmpty
                                                          ? widget
                                                              .productItem
                                                              .images![index]
                                                              .filePath!
                                                          : syncColorImageList![
                                                                  prevIndexInSecondSlider]
                                                              .images![index]
                                                              .filePath!,
                                                      height: 40,
                                                      width: 30,
                                                      logoTextHeight: 15,
                                                      logoTextWidth: 20,
                                                      circleDimensions: 7,
                                                      imageFit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: 30,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.5),
                                                            offset:
                                                                Offset(0, 3),
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
                                        itemCount: syncColorImageList
                                                .isNullOrEmpty
                                            ? widget.productItem.images!.length
                                            : syncColorImageList![
                                                    prevIndexInSecondSlider]
                                                .images!
                                                .length,
                                        padding:
                                            EdgeInsets.only(left: 5, top: 5),
                                        separatorBuilder: (ctx, index) {
                                          if (index ==
                                              (widget.productItem.images!
                                                      .length -
                                                  1)) return SizedBox.shrink();
                                          return SizedBox(
                                            width: 2,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    ValueListenableBuilder<
                                            Tuple2<List<String>, List<String>>>(
                                        valueListenable: threeImagesSlider,
                                        builder: (context, sliderData, child) {
                                          return MyGallery3DWidget(
                                            key: UniqueKey(),
                                            gallery3dController:
                                                gallery3dControllerForProductImages,
                                            gallery3dControllerForCircles:
                                                gallery3dControllerForProductImagesTrackingIndex,
                                            stopScrollingOnEdges:
                                                (double primaryDelta) {
                                              return (primaryDelta <= 0 &&
                                                      gallery3dControllerForProductImagesTrackingIndex
                                                              .currentIndex ==
                                                          ((widget
                                                                      .productItem
                                                                      .images
                                                                      ?.length ??
                                                                  0) -
                                                              1) ||
                                                  (primaryDelta >= 0 &&
                                                      gallery3dControllerForProductImagesTrackingIndex
                                                              .currentIndex ==
                                                          0));
                                            },
                                            itemWidth: 170.w,
                                            threeImages: sliderData.item1,
                                            onItemClick: (index) {
                                              widget.setThisEnabled
                                                  .call(-1, -1);
                                            },
                                            images: sliderData.item2,
                                            galleryHeight: 240,
                                            itemHeight: 240,
                                            onItemChanged: (int index) {
                                              bool scrollToLeft = false;
                                              if ((prevIndexForThreeImages ==
                                                          0 &&
                                                      index == 2) ||
                                                  (prevIndexForThreeImages ==
                                                          2 &&
                                                      index == 1) ||
                                                  (prevIndexForThreeImages ==
                                                          1 &&
                                                      index == 0)) {
                                                scrollToLeft = true;
                                              }
                                              if (!scrollToLeft) {
                                                gallery3dControllerForProductImagesTrackingIndex
                                                        .currentIndex =
                                                    (gallery3dControllerForProductImagesTrackingIndex
                                                                    .currentIndex +
                                                                1) ==
                                                            widget.productItem
                                                                .images!.length
                                                        ? 0
                                                        : (gallery3dControllerForProductImagesTrackingIndex
                                                                .currentIndex +
                                                            1);
                                              } else {
                                                gallery3dControllerForProductImagesTrackingIndex
                                                        .currentIndex =
                                                    (gallery3dControllerForProductImagesTrackingIndex
                                                                    .currentIndex -
                                                                1) <
                                                            0
                                                        ? widget
                                                                .productItem
                                                                .images!
                                                                .length -
                                                            1
                                                        : (gallery3dControllerForProductImagesTrackingIndex
                                                                .currentIndex -
                                                            1);
                                              }
                                              prevIndexForThreeImages = index;
                                              widget.currentChosenColor.value =
                                                  prevIndexForThreeImages;
                                              if (scrollToLeft) {
                                                updateImagesForThreeImagesSlider(
                                                    true,
                                                    calledFromOnChanged: true);
                                              } else {
                                                updateImagesForThreeImagesSlider(
                                                    false,
                                                    calledFromOnChanged: true);
                                              }
                                            },
                                            galleryWidth: 200,
                                            radius: 15,
                                            itemCount: widget.productItem.images
                                                    ?.length ??
                                                0,
                                          );
                                        }),
                                  } else
                                    const SizedBox.shrink(),
                                  if (slideModeIndex == 1 &&
                                      gallery3dControllerForCircles !=
                                          null) ...{
                                    ValueListenableBuilder<
                                            Tuple2<List<String>, List<String>>>(
                                        valueListenable: threeColorsSlider,
                                        builder: (context, sliderData, child) {
                                          return Transform.translate(
                                            offset: Offset(-5, 0),
                                            child: MyGallery3DWidget(
                                              //  key: ValueKey('gallery3dControllerForColors${widget.itemIndex}'),
                                              gallery3dController:
                                                  gallery3dControllerForColors,
                                              gallery3dControllerForCircles:
                                                  gallery3dControllerForCircles,
                                              stopScrollingOnEdges:
                                                  (double primaryDelta) {
                                                return (primaryDelta <= 0 &&
                                                        gallery3dControllerForCircles!
                                                                .currentIndex ==
                                                            (syncColorImageList!
                                                                        .length ~/
                                                                    2 -
                                                                1) ||
                                                    (primaryDelta >= 0 &&
                                                        gallery3dControllerForCircles!
                                                                .currentIndex ==
                                                            0));
                                              },
                                              itemWidth: 170.w,
                                              itemHeight: 240,
                                              threeImages: sliderData.item1,
                                              onItemClick: (index) {
                                                homeBloc.add(
                                                    AddCurrentSelectedColorEvent(
                                                        currentSelectedColor:
                                                            gallery3dControllerForCircles!
                                                                .currentIndex,
                                                        productId: widget
                                                            .productItem.id
                                                            .toString()));
                                                widget.setThisEnabled
                                                    .call(-1, -1);
                                              },
                                              images: sliderData.item2,
                                              galleryHeight: 240,
                                              onItemChanged: (int index) {
                                                bool scrollToLeft = false;
                                                if ((prevIndexForThreeColors ==
                                                            0 &&
                                                        index == 2) ||
                                                    (prevIndexForThreeColors ==
                                                            2 &&
                                                        index == 1) ||
                                                    (prevIndexForThreeColors ==
                                                            1 &&
                                                        index == 0)) {
                                                  scrollToLeft = true;
                                                }
                                                prevIndexForThreeColors = index;
                                                if (!scrollToLeft) {
                                                  prevIndexInSecondSlider =
                                                      prevIndexInFirstSlider =
                                                          (gallery3dControllerForCircles!
                                                                          .currentIndex +
                                                                      1) ==
                                                                  images.length
                                                              ? 0
                                                              : (gallery3dControllerForCircles!
                                                                      .currentIndex +
                                                                  1);
                                                  currentColorIndex.value =
                                                      prevIndexInFirstSlider;
                                                  gallery3dControllerForCircles!
                                                      .animateTo(
                                                          prevIndexInFirstSlider,
                                                          false);
                                                } else {
                                                  prevIndexInSecondSlider =
                                                      prevIndexInFirstSlider =
                                                          (gallery3dControllerForCircles!
                                                                          .currentIndex -
                                                                      1) <
                                                                  0
                                                              ? images.length -
                                                                  1
                                                              : (gallery3dControllerForCircles!
                                                                      .currentIndex -
                                                                  1);
                                                  currentColorIndex.value =
                                                      prevIndexInFirstSlider;
                                                  gallery3dControllerForCircles!
                                                      .animateTo(
                                                          prevIndexInFirstSlider,
                                                          true);
                                                  widget.currentChosenColor
                                                          .value =
                                                      prevIndexInFirstSlider;
                                                }
                                                if (scrollToLeft) {
                                                  updateImagesForThreeColorsSlider(
                                                      true,
                                                      calledFromOnChanged:
                                                          true);
                                                } else {
                                                  updateImagesForThreeColorsSlider(
                                                      false,
                                                      calledFromOnChanged:
                                                          true);
                                                }
                                              },
                                              galleryWidth: 200,
                                              radius: 15,
                                              itemCount: 3,
                                            ),
                                          );
                                        }),
                                    ValueListenableBuilder<int>(
                                      valueListenable: currentColorIndex,
                                      builder: (context, currentIndex, _) {
                                        return MyTextWidget(
                                          syncColorImageList.isNullOrEmpty
                                              ? ""
                                              : syncColorImageList![
                                                      currentIndex]
                                                  .colorName
                                                  .toString(),
                                          textAlign: TextAlign.center,
                                          style: textTheme.titleMedium?.mq
                                              .copyWith(
                                            color: Color(int.parse(
                                                '0xff${widget.productItem.colors![currentIndex % widget.productItem.colors!.length].color!.substring(1)}')),
                                          ),
                                        );
                                      },
                                    ),
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
                                    Stack(
                                      alignment: LanguageService.rtl
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      children: [
                                        SizedBox(
                                          height: 290,
                                          width: 200,
                                          child: CarouselSlider.builder(
                                              itemCount: syncColorImageList
                                                      .isNullOrEmpty
                                                  ? widget.productItem.images!
                                                      .length
                                                  : syncColorImageList![
                                                          prevIndexInSecondSlider]
                                                      .images!
                                                      .length,
                                              carouselController:
                                                  carouselController,
                                              options: CarouselOptions(
                                                initialPage:
                                                    indicatorForProductImages
                                                            .value[
                                                        prevIndexInSecondSlider]!,
                                                height: 290,
                                                onPageChanged: (page, reason) {
                                                  indicatorForProductImages
                                                              .value[
                                                          prevIndexInSecondSlider] =
                                                      page;
                                                  indicatorForProductImages
                                                      .notifyListeners();
                                                  if (widget.slidingModeItem
                                                          .item1 !=
                                                      -1) {
                                                    widget.setThisEnabled
                                                        .call(-1, -1);
                                                  }
                                                },
                                                enableInfiniteScroll: false,
                                                viewportFraction: 1,
                                              ),
                                              itemBuilder: (context, index, _) {
                                                return ProductListingImageWidget(
                                                  orginalHeight: syncColorImageList
                                                          .isNullOrEmpty
                                                      ? double.parse(widget
                                                          .productItem
                                                          .images![index]
                                                          .originalHeight!)
                                                      : double.parse(
                                                          syncColorImageList![
                                                                  prevIndexInSecondSlider]
                                                              .images![index]
                                                              .originalHeight!),
                                                  orginalWidth: syncColorImageList
                                                          .isNullOrEmpty
                                                      ? double.parse(widget
                                                          .productItem
                                                          .images![index]
                                                          .originalWidth!)
                                                      : double.parse(
                                                          syncColorImageList![
                                                                  prevIndexInSecondSlider]
                                                              .images![index]
                                                              .originalWidth!),
                                                  width: 200,
                                                  imageUrl: syncColorImageList
                                                          .isNullOrEmpty
                                                      ? widget
                                                          .productItem
                                                          .images![index]
                                                          .filePath!
                                                      : syncColorImageList![
                                                              prevIndexInSecondSlider]
                                                          .images![index]
                                                          .filePath!,
                                                  height: 290,
                                                  circleShape: false,
                                                  innerShadowYOffset: 3,
                                                );
                                              }),
                                        ),
                                        Container(
                                            height: 290,
                                            width: 30,
                                            color: Colors.transparent)
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: InkWell(
                                        onTap: () {
                                          widget.setThisEnabled
                                              .call(widget.itemIndex, 2);
                                          // setState(() {
                                          //   slideModeIndex = 2;
                                          // });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: ValueListenableBuilder<
                                                  Map<int, int>>(
                                              valueListenable:
                                                  indicatorForProductImages,
                                              builder: (context,
                                                  currentSelected, _) {
                                                int itemCount = syncColorImageList
                                                        .isNullOrEmpty
                                                    ? widget.productItem.images!
                                                        .length
                                                    : syncColorImageList![
                                                            prevIndexInSecondSlider]
                                                        .images!
                                                        .length;
                                                return Row(
                                                  children: List.generate(
                                                      itemCount, (index) {
                                                    return Container(
                                                      margin: EdgeInsets.only(
                                                          right: index !=
                                                                  (itemCount -
                                                                      1)
                                                              ? 2
                                                              : 0),
                                                      width: index <=
                                                              (itemCount ~/ 2)
                                                          ? (index * 2 + 2)
                                                          : ((index - ((index - (itemCount ~/ 2)) * 2)) *
                                                                      2 +
                                                                  2)
                                                              .abs()
                                                              .toDouble(),
                                                      height: index <=
                                                              (itemCount ~/ 2)
                                                          ? (index * 2 + 2)
                                                          : ((index - ((index - itemCount ~/ 2) * 2)) *
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
                                                                currentSelected[
                                                                    prevIndexInSecondSlider]
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
                                    ),
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
                                if (widget.productItem.brand != null)
                                  widget.productItem.brand!.icon != null
                                      ? widget.productItem.brand!.icon!
                                                  .filePath !=
                                              null
                                          ? SvgNetworkWidget(
                                              svgUrl: widget.productItem.brand!
                                                  .icon!.filePath!
                                                  .toString(),
                                              width: 30.w,
                                              height: 15)
                                          : SizedBox.shrink()
                                      : SizedBox.shrink(),
                                // SvgPicture.asset(
                                //   AppAssets.mangoSvg,
                                //   height: 10,
                                //   color: Color(0xff1A171B),
                                //   width: 169.w,
                                // ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MyTextWidget('1',
                                        style:
                                            textTheme.titleSmall?.mq.copyWith(
                                          color: Color(0xff5d5d5d),
                                        )),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    SizedBox(
                                      height: 10,
                                      child: Transform.translate(
                                          offset: Offset(0, 1),
                                          child: widget.productItem.category !=
                                                  null
                                              ? SvgNetworkWidget(
                                                  svgUrl: widget
                                                      .productItem
                                                      .category!
                                                      .flatPhotoPath!
                                                      .filePath
                                                      .toString(),
                                                  width: 10,
                                                  height: 10)
                                              : SizedBox.shrink()),
                                    ),
                                    // ListView.separated(
                                    //     itemCount: widget.productItem.categories?.length ?? 0,
                                    //     separatorBuilder: (ctx , index){
                                    //       return 5.horizontalSpace;
                                    //     },
                                    //     shrinkWrap: true,
                                    //     scrollDirection: Axis.horizontal,
                                    //     itemBuilder: (ctx , index){
                                    //       return MyCachedNetworkImage(imageUrl: widget.productItem
                                    //           .categories![index].icon.toString(),
                                    //           logoTextWidth: 5,
                                    //           logoTextHeight: 5,
                                    //           circleDimensions: 5,
                                    //           width: 10,
                                    //           imageFit: BoxFit.cover,
                                    //           height: 10);
                                    //     }),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                      child: MyTextWidget(
                                          widget.productItem.name.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              textTheme.titleSmall?.rq.copyWith(
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
                      width: 225,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 22),
                        child: BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (previous, current) =>
                                previous.getCurrencyForCountryModel !=
                                current.getCurrencyForCountryModel,
                            builder: (context, state) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      MyTextWidget(
                                        (widget.productItem.price! *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toStringAsFixed(state
                                                    .startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString(),
                                        style:
                                            textTheme.titleMedium?.lq.copyWith(
                                          color: Color(0xff3c3c3c),
                                          decoration:
                                              TextDecoration.lineThrough,
                                          height: 0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      MyTextWidget(
                                        (widget.productItem.offerPrice! *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toStringAsFixed(state
                                                    .startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString(),
                                        style:
                                            textTheme.titleMedium?.bq.copyWith(
                                          color: Color(0xff3c3c3c),
                                          height: 0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      MyTextWidget(state
                                              .getCurrencyForCountryModel!
                                              .data!
                                              .currency!
                                              .symbol ??
                                          "")
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      MyTextWidget(
                                        'Buy',
                                        style:
                                            textTheme.titleSmall?.lq.copyWith(
                                          color: Color(0xff414141),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SvgPicture.asset(
                                        AppAssets.bagSvg,
                                        height: 15,
                                        width: 15,
                                      ),
                                    ],
                                  )
                                ],
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              slideModeIndex != 2 && gallery3dControllerForCircles != null
                  ? Positioned(
                      bottom: 70,
                      child: AnimatedScale(
                        scale: slideModeIndex == 0 ? 0.625 : 1,
                        alignment: Alignment.bottomCenter,
                        duration: Duration(milliseconds: 100),
                        child: GestureDetector(
                            onPanStart: (details) {
                              if (slideModeIndex == 0) {
                                widget.setThisEnabled.call(widget.itemIndex, 1);
                                return;
                              }
                            },
                            onPanDown: (details) {
                              if (slideModeIndex == 0) {
                                widget.setThisEnabled.call(widget.itemIndex, 1);
                                return;
                              }
                            },
                            onTap: () {},
                            child: Gallery3D(
                                controller: gallery3dControllerForCircles!,
                                width: 200.w,
                                stopScrollingOnEdges: (double primaryDelta) {
                                  return (primaryDelta <= 0 &&
                                          gallery3dControllerForCircles!
                                                  .currentIndex ==
                                              (syncColorImageList!.length ~/ 2 -
                                                  1)) ||
                                      (primaryDelta >= 0 &&
                                          gallery3dControllerForCircles!
                                                  .currentIndex ==
                                              0);
                                },
                                height: null,
                                changingPagesScrollOffset: 0.1,
                                isClip: false,
                                onItemChanged: (index) {
                                  widget.currentChosenColor.value = index;
                                  if (slideModeIndex != 2 &&
                                      ((prevIndexInSecondSlider < index &&
                                              (index -
                                                      prevIndexInSecondSlider) !=
                                                  (syncColorImageList!.length -
                                                      1)) ||
                                          (prevIndexInSecondSlider ==
                                                  (syncColorImageList!.length -
                                                      1) &&
                                              index == 0))) {
                                    prevIndexForThreeColors =
                                        (gallery3dControllerForColors
                                                        .currentIndex +
                                                    1) ==
                                                3
                                            ? 0
                                            : (gallery3dControllerForColors
                                                    .currentIndex +
                                                1);
                                    gallery3dControllerForColors.animateTo(
                                        prevIndexForThreeColors, false);
                                    updateImagesForThreeColorsSlider(false);
                                  } else if (slideModeIndex != 2) {
                                    prevIndexForThreeColors =
                                        (gallery3dControllerForColors
                                                        .currentIndex -
                                                    1) <
                                                0
                                            ? 2
                                            : (gallery3dControllerForColors
                                                    .currentIndex -
                                                1);
                                    gallery3dControllerForColors.animateTo(
                                        prevIndexForThreeColors, true);
                                    updateImagesForThreeColorsSlider(true);
                                  }
                                  if (slideModeIndex != 2) {
                                    prevIndexInFirstSlider = index;
                                    prevIndexInSecondSlider = index;
                                    currentColorIndex.value =
                                        prevIndexInFirstSlider;
                                  }
                                },
                                itemConfig: GalleryItemConfig(
                                    width: 40,
                                    height: 40,
                                    radius: 360,
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
                                  return GestureDetector(
                                    onTap: () {
                                      if (index == prevIndexInFirstSlider)
                                        return;
                                      int indexx = gallery3dControllerForColors
                                          .currentIndex;
                                      if ((index -
                                              (syncColorImageList!.length ~/
                                                  4)) <=
                                          0) {
                                        gallery3dControllerForCircles!
                                            .animateTo(index, false);
                                        int stepCount = 0;
                                        if (index > prevIndexInFirstSlider) {
                                          stepCount =
                                              index - prevIndexInFirstSlider;
                                        } else {
                                          stepCount =
                                              (syncColorImageList!.length) -
                                                  prevIndexInFirstSlider +
                                                  index;
                                        }
                                        for (int i = 0; i < stepCount; i++) {
                                          indexx++;
                                          if (indexx == 3) {
                                            indexx = 0;
                                          }
                                          updateImagesForThreeColorsSlider(
                                              false,
                                              currentIndex: indexx);
                                        }
                                        for (int i = 0; i < stepCount; i++) {
                                          gallery3dControllerForColors.animateTo(
                                              gallery3dControllerForColors
                                                              .currentIndex +
                                                          1 ==
                                                      3
                                                  ? 0
                                                  : (gallery3dControllerForColors
                                                          .currentIndex +
                                                      1),
                                              false);
                                        }
                                      } else {
                                        homeBloc.add(
                                            AddCurrentSelectedColorEvent(
                                                currentSelectedColor: index,
                                                productId: widget.productItem.id
                                                    .toString()));
                                        gallery3dControllerForCircles!
                                            .animateTo(index, true);
                                        int stepCount = 0;
                                        if (index > prevIndexInFirstSlider) {
                                          stepCount =
                                              (syncColorImageList!.length) -
                                                  index +
                                                  prevIndexInFirstSlider;
                                        } else {
                                          stepCount =
                                              prevIndexInFirstSlider - index;
                                        }
                                        for (int i = 0; i < stepCount; i++) {
                                          indexx--;
                                          if (indexx == -1) {
                                            indexx = 2;
                                          }
                                          updateImagesForThreeColorsSlider(true,
                                              currentIndex: indexx);
                                        }
                                        for (int i = 0; i < stepCount; i++) {
                                          gallery3dControllerForColors.animateTo(
                                              (gallery3dControllerForColors
                                                              .currentIndex -
                                                          1) <
                                                      0
                                                  ? 2
                                                  : (gallery3dControllerForColors
                                                          .currentIndex -
                                                      1),
                                              true);
                                        }
                                      }
                                      prevIndexForThreeColors = indexx;
                                      prevIndexInSecondSlider =
                                          prevIndexInFirstSlider = index;
                                      currentColorIndex.value = index;
                                    },
                                    child: Visibility(
                                      visible: ((gallery3dControllerForCircles
                                                          ?.currentIndex ??
                                                      0) <
                                                  (syncColorImageList!.length ~/
                                                      2) &&
                                              index <
                                                  (syncColorImageList!.length ~/
                                                      2)) ||
                                          ((gallery3dControllerForCircles
                                                          ?.currentIndex ??
                                                      0) >=
                                                  (syncColorImageList!.length ~/
                                                      2) &&
                                              index >=
                                                  (syncColorImageList!.length ~/
                                                      2)),
                                      child: ProductListingImageWidget(
                                        orginalHeight: orginalHeigh[index],
                                        orginalWidth: orginalWidth[index],
                                        width: 40,
                                        height: 40,
                                        imageUrl: images[index],
                                        innerShadowYOffset: 4,
                                        borderColor: index ==
                                                prevIndexInFirstSlider
                                            ? Color(int.parse(
                                                '0xff${widget.productItem.colors![currentColorIndex.value % widget.productItem.colors!.length].color!.substring(1)}'))
                                            : Colors.white,
                                        circleShape: true,
                                      ),
                                    ),
                                  );
                                })),
                      ))
                  : const SizedBox.shrink()
            ],
          ),
        ));
  }

  void updateImagesForThreeColorsSlider(bool isScrollLeft,
      {bool calledFromOnChanged = false, int? currentIndex}) {
    int index = 0;
    List<String> threeImages = threeColorsSlider.value.item1;
    List<String> images = threeColorsSlider.value.item2;
    if (isScrollLeft) {
      index = currentIndex ??
          (calledFromOnChanged
              ? gallery3dControllerForColors.currentIndex
              : (gallery3dControllerForColors.currentIndex - 1) < 0
                  ? 2
                  : (gallery3dControllerForColors.currentIndex - 1));
      String middleImageFromThree =
          threeImages[index - 1 < 0 ? 2 : (index - 1)];
      threeImages[index - 1 < 0 ? 2 : (index - 1)] = images.last;
      images.removeLast();
      images.insert(0, middleImageFromThree);
    } else {
      index = currentIndex ??
          (calledFromOnChanged
              ? gallery3dControllerForColors.currentIndex
              : (gallery3dControllerForColors.currentIndex + 1) > 2
                  ? 0
                  : (gallery3dControllerForColors.currentIndex + 1));
      String middleImageFromThree =
          threeImages[index + 1 > 2 ? 0 : (index + 1)];
      threeImages[index + 1 > 2 ? 0 : (index + 1)] = images.first;
      images.removeAt(0);
      images.add(middleImageFromThree);
    }
    threeColorsSlider.value = Tuple2(threeImages, images);
  }

  void updateImagesForThreeImagesSlider(bool isScrollLeft,
      {bool calledFromOnChanged = false, int? currentIndex}) {
    int index = 0;
    List<String> threeImages = threeImagesSlider.value.item1;
    List<String> images = threeImagesSlider.value.item2;
    if (isScrollLeft) {
      index = currentIndex ??
          (calledFromOnChanged
              ? gallery3dControllerForProductImages.currentIndex
              : (gallery3dControllerForProductImages.currentIndex - 1) < 0
                  ? 2
                  : (gallery3dControllerForProductImages.currentIndex - 1));
      String middleImageFromThree =
          threeImages[index - 1 < 0 ? 2 : (index - 1)];
      threeImages[index - 1 < 0 ? 2 : (index - 1)] = images.last;
      images.removeLast();
      images.insert(0, middleImageFromThree);
    } else {
      index = currentIndex ??
          (calledFromOnChanged
              ? gallery3dControllerForProductImages.currentIndex
              : (gallery3dControllerForProductImages.currentIndex + 1) > 2
                  ? 0
                  : (gallery3dControllerForProductImages.currentIndex + 1));
      String middleImageFromThree =
          threeImages[index + 1 > 2 ? 0 : (index + 1)];
      threeImages[index + 1 > 2 ? 0 : (index + 1)] = images.first;
      images.removeAt(0);
      images.add(middleImageFromThree);
    }
    threeImagesSlider.value = Tuple2(threeImages, images);
  }
}
