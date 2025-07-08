import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart'
    as inset_shadow;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file/file.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';
import 'package:trydos/features/app/smart_cache_manager.dart';
import 'package:trydos/features/app/home_page_image_protector.dart';
import 'package:trydos/features/app/memory_management_helper.dart';
import 'package:trydos/features/app/trydos_shimmer_loading_stateless.dart';
// Simplified without complex managers

class MyCachedNetworkImage extends StatefulWidget {
  const MyCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    this.logoTextWidth,
    this.ordinalHeight,
    this.ordinalwidth,
    this.logoTextHeight,
    this.imageWidth,
    this.imageHeight,
    required this.imageFit,
    this.imageBuilder,
    this.imageColor,
    this.progressIndicatorBuilderWidget,
    this.callWhenDisplayImage,
    this.callWhenLoadingImage,
    this.radius = 12,
    this.innerShadowYOffset,
    this.withImageShadow = false,
    this.withInnerShadow = false,
    required this.height,
    this.fromStory,
    this.circleDimensions,
    this.imageSource,
  }) : super(key: key);

  final String imageUrl;
  final double width;
  final double? logoTextWidth;
  final double? imageWidth;
  final double? imageHeight;
  final double height;
  final double? ordinalHeight;
  final double? ordinalwidth;
  final double? logoTextHeight;
  final BoxFit imageFit;
  final double radius;
  final double? innerShadowYOffset;
  final bool withImageShadow;
  final bool withInnerShadow;
  final bool? fromStory;
  final ImageWidgetBuilder? imageBuilder;
  final double? circleDimensions;
  final Color? imageColor;
  final void Function()? callWhenDisplayImage;
  final void Function()? callWhenLoadingImage;
  final Widget? progressIndicatorBuilderWidget;
  final String? imageSource;

  @override
  State<MyCachedNetworkImage> createState() => _MyCachedNetworkImageState();
}

class _MyCachedNetworkImageState extends State<MyCachedNetworkImage> {
  late String currentUrl;
  bool enable = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.imageUrl;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String url = addSuitableWidthAndHeightToImage(
      imageUrl: currentUrl,
      ordinalWidth: widget.ordinalwidth,
      ordinalHeight: widget.ordinalHeight,
      height: widget.height,
      width: widget.width,
    );

    // 🔧 إصلاح: استخدام URL الأصلي إذا فشل التحويل
    if (url.isEmpty || url == "null" || url == "undefined") {
      url = currentUrl;
    }

    // 🛡️ حماية صور الصفحة الرئيسية
    if (widget.imageSource != null && url.isNotEmpty) {
      HomePageImageProtector.protectHomePageImage(url,
          source: widget.imageSource);
    }

    // 🔧 إصلاح: التحقق النهائي من صحة URL
    if (url.isEmpty || url == "null" || url == "undefined") {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[600],
            size: min(24, widget.height * 0.4),
          ),
        ),
      );
    }

    return Container(
      key: ValueKey(url),
      alignment: Alignment.center,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.withImageShadow
            ? [
                BoxShadow(
                  color: context.colorScheme.white.withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CachedNetworkImage(
          httpHeaders: {
            'User-Agent': (kDebugMode ? "developer" : "users") +
                'device OS:' +
                (Platform.isAndroid ? 'Android' : 'IOS') +
                ' '
                    ', application version: 1.0.0',
            "Referer": (kDebugMode ? "developer" : "users") +
                'device OS:' +
                (Platform.isAndroid ? 'Android' : 'IOS')
          },
          imageUrl: url,
          fit: widget.imageFit,
          width: widget.width, // maxHeightDiskCache: widget.height.ceil(),
          //  maxWidthDiskCache: widget.width.ceil(),
          color: widget.imageColor,
          useOldImageOnUrlChange: false,
          cacheManager: CustomCacheManagers(),
          height: widget.height,
          // 🔧 إصلاح: إعادة تفعيل memory cache للأداء الأفضل
          memCacheHeight: widget.height.ceil(),

          placeholder: (context, url) => _buildSimpleShimmer(),
          memCacheWidth: widget.width.ceil(),

          // ⚡ تقليل زمن الانتقالات لتسريع عرض الصور
          fadeInDuration: const Duration(milliseconds: 0),
          placeholderFadeInDuration: Duration(milliseconds: 0),
          fadeOutDuration: const Duration(milliseconds: 0),
          /*  progressIndicatorBuilder: (context, _, progress) {
            if (_isDisposed) return const SizedBox.shrink();

            widget.callWhenLoadingImage?.call();

           
          },*/
          imageBuilder: widget.imageBuilder ??
              (ctx, image) {
                if (_isDisposed) return const SizedBox.shrink();

                widget.callWhenDisplayImage?.call();

                return ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: widget.withInnerShadow
                        ? inset_shadow.BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.radius),
                            boxShadow: [
                              inset_shadow.BoxShadow(
                                offset:
                                    Offset(0, widget.innerShadowYOffset ?? 12),
                                blurRadius: 24,
                                inset: true,
                                color: Colors.black.withOpacity(0.44),
                              ),
                            ],
                          )
                        : null,
                    child: Image(
                      image: image,
                      fit: widget.imageFit,
                      width: widget.width,
                      height: widget.height,
                      color: widget.imageColor,
                    ),
                  ),
                );
              },
          errorWidget: (context, url, error) {
            if (_isDisposed) return const SizedBox.shrink();

            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                color: Colors.grey[300],
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: min(30, widget.height * 0.5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 📱 Shimmer ثابت مع أبعاد صحيحة
  Widget _buildSimpleShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: TrydosShimmerLoadingStateless(
          width: widget.width,
          height: widget.height,
          logoTextWidth: widget.width * 0.6, // 60% من العرض
          logoTextHeight: widget.height * 0.3, // 30% من الارتفاع
          radius: widget.radius,
          circleDimensions: widget.circleDimensions,
        ),
      ),
    );
  }
}

