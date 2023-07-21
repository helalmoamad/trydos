import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';

import '../../../../main.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_event.dart';

class ChatPageContent extends StatefulWidget {
  const ChatPageContent({Key? key}) : super(key: key);

  @override
  State<ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<ChatPageContent> {
  late ChatBloc chatBloc;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context)
      ..add(const GetContactsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {

      },
      builder: (context, state) {
        if (state.getChatsStatus == GetChatsStatus.loading) {
          return SliverToBoxAdapter(child: TrydosLoader());
        }
        return SlidableAutoCloseBehavior(
          closeWhenOpened: true,
          child: sliverListSeparated(
            itemBuilder: (_, index) => Visibility(
              visible: (state.chats[index].messages?.isNotEmpty ?? false),
              child: ChatCard(
                isTyping: false,
                chat: state.chats[index],
                index: index,
              ),
            ),
            separator: const SizedBox.shrink(),
            childCount: state.chats.length,
          ),
        );
      },
    );
  }
}
