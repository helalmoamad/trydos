import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';

class MyGallery3DWidget extends StatefulWidget {
  MyGallery3DWidget(
      {super.key,
      required this.itemWidth,
      required this.gallery3dController,
      required this.gallery3dControllerForCircles,
      required this.itemCount,
      this.itemHeight,
      this.stopScrollingOnEdges,
      this.onItemChanged,
      required this.radius,
      required this.galleryWidth,
      required this.galleryHeight,
      this.onItemClick,
      required this.threeImages,
      required this.images});

  final int itemCount;
  final double itemWidth;
  final double? itemHeight;
  final double radius;
  final double galleryWidth;
  final double galleryHeight;
  final bool Function(double primaryDelta)? stopScrollingOnEdges;
  final Gallery3DController gallery3dController;
  final Gallery3DController? gallery3dControllerForCircles;
  final void Function(int index)? onItemChanged;
  final void Function(int index)? onItemClick;

  List<String> images;
  List<String> threeImages;

  @override
  State<MyGallery3DWidget> createState() => _MyGallery3DWidgetState();
}

class _MyGallery3DWidgetState extends State<MyGallery3DWidget> {
  int leftItemIndex = 0, rightItemIndex = 0;

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
        onItemChanged: widget.onItemChanged,
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
          leftItemIndex = (widget.gallery3dController.currentIndex - 1) < 0
              ? ((widget.gallery3dControllerForCircles != null
                          ? 0
                          : widget.gallery3dControllerForCircles?.itemCount ??
                              0) ~/
                      2 -
                  1)
              : (widget.gallery3dController.currentIndex - 1);

          rightItemIndex = (widget.gallery3dController.currentIndex + 1) >
                  ((widget.gallery3dControllerForCircles?.itemCount ?? 0) ~/ 2 -
                      1)
              ? 0
              : (widget.gallery3dController.currentIndex + 1);
          print(
              'vis ${!((widget.gallery3dControllerForCircles?.currentIndex == 0 && index == leftItemIndex) || (widget.gallery3dControllerForCircles?.currentIndex == ((widget.gallery3dControllerForCircles?.itemCount ?? 0) / 2 - 1) && index == rightItemIndex))}');
          return Visibility(
            visible: widget.gallery3dControllerForCircles?.itemCount == 3
                ? index == 0
                : !((widget.gallery3dControllerForCircles?.currentIndex == 0 &&
                        index == leftItemIndex) ||
                    (widget.gallery3dControllerForCircles?.currentIndex ==
                            ((widget.gallery3dControllerForCircles?.itemCount ??
                                        0) /
                                    2 -
                                1) &&
                        index == rightItemIndex)),
            child: widget.threeImages.isNullOrEmpty
                ? SizedBox.shrink()
                : ProductListingImageWidget(
                    innerShadowYOffset: 3,
                    circleShape: false,
                    width: widget.itemWidth,
                    height: widget.itemHeight,
                    imageUrl: widget.threeImages[index]),
          );
        });
  }
}
