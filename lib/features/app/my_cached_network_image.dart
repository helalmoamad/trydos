import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';

class MyCachedNetworkImage extends StatelessWidget {
  MyCachedNetworkImage(
      {Key? key,
      required this.imageUrl,
      required this.width,
      this.logoTextWidth,
      this.logoTextHeight,
      required this.imageFit,
      this.imageBuilder,
      this.imageColor,
      this.progressIndicatorBuilderWidget,
      this.callWhenDisplayImage,
      this.callWhenLoadingImage,
      this.radius = 12,
      this.withImageShadow = false,
      required this.height,
      this.circleDimensions})
      : super(key: key);

  final ValueNotifier<int> rebuildImage = ValueNotifier(0);

  String currentUrl = '';
  bool enable = true;
  final String imageUrl;
  final double width;
  final double? logoTextWidth;
  final double height;
  final double? logoTextHeight;
  final BoxFit imageFit;
  final double radius;
  final bool withImageShadow;
  final ImageWidgetBuilder? imageBuilder;
  final double? circleDimensions;
  final Color? imageColor;
  final void Function()? callWhenDisplayImage;
  final void Function()? callWhenLoadingImage;

  final Widget? progressIndicatorBuilderWidget;

  Widget getErrorImageWidget() {
    return Center(
        child: GestureDetector(
      onTap: () async {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          currentUrl = '';
          enable = true;
          rebuildImage.value++;
        });
      },
      child: Icon(Icons.refresh,
          color: const Color(0xffff5f61), size: min(25, height)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<String> list;
    String url = '';
    list = imageUrl.split('upload');
    url = width > height
        ? list[0] + 'upload/c_scale,h_${2 * height.toInt()}' + list[1]
        : list[0] + 'upload/c_scale,w_${2 * width.toInt()}' + list[1];

    return ValueListenableBuilder<int>(
        valueListenable: rebuildImage,
        builder: (context, count, _) {
          return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: withImageShadow
                    ? [
                        BoxShadow(
                          color: context.colorScheme.black.withOpacity(0.16),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: CachedNetworkImage(
                  imageUrl: url,
                  key: ValueKey(url),
                  fit: imageFit,
                  width: width,
                  color: imageColor,
                  height: height,
                  cacheManager: CustomCacheManager(),
                  progressIndicatorBuilder: (context, _, progress) {
                    callWhenLoadingImage?.call();
                    return progressIndicatorBuilderWidget ??
                        TrydosShimmerLoading(
                          width: width,
                          height: height,
                          logoTextHeight: logoTextHeight ?? 14,
                          logoTextWidth: logoTextWidth ?? 48.w,
                          circleDimensions: circleDimensions,
                        );
                  },
                  imageBuilder: imageBuilder ??
                      (ctx, image) {
                        callWhenDisplayImage?.call();
                        return ClipRRect(
                            child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: width,
                            height: height,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(radius),
                                image: DecorationImage(
                                  image: image,
                                  fit: imageFit,
                                )),
                          ),
                        ));
                      },
                  errorWidget: (context, url, error) {
                    if (enable) {
                      enable = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        currentUrl = imageUrl;
                        rebuildImage.value++;
                      });
                    }
                    return getErrorImageWidget();
                  }));
        });
  }
}

class CustomCacheManager extends CacheManager {
  static const key = 'customCache';

  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }

  CustomCacheManager._()
      : super(Config(
          key,
          maxNrOfCacheObjects: 200,
          stalePeriod: const Duration(days: 30),
        ));
}
