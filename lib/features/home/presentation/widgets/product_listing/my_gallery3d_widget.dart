import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';

class MyGallery3DWidget extends StatefulWidget {
   MyGallery3DWidget(
      {super.key,
      required this.itemWidth,
      required this.gallery3dController,
      required this.gallery3dControllerForCircles,
      required this.itemCount,
      required this.showProductSides,
      required this.currentProduct,
      this.itemHeight,
        this.stopScrollingOnEdges,
      this.onItemChanged,
      required this.radius,
      required this.galleryWidth,
      required this.galleryHeight,
      this.onItemClick,
        required this.threeImages,
      required this.images});

  final bool showProductSides;
  final int currentProduct;
  final int itemCount;
  final double itemWidth;
  final double? itemHeight;
  final double radius;
  final double galleryWidth;
  final double galleryHeight;
   final bool Function(double primaryDelta)? stopScrollingOnEdges;
  final Gallery3DController gallery3dController;
  final Gallery3DController gallery3dControllerForCircles;
  final void Function(int index)? onItemChanged;
  final void Function(int index)? onItemClick;
   List<String> images;
   List<String> threeImages;

  @override
  State<MyGallery3DWidget> createState() => _MyGallery3DWidgetState();
}

class _MyGallery3DWidgetState extends State<MyGallery3DWidget> {
  List<Color> leftColors = [
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.grey,
    Colors.blue,
    Colors.red,
  ];
  List<Color> threeColors = [
    // Colors.green,
    // Colors.yellow,
    // Colors.brown,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.grey,
    Colors.blue,
    Colors.brown,
  ];
  List<String> threeImages = [];

  @override
  void initState() {
    // threeImages.add(widget.images[0]);
    // threeImages.add(widget.images[1]);
    // threeImages.add(widget.images[widget.images.length - 1]);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Gallery3D(
        controller: widget.gallery3dController,
        width: widget.galleryWidth,
        stopScrollingOnEdges: widget.stopScrollingOnEdges,
        key: widget.key,
        changingPagesScrollOffset: 0.3,
        height: widget.galleryHeight,
        isClip: false,
        // ellipseHeight: 80,
        // currentIndex: currentIndex,
        onItemChanged:
          widget.onItemChanged,
            // setState(() {
            //   if ((prevIndex == 0 && index == 2) ||
            //       (prevIndex == 2 && index == 1) ||
            //       (prevIndex == 1 && index == 0)) {
            //     String middleImageFromThree =
            //     widget.threeImages[index - 1 < 0 ? 2 : (index - 1)];
            //     widget.threeImages[index - 1 < 0 ? 2 : (index - 1)] =
            //         widget.images.last;
            //     widget.images.removeLast();
            //     widget.images.insert(0, middleImageFromThree);
            //   } else {
            //     String middleImageFromThree =
            //     widget.threeImages[index + 1 > 2 ? 0 : (index + 1)];
            //     widget.threeImages[index + 1 > 2 ? 0 : (index + 1)] =
            //         widget.images.first;
            //     widget.images.removeAt(0);
            //     widget.images.add(middleImageFromThree);
            //   }
            //   prevIndex = index;
            // });
        itemConfig: GalleryItemConfig(
          width: widget.itemWidth,
          //height: 220,
          radius: widget.radius,
          isShowTransformMask: false,
          // shadows: [
          //   BoxShadow(
          //       color: Color(0x90000000), offset: Offset(2, 0), blurRadius: 5)
          // ]
        ),
        onClickItem: (index) {
          widget.onItemClick?.call(index);
        },
        itemBuilder: (context, index) {
          // return Container(
          //   decoration: BoxDecoration(
          //     image: const DecorationImage(
          //       image: AssetImage('assets/image.png'),
          //       fit: BoxFit.cover,
          //     ),
          //     borderRadius: BorderRadius.circular(15.0),
          //     border: Border.all(width: 0.5, color: const Color(0xffffffff)),
          //   ),
          // );
          // return Container(
          //   color: threeColors[index],
          // );
          return Visibility(
            visible: !((widget.gallery3dControllerForCircles.currentIndex == 0 && index == 2) || (widget.gallery3dControllerForCircles.currentIndex == 6 && index == 1)),
            child: ProductListingImageWidget(
              innerShadowYOffset: 3,
              circleShape: false,
              width: widget.itemWidth,
              imageUrl: !widget.showProductSides
                  ? widget.threeImages[index]
                  : widget.threeImages[widget.currentProduct],
            ),
          );
        });
  }
}
