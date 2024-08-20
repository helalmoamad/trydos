import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:video_player/video_player.dart';

import 'my_text_widget.dart';
import 'video_player_full.dart';

class MYVideoPlayer extends StatefulWidget {
  const MYVideoPlayer(
      {Key? key, this.videoUrl, this.videoFile, required this.chatId})
      : super(key: key);
  final String? videoUrl;
  final File? videoFile;
  final String chatId;

  @override
  State<MYVideoPlayer> createState() => _MYVideoPlayerState();
}

class _MYVideoPlayerState extends State<MYVideoPlayer> {
  VideoPlayerController? _controller;
  Duration? videoDuration;
  String? imageUrl;

  late Future<void> initializeVideo;
  ValueNotifier<double> downloadingProgress = ValueNotifier(0);
  ValueNotifier<bool> isDownloading = ValueNotifier(false);
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    if (widget.videoUrl != null) {
      imageUrl = widget.videoUrl!
              .replaceFirst(widget.videoUrl!.split('.').last, 'JPG') +
          '?w=300&h=300';
    }
    if (widget.videoFile != null) {
      debugPrint('yes from memory');
      _controller = VideoPlayerController.file(widget.videoFile!);
      initializeController();
    }
    super.initState();
  }

  void initializeController() {
    initializeVideo = _controller!.initialize().then((value) {
      setState(() {});
    });
    _controller!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String getPosition() {
    final Duration duration;
    if (_controller!.value.isPlaying) {
      duration = Duration(
          milliseconds: _controller!.value.position.inMilliseconds.round());
    } else {
      duration = Duration(
          milliseconds: _controller!.value.duration.inMilliseconds.round());
    }

    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':')
        .padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    if (_controller?.value.position == _controller?.value.duration) {
      _controller?.seekTo(Duration.zero);
    }
    // If the VideoPlayerController has finished initialization, use
    // the data it provides to limit the aspect ratio of the video.
    return imageUrl != null && _controller == null
        ? SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 200,
                  height: 300,
                ),
                ValueListenableBuilder<bool>(
                    valueListenable: isDownloading,
                    builder: (context, downloading, _) {
                      return !downloading
                          ? InkWell(
                              onTap: () {
                                isDownloading.value = true;
                                FileSaving().downloadFileUsingDio(
                                    widget.videoUrl!,
                                    cancelToken,
                                    widget.chatId, (progress) {
                                  downloadingProgress.value = progress;
                                }, action: (File file) {
                                  _controller =
                                      VideoPlayerController.file(file);
                                  initializeController();
                                });
                              },
                              child: Icon(Icons.play_arrow,
                                  size: 50, color: Colors.grey.shade300),
                            )
                          : ValueListenableBuilder<double>(
                              valueListenable: downloadingProgress,
                              builder: (context, progress, _) {
                                debugPrint('progress: $progress');
                                return InkWell(
                                  onTap: () {
                                    isDownloading.value = false;
                                    cancelToken.cancel();
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: progress / 100,
                                        strokeWidth: 5,
                                        backgroundColor: Colors.grey,
                                        color: Color(0xff388CFF),
                                      ),
                                      MyTextWidget(
                                        'X',
                                        style: context.textTheme.bodyLarge?.ba
                                            .copyWith(
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                    }),
              ],
            ),
          )
        : FutureBuilder(
            future: initializeVideo,
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => {
                    setState(() {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MYVideoPlayerFull(
                          chatId: widget.chatId,
                          videoFile: widget.videoFile,
                          videoUrl: widget.videoUrl,
                          key: widget.key,
                        ),
                      ));
                    }),
                  },
                  child: SizedBox(
                    height: 400.h,
                    width: 250.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 1.sw,
                          height: 1.sh,
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            // Use the VideoPlayer widget to display the video.
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: VideoPlayer(_controller!)),
                          ),
                        ),
                        _controller!.value.isPlaying
                            ? Container()
                            : Icon(Icons.play_arrow,
                                size: 50, color: Colors.grey.shade300),
                        Positioned(
                          left: 8,
                          bottom: 25,
                          child: MyTextWidget(getPosition(),
                              style: context.textTheme.titleLarge?.rr
                                  .copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox(
                width: 300,
                height: 300,
                child: Center(child: TrydosLoader()),
              );
            });
  }
}
