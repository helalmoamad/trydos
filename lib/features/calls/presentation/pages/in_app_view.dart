import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';

class AgoraInAppWebView extends StatefulWidget {
  String type;
  String channelId;
  String uId;
  String auth_token;
  String action;
  String messageId;
  bool isReceivingCall;

  AgoraInAppWebView(
      {required this.messageId,
      required this.action,
      required this.type,
      required this.channelId,
      required this.auth_token,
      required this.uId,
      this.isReceivingCall = true,
      super.key});

  @override
  State<AgoraInAppWebView> createState() => _AgoraInAppWebViewState();
}

class _AgoraInAppWebViewState extends State<AgoraInAppWebView> {
  late Uri source;
  Timer? timer;
  AudioPlayer _audioPlayer = AudioPlayer();

  void playIncomingCall() {
    _audioPlayer.play(AssetSource('audio/incoming_call.mp3'), volume: 1);
  }

  void playWaitingCall() {
    _audioPlayer.play(AssetSource('audio/send_call_ring.mp3'), volume: 1);
  }

  void startVibration() {
    Vibration.vibrate(pattern: [500, 1000, 500, 1000], duration: 3);
  }

  @override
  void initState() {
    debugPrint("asdafsd{${widget.channelId}");
    debugPrint("asdafsd{${widget.messageId}");
    debugPrint("asdafsd{${widget.uId}");
    debugPrint("asdafsd{${widget.type}");
    debugPrint("asdafsd{${widget.action}");
    debugPrint("asdafsd{${widget.auth_token}");
    Uri baseUrl = Uri.parse('https://webdev.trydos.com');
    source = Uri(queryParameters: {
      'uid': widget.uId,
      'authToken': widget.auth_token,
      'message_id': widget.messageId,
      'type': widget.type,
      'action': widget.action,
      'ch_id': widget.channelId
    }, host: baseUrl.host, scheme: baseUrl.scheme, path: '/call_direct');
    // controller1 = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..loadRequest(source);
    log(source.toString());
    super.initState();
  }

  @override
  void dispose() {
    Vibration.cancel();
    timer?.cancel();
    super.dispose();
  }

  ValueNotifier<int> loadingNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print('error $error');
    };
    return BlocListener<CallsBloc, CallsState>(
      listener: (context, state) {
        print('xxxxxxxxxx');
        timer?.cancel();
        _audioPlayer.dispose();
      },
      listenWhen: (p, c) => p.stopRingToneReason != c.stopRingToneReason,
      child: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                // onLoadStop: (controller, url) {
                //   // controller.dispose();
                // },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  if (_audioPlayer.state == PlayerState.playing &&
                      widget.isReceivingCall &&
                      !(url?.queryParameters.containsKey('ring') ?? false)) {
                    timer?.cancel();
                    _audioPlayer.dispose();
                  }
                  if (url.toString().contains('callمnProg')) {
                    Timer.periodic(Duration(seconds: 7), (timer) {
                      controller.stopLoading();
                      controller.dispose();
                      if (context.canPop()) {
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  if (url.toString().contains('end')) {
                    controller.stopLoading();
                    controller.dispose();
                    if (context.canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                  log('asdhtf${url.toString().contains('end')}');
                },
                initialSettings: InAppWebViewSettings(
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptCanOpenWindowsAutomatically: true,
                ),

                // onPermissionRequest: (controller, permissionRequest) async {
                //   return await PermissionResponse(
                //       action: PermissionResponseAction.GRANT,
                //       resources: [
                //         PermissionResourceType.CAMERA_AND_MICROPHONE,
                //         PermissionResourceType.PROTECTED_MEDIA_ID,
                //   ]);
                // },
                initialUrlRequest: URLRequest(url: WebUri(source.toString())),
                onPermissionRequest: (controller, request) async {
                  final resources = <PermissionResourceType>[];
                  if (request.resources
                      .contains(PermissionResourceType.CAMERA)) {
                    final cameraStatus = await Permission.camera.request();
                    if (!cameraStatus.isDenied) {
                      resources.add(PermissionResourceType.CAMERA);
                    }
                  }
                  if (request.resources
                      .contains(PermissionResourceType.MICROPHONE)) {
                    final microphoneStatus =
                        await Permission.microphone.request();
                    if (!microphoneStatus.isDenied) {
                      resources.add(PermissionResourceType.MICROPHONE);
                    }
                  }
                  // only for iOS and macOS
                  if (request.resources
                      .contains(PermissionResourceType.CAMERA_AND_MICROPHONE)) {
                    final cameraStatus = await Permission.camera.request();
                    final microphoneStatus =
                        await Permission.microphone.request();
                    if (!cameraStatus.isDenied && !microphoneStatus.isDenied) {
                      resources
                          .add(PermissionResourceType.CAMERA_AND_MICROPHONE);
                    }
                  }

                  return PermissionResponse(
                      resources: resources,
                      action: resources.isEmpty
                          ? PermissionResponseAction.DENY
                          : PermissionResponseAction.GRANT);
                },

                onProgressChanged: (controller, progress) {
                  setState(() {
                    loadingNotifier.value = progress;
                  });
                },
              ),
              ValueListenableBuilder<int>(
                  valueListenable: loadingNotifier,
                  builder: (context, progress, child) {
                    if (progress < 100)
                      return Center(child: CircularProgressIndicator());
                    print('reacheddddd');
                    if (timer == null && !widget.isReceivingCall) {
                      timer = Timer.periodic(Duration(seconds: 14), (timer) {
                        playWaitingCall();
                      });
                    } else if (widget.isReceivingCall) {
                      startVibration();
                      timer = Timer.periodic(Duration(seconds: 2), (timer) {
                        playIncomingCall();
                      });
                    }
                    return const SizedBox.shrink();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
