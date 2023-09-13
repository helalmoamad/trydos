import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/voice_waves.dart';

import '../../../../../common/helper/file_saving.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import 'no_image_widget.dart';

class VoiceMessage extends StatefulWidget {
   VoiceMessage(
      {Key? key,
      required this.isSent,
      required this.messageId,
      required this.time,
      required this.isRead,
      required this.isReceived,
      required this.senderId,
        this.userMessagePhoto,
        required this.userMessageName,
      this.file,
      this.fileUrl,
      this.isForwarded = false,
      required this.isFirstMessage})
      : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String messageId;
   File? file;
  final String? fileUrl;
  final DateTime time;
   bool isRead;
   bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;

   @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<bool> audioPlayingNotifier = ValueNotifier(false);
  ValueNotifier<bool> durationChangedNotifier = ValueNotifier(false);
  PlayerState audioPlayerState = PlayerState.stopped;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late final Source audioSource;
  final ValueNotifier<int> _loadingFile =  ValueNotifier(0);


  getAudioDuration() async {
    if (widget.file != null) {
      audioSource = DeviceFileSource(
        widget.file!.path,
      );
      await audioPlayer.setSource(audioSource);
    } else {
      audioSource = UrlSource(widget.fileUrl!);
      await audioPlayer.setSource(audioSource);
    }
    duration = (await audioPlayer.getDuration())!;
    audioPlayingNotifier.notifyListeners();
  }

