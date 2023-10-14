import 'dart:io';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../common/helper/camera_screen.dart';
import '../../../common/helper/helper_functions.dart';
import '../../../generated/locale_keys.g.dart';

class GalleryAndCameraDialogWidget extends StatelessWidget {
  const GalleryAndCameraDialogWidget({super.key , required this.onChooseFileFromGalleryAction , required this.onChooseFileFromCameraAction});

  final void Function(AssetEntity? assetEntity) onChooseFileFromGalleryAction;
  final void Function(File? file) onChooseFileFromCameraAction;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
//    title: Text('choose'),
      content: Text(
          LocaleKeys
              .choose_photo_or_video_from_gallery_or_camera
              .tr()),
      actions: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment
              .spaceAround,
          children: [
            TextButton(
              onPressed:
                  () async {
                List<CameraDescription>
                cameras =
                [];
                cameras =
                await availableCameras();
                File?
                selectedFile =
                await Navigator.push<File>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraScreen(cameras)),
                );
                print('file path ${selectedFile?.path}');
                  onChooseFileFromCameraAction.call(selectedFile);
                Navigator.of(context).pop();
              },
              child: Text(LocaleKeys
                  .camera
                  .tr()),
            ),
            TextButton(
              onPressed:
                  () async {
                AssetEntity? assetEntity = await HelperFunctions.getAssetFromCamera(context);
                if (assetEntity != null) {
                  File? file = (await assetEntity.originFile);
                  onChooseFileFromCameraAction.call(file);
                }
                Navigator.of(context).pop();
              },
              child: Text(LocaleKeys
                  .gallery
                  .tr()),
            ),
          ],
        )
      ],
    );
  }
}
