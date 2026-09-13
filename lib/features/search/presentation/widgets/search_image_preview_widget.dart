import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../../generated/locale_keys.g.dart';
import 'package:trydos/common/helper/dev_log.dart';

class SearchImagePreviewWidget extends StatefulWidget {
  final File imageFile;
  final Function(File file) onSend;
  final VoidCallback onCancel;

  const SearchImagePreviewWidget({
    Key? key,
    required this.imageFile,
    required this.onSend,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<SearchImagePreviewWidget> createState() =>
      _SearchImagePreviewWidgetState();
}

class _SearchImagePreviewWidgetState extends State<SearchImagePreviewWidget> {
  bool _isLoading = false;
  bool _fileExists = true;
  bool _imageLoaded = false;
  late ImageProvider _image;
  final GlobalKey<SimpleImageCropperState> cropKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    devLog('SearchImagePreviewWidget: initState called');
    devLog(
      'SearchImagePreviewWidget: imageFile path = ${widget.imageFile.path}',
    );
    _image = FileImage(widget.imageFile);
    _checkFileExists();
    _preloadImage();
  }

  Future<void> _checkFileExists() async {
    devLog('SearchImagePreviewWidget: checking if file exists');
    final exists = await widget.imageFile.exists();
    devLog('SearchImagePreviewWidget: file exists = $exists');
    if (mounted) {
      setState(() {
        _fileExists = exists;
      });
    }
  }

  Future<void> _preloadImage() async {
    try {
      // تحميل الصورة مسبقاً
      final ImageStream stream = _image.resolve(ImageConfiguration.empty);
      final Completer<void> completer = Completer();
      stream.addListener(
        ImageStreamListener((image, _) {
          completer.complete();
        }),
      );
      await completer.future;
      if (mounted) {
        setState(() {
          _imageLoaded = true;
        });
      }
    } catch (e) {
      devLog('SearchImagePreviewWidget: error preloading image: $e');
    }
  }

  Future<ui.Image> convertImageProviderToUiImage(
    ImageProvider imageProvider,
  ) async {
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer();
    stream.addListener(
      ImageStreamListener((image, _) {
        completer.complete(image.image);
      }),
    );
    return completer.future;
  }

  Future<File> convertImageToFile(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final buffer = byteData.buffer;
      final directory = await getTemporaryDirectory();
      // `split('.').last` returns the whole path when the picked file has no
      // dot in its name, and that path carries separators — the write would
      // then land outside the temp directory. Keep it only when it looks like
      // a real extension.
      final String rawFormat = widget.imageFile.path.split('.').last;
      final String fileFormat = RegExp(
        r'^[A-Za-z0-9]{1,5}$',
      ).hasMatch(rawFormat)
          ? rawFormat
          : 'png';
      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      // nosemgrep: trydos-sec-path-from-interpolation -- fileFormat is checked against ^[A-Za-z0-9]{1,5}$ above; currentUnix is a timestamp
      final file = File('${directory.path}/$currentUnix.$fileFormat');
      await file.writeAsBytes(buffer.asUint8List());
      return file;
    } else {
      throw Exception('Failed to convert image to byte data');
    }
  }

  Future<void> _sendImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // محاولة الحصول على الصورة المقصوصة
      Image? croppedImage = await cropKey.currentState?.cropImage();
      if (croppedImage != null) {
        // إذا تم تحديد جزء من الصورة، أرسل الجزء المحدد
        final ui.Image uiImage = await convertImageProviderToUiImage(
          croppedImage.image,
        );
        final File file = await convertImageToFile(uiImage);
        widget.onSend(file);
      } else {
        // إذا لم يتم تحديد جزء، أرسل الصورة كاملة
        widget.onSend(widget.imageFile);
      }

      // إغلاق شاشة المعاينة بعد الإرسال
      Navigator.of(context).pop();
    } catch (e) {
      // في حالة حدوث خطأ، أرسل الصورة الأصلية
      widget.onSend(widget.imageFile);
      // إغلاق شاشة المعاينة حتى في حالة الخطأ
      Navigator.of(context).pop();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // معاينة الصورة مع إمكانية القص
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _fileExists
                      ? _imageLoaded
                            ? SimpleImageCropper(
                                key: cropKey,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                width: MediaQuery.of(context).size.width * 0.9,
                                image: _image,
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                      : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'الملف غير موجود',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // زر الإرسال - في الزاوية اليسرى السفلية
            Positioned(
              bottom: 40.h,
              left: 20.w,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _isLoading ? null : _sendImage,
              ),
            ),

            // نص التعليمات
            Positioned(
              top: 50,
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                width: 350.w,
                height: 50.h,
                child: MyTextWidget(
                  LocaleKeys.select_image_part.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            // زر الإلغاء - في الزاوية العليا اليمنى بلون أحمر
            Positioned(
              top: 40.h,
              right: 20.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 28.h),
                  onPressed: widget.onCancel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
