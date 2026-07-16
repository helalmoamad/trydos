import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart' as dartz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:shimmer/shimmer.dart';

import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/update_user_name_widget.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection_page_view.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/my_text_widget.dart';
import '../../data/models/get_stories_model.dart';
import '../bloc/story_state.dart';

class StoriesList extends StatefulWidget {
  final ValueNotifier<bool> isShowPanelForVerified;
  const StoriesList({super.key, required this.isShowPanelForVerified});
  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  bool allowedToUploadStories = false;
  Future<void> _loadAllowedToUploadStories() async {
    allowedToUploadStories = await prefsRepository.getAllowedToUploadStories();
  }

  final ScrollController listViewController = ScrollController();
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<dartz.Tuple2<int, int>> resizeStories = ValueNotifier(
    const dartz.Tuple2(-1, -1),
  );

  double _lastScrollPosition = 0;
  Timer? debounce;
  @override
  void initState() {
    _loadAllowedToUploadStories();
    listViewController.addListener(() {
      if (debounce?.isActive ?? false) {
        debounce!.cancel();
      }
      debounce = Timer(const Duration(milliseconds: 600), () {
        if (listViewController.offset >=
            (listViewController.position.maxScrollExtent * 0.6)) {
          BlocProvider.of<StoryBloc>(
            context,
          ).add(const GetStoryEvent(withPaginition: true));
        }
        if (resizeStories.value.value1 != -1 ||
            resizeStories.value.value2 != -1) {
          disableResizing();
        }

        double currentPosition = listViewController.position.pixels;
        if ((currentPosition - _lastScrollPosition).abs() >= 20) {
          debugPrint(listViewController.position.pixels.toString());
          _lastScrollPosition = currentPosition;
          /////////////////////////////
          // FirebaseAnalyticsService.logEventForSession(
          //   eventName: AnalyticsEventsConst.buttonClicked,
          //   executedEventName:
          //       AnalyticsButtonsEventNameConst.scrollStoriesInHomeEvent,
          // );
        }
      });
    });
    super.initState();
  }

  void disableResizing() {
    resizeStories.value = resizeStories.value.copyWith(value2: -1, value1: -1);
  }

