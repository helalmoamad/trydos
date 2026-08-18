import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
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
  bool isPrivate;
  String action;
  String messageId;
  bool isReceivingCall;

  AgoraInAppWebView({
    required this.messageId,
    required this.action,
    required this.type,
    required this.channelId,
    required this.auth_token,
    required this.isPrivate,
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
  static const platform = MethodChannel('com.trydos.audio/settings');

  Future<void> _setCallAudioMode(bool enable) async {
    if (kDebugMode) print("enable: $enable");
    try {
      await platform.invokeMethod('setCallAudioMode', enable);
    } on PlatformException catch (e) {
      debugPrint("Failed to set audio mode: '${e.message}'.");
    }
  }

  Future<void> playIncomingCall() async {
    try {
      // Only stop if already playing to avoid interrupting
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(
        AssetSource('audio/incoming_call.mp3'),
        volume: 1,
      );
    } catch (e) {
      if (kDebugMode) print('Error playing incoming call: $e');
    }
  }

  Future<void> playWaitingCall() async {
    try {
      // Only stop if already playing to avoid interrupting
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(
        AssetSource('audio/send_call_ring.mp3'),
        volume: 1,
      );
      if (!widget.isReceivingCall && widget.type == 'voice') {
        if (kDebugMode) print("setCallAudioMode: true");
        await Future.delayed(const Duration(milliseconds: 600));
        await _setCallAudioMode(true);
      }
    } catch (e) {
      if (kDebugMode) print('Error playing waiting call: $e');
    }
  }

  void startVibration() {
    Vibration.vibrate(pattern: [500, 1000, 500, 1000], duration: 3);
  }

  late ChatBloc chatBloc;
  @override
  void initState() {
    // Set audio mode based on call type
    // For incoming calls, set to speaker for video, earpiece for voice
    // For outgoing calls, set to earpiece for voice
    if (widget.isReceivingCall) {
      if (widget.type == 'video') {
        _setCallAudioMode(false); // Speaker for video calls
      } else {
        _setCallAudioMode(true); // Earpiece for voice calls
      }
    } else {
      if (widget.type == 'voice') {
        _setCallAudioMode(true); // Earpiece for outgoing voice calls
      }
    }
    if (kDebugMode)
      print(
        "myFcmToken ://///***/*8888****${GetIt.I<PrefsRepository>().getFcmTokens[0]}",
      );
    LastPagesTracker.push('AgoraInAppWebView');
    chatBloc = BlocProvider.of<ChatBloc>(context);
    debugPrint("asdafsd{${widget.channelId}");
    debugPrint("asdafsd{${widget.messageId}");
    debugPrint("asdafsd{${widget.uId}");
    debugPrint("asdafsd{${widget.type}");
    debugPrint("asdafsd{${widget.action}");
    debugPrint("asdafsd{${widget.auth_token}");
    Uri baseUrl = Uri.parse(dotenv.env['WEB_CALLS_URL']!);
    source = Uri(
      queryParameters: {
        'uid': widget.uId,
        'authToken': widget.auth_token,
        'message_id': widget.messageId,
        'type': widget.type,
        'action': widget.action,
        'ch_id': widget.channelId,
        'is_private': widget.isPrivate ? 'delivery' : null,
        'fcm': widget.isReceivingCall
            ? GetIt.I<PrefsRepository>().getFcmTokens[0]
            : null,
      }..removeWhere((key, value) => value == null),
      host: baseUrl.host,
      scheme: baseUrl.scheme,
      path: '/call_direct',
    );
    // controller1 = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..loadRequest(source);
    if (kDebugMode) print("source ://///***/*8888****${source.toString()}");
    log(source.toString());
    super.initState();
  }

  @override
  void dispose() {
    // Cancel timer first to prevent any callbacks
    timer?.cancel();
    timer = null;

    // Stop vibration
    Vibration.cancel();

    // Stop and dispose audio player
    _audioPlayer.stop();
    _audioPlayer.dispose();

    // Reset audio mode
    _setCallAudioMode(false);

    // Reset bloc state
    GetIt.I<CallsBloc>().add(ChangeMakeCallStatusToInitEvent());

    super.dispose();
  }

  ValueNotifier<int> loadingNotifier = ValueNotifier(0);
  void _performAction1(List<dynamic> args) {
    // Check if widget is still mounted before processing
    if (!mounted) return;

    debugPrint('Received message from web: $args');
    if (args.isEmpty) return;

    final action = args[0];
    if (kDebugMode) print("action: $action");

    // 1. معالجة إيقاف الرنين
    if (action == 'stop-ring') {
      Vibration.cancel();
      timer?.cancel();
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.stop(); // استخدم stop بدلاً من dispose للحفاظ على الكائن
      }
      // إذا كانت المكالمة صوتية ولم يتم تحديد حالة مكبر الصوت بعد، نضبطها على Earpiece افتراضياً
      // أما في مكالمات الفيديو فتكون Speaker افتراضياً
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          if (widget.type == 'voice') {
            _setCallAudioMode(true); // Earpiece
          } else {
            _setCallAudioMode(false); // Speaker
          }
        }
      });
    }

    // 2. معالجة حالة مكبر الصوت (Speaker)
    for (var arg in args) {
      if ((int.tryParse(arg.toString()) ?? 0) > 0) {
        if (mounted) {
          chatBloc.add(
            AddDurationToMessageCallEvent(
              channelId: widget.channelId,
              messageId: widget.messageId,
              duration: int.tryParse(arg.toString()) ?? 0,
            ),
          );
        }
      }
      if (arg == 'IsSpeaker') {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _setCallAudioMode(false);
          }
        });
        break;
      } else if (arg == 'IsEarpiece') {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _setCallAudioMode(true);
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  if (kDebugMode) print(
                      "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${url}^^^^^^^^^^99999999999999999}");
                  controller.dispose();
                },*/
                    onReceivedError: (controller, request, error) {
                      if (kDebugMode) {
                        if (kDebugMode)
                          print(
                            "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${error}",
                          );
                      }
                    },
                    onReceivedHttpError: (controller, webResources, webErrors) {
                      if (kDebugMode)
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
                      // Check if widget is still mounted before accessing context or widget
                      if (!mounted) return;

                      if (!widget.isReceivingCall && widget.type == 'voice') {
                        _setCallAudioMode(true);
                      }
                      if (kDebugMode)
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
                        if (kDebugMode)
                          print(
                            "57............................${url?.path.toString()}",
                          );
                        Timer.periodic(const Duration(seconds: 7), (timer) {
                          if (!mounted) {
                            timer.cancel();
                            return;
                          }
                          controller.stopLoading();
                          controller.dispose();
                          if (mounted &&
                              context.canPop() &&
                              context.widget is! SinglePageChat) {
                            Navigator.of(context).pop();
                          }
                          // GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                          //     payload: {'Target': 'Application From callInProg'},
                          //     messageId: widget.messageId.toString()));
                        });
                      }
                      if ((url?.path ?? "").toString().contains('end')) {
                        timer?.cancel();
                        timer = null;

                        // Stop vibration
                        Vibration.cancel();

                        // Stop and dispose audio player
                        _audioPlayer.stop();
                        _audioPlayer.dispose();

                        controller.stopLoading();
                        controller.dispose();
                        if (mounted &&
                            context.canPop() &&
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
                      allowsInlineMediaPlayback: true, // مهم جداً لـ iOS
                    ),

                    initialUrlRequest: URLRequest(
                      url: WebUri(source.toString()),
                    ),
                    onPermissionRequest: (controller, request) async {
                      debugPrint(
                        "Processing permission request for: ${request.resources}",
                      );

                      final resources = <PermissionResourceType>[];

                      for (var resource in request.resources) {
                        if (resource == PermissionResourceType.CAMERA) {
                          final status = await Permission.camera.request();
                          if (status.isGranted)
                            resources.add(PermissionResourceType.CAMERA);
                        } else if (resource ==
                            PermissionResourceType.MICROPHONE) {
                          final status = await Permission.microphone.request();
                          if (status.isGranted)
                            resources.add(PermissionResourceType.MICROPHONE);
                        } else if (resource ==
                            PermissionResourceType.CAMERA_AND_MICROPHONE) {
                          final cameraStatus = await Permission.camera
                              .request();
                          final microphoneStatus = await Permission.microphone
                              .request();
                          if (cameraStatus.isGranted &&
                              microphoneStatus.isGranted) {
                            resources.add(
                              PermissionResourceType.CAMERA_AND_MICROPHONE,
                            );
                          }
                        } else if (resource ==
                            PermissionResourceType.PROTECTED_MEDIA_ID) {
                          // مطلوب لبعض خدمات الـ RTC على أندرويد
                          resources.add(
                            PermissionResourceType.PROTECTED_MEDIA_ID,
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
                      if (kDebugMode)
                        print(
                          "******************---------------------------------------------------------------------------------/////////////////////////////////////////////////${progress}",
                        );

                      if (mounted) {
                        setState(() {
                          loadingNotifier.value = progress;
                        });
                      }
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: loadingNotifier,
                    builder: (context, progress, child) {
                      if (kDebugMode)
                        print(
                          "///////*111111111111111111111111111111111111****${timer?.isActive ?? false}*****${progress}**4444444444444444*7777777777777777777777777/////////////////////////////////////////*************",
                        );

                      if (progress < 100)
                        return const Center(child: CircularProgressIndicator());
                      if (!widget.isReceivingCall && widget.type == 'voice') {
                        _setCallAudioMode(true);
                      }
                      if (!(timer?.isActive ?? false) &&
                          !widget.isReceivingCall) {
                        playWaitingCall();

                        timer = Timer.periodic(const Duration(seconds: 10), (
                          t,
                        ) {
                          if (!mounted) {
                            t.cancel();
                            return;
                          }
                          if (kDebugMode) print("*/*/*222222222222111");
                          // Only play if audio player is not already playing
                          if (_audioPlayer.state != PlayerState.playing) {
                            playWaitingCall();
                          }
                        });
                        // Remove the delayed stop - let the ring play until stop-ring is received
                      } else if (!(timer?.isActive ?? false) &&
                          widget.isReceivingCall) {
                        startVibration();
                        if (kDebugMode) print("*/*/*11111111111111111111");
                        playIncomingCall();
                        timer = Timer.periodic(const Duration(seconds: 4), (t) {
                          if (!mounted) {
                            t.cancel();
                            return;
                          }
                          if (kDebugMode) print("*/*/*222222222222111");
                          // Only play if audio player is not already playing
                          if (_audioPlayer.state != PlayerState.playing) {
                            playIncomingCall();
                          }
                        });
                        // Remove the delayed stop - let the ring play until stop-ring is received
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
