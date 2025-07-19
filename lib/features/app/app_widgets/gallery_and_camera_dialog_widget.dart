import 'dart:io';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:trydos/common/helper/add_lint_to_photo.dart';
import 'package:trydos/common/helper/camera_screen_story.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../common/helper/camera_screen.dart';
import '../../../common/helper/helper_functions.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../my_text_widget.dart';

class GalleryAndCameraDialogWidget extends StatelessWidget {
  final bool? fromStory;
  final bool? fromChat;
  GalleryAndCameraDialogWidget(
      {super.key,
      this.fromStory,
      this.fromChat,
      required this.onChooseFileFromGalleryAction,
      required this.onChooseFileFromCameraAction,
      this.onImagePreviewAction});

  final void Function(AssetEntity? assetEntity) onChooseFileFromGalleryAction;
  final void Function(File? file) onChooseFileFromCameraAction;
  final void Function(File file)? onImagePreviewAction;

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

                // إذا كان من المحادثة وكانت صورة، اعرض المعاينة
                if (fromChat == true && selectedFile != null) {
                  String mimeStr =
                      lookupMimeType(selectedFile!.absolute.path) ?? '';
                  var fileType = mimeStr.split('/');
                  if (fileType[0] == 'image') {
                    Navigator.of(context).pop();
                    onImagePreviewAction?.call(selectedFile!);
                    return;
                  }
                }

                onChooseFileFromCameraAction.call(selectedFile);
                Navigator.of(context).pop();
                /////////////////////////////////
                // FirebaseAnalyticsService.logEventForSession(
                //   eventName: AnalyticsEventsConst.buttonClicked,
                //   executedEventName:
                //       AnalyticsButtonsEventNameConst.uploadCameraButton,
                // );
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
                      showWarningMessage(
                          context, LocaleKeys.video_length_limit.tr());
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
                      } else if (fromChat == true &&
                          assetEntity.type == AssetType.image) {
                        // إذا كان من المحادثة وكانت صورة، اعرض المعاينة
                        File? galleryFile = await assetEntity.file;
                        if (galleryFile != null) {
                          Navigator.of(context).pop();
                          onImagePreviewAction?.call(galleryFile);
                          return;
                        }
                      } else {
                        onChooseFileFromGalleryAction.call(assetEntity);
                        Navigator.of(context).pop();
                      }
                    }
                  }
                  //    Navigator.of(context).pop();
                  /////////////////////////////////
                  // FirebaseAnalyticsService.logEventForSession(
                  //   eventName: AnalyticsEventsConst.buttonClicked,
                  //   executedEventName:
                  //       AnalyticsButtonsEventNameConst.uploadGalleryButton,
                  // );
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
