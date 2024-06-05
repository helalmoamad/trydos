/*import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'story_collection.dart';

class StoryCollectionPageView extends StatefulWidget {
  const StoryCollectionPageView({super.key, required this.initialPage});

  final int initialPage;

  @override
  State<StoryCollectionPageView> createState() =>
      _StoryCollectionPageViewState();
}

class _StoryCollectionPageViewState extends State<StoryCollectionPageView>
    with TickerProviderStateMixin {
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();
  final ValueNotifier<bool> startStoriesNotifier = ValueNotifier(true);
  final ValueNotifier<int> denyScrollingAtEdgesNotifier = ValueNotifier(0);

  @override
  void initState() {
    prevPageNumber = widget.initialPage;
    pageController = PageController(initialPage: prevPageNumber);
    super.initState();
  }

  late PageController pageController;

  bool stopAnimationAndVideo = false;
  late int prevPageNumber;

  List<AnimationController> animationControllers = [];

  @override
  void dispose() {
    for (int i = 0; i < animationControllers.length; i++)
      animationControllers[i].dispose();
    super.dispose();
  }

  bool denyScrollingToRight = false, denyScrollingToLeft = false;
  late int currentPage;

  @override
  Widget build(BuildContext context) {
    return OverscrollPop(
      dragToPopDirection: DragToPopDirection.toBottom,
      friction: 2,
      dealWithStoryWhileDrag: (bool startStories) {
        startStoriesNotifier.value = startStories;
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) => false,
        builder: (context, state) {
          animationControllers = List.generate(state.storiesCollections.length,
              (index) => AnimationController(vsync: this));
          return Directionality(
              textDirection: TextDirection.ltr,
              child: ValueListenableBuilder<int>(
                  valueListenable: denyScrollingAtEdgesNotifier,
                  builder: (context, value, _) {
                    return CarouselSlider.builder(
                        detectingScrollingForEdges: (double dx) {
                          if (currentPage ==
                              state.storiesCollections.length - 1) {
                            denyScrollingAtEdgesNotifier.value = 2;
                          } else if (currentPage == 0) {
                            denyScrollingAtEdgesNotifier.value = 1;
                          } else {
                            denyScrollingAtEdgesNotifier.value = 0;
                          }
                        },
                        onSlideChanged: (int? newPage) {
                          if ((newPage! % state.storiesCollections.length) ==
                                  state.storiesCollections.length - 1 &&
                              currentPage == 0 &&
                              (carouselSliderController
                                          .doubleValueOfCurrentPage ??
                                      (state.storiesCollections.length *
                                          100000)) <
                                  (state.storiesCollections.length * 100000)) {
                            carouselSliderController.jumpToPage(index: 0);
                          } else if ((newPage %
                                      state.storiesCollections.length) ==
                                  0 &&
                              currentPage ==
                                  state.storiesCollections.length - 1 &&
                              (carouselSliderController
                                          .doubleValueOfCurrentPage ??
                                      (state.storiesCollections.length *
                                          100000)) >
                                  (state.storiesCollections.length * 100000) +
                                      state.storiesCollections.length -
                                      1) {
                            carouselSliderController.jumpToPage(
                                index: state.storiesCollections.length - 1);
                          }
                        },
                        slideBuilder: (int index) {
                          currentPage = widget.initialPage;
                          int carouselSliderCurrentPage;
                          if (carouselSliderController.currentPage != null) {
                            currentPage = carouselSliderController.currentPage!;
                            carouselSliderCurrentPage =
                                carouselSliderController.currentPage!;
                            if (carouselSliderCurrentPage <
                                (state.storiesCollections.length * 10000)) {
                              currentPage = (carouselSliderCurrentPage +
                                      state.storiesCollections.length) %
                                  state.storiesCollections.length;
                            } else {
                              currentPage = (carouselSliderCurrentPage -
                                      (state.storiesCollections.length *
                                          10000)) %
                                  state.storiesCollections.length;
                            }
                          }
                          debugPrint(
                              'kkk ${carouselSliderController.doubleValueOfCurrentPage}');
                          //ToDO case of 2 or 1 stories
                          if (currentPage == 0 &&
                              index == state.storiesCollections.length - 1 &&
                              (carouselSliderController
                                          .doubleValueOfCurrentPage ??
                                      (state.storiesCollections.length *
                                          100000)) <
                                  (state.storiesCollections.length * 100000)) {
                            return Container(
                              color: Colors.black,
                            );
                          }
                          if (currentPage ==
                                  (state.storiesCollections.length - 1) &&
                              index == 0 &&
                              (carouselSliderController
                                          .doubleValueOfCurrentPage ??
                                      (state.storiesCollections.length *
                                          100000)) >
                                  (state.storiesCollections.length * 100000) +
                                      state.storiesCollections.length -
                                      1) {
                            return Container(
                              color: Colors.black,
                            );
                          }
                          return ValueListenableBuilder<bool>(
                              valueListenable: startStoriesNotifier,
                              builder: (context, startStories, child) {
                                return StoryCollection(
                                    collectionIndex: index,
                                    animatedController:
                                        animationControllers[index],
                                    screenChanged:
                                        prevPageNumber != currentPage,
                                    onReachStoryAtEdge: (int collectionIndex,
                                        bool isReachTheLeftMost) {
                                      GetIt.I<HomeBloc>().add(StorySelectEvent(
                                          collectionIndex: collectionIndex,
                                          selectedStoryIndexInCollection: 0,
                                          currentPage: collectionIndex));
                                      if (!isReachTheLeftMost) {
                                        if (collectionIndex ==
                                            state.storiesCollections.length -
                                                1) {
                                          if (context.canPop()) {
                                            Navigator.of(context).pop();
                                          }
                                          return;
                                        }
                                        GetIt.I<HomeBloc>().add(
                                            StorySelectEvent(
                                                collectionIndex:
                                                    collectionIndex + 1,
                                                selectedStoryIndexInCollection:
                                                    -1,
                                                currentPage:
                                                    collectionIndex + 1));
                                        carouselSliderController.nextPage(
                                            Duration(milliseconds: 200));
                                        prevPageNumber = collectionIndex + 1;
                                      } else {
                                        if (collectionIndex == 0) {
                                          if (context.canPop()) {
                                            Navigator.of(context).pop();
                                          }
                                          return;
                                        }
                                        GetIt.I<HomeBloc>().add(
                                            StorySelectEvent(
                                                collectionIndex:
                                                    collectionIndex - 1,
                                                selectedStoryIndexInCollection:
                                                    -1,
                                                currentPage:
                                                    collectionIndex - 1));
                                        carouselSliderController.previousPage(
                                            Duration(milliseconds: 200));
                                        prevPageNumber = collectionIndex - 1;
                                      }
                                    },
                                    stopAnimationAndVideo:
                                        stopAnimationAndVideo ||
                                            index != prevPageNumber ||
                                            !startStories);
                              });
                        },
                        onSlideStart: () {
                          stopAnimationAndVideo = true;
                        },
                        onSlideEnd: () {
                          stopAnimationAndVideo = false;
                          int currentPage;
                          debugPrint(
                              'page: ${carouselSliderController.currentPage!}');
                          if (carouselSliderController.currentPage!
                                  .round()
                                  .toInt() <
                              (state.storiesCollections.length * 10000)) {
                            currentPage = (carouselSliderController.currentPage!
                                        .round()
                                        .toInt() +
                                    state.storiesCollections.length) %
                                state.storiesCollections.length;
                          } else {
                            currentPage = (carouselSliderController.currentPage!
                                        .round()
                                        .toInt() -
                                    (state.storiesCollections.length * 10000)) %
                                state.storiesCollections.length;
                          }
                          if (currentPage != prevPageNumber) {
                            GetIt.I<HomeBloc>().add(StorySelectEvent(
                                collectionIndex: currentPage,
                                currentPage: currentPage,
                                selectedStoryIndexInCollection: -1));
                            animationControllers[prevPageNumber].reset();
                            prevPageNumber = currentPage;
                          }
                        },
                        controller: carouselSliderController,
                        unlimitedMode: true,
                        scrollPhysics: value == 1
                            ? denyScrollingToLeftScrollPhysics()
                            : value == 2
                                ? denyScrollingToRightScrollPhysics()
                                : ClampingScrollPhysics(),
                        slideTransform: CubeTransform(),
                        initialPage: widget.initialPage,
                        itemCount: state.storiesCollections.length);
                  }));
        },
      ),
    );
  }
}

class denyScrollingToRightScrollPhysics extends ScrollPhysics {
  const denyScrollingToRightScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  // final int currentIndex;
  // final int maxIndex;
  @override
  denyScrollingToRightScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return denyScrollingToRightScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool get allowImplicitScrolling => false;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0) {
      return -0.5;
    }

    return super.applyPhysicsToUserOffset(position, offset);
  }
}

class denyScrollingToLeftScrollPhysics extends ScrollPhysics {
  const denyScrollingToLeftScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  denyScrollingToLeftScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return denyScrollingToLeftScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool get allowImplicitScrolling => false;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0) {
      return -1 * super.applyPhysicsToUserOffset(position, offset.abs());
    }
    return 0.5;
  }
}
 */