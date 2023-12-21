import 'package:video_player/video_player.dart';

enum SaveContactsStatus { init, loading, success, failure }

class PreloadingVideosState {
  PreloadingVideosState(
      {this.controllers = const {},
      this.urls = const [
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#1',
        'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
        'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
        'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
      ],
      this.focusedIndex = 0});

  final Map<int, VideoPlayerController> controllers;
  final List<String> urls;
  final int focusedIndex;

  PreloadingVideosState copyWith(
      {final Map<int, VideoPlayerController>? controllers,
      final List<String>? urls,
      final int? focusedIndex}) {
    return PreloadingVideosState(
      focusedIndex: focusedIndex ?? this.focusedIndex,
      urls: urls ?? this.urls,
      controllers: controllers ?? this.controllers,
    );
  }
}
