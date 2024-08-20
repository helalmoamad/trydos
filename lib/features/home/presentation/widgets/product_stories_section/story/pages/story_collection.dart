/*import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:trydos/service/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/no_image_widget.dart';

import 'package:video_player/video_player.dart';

import '../../../../../../../common/helper/helper_functions.dart';
import '../../../../../../app/my_cached_network_image.dart';
import '../../../../../../app/my_text_widget.dart';
import '../../../../../../app/trydos_shimmer_loading.dart';
import '../widget/animated_builder.dart';
import 'dart:ui';

class StoryCollection extends StatefulWidget {
  final int collectionIndex;
  final AnimationController animatedController;
  bool stopAnimationAndVideo;
  final bool screenChanged;
  final void Function(int collectionIndex, bool isReachTheLeftMost)
      onReachStoryAtEdge;

  @override
  State<StoryCollection> createState() => _StoryCollectionState();

  StoryCollection(
      {Key? key,
      required this.collectionIndex,
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
    debugPrint('initState ${widget.collectionIndex}');
    GetIt.I<HomeBloc>().add(StorySelectEvent(
        collectionIndex: widget.collectionIndex,
        selectedStoryIndexInCollection: -1,
        currentPage: -1));
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
      debugPrint(error.toString());
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return Hero(
      tag: widget.collectionIndex,
      createRectTween: HeroAnimationAsset.customTweenRect,
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (ctx, state) {
          widget.stopAnimationAndVideo = false;
        },
        builder: (context, state) {
          //todo the initial story
//        int currentInitialIndex = state.currentStoryInEachCollection!;
//        List<Story> collectionOfSelectedStory =
//            state.stories[widget.collectionIndex].stories!;
//        var currentStoryInEachCollection = collectionOfSelectedStory[currentInitialIndex];
          pageController = PageController(
              initialPage:
                  state.currentStoryInEachCollection[widget.collectionIndex]!);
          widget.animatedController.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.animatedController.stop();
              widget.animatedController.reset();

              if ((state.currentStoryInEachCollection[widget.collectionIndex]! +
                      1) >=
                  state.storiesCollections[widget.collectionIndex].stories!
                      .length) {
                widget.onReachStoryAtEdge.call(widget.collectionIndex, false);
              } else {
                GetIt.I<HomeBloc>().add(StorySelectEvent(
                    collectionIndex: widget.collectionIndex,
                    currentPage: -1,
                    selectedStoryIndexInCollection:
                        state.currentStoryInEachCollection[
                                widget.collectionIndex]! +
                            1));
              }
            }
          });
          return Stack(
            children: [
//          MyTextWidget('${state.selectedStoriesStatus}'),
//          state.selectedStoriesStatus==SelectedStoriesStatus.success?MyTextWidget('${state.imageDetail!.width}'):MyTextWidget('data')
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
                  debugPrint(dx.toString());
                  _videoController?.dispose();
                  _videoController = null;
                  init = null;
                  if (LanguageService.rtl) {
                    if (dx > screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! +
                              1) >=
                          state.storiesCollections[widget.collectionIndex]
                              .stories!.length) {
                        GetIt.I<HomeBloc>().add(StorySelectEvent(
                          collectionIndex: widget.collectionIndex,
                          selectedStoryIndexInCollection: 0,
                          currentPage: -1,
                        ));
                        Navigator.of(context).pop();
                      } else {
                        GetIt.I<HomeBloc>().add(StorySelectEvent(
                            collectionIndex: widget.collectionIndex,
                            currentPage: -1,
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! +
                                    1));
                      }
                    } else if (dx < screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! -
                              1) >
                          0) {
                        context.read<HomeBloc>().add(StorySelectEvent(
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! -
                                    1,
                            currentPage: -1,
                            collectionIndex: widget.collectionIndex));
                      } else {
                        context.read<HomeBloc>().add(StorySelectEvent(
                            currentPage: -1,
                            selectedStoryIndexInCollection: 0,
                            collectionIndex: widget.collectionIndex));
                      }
                    }
                  } else {
                    if (dx > screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! +
                              1) >=
                          state.storiesCollections[widget.collectionIndex]
                              .stories!.length) {
                        widget.onReachStoryAtEdge
                            .call(widget.collectionIndex, false);
                      } else {
                        GetIt.I<HomeBloc>().add(StorySelectEvent(
                            collectionIndex: widget.collectionIndex,
                            currentPage: -1,
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! +
                                    1));
                      }
                    } else if (dx < screenWidth * 1 / 2) {
                      widget.animatedController.stop();

                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! -
                              1) >
                          0) {
                        context.read<HomeBloc>().add(StorySelectEvent(
                            currentPage: -1,
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! -
                                    1,
                            collectionIndex: widget.collectionIndex));
                      } else {
                        widget.onReachStoryAtEdge
                            .call(widget.collectionIndex, true);
                      }
                    }
                  }
                },
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  itemBuilder: (context, index) {
//todo check whether photo or video and start processing
                    if (state.storiesCollections[widget.collectionIndex]
                            .selectedStoriesStatusForCollection ==
                        SelectedStoriesStatus.failure)
                      return Center(
                        child: ElevatedButton(
                            onPressed: () {
                              GetIt.I<HomeBloc>().add(StorySelectEvent(
                                  currentPage: -1,
                                  selectedStoryIndexInCollection:
                                      state.currentStoryInEachCollection[
                                          widget.collectionIndex]!,
                                  collectionIndex: widget.collectionIndex));
                            },
                            child: MyTextWidget(LocaleKeys.try_again.tr())),
                      );
                    else if (state
                            .storiesCollections[widget.collectionIndex]
                            .stories![state.currentStoryInEachCollection[
                                widget.collectionIndex]!]
                            .isPhoto ==
                        1) {
                      if (state.storiesCollections[widget.collectionIndex]
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
                      if (state.storiesCollections[widget.collectionIndex]
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
                              .storiesCollections[widget.collectionIndex]
                              .stories![state.currentStoryInEachCollection[
                                  widget.collectionIndex]!]
                              .photoPath!,
                          callWhenDisplayImage: () {
                            if (widget.stopAnimationAndVideo) {
                              widget.animatedController.stop();
                            } else {
                              widget.animatedController.forward();
                            }
                          },
                          callWhenLoadingImage: () {
                            widget.animatedController.stop();
                          },
                          width: state
                              .storiesCollections[widget.collectionIndex]
                              .imageDetail!
                              .width
                              .toDouble(),
                          height: state
                              .storiesCollections[widget.collectionIndex]
                              .imageDetail!
                              .height
                              .toDouble(),
                          imageFit: BoxFit.contain,
                        );
                      }
                      return Container();
                    } else {
                      if (_videoController == null) {
                        _videoController = VideoPlayerController.networkUrl(
                            Uri.parse(state
                                .storiesCollections[widget.collectionIndex]
                                .stories![state.currentStoryInEachCollection[
                                    widget.collectionIndex]!]
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
                          GetIt.I<HomeBloc>().add(LoadFailureEvent(
                              collectionId: widget.collectionIndex));
                        });
                      }
                      if (widget.collectionIndex != state.currentPage) {
                        _videoController?.pause();
                        widget.animatedController.stop();
                      } else {
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
                                        GetIt.I<HomeBloc>().add(StorySelectEvent(
                                            selectedStoryIndexInCollection:
                                                state.currentStoryInEachCollection[
                                                    widget.collectionIndex]!,
                                            currentPage: -1,
                                            collectionIndex:
                                                widget.collectionIndex));
                                      },
                                      child:
                                          MyTextWidget(LocaleKeys.trye.tr())),
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
                  itemCount: state.storiesCollections[widget.collectionIndex]
                      .stories!.length,
                ),
              ),
              Positioned(
                  top: 40.0,
                  left: 10.0,
                  right: 10.0,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Row(
                      children: state
                          .storiesCollections[widget.collectionIndex].stories!
                          .map((e) => AnimatedBar(
                              animController: widget.animatedController,
                              collectionIndex: widget.collectionIndex,
                              position: state
                                  .storiesCollections[widget.collectionIndex]
                                  .stories!
                                  .indexOf(e)))
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
                          child: state.storiesCollections[widget.collectionIndex].photoPath == null
                              ? NoImageWidget(
                                  height: 40,
                                  width: 40,
                                  textStyle: context.textTheme.bodyMedium?.br
                                      .copyWith(
                                          color: const Color(0xff6638FF),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                  name: state
                                              .storiesCollections[
                                                  widget.collectionIndex]
                                              .name ==
                                          null
                                      ? LocaleKeys.uk.tr()
                                      : HelperFunctions.getTheFirstTwoLettersOfName(state
                                          .storiesCollections[
                                              widget.collectionIndex]
                                          .name!))
                              : MyCachedNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imageFit: BoxFit.cover,
                                  imageUrl: state
                                      .storiesCollections[widget.collectionIndex]
                                      .photoPath),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: 10),
                          child: MyTextWidget(
                              style: textTheme.bodyLarge?.rr
                                  .copyWith(color: Colors.white),
                              state.storiesCollections[widget.collectionIndex]
                                          .name ==
                                      null
                                  ? LocaleKeys.uk.tr()
                                  : state
                                      .storiesCollections[
                                          widget.collectionIndex]
                                      .name!),
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
*/