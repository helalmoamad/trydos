import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';

class ReplayOnMeMessage extends StatefulWidget {
  const ReplayOnMeMessage({Key? key,
    required this.message,
    required this.messageId,
    required this.messageAnswerId,
     this.messageAnswer,
    this.answeredFile,
    required this.isSent,
    required this.messageDate,
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
    return Column(
      children: [
        TextMessage(
            key: key,
            sendColor: const Color(0xffF1FDE3),
            message: widget.message,
            withShadow: false,
            withImageShadow: false,
            messageId: widget.messageId,
            isSent: widget.isSent,
            time: widget.messageDate,
            isFirstMessage: true),
        Transform.translate(
            offset: Offset(height < 60 ? 10 : 0, -20.h),
            child: widget.answeredFile != null ?
            ImageMessage(isSent: widget.isSent,
              time: DateTime.now(),
              messageId: widget.messageId,
              isFirstMessage: widget.isFirstMessage,
              imageUrl: widget.answeredFile!.path,) :
            TextMessage(
                message: widget.messageAnswer!,
                withImageShadow: true,
                messageId: widget.messageAnswerId,
                isSent: widget.isSent,
                time: widget.messageDate,
                isFirstMessage: true)),
      ],
    );
  }
}
