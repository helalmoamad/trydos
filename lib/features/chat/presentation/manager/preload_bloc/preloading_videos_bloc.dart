


import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/presentation/manager/preload_bloc/preloading_videos_event.dart';
import 'package:trydos/features/chat/presentation/manager/preload_bloc/preloading_videos_state.dart';
import 'package:video_player/video_player.dart';

@injectable
class PreloadingVideosBloc extends Bloc<PreloadingVideosEvent ,PreloadingVideosState> {
  PreloadingVideosBloc() : super(PreloadingVideosState()) {
    on<PreloadingVideosEvent>((event, emit) {});
    
    on<PreloadInitialization>(_onPreloadInitialization);
    on<PreloadPreviousOrNext>(_onPreloadPreviousOrNext);
  }

  FutureOr<void> _onPreloadInitialization(PreloadInitialization event, Emitter<PreloadingVideosState> emit)async {
    Map<int, VideoPlayerController> controllers;
    /// Initialize 1st video
    controllers = await _initializeControllerAtIndex(0);
    emit(state.copyWith(controllers: controllers));
    /// Play 1st video
    _playControllerAtIndex(0);
    /// Initialize 2nd vide
    controllers = await _initializeControllerAtIndex(1);
    emit(state.copyWith(controllers: controllers));
  }


  FutureOr<void> _onPreloadPreviousOrNext(PreloadPreviousOrNext event, Emitter<PreloadingVideosState> emit) async{
    if (event.index > state.focusedIndex) {
      _playNext(event.index);
    } else {
      _playPrevious(event.index);
    }
     emit(state.copyWith(focusedIndex: event.index));
  }

  void _playNext(int index) async{
    Map<int, VideoPlayerController> controllers;
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);
    /// Dispose [index - 2] controller
    controllers = _disposeControllerAtIndex(index - 2);
    emit(state.copyWith(controllers: controllers));
    /// Play current video (already initialized)
    _playControllerAtIndex(index);
    /// Initialize [index + 1] controller
    controllers = await _initializeControllerAtIndex(index + 1);
    emit(state.copyWith(controllers: controllers));
  }


  void _playPrevious(int index)async {
    Map<int, VideoPlayerController> controllers;
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);
    /// Dispose [index + 2] controller
    controllers = _disposeControllerAtIndex(index + 2);
    emit(state.copyWith(controllers: controllers));
    /// Play current video (already initialized)
    _playControllerAtIndex(index);
    /// Initialize [index - 1] controller
    controllers = await _initializeControllerAtIndex(index - 1);
    emit(state.copyWith(controllers: controllers));
  }

   _initializeControllerAtIndex(int index) async {
    Map<int, VideoPlayerController> controllers=Map.of(state.controllers);
    if (state.urls.length > index && index >= 0) {
      /// Create new controller
      final VideoPlayerController controller =
      VideoPlayerController.networkUrl(Uri.parse(state.urls[index]));
      /// Add to [controllers] list
      controllers[index] = controller;
      /// Initialize
      await controller.initialize();
      log('🚀🚀🚀 INITIALIZED $index');
    }
    return controllers;
  }
  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController controller = state.controllers[index]!;
      /// Play controller
      controller.play();
      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController controller = state.controllers[index]!;
      /// Pause
      controller.pause();
      /// Reset postiton to beginning
      controller.seekTo(const Duration());
      log('🚀🚀🚀 STOPPED $index');
    }
  }
  Map<int, VideoPlayerController> _disposeControllerAtIndex(int index) {
    Map<int, VideoPlayerController> controllers=Map.of(state.controllers);
    if (state.urls.length > index && index >= 0) {
      /// Get controller at controller
      final VideoPlayerController controller = state.controllers[index]!;
      /// Dispose controller
      controller.dispose();
      controllers.remove(controller);
      log('🚀🚀🚀 DISPOSED $index');
    }
    return controllers;
  }

}
