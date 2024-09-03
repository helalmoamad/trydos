import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_state.dart';
import '../utils/firebase_presence.dart';

class ChatPageContent extends StatefulWidget {
  const ChatPageContent({Key? key, this.onSendForwardMessage})
      : super(key: key);
  final Function(int receiverId, String channelId)? onSendForwardMessage;

  @override
  State<ChatPageContent> createState() => ChatPageContentState();
}

class ChatPageContentState extends State<ChatPageContent> {
  late Timer timers;
  late ChatBloc chatBloc;
  int differencetime = 0;
  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    differencetime = GetIt.I<PrefsRepository>().getdurtion ?? 0;

    FirebasePresence.sendUserStatus(DateTime.now()
        .toUtc()
        .add(Duration(minutes: differencetime))
        .toString());

    timers = Timer.periodic(Duration(minutes: 4), (timer) {
      FirebasePresence.sendUserStatus(DateTime.now()
          .toUtc()
          .add(Duration(minutes: differencetime))
          .toString());
    });

    super.initState();
  }

  @override
  void dispose() {
    timers.cancel();
    super.dispose();
  }
// todo 9/21 unused code
//  late ChatBloc chatBloc;

//  @override
//  void initState() {
//
//    chatBloc = BlocProvider.of<ChatBloc>(context);
//    super.initState();
//  }
  static ValueNotifier<List<Chat>> searchChats = ValueNotifier([]);
  static List<Chat> initialChats = [];

  static searchInChats(String? text) {
    if (text?.isEmpty ?? true) {
      searchChats.value = initialChats;
    } else {
      List<Chat> search = [];
      for (Chat chat in initialChats) {
        ChannelMember member = chat.channelMembers!.firstWhere(
            (element) => element.userId != GetIt.I<PrefsRepository>().myChatId);
        if ((chat.channelName ?? LocaleKeys.unknown_user.tr())
                .toLowerCase()
                .contains(text?.toLowerCase() ?? '') ||
            (member.user?.mobilePhone ?? LocaleKeys.no_num.tr())
                .toLowerCase()
                .contains(text?.toLowerCase() ?? '')) {
          search.add(chat);
        }
      }
      searchChats.value = search;
    }
  }

  @override
// ! asd
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Chat_Page_Content"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print(error);
    };
    //todo  9/21  change it to BlocBuilder
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) =>
          p.getChatsStatus != c.getChatsStatus ||
          p.unReadMessagesFromAllChats != c.unReadMessagesFromAllChats ||
          (p.changeChatPropertyStatus != c.changeChatPropertyStatus &&
              c.changeChatPropertyStatus != ChangeChatPropertyStatus.success) ||
          p.deleteChatStatus != c.deleteChatStatus ||
          c.createAnewChat ||
          c.sendMessageStatus == SendMessageStatus.loading ||
          p.receiveMessageStatus != c.receiveMessageStatus,
      builder: (context, state) {
        if ((state.getChatsStatus == GetChatsStatus.loading ||
                state.getChatsStatus == GetChatsStatus.init) &&
            state.chats.isEmpty &&
            state.pinnedChats.isEmpty) {
          return SliverToBoxAdapter(
              child: SizedBox(
            height: 1.sh - 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TrydosLoader(),
              ],
            ),
          ));
        }
        if (state.getChatsStatus == GetChatsStatus.failure) {
          return SliverToBoxAdapter(
            child: Center(
              child: ElevatedButton(
                  onPressed: () {
                    GetIt.I<ChatBloc>().add(GetChatsEvent(limit: 10));
                  },
                  child: MyTextWidget(LocaleKeys.try_again.tr())),
            ),
          );
        }
        // todo (future update) here we can return try again if the status failure
        List<Chat> chats = List.of(state.pinnedChats);
        chats.addAll(List.of(state.chats));
        // todo  (future update) remove this from here handle it in the back of in bloc

        chats.removeWhere((element) =>
            // int.tryParse(element.id.toString()) == null &&
            (element.messages.isNullOrEmpty));

        initialChats = chats;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          searchChats.value = chats;
        });
        return SlidableAutoCloseBehavior(
          closeWhenOpened: true,
          closeWhenTapped: true,
          child: BlocBuilder<AppBloc, AppState>(
            buildWhen: (p, c) =>
                p.pusherActivityIds.length != c.pusherActivityIds.length,
            builder: (context, appState) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                      child: Container(
                          width: 1.sw,
                          color: colorScheme.white,
                          child:
                              state.getChatsStatus != GetChatsStatus.success &&
                                      state.firstRequestForGetChats
                                  ? TrydosLoader()
                                  : const SizedBox.shrink())),
                  ValueListenableBuilder<List<Chat>>(
                      valueListenable: searchChats,
                      builder: (context, searchedChats, _) {
                        return sliverListSeparated(
                            separator: const SizedBox.shrink(),
                            childCount: searchedChats.length,
                            itemBuilder: (_, index) {
                              bool thereActivity = int.tryParse(
                                          searchedChats[index].id.toString()) !=
                                      null
                                  ? appState.pusherActivityIds.containsKey(
                                      int.parse(
                                          searchedChats[index].id.toString()))
                                  : false;
                              return ChatCard(
                                key: TestVariables.kTestMode
                                    ? Key(
                                        '${WidgetsKey.chatConversationCardKey}$index',
                                      )
                                    : null,
                                onSendForwardMessage:
                                    widget.onSendForwardMessage,
                                chat: searchedChats[index],
                                thereActivity: thereActivity,
                                index: index,
                                activityDescription: thereActivity
                                    ? appState.pusherActivityDescription[
                                        int.parse(
                                            searchedChats[index].id.toString())]
                                    : null,
                                messageId:
                                    searchedChats[index].messages?.first.id ??
                                        "",
                              );
                            });
                      }),
                  SliverToBoxAdapter(
                      child: Container(
                          width: 1.sw,
                          color: colorScheme.white,
                          child:
                              state.getChatsStatus != GetChatsStatus.success &&
                                      !state.firstRequestForGetChats
                                  ? TrydosLoader()
                                  : const SizedBox.shrink())),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
