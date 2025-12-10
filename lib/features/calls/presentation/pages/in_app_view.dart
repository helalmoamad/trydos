import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:vibration/vibration.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';

// ignore: must_be_immutable
class AgoraInAppWebView extends StatefulWidget {
  String type;
  String channelId;
  String uId;
  String auth_token;
  String action;
  String messageId;
  bool isReceivingCall;

  AgoraInAppWebView({
    required this.messageId,
    required this.action,
    required this.type,
    required this.channelId,
    required this.auth_token,
    required this.uId,
    this.isReceivingCall = true,
    super.key,
  });

  @override
  State<AgoraInAppWebView> createState() => _AgoraInAppWebViewState();
}

class _AgoraInAppWebViewState extends State<AgoraInAppWebView> {
  late Uri source;
  Timer? timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playIncomingCall() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('audio/incoming_call.mp3'),
        volume: 1,
      );
    } catch (e) {
      print('Error playing incoming call: $e');
    }
  }

  Future<void> playWaitingCall() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('audio/send_call_ring.mp3'),
        volume: 1,
      );
    } catch (e) {
      print('Error playing waiting call: $e');
    }
  }

  void startVibration() {
    Vibration.vibrate(pattern: [500, 1000, 500, 1000], duration: 3);
  }

  late ChatBloc chatBloc;
  @override
  void initState() {
    LastPagesTracker.push('AgoraInAppWebView');
    chatBloc = BlocProvider.of<ChatBloc>(context);
    debugPrint("asdafsd{${widget.channelId}");
    debugPrint("asdafsd{${widget.messageId}");
    debugPrint("asdafsd{${widget.uId}");
    debugPrint("asdafsd{${widget.type}");
    debugPrint("asdafsd{${widget.action}");
    debugPrint("asdafsd{${widget.auth_token}");
    Uri baseUrl = Uri.parse(dotenv.env['WEB_CALLS_NEST_URL']!);
    source = Uri(
      queryParameters: {
        'uid': widget.uId,
        'authToken': widget.auth_token,
        'message_id': widget.messageId,
        'type': widget.type,
        'action': widget.action,
        'ch_id': widget.channelId,
      },
      host: baseUrl.host,
      scheme: baseUrl.scheme,
      path: '/call_direct',
    );
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
  void _performAction1(List<dynamic> args) {
    print('Received message from web: $args');
    // أضف المنطق الخاص بك هنا
    if (args.isNotEmpty) {
      final action = args[0];
      print("action://///////////// $action");
      if (action == 'stop-ring') {
        Vibration.cancel();
        timer?.cancel();
        if (_audioPlayer.state == PlayerState.playing) {
          _audioPlayer.dispose();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return BlocListener<CallsBloc, CallsState>(
      listener: (context, state) {
        timer?.cancel();
        if (_audioPlayer.state == PlayerState.playing) {
          _audioPlayer.stop();
        }
      },
      listenWhen: (p, c) => p.stopRingToneReason != c.stopRingToneReason,
      child:
          // ignore: deprecated_member_use
          WillPopScope(
            onWillPop: () => Future.value(false),
            child: Scaffold(
              body: Stack(
                children: [
                  InAppWebView(
                    onWebViewCreated: (controller) {
                      // --- REGISTER JAVASCRIPT HANDLER ---
                      controller.addJavaScriptHandler(
                        handlerName:
                            'flutterMessageHandler', // Name the web content will use
                        callback: (args) {
                          // Trigger ACTION1 when a message is received from the web
                          _performAction1(args);
                          // No response/send functionality added here as requested
                        },
                      );
                      // --- END HANDLER REGISTRATION ---
                    },
                    /*   onLoadStop: (controller, url) {
                  print(
                      "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${url}^^^^^^^^^^99999999999999999}");
                  controller.dispose();
                },*/
                    onReceivedError: (controller, request, error) => print(
                      "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${error}",
                    ),
                    onReceivedHttpError: (controller, webResources, webErrors) {
                      print(
                        "*********************/////////////////////////////////////////////////${webErrors}",
                      );
                      // showMessage('Can\'t lunch call , please try again' , showInRelease: true);
                      // GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                      //     messageId: widget.messageId.toString()));
                      // controller.stopLoading();
                      // controller.dispose();
                      // Navigator.pop(context);
                    },

                    onUpdateVisitedHistory: (controller, url, isReload) {
                      print(
                        "//////////////////////////////////////1111111111111111111111///////////${url?.queryParameters}",
                      );

                      log('ring? ${url?.queryParameters.containsKey('ring')}');
                      if (_audioPlayer.state == PlayerState.playing &&
                          widget.isReceivingCall &&
                          !(url?.queryParameters.containsKey('ring') ??
                              false)) {
                        timer?.cancel();
                        _audioPlayer.stop();
                      }
                      if ((url?.path ?? "").toString().contains('callInProg')) {
                        print(
                          "57............................${url?.path.toString()}",
                        );
                        Timer.periodic(const Duration(seconds: 7), (timer) {
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
                      if ((url?.path ?? "").toString().contains('end')) {
                        print("54..............${url.toString()}");
                        controller.stopLoading();
                        controller.dispose();
                        if (context.canPop() &&
                            context.widget is! SinglePageChat) {
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
                    initialUrlRequest: URLRequest(
                      url: WebUri(source.toString()),
                    ),
                    onPermissionRequest: (controller, request) async {
                      print(
                        "///////*************111111111111111117777777777777777777777777////////////////////////////////////////44/",
                      );

                      final resources = <PermissionResourceType>[];
                      if (request.resources.contains(
                        PermissionResourceType.CAMERA,
                      )) {
                        final cameraStatus = await Permission.camera.request();
                        if (!cameraStatus.isDenied) {
                          resources.add(PermissionResourceType.CAMERA);
                        }
                      }
                      if (request.resources.contains(
                        PermissionResourceType.MICROPHONE,
                      )) {
                        final microphoneStatus = await Permission.microphone
                            .request();
                        if (!microphoneStatus.isDenied) {
                          resources.add(PermissionResourceType.MICROPHONE);
                        }
                      }
                      // only for iOS and macOS
                      if (request.resources.contains(
                        PermissionResourceType.CAMERA_AND_MICROPHONE,
                      )) {
                        final cameraStatus = await Permission.camera.request();
                        final microphoneStatus = await Permission.microphone
                            .request();
                        if (!cameraStatus.isDenied &&
                            !microphoneStatus.isDenied) {
                          resources.add(
                            PermissionResourceType.CAMERA_AND_MICROPHONE,
                          );
                        }
                      }

                      return PermissionResponse(
                        resources: resources,
                        action: resources.isEmpty
                            ? PermissionResponseAction.DENY
                            : PermissionResponseAction.GRANT,
                      );
                    },

                    onProgressChanged: (controller, progress) {
                      print(
                        "******************---------------------------------------------------------------------------------/////////////////////////////////////////////////${progress}",
                      );

                      setState(() {
                        loadingNotifier.value = progress;
                      });
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: loadingNotifier,
                    builder: (context, progress, child) {
                      print(
                        "///////*111111111111111111111111111111111111****${timer?.isActive ?? false}*****${progress}**4444444444444444*7777777777777777777777777/////////////////////////////////////////*************",
                      );

                      if (progress < 100)
                        return const Center(child: CircularProgressIndicator());
                      if (!(timer?.isActive ?? false) &&
                          !widget.isReceivingCall) {
                        print("*/*/*11111111111111111111");
                        playWaitingCall();
                        timer = Timer.periodic(const Duration(seconds: 10), (
                          t,
                        ) {
                          print("*/*/*222222222222111");
                          playWaitingCall();
                        });
                        Future.delayed(const Duration(seconds: 7), () {
                          if (_audioPlayer.state == PlayerState.playing) {
                            print("*/*/*33333333333333333333");
                            _audioPlayer.stop();
                          }
                        });
                      } else if (timer == null && widget.isReceivingCall) {
                        startVibration();
                        timer = Timer.periodic(const Duration(seconds: 2), (
                          timer,
                        ) {
                          playIncomingCall();
                        });
                        Future.delayed(const Duration(seconds: 7), () {
                          timer?.cancel();
                          if (_audioPlayer.state == PlayerState.playing) {
                            _audioPlayer.stop();
                          }
                        });
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
