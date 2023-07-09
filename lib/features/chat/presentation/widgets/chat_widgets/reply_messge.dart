import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';

import 'image_message.dart';

class ReplayMessage extends StatefulWidget {
  const ReplayMessage({Key? key, required this.message,
    required this.messageId,
    required this.messageAnswerId,
     this.messageAnswer,
    required this.isSent,
     this.answeredFile,
    required this.messageDate,
    required this.isFirstMessage}) : super(key: key);
  final String message;
  final String messageId;
  final String? messageAnswer;
  final String messageAnswerId;
  final bool isSent;
  final bool isFirstMessage;
  final DateTime messageDate;
  final File? answeredFile;


  @override
  State<ReplayMessage> createState() => _ReplayMessageState();
}

class _ReplayMessageState extends State<ReplayMessage> {
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
    return Column(
      children: [
        TextMessage(
          key: key,
          receivedColor: const Color(0xffD5F6E6),
          message:widget.message,
          withShadow: false,
          withImageShadow: false,
          messageId: widget.messageId,
          isSent: false,
          isFirstMessage: true,
          time: widget.messageDate,),
        Transform.translate(
            offset: Offset(height < 60 ? 10 : 0, -20.h),
            child: widget.answeredFile != null ?
            ImageMessage(isSent: widget.isSent,
              time: widget.messageDate,
              messageId: widget.messageId,
              isFirstMessage: widget.isFirstMessage,
              imageUrl: widget.answeredFile!.path,) :TextMessage(message: widget.messageAnswer!,
              withImageShadow: true,
              messageId: widget.messageAnswerId,
              isSent: true,
              isFirstMessage: true,
              time: DateTime.now(),)),
      ],
    );
  }
}
