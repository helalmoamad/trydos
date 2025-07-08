import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sync/semaphore.dart';

import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_state.dart';

import 'package:trydos/main.dart';

import '../../my_cached_network_image.dart';

part 'pre_caching_image_event.dart';

@LazySingleton()
class PreCachingImageBloc
    extends HydratedBloc<PreCachingImageEvent, PreCachingImageState> {
  PreCachingImageBloc() : super(PreCachingImageState()) {
    on<PreCachingImageEvent>((event, emit) {});
    on<CacheImageEvent>(_onCacheImageEvent);
    on<CacheSvgEvent>(_onCacheSvgEvent);
    on<SetImageCacheStatusEvent>(_onSetImageCacheStatusEvent);
    on<RemoveUrlThatNotUsedEvent>(_onRemoveUrlThatNotUsedEvent);
  }

  @override
  PreCachingImageState? fromJson(Map<String, dynamic> json) {
    return PreCachingImageState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(PreCachingImageState state) {
    return state.toJson();
  }

  /*FutureOr<void> _onCacheSvgEvent(
      CacheSvgEvent event, Emitter<PreCachingImageState> emit) async {
    if (await CustomCacheManagers().getFileFromCache(event.svgUrl) != null) {
      return;
    }
    if (state.cachehSvgs[event.svgUrl] == true) return;
    Map<String, bool> cachehSvgs = Map.of(state.cachehSvgs);
    cachehSvgs[event.svgUrl] = false;
    emit(PreCachingImageState(cachehSvgs: cachehSvgs));
    await brandListingImages.acquire();
    await precacheImage(
            SvgImage.cachedNetwork(
              event.svgUrl,
              width: event.width,
              height: event.height,
              cacheManager: CustomCacheManagers(),
            ),
            event.context)
        .then(
      (value) {
        brandListingImages.release();
      },
    ).catchError((e) {
      brandListingImages.release();
    });
    cachehSvgs = Map.of(state.cachehSvgs);
    cachehSvgs[event.svgUrl] = true;
    emit(PreCachingImageState(cachehSvgs: cachehSvgs));
  }

  FutureOr<void> _onCacheImageEvent(
      CacheImageEvent event, Emitter<PreCachingImageState> emit) async {
    if (await CustomCacheManagers().getFileFromCache(event.imageUrl) != null) {
      return;
    }
    if (state.cachedImages[event.imageUrl] == true) return;

    Map<String, bool> cachedImages = state.cachedImages;

    cachedImages[event.imageUrl] = false;
    emit(PreCachingImageState(cachedImages: cachedImages));
    if (event.type == "banner") {
      await imageBanner.acquire();
    } else if (event.type == "categoryBoutique") {
      await imageCategoryBoutiques.acquire();
    } else if (event.type == "syncColorImages") {
      await syncColorImages.acquire();
    } else if (event.type == "productListingImages") {
      await productListingImages.acquire();
    } else if (event.type == "categoryListingImages") {
      await categoryListingImages.acquire();
    } else if (event.type == "productDetailsImages") {
      await productDetailsImages.acquire();
    }
    print(
        "qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqSSSSSSSSSSSSSSSSSSSSSSqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq${event.type}");
    await precacheImage(
            CachedNetworkImageProvider(event.imageUrl,
                cacheManager: CustomCacheManagers()),
            event.context)
        .then(
      (value) {
        print(
            "qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqffffffffffffffffffffffffffffffqqqqqqqqqqqqqqqqqqqqqqqqqqqqq${event.type}");
        if (event.type == "banner") {
          imageBanner.release();
        } else if (event.type == "categoryBoutique") {
          imageCategoryBoutiques.release();
        } else if (event.type == "syncColorImages") {
          syncColorImages.release();
        } else if (event.type == "productListingImages") {
          productListingImages.release();
        } else if (event.type == "categoryListingImages") {
          categoryListingImages.release();
        } else if (event.type == "productDetailsImages") {
          productDetailsImages.release();
        }
      },
    ).catchError((e) {
      if (event.type == "banner") {
        imageBanner.release();
      } else if (event.type == "categoryBoutique") {
        imageCategoryBoutiques.release();
      } else if (event.type == "syncColorImages") {
        syncColorImages.release();
      } else if (event.type == "productListingImages") {
        productListingImages.release();
      } else if (event.type == "categoryListingImages") {
        categoryListingImages.release();
      } else if (event.type == "productDetailsImages") {
        productDetailsImages.release();
      }
    });

    cachedImages[event.imageUrl] = true;

    emit(PreCachingImageState(cachedImages: cachedImages));
  }
*/

  FutureOr<void> _onCacheSvgEvent(
    CacheSvgEvent event,
    Emitter<PreCachingImageState> emit,
  ) async {
    /*
  // 1. التحقق من وجود الملف في الكاش مسبقًا
  final cachedFile = await CustomCacheManagers().getFileFromCache(event.svgUrl);
  if (cachedFile != null) {
    return; // الملف موجود مسبقًا، لا حاجة لإعادة التحميل
  }

  // 2. التحقق من عدم وجود تحميل جارٍ للملف
  if (state.cachehSvgs[event.svgUrl] == true) return;

  // 3. تحديث الحالة لإظهار أن التحميل جارٍ
  final updatedCachehSvgs = Map<String, bool>.from(state.cachehSvgs);
  updatedCachehSvgs[event.svgUrl] = false;
  emit(PreCachingImageState(cachehSvgs: updatedCachehSvgs));

  // 4. التحكم في التزامن باستخدام Semaphore المناسب
  final semaphore = brandListingImages; // أو اختر Semaphore حسب نوع SVG إذا كان لديك

  try {
    await semaphore.acquire();

    // 5. تحميل وتخزين SVG باستخدام CachedNetworkSVGImage.preCache
    await SvgNetworkWidget(
      event.svgUrl,
      cacheManager: CustomCacheManagers(),
      width: event.width,
      height: event.height,
    );

    // 6. تحديث الحالة بعد نجاح التحميل
    final successCachehSvgs = Map<String, bool>.from(updatedCachehSvgs);
    successCachehSvgs[event.svgUrl] = true;
    emit(PreCachingImageState(cachehSvgs: successCachehSvgs));
  } catch (e) {
    print("Error caching SVG: $e");
  } finally {
    semaphore.release();
  }*/
  }

// ============= الدوال المساعدة =============

// أ) تحميل SVG مع عزل محتمل

// ب) معاملات العزل

  FutureOr<void> _onCacheImageEvent(
    CacheImageEvent event,
    Emitter<PreCachingImageState> emit,
  ) async {
    if (!event.imageUrl.contains("cloudinary")) {
      return;
    }

    // منع التحميل إذا كانت الذاكرة ممتلئة أكثر من 90%

    // التحقق من وجود الصورة في الكاش مسبقاً
    try {
      final cachedFile =
          await CustomCacheManagers().getFileFromCache(event.imageUrl);
      if (cachedFile != null) {
        return; // الصورة موجودة مسبقاً
      }
    } catch (e) {
      // في حالة فشل فحص الكاش، نكمل التحميل
    }

    // اختيار Semaphore المناسب حسب نوع الصورة
    //final semaphore = _getSemaphoreForType(event.type);

    try {
      // await semaphore.acquire();

      // ⚡ تحميل غير متزامن مع تجنب blocking الـ UI thread
      _precacheImageSafely(event);
    } catch (e) {
      //  semaphore.release();
      debugPrint("Error starting image cache: $e");
    }
  }

  /// تحميل آمن للصور بدون تأثير على UI thread
  void _precacheImageSafely(CacheImageEvent event) async {
    try {
      // ⚡ استخدام Future.microtask لنقل العملية خارج UI thread
      await Future.microtask(() async {
        await precacheImage(
          CachedNetworkImageProvider(
            event.imageUrl,
            headers: {
              'User-Agent': (kDebugMode ? "developer" : "users") +
                  'device OS:' +
                  (Platform.isAndroid ? 'Android' : 'IOS') +
                  ' , application version: 1.0.0',
              "Referer": (kDebugMode ? "developer" : "users") +
                  'device OS:' +
                  (Platform.isAndroid ? 'Android' : 'IOS')
            },
            cacheManager: CustomCacheManagers(),
          ),
          event.context,
        );
      });

      debugPrint('✅ Successfully cached: ${event.type}');
    } catch (e) {
      debugPrint("Error caching image: $e");
    } finally {
      //  semaphore.release();
    }
  }

// دالة اختيار Semaphore حسب نوع الصورة (كما لديك)
  /* Semaphore _getSemaphoreForType(String type) {
    switch (type) {
      case "banner":
        return imageBanner;
      case "categoryBoutique":
        return imageCategoryBoutiques;
      case "syncColorImages":
        return syncColorImages;
      case "productListingImages":
        return productListingImages;
      case "categoryListingImages":
        return categoryListingImages;
      case "productDetailsImages":
        return productDetailsImages;
      default:
        throw Exception("Unknown image type");
    }
  }
*/
// ج) معاملات العزل

// د) الدالة المعزولة

  _onSetImageCacheStatusEvent(
      SetImageCacheStatusEvent event, Emitter<PreCachingImageState> emit) {
    if (state.cachedImages.containsKey(event.imageUrl)) return;
    Map<String, bool> cachedImages = Map.of(state.cachedImages);
    cachedImages[event.imageUrl] = event.isLoaded;
    emit(PreCachingImageState(cachedImages: cachedImages));
  }

  _onRemoveUrlThatNotUsedEvent(RemoveUrlThatNotUsedEvent event,
      Emitter<PreCachingImageState> emit) async {
    Map<String, bool> cachedImages = Map.of(state.cachedImages);
    Map<String, bool> cachefSvgs = Map.of(state.cachehSvgs);
    List<String> keysImages = cachedImages.keys.toList();
    List<String> keysSvgs = cachefSvgs.keys.toList();

    try {
      for (var i = 0; i < keysImages.length; i++) {
        if (await CustomCacheManagers().getFileFromCache(keysImages[i]) ==
            null) {
          cachedImages.removeWhere((key, value) => key == key[i]);
        }
      }
      for (var i = 0; i < keysSvgs.length; i++) {
        if (await CustomCacheManagers().getFileFromCache(keysSvgs[i]) == null) {
          cachefSvgs.removeWhere((key, value) => key == key[i]);
        }
      }
    } catch (e) {}
    emit(PreCachingImageState(
        cachedImages: cachedImages, cachehSvgs: cachefSvgs));
  }
}
