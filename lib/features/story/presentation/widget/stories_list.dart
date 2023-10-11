import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/core/data/repository/prefs_repository_impl.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../authentication/presentation/pages/first_registeration_page.dart';

class StoriesList extends StatelessWidget {
  StoriesList({super.key});

  final ScrollController listViewController = ScrollController();
  final ValueNotifier<int> resizeStories = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    var size = MediaQuery.of(context).size;

    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
//todo the ScrollConfiguration make behavior to the scroll
      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child: //todo the ValueListenableBuilder to control the effect when make longPress on the story and other action
            ValueListenableBuilder<int>(
                valueListenable: resizeStories,
                builder: (context, focused, _) {
                  return Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                              width: 110,
                              height: 200,
                              child: ListView.separated(
                                  controller: listViewController,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return state.uploadStoryStatus ==
                                              UploadStoryStatus.loading
                                          ? TrydosLoader()
                                          : Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(
                                                      top: 23.0, bottom: 23),
                                              child: SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: InkWell(
                                                  child: Container(
                                                    child: Center(
                                                        child: Text('uplaod')),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      color: Colors.grey,
                                                    ),
                                                    width: 100,
                                                    height: 120,
                                                  ),
                                                  onTap: () async {
                                                    if (GetIt.I<PrefsRepository>()
                                                            .isVerifiedPhone ==
                                                        false) {
                                                      context.go(GRouter
                                                          .config
                                                          .applicationRoutes
                                                          .kRegistrationPage);
                                                    } else {
//                                                      Fluttertoast.showToast(
//                                                          msg: 'vessrify');
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return GalleryAndCameraDialogWidget(
                                                                onChooseFileFromCameraAction:
                                                                    (File?
                                                                        file) {
                                                              if (file !=
                                                                  null) {
                                                                GetIt.I<StoryBloc>().add(
                                                                    UploadStoryEvent(
                                                                        file));
                                                              }
                                                            }, onChooseFileFromGalleryAction:
                                                                    (AssetEntity?
                                                                        assetEntity) async {
                                                              if (assetEntity !=
                                                                  null) {
                                                                File file =
                                                                    (await assetEntity
                                                                        .originFile)!;
                                                                GetIt.I<StoryBloc>().add(
                                                                    UploadStoryEvent(
                                                                        file));
                                                              }
                                                            });
                                                          });
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                    } else {
                                      index = index - 1;
                                      var indexOfInitialStory =
                                          firstWhereNotShowed(
                                              state.stories[index].stories!);
                                      var initialStory = state.stories[index]
                                          .stories![indexOfInitialStory];
                                      return GestureDetector(
                                        onTap: () async {
                                          GetIt.I<StoryBloc>().add(
                                              StorySelectedEvent(
                                                  selected: index,
                                                  initialStory:
                                                      indexOfInitialStory));

                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      StoryCollection(index)));
                                        },
                                        onLongPressStart: (details) {
                                          resizeStories.value = (details
                                                      .globalPosition.dx +
                                                  listViewController.offset) ~/
                                              230;
                                        },
                                        onLongPressUp: () {
                                          resizeStories.value = -1;
                                        },
                                        onLongPressMoveUpdate: (details) {
                                          resizeStories.value = (details
                                                      .globalPosition.dx +
                                                  listViewController.offset) ~/
                                              230;
                                        },
                                        child: SizedBox(
                                            height: focused == -1 ? 170 : 190,
                                            child: (initialStory.isPhoto == 1)
                                                ? StoryItemWidget(
                                                    index: index,
                                                    resize: index == focused,
                                                    firstPhotoNotShowed: state
                                                        .stories[index]
                                                        .stories![
                                                            firstWhereNotShowed(
                                                                state
                                                                    .stories[
                                                                        index]
                                                                    .stories!)]
                                                        .photoPath!,
                                                  )
                                                : StoryItemWidget(
                                                    index: index,
                                                    resize: index == focused,
                                                    firstPhotoNotShowed: state
                                                        .stories[index]
                                                        .stories![
                                                            firstWhereNotShowed(
                                                                state
                                                                    .stories[
                                                                        index]
                                                                    .stories!)]
                                                        .fullVideoPath!
                                                        .replaceAll(
                                                            'mp4', 'png'),
                                                  )
//      }

                                            ),
                                      );
                                    }
                                  },
                                  physics: const ClampingScrollPhysics(),
                                  padding:
                                      EdgeInsetsDirectional.only(start: 10),
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        width: 5,
                                      ),
                                  itemCount: state.stories.length + 1)))
                    ],
                  );
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
