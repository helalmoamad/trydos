import 'dart:developer';
import 'dart:convert' as convert;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/app_bottom_navigation_bar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';

import 'features/chat/data/models/my_chats_response_model.dart';
import 'features/chat/presentation/manager/chat_bloc.dart';
import 'features/chat/presentation/manager/chat_event.dart';

class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  late ChatBloc chatBloc;
  final List<Widget> pages = [
    const HomePage(),
    const HomePage(),
    const ChatPages(description: ''),
    const HomePage(),
  ];

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    onMessage();
    super.initState();
  }

  void onMessage() {
    FirebaseMessaging.onMessage.listen((event) {
      ChatBloc bloc = BlocProvider.of<ChatBloc>(context);
      Message message = Message.fromJson(convert.jsonDecode(event.data['message']));
      String prevMessageId=event.data['prev_message_id'];
      bloc.add(ReceiveMessageEvent(message: message,prevMessageId: prevMessageId));
      log('object ${event.data}');
      log('object ${event.senderId}');
      log('object ${event.notification?.title}');
      log('object ${event.notification?.body}');
      log('object ${event.notification?.bodyLocArgs}');
      log('object ${event.data}');
      LocalNotificationService().showNotificationWithPayload(message: event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      bottomNavigationBar: BlocBuilder<AppBloc, AppState>(
          buildWhen: (p, c) => p.showBars != c.showBars,
          builder: (context, state) {
            if (state.showBars == true) {
              return const AppBottomNavBar();
            } else {
              return const SizedBox.shrink();
            }
          }),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (initialMessage != null && state.chats.isNotEmpty) {
            AppBloc appBloc = BlocProvider.of<AppBloc>(context);
            appBloc.add(ChangeBasePage(2));
            chatBloc.add(
                ReadAllMessagesEvent(initialMessage!.channelId!.toString()));
            List<Chat> chats = [];
            chats.addAll(state.pinnedChats);
            chats.addAll(state.chats);
            Chat chat = chats.firstWhere(
                (element) => element.id == initialMessage!.channelId);
            // int chatIndex = chats.indexWhere((element) => element.id == initialMessage!.channelId);
            User? receiver = chat.channelMembers!
                .firstWhere((element) =>
                    element.userId != GetIt.I<PrefsRepository>().myId)
                .user;
            String receiverName = receiver?.name ==null ? 'UK' :HelperFunctions.getTheFirstTwoLettersOfName(receiver!.name!);
            ChannelMember me = chat.channelMembers!.firstWhere(
                (element) => element.userId == GetIt.I<PrefsRepository>().myId);
            User? sender = me.user;
            String senderName = sender?.name ==null ? 'UK' :HelperFunctions.getTheFirstTwoLettersOfName(sender!.name!);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            return SinglePageChat(
                              chatId: chat.id!.toString(),
                              receiverName: receiverName,
                              fullReceiverName: receiver?.name ??
                                  receiver?.mobilePhone ??
                                  'Un Known User',
                              receiverPhone: receiver?.mobilePhone ??
                                  'Uo Number',
                              senderName: senderName,
                            );
                          },
                        )));
          }
        },
        child: BlocBuilder<AppBloc, AppState>(
          buildWhen: (oldState, newState) =>
              oldState.currentIndex != newState.currentIndex,
          builder: (_, state) {
            return pages[state.currentIndex];
          },
        ),
      ),
    );
  }
}
