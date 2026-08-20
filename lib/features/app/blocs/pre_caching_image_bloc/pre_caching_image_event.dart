part of 'pre_caching_image_bloc.dart';

@immutable
abstract class PreCachingImageEvent {
  const PreCachingImageEvent();
}

class CacheImageEvent extends PreCachingImageEvent {
  final String imageUrl;
  final String type;

  const CacheImageEvent({required this.imageUrl, required this.type});
}

class CacheSvgEvent extends PreCachingImageEvent {
  final String svgUrl;
  final BuildContext context;
  final double? width;
  final double? height;
  final String type;
  const CacheSvgEvent({
    required this.svgUrl,
    required this.type,
    required this.height,
    required this.width,
    required this.context,
  });
}

class SetImageCacheStatusEvent extends PreCachingImageEvent {
  final bool isLoaded;
  final String imageUrl;
  const SetImageCacheStatusEvent({
    required this.isLoaded,
    required this.imageUrl,
  });
}

class RemoveUrlThatNotUsedEvent extends PreCachingImageEvent {
  const RemoveUrlThatNotUsedEvent();
}
