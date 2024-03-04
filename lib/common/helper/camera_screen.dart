import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trydos/common/helper/show_message.dart';

import '../../features/app/my_text_widget.dart';

class CameraScreen extends StatefulWidget {
  List<CameraDescription> cameras;

  CameraScreen(this.cameras);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController animatedController;

  //todo start timer for recording video
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _seconds = 0;
    });
  }

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
    _timer?.cancel();
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
// Hide the status bar
//    SystemChrome.setEnabledSystemUIOverlays([]);
//;
    animatedController = AnimationController(vsync: this);
    animatedController.stop();
    animatedController.reset();
    animatedController.duration = const Duration(seconds: 60);
    animatedController.addListener(() {
      if(animatedController.status == AnimationStatus.completed){
        _isRecordingInProgress = false;
        onRecordVideoFinished(lengthMoreThan60: true);
      }
    });
    onNewCameraSelected(widget.cameras[0]);
    super.initState();
  }

//todo timer for recording video
   Timer? _timer;
  int _seconds = 0;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;

//todo for flash camera check is the front or back camera mode
  bool _isRearCameraSelected = true;

//  todo flash
  FlashMode? _currentFlashMode;

  //todo exposure values
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

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
      cameraController
          .getMaxZoomLevel()
          .then((value) => _maxAvailableZoom = value);

      cameraController
          .getMinZoomLevel()
          .then((value) => _minAvailableZoom = value);
//todo exposure
      cameraController
          .getMinExposureOffset()
          .then((value) => _minAvailableExposureOffset = value);

      cameraController
          .getMaxExposureOffset()
          .then((value) => _maxAvailableExposureOffset = value);
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
    _currentFlashMode = controller!.value.flashMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.86,
//        aspectRatio: 1 / controller!.value.aspectRatio,
                  child: Stack(children: [
                    //todo show a live camera
                    controller!.buildPreview(),

                    _isVideoCameraSelected
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(top: 55.0),
                              child: MyTextWidget(
                                '0 : $_seconds',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : Container(),

//todo drop down item list for resolution
                    Padding(
                      padding: const EdgeInsets.all(38.0),
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
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            currentResolutionPreset = value!;
                            _isCameraInitialized = false;
                          });
                          onNewCameraSelected(controller!.description);
                        },
                        hint: MyTextWidget("Select item"),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            bottom: 90, start: 20, end: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyTextWidget(
                                    _currentZoomLevel.toStringAsFixed(1) + 'x',
                                    style: TextStyle(color: Colors.white),
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
                            bottom: 12, start: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isCameraInitialized = false;
                                  _isRearCameraSelected =
                                      !_isRearCameraSelected;
                                });

                                onNewCameraSelected(
                                  widget.cameras[_isRearCameraSelected ? 0 : 1],
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
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
                            _isVideoCameraSelected
                                ? GestureDetector(
                                    onLongPress: () async {
                                      await startVideoRecording();
                                      animatedController.forward();
                                    },
                                    onLongPressUp: () async {
                                      if (_isRecordingInProgress) {
                                        onRecordVideoFinished();
                                      }
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle),
                                          width: 50,
                                          height: 50,
                                          child: LayoutBuilder(
                                            builder: (context, constraints) =>
                                                AnimatedBuilder(
                                              animation: animatedController,
                                              builder: (context, child) =>
                                                  CircularProgressIndicator(
                                                      strokeWidth: 15,
                                                      value: animatedController
                                                          .value,
                                                      color: Colors.red),
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.circle,
                                            color: Colors.white38, size: 80),
                                        Icon(Icons.circle,
                                            color: Colors.white, size: 65),
                                        _isRecordingInProgress
                                            ? Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                              )
                                            : Icon(Icons.circle,
                                                color: Colors.red, size: 25),
                                      ],
                                    ),
                                  )
                                : InkWell(
                                    onTap: () async {
                                      XFile? rawImage = await takePicture();
                                      File imageFile = File(rawImage!.path);

                                      int currentUnix =
                                          DateTime.now().millisecondsSinceEpoch;
                                      final directory =
                                          await getApplicationDocumentsDirectory();
                                      String fileFormat =
                                          imageFile.path.split('.').last;
                                      await imageFile.copy(
                                        '${directory.path}/$currentUnix.$fileFormat',
                                      );
                                      Navigator.pop(context, imageFile);

//                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowMessage(imageFile)));
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Icon(Icons.circle,
                                        //     color: Colors.white38, size: 80),

                                        Icon(Icons.circle,
                                            color: Colors.white, size: 65),
                                      ],
                                    ),
                                  ),
                            Container(
                              width: 90,
                              height: 90,
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //todo image button transform
                    TextButton(
                      onPressed: _isRecordingInProgress
                          ? null
                          : () {
                              if (_isVideoCameraSelected) {
                                setState(() {
                                  _isVideoCameraSelected = false;
                                });
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _isVideoCameraSelected
                              ? Colors.white
                              : Colors.black,
                        ),
                        width: 90,
                        height: 40,
                        child: Center(
                          child: MyTextWidget('IMAGE',
                              style: TextStyle(
                                  color: _isVideoCameraSelected
                                      ? Colors.grey
                                      : Colors.white)),
                        ),
                      ),
                    ),
                    //todo image button transform

                    TextButton(
                      onPressed: () {
                        if (!_isVideoCameraSelected) {
                          setState(() {
                            _isVideoCameraSelected = true;
                          });
                        }
                      },
                      // style: TextButton.styleFrom(
                      //
                      // ),
                      child: Container(
                          decoration: BoxDecoration(
                              color: _isVideoCameraSelected
                                  ? Colors.black
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          width: 60,
                          height: 40,
                          child: Center(
                            child: MyTextWidget(
                              'VIDEO',
                              style: TextStyle(
                                  color: _isVideoCameraSelected
                                      ? Colors.white
                                      : Colors.grey
                                  // color: _isVideoCameraSelected
                                  // ? Colors.white
                                  // : Colors.black,
                                  ),
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _currentFlashMode = FlashMode.off;
                        });
                        await controller!.setFlashMode(
                          FlashMode.off,
                        );
                      },
                      child: Icon(
                        Icons.flash_off,
                        color: _currentFlashMode == FlashMode.off
                            ? Colors.amber
                            : Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _currentFlashMode = FlashMode.auto;
                        });
                        await controller!.setFlashMode(
                          FlashMode.auto,
                        );
                      },
                      child: Icon(
                        Icons.flash_auto,
                        color: _currentFlashMode == FlashMode.auto
                            ? Colors.amber
                            : Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _currentFlashMode = FlashMode.torch;
                        });
                        await controller!.setFlashMode(
                          FlashMode.torch,
                        );
                      },
                      child: Icon(
                        Icons.highlight,
                        color: _currentFlashMode == FlashMode.torch
                            ? Colors.amber
                            : Colors.black,
                      ),
                    ),
                  ],
                )
              ],
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

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
      });

      _startTimer();
    } on CameraException catch (e) {
      debugPrint('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      debugPrint('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      debugPrint('Error resuming video recording: $e');
    }
  }

  void onRecordVideoFinished({bool lengthMoreThan60 = false}) async{
    animatedController.stop();
    _timer?.cancel();
    // _resetTimer();
    XFile? rawVideo = await stopVideoRecording();
    File videoFile = File(rawVideo!.path);
    Navigator.pop(context, !lengthMoreThan60 ? videoFile : null);
    if(lengthMoreThan60){
      showMessage(
          'Video length must not be longer than 59 seconds',
          showInRelease: true);
    }
  }
}
