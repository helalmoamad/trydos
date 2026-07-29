import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart'
    as inset_shadow;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
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
    this.fromBoutique = false,
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
  final bool? fromBoutique;
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
  void didUpdateWidget(MyCachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        currentUrl = widget.imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String url = addSuitableWidthAndHeightToImage(
      imageUrl: currentUrl,
      height: widget.height,
      width: widget.width,
      // Boutique banners render with `height: null` + BoxFit.fitWidth, so the
      // URL must constrain width only. Without this the height branch below
      // pads them to `height * 1.5` (600px for a 250.h carousel) — ~2.4x the
      // pixels actually drawn.
      fromBoutique: widget.fromBoutique,
    );
    // 🔧 إصلاح: استخدام URL الأصلي إذا فشل التحويل
    if (url.isEmpty || url == "null" || url == "undefined") {
      url = currentUrl;
    }

    // 🔧 إصلاح: التحقق النهائي من صحة URL
    if (url.isEmpty || url == "null" || url == "undefined") {
      if (kDebugMode) print("url is empty or null or undefined${url}");
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

    // أُزيل RepaintBoundary الذي كان يلفّ الودجت.
    //
    // العزل في صفحات القوائم صار من مسؤولية القائمة نفسها عبر
    // `addRepaintBoundaries` على الـdelegate — ونطاقه أوسع: يعزل **العنصر
    // كاملاً** (بطاقة، كاروسيل، نصّ) لا الصورة وحدها. فحاجزان متداخلان يعنيان
    // طبقة GPU زائدة لكل صورة مرئية بلا تغطية إضافية داخل القوائم.
    //
    // مقصود: الشاشات غير القائمية (تفاصيل، صور في Row، شعارات) تفقد العزل،
    // فشيمر التحميل فيها يُعيد رسم ما يحيطه. قرار مقبول لأن أولوية الأداء
    // هنا لصفحات القوائم.
    return Container(
      key: ValueKey(url),
      alignment: Alignment.center,
      /*constraints: BoxConstraints(
      maxHeight: (widget.fromBoutique ?? false)
            ? (0.40 * 1.sh)
            : double.infinity,
        minHeight: (widget.fromBoutique ?? false) ? (0.10 * 1.sh) : 0,
      ),*/
      width: widget.width,
      height: (widget.fromBoutique ?? false) ? null : widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.withImageShadow
            ? [
                BoxShadow(
                  // ignore: deprecated_member_use
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
            'User-Agent':
                (kDebugMode ? "developer" : "users") +
                'device OS:' +
                (Platform.isAndroid ? 'Android' : 'IOS') +
                ' '
                    ', application version: 1.0.0',
            "Referer":
                (kDebugMode ? "developer" : "users") +
                'device OS:' +
                (Platform.isAndroid ? 'Android' : 'IOS'),
          },
          imageUrl: url,
          fit: widget.imageFit,
          width: widget.width,
          color: widget.imageColor,
          cacheManager: CustomCacheManagers(),
          height: (widget.fromBoutique ?? false) ? null : widget.height,

          // ⚡ تحسين: ضغط الصور في الذاكرة فقط (لا يؤثر على جودة العرض).
          // ملاحظة: لا تستخدم maxHeightDiskCache هنا — إنها تصغّر النسخة
          // المخزّنة على القرص لكل الشاشات فتتشوه الصور الكبيرة، والتصغير
          // يتم أصلاً من الخادم عبر addSuitableWidthAndHeightToImage.
          memCacheHeight: (widget.fromBoutique ?? false)
              ? null
              : (widget.height * MediaQuery.devicePixelRatioOf(context))
                    .round(),

          memCacheWidth: (widget.fromBoutique ?? false)
              ? (widget.width * MediaQuery.devicePixelRatioOf(context)).round()
              : null,

          placeholder: (context, url) {
            widget.callWhenLoadingImage?.call();
            return _buildSimpleShimmer();
          },

          // ⚡ تقليل زمن الانتقالات لتسريع عرض الصور
          fadeInDuration: const Duration(),
          placeholderFadeInDuration: const Duration(),
          fadeOutDuration: const Duration(),
          /*  progressIndicatorBuilder: (context, _, progress) {
            if (_isDisposed) return const SizedBox.shrink();

            widget.callWhenLoadingImage?.call();

           
          },*/
          imageBuilder: (widget.fromBoutique ?? false)
              ? null
              : widget.imageBuilder ??
                    (ctx, image) {
                      if (_isDisposed) return const SizedBox.shrink();

                      widget.callWhenDisplayImage?.call();

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(widget.radius),
                        child: Container(
                          width: widget.width,
                          height: (widget.fromBoutique ?? false)
                              ? null
                              : widget.height,
                          decoration: widget.withInnerShadow
                              ? inset_shadow.BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    widget.radius,
                                  ),
                                  boxShadow: [
                                    inset_shadow.BoxShadow(
                                      offset: Offset(
                                        0,
                                        widget.innerShadowYOffset ?? 12,
                                      ),
                                      blurRadius: 24,
                                      inset: true,
                                      // ignore: deprecated_member_use
                                      color: Colors.black.withOpacity(0.44),
                                    ),
                                  ],
                                )
                              : null,
                          child: Image(
                            image: image,
                            fit: widget.imageFit,
                            width: widget.width,
                            height: (widget.fromBoutique ?? false)
                                ? null
                                : widget.height,
                            color: widget.imageColor,
                          ),
                        ),
                      );
                    },
          errorWidget: (context, url, error) {
            if (_isDisposed) return const SizedBox.shrink();

            // 🔄 Widget to allow retrying the image download when it fails
            return GestureDetector(
              onTap: () async {
                try {
                  // Remove the possibly corrupted file from the cache so that it is fetched again
                  await CustomCacheManagers().removeFile(url);
                } catch (_) {}
                // Trigger a new download by changing the URL key slightly (cache-buster)
                if (mounted) {
                  setState(() {
                    currentUrl =
                        widget.imageUrl +
                        '?retry=${DateTime.now().millisecondsSinceEpoch}';
                  });
                }
              },
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Container(
                    width: min(32.0, widget.height * 0.4),
                    height: min(32.0, widget.height * 0.4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
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
    widget.callWhenLoadingImage?.call();
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
    : super(
        Config(
          key,
          maxNrOfCacheObjects: _getOptimizedCacheSize(),
          stalePeriod: Duration(days: _getOptimizedStalePeriod()),
          // 🔧 إصلاح: إضافة timeout للشبكة
        ),
      );

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
  bool? fromBoutique,
  required double width,
  required double height,
}) {
  if (kDebugMode) print("original image url: $imageUrl");
  if (imageUrl.isEmpty || imageUrl == "null" || imageUrl == "undefined") {
    return imageUrl;
  }

  // 🔧 إصلاح: تحسين معالجة عدم توفر الأبعاد الأصلية
  if (!imageUrl.contains('upload')) {
    return imageUrl;
  }

  int fHeight = 0;
  int fWidth = 0;

  fWidth = (width * 1.5).toInt();
  fHeight = (height * 1.5).toInt();

  List<String> list = imageUrl.split('upload');
  String url = '';
  if (imageUrl.contains('media_server')) {
    if (fromBoutique ?? false) {
      url =
          list[0] +
          'upload/w_${fWidth},c_pad,b_auto/f_auto/q_auto:good/fl_lossy/so_0' +
          list[1];
    } else {
      // الصورة أعرض من الارتفاع - استخدم العرض
      url =
          list[0] +
          'upload/h_${fHeight},w_${fWidth},c_pad,b_auto/f_auto/q_auto:good/fl_lossy/so_0' +
          list[1];
    }

    return url;
  }

  if (fromBoutique ?? false) {
    url = list[0] + 'upload/w_${fWidth},c_fit,f_webp,q_85' + list[1];
  } else if (width > height) {
    // الصورة أعرض من الارتفاع - استخدم العرض
    url =
        list[0] +
        'upload/w_${fWidth},h_${fHeight},c_pad,b_auto,f_webp,q_85' +
        list[1];
  } else {
    // الصورة أطول من العرض - استخدم الارتفاع
    url =
        list[0] +
        'upload/w_${fWidth},h_${fHeight},c_pad,b_auto,f_webp,q_85' +
        list[1];
  }
  //}

  // ⚡ تحسين: تحويل صور Cloudinary إلى WebP مع جودة محسّنة (إذا لم يتم تطبيقه بالفعل)
  if (url.contains('cloudinary.com') && url.contains('/upload/')) {
    // ✅ تحويل إلى WebP format (أصغر حجماً، نفس الجودة)
    if (!url.contains('f_webp')) {
      url = url.replaceFirst('/upload/', '/upload/f_webp,q_85/');
    }
    // ✅ ضبط الجودة إلى 85% (توازن ممتاز بين الحجم والجودة)
    if (!url.contains('q_85') && !url.contains('q_auto')) {
      url = url.replaceFirst('/upload/', '/upload/q_85/');
    }
  }

  return url;
}
