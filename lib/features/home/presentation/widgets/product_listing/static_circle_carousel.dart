import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class StaticCircleCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final ValueNotifier<int>? tapIndexToShowColorImages;
  final List<String> colors;

  final ValueNotifier<bool>? showShadowForColorImages;
  final PanelController? colorImagesPanelController;
  final int itemIndex;
  const StaticCircleCarousel({
    Key? key,
    required this.imageUrls,
    required this.itemIndex,
    this.tapIndexToShowColorImages,
    this.showShadowForColorImages,
    this.colorImagesPanelController,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    // إعداد أحجام الدوائر
    const double big = 22;
    const double medium = 22;
    const double small = 18;
    const double overlap = 12; // مقدار التداخل بين الدوائر

    if (imageUrls.isEmpty) return const SizedBox.shrink();
    int center = imageUrls.length ~/ 2;

    List<Widget> circles = [];
    // ترتيب رسم الدوائر: الأبعد فالأقرب فالمركزية
    List<int> order = [];
    for (int offset = (imageUrls.length ~/ 2); offset > 0; offset--) {
      if (center - offset >= 0) order.add(center - offset);
      if (center + offset < imageUrls.length) order.add(center + offset);
    }
    // أضف المركزية في النهاية (لتكون في الأعلى)
    order.add(center);

    for (int i in order) {
      double size;

      if (i == center) {
        size = big;
      } else if ((i - center).abs() == 1) {
        size = medium;
      } else {
        size = small;
      }
      double left = (i - center) * overlap + (big - size) / 2;
      circles.add(
        Positioned(
          left: left + (imageUrls.length * overlap) / 2,
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Color(int.parse('0xff${colors[i].substring(1)}'))),
              ),
              child: MyCachedNetworkImage(
                  imageUrl: imageUrls[i],
                  width: size,
                  imageFit: BoxFit.cover,
                  height: size)),
        ),
      );
    }

    return InkWell(
        onTap: () {
          tapIndexToShowColorImages?.value = itemIndex;
          showShadowForColorImages?.value = true;
          colorImagesPanelController?.open();
        },
        child: SizedBox(
          height: big + 16,
          width: (imageUrls.length * overlap) + big,
          child: Stack(
            clipBehavior: Clip.none,
            children: circles,
          ),
        ));
  }
}
