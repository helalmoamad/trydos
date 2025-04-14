import 'dart:async';

import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/trydos_shimmer_loading.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
      Timer.periodic(Duration(seconds: 3), (timer) {
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
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return FutureBuilder(
        future: initializeVideo,
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => {},
              child: Stack(
                children: [
                  Container(
                    width: 135.w,
                    height: 194,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.white),
                      borderRadius: BorderRadius.circular(30.0.r),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.black.withOpacity(0.1),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0.r),
                        child: VideoPlayer(_controller!)),
                  ),
                  Container(
                    height: 194,
                    width: 135.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0.r),
                      boxShadow: [
                        BoxShadow(
                            color: colorScheme.white,
                            offset: Offset(0, 3),
                            blurRadius: 3,
                            inset: true),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return TrydosShimmerLoading(
            width: 135.w,
            height: 194,
            radius: 30.r,
            logoTextHeight: 14,
            logoTextWidth: 48.w,
          );
        });
  }
}
