import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;

import 'package:flutter/material.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_state.dart';

import '../../my_cached_network_image.dart';

part 'pre_caching_image_event.dart';

@LazySingleton()
class PreCachingImageBloc
    extends HydratedBloc<PreCachingImageEvent, PreCachingImageState> {
  PreCachingImageBloc() : super(const PreCachingImageState()) {
    on<PreCachingImageEvent>((event, emit) {});
    on<CacheImageEvent>(_onCacheImageEvent);
    on<CacheSvgEvent>(_onCacheSvgEvent);
    on<SetImageCacheStatusEvent>(_onSetImageCacheStatusEvent);
    on<RemoveUrlThatNotUsedEvent>(_onRemoveUrlThatNotUsedEvent);
  }

  /// أقصى عدد عمليات تخزين مسبق متزامنة.
  ///
  /// كان الاستدعاء بلا `await` وبلا سيمافور (السيمافورات معلَّقة في main.dart)،
  /// فيبدأ تحميل وفكّ ترميز **كل** صورة فور وصول حدثها. وعند تمرير قائمة
  /// منتجات تصل عشرات الأحداث معاً، فيمتلئ `imageCache` وتُخلى منه صور معروضة
  /// على الشاشة الآن — فتُعاد قراءتها وفكّ ترميزها، وهو تقطيع مباشر.
  ///
  /// التخزين المسبق بلا حدّ يضرّ أكثر ممّا ينفع.
  static const int _maxConcurrentPrecache = 9;
  int _activePrecache = 0;
  final List<Completer<void>> _precacheQueue = <Completer<void>>[];

  Future<void> _acquirePrecacheSlot() {
    if (_activePrecache < _maxConcurrentPrecache) {
      _activePrecache++;
      return Future<void>.value();
    }
    final Completer<void> waiter = Completer<void>();
    _precacheQueue.add(waiter);
    return waiter.future;
  }

  void _releasePrecacheSlot() {
    if (_precacheQueue.isNotEmpty) {
      _precacheQueue.removeAt(0).complete(); // ينتقل المقعد دون تصفير العدّاد
    } else if (_activePrecache > 0) {
      _activePrecache--;
    }
  }

  @override
  PreCachingImageState? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(PreCachingImageState state) => null;

  FutureOr<void> _onCacheSvgEvent(
    CacheSvgEvent event,
    Emitter<PreCachingImageState> emit,
  ) async {}

  FutureOr<void> _onCacheImageEvent(
    CacheImageEvent event,
    Emitter<PreCachingImageState> emit,
  ) async {
    if (kDebugMode)
      print("CCCCCCCCCCCCCCCCCCCCCCC${event.imageUrl}//${event.type}");
    if (!event.imageUrl.contains("cloudinary") &&
        !event.imageUrl.contains("media_server")) {
      return;
    }

    try {
      final cachedFile = await CustomCacheManagers().getFileFromCache(
        event.imageUrl,
      );
      if (cachedFile != null) {
        return; // الصورة موجودة مسبقاً
      }
    } catch (e) {
      // في حالة فشل فحص الكاش، نكمل التحميل
    }

    _warmDiskCache(event);
  }

  /// تدفئة كاش القرص لصورة لم يرَها المستخدم بعد — **بلا فكّ ترميز**.
  ///
  /// كان هنا `precacheImage`، وهو يفعل شيئين: ينزّل **ويفكّ الترميز** إلى
  /// `imageCache`. والثاني ضارّ في التخزين المسبق: صور قد لا يصلها المستخدم
  /// تزاحم الصور المعروضة على ميزانية واحدة (١٠٠ ميغابايت افتراضياً)، فتُخلى
  /// المعروضة وتُعاد قراءتها — وهو تقطيع مباشر.
  ///
  /// `downloadFile` ينزّل البايتات إلى القرص فقط. والبطيء في العملية هو الشبكة
  /// (مئات الملّي ثانية) لا فكّ الترميز من ملف محلي، فتبقى فائدة التدفئة كاملة
  /// بجزء يسير من الكلفة.
  ///
  /// وفكّ الترميز يقع عند العرض بالمقاس الصحيح عبر `MyCachedNetworkImage`
  /// التي تضبط `memCacheWidth`/`memCacheHeight` أصلاً.
  ///
  /// ولا يحتاج `BuildContext` بخلاف `precacheImage` — فينتفي خطر استعماله بعد
  /// تفكيكه.
  void _warmDiskCache(CacheImageEvent event) async {
    await _acquirePrecacheSlot();
    try {
      await CustomCacheManagers().downloadFile(
        event.imageUrl,
        authHeaders: {
          'User-Agent':
              (kDebugMode ? "developer" : "users") +
              'device OS:' +
              (Platform.isAndroid ? 'Android' : 'IOS') +
              ' , application version: 1.0.0',
          "Referer":
              (kDebugMode ? "developer" : "users") +
              'device OS:' +
              (Platform.isAndroid ? 'Android' : 'IOS'),
        },
      );
    } catch (e) {
      debugPrint("Error warming disk cache: $e");
    } finally {
      _releasePrecacheSlot();
    }
  }

  _onSetImageCacheStatusEvent(
    SetImageCacheStatusEvent event,
    Emitter<PreCachingImageState> emit,
  ) {
    if (state.cachedImages.containsKey(event.imageUrl)) return;
    Map<String, bool> cachedImages = Map.of(state.cachedImages);
    cachedImages[event.imageUrl] = event.isLoaded;
    emit(state.copyWith(cachedImages: cachedImages));
  }

  _onRemoveUrlThatNotUsedEvent(
    RemoveUrlThatNotUsedEvent event,
    Emitter<PreCachingImageState> emit,
  ) async {
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
    emit(
      PreCachingImageState(cachedImages: cachedImages, cachehSvgs: cachefSvgs),
    );
  }
}
