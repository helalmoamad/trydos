import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_image/flutter_svg_image.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_state.dart';

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

  FutureOr<void> _onCacheSvgEvent(
      CacheSvgEvent event, Emitter<PreCachingImageState> emit) async {
    if (await CustomCacheManager().getFileFromCache(event.svgUrl) != null) {
      return;
    }
    if (state.cachehSvgs[event.svgUrl] == true) return;
    Map<String, bool> cachehSvgs = Map.of(state.cachehSvgs);
    cachehSvgs[event.svgUrl] = false;
    emit(PreCachingImageState(cachehSvgs: cachehSvgs));
    await precacheImage(
        SvgImage.cachedNetwork(
          event.svgUrl,
          width: event.width,
          height: event.height,
          cacheManager: CustomCacheManager(),
        ),
        event.context);
    cachehSvgs = Map.of(state.cachehSvgs);
    cachehSvgs[event.svgUrl] = true;
    emit(PreCachingImageState(cachehSvgs: cachehSvgs));
  }

  FutureOr<void> _onCacheImageEvent(
      CacheImageEvent event, Emitter<PreCachingImageState> emit) async {
    if (await CustomCacheManager().getFileFromCache(event.imageUrl) != null) {
      return;
    }
    if (state.cachedImages[event.imageUrl] == true) return;

    Map<String, bool> cachedImages = Map.of(state.cachedImages);

    cachedImages[event.imageUrl] = false;
    emit(PreCachingImageState(cachedImages: cachedImages));
    await precacheImage(
        CachedNetworkImageProvider(event.imageUrl,
            cacheManager: CustomCacheManager()),
        event.context);
    cachedImages = Map.of(state.cachedImages);
    cachedImages[event.imageUrl] = true;

    emit(PreCachingImageState(cachedImages: cachedImages));
  }

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
    for (var i = 0; i < keysImages.length; i++) {
      if (await CustomCacheManager().getFileFromCache(keysImages[i]) == null) {
        cachedImages.removeWhere((key, value) => key == key[i]);
      }
    }
    for (var i = 0; i < keysSvgs.length; i++) {
      if (await CustomCacheManager().getFileFromCache(keysSvgs[i]) == null) {
        cachefSvgs.removeWhere((key, value) => key == key[i]);
      }
    }
    emit(PreCachingImageState(
        cachedImages: cachedImages, cachehSvgs: cachefSvgs));
  }
}
