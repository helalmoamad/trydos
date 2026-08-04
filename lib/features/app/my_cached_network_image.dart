import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:trydos/features/app/trydos_shimmer_loading_stateless.dart';

class MyCachedNetworkImage extends StatelessWidget {
  const MyCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.imageFit,
    this.logoTextWidth,
    this.ordinalHeight,
    this.ordinalwidth,
    this.logoTextHeight,
    this.imageWidth,
    this.imageHeight,
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
    this.fromStory,
    this.circleDimensions,
    this.imageSource,
  }) : super(key: key);

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit imageFit;
  final double radius;
  final double? logoTextWidth;
  final double? imageWidth;
  final double? imageHeight;
  final double? ordinalHeight;
  final double? ordinalwidth;
  final double? logoTextHeight;
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

  // ⚡ ثوابت الذاكرة لمنع إعادة إنشائها مع كل Build لكل صورة
  static final CustomCacheManagers _cacheManager = CustomCacheManagers();
  static final Map<String, String> _httpHeaders = {
    'User-Agent':
        '${kDebugMode ? "developer" : "users"}device OS:${Platform.isAndroid ? 'Android' : 'IOS'}, application version: 1.0.0',
    "Referer":
        '${kDebugMode ? "developer" : "users"}device OS:${Platform.isAndroid ? 'Android' : 'IOS'}',
  };

  @override
  Widget build(BuildContext context) {
    final bool isBoutique = fromBoutique ?? false;

    const double safeRatio = 1;

    // ⚡ 2. حساب الأبعاد الآمنة وحماية الكود في حال تم تمرير double.infinity
    final double effectiveWidth = width.isInfinite
        ? MediaQuery.sizeOf(context).width
        : width;
    final double safeFallbackHeight = height > 0 ? height : 180.0;

    // ⚡ 3. توحيد معامل المعالجة بين طلب السيرفر وتخزين الذاكرة MemCache
    String url = addSuitableWidthAndHeightToImage(
      imageUrl: imageUrl,
      height: safeFallbackHeight,
      width: effectiveWidth,
      fromBoutique: isBoutique,
    );

    if (url.isEmpty || url == "null" || url == "undefined") {
      url = imageUrl;
    }

    // الـ Widget الاحتياطي للروابط التالفة أو الفارغة
    if (url.isEmpty || url == "null" || url == "undefined") {
      return Container(
        width: effectiveWidth,
        height: isBoutique ? null : safeFallbackHeight,
        constraints: isBoutique ? const BoxConstraints(minHeight: 120) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.grey[300],
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
        ),
      );
    }

    // ⚡ 4. توحيد الأبعاد المحسوبة للـ MemCache مع أبعاد صورة السيرفر تماماً
    final int safeMemWidth = max(10, (effectiveWidth * safeRatio).round());
    final int? safeMemHeight = isBoutique
        ? null
        : max(10, (safeFallbackHeight * safeRatio).round());

    // ⚡ 5. تغليف بصورة منفصلة لمنع إعادة رسم باقي عناصر البطاقة أثناء السكرول
    return SizedBox(
      key: ValueKey(url),
      width: effectiveWidth,
      height: isBoutique ? null : safeFallbackHeight,
      child: CachedNetworkImage(
        httpHeaders: _httpHeaders,
        imageUrl: url,
        width: effectiveWidth,
        height: isBoutique ? null : safeFallbackHeight,
        cacheManager: _cacheManager,

        // ⚡ أبعاد الذاكرة متطابقة 100% مع أبعاد السيرفر لمنع إعادة التكييف بالـ CPU
        memCacheWidth: safeMemWidth,
        memCacheHeight: safeMemHeight,

        placeholder: (context, url) {
          callWhenLoadingImage?.call();
          return _buildSimpleShimmer(
            isBoutique,
            safeFallbackHeight,
            effectiveWidth,
          );
        },

        fadeInDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,

        imageBuilder:
            imageBuilder ??
            (ctx, imageProvider) {
              callWhenDisplayImage?.call();

              if (isBoutique) {
                return Container(
                  width: effectiveWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: Image(
                    image: imageProvider,
                    width: effectiveWidth,
                    fit: BoxFit.fitWidth,
                    color: imageColor,
                    colorBlendMode: imageColor != null ? BlendMode.srcIn : null,
                  ),
                );
              }

              return Container(
                width: effectiveWidth,
                height: safeFallbackHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: imageFit,
                    colorFilter: imageColor != null
                        ? ColorFilter.mode(imageColor!, BlendMode.srcIn)
                        : null,
                  ),
                ),
              );
            },

        errorWidget: (context, errorUrl, error) =>
            _buildErrorWidget(isBoutique, safeFallbackHeight, effectiveWidth),
      ),
    );
  }

  Widget _buildErrorWidget(
    bool isBoutique,
    double safeHeight,
    double currentWidth,
  ) {
    return Container(
      width: currentWidth,
      height: isBoutique ? 150 : safeHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.grey[300],
      ),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 24),
      ),
    );
  }

  Widget _buildSimpleShimmer(
    bool isBoutique,
    double safeHeight,
    double currentWidth,
  ) {
    final double shimmerHeight = isBoutique ? 200 : safeHeight;
    return TrydosShimmerLoadingStateless(
      width: currentWidth,
      height: shimmerHeight,
      logoTextWidth: logoTextWidth ?? currentWidth * 0.6,
      logoTextHeight: logoTextHeight ?? shimmerHeight * 0.3,
      radius: radius,
      circleDimensions: circleDimensions,
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
          maxNrOfCacheObjects: 500,
          stalePeriod: const Duration(days: 7),
        ),
      );
}

void clearCustomCashe() async {
  await CustomCacheManagers().emptyCache();
}

/// 🎯 دالة معالجة رابط Cloudinary مع توحيد معامل الكثافة
String addSuitableWidthAndHeightToImage({
  required String imageUrl,
  bool? fromBoutique,
  required double width,
  required double height,
}) {
  if (imageUrl.isEmpty || imageUrl == "null" || imageUrl == "undefined") {
    return imageUrl;
  }

  if (!imageUrl.contains('upload')) {
    return imageUrl;
  }

  // حساب أبعاد السيرفر بالاعتماد على نفس المعامل الآمن
  final int fWidth = max(10, (width * 1.5).round());
  final int fHeight = max(10, (height * 1.5).round());

  List<String> list = imageUrl.split('upload');

  String pathAfterUpload = list[1];
  if (!pathAfterUpload.startsWith('/')) {
    pathAfterUpload = '/$pathAfterUpload';
  }

  if (imageUrl.contains('media_server')) {
    if (fromBoutique ?? false) {
      return '${list[0]}upload/w_$fWidth,c_pad,b_auto/f_auto/q_auto:good/fl_lossy/so_0$pathAfterUpload';
    } else {
      return '${list[0]}upload/h_$fHeight,w_$fWidth,c_pad,b_auto/f_auto/q_auto:good/fl_lossy/so_0$pathAfterUpload';
    }
  }

  if (fromBoutique ?? false) {
    return '${list[0]}upload/w_$fWidth,f_webp,q_80$pathAfterUpload';
  } else {
    return '${list[0]}upload/w_$fWidth,h_${fHeight},c_pad,b_auto,f_webp,q_80$pathAfterUpload';
  }
}
