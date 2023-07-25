import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';

class MyCachedNetworkImage extends StatelessWidget {
  MyCachedNetworkImage(
      {Key? key,
      required this.imageUrl,
      required this.width,
      required this.imageFit,
      required this.height})
      : super(key: key);

  final ValueNotifier<int> rebuildImage = ValueNotifier(0);

  String currentUrl = '';
  bool enable = true;
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit imageFit;

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
      child: Icon(Icons.refresh, color: const Color(0xffff5f61), size: 30.sp),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: rebuildImage,
        builder: (context, count, _) {
          return SizedBox(
              width: width,
              height: height,
              child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: imageFit,
                  cacheManager: CustomCacheManager(),
                  placeholder: (context, url) => TrydosLoader(),
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
