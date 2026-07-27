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
                // نلتقط الـ Navigator قبل الإغلاق: بعد pop يصبح هذا الـ context
                // مُفكَّكاً (deactivated) ولا يصلح للتنقّل لاحقاً.
                final NavigatorState navigator = Navigator.of(context);
                final BuildContext rootContext = navigator.context;
                navigator.pop();
                List<CameraDescription> cameras = [];
                cameras = await availableCameras();
                if (fromStory ?? false) {
                  selectedFile = await navigator.push<File>(
                    MaterialPageRoute(
                        builder: (context) => CameraScreenStory(cameras)),
                  );
                } else {
                  selectedFile = await navigator.push<File>(
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
                    // لا pop هنا: الحوار أُغلق أصلاً أعلاه، وإعادة الإغلاق
                    // كانت تُخرج المستخدم من الصفحة التي تحته.
                    onImagePreviewAction?.call(selectedFile!);
                    return;
                  }
                }

                // حدّ حجم فيديو الستوري — يكمّل حدّ المدّة: دقيقة بجودة عالية
                // قد تتجاوز العشرة ميغابايت بسهولة.
                if ((fromStory ?? false) &&
                    selectedFile != null &&
                    !_isStoryVideoSizeAllowed(selectedFile!)) {
                  showWarningMessage(
                      rootContext, LocaleKeys.video_size_limit.tr());
                  return;
                }

                onChooseFileFromCameraAction.call(selectedFile);

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
                  // يجب التقاط الـ Navigator و context الجذر قبل الإغلاق —
                  // المستخدم يقضي ثوانٍ داخل المعرض، وبعدها يكون context الحوار
                  // مُفكَّكاً فيرمي Flutter «deactivated widget's ancestor».
                  final NavigatorState navigator = Navigator.of(context);
                  final BuildContext rootContext = navigator.context;
                  navigator.pop();

                  final AssetEntity? assetEntity =
                      await HelperFunctions.getAssetFromGallery(rootContext);
                  if (assetEntity == null) return;

                  if (assetEntity.type == AssetType.video &&
                      assetEntity.duration > 59) {
                    showWarningMessage(
                        rootContext, LocaleKeys.video_length_limit.tr());
                    return;
                  }

                  if (fromStory ?? false) {
                    // ملف غير مقروء (تالف أو محذوف من القرص مع بقاء سجلّه في
                    // MediaStore) يرجع null — و AddLinkToStory يفكّه بـ ! .
                    final File? gallaryFile = await assetEntity.file;
                    if (gallaryFile == null) {
                      showWarningMessage(
                          rootContext, LocaleKeys.error_picking_file.tr());
                      return;
                    }
                    final bool isVideo = assetEntity.type == AssetType.video;
                    if (isVideo && !_isStoryVideoSizeAllowed(gallaryFile)) {
                      showWarningMessage(
                          rootContext, LocaleKeys.video_size_limit.tr());
                      return;
                    }
                    navigator.push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddLinkToStory(
                                isVideo ? null : gallaryFile,
                                assetEntity,
                                isVideo ? gallaryFile : null,
                                onChooseFileFromGalleryAction)));
                  } else if (fromChat == true &&
                      assetEntity.type == AssetType.image) {
                    // إذا كان من المحادثة وكانت صورة، اعرض المعاينة
                    final File? galleryFile = await assetEntity.file;
                    if (galleryFile == null) {
                      showWarningMessage(
                          rootContext, LocaleKeys.error_picking_file.tr());
                      return;
                    }
                    onImagePreviewAction?.call(galleryFile);
                  } else {
                    onChooseFileFromGalleryAction.call(assetEntity);
                  }
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

/// حدّ حجم فيديو الستوري: عشرة ميغابايت.
const int _maxStoryVideoBytes = 10 * 1024 * 1024;

/// يرجع `false` **فقط** إذا كان الملف فيديو ويتجاوز الحدّ — الصور لا يشملها.
///
/// يكمّل حدّ المدّة (٥٩ ثانية) ولا يغني عنه: فيديو قصير بجودة عالية قد يتجاوز
/// الحجم، وفيديو طويل رديء قد لا يتجاوزه.
bool _isStoryVideoSizeAllowed(File file) {
  if (HelperFunctions.mediaTypeOfPath(file.path) != 'video') return true;
  try {
    return file.lengthSync() <= _maxStoryVideoBytes;
  } catch (e) {
    // تعذّر قياس الحجم: لا نمنع رفعاً صالحاً بسبب فشل قراءة.
    return true;
  }
}
