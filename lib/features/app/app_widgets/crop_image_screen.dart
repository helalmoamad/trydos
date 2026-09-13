import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';

import '../../../generated/locale_keys.g.dart';

/// شاشة قص صورة مشتركة — تُدفَع عبر [Navigator.push] وترجع الملف المقصوص،
/// أو `null` إذا ألغى المستخدم. تستخدمها معاينة صور الدردشة وشاشة رفع الستوري.
class CropImageScreen extends StatefulWidget {
  final File imageFile;

  const CropImageScreen({required this.imageFile, super.key});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
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
          if (image == null) return;
          final ui.Image uiImage =
              await convertImageProviderToUiImage(image.image);
          final File file = await convertImageToFile(uiImage);
          if (!context.mounted) return;
          Navigator.pop(context, file);
        },
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
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
