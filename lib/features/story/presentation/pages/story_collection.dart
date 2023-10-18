import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../config/theme/typography.dart';
import 'package:trydos/service/language_service.dart';

//import 'package:dartz/dartz_streaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/no_image_widget.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../widget/animated_builder.dart';

class StoryCollection extends StatefulWidget {
  int id;

  @override
  State<StoryCollection> createState() => _StoryCollectionState();

  StoryCollection(this.id);
}

class _StoryCollectionState extends ThemeState<StoryCollection>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
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
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<StoryBloc, StoryState>(
//      buildWhen:  (previous, current) => previous.getStoriesStatus!=current.getStoriesStatus,
      builder: (context, state) {
        _videoController?.dispose();

        //todo the initial story
//        int currentInitialIndex = state.initialStory!;
//        List<Story> collectionOfSelectedStory =
//            state.stories[state.selectedStory!].stories!;
//        var initialStory = collectionOfSelectedStory[currentInitialIndex];

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
              Navigator.of(context).pop();
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

             GestureDetector(
            onLongPress: () => animatedController.stop(),
        onLongPressUp: () => animatedController.forward(),
        onTapDown: (details) {
        final double screenWidth =
        MediaQuery.of(context).size.width;
        final double dx = details.globalPosition.dx;

        if (LanguageService.rtl) {
        if (dx < screenWidth * 1 / 2) {
        animatedController.stop();
        animatedController.reset();
        if ((state.initialStory! + 1) >=
        state.stories[state.selectedStory!].stories!
            .length) {
        GetIt.I<StoryBloc>().add(StorySelectedEvent(
        selected: state.selectedStory!,
        initialStory: 0));
        Navigator.of(context).pop();
        } else {
        GetIt.I<StoryBloc>().add(StorySelectedEvent(
        selected: state.selectedStory!,
        initialStory: state.initialStory! + 1));
        }
        } else if (dx > screenWidth * 1 / 2) {
        animatedController.stop();

        animatedController.reset();
        if ((state.initialStory! - 1) > 0) {
        context.read<StoryBloc>().add(StorySelectedEvent(
        initialStory: state.initialStory! - 1,
        selected: state.selectedStory!));
        } else {
        context.read<StoryBloc>().add(StorySelectedEvent(
        initialStory: 0,
        selected: state.selectedStory!));
        }
        }
        } else {
        if (dx > screenWidth * 1 / 2) {
        animatedController.stop();
        animatedController.reset();
        if ((state.initialStory! + 1) >=
        state.stories[state.selectedStory!].stories!
            .length) {
        GetIt.I<StoryBloc>().add(StorySelectedEvent(
        selected: state.selectedStory!,
        initialStory: 0));
        Navigator.of(context).pop();
        } else {
        GetIt.I<StoryBloc>().add(StorySelectedEvent(
        selected: state.selectedStory!,
        initialStory: state.initialStory! + 1));
        }
        } else if (dx < screenWidth * 1 / 2) {
        animatedController.stop();

        animatedController.reset();
        if ((state.initialStory! - 1) > 0) {
        context.read<StoryBloc>().add(StorySelectedEvent(
        initialStory: state.initialStory! - 1,
        selected: state.selectedStory!));
        } else {
        context.read<StoryBloc>().add(StorySelectedEvent(
        initialStory: 0,
        selected: state.selectedStory!));
        }
        }
        }

        ;
        },
        child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemBuilder: (context, index) {
//todo check whether photo or video and start processing
        if (state.selectedStoriesStatus ==
        SelectedStoriesStatus.failure)
        return


          Center(
            child: ElevatedButton(
                onPressed: () {
                  GetIt.I<StoryBloc>().add(
                      StorySelectedEvent(
                          initialStory: state.initialStory!,
                          selected: state.selectedStory!));
                },
                child: Text('Try Again')),
          );
        else if (state.stories[state.selectedStory!]
            .stories![state.initialStory!].isPhoto ==
        1) {
        if (state.selectedStoriesStatus ==
        SelectedStoriesStatus.loading)
        return SizedBox(
        height: 60, width: 60, child: TrydosLoader());
        if (state.selectedStoriesStatus ==
        SelectedStoriesStatus.success) {
        animatedController.duration =
        const Duration(seconds: 4);
        animatedController.forward();

        return CachedNetworkImage(
        imageUrl: state.stories[state.selectedStory!]
            .stories![state.initialStory!].photoPath!,
        width: state.imageDetail!.width.toDouble(),
        height: state.imageDetail!.height.toDouble(),
        );
        }

        return Container();
        } else {
        _videoController = null;
        _videoController?.dispose();
        _videoController = VideoPlayerController.networkUrl(
        Uri.parse(state
            .stories[state.selectedStory!]
            .stories![state.initialStory!]
            .fullVideoPath!));
        Future<void> init =
        _videoController!.initialize().then((_) {
        animatedController.duration =
        _videoController!.value.duration;
        _videoController!.play();
        animatedController.forward();
        },onError: (e){

        GetIt.I<StoryBloc>().add(LoadFailureEvent());

        });
        return FutureBuilder(
        future: init,
        builder: (context, snapshot) {
        if (snapshot.connectionState ==
        ConnectionState.done) {
        return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
        width: _videoController!.value.size.width,
        height:
        _videoController!.value.size.height,
        child: VideoPlayer(
        _videoController!,
        ),
        ),
        );
        } else if (snapshot.connectionState ==
        ConnectionState.waiting) {
        return Center(
        child: TrydosLoader(),
        );
        } else if (snapshot.hasError)
        return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
        color: Colors.white,
        child: Center(
        child: ElevatedButton(
        onPressed: () {
        GetIt.I<StoryBloc>().add(
        StorySelectedEvent(
        initialStory:
        state.initialStory!,
        selected: state
            .selectedStory!));
        },
        child: Text('try')),
        ),
        ),
        );
        return Container(
        color: Colors.amberAccent,
        width: 200,
        height: 200,
        );
        },
        );

        }
        },
        itemCount:
        state.stories[state.selectedStory!].stories!.length,
        ),
        )
,
            Positioned(
                top: 40.0,
                left: 10.0,
                right: 10.0,
                child: Column(children: <Widget>[
                  Row(
                    children: state.stories[state.selectedStory!].stories!
                        .map((e) => AnimatedBar(
                            animController: animatedController,
                            position: state
                                .stories[state.selectedStory!].stories!
                                .indexOf(e)))
                        .toList(),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30.0,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: state.stories[state.selectedStory!].photoPath ==
                                null
                            ? NoImageWidget(
                                height: 40,
                                width: 40,
                                textStyle: context.textTheme.subtitle1?.br
                                    .copyWith(
                                        color: const Color(0xff6638FF),
                                        letterSpacing: 0.18,
                                        height: 1.33),
                                name: state.stories[state.selectedStory!]
                                            .name ==
                                        null
                                    ? 'UK'
                                    : HelperFunctions
                                        .getTheFirstTwoLettersOfName(state
                                            .stories[state.selectedStory!]
                                            .name!))
                            : CachedNetworkImage(
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.white,
                                        ),
                                        baseColor: Colors.grey,
                                        highlightColor:
                                            Color.fromARGB(31, 146, 144, 144)),
                                imageUrl: state
                                    .stories[state.selectedStory!].photoPath),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: 10),
                        child: Text(
                            style: textTheme.headline6?.rr
                                .copyWith(color: Colors.white),
                            state.stories[state.selectedStory!].name == null
                                ? 'UK'
                                : state.stories[state.selectedStory!].name!),
                      )
                    ]),
                  ),
                ])),
          ],
        );
      },
    );
  }
}

