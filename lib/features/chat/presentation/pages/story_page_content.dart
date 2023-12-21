import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/preload_bloc/preloading_videos_event.dart';
import 'package:trydos/features/chat/presentation/manager/preload_bloc/preloading_videos_state.dart';
import 'package:video_player/video_player.dart';

class StoryPageContent extends StatefulWidget {
  const StoryPageContent({Key? key}) : super(key: key);

  @override
  State<StoryPageContent> createState() => _StoryPageContentState();
}

class _StoryPageContentState extends State<StoryPageContent> {

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: BlocBuilder<PreloadingVideosBloc, PreloadingVideosState>(
      builder: (context, state) {
        return SizedBox(
          height: 1.sh-150.h,
          child: PageView.builder(
              itemCount: state.urls.length,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                BlocProvider.of<PreloadingVideosBloc>(context)
                    .add(PreloadPreviousOrNext(index: index));
              },
              itemBuilder: (context, index) {
                return state.focusedIndex == index
                    ? state.controllers[index] == null ?  Center(
                  child: TrydosLoader(),
                ) :AspectRatio(
                    aspectRatio: state.controllers[index]!.value.aspectRatio,
                    child: VideoPlayer(state.controllers[index]!))
                    : const SizedBox.shrink();
              }),
        );
      },
    ));
  }
}
