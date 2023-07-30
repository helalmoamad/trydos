import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';

import '../../../../../core/domin/repositories/prefs_repository.dart';

class ReplayOnMeMessage extends StatefulWidget {
  const ReplayOnMeMessage({Key? key,
    required this.message,
    required this.messageId,
    required this.messageAnswerId,
    required this.senderAnswerName,
    required this.replayedName,
    this.replayedPhoto,
    this.senderAnswerPhoto,
     this.messageAnswer,
    this.answeredFile,
    this.answeredFilePath,
    required this.isSent,
    required this.parentSenderId,
    required this.isReplayedMessageRead,
    required this.isReplayedMessageReceived,
    required this.isAnswerMessageRead,
    required this.isAnswerMessageReceived,
    required this.messageDate,
    required this.scrollToMessage,
    required this.isFirstMessage})
      : super(key: key);
  final String message;
  final String messageId;
  final String? messageAnswer;
  final String messageAnswerId;
  final bool isSent;
  final bool isFirstMessage;
  final DateTime messageDate;
  final File? answeredFile;
  final String? answeredFilePath;
  final bool isReplayedMessageRead;
  final bool isAnswerMessageRead;
  final bool isAnswerMessageReceived;
  final bool isReplayedMessageReceived;
  final int parentSenderId;
  final String? replayedPhoto;
  final String? senderAnswerPhoto;
  final String replayedName;
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
      final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
      height = renderBox.size.height;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          InkWell(
            onTap: widget.scrollToMessage,
            child: TextMessage(
                key: key,
                sendColor: widget.isSent ? const Color(0xffF1FDE3) : const Color(0xffD5F6E6),
                message: widget.message,
                withShadow: false,
                senderId: widget.parentSenderId,
                withImageShadow: false,
                isReceived: widget.isReplayedMessageRead,
                userMessageName: widget.replayedName,
                userMessagePhoto: widget.replayedPhoto,
                messageId: widget.messageId,
                isSent: widget.isSent,
                isRead: widget.isReplayedMessageRead,
                time: widget.messageDate,
                isFirstMessage: true),
          ),
          Transform.translate(
              offset: const Offset(0, -22),
              child: (widget.answeredFile != null || widget.answeredFilePath != null ) ?
              ImageMessage(isSent: widget.isSent,
                time: DateTime.now(),
                messageId: widget.messageId,
                isRead: widget.isAnswerMessageRead,
                senderId: GetIt.I<PrefsRepository>().myId!,
                isFirstMessage: widget.isFirstMessage,
                  isReceived: widget.isAnswerMessageReceived,
                  userMessageName: widget.senderAnswerName,
                  userMessagePhoto: widget.senderAnswerPhoto,
                  isLocalMessage: widget.answeredFilePath==null,
                imageFile: widget.answeredFile,
                imageUrl: widget.answeredFilePath
                ) :
              TextMessage(
                  message: widget.messageAnswer!,
                  withImageShadow: true,
                  senderId: GetIt.I<PrefsRepository>().myId!,
                  isRead: widget.isAnswerMessageRead,
                  isReceived: widget.isAnswerMessageReceived,
                  messageId: widget.messageAnswerId,
                  userMessageName: widget.senderAnswerName,
                  userMessagePhoto: widget.senderAnswerPhoto,
                  isSent: widget.isSent,
                  time: widget.messageDate,
                  isFirstMessage: true)),
        ],
      ),
    );
  }
}
