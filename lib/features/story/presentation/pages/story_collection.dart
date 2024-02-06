import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../config/theme/typography.dart';
import 'package:trydos/service/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/no_image_widget.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/trydos_shimmer_loading.dart';
import '../../data/models/get_stories_model.dart';
import '../bloc/story_state.dart';
import '../widget/animated_builder.dart';
import 'dart:ui';

class StoryCollection extends StatefulWidget {
  final int id;
  final AnimationController animatedController;
   bool stopAnimationAndVideo;
  final bool screenChanged;
  final void Function(int collectionIndex, bool isReachTheLeftMost)
      onReachStoryAtEdge;

  @override
  State<StoryCollection> createState() => _StoryCollectionState();

    StoryCollection(this.id,
      {Key? key,
      required this.animatedController,
      required this.onReachStoryAtEdge,
      required this.screenChanged,
      required this.stopAnimationAndVideo})
      : super(key: key);
}

class _StoryCollectionState extends ThemeState<StoryCollection> {
  late PageController pageController;
  VideoPlayerController? _videoController;

  LongPressDownDetails details = LongPressDownDetails();
  var init;

  @override
  void initState() {
    print('initState ${widget.id}');
    GetIt.I<StoryBloc>().add(StorySelectedEvent(selected: widget.id, initialStory: -1,currentPage: -1));
    super.initState();
  }


