import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/crope_image.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class CameraProfile extends StatefulWidget {
  final ValueNotifier<bool> visiblecamera;
  final ValueNotifier<bool> visibleSave;
  final ValueNotifier<File?> visiblePersonPhoto;
  final ValueNotifier<bool> visibleNewImage;
  final List<CameraDescription> cameras;

  CameraProfile(
    this.cameras,
    this.visiblePersonPhoto,
    this.visiblecamera,
    this.visibleNewImage,
    this.visibleSave, {
    super.key,
  });

  @override
  _CameraProfileState createState() => _CameraProfileState();
}

class _CameraProfileState extends State<CameraProfile>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController animatedController;

  //todo start timer for recording video

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller!.setFlashMode(
        FlashMode.auto,
      ); // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    // if(mounted) {
    //   setState(() {
    //     controller!.setFlashMode(
    //       FlashMode.off,
    //     );
    //   });
    // }
    controller?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    LastPagesTracker.push('CameraProfile');
    // Hide the status bar
    //    SystemChrome.setEnabledSystemUIOverlays([]);
    //;

    onNewCameraSelected(widget.cameras[0]);
    super.initState();
  }

  //todo timer for recording video

  //todo for flash camera check is the front or back camera mode
  bool _isRearCameraSelected = true;

  //todo exposure values

  //todo zoom values
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
  CameraController? controller;
  bool _isCameraInitialized = false;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
      //get  the max and min zoom of the camera
      cameraController.getMaxZoomLevel().then(
        (value) => _maxAvailableZoom = value,
      );

      cameraController.getMinZoomLevel().then(
        (value) => _minAvailableZoom = value,
      );
      //todo exposure
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Scaffold(
      body: _isCameraInitialized
          ? Container(
              width: 1.sw,
              height: 406.h,
              //        aspectRatio: 1 / controller!.value.aspectRatio,
              child: Stack(
                children: [
                  //todo show a live camera
                  controller!.buildPreview(),

                  //todo drop down item list for resolution
                  Padding(
                    padding: EdgeInsets.all(38.w),
                    child: DropdownButton<ResolutionPreset>(
                      dropdownColor: Colors.black87,
                      underline: Container(),
                      value: currentResolutionPreset,
                      items: [
                        for (ResolutionPreset preset in resolutionPresets)
                          DropdownMenuItem(
                            value: preset,
                            child: MyTextWidget(
                              preset.toString().split('.')[1].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          currentResolutionPreset = value!;
                          _isCameraInitialized = false;
                        });
                        onNewCameraSelected(controller!.description);
                      },
                      hint: const MyTextWidget("Select item"),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: 90.h,
                        start: 20.w,
                        end: 20.w,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 30.h,
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _currentZoomLevel,
                                min: _minAvailableZoom,
                                max: _maxAvailableZoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentZoomLevel = value;
                                  });
                                  await controller!.setZoomLevel(value);
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: MyTextWidget(
                                  _currentZoomLevel.toStringAsFixed(1) + 'x',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //todo row transform and take video button
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: 12,
                        start: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isCameraInitialized = false;
                                _isRearCameraSelected = !_isRearCameraSelected;
                              });

                              onNewCameraSelected(
                                widget.cameras[_isRearCameraSelected ? 0 : 1],
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.black38,
                                  size: 60,
                                ),
                                Icon(
                                  _isRearCameraSelected
                                      ? Icons.camera_front
                                      : Icons.camera_rear,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              XFile? rawImage = await takePicture();
                              File imageFile = File(rawImage!.path);

                              int currentUnix =
                                  DateTime.now().millisecondsSinceEpoch;
                              final directory =
                                  await getApplicationDocumentsDirectory();
                              String fileFormat = imageFile.path
                                  .split('.')
                                  .last;
                              await imageFile.copy(
                                '${directory.path}/$currentUnix.$fileFormat',
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CopperImage(
                                    visibleNewImage: widget.visibleNewImage,
                                    image: imageFile,
                                    visiblePersonPhoto:
                                        widget.visiblePersonPhoto,
                                    visibleSave: widget.visibleSave,
                                    visiblecamera: widget.visiblecamera,
                                  ),
                                ),
                              );
                            },
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                // Icon(Icons.circle,
                                //     color: Colors.white38, size: 80),
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 65,
                                ),
                              ],
                            ),
                          ),
                          Container(width: 90.w, height: 90.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  /*Future<void> _cropImage(String filePath) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxWidth: 400,
        maxHeight: 410);

    if (croppedFile != null) {
      widget.visiblePersonPhoto.value = File(croppedFile.path);
      widget.visiblecamera.value = false;
      widget.visibleSave.value = true;
    }
  }*/
}
