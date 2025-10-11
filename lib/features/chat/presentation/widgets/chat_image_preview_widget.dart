import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../../generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ChatImagePreviewWidget extends StatefulWidget {
  final File imageFile;
  final Function(File file) onSend;
  final VoidCallback onCancel;

  const ChatImagePreviewWidget({
    Key? key,
    required this.imageFile,
    required this.onSend,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ChatImagePreviewWidget> createState() => _ChatImagePreviewWidgetState();
}

class _ChatImagePreviewWidgetState extends State<ChatImagePreviewWidget> {
  bool _isLoading = false;

  Future<void> _cropImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // انتقل إلى شاشة القص
      final result = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (context) => _CropImageScreen(imageFile: widget.imageFile),
        ),
      );

      if (result != null) {
        widget.onSend(result);
      }
    } catch (e) {
      // في حالة حدوث خطأ، أرسل الصورة الأصلية
      widget.onSend(widget.imageFile);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return GestureDetector(
        onTap: widget.onCancel, // إلغاء عند الضغط على أي مكان
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // معاينة الصورة
              Center(
                child: GestureDetector(
                  onTap: () {}, // منع الإلغاء عند الضغط على الصورة
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // زر القص
              Positioned(
                bottom: 100,
                left: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.crop, color: Colors.white),
                  onPressed: _isLoading ? null : _cropImage,
                ),
              ),

              // زر الإرسال
              Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => widget.onSend(widget.imageFile),
                ),
              ),

              // نص التعليمات
              Positioned(
                top: 50,
                child: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  width: 350,
                  height: 50,
                  child: MyTextWidget(
                    LocaleKeys.image_preview_instructions.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
              ),

              // زر الإلغاء - في الزاوية العليا اليمنى بلون أحمر
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: widget.onCancel,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// شاشة قص الصورة
class _CropImageScreen extends StatefulWidget {
  final File imageFile;

  const _CropImageScreen({required this.imageFile});

  @override
  State<_CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<_CropImageScreen> {
  late ImageProvider _image;
  final GlobalKey<SimpleImageCropperState> cropKey = GlobalKey();

  @override
  void initState() {
    _image = FileImage(widget.imageFile);
    super.initState();
  }

  Future<ui.Image> convertImageProviderToUiImage(
      ImageProvider imageProvider) async {
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer();
    stream.addListener(ImageStreamListener((image, _) {
      completer.complete(image.image);
    }));
    return completer.future;
  }

  Future<File> convertImageToFile(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final buffer = byteData.buffer;
      final directory = await getTemporaryDirectory();
      String fileFormat = widget.imageFile.path.split('.').last;
      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/$currentUnix.$fileFormat');
      await file.writeAsBytes(buffer.asUint8List());
      return file;
    } else {
      throw Exception('Failed to convert image to byte data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocaleKeys.crop_image.tr(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
        onPressed: () async {
          Image? image = await cropKey.currentState?.cropImage();
          if (image != null) {
            final ui.Image uiImage =
                await convertImageProviderToUiImage(image.image);
            final File file = await convertImageToFile(uiImage);
            Navigator.pop(context, file);
          }
        },
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size.height,
            width: size.width,
            child: SimpleImageCropper(
              key: cropKey,
              height: size.height,
              width: size.width,
              image: _image,
            ),
          ),
          Positioned(
            top: 120,
            child: Container(
              color: Colors.black.withValues(alpha: 0.8),
              alignment: Alignment.center,
              width: 350,
              height: 50,
              child: Text(
                LocaleKeys.select_image_part.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
