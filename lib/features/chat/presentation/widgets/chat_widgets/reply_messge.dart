
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';

class ReplayMessage extends StatefulWidget {
  const ReplayMessage({Key? key , required this.message}) : super(key: key);
  final String message;
  @override
  State<ReplayMessage> createState() => _ReplayMessageState();
}

class _ReplayMessageState extends State<ReplayMessage> {
  double height=1;
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
            receivedColor:const Color(0xffD5F6E6),message: 'The person who says it cannot be only onc done should not interrupt the person who is doing it.',withShadow: false,withImageShadow: false, messageId: '12', isSent: false, isFirstMessage: true),
         Transform.translate(
             offset: Offset(height< 60 ? 10 : 0,-20.h),
             child: TextMessage(message: widget.message,withImageShadow: true, messageId: '13', isSent: true, isFirstMessage: true)),
      ],
    );
  }
}
