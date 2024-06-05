/*import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart' as dartz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui' as ui;
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/story/presentation/pages/story_collection_page_view.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';

//import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class StoryList extends StatefulWidget {
  StoryList({super.key});

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  final ScrollController listViewController = ScrollController();

  final ValueNotifier<dartz.Tuple2<int, int>> resizeStories =
      ValueNotifier(dartz.Tuple2(-1, -1));

  @override
  void initState() {
    listViewController.addListener(() {
      disableResizing();
    });
    super.initState();
  }

  void disableResizing() {
    resizeStories.value = resizeStories.value.copyWith(value2: -1, value1: -1);
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
//todo the ScrollConfiguration make behavior to the scroll
      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child: //todo the ValueListenableBuilder to control the effect when make longPress on the story and other action
            ValueListenableBuilder<dartz.Tuple2<int, int>>(
                valueListenable: resizeStories,
                builder: (context, focused, _) {
                  return () {
                    switch (state.getStoriesForProductStatus) {
                      case GetStoriesForProductStatus.success:
                        return SizedBox(
                            height: 194,
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: ListView.separated(
                                  controller: listViewController,
                                  itemBuilder: (context, index) {
                                    int indexOfInitialStory;
                                    Stories initialStory;
                                    if (GetIt.I<PrefsRepository>()
                                            .myStoriesId ==
                                        state.storiesCollections[index]
                                            .stories![0].userId) {
                                      indexOfInitialStory = state
                                          .storiesCollections[index].stories!
                                          .lastIndexWhere((element) =>
                                              element.isSeen == false);
                                      indexOfInitialStory =
                                          indexOfInitialStory == -1
                                              ? 0
                                              : indexOfInitialStory;
                                    } else {
                                      indexOfInitialStory = 0;
                                    }
                                    initialStory = state
                                        .storiesCollections[index]
                                        .stories![indexOfInitialStory];
                                    String? imageOfVideoUrl;
                                    if (initialStory.isPhoto != 1) {
                                      int index = initialStory.fullVideoPath!
                                          .lastIndexOf('.');
                                      imageOfVideoUrl = initialStory
                                              .fullVideoPath!
                                              .substring(0, index) +
                                          '.png';
                                    }
                                    return AnimatedPadding(
                                      duration: Duration(milliseconds: 200),
                                      padding: EdgeInsets.only(
                                          left: focused.value1 != -1 &&
                                                  focused.value1 == (index - 1)
                                              ? 30
                                              : 0),
                                      child: GestureDetector(
                                          onLongPressStart: (details) {
                                            bool isFirstPress =
                                                resizeStories.value.value1 ==
                                                    -1;
                                            resizeStories.value =
                                                resizeStories.value.copyWith(
                                                    value1: (details
                                                                .globalPosition
                                                                .dx +
                                                            listViewController
                                                                .offset -
                                                            115) ~/
                                                        115);
                                            if (details.localPosition.dx <=
                                                    (40 +
                                                        resizeStories
                                                                .value.value1 *
                                                            115 +
                                                        (resizeStories.value
                                                                    .value1 ==
                                                                resizeStories
                                                                    .value
                                                                    .value2
                                                            ? 45
                                                            : 0)) &&
                                                details.localPosition.dy <=
                                                    (40 +
                                                        (isFirstPress
                                                            ? 20
                                                            : 0) +
                                                        (resizeStories.value
                                                                    .value1 ==
                                                                resizeStories
                                                                    .value
                                                                    .value2
                                                            ? 45
                                                            : 0))) {
                                              resizeStories.value =
                                                  resizeStories.value.copyWith(
                                                      value2: resizeStories
                                                          .value.value1);
                                            } else {
                                              resizeStories.value =
                                                  resizeStories.value
                                                      .copyWith(value2: -1);
                                            }
                                          },
                                          onLongPressUp: () {
                                            resizeStories.value = resizeStories
                                                    .value =
                                                resizeStories.value.copyWith(
                                                    value2: -1, value1: -1);
                                          },
                                          onLongPressMoveUpdate: (details) {
                                            resizeStories.value =
                                                resizeStories.value.copyWith(
                                                    value1: (details
                                                                .globalPosition
                                                                .dx +
                                                            listViewController
                                                                .offset -
                                                            115) ~/
                                                        115);
                                            if (details.localPosition.dx <=
                                                    (40 +
                                                        resizeStories
                                                                .value.value1 *
                                                            115 +
                                                        (resizeStories.value
                                                                    .value1 ==
                                                                resizeStories
                                                                    .value
                                                                    .value2
                                                            ? 50
                                                            : 0)) &&
                                                details.localPosition.dy <=
                                                    (40 +
                                                        (resizeStories.value
                                                                    .value1 ==
                                                                resizeStories
                                                                    .value
                                                                    .value2
                                                            ? 50
                                                            : 0))) {
                                              resizeStories.value =
                                                  resizeStories.value.copyWith(
                                                      value2: resizeStories
                                                          .value.value1);
                                            } else {
                                              resizeStories.value =
                                                  resizeStories.value
                                                      .copyWith(value2: -1);
                                            }
                                          },
                                          child: (initialStory.isPhoto == 1)
                                              ? StoryItemWidget(
                                                  index: index,
                                                  onTapOnStoryAction: () async {
                                                    GetIt.I<HomeBloc>().add(
                                                        StorySelectEvent(
                                                            collectionIndex:
                                                                index,
                                                            currentPage: index,
                                                            selectedStoryIndexInCollection:
                                                                indexOfInitialStory));
                                                    // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> StoryCollectionPageView(
                                                    //             initialPage:
                                                    //             index)));
                                                    pushOverscrollRoute(
                                                        context: context,
                                                        child:
                                                            StoryCollectionPageView(
                                                                initialPage:
                                                                    index),
                                                        dragToPopDirection:
                                                            DragToPopDirection
                                                                .toBottom,
                                                        fullscreenDialog: true);
                                                    disableResizing();
                                                  },
                                                  onTapOnUserImage: () {
                                                    resizeStories.value =
                                                        resizeStories.value
                                                            .copyWith(
                                                                value2: index,
                                                                value1: index);
                                                  },
                                                  resize:
                                                      index == focused.value1,
                                                  resizeUserImage:
                                                      index == focused.value2,
                                                  firstPhotoNotShowed:
                                                      initialStory.photoPath,
                                                )
                                              : StoryItemWidget(
                                                  index: index,
                                                  onTapOnStoryAction: () async {
                                                    disableResizing();
                                                    GetIt.I<HomeBloc>().add(
                                                        StorySelectEvent(
                                                            collectionIndex:
                                                                index,
                                                            currentPage: index,
                                                            selectedStoryIndexInCollection:
                                                                indexOfInitialStory));
                                                    // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> StoryCollectionPageView(
                                                    //     initialPage:
                                                    //     index)));
                                                    pushOverscrollRoute(
                                                        context: context,
                                                        child:
                                                            StoryCollectionPageView(
                                                                initialPage:
                                                                    index),
                                                        dragToPopDirection:
                                                            DragToPopDirection
                                                                .toBottom,
                                                        fullscreenDialog: true);
                                                    // Navigator.push(context, MaterialPageRoute(builder: (_)=> StoryCollection(index ,   key: UniqueKey()),));
                                                  },
                                                  onTapOnUserImage: () {
                                                    resizeStories.value =
                                                        resizeStories.value
                                                            .copyWith(
                                                                value2: index,
                                                                value1: index);
                                                  },
                                                  resize:
                                                      index == focused.value1,
                                                  resizeUserImage:
                                                      index == focused.value2,
                                                  firstPhotoNotShowed:
                                                      imageOfVideoUrl,
                                                )),
                                    );
                                  },
                                  physics: const ClampingScrollPhysics(),
                                  padding: EdgeInsetsDirectional.symmetric(
                                      horizontal: 10),
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        width: 15,
                                      ),
                                  itemCount: state.storiesCollections.length),
                            ));
                      case GetStoriesForProductStatus.init:
                        return Container();
                      case GetStoriesForProductStatus.failure:
                        return Center(
                          child: ElevatedButton(
                              onPressed: () {
                                GetIt.I<HomeBloc>()
                                    .add(GetStoryForProductEvent());
                              },
                              child: MyTextWidget(LocaleKeys.try_again.tr())),
                        );
                      case GetStoriesForProductStatus.loading:
                        return SizedBox(
                          width: double.infinity,
                          height: 220,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 10, top: 35, bottom: 30),
                                  child: TrydosShimmerLoading(
                                    width: 100,
                                    height: 150,
                                    logoTextHeight: 14,
                                    logoTextWidth: 48.w,
                                  )),
                              separatorBuilder: (context, index) => SizedBox(
                                    width: 5,
                                  ),
                              itemCount: 7),
                        );
                    }
                  }();
                }),
      );
    });
  }
}

//Future<Uint8List> generateThumbnail(String videoPath) async {
//  final uint8list = await VideoThumbnail.thumbnailData(
//    video: videoPath,
//    imageFormat: ImageFormat.PNG,
//    maxWidth: 1280,
//    quality: 100,
//  );
//  return uint8list!;
//}
*/