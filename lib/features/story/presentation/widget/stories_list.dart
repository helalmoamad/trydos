import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';

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
                                    //TODO FIRST ELEMENT IN THE LISTvIEW IT WILL BE THE UPLOAD BUTTON
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
//
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return GalleryAndCameraDialogWidget(
                                                                onChooseFileFromCameraAction:
                                                                    (File?
                                                                        file) async {
                                                              // final cloudinary = CloudinaryPublic('CLOUD_NAME', 'UPLOAD_PRESET', cache: false);

                                                              print('ppppppp');

                                                              if (file !=
                                                                  null) {
                                                                GetIt.I<StoryBloc>().add(
                                                                    UploadStoryEvent(
                                                                        file));

                                                                // final cloudinary =
                                                                //     CloudinaryPublic(
                                                                //         'djooohujg',
                                                                //         'v4h8xqns',
                                                                //         cache:
                                                                //             false);
                                                                // CloudinaryResponse
                                                                //     response =
                                                                //     await cloudinary
                                                                //         .uploadFile(
                                                                //   CloudinaryFile.fromFile(
                                                                //       file.path,
                                                                //       resourceType:
                                                                //           CloudinaryResourceType
                                                                //               .Image),
                                                                // );
                                                                // print('sssssc');
                                                                // print(response
                                                                //     .publicId);
                                                                // Navigator.push(
                                                                //     context,
                                                                //     MaterialPageRoute(
                                                                //       builder: (context) =>
                                                                //           CloudWidget(
                                                                //               publicId: response.publicId),
                                                                //     ));
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
                                                                // Fluttertoast
                                                                //     .showToast(
                                                                //         msg:
                                                                //             'gallrey');
                                                                // try {
                                                                //   var response = Dio().post(
                                                                //       'https://api.cloudinary.com/v1_1/djooohujg/uplaod',
                                                                //       data: FormData
                                                                //           .fromMap({
                                                                //         "file":
                                                                //             await MultipartFile.fromFile(
                                                                //           file.path,
                                                                //         ),
                                                                //         "upload_preset":
                                                                //             'v4h8xqns'
                                                                //       }));
                                                                //   print(
                                                                //       'response cloudinary $response ');
                                                                // } catch (e) {
                                                                //   debugPrint(
                                                                //       'catch cloudinary');
                                                                // }
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

                                      //TODO CHECK WITHER THE USER AUTH OR NOT SO IF AUTH IF HE HAS STORY RETURN TO IT THE
                                      //TODO LAST STORY HE UPLOAD
                                      var indexOfInitialStory;
                                      var initialStory;
                                      if (GetIt.I<PrefsRepository>()
                                              .myStoriesId ==
                                          state.stories[index].stories![0]
                                              .userId) {
                                        indexOfInitialStory = state
                                                .stories[index]
                                                .stories!
                                                .length -
                                            1;
                                        initialStory = state.stories[index]
                                            .stories![indexOfInitialStory];
                                      } else {
                                        indexOfInitialStory =
                                            firstWhereNotShowed(
                                                state.stories[index].stories!);
                                        initialStory = state.stories[index]
                                            .stories![indexOfInitialStory];
                                      }

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
                                                    firstPhotoNotShowed:
                                                        initialStory.photoPath!,
                                                  )
                                                : StoryItemWidget(
                                                    index: index,
                                                    resize: index == focused,
                                                    firstPhotoNotShowed:
                                                        initialStory
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
