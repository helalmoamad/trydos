import 'dart:io';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trydos/common/helper/add_lint_to_photo.dart';
import 'package:trydos/common/helper/camera_screen_story.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../common/helper/camera_screen.dart';
import '../../../common/helper/helper_functions.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../my_text_widget.dart';

class GalleryAndCameraDialogWidget extends StatelessWidget {
  final bool? fromStory;
  GalleryAndCameraDialogWidget(
      {super.key,
      this.fromStory,
      required this.onChooseFileFromGalleryAction,
      required this.onChooseFileFromCameraAction});

  final void Function(AssetEntity? assetEntity) onChooseFileFromGalleryAction;
  final void Function(File? file) onChooseFileFromCameraAction;

  @override
  Widget build(BuildContext context) {
    File? selectedFile;
    return AlertDialog(
//    title: MyTextWidget('choose'),
      content: MyTextWidget(
          LocaleKeys.choose_photo_or_video_from_gallery_or_camera.tr()),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () async {
                List<CameraDescription> cameras = [];
                cameras = await availableCameras();
                if (fromStory ?? false) {
                  selectedFile = await Navigator.push<File>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraScreenStory(cameras)),
                  );
                } else {
                  selectedFile = await Navigator.push<File>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraScreen(cameras)),
                  );
                }

                onChooseFileFromCameraAction.call(selectedFile);
                Navigator.of(context).pop();
                /////////////////////////////////
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.buttonClicked,
                  executedEventName:
                      AnalyticsExecutedEventNameConst.uploadCameraButton,
                );
              },
              child: MyTextWidget(LocaleKeys.camera.tr()),
            ),
            Builder(builder: (context) {
              return TextButton(
                onPressed: () async {
                  AssetEntity? assetEntity;
                  assetEntity =
                      await HelperFunctions.getAssetFromGallery(context);
                  if (assetEntity != null) {
                    if (assetEntity.type == AssetType.video &&
                        assetEntity.duration > 59) {
                      showWarningMessage(context,
                          'Video length must not be longer than 59 seconds');
                    } else {
                      if (fromStory ?? false) {
                        File? gallaryFile = await assetEntity.file;
                        Navigator.of(context).pushReplacement(PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                AddLinkToStory(
                                    assetEntity?.type == AssetType.video
                                        ? null
                                        : gallaryFile,
                                    assetEntity,
                                    assetEntity?.type != AssetType.video
                                        ? null
                                        : gallaryFile,
                                    onChooseFileFromGalleryAction)));
                      } else {
                        onChooseFileFromGalleryAction.call(assetEntity);
                        Navigator.of(context).pop();
                      }
                    }
                  }
                  //    Navigator.of(context).pop();
                  /////////////////////////////////
                  FirebaseAnalyticsService.logEventForSession(
                    eventName: AnalyticsEventsConst.buttonClicked,
                    executedEventName:
                        AnalyticsExecutedEventNameConst.uploadGalleryButton,
                  );
                },
                child: MyTextWidget(LocaleKeys.gallery.tr()),
              );
            })
          ],
        )
      ],
    );
  }
}
