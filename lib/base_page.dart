import 'dart:developer';
import 'dart:convert' as convert;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  const BasePage({Key? key }) : super(key: key);

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  late ChatBloc chatBloc;
  final List<Widget> pages = [
    const HomePage(),
    const HomePage(),
    const ChatPages(),
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
      Message message = Message.fromJson(
          convert.jsonDecode(event.data['message']));
      bloc.add(ReceiveMessageEvent(message: message));
      log('object ${event.data}');
      log('object ${event.senderId}');
      log('object ${event.notification?.title}');
      log('object ${event.notification?.body}');
      log('object ${event.notification?.bodyLocArgs}');
      log('object ${event.data}');
      LocalNotificationService().showNotificationWithPayload(message: event);
      // _handleNotificationForLocal('');
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
          print(state.getChatsStatus);
          print(state.sendMessageStatus);
          print(state.receiveMessageStatus);
          print(state.saveContactsStatus);
          print(state.getContactsStatus);
          print(state.readMessagesStatus);
          print(state.notifyThatIReceivedMessageStatus);
          print('kkkkkkkkkkkkkkk');
          if (initialMessage != null && state.chats.isNotEmpty) {
            print('kkkkkkkkkkk2222');
            AppBloc appBloc =BlocProvider.of<AppBloc>(context);
            appBloc.add(ChangeBasePage(2));
            chatBloc.add(ReadAllMessagesEvent(initialMessage!.channelId!));
            Chat chat = state.chats.firstWhere((element) => element.id == initialMessage!.channelId);
            int chatIndex = state.chats.indexWhere((element) => element.id == initialMessage!.channelId);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        return SinglePageChat(
                          chatIndex: chatIndex,

                          receiverName: chat.channelMembers
                              ?.firstWhere((element) =>
                          element.id == initialMessage!.senderUserId)
                              .user!
                              .name
                              .toString() ??
                              '',
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
