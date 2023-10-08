import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';

import 'image_message.dart';

class ReplayMessage extends StatefulWidget {
   ReplayMessage({Key? key, required this.message,
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
    required this.isFirstMessage}) : super(key: key);
  final String message;
  final String messageId;
  final String? messageAnswer;
  final String messageAnswerId;
  final bool isSent;
  final bool isISentFirstMessage;
  final bool isFirstMessage;
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
      final RenderObject? renderBox =key.currentContext?.findRenderObject();
      if(renderBox != null) {
        height = (renderBox as RenderBox).size.height;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (p, c) =>
      p.changeMessageStateFromPusherStatus !=c.changeMessageStateFromPusherStatus &&
          c.changeMessageStateFromPusherStatus !=ChangeMessageStateFromPusherStatus.init,
      listener: (context, state) {
        if (state.changeMessageStateFromPusherStatus==ChangeMessageStateFromPusherStatus.watched)
        {
          if(widget.isAnswerMessageRead){
            return;
          }
          setState(() {
            widget.isAnswerMessageRead=true;
            widget.isReplayedMessageRead=true;
          });
        }
        else if(!widget.isAnswerMessageReceived){
          setState(() {
            widget.isAnswerMessageReceived=true;
            widget.isReplayedMessageReceived=true;
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
              padding: const EdgeInsetsDirectional.only(end: 25.0),
              child: InkWell(
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: widget.scrollToMessage,
                child: TextMessage(
                  key: key,
                  receivedColor: !widget.isISentFirstMessage ? const Color(0xffD5F6E6) : const Color(0xffF1FDE3),
                  message:widget.message,
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
                  time: widget.messageDate,),
              ),
            ),
FractionalTranslation(translation: Offset(0.0,0.43),child: (widget.answeredFile != null || widget.answeredFilePath != null) ?
ImageMessage(
    isSent: widget.isSent,
    time: widget.messageDate,
    isRead: widget.isAnswerMessageRead,
    messageId: widget.messageId,
    isReceived: widget.isAnswerMessageReceived,
    isFirstMessage: widget.isFirstMessage,
    userMessageName: widget.senderAnswerName,
    userMessagePhoto: widget.senderAnswerPhoto,
    senderId: GetIt.I<PrefsRepository>().myChatId!,
    isLocalMessage: widget.answeredFilePath==null,
    imageFile: widget.answeredFile,
    imageUrl: widget.answeredFilePath)
    :TextMessage(message: widget.messageAnswer!,
  withImageShadow: true,
  messageId: widget.messageAnswerId,
  userMessageName: widget.senderAnswerName,
  userMessagePhoto: widget.senderAnswerPhoto,
  isReceived: widget.isAnswerMessageReceived,
  isSent: widget.isSent,
  senderId: GetIt.I<PrefsRepository>().myChatId!,
  isRead: widget.isAnswerMessageRead,
  isFirstMessage: true,
  time: DateTime.now(),),)
          ],
        ),
      const SizedBox(height: 25,),
    ],
  ),
);
  }
}
