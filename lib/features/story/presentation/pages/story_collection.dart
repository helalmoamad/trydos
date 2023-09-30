import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:video_player/video_player.dart';

class StoryCollection extends StatefulWidget {
  int id;

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
//      buildWhen:  (previous, current) => previous.getStoriesStatus!=current.getStoriesStatus,
      builder: (context, state) {
        //todo the initial story
        int currentInitialIndex = state.initialStory!;
        List<Story> collectionOfSelectedStory =
            state.stories[state.selectedStory!].stories!;
        var initialStory = collectionOfSelectedStory[currentInitialIndex];

        animatedController = AnimationController(vsync: this);
        pageController = PageController(initialPage: state.initialStory!);
        animatedController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            animatedController.stop();
            animatedController.reset();

            if ((state.initialStory! + 1) >=
                state.stories[state.selectedStory!].stories!.length) {
              GetIt.I<StoryBloc>().add(StorySelectedEvent(
                  selected: state.selectedStory!, initialStory: 0));
            } else {
              GetIt.I<StoryBloc>().add(StorySelectedEvent(
                  selected: state.selectedStory!,
                  initialStory: state.initialStory! + 1));
            }
          }
        });
        return Stack(
          children: [
//          Text('${state.selectedStoriesStatus}'),
//          state.selectedStoriesStatus==SelectedStoriesStatus.success?Text('${state.imageDetail!.width}'):Text('data')
            Positioned(
                top: 40.0,
                left: 10.0,
                right: 10.0,
                child: Column(children: <Widget>[
                  Row(
                    children: collectionOfSelectedStory
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            AnimatedBar(
                              animController: animatedController,
                              position: i,
                              currentIndex: currentInitialIndex,
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                ])),

            () {
              switch (state.getStoriesStatus) {
                case GetStoriesStatus.success:

                  animatedController.duration = const Duration(seconds: 4);
                  animatedController.forward();

                  return GestureDetector(
//onLongPress: () => animatedController.stop(),
                    onTapDown: (details) {
                      final double screenWidth = MediaQuery.of(context).size.width;
                      final double dx = details.globalPosition.dx;
                      if (dx > screenWidth * 2 / 3) {
                        animatedController.stop();
                        animatedController.reset();
                        if ((state.initialStory! + 1) <
                            collectionOfSelectedStory.length) {
                          context.read<StoryBloc>().add(StorySelectedEvent(
                              initialStory: state.initialStory!,
                              selected: state.selectedStory!));
                        } else {
                          context.read<StoryBloc>().add(StorySelectedEvent(
                              initialStory: 0, selected: state.selectedStory!));
                        }
                      } else if (dx < screenWidth * 1 / 3) {
                        animatedController.stop();

                        animatedController.reset();
                        if ((state.initialStory! - 1) > 0) {
                          context.read<StoryBloc>().add(StorySelectedEvent(
                              initialStory: state.initialStory! - 1,
                              selected: state.selectedStory!));
                        } else {
                          context.read<StoryBloc>().add(StorySelectedEvent(
                              initialStory: 0, selected: state.selectedStory!));
                        }
                      }
                    },
                    child: PageView.builder(
                      controller: pageController,
                      itemBuilder: (context, index) {
//todo check whether photo or video and start processing
                        if (initialStory.isPhoto == 1) {
                          return CachedNetworkImage(
                            imageUrl: initialStory.photoPath!,
                            width: state.imageDetail!.width.toDouble(),
                            height: state.imageDetail!.height.toDouble(),
                          );
                        } else {
                          _videoController = null;
                          _videoController?.dispose();
                          _videoController = VideoPlayerController.networkUrl(
                              initialStory.fullVideoPath)
                            ..initialize().then((_) {
//                  setState(() {});
                              if (_videoController!.value.isInitialized) {
                                animatedController.duration =
                                    _videoController!.value.duration;
                                _videoController!.play();
                                animatedController.forward();
                              }
                            });

                          return Text('video');
                        }
                      },
                      itemCount: collectionOfSelectedStory.length,
                    ),
                  )
                  ;
                case GetStoriesStatus.failure:
                  return Text('failed');
                case GetStoriesStatus.loading:
                  return CircularProgressIndicator();
                case GetStoriesStatus.init:
                  // TODO: Handle this case.
                  break;
              }
              return Container();
            }()
          ],
        );
      },
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context1, state) {
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: <Widget>[
                    _buildContainer(
                      double.infinity,
                      position < state.initialStory!
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                    position == state.initialStory
                        ? AnimatedBuilder(
                            animation: animController,
                            builder: (context, child) {
                              return _buildContainer(
                                constraints.maxWidth * animController.value,
                                Colors.white,
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Container _buildContainer(double width, Color color) {
  return Container(
    height: 5.0,
    width: width,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(
        color: Colors.black26,
        width: 0.8,
      ),
      borderRadius: BorderRadius.circular(3.0),
    ),
  );
}
