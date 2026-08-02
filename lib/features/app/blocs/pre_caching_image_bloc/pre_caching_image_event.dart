part of 'pre_caching_image_bloc.dart';

@immutable
abstract class PreCachingImageEvent {
  const PreCachingImageEvent();
}

class CacheImageEvent extends PreCachingImageEvent {
  final String imageUrl;
  final String type;
  final int priority; // 0 = الأعلى أولوية, 1 = متوسط, 2 = منخفض

  const CacheImageEvent({
    required this.imageUrl,
    required this.type,
    this.priority = 1, // القيمة الافتراضية
  });
}
