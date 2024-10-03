import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_state.dart';

import '../../my_cached_network_image.dart';

part 'pre_caching_image_event.dart';
@LazySingleton()
class PreCachingImageBloc
    extends HydratedBloc<PreCachingImageEvent, PreCachingImageState> {
  PreCachingImageBloc() : super(PreCachingImageState()) {
    on<PreCachingImageEvent>((event, emit) {});
    on<CacheImageEvent>(_onCacheImageEvent);
    on<SetImageCacheStatusEvent>(_onSetImageCacheStatusEvent);
  }

  @override
  PreCachingImageState? fromJson(Map<String, dynamic> json) {
    return PreCachingImageState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(PreCachingImageState state) {
    return state.toJson();
  }

  FutureOr<void> _onCacheImageEvent(
      CacheImageEvent event, Emitter<PreCachingImageState> emit) async {
    if(await CustomCacheManager().getFileFromCache(event.imageUrl) != null){
      return ;
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

  _onSetImageCacheStatusEvent(SetImageCacheStatusEvent event, Emitter<PreCachingImageState> emit) {
    if (state.cachedImages.containsKey(event.imageUrl)) return;
    Map<String, bool> cachedImages = Map.of(state.cachedImages);
    cachedImages[event.imageUrl] = event.isLoaded;
    emit(PreCachingImageState(cachedImages: cachedImages));
  }

}
