import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../common/helper/helper_functions.dart';

class StoriesList extends StatelessWidget {
  StoriesList({super.key});

  final ScrollController listViewController = ScrollController();
  final ValueNotifier<int> resizeStories = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return BlocBuilder<StoryBloc, StoryState>(
//        buildWhen: (previous, current) => previous.stories.length!=current.stories.length,
        builder: (context, state) {
//todo the ScrollConfiguration make behavior to the scroll
      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child: //todo the ValueListenableBuilder to control the effect when make longPress on the story and other action
            ValueListenableBuilder<int>(
                valueListenable: resizeStories,
                builder: (context, focused, _) {
                  return Row(
                    children: [
//                      state.uploadStoryStatus == UploadStoryStatus.loading
//                          ? CircularProgressIndicator()
//                          :
                      Expanded(
                          child: SizedBox(
                              width: 110,
                              height: 190,
                              child: ListView.separated(
                                  controller: listViewController,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                top: 18.0, bottom: 18),
                                        child: SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: Colors.green,
                                              ),
                                              width: 100,
                                              height: 120,
                                            ),
                                            onTap: () async {
                                              AssetEntity? assetEntity =
                                                  await HelperFunctions
                                                      .getAssetFromCamera(
                                                          context);

                                              if (assetEntity != null) {
                                                File file = (await assetEntity
                                                    .originFile)!;
                                                String mimeStr = lookupMimeType(
                                                        file.absolute.path) ??
                                                    '';
                                                var fileType =
                                                    mimeStr.split('/');
                                                Fluttertoast.showToast(
                                                    msg: file.absolute.path,
                                                    backgroundColor:
                                                        Colors.yellow);
                                                GetIt.I<StoryBloc>().add(
                                                    UploadStoryEvent(file));
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
                                              115;
                                        },
                                        onLongPressUp: () {
                                          resizeStories.value = -1;
                                        },
                                        onLongPressMoveUpdate: (details) {
                                          resizeStories.value = (details
                                                      .globalPosition.dx +
                                                  listViewController.offset) ~/
                                              115;
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
                                                : FutureBuilder<Uint8List>(
                                                    future: generateThumbnail(state
                                                        .stories[index]
                                                        .stories![
                                                            firstWhereNotShowed(
                                                                state
                                                                    .stories[
                                                                        index]
                                                                    .stories!)]
                                                        .fullVideoPath),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.connectionState ==
                                                              ConnectionState
                                                                  .done &&
                                                          snapshot.hasData) {
                                                        // Use the generated thumbnail as the background image
                                                        return StoryItemWidget(
                                                          index: index,
                                                          resize:
                                                              index == focused,
                                                          videoData:
                                                              snapshot.data!,
                                                        );
                                                      } else {
                                                        // Display a placeholder or loading indicator while generating the thumbnail
                                                        return Container(
                                                          child: Shimmer
                                                              .fromColors(
                                                            baseColor:
                                                                Colors.grey,
                                                            highlightColor:
                                                                Color.fromARGB(
                                                                    31,
                                                                    146,
                                                                    144,
                                                                    144),
                                                            child: Container(
                                                              width:
                                                                  size.width *
                                                                      0.23,
                                                              height:
                                                                  size.height *
                                                                      0.01,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .amber,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20)),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
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

Future<Uint8List> generateThumbnail(String videoPath) async {
  final uint8list = await VideoThumbnail.thumbnailData(
    video: videoPath,
    imageFormat: ImageFormat.PNG,
    maxWidth: 1280,
    quality: 100,
  );
  return uint8list!;
}