  @override
  void initState() {
    // audioPlayer.onDurationChanged.listen((Duration duration) {
    //   print(duration);
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
        print(position);
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
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (p, c) =>
      p.changeMessageStateFromPusherStatus !=
          c.changeMessageStateFromPusherStatus &&
          c.changeMessageStateFromPusherStatus !=
              ChangeMessageStateFromPusherStatus.init,
      listener: (context, state) {
        if (state.changeMessageStateFromPusherStatus==ChangeMessageStateFromPusherStatus.watched){
          if(widget.isRead){
            return;
          }
          setState(() {
            widget.isRead=true;
          });
        }else if(!widget.isReceived){
          setState(() {
            widget.isReceived=true;
          });
        }
      },
      builder: (context, state) {
        return Padding(
          padding: HWEdgeInsets.only(
              right: widget.isSent ? 25.w : 0, left: widget.isSent ? 0 : 25.w),
          child: SwipeTo(
            animationDuration: const Duration(milliseconds: 150),
            offsetDx: 0.15,
            iconSize: 0,
            onLeftSwipe: () {
              if((state.sendMessageStatus ==
                  SendMessageStatus.loading &&
                  state.currentMessage
                      .contains(widget.messageId))){
                return ;
              }
              BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                  true,
                  'voice',
                  senderParentMessageId: widget.senderId,
                  widget.isSent,
                  messageId: widget.messageId,
                  time: widget.time,
                  message: 'Voice'));
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
                      Stack(
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
                                      color: context.colorScheme.black
                                          .withOpacity(0.05),
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
                                                          : AppAssets.pauseSvg,
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
                                                      duration==Duration.zero ? Padding(
                                                        padding: HWEdgeInsets.only(top: 5.0),
                                                        child: TrydosLoader(size: 15.sp,),
                                                      ) :Container(
                                                          width: 47.w,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                            border: Border.all(
                                                                width: 0.4,
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
                                                                  return Text(
                                                                    (isPlaying)
                                                                        ? HelperFunctions.getTimeInFormat(
                                                                            position)
                                                                        : HelperFunctions.getTimeInFormat(
                                                                            duration),
                                                                    style: context
                                                                        .textTheme
                                                                        .overline
                                                                        ?.rt
                                                                        .copyWith(
                                                                            color:
                                                                                const Color(0xff404040),
                                                                            height: 1.4),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  );
                                                                }),
                                                          )),
                                                      1.verticalSpace,
                                                      SizedBox(
                                                        height: 20,
                                                        width: 220.w,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            SvgPicture.string(
                                                              '<svg viewBox="117.0 1976.5 220.0 1.0" ><path transform="translate(117.0, 1976.5)" d="M 0 0 L 220 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                                                              allowDrawingOutsideViewBox:
                                                                  true,
                                                              fit: BoxFit.fill,
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
                                                  Transform(
                                                      alignment:
                                                          Alignment.center,
                                                      transform: Matrix4
                                                          .diagonal3Values(
                                                              -1.0, 1.0, 1.0),
                                                      child: SvgPicture.asset(
                                                        AppAssets
                                                            .voicePlayedSvg,
                                                        width: 25.w,
                                                        height: 28,
                                                      )),
                                                  15.horizontalSpace,
                                                  InkWell(
                                                    onTap: audioToggle,
                                                    child: SvgPicture.asset(
                                                      isPlaying
                                                          ? AppAssets.playSvg
                                                          : AppAssets.pauseSvg,
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
                                                      duration==Duration.zero ? Padding(
                                                        padding: HWEdgeInsets.only(top: 5.0),
                                                        child: TrydosLoader(size: 15.sp,),
                                                      ) :Container(
                                                          width: 47.w,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                            border: Border.all(
                                                                width: 0.4,
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
                                                                  return Text(
                                                                    (isPlaying)
                                                                        ? HelperFunctions.getTimeInFormat(
                                                                            position)
                                                                        : HelperFunctions.getTimeInFormat(
                                                                            duration),
                                                                    style: context
                                                                        .textTheme
                                                                        .overline
                                                                        ?.rt
                                                                        .copyWith(
                                                                            color:
                                                                                const Color(0xff404040),
                                                                            height: 1.4),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  );
                                                                }),
                                                          )),
                                                      1.verticalSpace,
                                                      SizedBox(
                                                        height: 20,
                                                        width: 220.w,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            SvgPicture.string(
                                                              '<svg viewBox="117.0 1976.5 220.0 1.0" ><path transform="translate(117.0, 1976.5)" d="M 0 0 L 220 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                                                              allowDrawingOutsideViewBox:
                                                                  true,
                                                              fit: BoxFit.fill,
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
                                          padding: const EdgeInsets.only(
                                              top: 0),
                                          child: Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: Row(
                                              mainAxisAlignment: widget.isSent
                                                  ? MainAxisAlignment.start
                                                  : MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  !widget.time.isUtc
                                                      ? HelperFunctions
                                                          .getDateInFormat(
                                                              widget.time)
                                                      : HelperFunctions
                                                          .getZonedDateInFormat(
                                                              widget.time),
                                                  style: context
                                                      .textTheme.overline?.rr
                                                      .copyWith(
                                                          color: const Color(
                                                              0xff505050)),
                                                ),
                                                if (widget.isSent) ...{
                                                  10.horizontalSpace,
                                                  SvgPicture.asset(
                                                    (state.currentMessage
                                                        .contains(
                                                        widget.messageId))
                                                        ? AppAssets.sandClockSvg :
                                                    (state.currentFailedMessage
                                                        .contains(
                                                        widget.messageId)) ?
                                                    AppAssets.MessageFailedSvg: widget.isRead
                                                        ? AppAssets
                                                        .messageReadArrowSvg
                                                        : widget.isReceived ? AppAssets.messageDeliveredArrowSvg :AppAssets
                                                        .messageSentArrowSvg,
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
                                        imageUrl: Urls.baseUrl + widget.userMessagePhoto!,
                                        imageFit: BoxFit.cover,
                                        radius: 8,
                                        width: 30.w,
                                        height: 30,
                                      )
                                          : NoImageWidget(
                                          width: 30.w,
                                          height: 30,
                                           textStyle:context.textTheme.caption?.br.copyWith(
                                               color: const Color(0xff6638FF),
                                               letterSpacing: 0.18,
                                               height: 1.33),
                                          radius: 8,
                                          name:widget.userMessageName
                                      )
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                      // 7.verticalSpace,
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: widget.isSent ? const Color(0xffFFF9B4):const Color(0xffcefde6),
                      //     borderRadius: BorderRadius.circular(8.0),
                      //   ),
                      //   padding: HWEdgeInsets.symmetric(horizontal: 16 , vertical: 5),
                      //   child: Center(
                      //     child: Text('Forwarded Message' , style: context.textTheme.overline?.rr.copyWith(
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
    if(duration==Duration.zero){
      return;
    }
    if (audioPlayerState == PlayerState.playing) {
      await audioPlayer.pause();
      audioPlayingNotifier.value = false;
    } else if (audioPlayerState == PlayerState.paused) {
      audioPlayingNotifier.value = true;
      await audioPlayer.resume();
    } else {
      audioPlayingNotifier.value = true;
      await audioPlayer.play(audioSource);
    }
  }
}
