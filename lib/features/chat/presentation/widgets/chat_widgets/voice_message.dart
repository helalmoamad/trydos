import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/voice_waves.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../manager/chat_event.dart';
import '../../manager/chat_state.dart';
import 'no_image_widget.dart';
import 'text_message.dart';

class VoiceMessage extends StatefulWidget {
  VoiceMessage({
    Key? key,
    required this.isSent,
    required this.messageId,
    required this.isRead,
    required this.isReceived,
    required this.senderId,
    this.userMessagePhoto,
    required this.userMessageName,
    this.file,
    this.fileUrl,
    this.isForwarded = false,
    required this.isFirstMessage,
    this.receivedAt,
    this.createAt,
    this.watchedAt,
    required this.channelId,
  }) : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String messageId;
  File? file;
  final String? fileUrl;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  bool isRead;
  bool isReceived;
  final String channelId;
  final int senderId;
  final String? userMessagePhoto;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final DateTime? watchedAt;
  final String userMessageName;

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  late ChatBloc chatBloc;
  ValueNotifier<bool> audioPlayingNotifier = ValueNotifier(false);
  ValueNotifier<bool> durationChangedNotifier = ValueNotifier(false);
  PlayerState audioPlayerState = PlayerState.stopped;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late final Source audioSource;
  bool timer = false;

//  final ValueNotifier<int> _loadingFile =  ValueNotifier(0);

