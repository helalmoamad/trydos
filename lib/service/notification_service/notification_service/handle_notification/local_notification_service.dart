import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/features/chat/data/data_sources/chat_remote_datasource.dart';
import 'package:trydos/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:trydos/features/chat/domain/use_cases/receive_message_usecase.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import '../../../../core/di/di_container.dart';
import '../../../../features/app/blocs/sensitive_connectivity/connectivity_observer.dart';
import '../../../../features/chat/presentation/manager/chat_bloc.dart';
import '../../../../features/chat/presentation/manager/chat_event.dart';
import 'notification_process.dart';
import '../../../../features/chat/data/models/my_chats_response_model.dart' as chat;
import 'dart:convert' as convert;

class LocalNotificationService {
  static final _localNotificationPlugin = FlutterLocalNotificationsPlugin();

  final String _androidChannelId = r'$_$_1_$_$';
  final String _androidChannelName = "Notification";

  static FlutterLocalNotificationsPlugin get localNotificationPlugin => _localNotificationPlugin;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('app_icon');

    DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotificationPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(LocalNotificationService().getAndroidChannel);

    await _localNotificationPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: _onSelectNotification,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  Future<void> showNotificationWithPayload({required RemoteMessage message}) async {
    dealWithTimer();
    print('hello');
    chat.Message myMessage = chat.Message.fromJson(
        convert.jsonDecode(message.data['message']));
    sendIReceivedTheMessage(myMessage.channelId!);
    String type=myMessage.messageType!.name.toString();
    String prevMessageId=message.data['prev_message_id'];
    await _localNotificationPlugin.show(
      0,
      myMessage.senderInfo!.name ?? myMessage.senderMobilePhone ?? 'Un Known User',
      type == 'TextMessage' ? myMessage.messageContent!.content.toString() :  type=='ImageMessage' ? 'Photo' :type=='VoiceMessage' ? 'Voice' : type == 'VideoMessage' ? 'Video' :'File',
      _notificationDetails(),
      payload: '${message.data['message']},,${prevMessageId}'
    );
  }
   static void sendIReceivedTheMessage(String channelId)async {
     HttpOverrides.global =  MyHttpOverrides();
    GetIt.I<ChatBloc>().add(NotifyThatIReceivedMessageEvent(channelId: channelId));
   }


  static void _onSelectNotification(NotificationResponse notificationResponse) {
    print('tapped');
    chat.Message myMessage = chat.Message.fromJson(
        convert.jsonDecode(notificationResponse.payload!.split(',,')[0]));
    String prevMessageId=notificationResponse.payload!.split(',,')[1];
    print('ok');
    initialMessage=myMessage;
    GetIt.I<ChatBloc>().add(ReceiveMessageEvent(message: myMessage,prevMessageId: prevMessageId));
    navigatorKey.currentState!.context.go(GRouter.config.applicationRoutes.kBasePage);
  }
  _notificationDetails() {
    final channel = LocalNotificationService().getAndroidChannel;

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      ticker: 'ticker',
      importance: channel.importance,
      priority: Priority.max,
      playSound: channel.playSound,
      enableVibration: channel.enableVibration,
    );
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails();

    return NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
  }

  AndroidNotificationChannel get getAndroidChannel => AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName, // title
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
}
