import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:trydos/config/theme/typography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class CopperImage extends StatefulWidget {
  File image;
  final ValueNotifier<bool> visiblecamera;
  final ValueNotifier<bool> visibleSave;
  final ValueNotifier<File?> visiblePersonPhoto;
  final ValueNotifier<bool> visibleNewImage;
  CopperImage(
      {Key? key,
      required this.image,
      required this.visiblePersonPhoto,
      required this.visibleNewImage,
      required this.visiblecamera,
      required this.visibleSave})
      : super(key: key);

  @override
  _CopperImageState createState() => _CopperImageState();
}

class _CopperImageState extends State<CopperImage> {
  late ImageProvider _image;
  final GlobalKey<SimpleImageCropperState> cropKey = GlobalKey();

  @override
  void initState() {
    _image = FileImage(widget.image);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<ui.Image> convertImageProviderToUiImage(
        ImageProvider imageProvider) async {
      final ImageStream stream =
          imageProvider.resolve(ImageConfiguration.empty);
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
        String fileFormat = widget.image.path.split('.').last;
        int currentUnix = DateTime.now().millisecondsSinceEpoch;
        final file = File('${directory.path}/$currentUnix.$fileFormat');
        await file.writeAsBytes(buffer.asUint8List());
        return file;
      } else {
        throw Exception('Failed to convert image to byte data');
      }
    }

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.crop),
        onPressed: () async {
          Image? image = await cropKey.currentState?.cropImage();
          if (image != null) {
            final ui.Image uiImage =
                await convertImageProviderToUiImage(image.image);
            final File file = await convertImageToFile(uiImage);

            Navigator.pop(context);
            widget.visibleNewImage.value = true;
            widget.visiblePersonPhoto.value = file;
            widget.visiblecamera.value = false;
            widget.visibleSave.value = true;
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
              )),
          Positioned(
              top: 50,
              child: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  width: 350,
                  height: 50,
                  child: Text(
                    LocaleKeys.select_the_part_of_the_image.tr(),
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: const ui.Color.fromARGB(255, 253, 253, 253),
                        letterSpacing: 0.18,
                        fontSize: 14,
                        height: 1.2),
                  )))
        ],
      ),
    );
  }
}
