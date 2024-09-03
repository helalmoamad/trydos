import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';

import '../../manager/chat_state.dart';
import 'document_message.dart';
import 'image_message.dart';
import 'video_message.dart';
import 'voice_message.dart';

class ReplayMessage extends StatefulWidget {
  ReplayMessage({
    Key? key,
    required this.message,
    required this.messageId,
    required this.messageAnswerId,
    this.messageAnswer,
    required this.isSent,
    required this.parentSenderId,
    required this.isReplayedMessageRead,
    required this.isReplayedMessageReceived,
    required this.isAnswerMessageRead,
    required this.isAnswerMessageReceived,
    required this.senderAnswerName,
    required this.replayedName,
    this.replayedPhoto,
    this.senderAnswerPhoto,
    this.answeredFile,
    this.answeredFilePath,
    required this.isISentFirstMessage,
    required this.scrollToMessage,
    required this.messageDate,
    required this.messageType,
    required this.isFirstMessage,
    this.receivedAt,
    this.createAt,
    this.index = 0,
    this.watchedAt,
    required this.channalId,
  }) : super(key: key);
  final String message;
  final String messageType;
  final String messageId;
  final String? messageAnswer;
  final String messageAnswerId;
  final int index;
  final bool isSent;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final DateTime? watchedAt;
  final bool isISentFirstMessage;
  final bool isFirstMessage;
  final String channalId;
  final DateTime messageDate;
  final File? answeredFile;
  final String? answeredFilePath;
  final int parentSenderId;
  bool isReplayedMessageRead;
  bool isAnswerMessageRead;
  bool isAnswerMessageReceived;
  bool isReplayedMessageReceived;
  final String? replayedPhoto;
  final String? senderAnswerPhoto;
  final String replayedName;
  final String senderAnswerName;
  final void Function() scrollToMessage;

  @override
  State<ReplayMessage> createState() => _ReplayMessageState();
}

