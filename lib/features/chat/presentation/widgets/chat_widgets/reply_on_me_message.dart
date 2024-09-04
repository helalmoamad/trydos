import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/voice_message.dart';

import '../../../../../core/domin/repositories/prefs_repository.dart';
import 'document_message.dart';
import 'video_message.dart';

class ReplayOnMeMessage extends StatefulWidget {
  const ReplayOnMeMessage({
    Key? key,
    required this.message,
    required this.messageId,
    required this.messageAnswerId,
    required this.senderAnswerName,
    this.senderAnswerPhoto,
    this.messageAnswer,
    this.answeredFile,
    this.answeredFilePath,
    this.index = 0,
    required this.isSent,
    required this.messageType,
    required this.isISentFirstMessage,
    required this.isReplayedMessageRead,
    required this.isReplayedMessageReceived,
    required this.isAnswerMessageRead,
    required this.isAnswerMessageReceived,
    required this.scrollToMessage,
    required this.isFirstMessage,
    this.receivedAt,
    this.createAt,
    this.messageDate,
    this.watchedaAt,
    required this.channalId,
  }) : super(key: key);
  final String message;
  final int index;
  final String channalId;
  final String messageType;
  final String messageId;
  final String? messageAnswer;
  final String messageAnswerId;
  final bool isISentFirstMessage;
  final bool isSent;
  final bool isFirstMessage;
  final DateTime? watchedaAt;
  final File? answeredFile;
  final String? answeredFilePath;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final DateTime? messageDate;
  final bool isReplayedMessageRead;
  final bool isAnswerMessageRead;
  final bool isAnswerMessageReceived;
  final bool isReplayedMessageReceived;
  final String? senderAnswerPhoto;
  final String senderAnswerName;
  final void Function() scrollToMessage;

  @override
  State<ReplayOnMeMessage> createState() => _ReplayOnMeMessageState();
}

class _ReplayOnMeMessageState extends State<ReplayOnMeMessage> {
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
    print(widget.messageType);
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            InkWell(
              onTap: widget.scrollToMessage,
              child: TextMessage(
                isreplay: true,
                index: widget.index,
                key: key,
                sendColor: widget.isISentFirstMessage
                    ? const Color(0xffF1FDE3)
                    : const Color(0xffD5F6E6),
                message: widget.message,
                withShadow: false,
                senderId: GetIt.I<PrefsRepository>().myChatId!,
                withImageShadow: false,
                isReceived: widget.isReplayedMessageRead,
                userMessageName: widget.senderAnswerName,
                userMessagePhoto: widget.senderAnswerPhoto,
                messageId: widget.messageId,
                disableMessageAlignment: false,
                isSent: widget.isISentFirstMessage,
                isRead: widget.isReplayedMessageRead,
                watchedAt: widget.watchedaAt,
                isFirstMessage: true,
                receivedAt: widget.receivedAt,
                createAt: widget.messageDate!,
                channalId: widget.channalId,
              ),
            ),
            Transform.translate(
                offset: const Offset(0, 25),
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
                        watchedAt: widget.watchedaAt,
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
                            watchedAt: widget.watchedaAt,
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
                                senderId: GetIt.I<PrefsRepository>().myChatId!,
                                userMessageName: widget.senderAnswerName,
                                userMessagePhoto: widget.senderAnswerPhoto,
                                watchedAt: widget.watchedaAt,
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
                                    userMessagePhoto: widget.senderAnswerPhoto,
                                    watchedAt: widget.watchedaAt,
                                    isRead: widget.isAnswerMessageRead,
                                    isFirstMessage: widget.isFirstMessage,
                                    isReceived: widget.isAnswerMessageReceived,
                                  )
                                : TextMessage(
                                    message: widget.messageAnswer!,
                                    index: widget.index,
                                    withImageShadow: true,
                                    senderId:
                                        GetIt.I<PrefsRepository>().myChatId!,
                                    isRead: widget.isAnswerMessageRead,
                                    disableMessageAlignment: false,
                                    isReceived: widget.isAnswerMessageReceived,
                                    messageId: widget.messageAnswerId,
                                    userMessageName: widget.senderAnswerName,
                                    userMessagePhoto: widget.senderAnswerPhoto,
                                    isSent: widget.isSent,
                                    watchedAt: widget.watchedaAt,
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
    );
  }
}
