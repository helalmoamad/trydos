import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:video_player/video_player.dart';

class MYVideoPlayer extends StatefulWidget {
  const MYVideoPlayer({Key? key, this.videoUrl, this.videoFile})
      : super(key: key);
  final String? videoUrl;
  final File? videoFile;

  @override
  State<MYVideoPlayer> createState() => _MYVideoPlayerState();
}

class _MYVideoPlayerState extends State<MYVideoPlayer> {
  late VideoPlayerController _controller;
  Duration? videoDuration;

  @override
  void initState() {
    if (widget.videoFile != null) {
      print('yes from memory');
      _controller = VideoPlayerController.file(widget.videoFile!);
    } else {
      FileSaving().downloadFileToLocalStorage(widget.videoUrl!);
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );
    }
    _controller.initialize().then((value) {
      setState(() {

      });
    });
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getPosition() {
    final Duration duration;
    if (_controller.value.isPlaying) {
      duration = Duration(
          milliseconds: _controller.value.position.inMilliseconds.round());
    } else {
      duration = Duration(
          milliseconds: _controller.value.duration.inMilliseconds.round());
    }

    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':')
        .padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    //print('_initializeVideoPlayerFuture : $_initializeVideoPlayerFuture');
    print('videoUrl : ${widget.videoUrl}');
    print('videoFile : ${widget.videoFile}');
    if (_controller.value.position == _controller.value.duration) {
      _controller.seekTo(Duration.zero);
    }
    // If the VideoPlayerController has finished initialization, use
    // the data it provides to limit the aspect ratio of the video.
    return _controller.value.isInitialized
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              }),
            },
            child: SizedBox(
              height: 400.h,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: VideoPlayer(_controller)),
                  ),
                  _controller.value.isPlaying
                      ? Container()
                      : Icon(Icons.play_arrow,
                          size: 50, color: Colors.grey.shade300),
                  buildSpeed(),
                  Positioned(
                    left: 8,
                    bottom: 38,
                    child: Text(getPosition(),
                        style: context.textTheme.bodyText2?.rr
                            .copyWith(color: Colors.white)),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      height: 16,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                            bufferedColor: Colors.white,
                            playedColor: const Color(0xff388CFF),
                            backgroundColor: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : SizedBox(
            width: 300,
            height: 300,
            child: Center(child: TrydosLoader()),
          );
  }

  Widget buildSpeed() {
    const allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];
    return Positioned(
      bottom: 38,
      right: 8,
      child: PopupMenuButton<double>(
        initialValue: _controller.value.playbackSpeed,
        tooltip: 'Playback speed',
        onSelected: _controller.setPlaybackSpeed,
        itemBuilder: (context) => allSpeeds
            .map<PopupMenuEntry<double>>((speed) => PopupMenuItem(
                  value: speed,
                  child: Text(
                    '${speed}x',
                    style: const TextStyle(
                      color: Color(0xff388CFF),
                    ),
                  ),
                ))
            .toList(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            '${_controller.value.playbackSpeed}x',
            style: const TextStyle(
              color: Color(0xff388CFF),
            ),
          ),
        ),
      ),
    );
  }
}