class _ReplayMessageState extends State<ReplayMessage> {
  double height = 1;
  final key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final RenderObject? renderBox = key.currentContext?.findRenderObject();
      if (renderBox != null) {
        height = (renderBox as RenderBox).size.height;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (p, c) =>
          p.changeMessageStateFromPusherStatus !=
              c.changeMessageStateFromPusherStatus &&
          c.changeMessageStateFromPusherStatus !=
              ChangeMessageStateFromPusherStatus.init,
      listener: (context, state) {
        if (state.changeMessageStateFromPusherStatus ==
            ChangeMessageStateFromPusherStatus.watched) {
          if (widget.isAnswerMessageRead) {
            return;
          }
          setState(() {
            widget.isAnswerMessageRead = true;
            widget.isReplayedMessageRead = true;
          });
        } else if (!widget.isAnswerMessageReceived) {
          setState(() {
            widget.isAnswerMessageReceived = true;
            widget.isReplayedMessageReceived = true;
          });
        }
      },
      //todo here i remove the Transformer.translate and put FractionTransaction to have better performance
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    right: widget.isSent ? 25.0 : 0,
                    left: widget.isSent ? 0.0 : 25),
                child: InkWell(
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: widget.scrollToMessage,
                  child: TextMessage(
                    isreplay: true,
                    key: key,
                    receivedColor: !widget.isISentFirstMessage
                        ? const Color(0xffD5F6E6)
                        : const Color(0xffF1FDE3),
                    message: widget.message,
                    withShadow: false,
                    withImageShadow: false,
                    messageId: widget.messageId,
                    isSent: widget.isISentFirstMessage,
                    userMessageName: widget.replayedName,
                    userMessagePhoto: widget.replayedPhoto,
                    isReceived: widget.isReplayedMessageRead,
                    disableMessageAlignment: true,
                    senderId: widget.parentSenderId,
                    isRead: widget.isReplayedMessageRead,
                    isFirstMessage: true,
                    watchedAt: widget.watchedAt,
                    receivedAt: widget.receivedAt,
                    createAt: widget.messageDate,
                    channalId: widget.channalId,
                  ),
                ),
              ),
              FractionalTranslation(
                  translation: Offset(0.0, 0.43),
                  child: (widget.answeredFile != null ||
                              widget.answeredFilePath != null) &&
                          widget.messageType == "ImageMessage"
                      ? ImageMessage(
                          channelId: widget.channalId,
                          isSent: widget.isSent,
                          messageId: widget.messageId,
                          isRead: widget.isAnswerMessageRead,
                          senderId: GetIt.I<PrefsRepository>().myChatId!,
                          isFirstMessage: widget.isFirstMessage,
                          isReceived: widget.isAnswerMessageReceived,
                          userMessageName: widget.senderAnswerName,
                          userMessagePhoto: widget.senderAnswerPhoto,
                          isLocalMessage: widget.answeredFilePath == null,
                          imageFile: widget.answeredFile,
                          imageUrl: widget.answeredFilePath,
                          receivedAt: widget.receivedAt,
                          createAt: widget.createAt!,
                          watchedAt: widget.watchedAt,
                        )
                      : (widget.answeredFile != null ||
                                  widget.answeredFilePath != null) &&
                              widget.messageType == "VoiceMessage"
                          ? VoiceMessage(
                              receivedAt: widget.receivedAt,
                              createAt: widget.createAt!,
                              isSent: widget.isSent,
                              file: widget.answeredFile,
                              fileUrl: widget.answeredFilePath,
                              messageId: widget.messageId.toString(),
                              senderId: GetIt.I<PrefsRepository>().myChatId!,
                              userMessageName: widget.senderAnswerName,
                              userMessagePhoto: widget.senderAnswerPhoto,
                              watchedAt: widget.watchedAt,
                              isRead: widget.isAnswerMessageRead,
                              isFirstMessage: widget.isFirstMessage,
                              isReceived: widget.isAnswerMessageReceived,
                              channelId: widget.channalId,
                            )
                          : (widget.answeredFile != null ||
                                      widget.answeredFilePath != null) &&
                                  widget.messageType == "FileMessage"
                              ? DocumentMessage(
                                  createAt: widget.createAt!,
                                  isSent: widget.isSent,
                                  documentFile: widget.answeredFile,
                                  channelId: widget.channalId,
                                  receivedAt: widget.receivedAt,
                                  fileName:
                                      widget.answeredFile!.path.split('/').last,
                                  documentFileUrl: widget.answeredFilePath,
                                  messageId: widget.messageId.toString(),
                                  senderId:
                                      GetIt.I<PrefsRepository>().myChatId!,
                                  userMessageName: widget.senderAnswerName,
                                  userMessagePhoto: widget.senderAnswerPhoto,
                                  watchedAt: widget.watchedAt,
                                  isRead: widget.isAnswerMessageRead,
                                  isFirstMessage: widget.isFirstMessage,
                                  isReceived: widget.isAnswerMessageReceived,
                                )
                              : (widget.answeredFile != null ||
                                          widget.answeredFilePath != null) &&
                                      widget.messageType == "VideoMessage"
                                  ? VideoMessage(
                                      createAt: widget.createAt!,
                                      isSent: widget.isSent,
                                      videoFile: widget.answeredFile,
                                      channelId: widget.channalId,
                                      receivedAt: widget.receivedAt,
                                      videoUrl: widget.answeredFilePath,
                                      messageId: widget.messageId.toString(),
                                      senderId:
                                          GetIt.I<PrefsRepository>().myChatId!,
                                      userMessageName: widget.senderAnswerName,
                                      userMessagePhoto:
                                          widget.senderAnswerPhoto,
                                      watchedAt: widget.watchedAt,
                                      isRead: widget.isAnswerMessageRead,
                                      isFirstMessage: widget.isFirstMessage,
                                      isReceived:
                                          widget.isAnswerMessageReceived,
                                    )
                                  : TextMessage(
                                      message: widget.messageAnswer!,
                                      index: widget.index,
                                      withImageShadow: true,
                                      senderId:
                                          GetIt.I<PrefsRepository>().myChatId!,
                                      isRead: widget.isAnswerMessageRead,
                                      disableMessageAlignment: false,
                                      isReceived:
                                          widget.isAnswerMessageReceived,
                                      messageId: widget.messageAnswerId,
                                      userMessageName: widget.senderAnswerName,
                                      userMessagePhoto:
                                          widget.senderAnswerPhoto,
                                      isSent: widget.isSent,
                                      watchedAt: widget.watchedAt,
                                      isFirstMessage: true,
                                      receivedAt: widget.receivedAt,
                                      createAt: widget.createAt!,
                                      channalId: widget.channalId,
                                    )),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