  @override
  void dispose() {
    pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      print(error);
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return Hero(
      tag: widget.id,
      createRectTween: HeroAnimationAsset.customTweenRect,
      child: BlocConsumer<StoryBloc, StoryState>(
        listener: (ctx, state) {
          widget.stopAnimationAndVideo = false;
        },
        builder: (context, state) {
          //todo the initial story
//        int currentInitialIndex = state.initialStory!;
//        List<Story> collectionOfSelectedStory =
//            state.stories[widget.id].stories!;
//        var initialStory = collectionOfSelectedStory[currentInitialIndex];
          pageController = PageController(initialPage: state.initialStory[widget.id]!);
          widget.animatedController.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.animatedController.stop();
              widget.animatedController.reset();

              if ((state.initialStory[widget.id]! + 1) >=
                  state.stories[widget.id].stories!.length) {
                widget.onReachStoryAtEdge.call(widget.id, false);
              } else {
                GetIt.I<StoryBloc>().add(StorySelectedEvent(
                    selected: widget.id,
                    currentPage: -1,
                    initialStory: state.initialStory[widget.id]! + 1));
              }
            }
          });
          return Stack(
            children: [
//          Text('${state.selectedStoriesStatus}'),
//          state.selectedStoriesStatus==SelectedStoriesStatus.success?Text('${state.imageDetail!.width}'):Text('data')
              GestureDetector(
                onLongPressDown: (_) {
                  details = _;
                },
                onLongPressStart: (_) {
                  widget.animatedController.stop();
                  _videoController?.pause();
                },
                onLongPressUp: () {
                  widget.animatedController.forward();
                  _videoController?.play();
                },

                // onVerticalDragUpdate: (details) {
                //   if (details.delta.direction > 0) {
                //     Navigator.pop(context);
                //   }
                // },
                onLongPressCancel: () {
                  final double screenWidth = MediaQuery.of(context).size.width;
                  final double dx = details.localPosition.dx;
                  print(dx);
                  _videoController?.dispose();
                  _videoController = null;
                  init = null;
                  if (LanguageService.rtl) {
                    if (dx > screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.initialStory[widget.id]! + 1) >=
                          state.stories[widget.id].stories!.length) {
                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                            selected: widget.id, initialStory: 0,currentPage: -1,));
                        Navigator.of(context).pop();
                      } else {
                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                            selected: widget.id,
                            currentPage: -1,
                            initialStory: state.initialStory[widget.id]! + 1));
                      }
                    } else if (dx < screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.initialStory[widget.id]! - 1) > 0) {
                        context.read<StoryBloc>().add(StorySelectedEvent(
                            initialStory: state.initialStory[widget.id]! - 1,
                            currentPage: -1,
                            selected: widget.id));
                      } else {
                        context.read<StoryBloc>().add(StorySelectedEvent(
                            currentPage: -1,
                            initialStory: 0, selected: widget.id));
                      }
                    }
                  } else {
                    if (dx > screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.initialStory[widget.id]! + 1) >=
                          state.stories[widget.id].stories!.length) {
                        widget.onReachStoryAtEdge.call(widget.id, false);
                      } else {
                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                            selected: widget.id,
                            currentPage: -1,
                            initialStory: state.initialStory[widget.id]! + 1));
                      }
                    } else if (dx < screenWidth * 1 / 2) {
                      widget.animatedController.stop();

                      widget.animatedController.reset();
                      if ((state.initialStory[widget.id]! - 1) > 0) {
                        context.read<StoryBloc>().add(StorySelectedEvent(
                            currentPage: -1,
                            initialStory: state.initialStory[widget.id]! - 1,
                            selected: widget.id));
                      } else {
                        widget.onReachStoryAtEdge.call(widget.id, true);
                      }
                    }
                  }
                },
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  itemBuilder: (context, index) {
//todo check whether photo or video and start processing
                    if (state.stories[widget.id]
                            .selectedStoriesStatusForCollection ==
                        SelectedStoriesStatus.failure)
                      return Center(
                        child: ElevatedButton(
                            onPressed: () {
                              GetIt.I<StoryBloc>().add(StorySelectedEvent(
                                  currentPage: -1,
                                  initialStory: state.initialStory[widget.id]!,
                                  selected: widget.id));
                            },
                            child: Text('Try Again')),
                      );
                    else if (state.stories[widget.id]
                            .stories![state.initialStory[widget.id]!].isPhoto ==
                        1) {
                      if (state.stories[widget.id]
                              .selectedStoriesStatusForCollection ==
                          SelectedStoriesStatus.loading) {
                        widget.animatedController.stop();
                        return TrydosShimmerLoading(
                          width: 60,
                          height: 60,
                          logoTextHeight: 14,
                          logoTextWidth: 20.w,
                        );
                      }
                      if (state.stories[widget.id]
                              .selectedStoriesStatusForCollection ==
                          SelectedStoriesStatus.success) {
                        widget.animatedController.stop();
                        widget.animatedController.duration =
                            const Duration(seconds: 4);
                        if (widget.stopAnimationAndVideo) {
                          widget.animatedController.stop();
                        } else {
                          widget.animatedController.forward();
                        }
                        return MyCachedNetworkImage(
                          imageUrl: state
                              .stories[widget.id]
                              .stories![state.initialStory[widget.id]!]
                              .photoPath!,
                          width: state.stories[widget.id].imageDetail!.width
                              .toDouble(),
                          height: state.stories[widget.id].imageDetail!.height
                              .toDouble(),
                          imageFit: BoxFit.contain,
                        );
                      }
                      return Container();
                    } else {
                      if (_videoController == null) {
                        _videoController = VideoPlayerController.networkUrl(
                            Uri.parse(state
                                .stories[widget.id]
                                .stories![state.initialStory[widget.id]!]
                                .fullVideoPath!));
                        init = _videoController!.initialize().then((_) {
                          widget.animatedController.duration =
                              _videoController!.value.duration;
                          if (widget.stopAnimationAndVideo) {
                            _videoController?.pause();
                            widget.animatedController.stop();
                          } else {
                            _videoController?.play();
                            widget.animatedController.forward();
                          }
                          _videoController!.addListener(() {
                            if (!_videoController!.value.isPlaying) {
                              widget.animatedController.stop();
                            } else {
                              widget.animatedController.forward();
                            }
                          });
                        }, onError: (e) {
                          GetIt.I<StoryBloc>()
                              .add(LoadFailureEvent(collectionId: widget.id));
                        });
                      }
                      if(widget.id != state.currentPage){
                        _videoController?.pause();
                        widget.animatedController.stop();
                      }else {
                        if (widget.stopAnimationAndVideo) {
                          _videoController?.pause();
                          widget.animatedController.stop();
                        } else {
                          _videoController?.play();
                          if (_videoController != null) {
                            if (_videoController!.value.isInitialized) {
                              widget.animatedController.forward();
                            }
                          }
                        }
                      }
                      return FutureBuilder(
                        future: init,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
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
                                                initialStory: state
                                                    .initialStory[widget.id]!,
                                                currentPage: -1,
                                                selected: widget.id));
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
                  itemCount: state.stories[widget.id].stories!.length,
                ),
              ),
              Positioned(
                  top: 40.0,
                  left: 10.0,
                  right: 10.0,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Row(
                      children: state.stories[widget.id].stories!
                          .map((e) => AnimatedBar(
                              animController: widget.animatedController,
                              collectionIndex: widget.id,
                              position:
                                  state.stories[widget.id].stories!.indexOf(e)))
                          .toList(),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
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
                          child: state.stories[widget.id].photoPath == null
                              ? NoImageWidget(
                                  height: 40,
                                  width: 40,
                                  textStyle: context.textTheme.subtitle1?.br
                                      .copyWith(
                                          color: const Color(0xff6638FF),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                  name: state.stories[widget.id].name == null
                                      ? 'UK'
                                      : HelperFunctions
                                          .getTheFirstTwoLettersOfName(
                                              state.stories[widget.id].name!))
                              : MyCachedNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imageFit: BoxFit.cover,
                                  imageUrl: state.stories[widget.id].photoPath),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: 10),
                          child: Text(
                              style: textTheme.headline6?.rr
                                  .copyWith(color: Colors.white),
                              state.stories[widget.id].name == null
                                  ? 'UK'
                                  : state.stories[widget.id].name!),
                        )
                      ]),
                    ),
                  ])),
            ],
          );
        },
      ),
    );
  }
}



class HeroAnimationAsset {
  static Tween<Rect?> customTweenRect(Rect? begin, Rect? end) =>
      CustomRectTween(end: end, begin: begin);
}

//////////////////////////////////////////////////////////////////////////////

class CustomRectTween extends RectTween {
  CustomRectTween({
    Rect? begin,
    Rect? end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.fastEaseInToSlowEaseOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin!.left, end!.left, elasticCurveValue)!,
      lerpDouble(begin!.top, end!.top, elasticCurveValue)!,
      lerpDouble(begin!.right, end!.right, elasticCurveValue)!,
      lerpDouble(begin!.bottom, end!.bottom, elasticCurveValue)!,
    );
  }
}