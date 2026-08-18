import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/trydos_shimmer_loading.dart';

class ProductStoryVideoItem extends StatefulWidget {
  const ProductStoryVideoItem({super.key, required this.videoUrl});

  final String videoUrl;
  @override
  State<ProductStoryVideoItem> createState() => _ProductStoryVideoItemState();
}

class _ProductStoryVideoItemState extends State<ProductStoryVideoItem> {
  late Future<void> initializeVideo;
  VideoPlayerController? _controller;
  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    initializeController();
    super.initState();
  }

  void initializeController() {
    initializeVideo = _controller!.initialize().then((value) {
      Timer.periodic(const Duration(seconds: 3), (timer) {
        _controller!.setVolume(0);
        _controller!.seekTo(Duration.zero);
        _controller!.play();
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeVideo,
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => {},
            child: Container(
              width: 135.w,
              height: 194.h,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.white),
                borderRadius: BorderRadius.circular(30.0.r),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: colorScheme.black.withOpacity(0.1),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              // التوهّج الأبيض على الحافة العليا. كان صندوقاً ثانياً في Stack
              // يحمل BoxShadow(inset: true)، وهي تُرسم بـ drawDRRect مع
              // MaskFilter.blur — خارج المسار السريع في Impeller. وبما أنه كان
              // شقيقاً لـ VideoPlayer بلا RepaintBoundary فقد كان يُعاد رسمه
              // بمعدّل إطارات الفيديو. التدرّج رسمة واحدة بلا ضبابية.
              // (الصندوق المحذوف كان يستعمل 194 خاماً بدل 194.h فلا يطابق
              // ارتفاع الفيديو على الشاشات المختلفة.)
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.white,
                    // withAlpha(0) لا Colors.transparent: الأخير أسود شفاف
                    // فينتج حافة رمادية عند الاستيفاء
                    colorScheme.white.withAlpha(0),
                  ],
                  // الإزاحة 3 + نصف قطر الضبابية 3 = نفس منطقة الظل السابق
                  stops: [0.0, (6 / 194.h).clamp(0.0, 1.0)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0.r),
                child: VideoPlayer(_controller!),
              ),
            ),
          );
        }
        return TrydosShimmerLoading(
          width: 135.w,
          height: 194.h,
          radius: 30.r,
          logoTextHeight: 14.h,
          logoTextWidth: 48.w,
        );
      },
    );
  }
}
