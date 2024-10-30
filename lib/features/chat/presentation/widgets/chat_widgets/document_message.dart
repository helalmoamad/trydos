import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../manager/chat_event.dart';
import '../../manager/chat_state.dart';
import 'no_image_widget.dart';
import 'text_message.dart';

class DocumentMessage extends StatefulWidget {
  DocumentMessage(
      {Key? key,
      this.isForwarded = false,
      this.isLocalMessage = true,
      required this.isSent,
      required this.isRead,
      required this.senderId,
      required this.fileName,
      this.userMessagePhoto,
      this.documentFile,
      this.documentFileUrl,
      required this.userMessageName,
      required this.messageId,
      required this.isReceived,
      required this.isFirstMessage,
      this.receivedAt,
      this.createAt,
      this.watchedAt,
      required this.channelId})
      : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final bool isForwarded;
  final DateTime? watchedAt;
  final String messageId;
  File? documentFile;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final bool isLocalMessage;
  final String? documentFileUrl;

  bool isRead;
  bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;
  final String fileName;
  final String channelId;

  @override
  State<DocumentMessage> createState() => _DocumentMessageState();
}

class _DocumentMessageState extends State<DocumentMessage> {
  late ChatBloc chatBloc;
  bool timer = false;
  @override
  void initState() {
    if (widget.isSent) {
      FileSaving().downloadFileToLocalStorage(
        widget.documentFileUrl ?? widget.documentFile!.path,
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
    // TODO: implement initState
    super.initState();
  }

  final ValueNotifier<int> _loadingFile = ValueNotifier(0);

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
                      true, 'file', widget.isSent,
                      senderParentMessageId: widget.senderId,
                      messageId: widget.messageId,
                      time: widget.createAt,
                      message: widget.fileName));
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
                      true, 'file', widget.isSent,
                      senderParentMessageId: widget.senderId,
                      messageId: widget.messageId,
                      time: widget.createAt,
                      message: widget.fileName));
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
                            ? Offset(140.w, 0)
                            : Offset(-140.w, 0),
                    child: Stack(
                      alignment: widget.isSent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.documentFile != null) {
                              // ignore: body_might_complete_normally_catch_error
                              OpenFile.open(widget.documentFile!.path)
                                  .then((value) => {print("access")})
                                  // ignore: body_might_complete_normally_catch_error
                                  .catchError((onError) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Text("صيغة الملف غير مدعومة"),
                                  ),
                                );
                              });
                            }
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            decoration: BoxDecoration(
                              color: widget.isSent
                                  ? const Color(0xffFFF9B4)
                                  : const Color(0xffB4FED9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: HWEdgeInsets.only(
                                  left: widget.isSent ? 20.w : 40.w,
                                  top: 10,
                                  right: widget.isSent ? 40.w : 20.w),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment: widget.isSent
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          AppAssets.documentSvg,
                                          width: 25,
                                          height: 25,
                                        ),
                                        10.horizontalSpace,
                                        Container(
                                          constraints:
                                              BoxConstraints(maxWidth: 310.w),
                                          child: SizedBox(
                                            width: 200.w,
                                            child: MyTextWidget(
                                              widget.fileName,
                                              maxLines: 3,
                                              style: context
                                                  .textTheme.titleLarge?.rr
                                                  .copyWith(
                                                      color: const Color(
                                                          0xffC4C2C2),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      height: 1.43),
                                            ),
                                          ),
                                        ),
                                        if (widget.documentFile == null) ...{
                                          10.horizontalSpace,
                                          ValueListenableBuilder<int>(
                                              valueListenable: _loadingFile,
                                              builder: (context, status, _) {
                                                if (status == 0) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      _loadingFile.value = 1;
                                                    },
                                                    child: Icon(
                                                        Icons.save_alt_outlined,
                                                        color: const Color(
                                                            0xff388CFF),
                                                        size: 35.sp),
                                                  );
                                                } else if (status == 1) {
                                                  FileSaving()
                                                      .downloadFileToLocalStorage(
                                                          widget
                                                              .documentFileUrl!,
                                                          widget.channelId,
                                                          action: (File? file) {
                                                    _loadingFile.value = 2;
                                                    widget.documentFile = file;
                                                    setState(() {});
                                                  });
                                                  return CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.grey.shade100,
                                                    color:
                                                        const Color(0xff388CFF),
                                                  );
                                                } else {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                              }),
                                        }
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        children: [
                                          MyTextWidget(
                                            !widget.createAt!.isUtc
                                                ? HelperFunctions
                                                    .getDateInFormat(
                                                        widget.createAt!)
                                                : HelperFunctions
                                                    .getZonedDateInFormat(
                                                        widget.createAt!),
                                            style: context
                                                .textTheme.titleSmall?.rr
                                                .copyWith(
                                                    color: const Color(
                                                        0xffC4C2C2)),
                                          ),
                                          if (widget.isSent) ...{
                                            10.horizontalSpace,
                                            (state.currentFailedMessage
                                                    .contains(widget.messageId))
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            chatBloc.add(ResendMessageEvent(
                                                                messageType:
                                                                    "file",
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
                                                                    ? (state.currentMessage.contains(widget
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
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                                    ? Offset(-350.w, 0)
                                    : Offset(350.w, 0),
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
