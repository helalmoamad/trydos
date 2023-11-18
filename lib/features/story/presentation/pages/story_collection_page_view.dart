import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import '../../presentation/pages/story_collection.dart';

class StoryCollectionPageView extends StatefulWidget {
  const StoryCollectionPageView({super.key, required this.initialPage });

  final int initialPage;

  @override
  State<StoryCollectionPageView> createState() =>
      _StoryCollectionPageViewState();
}

class _StoryCollectionPageViewState extends State<StoryCollectionPageView>
    with TickerProviderStateMixin {

  final CarouselSliderController carouselSliderController = CarouselSliderController();
  final ValueNotifier<bool> startStoriesNotifier = ValueNotifier(true);
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

  @override
  Widget build(BuildContext context) {
    return OverscrollPop(
      dragToPopDirection: DragToPopDirection.toBottom,
      friction: 2,
      scrollToPopOption: ScrollToPopOption.none,
      dealWithStoryWhileDrag: (bool startStories){
        startStoriesNotifier.value = startStories;
      },
      child: BlocBuilder<StoryBloc, StoryState>(
        buildWhen: (p, c) => false,
        builder: (context, state) {
          animationControllers = List.generate(
              state.stories.length, (index) => AnimationController(vsync: this));
          return Directionality(
            textDirection: TextDirection.ltr,
            child: CarouselSlider.builder(
                slideBuilder: (int index) {
                  int currentPage = widget.initialPage;
                  int carouselSliderCurrentPage ;
                  if(carouselSliderController.currentPage != null) {
                    carouselSliderCurrentPage = carouselSliderController.currentPage!.toInt();
                    if ( carouselSliderCurrentPage <
                        (state.stories.length * 10000)) {
                      currentPage =
                          (carouselSliderCurrentPage +
                              state.stories.length) % state.stories.length;
                    } else {
                      currentPage =
                          (carouselSliderCurrentPage -
                              (state.stories.length * 10000)) %
                              state.stories.length;
                    }
                  }
                  return ValueListenableBuilder<bool>(
                    valueListenable: startStoriesNotifier,
                    builder: (context , startStories , child) {
                      print('startStories $startStories');
                      return StoryCollection(
                          index,
                          animatedController: animationControllers[index],
                          screenChanged: prevPageNumber != currentPage,
                          onReachStoryAtEdge:
                              (int collectionIndex, bool isReachTheLeftMost) {
                                GetIt.I<StoryBloc>().add(StorySelectedEvent(
                                    selected: collectionIndex, initialStory: 0,currentPage: collectionIndex));
                        if (!isReachTheLeftMost) {
                          print(collectionIndex);
                            GetIt.I<StoryBloc>().add(StorySelectedEvent(
                                selected: collectionIndex + 1, initialStory: -1,currentPage: collectionIndex + 1 ));
                            carouselSliderController.nextPage(Duration(milliseconds: 200));
                            prevPageNumber = collectionIndex + 1;
                          }
                        else{
                          GetIt.I<StoryBloc>().add(StorySelectedEvent(
                              selected: collectionIndex - 1, initialStory: -1,currentPage: collectionIndex -1 ));
                          carouselSliderController.previousPage(Duration(milliseconds: 200));
                          prevPageNumber = collectionIndex - 1;
                        }
                      },
                          stopAnimationAndVideo: stopAnimationAndVideo || index != prevPageNumber || !startStories);
                    }
                  );
                },
                onSlideStart: (){
                  stopAnimationAndVideo = true;
                },
                onSlideEnd: (){
                    stopAnimationAndVideo = false;
                  int currentPage;
                    print('page: ${carouselSliderController.currentPage!}');
                  if(carouselSliderController.currentPage!.round().toInt() < (state.stories.length * 10000)){
                    currentPage = (carouselSliderController.currentPage!.round().toInt() + state.stories.length) % state.stories.length;
                  }else {
                    currentPage = (carouselSliderController.currentPage!.round().toInt() - (state.stories.length * 10000)) % state.stories.length ;
                  }

                  if (currentPage != prevPageNumber) {
                    GetIt.I<StoryBloc>().add(StorySelectedEvent(
                        selected: currentPage,
                        currentPage: currentPage,
                        initialStory: -1));
                    animationControllers[prevPageNumber].reset();
                    prevPageNumber = currentPage ;
                  }
                },
                controller: carouselSliderController,
                unlimitedMode: true,
                scrollPhysics: ClampingScrollPhysics(),
                slideTransform: CubeTransform(),
                initialPage: widget.initialPage,
                itemCount: state.stories.length),
          );
        },
      ),
    );
  }
}

