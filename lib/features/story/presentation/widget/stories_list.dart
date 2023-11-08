import 'dart:io';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../app/trydos_shimmer_loading.dart';

class StoriesList extends StatefulWidget {
  StoriesList({super.key});

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  final ScrollController listViewController = ScrollController();

  final ValueNotifier<dartz.Tuple2<int ,int >> resizeStories = ValueNotifier(dartz.Tuple2(-1 , -1));

  @override
  void initState() {
    listViewController.addListener(() {
      disableResizing();
    });
    super.initState();
  }

  void disableResizing(){
    resizeStories.value = resizeStories.value.copyWith(
        value2: -1,
        value1: -1
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
//todo the ScrollConfiguration make behavior to the scroll
      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child: //todo the ValueListenableBuilder to control the effect when make longPress on the story and other action
        ValueListenableBuilder<dartz.Tuple2<int,int>>(
            valueListenable: resizeStories,
            builder: (context, focused, _) {
              return () {
                switch (state.getStoriesStatus) {
                  case GetStoriesStatus.success:
                    return SizedBox(
                        height:  220,
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
                                    SizedBox(
                                      width: 100,
                                      height: 150,
                                      child: InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: Container(
                                          child: Center(
                                              child: Text(
                                                  'uplaod')),
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
                                          } else {
//
                                            showDialog(
                                                context:
                                                context,
                                                builder:
                                                    (BuildContext
                                                context) {
                                                  return GalleryAndCameraDialogWidget(onChooseFileFromCameraAction:
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
                                                    }
                                                  }, onChooseFileFromGalleryAction:
                                                      (AssetEntity?
                                                  assetEntity) async {
                                                    if (assetEntity !=
                                                        null) {
                                                      File
                                                      file =
                                                      (await assetEntity
                                                          .originFile)!;
                                                      GetIt.I<StoryBloc>().add(
                                                          UploadStoryCloudinaryEvent(
                                                              file));
                                                    }
                                                  });
                                                });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                //todo cause we take the index 0 to the upload button
                                index = index - 1;
                                //TODO CHECK WITHER THE USER AUTH OR NOT SO IF AUTH IF HE HAS STORY RETURN TO IT THE
                                //TODO LAST STORY HE UPLOAD ELSE MAKE THE FIRST STORY NOT SHOWED IN FRONT
                                var indexOfInitialStory;
                                var initialStory;
                                if (GetIt.I<PrefsRepository>()
                                    .myStoriesId ==
                                    state.stories[index].stories![0]
                                        .userId) {
                                  indexOfInitialStory = state
                                      .stories[index].stories!
                                      .lastIndexWhere((element) =>
                                  element.isSeen == false);
                                  indexOfInitialStory =
                                  indexOfInitialStory == -1
                                      ? 0
                                      : indexOfInitialStory;
                                  initialStory =
                                  state.stories[index].stories![
                                  indexOfInitialStory];
                                } else {
                                  indexOfInitialStory =
                                      firstWhereNotShowed(state
                                          .stories[index].stories!);
                                  initialStory =
                                  state.stories[index].stories![
                                  indexOfInitialStory];
                                }

                                return AnimatedPadding(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.only(left: focused.value1 != -1 && focused.value1 == (index  - 1)  ? 30 : 0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      disableResizing();
                                      GetIt.I<StoryBloc>().add(
                                          StorySelectedEvent(
                                              selected: index,
                                              initialStory:
                                              indexOfInitialStory));
                                      context.go(GRouter.config.applicationRoutes.kStoryCollectionsPagePath + '?id=$index');
                                    },
                                    onLongPressStart: (details) {
                                      bool isFirstPress = resizeStories.value.value1 == -1  ;
                                      resizeStories.value = resizeStories.value.copyWith(
                                          value1: (details.globalPosition.dx +
                                              listViewController
                                                  .offset -
                                              115) ~/
                                              115
                                      );
                                      if(details.localPosition.dx <=(40 + resizeStories.value.value1 * 115 + (resizeStories.value.value1 == resizeStories.value.value2 ? 45 : 0)) && details.localPosition.dy<=(40 + (isFirstPress ? 20 : 0) + (resizeStories.value.value1 == resizeStories.value.value2 ? 45 : 0))){

                                        resizeStories.value = resizeStories.value.copyWith(
                                            value2: resizeStories.value.value1
                                        );

                                      }else{
                                        resizeStories.value = resizeStories.value.copyWith(
                                            value2: -1
                                        );
                                      }
                                    },
                                    onLongPressUp: () {
                                      resizeStories.value = resizeStories.value = resizeStories.value.copyWith(
                                          value2: -1,value1: -1
                                      );
                                    },
                                    onLongPressMoveUpdate: (details) {
                                      resizeStories.value = resizeStories.value.copyWith(
                                          value1: (details.globalPosition.dx +
                                              listViewController
                                                  .offset -
                                              115) ~/
                                              115
                                      );
                                      if(details.localPosition.dx <=(40 + resizeStories.value.value1 * 115 +(resizeStories.value.value1 == resizeStories.value.value2 ? 50 : 0)) && details.localPosition.dy<=(40 + (resizeStories.value.value1 == resizeStories.value.value2 ? 50 : 0))){

                                        resizeStories.value = resizeStories.value.copyWith(
                                            value2: resizeStories.value.value1
                                        );

                                      }else{
                                        resizeStories.value = resizeStories.value.copyWith(
                                            value2: -1
                                        );
                                      }
                                    },
                                    child: (initialStory
                                        .isPhoto ==
                                        1)
                                        ? StoryItemWidget(
                                      index: index,
                                      onTapOnUserImage: (){
                                        resizeStories.value = resizeStories.value.copyWith(
                                            value2: index,
                                            value1: index
                                        );
                                      },
                                      resize: index == focused.value1,
                                      resizeUserImage: index == focused.value2,
                                      firstPhotoNotShowed:
                                      initialStory
                                          .photoPath,
                                    )
                                        : StoryItemWidget(
                                      index: index,
                                      onTapOnUserImage: (){
                                        resizeStories.value = resizeStories.value.copyWith(
                                            value2: index,
                                            value1: index
                                        );
                                      },
                                      resize: index == focused.value1,
                                      resizeUserImage: index == focused.value2,
                                      firstPhotoNotShowed:
                                      initialStory
                                          .fullVideoPath!
                                          .replaceAll(
                                          'mp4',
                                          'png'),
                                    ),
                                  ),
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
                            itemCount: state.stories.length + 1));
                  case GetStoriesStatus.init:
                    return Container();
                  case GetStoriesStatus.failure:
                    return Center(
                      child: ElevatedButton(
                          onPressed: () {
                            GetIt.I<StoryBloc>().add(GetStoryEvent());
                          },
                          child: Text('Try Again')),
                    );
                  case GetStoriesStatus.loading:
                    return Container(
                      width: double.infinity,
                      height: 170,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => Padding(
                              padding:
                              EdgeInsetsDirectional.only(start: 20 , top: 35),
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
              return Container();
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
