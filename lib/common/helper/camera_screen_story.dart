import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:video_player/video_player.dart';
import '../../features/app/my_text_widget.dart';

class CameraScreenStory extends StatefulWidget {
  List<CameraDescription> cameras;

  CameraScreenStory(this.cameras, {super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenStory>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController animatedController;
  late StoryBloc storyBloc;
  String? link;
  ValueNotifier<bool> addUrlToStory = ValueNotifier(false);
  //todo start timer for recording video
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  /*void _resetTimer() {
    setState(() {
      _seconds = 0;
    });
  }*/

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
    storyBloc = BlocProvider.of<StoryBloc>(context);
    storyBloc.add(const SetStoryLinkEvent(""));
// Hide the status bar
//    SystemChrome.setEnabledSystemUIOverlays([]);
//;
    animatedController = AnimationController(vsync: this);
    animatedController.stop();
    animatedController.reset();
    animatedController.duration = const Duration(seconds: 60);
    animatedController.addListener(() {
      if (animatedController.status == AnimationStatus.completed) {
        _isRecordingInProgress = false;
        lengthMoreThan60 = true;
        onRecordVideoFinished();
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
  bool lengthMoreThan60 = false;
//  todo flash
  FlashMode? _currentFlashMode;
  File? imageFile;
  //todo exposure values
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  final double _currentExposureOffset = 0.0;
  XFile? rawImage;
  File? videoFile;
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
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          Future.delayed(const Duration(milliseconds: 300),
              () => FocusScope.of(context).unfocus());
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Scaffold(
        body: _isCameraInitialized
            ? ValueListenableBuilder<bool>(
                valueListenable: addUrlToStory,
                builder: (context, _addUrlToStory, _) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _addUrlToStory
                            ? videoFile != null
                                ? Container(
                                    width: double.infinity,
                                    height: MediaQuery.sizeOf(context).height *
                                        (_addUrlToStory ? 0.76 : 0.86),
                                    child: VideoPlayerWidget(videoFile!),
                                  )
                                : Container(
                                    width: 1.sw,
                                    height: MediaQuery.sizeOf(context).height *
                                        (_addUrlToStory ? 0.78 : 0.86),
                                    child: Image.file(
                                      imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                            : SizedBox(
                                width: double.infinity,
                                height: MediaQuery.sizeOf(context).height *
                                    (_addUrlToStory ? 0.78 : 0.86),
                                //        aspectRatio: 1 / controller!.value.aspectRatio,
                                child: Stack(children: [
                                  //todo show a live camera
                                  videoFile != null || imageFile != null
                                      ? const SizedBox.shrink()
                                      : controller!.buildPreview(),

                                  _isVideoCameraSelected
                                      ? Align(
                                          alignment: Alignment.topCenter,
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(top: 55.0),
                                            child: MyTextWidget(
                                              '0 : $_seconds',
                                              style: const TextStyle(
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
                                        for (ResolutionPreset preset
                                            in resolutionPresets)
                                          DropdownMenuItem(
                                            value: preset,
                                            child: MyTextWidget(
                                              preset
                                                  .toString()
                                                  .split('.')[1]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          currentResolutionPreset = value!;
                                          _isCameraInitialized = false;
                                        });
                                        onNewCameraSelected(
                                            controller!.description);
                                      },
                                      hint: const MyTextWidget("Select item"),
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
                                        child: _addUrlToStory
                                            ? const SizedBox.shrink()
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: Slider(
                                                      value: _currentZoomLevel,
                                                      min: _minAvailableZoom,
                                                      max: _maxAvailableZoom,
                                                      activeColor: Colors.white,
                                                      inactiveColor:
                                                          Colors.white30,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          _currentZoomLevel =
                                                              value;
                                                        });
                                                        await controller!
                                                            .setZoomLevel(
                                                                value);
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black87,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: MyTextWidget(
                                                        _currentZoomLevel
                                                                .toStringAsFixed(
                                                                    1) +
                                                            'x',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
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
                                      child: _addUrlToStory
                                          ? const SizedBox.shrink()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _isCameraInitialized =
                                                          false;
                                                      _isRearCameraSelected =
                                                          !_isRearCameraSelected;
                                                    });

                                                    onNewCameraSelected(
                                                      widget.cameras[
                                                          _isRearCameraSelected
                                                              ? 0
                                                              : 1],
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
                                                _addUrlToStory
                                                    ? const SizedBox.shrink()
                                                    : _isVideoCameraSelected
                                                        ? GestureDetector(
                                                            onLongPress:
                                                                () async {
                                                              await startVideoRecording();
                                                              animatedController
                                                                  .forward();
                                                            },
                                                            onLongPressUp:
                                                                () async {
                                                              if (_isRecordingInProgress) {
                                                                onRecordVideoFinished();
                                                              }
                                                            },
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle),
                                                                  width: 50,
                                                                  height: 50,
                                                                  child:
                                                                      LayoutBuilder(
                                                                    builder: (context,
                                                                            constraints) =>
                                                                        AnimatedBuilder(
                                                                      animation:
                                                                          animatedController,
                                                                      builder: (context, child) => CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              15,
                                                                          value: animatedController
                                                                              .value,
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: Colors
                                                                        .white38,
                                                                    size: 80),
                                                                const Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 65),
                                                                _isRecordingInProgress
                                                                    ? Container(
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.circular(4)),
                                                                      )
                                                                    : const Icon(
                                                                        Icons
                                                                            .circle,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            25),
                                                              ],
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () async {
                                                              rawImage =
                                                                  await takePicture();
                                                              imageFile = File(
                                                                  rawImage!
                                                                      .path);

                                                              int currentUnix =
                                                                  DateTime.now()
                                                                      .millisecondsSinceEpoch;
                                                              final directory =
                                                                  await getApplicationDocumentsDirectory();
                                                              String
                                                                  fileFormat =
                                                                  imageFile!
                                                                      .path
                                                                      .split(
                                                                          '.')
                                                                      .last;
                                                              await imageFile!
                                                                  .copy(
                                                                '${directory.path}/$currentUnix.$fileFormat',
                                                              );

                                                              await controller!
                                                                  .dispose();

                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          600),
                                                                  () {
                                                                addUrlToStory
                                                                        .value =
                                                                    true;
                                                              });
                                                              //                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowMessage(imageFile)));
                                                            },
                                                            child: const Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                // Icon(Icons.circle,
                                                                //     color: Colors.white38, size: 80),

                                                                Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 65),
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
                        _addUrlToStory
                            ? const SizedBox.shrink()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                        child: MyTextWidget(
                                            '${LocaleKeys.photo.tr()}',
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
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        width: 60,
                                        height: 40,
                                        child: Center(
                                          child: MyTextWidget(
                                            '${LocaleKeys.vvideo.tr()}',
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
                        !_addUrlToStory
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.all(10),
                                child: AppTextField(
                                  onChange: (val) {
                                    link = val;
                                    storyBloc.add(SetStoryLinkEvent(val));
                                  },
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () => FocusScope.of(context).unfocus());
                                  },
                                  onFieldSubmitted: (val) {
                                    Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () => FocusScope.of(context).unfocus());
                                  },
                                  hintText:
                                      '${LocaleKeys.add_link_to_story.tr()}',
                                ),
                              ),
                        _addUrlToStory
                            ? const SizedBox.shrink()
                            : const SizedBox(
                                height: 20,
                              ),
                        !_addUrlToStory
                            ? const SizedBox.shrink()
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(40)),
                                width: 70,
                                height: 70,
                                child: InkWell(
                                    onTap: () {
                                      if (link?.contains("coupon") ?? false) {
                                        showWarningMessage(
                                            context,
                                            LocaleKeys.coupon_link_not_allowed
                                                .tr());
                                        return;
                                      }
                                      if (imageFile != null) {
                                        Navigator.pop(context, imageFile);
                                      } else if (videoFile != null) {
                                        Navigator.pop(
                                            context,
                                            !lengthMoreThan60
                                                ? videoFile
                                                : null);
                                        if (lengthMoreThan60) {
                                          showMessage(
                                              LocaleKeys.video_length_limit
                                                  .tr(),
                                              hasError: true,
                                              showInRelease: true);
                                        }
                                      }
                                    },
                                    child: Text("${LocaleKeys.send.tr()}")),
                              ),
                        _addUrlToStory
                            ? const SizedBox.shrink()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                      color:
                                          _currentFlashMode == FlashMode.torch
                                              ? Colors.amber
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              )
                      ],
                    ),
                  );
                })
            : Container(),
      ),
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

  void onRecordVideoFinished() async {
    animatedController.stop();
    _timer?.cancel();
    // _resetTimer();
    XFile? rawVideo = await stopVideoRecording();
    videoFile = File(rawVideo!.path);
    addUrlToStory.value = true;
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;
  VideoPlayerWidget(this.file, {super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        // لا تبدأ التشغيل تلقائياً، الفيديو يبدأ متوقف
        // _controller.play();  // احذف أو علق هذا السطر
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  if (!_controller.value.isPlaying)
                    Container(
                      color: Colors.black26,
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                ],
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
