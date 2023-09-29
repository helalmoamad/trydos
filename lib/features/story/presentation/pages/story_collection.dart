import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:video_player/video_player.dart';

class StoryCollection extends StatefulWidget {
  int id ;
  @override
  State<StoryCollection> createState() => _StoryCollectionState();

  StoryCollection(this.id);
}

class _StoryCollectionState extends State<StoryCollection>
    with TickerProviderStateMixin {
  late VideoPlayerController? _videoController;
  late PageController pageController;
  late AnimationController animatedController;

  @override
  void dispose() {
    pageController.dispose();
    animatedController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      buildWhen:  (previous, current) => previous.getStoriesStatus!=current.getStoriesStatus,
      builder: (context, state) {
        if(state.selectedStoriesStatus ==SelectedStoriesStatus.loading)
          return Text('${state.getStoriesStatus}');
        if(state.selectedStoriesStatus==SelectedStoriesStatus.success)
          return Text('${state.imageDetail!.width}');
        return Text('');
      },
    );
  }
}
