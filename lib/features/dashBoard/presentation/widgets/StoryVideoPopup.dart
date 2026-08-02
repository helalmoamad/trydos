import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:video_player/video_player.dart';

class StoryVideoPopup extends StatefulWidget {
  const StoryVideoPopup({super.key, required this.videoUrl, this.thumbnailUrl});

  final String videoUrl;
  final String? thumbnailUrl;

  @override
  State<StoryVideoPopup> createState() => _StoryVideoPopupState();
}

class _StoryVideoPopupState extends State<StoryVideoPopup> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _isDownloading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final file = await _downloadVideoLocally(widget.videoUrl);
      if (!mounted) return;
      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _isReady = true;
      });
      _controller!.play();
      _controller!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _error = 'تعذر تشغيل الفيديو';
      });
    }
  }

  Future<File> _downloadVideoLocally(String url) async {
    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    }

    await dio.download(url, filePath);
    return file;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ✅ الصورة تظهر خلف كل حاجة طول ما الفيديو لسه بيحمّل
          if (!_isReady &&
              widget.thumbnailUrl != null &&
              widget.thumbnailUrl!.isNotEmpty)
            Positioned.fill(
              child: MyCachedNetworkImage(
                imageUrl: widget.thumbnailUrl!,
                width: double.infinity,
                height: double.infinity,
                imageFit: BoxFit.contain,
                fromStory: true,
              ),
            ),

          // محتوى الفيديو
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.white))
          else if (_isReady && _controller != null)
            GestureDetector(
              onTap: () {},
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller!),
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // ✅ overlay شفاف فوق الصورة بيبين إن الفيديو لسه بيتحمّل
            Container(
              color: Colors.black26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  if (_isDownloading) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'جاري تحميل الفيديو...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),

          // زر إغلاق
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),

          if (_isReady && _controller != null)
            Positioned(
              bottom: 40,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                icon: Icon(
                  _controller!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StoryImagePopup extends StatelessWidget {
  const StoryImagePopup({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // خلفية سوداء تسد الشاشة كلها، بتقفل البوب أب عند الضغط عليها
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black, width: 1.sw, height: 1.sh),
          ),

          // الصورة نفسها
          GestureDetector(
            onTap: () {}, // يمنع إغلاق البوب أب عند الضغط على الصورة نفسها
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: MyCachedNetworkImage(
                imageUrl: imageUrl,
                width: 1.sw,
                height: 1.sh,
                imageFit: BoxFit.contain,
                fromStory: true,
              ),
            ),
          ),

          // زر إغلاق
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
