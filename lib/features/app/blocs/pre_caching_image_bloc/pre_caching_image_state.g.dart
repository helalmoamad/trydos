// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_caching_image_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreCachingImageState _$PreCachingImageStateFromJson(
        Map<String, dynamic> json) =>
    PreCachingImageState(
      cachedImages: (json['cachedImages'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$PreCachingImageStateToJson(
        PreCachingImageState instance) =>
    <String, dynamic>{
      'cachedImages': instance.cachedImages,
    };
