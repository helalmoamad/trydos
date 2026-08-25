import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';

import 'package:trydos/generated/locale_keys.g.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'search_image_preview_widget.dart';
import 'package:trydos/common/helper/dev_log.dart';

class SearchWithImageRelatedGemini {
  static void SelecteImageForSearch(
      {required BuildContext context, required bool fromSearch}) async {
    void _sendImageForSearch(File image) {
      GetIt.I<CategoryBloc>()
          .add(ReplyFromGeminiEvent(fromSearch: fromSearch, image: image));
    }

    void _showImagePreview(File imageFile) {
      devLog('SearchWithImageRelatedGemini: _showImagePreview called');
      devLog('SearchWithImageRelatedGemini: imageFile path = ${imageFile.path}');
      devLog(
          'SearchWithImageRelatedGemini: imageFile exists = ${imageFile.existsSync()}');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SearchImagePreviewWidget(
            imageFile: imageFile,
            onSend: _sendImageForSearch,
            onCancel: () => Navigator.of(context).pop(),
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GalleryAndCameraDialogWidget(
          fromChat: true, // إضافة هذا لتفعيل معاينة الصور
          onChooseFileFromGalleryAction: (AssetEntity? assetEntity) async {
            devLog(
                'SearchWithImageRelatedGemini: onChooseFileFromGalleryAction called');
            if (assetEntity != null) {
              // originFile يرجع null للملفات غير المقروءة.
              final File? pickedFile = await assetEntity.originFile;
              if (pickedFile == null) {
                showWarningMessage(
                    context, LocaleKeys.error_picking_file.tr());
                return;
              }
              File file = pickedFile;
              devLog(
                  'SearchWithImageRelatedGemini: gallery file path = ${file.path}');
              String mimeStr = lookupMimeType(file.absolute.path) ?? '';
              var fileType = mimeStr.split('/');

              if (fileType[0] != 'image') {
                showErrorMessage(
                    context, LocaleKeys.video_file_not_supported.tr());
              } else {
                // إغلاق ديالوج الاختيار
                Navigator.of(context).pop();
                // تأخير صغير لضمان إغلاق الديالوج
                await Future.delayed(const Duration(milliseconds: 100));
                // عرض معاينة الصورة
                _showImagePreview(file);
              }
            }
          },
          onChooseFileFromCameraAction: (File? file) async {
            devLog(
                'SearchWithImageRelatedGemini: onChooseFileFromCameraAction called');
            if (file != null) {
              devLog(
                  'SearchWithImageRelatedGemini: camera file path = ${file.path}');
              String mimeStr = lookupMimeType(file.absolute.path) ?? '';
              var fileType = mimeStr.split('/');
              if (fileType[0] != 'image') {
                showErrorMessage(
                    context, LocaleKeys.video_file_not_supported.tr());
              } else {
                // إغلاق ديالوج الاختيار
                Navigator.of(context).pop();
                // تأخير صغير لضمان إغلاق الديالوج
                await Future.delayed(const Duration(milliseconds: 100));
                // عرض معاينة الصورة
                _showImagePreview(file);
              }
            }
          },
          onImagePreviewAction: (File image) {
            devLog('SearchWithImageRelatedGemini: onImagePreviewAction called');
            devLog(
                'SearchWithImageRelatedGemini: preview image path = ${image.path}');
            // هذا سيتم استدعاؤه تلقائياً من GalleryAndCameraDialogWidget
            // عندما fromChat = true
            _showImagePreview(image);
          },
        );
      },
    );
  }
}
