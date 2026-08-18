import 'package:flutter/material.dart';
// ScrollCacheExtent غير مُصدَّرة عبر material.dart/widgets.dart
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;

import 'package:trydos/features/home/presentation/widgets/product_listing/product_colors_panel.dart';


class ColorImagesPanel extends StatelessWidget {
  const ColorImagesPanel({
    super.key,
    required this.panelController,
    required this.productItem,
    required this.currentActiveTab,
    required this.panelControllerForCart,
    required this.visibleRedeem,
  });
  final ValueNotifier<bool> visibleRedeem;
  final PanelController panelController;
  final PanelController panelControllerForCart;
  final product.Products productItem;
  final ValueNotifier<int> currentActiveTab;
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      minHeight: 0,
      controller: panelController,
      maxHeight: 1.sh - 70.h,
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        return panelBuilderContent(scrollController);
      },
    );
  }

  Widget panelBuilderContent(ScrollController sc) {
    final ValueNotifier<bool> visibleRedeem = ValueNotifier(false);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30.r)),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.w),
              height: 2.h,
              width: 40.w,
              decoration: const BoxDecoration(color: const Color(0xffC4C2C2)),
            ),
            SizedBox(height: 5.h),
            Expanded(
              child: GridView.builder(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
                // صفّ كامل مسبقاً. ارتفاع الخانة مشتقّ من childAspectRatio
                // أدناه فيساوي 397.w تقريباً، ويضاف إليه mainAxisSpacing
                scrollCacheExtent: ScrollCacheExtent.pixels(397.w + 5.h),
                controller: sc,
                itemCount: productItem.syncColorImages?.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 5.h,
                  crossAxisSpacing: 5.w,
                  childAspectRatio: 1.sw / (397.w * 2),
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) => Material(
                  color: Colors.transparent,
                  child: ProductColorPanal(
                    panelController: panelController,
                    panelControllerForCart: panelControllerForCart,
                    currentActiveTab: currentActiveTab,
                    colorImages:
                        productItem.syncColorImages?[index].images
                            ?.map((e) => e.filePath ?? "")
                            .toList() ??
                        [],
                    visibleRedeem: visibleRedeem,
                    productItem: productItem,
                    fromDetailsPage: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
