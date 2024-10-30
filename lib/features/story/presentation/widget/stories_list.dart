import 'dart:io';
import 'package:dartz/dartz.dart' as dartz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/update_user_name_widget.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection_page_view.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../../data/models/get_stories_model.dart';
import '../bloc/story_state.dart';

class StoriesList extends StatefulWidget {
  StoriesList({super.key});

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  final ScrollController listViewController = ScrollController();

  final ValueNotifier<dartz.Tuple2<int, int>> resizeStories =
      ValueNotifier(dartz.Tuple2(-1, -1));

  double _lastScrollPosition = 0;

  @override
  void initState() {
    listViewController.addListener(
      () {
        if (resizeStories.value.value1 != -1 ||
            resizeStories.value.value2 != -1) {
          disableResizing();
        }

        double currentPosition = listViewController.position.pixels;
        if ((currentPosition - _lastScrollPosition).abs() >= 20) {
          debugPrint(listViewController.position.pixels.toString());
          _lastScrollPosition = currentPosition;
          /////////////////////////////
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.buttonClicked,
            executedEventName:
                AnalyticsExecutedEventNameConst.scrollStoriesInHomeEvent,
          );
        }
      },
    );
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
      print(error.toString());
    };
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
//todo the ScrollConfiguration make behavior to the scroll
      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child: //todo the ValueListenableBuilder to control the effect when make longPress on the story and other action
            ValueListenableBuilder<dartz.Tuple2<int, int>>(
                valueListenable: resizeStories,
                builder: (context, focused, _) {
                  return () {
                    switch (state.getStoriesStatus) {
                      case GetStoriesStatus.success:
                        return SizedBox(
                            key: TestVariables.kTestMode
                                ? Key(WidgetsKey.storiesSuccessStatusKey)
                                : null,
                            height: 220,
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: ListView.separated(
                                  controller: listViewController,
                                  itemBuilder: (context, index) {
                                    //todo FIRST ELEMENT IN THE LISTvIEW IT WILL BE THE UPLOAD BUTTON
                                    if (index == 0) {
                                      return state.uploadStoryCloudinaryStatus ==
                                              UploadStoryCloudinaryStatus
                                                  .loading
                                          ? TrydosLoader()
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 40),
                                                Material(
                                                  color: Colors.transparent,
                                                  child: SizedBox(
                                                    width: 100,
                                                    height: 150,
                                                    child: InkWell(
                                                      highlightColor:
                                                          Colors.transparent,
                                                      splashColor:
                                                          Colors.transparent,
                                                      child: Container(
                                                        child: Center(
                                                            child: MyTextWidget(
                                                                LocaleKeys
                                                                    .upload
                                                                    .tr())),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                          color: Colors.grey,
                                                        ),
                                                        width: 100,
                                                      ),
                                                      onTap: () async {
                                                        disableResizing();
                                                        if (GetIt.I<PrefsRepository>()
                                                                .isVerifiedPhone ==
                                                            false) {
                                                          context.go(GRouter
                                                              .config
                                                              .applicationRoutes
                                                              .kRegistrationPage);
                                                        } else if (GetIt.I<
                                                                    PrefsRepository>()
                                                                .myMarketName ==
                                                            null) {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return UpdateUserNameWidget();
                                                            },
                                                          );
                                                        } else {
                                                          FirebaseAnalyticsService
                                                              .logEventForSession(
                                                            eventName:
                                                                AnalyticsEventsConst
                                                                    .buttonClicked,
                                                            executedEventName:
                                                                AnalyticsExecutedEventNameConst
                                                                    .uploadStoryButton,
                                                          );
                                                          //////////////////////////////////////
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return GalleryAndCameraDialogWidget(
                                                                onChooseFileFromCameraAction:
                                                                    (File?
                                                                        file) async {
                                                                  if (file !=
                                                                      null) {
                                                                    GetIt.I<StoryBloc>().add(
                                                                        UploadStoryCloudinaryEvent(
                                                                            file));

                                                                    // final cloudinary =
                                                                    //     CloudinaryPublic(
                                                                    //         'djooohujg',
                                                                    //         'v4h8xqns',
                                                                    //         cache:false);
                                                                    // CloudinaryResponse
                                                                    //     response =
                                                                    //     await cloudinary
                                                                    //         .uploadFile(
                                                                    //
                                                                    //
                                                                    //   CloudinaryFile.fromFile(
                                                                    ///////////////////////////////////////////
                                                                    FirebaseAnalyticsService
                                                                        .logEventForSession(
                                                                      eventName:
                                                                          AnalyticsEventsConst
                                                                              .buttonClicked,
                                                                      executedEventName:
                                                                          AnalyticsExecutedEventNameConst
                                                                              .confirmUploadStoryButton,
                                                                    );
                                                                  }
                                                                },
                                                                onChooseFileFromGalleryAction:
                                                                    (AssetEntity?
                                                                        assetEntity) async {
                                                                  if (assetEntity !=
                                                                      null) {
                                                                    File file =
                                                                        (await assetEntity
                                                                            .originFile)!;
                                                                    GetIt.I<StoryBloc>().add(
                                                                        UploadStoryCloudinaryEvent(
                                                                            file));
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                    } else {
                                      //todo cause we take the index 0 to the upload button
                                      index = index - 1;
                                      //TODO CHECK WITHER THE USER AUTH OR NOT SO IF AUTH IF HE HAS STORY RETURN TO IT THE
                                      //TODO LAST STORY HE UPLOAD ELSE MAKE THE FIRST STORY NOT SHOWED IN FRONT
                                      int indexOfInitialStory;
                                      Story initialStory;
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
                                        indexOfInitialStory =
                                            firstWhereNotShowed(state
                                                .storiesCollections[index]
                                                .stories!);
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
                                                    focused.value1 ==
                                                        (index - 1)
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
                                                          resizeStories.value
                                                                  .value1 *
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
                                                    resizeStories.value
                                                        .copyWith(
                                                            value2:
                                                                resizeStories
                                                                    .value
                                                                    .value1);
                                              } else {
                                                resizeStories.value =
                                                    resizeStories.value
                                                        .copyWith(value2: -1);
                                              }
                                            },
                                            onLongPressUp: () {
                                              resizeStories.value =
                                                  resizeStories.value =
                                                      resizeStories.value
                                                          .copyWith(
                                                              value2: -1,
                                                              value1: -1);
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
                                                          resizeStories.value
                                                                  .value1 *
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
                                                    resizeStories.value
                                                        .copyWith(
                                                            value2:
                                                                resizeStories
                                                                    .value
                                                                    .value1);
                                              } else {
                                                resizeStories.value =
                                                    resizeStories.value
                                                        .copyWith(value2: -1);
                                              }
                                            },
                                            child: (initialStory.isPhoto == 1)
                                                ? StoryItemWidget(
                                                    index: index,
                                                    onTapOnStoryAction:
                                                        () async {
                                                      GetIt.I<StoryBloc>().add(
                                                          StorySelectedEvent(
                                                              collectionIndex:
                                                                  index,
                                                              currentPage:
                                                                  index,
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
                                                          fullscreenDialog:
                                                              true);
                                                      disableResizing();
                                                      //////////////////////////////
                                                      FirebaseAnalyticsService
                                                          .logEventForSession(
                                                        eventName:
                                                            AnalyticsEventsConst
                                                                .buttonClicked,
                                                        executedEventName:
                                                            AnalyticsExecutedEventNameConst
                                                                .viewStoryButton,
                                                      );
                                                    },
                                                    onTapOnUserImage: () {
                                                      resizeStories.value =
                                                          resizeStories.value
                                                              .copyWith(
                                                                  value2: index,
                                                                  value1:
                                                                      index);
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
                                                    onTapOnStoryAction:
                                                        () async {
                                                      disableResizing();
                                                      GetIt.I<StoryBloc>().add(
                                                          StorySelectedEvent(
                                                              collectionIndex:
                                                                  index,
                                                              currentPage:
                                                                  index,
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
                                                          fullscreenDialog:
                                                              true);
                                                      // Navigator.push(context, MaterialPageRoute(builder: (_)=> StoryCollection(index ,   key: UniqueKey()),));
                                                      //////////////////////////////
                                                      FirebaseAnalyticsService
                                                          .logEventForSession(
                                                        eventName:
                                                            AnalyticsEventsConst
                                                                .buttonClicked,
                                                        executedEventName:
                                                            AnalyticsExecutedEventNameConst
                                                                .viewStoryButton,
                                                      );
                                                    },
                                                    onTapOnUserImage: () {
                                                      resizeStories.value =
                                                          resizeStories.value
                                                              .copyWith(
                                                                  value2: index,
                                                                  value1:
                                                                      index);
                                                    },
                                                    resize:
                                                        index == focused.value1,
                                                    resizeUserImage:
                                                        index == focused.value2,
                                                    firstPhotoNotShowed:
                                                        imageOfVideoUrl,
                                                  )),
                                      );
                                    }
                                  },
                                  physics: const ClampingScrollPhysics(),
                                  padding: EdgeInsetsDirectional.symmetric(
                                      horizontal: 10),
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        width: 15,
                                      ),
                                  itemCount:
                                      state.storiesCollections.length + 1),
                            ));
                      case GetStoriesStatus.init:
                        return Container();
                      case GetStoriesStatus.failure:
                        return SizedBox.shrink();
                      //   Center(
                      //   key: Key(WidgetsKey.storiesFailureStatusKey),
                      //   child: ElevatedButton(
                      //       onPressed: () {
                      //         GetIt.I<StoryBloc>().add(GetStoryEvent());
                      //       },
                      //       child: MyTextWidget(LocaleKeys.try_again.tr())),
                      // );
                      case GetStoriesStatus.loading:
                        return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            enabled: true,
                            child: SizedBox(
                              width: double.infinity,
                              height: 220,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 10, top: 35, bottom: 30),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                width: 100,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xff000000)
                                                          .withOpacity(0.4),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 6,
                                                    )
                                                  ],
                                                )),
                                            Positioned(
                                                left: 0,
                                                top: 0,
                                                child: CircleAvatar(
                                                  radius: 15,
                                                )),
                                            SvgPicture.asset(
                                              AppAssets.storyFilmSvg,
                                              width: 20,
                                              height: 20,
                                            ),
                                          ])),
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        width: 5,
                                      ),
                                  itemCount: 7),
                            ));
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
