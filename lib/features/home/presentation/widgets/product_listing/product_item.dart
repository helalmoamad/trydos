import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'dart:ui' as ui;

import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_3d_slider.dart';
import 'package:tuple/tuple.dart';

class ProductItem extends StatefulWidget {
  const ProductItem(
      {super.key,
      required this.setThisEnabled,
      required this.slidingModeItem,
      required this.itemIndex,
      required this.productItem});

  final void Function(int, int) setThisEnabled;
  final Tuple2<int, int> slidingModeItem;
  final productListingModel.Products productItem;
  final int itemIndex;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final PageController pageController = PageController();
  late final ValueNotifier<int> currentChosenColor;

  @override
  void initState() {
    currentChosenColor =
        ValueNotifier((widget.productItem.syncColorImages?.length ?? 0) ~/ 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 350,
            width: 200.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff000000).withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ValueListenableBuilder<int>(
                    valueListenable: currentChosenColor,
                    builder: (context, index, _) {
                      return widget.productItem.syncColorImages.isNullOrEmpty ||
                              widget.productItem.syncColorImages![index].images
                                  .isNullOrEmpty
                          ? Image.asset(
                              'assets/product_listing_background_blur_image.png',
                              fit: BoxFit.cover)
                          : MyCachedNetworkImage(
                              ordinalHeight: double.parse(widget
                                  .productItem
                                  .syncColorImages![index]
                                  .images![0]
                                  .originalHeight!),
                              ordinalwidth: double.parse(widget
                                  .productItem
                                  .syncColorImages![index]
                                  .images![0]
                                  .originalWidth!),
                              imageUrl: widget.productItem
                                  .syncColorImages![index].images![0].filePath!,
                              height: 350,
                              width: 200.w,
                              imageFit: BoxFit.cover,
                            );
                    })),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: BackdropFilter(
                blendMode: BlendMode.overlay,
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xfffafafa)),
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
                  decoration: BoxDecoration(
                      color: const Color(0xffffffff).withOpacity(0.8)),
                ),
              ),
            ),
          ),
          ProductListing3DSlider(
              productItem: widget.productItem,
              slidingModeItem: widget.slidingModeItem,
              currentChosenColor: currentChosenColor,
              itemIndex: widget.itemIndex,
              setThisEnabled: widget.setThisEnabled),
        ]);
  }
}
