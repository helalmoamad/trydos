import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/app_widgets/crop_image_screen.dart';
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
          builder: (context) => CropImageScreen(imageFile: widget.imageFile),
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
