import 'dart:async';

import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:video_player/video_player.dart';

/// 🚀 نسخة مبسطة جداً من ProductListing3DSlider - أداء فائق ⚡
class ProductVedio extends StatefulWidget {
  const ProductVedio({
    super.key,
    this.videoSource,
    this.imageSource,
  });

  final String? videoSource;
  final String? imageSource;

  @override
  State<ProductVedio> createState() => _ProductVedioState();
}

class _ProductVedioState extends State<ProductVedio> {
  Timer? disDebounce;
  late VideoPlayerController videoProductInListingController;
  Future<void>? _initializeVideoFuture;
  late VoidCallback _videoListener;

  @override
  void initState() {
    super.initState();
    if (widget.videoSource != null && widget.videoSource!.isNotEmpty) {
      videoProductInListingController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoSource!),
        videoPlayerOptions: VideoPlayerOptions(),
      )..setLooping(true);
      _initializeVideoFuture =
          videoProductInListingController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        // videoProductInListingController.setVolume(0);
        videoProductInListingController.play();
      });

      _videoListener = () {
        if (!mounted) return;
        setState(() {});
      };
      videoProductInListingController.addListener(_videoListener);
    }
  }

  @override
  void dispose() {
    // إزالة المستمع قبل التخلص
    if (widget.videoSource != null && widget.videoSource!.isNotEmpty) {
      videoProductInListingController.removeListener(_videoListener);
      if (videoProductInListingController.value.isInitialized) {
        videoProductInListingController.pause();
      }
      videoProductInListingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _buildVideoBox(widget.imageSource ?? ""),
    );
  }

  Widget _buildVideoBox(String imageUrl) {
    return Container(
        height: 200,
        child: FutureBuilder<void>(
          future: _initializeVideoFuture,
          builder: (context, snapshot) {
            final bool initialized =
                videoProductInListingController.value.isInitialized;
            final bool buffering =
                videoProductInListingController.value.isBuffering;
            final bool showLoading = !initialized;

            Widget videoChild;
            if (initialized) {
              videoChild = FittedBox(
                  fit: BoxFit.cover,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        width: 138,
                        height: 200,
                        child: VideoPlayer(videoProductInListingController),
                      )));
            } else {
              videoChild = const SizedBox.shrink();
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                videoChild,
                if (showLoading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ProductListingImageWidget(
                      orginalHeight: 200,
                      orginalWidth: 200,
                      width: 138,
                      imageUrl: imageUrl,
                      height: 200,
                      circleShape: false,
                      innerShadowYOffset: 3,
                    ),
                  ),
                SizedBox(
                    width: 76,
                    height: 20,
                    child: Text("${LocaleKeys.quick_video.tr()}",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.br.copyWith(
                          fontSize: 13,
                          color: const Color(0xffFFFFFF),
                        ))),
                buffering
                    ? TrydosLoader(
                        size: 20,
                      )
                    : const SizedBox.shrink()
              ],
            );
          },
        ));
  }
}
