
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';

import '../../../home/presentation/widgets/sliver_list_seprated.dart';

class ChatPageContent extends StatefulWidget {
  const ChatPageContent({Key? key}) : super(key: key);

  @override
  State<ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<ChatPageContent> {
  @override
  Widget build(BuildContext context) {
    return  SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      child: sliverListSeparated(
        itemBuilder: (_, index) =>
            ChatCard(
              isTyping: index == 0,
              index: index,
            ),
        separator: const SizedBox.shrink(),
        childCount: 8,
      ),
    );
  }
}
