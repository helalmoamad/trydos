import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_state.dart';
import '../../my_cached_network_image.dart';

part 'pre_caching_image_event.dart';

/// كلاس داخلي لربط الـ Completer بالأولوية
class _PrecacheTask {
  final Completer<void> completer;
  final int priority;

  _PrecacheTask({required this.completer, required this.priority});
}

@LazySingleton()
class PreCachingImageBloc
    extends Bloc<PreCachingImageEvent, PreCachingImageState> {
  PreCachingImageBloc() : super(const PreCachingImageState()) {
    on<CacheImageEvent>(_onCacheImageEvent);
  }

  static const int _maxConcurrentPrecache = 3;
  int _activePrecache = 0;

  // قائمة انتظار مهيكلة بحسب الأولويات
  final List<_PrecacheTask> _precacheQueue = <_PrecacheTask>[];

  Future<void> _acquirePrecacheSlot(int priority) async {
    if (_activePrecache < _maxConcurrentPrecache) {
      _activePrecache++;
      return;
    }

    final Completer<void> waiter = Completer<void>();
    _precacheQueue.add(_PrecacheTask(completer: waiter, priority: priority));

    // ترتيب القائمة دائماً: الأقل رقماً (0) يكون في المقدمة (index 0)
    _precacheQueue.sort((a, b) => a.priority.compareTo(b.priority));

    await waiter.future;
  }

  void _releasePrecacheSlot() {
    if (_precacheQueue.isNotEmpty) {
      // إخراج العنصر ذو الأولوية الأعلى (الموجود في رأس القائمة)
      final task = _precacheQueue.removeAt(0);
      task.completer.complete();
    } else if (_activePrecache > 0) {
      _activePrecache--;
    }
  }

  Future<void> _onCacheImageEvent(
    CacheImageEvent event,
    Emitter<PreCachingImageState> emit,
  ) async {
    // 1. الفلترة السريعة للروابط
    if (!event.imageUrl.contains("cloudinary") &&
        !event.imageUrl.contains("media_server")) {
      return;
    }

    try {
      // 2. الفحص من التخزين المحلي
      final cachedFile = await CustomCacheManagers().getFileFromCache(
        event.imageUrl,
      );
      if (cachedFile != null) return;

      // 3. التنزيل مع الاهتمام برقم الأولوية
      await _warmDiskCache(event.imageUrl, event.priority);
    } catch (e) {
      debugPrint("Error checking image cache: $e");
    }
  }

  Future<void> _warmDiskCache(String url, int priority) async {
    // حجز المكان بناءً على الأولوية
    await _acquirePrecacheSlot(priority);
    try {
      final String userAgent =
          (kDebugMode ? "developer" : "users") +
          'device OS:' +
          (Platform.isAndroid ? 'Android' : 'IOS') +
          ' , application version: 1.0.0';

      final String referer =
          (kDebugMode ? "developer" : "users") +
          'device OS:' +
          (Platform.isAndroid ? 'Android' : 'IOS');

      await CustomCacheManagers().downloadFile(
        url,
        authHeaders: {'User-Agent': userAgent, 'Referer': referer},
      );
    } catch (e) {
      debugPrint("Error warming disk cache for $url: $e");
    } finally {
      _releasePrecacheSlot();
    }
  }
}
