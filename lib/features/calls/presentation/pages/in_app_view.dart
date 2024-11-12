import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';

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

  late ChatBloc chatBloc;
  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    debugPrint("asdafsd{${widget.channelId}");
    debugPrint("asdafsd{${widget.messageId}");
    debugPrint("asdafsd{${widget.uId}");
    debugPrint("asdafsd{${widget.type}");
    debugPrint("asdafsd{${widget.action}");
    debugPrint("asdafsd{${widget.auth_token}");
    Uri baseUrl = Uri.parse(dotenv.env['WEB_CALLS_URL']!);
    source = Uri(queryParameters: {
      'uid': widget.uId,
      'authToken': widget.auth_token,
      'message_id': widget.messageId,
      'type': widget.type,
      'action': widget.action,
      'ch_id': widget.channelId,
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
    if (_audioPlayer.state == PlayerState.playing) {
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  ValueNotifier<int> loadingNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      print(
          "///////*************7777777777777777777777777///////////////////////////////////////////${error}");

      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Agora_In_AppWeb_View"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return BlocListener<CallsBloc, CallsState>(
      listener: (context, state) {
        timer?.cancel();
        if (_audioPlayer.state == PlayerState.playing) {
          _audioPlayer.dispose();
        }
      },
      listenWhen: (p, c) => p.stopRingToneReason != c.stopRingToneReason,
      child: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                /*   onLoadStop: (controller, url) {
                  print(
                      "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${url}^^^^^^^^^^99999999999999999}");
                  controller.dispose();
                },*/
                onReceivedError: (controller, request, error) =>
                    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${error}"),
                onReceivedHttpError: (controller, webResources, webErrors) {
                  print(
                      "*********************/////////////////////////////////////////////////${webErrors}");
                  // showMessage('Can\'t lunch call , please try again' , showInRelease: true);
                  // GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                  //     messageId: widget.messageId.toString()));
                  // controller.stopLoading();
                  // controller.dispose();
                  // Navigator.pop(context);
                },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  print(
                      "//////////////////////////////////////1111111111111111111111///////////${url}");

                  log('ring? ${url?.queryParameters.containsKey('ring')}');
                  if (_audioPlayer.state == PlayerState.playing &&
                      widget.isReceivingCall &&
                      !(url?.queryParameters.containsKey('ring') ?? false)) {
                    timer?.cancel();
                    _audioPlayer.dispose();
                  }
                  if (url.toString().contains('callInProg')) {
                    Timer.periodic(Duration(seconds: 7), (timer) {
                      controller.stopLoading();
                      controller.dispose();
                      if (context.canPop() &&
                          context.widget is! SinglePageChat) {
                        Navigator.of(context).pop();
                      }
                      // GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                      //     payload: {'Target': 'Application From callInProg'},
                      //     messageId: widget.messageId.toString()));
                    });
                  }
                  if (url.toString().contains('end')) {
                    print(
                        "54............................................................................................");
                    controller.stopLoading();
                    controller.dispose();
                    if (context.canPop() && context.widget is! SinglePageChat) {
                      Navigator.of(context).pop();
                    }
                    //    Navigator.of(context).pop();
                    // GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                    //     payload: {'Target': 'Application  From end'},
                    //     messageId: widget.messageId.toString()));
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
                  print(
                      "///////*************111111111111111117777777777777777777777777////////////////////////////////////////44/");

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
                  print(
                      "******************---------------------------------------------------------------------------------/////////////////////////////////////////////////${progress}");

                  setState(() {
                    loadingNotifier.value = progress;
                  });
                },
              ),
              ValueListenableBuilder<int>(
                  valueListenable: loadingNotifier,
                  builder: (context, progress, child) {
                    print(
                        "///////*111111111111111111111111111111111111*********${progress}**4444444444444444*7777777777777777777777777/////////////////////////////////////////*************");

                    if (progress < 100)
                      return Center(child: CircularProgressIndicator());
                    if (timer == null && !widget.isReceivingCall) {
                      timer = Timer.periodic(Duration(seconds: 14), (timer) {
                        playWaitingCall();
                      });
                      Future.delayed(Duration(seconds: 7), () {
                        timer?.cancel();
                        if (_audioPlayer.state == PlayerState.playing) {
                          _audioPlayer.dispose();
                        }
                      });
                    } else if (timer == null && widget.isReceivingCall) {
                      startVibration();
                      timer = Timer.periodic(Duration(seconds: 2), (timer) {
                        playIncomingCall();
                      });
                      Future.delayed(Duration(seconds: 7), () {
                        timer?.cancel();
                        if (_audioPlayer.state == PlayerState.playing) {
                          _audioPlayer.dispose();
                        }
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
