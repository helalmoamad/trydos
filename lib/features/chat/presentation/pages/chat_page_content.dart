import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';

import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../manager/chat_bloc.dart';

class ChatPageContent extends StatefulWidget {
  const ChatPageContent({Key? key, this.onSendForwardMessage})
      : super(key: key);
  final Function(int receiverId , String channelId)? onSendForwardMessage;

  @override
  State<ChatPageContent> createState() => ChatPageContentState();
}

class ChatPageContentState extends State<ChatPageContent> {

// todo 9/21 unused code
//  late ChatBloc chatBloc;

//  @override
//  void initState() {
//
//    chatBloc = BlocProvider.of<ChatBloc>(context);
//    super.initState();
//  }
  static ValueNotifier<List<Chat>> searchChats=ValueNotifier([]);
  static List<Chat> initialChats=[];

  static searchInChats(String? text){
    if(text?.isEmpty ?? true){
      searchChats.value=initialChats;
    }else{
      List<Chat> search=[];
      for(Chat chat in initialChats){
        ChannelMember member=chat.channelMembers!.firstWhere((element) => element.userId!=GetIt.I<PrefsRepository>().myChatId);
        if((member.user?.name ?? 'UnKnown User').toLowerCase().contains(text?.toLowerCase() ?? '') || (member.user?.mobilePhone ?? 'No Number').toLowerCase().contains(text?.toLowerCase() ?? '')){
          search.add(chat);
        }
      }
      searchChats.value=search;
    }
  }
  @override
// ! asd
  Widget build(BuildContext context) {
    //todo  9/21  change it to BlocBuilder
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p,c)=> p.getChatsStatus != c.getChatsStatus || p.unReadMessagesFromAllChats != c.unReadMessagesFromAllChats,
      builder: (context, state) {
        if (state.getChatsStatus == GetChatsStatus.loading && state.chats.isEmpty && state.pinnedChats.isEmpty) {
          return SliverToBoxAdapter(child: TrydosLoader());
        }
        // todo (future update) here we can return try again if the status failure

        List<Chat> chats = [];
        chats.addAll(state.pinnedChats);
        chats.addAll(state.chats);

        // todo  (future update) remove this from here handle it in the back of in bloc
        chats.removeWhere((element) => int.tryParse(element.id.toString())==null && (element.messages?.isEmpty ?? true));
        initialChats=chats;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          searchChats.value=chats;
        });
        return SlidableAutoCloseBehavior(

          closeWhenOpened: true,
          closeWhenTapped: true,
          child: BlocBuilder<AppBloc, AppState>(
            buildWhen: (p,c)=> p.pusherActivityIds.length != c.pusherActivityIds.length,
            builder: (context, appState) {
              return ValueListenableBuilder<List<Chat>>(
                valueListenable: searchChats,
                builder: (context , searchedChats , _) {
                  return sliverListSeparated(
                    itemBuilder: (_, index) {
                      bool thereActivity=appState.pusherActivityIds.containsKey(int.parse(searchedChats[index].id.toString()));
                      return
                        ChatCard(
                          onSendForwardMessage: widget.onSendForwardMessage,
                          chat: searchedChats[index],
                          thereActivity: thereActivity,
                          index: index,
                          activityDescription: thereActivity ? appState.pusherActivityDescription[int.parse(searchedChats[index].id.toString())]: null,
                        )
                      ;
                    },
                    separator: const SizedBox.shrink(),
                    childCount: searchedChats.length,
                  );
                }
              );
            },
          ),
        );
      },
    );
  }
}