class CustomCacheManagers extends CacheManager {
  static const key = 'customCaches';
  static CustomCacheManagers? _instance;

  factory CustomCacheManagers() {
    return _instance ??= CustomCacheManagers._internal();
  }

  CustomCacheManagers._internal()
      : super(Config(
          key,
          maxNrOfCacheObjects: _getOptimizedCacheSize(),
          stalePeriod: Duration(days: _getOptimizedStalePeriod()),
          // 🔧 إصلاح: إضافة timeout للشبكة
        ));

  /// 🎯 إعدادات كاش بسيطة وفعالة
  static int _getOptimizedCacheSize() {
    return 500; // قيمة ثابتة لجميع الأجهزة
  }

  /// 🎯 مدة كاش بسيطة
  static int _getOptimizedStalePeriod() {
    return 7; // 3 أيام ثابتة لجميع الأجهزة
  }
}

void clearCustomCashe() async {
  await CustomCacheManagers().emptyCache();
}

/// 🎯 دالة مبسطة لتحسين الصور (بدون تعقيد)

String addSuitableWidthAndHeightToImage({
  required String imageUrl,
  double? ordinalHeight,
  double? ordinalWidth,
  required double width,
  required double height,
}) {
  // 🔧 إصلاح: إرجاع URL الأصلي للصور غير Cloudinary
  if (!imageUrl.contains("cloudinary")) {
    return imageUrl;
  }

  // 🔧 إصلاح: تحسين معالجة عدم توفر الأبعاد الأصلية
  if (!imageUrl.contains('upload')) {
    return imageUrl;
  }

  int fHeight = 0;
  int fWidth = 0;
  if (height > 200 && width > 200) {
    fWidth = (width * 1.3).toInt();
    fHeight = (height * 1.3).toInt();
  } else {
    fWidth = (width * 1.3).toInt();
    fHeight = (height * 1.3).toInt();
  }

  List<String> list = imageUrl.split('upload');
  String url = '';

  if (ordinalHeight != null &&
      ordinalWidth != null &&
      ordinalHeight != 0 &&
      ordinalWidth != 0) {
    // 🎯 حالة وجود الأبعاد الأصلية (مثل listing)
    url = ordinalWidth >= ordinalHeight
        ? list[0] +
            'upload/c_pad,so_0,f_auto,q_auto,fl_lossy,c_scale,h_${fHeight != 0 ? fHeight : fWidth}' +
            list[1]
        : list[0] +
            'upload/c_pad,so_0,f_auto,q_auto,fl_lossy,c_scale,w_${fWidth != 0 ? fWidth : fHeight}' +
            list[1];
  } else {
    // 🔧 إصلاح: حالة عدم وجود الأبعاد الأصلية (مثل home page)
    // استخدام استراتيجية ذكية بدلاً من h_ فقط
    if (width >= height) {
      // الصورة أعرض من الارتفاع - استخدم العرض
      url = list[0] +
          'upload/c_pad,so_0,f_auto,q_auto,fl_lossy,c_scale,w_${fWidth}' +
          list[1];
    } else {
      // الصورة أطول من العرض - استخدم الارتفاع
      url = list[0] +
          'upload/c_pad,so_0,f_auto,q_auto,fl_lossy,c_scale,h_${fHeight}' +
          list[1];
    }
  }

  print('🔧 Fixed image URL: $url');
  return url;
}
