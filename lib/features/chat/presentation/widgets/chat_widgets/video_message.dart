import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/vedio_player.dart';
import '../../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/file_saving.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../manager/chat_bloc.dart';
import '../../manager/chat_event.dart';
import '../../manager/chat_state.dart';
import 'no_image_widget.dart';
import 'text_message.dart';

class VideoMessage extends StatefulWidget {
  VideoMessage(
      {Key? key,
      this.isForwarded = false,
      this.isLocalMessage = true,
      required this.isSent,
      this.watchedAt,
      required this.isRead,
      required this.senderId,
      this.userMessagePhoto,
      this.videoFile,
      this.videoUrl,
      required this.userMessageName,
      required this.messageId,
      required this.isReceived,
      required this.isFirstMessage,
      this.receivedAt,
      this.createAt,
      required this.channelId})
      : super(key: key);

  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String messageId;
  final String channelId;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final File? videoFile;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final bool isLocalMessage;
  final String? videoUrl;
  final DateTime? watchedAt;
  final bool isRead;
  final bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;
  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late bool isRead;
  late bool isReceived;
  bool timer = false;
  late ChatBloc chatBloc;
  @override
  void initState() {
    if (widget.isSent) {
      FileSaving().downloadFileToLocalStorage(
        widget.videoUrl ?? widget.videoFile!.path,
        widget.channelId,
      );
    }
    chatBloc = BlocProvider.of<ChatBloc>(context);
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          timer = true;
        });
      }
    });
    isRead = widget.isRead;
    isReceived = widget.isReceived;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocConsumer<ChatBloc, ChatState>(
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
              isRead = true;
            });
          } else if (!widget.isReceived) {
            setState(() {
              isReceived = true;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: HWEdgeInsets.only(
                right: widget.isSent ? 25.w : 0,
                left: widget.isSent ? 0 : 25.w),
            child: SwipeTo(
              onLeftSwipe: () {
                if (widget.senderId == widget._prefsRepository.myChatId) {
                  if ((state.sendMessageStatus == SendMessageStatus.loading &&
                      state.currentMessage.contains(widget.messageId))) {
                    return;
                  }
                  BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                      true, 'video', widget.isSent,
                      senderParentMessageId: widget.senderId,
                      imageUrl: widget.videoUrl ?? widget.videoFile!.path,
                      messageId: widget.messageId,
                      time: widget.createAt,
                      message: 'Video'));
                } else {}
              },
              iconSize: 0,
              animationDuration: const Duration(milliseconds: 100),
              offsetDx: 0.15,
              onRightSwipe: () {
                if (widget.senderId == widget._prefsRepository.myChatId) {
                  BlocProvider.of<ChatBloc>(context)
                      .add(ChangeSlop(messageId: widget.messageId));
                } else {
                  if ((state.sendMessageStatus == SendMessageStatus.loading &&
                      state.currentMessage.contains(widget.messageId))) {
                    return;
                  }
                  BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                      true, 'video', widget.isSent,
                      senderParentMessageId: widget.senderId,
                      imageUrl: widget.videoUrl ?? widget.videoFile!.path,
                      messageId: widget.messageId,
                      time: widget.createAt,
                      message: 'Video'));
                }
              },
              child: Row(
                mainAxisAlignment: widget.isSent
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: !(state.isSlpoing &&
                            state.slopMessageId!.contains(widget.messageId) &&
                            (widget.isReceived || widget.isRead))
                        ? Offset(0, 0)
                        : widget.senderId == widget._prefsRepository.myChatId
                            ? Offset(100.w, 0)
                            : Offset(-50.w, 0),
                    child: Stack(
                      alignment: widget.isSent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                                width: 300.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    width: 3.0,
                                    color: widget.isSent
                                        ? const Color(0xffFFF9B4)
                                        : const Color(0xffB4FFD9),
                                  ),
                                ),
                                child: MYVideoPlayer(
                                    chatId: widget.channelId,
                                    videoUrl: widget.videoUrl,
                                    videoFile: widget.videoFile)),
                            Transform.translate(
                              offset: const Offset(0, -3),
                              child: Container(
                                height: 50,
                                width: 300.w,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment(0.0, 0),
                                    end: Alignment(0.0, 1.0),
                                    colors: [
                                      Color(0x00000000),
                                      Color(0xb2000000)
                                    ],
                                    stops: [0.0, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      MyTextWidget(
                                        !widget.createAt!.isUtc
                                            ? HelperFunctions.getDateInFormat(
                                                widget.createAt!)
                                            : HelperFunctions
                                                .getZonedDateInFormat(
                                                    widget.createAt!),
                                        style: context.textTheme.titleSmall?.rr
                                            .copyWith(
                                                color:
                                                    context.colorScheme.white),
                                      ),
                                      if (widget.isSent) ...{
                                        10.horizontalSpace,
                                        (state.currentFailedMessage
                                                .contains(widget.messageId))
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        chatBloc.add(
                                                            ResendMessageEvent(
                                                                messageType:
                                                                    "video",
                                                                channelId: widget
                                                                    .channelId,
                                                                messageId: widget
                                                                    .messageId));
                                                      },
                                                      child: Icon(
                                                        Icons.refresh,
                                                        size: 27.w,
                                                      )),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5.w),
                                                    child: SvgPicture.asset(
                                                      AppAssets
                                                          .messageFailedSvg,
                                                      width: 10.sp,
                                                      height: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SvgPicture.asset(
                                                widget.isRead
                                                    ? AppAssets
                                                        .messageReadArrowSvg
                                                    : widget.isReceived
                                                        ? AppAssets
                                                            .messageDeliveredArrowSvg
                                                        : (state.currentMessage
                                                                .contains(widget
                                                                    .messageId))
                                                            ? timer
                                                                ? (state.currentMessage
                                                                        .contains(widget
                                                                            .messageId))
                                                                    ? AppAssets
                                                                        .sandClockSvg
                                                                    : AppAssets
                                                                        .messageSentArrowSvg
                                                                : ""
                                                            : AppAssets
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
                              ),
                            ),
                          ],
                        ),
                        widget.isFirstMessage
                            ? Transform.translate(
                                offset: Offset(widget.isSent ? 15.w : -15.w, 0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Stack(
                                      alignment: widget.isSent
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEBFFF8),
                                            border: Border.all(
                                              width: 3.0,
                                              color: widget.isSent
                                                  ? const Color(0xffFFF9B4)
                                                  : const Color(0xffB4FFD9),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        Container(
                                          width: 20.w,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEBFFF8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    widget.userMessagePhoto != null
                                        ? MyCachedNetworkImage(
                                            imageUrl: ChatUrls.baseUrl +
                                                widget.userMessagePhoto!,
                                            imageFit: BoxFit.cover,
                                            progressIndicatorBuilderWidget:
                                                TrydosLoader(),
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
                                                    color:
                                                        const Color(0xff6638FF),
                                                    letterSpacing: 0.18,
                                                    height: 1.33),
                                            radius: 8,
                                            name: widget.userMessageName)
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        state.isSlpoing &&
                                state.slopMessageId!.contains(widget.messageId)
                            ? Transform.translate(
                                offset: widget.senderId ==
                                        widget._prefsRepository.myChatId
                                    ? Offset(-310.w, 0)
                                    : Offset(110.w, 0),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