  @override
  void dispose() {
    listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*  FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };*/
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.loginToStoriesStatus != current.loginToStoriesStatus,
      builder: (context, authState) {
        //todo the ScrollConfiguration make behavior to the scroll
        return BlocBuilder<StoryBloc, StoryState>(
          buildWhen: (previous, current) =>
              previous.uploadStoryCloudinaryStatus !=
                  current.uploadStoryCloudinaryStatus ||
              previous.getStoryWithPagintionStatusLoading !=
                  current.getStoryWithPagintionStatusLoading ||
              previous.getStoriesStatus != current.getStoriesStatus ||
              previous.deleteStoryStatus != current.deleteStoryStatus,
          builder: (context, state) {
            List<CollectionStoryModel> storiesCollections = List.of(
              state.storiesCollections,
            );
            storiesCollections.removeWhere(
              (element) => element.stories?.length == 0,
            );

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
                              ? const Key(WidgetsKeys.storiesSuccessStatusKey)
                              : null,
                          height: 220.h,
                          child: ListView.separated(
                            controller: listViewController,
                            itemBuilder: (context, index) {
                              if (index == storiesCollections.length + 1) {
                                return Container(
                                  height:
                                      !(state
                                          .getStoryWithPagintionStatusLoading)
                                      ? 0
                                      : 50.h,
                                  width:
                                      !(state
                                          .getStoryWithPagintionStatusLoading)
                                      ? 0
                                      : 50.h,
                                  child:
                                      !(state
                                          .getStoryWithPagintionStatusLoading)
                                      ? const SizedBox.shrink()
                                      : TrydosLoader(size: 20.w),
                                );
                              }
                              //todo FIRST ELEMENT IN THE LISTvIEW IT WILL BE THE UPLOAD BUTTON
                              if (index == 0) {
                                if (!allowedToUploadStories) {
                                  return const SizedBox.shrink();
                                }
                                return state.uploadStoryCloudinaryStatus ==
                                        UploadStoryCloudinaryStatus.loading
                                    ? TrydosLoader()
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 40.h),
                                          Material(
                                            color: const Color.fromARGB(
                                              0,
                                              255,
                                              222,
                                              222,
                                            ),
                                            child: SizedBox(
                                              width: 100.w,
                                              height: 150.h,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                    child: MyCachedNetworkImage(
                                                      imageUrl:
                                                          prefsRepository
                                                              .myProfilePhoto ??
                                                          "",
                                                      width: 100.w,
                                                      imageFit: BoxFit.cover,
                                                      height: 150.h,
                                                    ),
                                                  ),

                                                  Container(
                                                    width: 100.w,
                                                    height: 150.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                      color: Colors.grey,
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 40.w,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    highlightColor:
                                                        Colors.transparent,
                                                    splashColor:
                                                        Colors.transparent,
                                                    child:
                                                        (authState
                                                                .loginToStoriesStatus ==
                                                            LoginToStoriesStatus
                                                                .loading)
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20.r,
                                                                ),
                                                            child: Container(
                                                              color:
                                                                  Colors.grey,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 150.h,
                                                              width: 100.w,
                                                              child:
                                                                  TrydosLoader(
                                                                    size: 25,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                          )
                                                        : Container(
                                                            child: Center(
                                                              child:
                                                                  MyTextWidget(
                                                                    LocaleKeys
                                                                        .upload
                                                                        .tr(),
                                                                  ),
                                                            ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20.0.r,
                                                                  ),
                                                              color:
                                                                  (prefsRepository
                                                                              .myProfilePhoto ==
                                                                          null ||
                                                                      prefsRepository
                                                                              .myProfilePhoto ==
                                                                          "")
                                                                  ? Colors.grey
                                                                  // ignore: deprecated_member_use
                                                                  : Colors.grey
                                                                    // ignore: deprecated_member_use
                                                                    .withOpacity(
                                                                      0.7,
                                                                    ),
                                                            ),
                                                            width: 100.w,
                                                          ),
                                                    onTap: () async {
                                                      if (authState
                                                              .loginToStoriesStatus ==
                                                          LoginToStoriesStatus
                                                              .loading) {
                                                        return;
                                                      }
                                                      disableResizing();
                                                      if (GetIt.I<
                                                                    PrefsRepository
                                                                  >()
                                                                  .isVerifiedPhone ==
                                                              false ||
                                                          GetIt.I<
                                                                PrefsRepository
                                                              >()
                                                              .storiesToken
                                                              .isNullOrEmpty) {
                                                        widget
                                                                .isShowPanelForVerified
                                                                .value =
                                                            true;
                                                      } else if ((GetIt.I<
                                                                    PrefsRepository
                                                                  >()
                                                                  .myMarketName
                                                                  ?.length ??
                                                              0) <
                                                          3) {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder:
                                                              (
                                                                BuildContext
                                                                context,
                                                              ) {
                                                                return UpdateUserNameWidget();
                                                              },
                                                        );
                                                      } else {
                                                        // FirebaseAnalyticsService
                                                        //     .logEventForSession(
                                                        //   eventName:
                                                        //       AnalyticsEventsConst.buttonClicked,
                                                        //   executedEventName:
                                                        //       AnalyticsButtonsEventNameConst.uploadStoryButton,
                                                        // );
                                                        //////////////////////////////////////
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return GalleryAndCameraDialogWidget(
                                                              fromStory: true,
                                                              onChooseFileFromCameraAction: (File? file) async {
                                                                if (file !=
                                                                    null) {
                                                                  GetIt.I<
                                                                        StoryBloc
                                                                      >()
                                                                      .add(
                                                                        UploadStoryCloudinaryEvent(
                                                                          file,
                                                                        ),
                                                                      );

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
                                                                  // FirebaseAnalyticsService.logEventForSession(
                                                                  //   eventName: AnalyticsEventsConst.buttonClicked,
                                                                  //   executedEventName: AnalyticsButtonsEventNameConst.confirmUploadStoryButton,
                                                                  // );
                                                                }
                                                              },
                                                              onChooseFileFromGalleryAction:
                                                                  (
                                                                    AssetEntity?
                                                                    assetEntity,
                                                                  ) async {
                                                                    if (assetEntity !=
                                                                        null) {
                                                                      File
                                                                      file = (await assetEntity
                                                                          .originFile)!;
                                                                      GetIt.I<
                                                                            StoryBloc
                                                                          >()
                                                                          .add(
                                                                            UploadStoryCloudinaryEvent(
                                                                              file,
                                                                            ),
                                                                          );
                                                                    }
                                                                  },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
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
                                if (GetIt.I<PrefsRepository>().myStoriesId ==
                                    storiesCollections[index]
                                        .stories![0]
                                        .userId) {
                                  indexOfInitialStory =
                                      storiesCollections[index].stories!
                                          .lastIndexWhere(
                                            (element) =>
                                                element.isSeen == false,
                                          );
                                  indexOfInitialStory =
                                      indexOfInitialStory == -1
                                      ? 0
                                      : indexOfInitialStory;
                                } else {
                                  indexOfInitialStory = firstWhereNotShowed(
                                    storiesCollections[index].stories!,
                                  );
                                }
                                initialStory = storiesCollections[index]
                                    .stories![indexOfInitialStory];

                                String? imageOfVideoUrl;
                                if (initialStory.isPhoto != 1) {
                                  if (mediaServerIsS3 &&
                                      !(initialStory.fullVideoPath?.contains(
                                            "res.cloudinary.com",
                                          ) ??
                                          true)) {
                                    imageOfVideoUrl =
                                        initialStory.fullVideoPath! +
                                        "?target=snapshot";
                                  } else {
                                    int index = initialStory.fullVideoPath!
                                        .lastIndexOf('.');
                                    imageOfVideoUrl =
                                        initialStory.fullVideoPath!.substring(
                                          0,
                                          index,
                                        ) +
                                        '.png';
                                  }
                                }
                                return AnimatedPadding(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.only(
                                    left:
                                        focused.value1 != -1 &&
                                            focused.value1 == (index - 1)
                                        ? 30.w
                                        : 0,
                                  ),
                                  child: GestureDetector(
                                    onLongPressStart: (details) {
                                      bool isFirstPress =
                                          resizeStories.value.value1 == -1;
                                      resizeStories.value = resizeStories.value
                                          .copyWith(
                                            value1:
                                                (details.globalPosition.dx +
                                                    listViewController.offset -
                                                    115.w) ~/
                                                115.w,
                                          );
                                      if (details.localPosition.dx <=
                                              (40.w +
                                                  resizeStories.value.value1 *
                                                      115.w +
                                                  (resizeStories.value.value1 ==
                                                          resizeStories
                                                              .value
                                                              .value2
                                                      ? 45.w
                                                      : 0)) &&
                                          details.localPosition.dy <=
                                              (40.h +
                                                  (isFirstPress ? 20.h : 0) +
                                                  (resizeStories.value.value1 ==
                                                          resizeStories
                                                              .value
                                                              .value2
                                                      ? 45.h
                                                      : 0))) {
                                        resizeStories.value = resizeStories
                                            .value
                                            .copyWith(
                                              value2:
                                                  resizeStories.value.value1,
                                            );
                                      } else {
                                        resizeStories.value = resizeStories
                                            .value
                                            .copyWith(value2: -1);
                                      }
                                    },
                                    onLongPressUp: () {
                                      resizeStories.value =
                                          resizeStories.value = resizeStories
                                              .value
                                              .copyWith(value2: -1, value1: -1);
                                    },
                                    onLongPressMoveUpdate: (details) {
                                      resizeStories.value = resizeStories.value
                                          .copyWith(
                                            value1:
                                                (details.globalPosition.dx +
                                                    listViewController.offset -
                                                    115.w) ~/
                                                115.w,
                                          );
                                      if (details.localPosition.dx <=
                                              (40.w +
                                                  resizeStories.value.value1 *
                                                      115.w +
                                                  (resizeStories.value.value1 ==
                                                          resizeStories
                                                              .value
                                                              .value2
                                                      ? 50.w
                                                      : 0)) &&
                                          details.localPosition.dy <=
                                              (40.h +
                                                  (resizeStories.value.value1 ==
                                                          resizeStories
                                                              .value
                                                              .value2
                                                      ? 50.h
                                                      : 0))) {
                                        resizeStories.value = resizeStories
                                            .value
                                            .copyWith(
                                              value2:
                                                  resizeStories.value.value1,
                                            );
                                      } else {
                                        resizeStories.value = resizeStories
                                            .value
                                            .copyWith(value2: -1);
                                      }
                                    },
                                    child: (initialStory.isPhoto == 1)
                                        ? StoryItemWidget(
                                            index: index,
                                            onTapOnStoryAction: () async {
                                              GetIt.I<StoryBloc>().add(
                                                StorySelectedEvent(
                                                  collectionIndex: index,
                                                  currentPage: index,
                                                  selectedStoryIndexInCollection:
                                                      indexOfInitialStory,
                                                ),
                                              );
                                              // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> StoryCollectionPageView(
                                              //             initialPage:
                                              //             index)));
                                              pushOverscrollRoute(
                                                context: context,
                                                child: StoryCollectionPageView(
                                                  initialPage: index,
                                                ),
                                                dragToPopDirection:
                                                    DragToPopDirection.toBottom,
                                                fullscreenDialog: true,
                                              );
                                              disableResizing();
                                              //////////////////////////////
                                              // FirebaseAnalyticsService
                                              //     .logEventForSession(
                                              //   eventName:
                                              //       AnalyticsEventsConst
                                              //           .buttonClicked,
                                              //   executedEventName:
                                              //       AnalyticsButtonsEventNameConst
                                              //           .viewStoryButton,
                                              // );
                                            },
                                            onTapOnUserImage: () {
                                              resizeStories.value =
                                                  resizeStories.value.copyWith(
                                                    value2: index,
                                                    value1: index,
                                                  );
                                            },
                                            resize: index == focused.value1,
                                            resizeUserImage:
                                                index == focused.value2,
                                            firstPhotoNotShowed:
                                                initialStory.photoPath,
                                          )
                                        : StoryItemWidget(
                                            index: index,
                                            onTapOnStoryAction: () async {
                                              disableResizing();
                                              GetIt.I<StoryBloc>().add(
                                                StorySelectedEvent(
                                                  collectionIndex: index,
                                                  currentPage: index,
                                                  selectedStoryIndexInCollection:
                                                      indexOfInitialStory,
                                                ),
                                              );
                                              // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> StoryCollectionPageView(
                                              //     initialPage:
                                              //     index)));
                                              pushOverscrollRoute(
                                                context: context,
                                                child: StoryCollectionPageView(
                                                  initialPage: index,
                                                ),
                                                dragToPopDirection:
                                                    DragToPopDirection.toBottom,
                                                fullscreenDialog: true,
                                              );
                                              // Navigator.push(context, MaterialPageRoute(builder: (_)=> StoryCollection(index ,   key: UniqueKey()),));
                                              //////////////////////////////
                                              // FirebaseAnalyticsService
                                              //     .logEventForSession(
                                              //   eventName:
                                              //       AnalyticsEventsConst
                                              //           .buttonClicked,
                                              //   executedEventName:
                                              //       AnalyticsButtonsEventNameConst
                                              //           .viewStoryButton,
                                              // );
                                            },
                                            onTapOnUserImage: () {
                                              resizeStories.value =
                                                  resizeStories.value.copyWith(
                                                    value2: index,
                                                    value1: index,
                                                  );
                                            },
                                            resize: index == focused.value1,
                                            resizeUserImage:
                                                index == focused.value2,
                                            firstPhotoNotShowed:
                                                imageOfVideoUrl,
                                          ),
                                  ),
                                );
                              }
                            },
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 10.w,
                            ),
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 15.w),
                            itemCount: storiesCollections.length + 2,
                          ),
                        );
                      case GetStoriesStatus.init:
                        return Container();
                      case GetStoriesStatus.failure:
                        return const SizedBox.shrink();
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
                          child: SizedBox(
                            width: double.infinity,
                            height: 220.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 10.w,
                                  top: 35.h,
                                  bottom: 30.h,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100.w,
                                      height: 150.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.0.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff000000)
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.4),
                                            offset: const Offset(0, 3),
                                            blurRadius: 6.r,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: CircleAvatar(radius: 15.r),
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.storyFilmSvg,
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                  ],
                                ),
                              ),
                              separatorBuilder: (context, index) =>
                                  SizedBox(width: 5.w),
                              itemCount: 7,
                            ),
                          ),
                        );
                    }
                  }();
                },
              ),
            );
          },
        );
      },
    );
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