  getAudioDuration() async {
    if (widget.file != null) {
      audioSource = DeviceFileSource(
        widget.file!.path,
      );
    } else {
      audioSource = UrlSource(widget.fileUrl!);
    }
    await audioPlayer.setSource(audioSource);
    duration = (await audioPlayer.getDuration()) ?? Duration.zero;
    audioPlayingNotifier.notifyListeners();
  }

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          timer = true;
        });
      }
    });
    // audioPlayer.onDurationChanged.listen((Duration duration) {
    //   debugPrint(duration);
    //
    // });
    audioPlayer.audioCache = AudioCache();
    audioPlayer.onPlayerComplete.listen((event) {
      position = Duration.zero;
      audioPlayingNotifier.value = false;
    });
    getAudioDuration();
    audioPlayer.onPositionChanged.listen((newDuration) {
      audioPlayingNotifier.notifyListeners();
      if (newDuration.inSeconds.compareTo(position.inSeconds) > 0) {
        position = newDuration;
        debugPrint(position.toString());
        durationChangedNotifier.value = !durationChangedNotifier.value;
      }
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      audioPlayerState = state;
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (p, c) =>
          p.changeMessageStateFromPusherStatus !=
              c.changeMessageStateFromPusherStatus &&
          c.changeMessageStateFromPusherStatus !=
              ChangeMessageStateFromPusherStatus.init,
      listener: (context, state) {
        if (state.changeMessageStateFromPusherStatus ==
            ChangeMessageStateFromPusherStatus.watched) {
          if (widget.isRead) {
            return;
          }
          setState(() {
            widget.isRead = true;
          });
        } else if (!widget.isReceived) {
          setState(() {
            widget.isReceived = true;
          });
        }
      },
      builder: (context, state) {
        return Padding(
          padding: HWEdgeInsets.only(
              right: widget.isSent ? 25.w : 0, left: widget.isSent ? 0 : 25.w),
          child: SwipeTo(
            onLeftSwipe: () {
              if (widget.senderId == widget._prefsRepository.myChatId) {
                if ((state.sendMessageStatus == SendMessageStatus.loading &&
                    state.currentMessage.contains(widget.messageId))) {
                  return;
                }
                BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                    true,
                    'voice',
                    senderParentMessageId: widget.senderId,
                    widget.isSent,
                    messageId: widget.messageId,
                    time: widget.createAt,
                    message: 'Voice'));
              } else {}
            },
            animationDuration: const Duration(milliseconds: 150),
            offsetDx: 0.15,
            iconSize: 0,
            onRightSwipe: () {
              if (widget.senderId == widget._prefsRepository.myChatId) {
                BlocProvider.of<ChatBloc>(context)
                    .add(ChangeSlop(messageId: widget.messageId));
              } else if (widget.senderId == widget._prefsRepository.myChatId) {
                if ((state.sendMessageStatus == SendMessageStatus.loading &&
                    state.currentMessage.contains(widget.messageId))) {
                  return;
                }
                BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                    true,
                    'voice',
                    senderParentMessageId: widget.senderId,
                    widget.isSent,
                    messageId: widget.messageId,
                    time: widget.createAt,
                    message: 'Voice'));
              }
            },
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: widget.isSent
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: widget.isSent
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Transform.translate(
                        offset: !(state.isSlpoing &&
                                state.slopMessageId!
                                    .contains(widget.messageId) &&
                                (widget.isReceived || widget.isRead))
                            ? Offset(0, 0)
                            : widget.senderId ==
                                    widget._prefsRepository.myChatId
                                ? Offset(100.w, 0)
                                : Offset(-100.w, 0),
                        child: Stack(
                          alignment: widget.isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          children: [
                            Container(
                              height: 70,
                              width: 365.w,
                              decoration: BoxDecoration(
                                  color: widget.isSent
                                      ? const Color(0xffFFF9B4)
                                      : const Color(0xffB4FED9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        //todo change the commented opacity to fromARGB for better performance
                                        color: Color.fromARGB(50, 0, 0, 0)
                                        //                                      context.colorScheme.black
                                        //                                          .withOpacity(0.05)
                                        ,
                                        offset: const Offset(0, 3),
                                        blurRadius: 6)
                                  ]),
                              child: Padding(
                                padding: HWEdgeInsets.only(
                                    left: widget.isSent ? 20.w : 27.w,
                                    top: 8,
                                    right: widget.isSent ? 27.w : 20.w),
                                child: ValueListenableBuilder<bool>(
                                    valueListenable: audioPlayingNotifier,
                                    builder: (context, isPlaying, _) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              height: 41,
                                              width: 318.w,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  if (widget.isSent) ...{
                                                    InkWell(
                                                      onTap: audioToggle,
                                                      child: SvgPicture.asset(
                                                        isPlaying
                                                            ? AppAssets.playSvg
                                                            : AppAssets
                                                                .pauseSvg,
                                                        width: 20.sp,
                                                        height: 20.sp,
                                                      ),
                                                    ),
                                                    26.horizontalSpace,
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        duration ==
                                                                Duration.zero
                                                            ? Padding(
                                                                padding:
                                                                    HWEdgeInsets
                                                                        .only(
                                                                            top:
                                                                                5.0),
                                                                child:
                                                                    TrydosLoader(
                                                                  size: 15.sp,
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 47.w,
                                                                height: 20,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  border: Border.all(
                                                                      width:
                                                                          0.4,
                                                                      color: const Color(
                                                                          0xff388cff)),
                                                                ),
                                                                child: Center(
                                                                  child: ValueListenableBuilder<
                                                                          bool>(
                                                                      valueListenable:
                                                                          durationChangedNotifier,
                                                                      builder: (context,
                                                                          durationChanged,
                                                                          _) {
                                                                        return MyTextWidget(
                                                                          (isPlaying)
                                                                              ? HelperFunctions.getTimeInFormat(position)
                                                                              : HelperFunctions.getTimeInFormat(duration),
                                                                          style: context
                                                                              .textTheme
                                                                              .titleSmall
                                                                              ?.rt
                                                                              .copyWith(color: const Color(0xff404040), height: 1.4),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        );
                                                                      }),
                                                                )),
                                                        1.verticalSpace,
                                                        SizedBox(
                                                          height: 20,
                                                          width: 220.w,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              SvgPicture.string(
                                                                '<svg viewBox="117.0 1976.5 220.0 1.0" ><path transform="translate(117.0, 1976.5)" d="M 0 0 L 220 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                                                                allowDrawingOutsideViewBox:
                                                                    true,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                              const VoiceWaves(),
                                                              // if (widget.file == null) ...{
                                                              //   10.horizontalSpace,
                                                              //   ValueListenableBuilder<int>(
                                                              //       valueListenable: _loadingFile,
                                                              //       builder: (context, status, _) {
                                                              //         if (status == 0) {
                                                              //           return InkWell(
                                                              //             onTap: () async{
                                                              //               _loadingFile.value = 1;
                                                              //             },
                                                              //             child: Icon(
                                                              //                 Icons
                                                              //                     .save_alt_outlined,
                                                              //                 color: const Color(
                                                              //                     0xff388CFF),
                                                              //                 size: 20.sp),
                                                              //           );
                                                              //         } else if (status == 1) {
                                                              //           FileSaving().downloadFileToLocalStorage(widget.fileUrl!,action: (File? file){
                                                              //             _loadingFile.value=2;
                                                              //             widget.file=file;
                                                              //             getAudioDuration();
                                                              //             setState(() {
                                                              //
                                                              //             });
                                                              //           });
                                                              //           return  CircularProgressIndicator(
                                                              //             backgroundColor: Colors.grey.shade100,
                                                              //             color:
                                                              //             const  Color(0xff388CFF),
                                                              //           );
                                                              //         }else{
                                                              //           return const SizedBox.shrink();
                                                              //         }
                                                              //       }),
                                                              // }
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    16.horizontalSpace,
                                                    SvgPicture.asset(
                                                      AppAssets.voicePlayedSvg,
                                                      width: 25.w,
                                                      height: 28,
                                                    )
                                                  } else ...{
                                                    //todo these transform cost a lot of resources i make a trick to avoid use this transformer
                                                    //                                                  Transform(
                                                    //                                                      alignment:
                                                    //                                                          Alignment.center,
                                                    //                                                      transform: Matrix4
                                                    //                                                          .diagonal3Values(
                                                    //                                                              -1.0, 1.0, 2.0),
                                                    //                                                      child: SvgPicture.asset(
                                                    //                                                        AppAssets
                                                    //                                                            .voicePlayedSvg,
                                                    //                                                        width: 25.w,
                                                    //                                                        height: 28,
                                                    //                                                      )),
                                                    SvgPicture.asset(
                                                      AppAssets.voicePlayedSvg,
                                                      width: 25.w,
                                                      height: 28,
                                                    ),
                                                    15.horizontalSpace,
                                                    InkWell(
                                                      onTap: audioToggle,
                                                      child: SvgPicture.asset(
                                                        isPlaying
                                                            ? AppAssets.playSvg
                                                            : AppAssets
                                                                .pauseSvg,
                                                        width: 20.sp,
                                                        height: 20.sp,
                                                      ),
                                                    ),
                                                    26.horizontalSpace,
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        duration ==
                                                                Duration.zero
                                                            ? Padding(
                                                                padding:
                                                                    HWEdgeInsets
                                                                        .only(
                                                                            top:
                                                                                5.0),
                                                                child:
                                                                    TrydosLoader(
                                                                  size: 15.sp,
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 47.w,
                                                                height: 20,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  border: Border.all(
                                                                      width:
                                                                          0.4,
                                                                      color: const Color(
                                                                          0xff388cff)),
                                                                ),
                                                                child: Center(
                                                                  child: ValueListenableBuilder<
                                                                          bool>(
                                                                      valueListenable:
                                                                          durationChangedNotifier,
                                                                      builder: (context,
                                                                          durationChanged,
                                                                          _) {
                                                                        return MyTextWidget(
                                                                          (isPlaying)
                                                                              ? HelperFunctions.getTimeInFormat(position)
                                                                              : HelperFunctions.getTimeInFormat(duration),
                                                                          style: context
                                                                              .textTheme
                                                                              .titleSmall
                                                                              ?.rt
                                                                              .copyWith(color: const Color(0xff404040), height: 1.4),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        );
                                                                      }),
                                                                )),
                                                        1.verticalSpace,
                                                        SizedBox(
                                                          height: 20,
                                                          width: 220.w,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              SvgPicture.string(
                                                                '<svg viewBox="117.0 1976.5 220.0 1.0" ><path transform="translate(117.0, 1976.5)" d="M 0 0 L 220 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                                                                allowDrawingOutsideViewBox:
                                                                    true,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                              const VoiceWaves(),
                                                              // if (widget.file == null) ...{
                                                              //   10.horizontalSpace,
                                                              //   ValueListenableBuilder<int>(
                                                              //       valueListenable: _loadingFile,
                                                              //       builder: (context, status, _) {
                                                              //         if (status == 0) {
                                                              //           return InkWell(
                                                              //             onTap: () async{
                                                              //               _loadingFile.value = 1;
                                                              //             },
                                                              //             child: Icon(
                                                              //                 Icons
                                                              //                     .save_alt_outlined,
                                                              //                 color: const Color(
                                                              //                     0xff388CFF),
                                                              //                 size: 20.sp),
                                                              //           );
                                                              //         } else if (status == 1) {
                                                              //           FileSaving().downloadFileToLocalStorage(widget.fileUrl!,action: (File? file){
                                                              //             _loadingFile.value=2;
                                                              //             widget.file=file;
                                                              //             getAudioDuration();
                                                              //             setState(() {
                                                              //
                                                              //             });
                                                              //           });
                                                              //           return  CircularProgressIndicator(
                                                              //             backgroundColor: Colors.grey.shade100,
                                                              //             color:
                                                              //             const  Color(0xff388CFF),
                                                              //           );
                                                              //         }else{
                                                              //           return const SizedBox.shrink();
                                                              //         }
                                                              //       }),
                                                              // }
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  }
                                                ],
                                              )),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0),
                                            child: Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Row(
                                                mainAxisAlignment: widget.isSent
                                                    ? MainAxisAlignment.start
                                                    : MainAxisAlignment.end,
                                                children: [
                                                  MyTextWidget(
                                                    widget.createAt!.isUtc
                                                        ? HelperFunctions
                                                            .getDateInFormat(
                                                                widget
                                                                    .createAt!)
                                                        : HelperFunctions
                                                            .getZonedDateInFormat(
                                                                widget
                                                                    .createAt!),
                                                    style: context.textTheme
                                                        .titleSmall?.rr
                                                        .copyWith(
                                                            color: const Color(
                                                                0xff505050)),
                                                  ),
                                                  if (widget.isSent) ...{
                                                    10.horizontalSpace,
                                                    (state.currentFailedMessage
                                                            .contains(widget
                                                                .messageId))
                                                        ? Container(
                                                            width: 40.w,
                                                            height: 20.w,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                InkWell(
                                                                    onTap: () {
                                                                      chatBloc.add(ResendMessageEvent(
                                                                          messageType:
                                                                              "voice",
                                                                          channelId: widget
                                                                              .channelId,
                                                                          messageId:
                                                                              widget.messageId));
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .refresh,
                                                                      size:
                                                                          25.w,
                                                                    )),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5.w),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AppAssets
                                                                        .messageFailedSvg,
                                                                    width:
                                                                        10.sp,
                                                                    height:
                                                                        10.sp,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : SvgPicture.asset(
                                                            widget.isRead
                                                                ? AppAssets
                                                                    .messageReadArrowSvg
                                                                : widget
                                                                        .isReceived
                                                                    ? AppAssets
                                                                        .messageDeliveredArrowSvg
                                                                    : (state.currentMessage
                                                                            .contains(widget.messageId))
                                                                        ? timer
                                                                            ? (state.currentMessage.contains(widget.messageId))
                                                                                ? AppAssets.sandClockSvg
                                                                                : AppAssets.messageSentArrowSvg
                                                                            : ""
                                                                        : AppAssets.messageSentArrowSvg,
                                                            width: 10.sp,
                                                            height: 10.sp,
                                                          )
                                                  },
                                                  if (widget.isForwarded) ...{
                                                    10.horizontalSpace,
                                                    SvgPicture.asset(
                                                      AppAssets.forwardedSvg,
                                                      width: 10.sp,
                                                      height: 10.sp,
                                                    )
                                                  }
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                              ),
                            ),
                            widget.isFirstMessage
                                ? Transform.translate(
                                    offset:
                                        Offset(widget.isSent ? 20.w : -20.w, 0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEBFFF8),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        widget.userMessagePhoto != null
                                            ? MyCachedNetworkImage(
                                                imageUrl: ChatUrls.baseUrl +
                                                    widget.userMessagePhoto!,
                                                progressIndicatorBuilderWidget:
                                                    TrydosLoader(),
                                                imageFit: BoxFit.cover,
                                                radius: 8,
                                                width: 30.w,
                                                height: 30,
                                              )
                                            : NoImageWidget(
                                                width: 30.w,
                                                height: 30,
                                                textStyle: context
                                                    .textTheme.titleMedium?.br
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff6638FF),
                                                        letterSpacing: 0.18,
                                                        height: 1.33),
                                                radius: 8,
                                                name: widget.userMessageName)
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            state.isSlpoing &&
                                    state.slopMessageId!
                                        .contains(widget.messageId)
                                ? Transform.translate(
                                    offset: widget.senderId ==
                                            widget._prefsRepository.myChatId
                                        ? Offset(-380.w, 0)
                                        : Offset(380.w, 0),
                                    child: SendRecieveWatchTime(
                                      isRead: widget.isRead,
                                      isReceived: widget.isReceived,
                                      receivedAt: widget.receivedAt,
                                      watchedAt: widget.watchedAt,
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                      // 7.verticalSpace,
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: widget.isSent ? const Color(0xffFFF9B4):const Color(0xffcefde6),
                      //     borderRadius: BorderRadius.circular(8.0),
                      //   ),
                      //   padding: HWEdgeInsets.symmetric(horizontal: 16 , vertical: 5),
                      //   child: Center(
                      //     child: MyTextWidget('Forwarded Message' , style: context.textTheme.titleSmall?.rr.copyWith(
                      //       color: const Color(0xff505050),
                      //       height: 1.4
                      //     )),
                      //   ),
                      // )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void audioToggle() async {
    if (duration == Duration.zero) {
      return;
    }
    if (audioPlayerState == PlayerState.playing) {
      audioPlayingNotifier.value = false;
      await audioPlayer.pause();
    } else if (audioPlayerState == PlayerState.paused) {
      audioPlayingNotifier.value = true;
      await audioPlayer.resume();
    } else {
      audioPlayingNotifier.value = true;
      await audioPlayer.play(audioSource);
    }
  }
}
