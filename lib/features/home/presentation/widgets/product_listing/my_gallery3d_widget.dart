import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';

class MyGallery3DWidget extends StatefulWidget {
  const MyGallery3DWidget(
      {super.key,
      required this.itemWidth,
      required this.gallery3dController,
      required this.itemCount,
      this.itemHeight,
      this.onItemChanged,
      required this.radius,
      required this.galleryWidth, required this.galleryHeight});

  final int itemCount;
  final double itemWidth;
  final double? itemHeight;
  final double radius;
  final double galleryWidth;
  final double galleryHeight;
  final Gallery3DController gallery3dController;
  final void Function(int index)? onItemChanged;
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

  int prevIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Gallery3D(
        controller: widget.gallery3dController,
        width: widget.galleryWidth,
        changingPagesScrollOffset: 0.7,
        height: widget.galleryHeight,
        isClip: false,
        // ellipseHeight: 80,
        // currentIndex: currentIndex,
        onItemChanged: (index) {
          widget.onItemChanged?.call(index);
          // scroll to right
          // if (widget.itemCount == 3) {
          //   setState(() {
          //     if ((prevIndex == 0 && index == 2) ||
          //         (prevIndex == 2 && index == 1) ||
          //         (prevIndex == 1 && index == 0)) {
          //       Color middleColorFromThree =
          //           threeColors[index - 1 < 0 ? 2 : (index - 1)];
          //       threeColors[index - 1 < 0 ? 2 : (index - 1)] =
          //           leftColors.first;
          //       leftColors.removeAt(0);
          //       leftColors.add(middleColorFromThree);
          //     } else {
          //       Color middleColorFromThree =
          //           threeColors[index + 1 > 2 ? 0 : (index + 1)];
          //       threeColors[index + 1 > 2 ? 0 : (index + 1)] =
          //           leftColors.last;
          //       leftColors.removeLast();
          //       leftColors.insert(0, middleColorFromThree);
          //     }
          //     prevIndex = index;
          //   });
          // }
        },
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
          //if (kDebugMode) print("currentIndex:$index");
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
          return const ProductListingImageWidget(innerShadowYOffset: 3,circleShape: false,);
        });
  }
}
