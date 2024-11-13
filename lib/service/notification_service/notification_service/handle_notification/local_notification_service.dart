import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import '../../../../base_page.dart';
import '../../../../core/di/di_container.dart';

import '../../../../features/chat/presentation/manager/chat_bloc.dart';
import '../../../../features/chat/presentation/manager/chat_event.dart';
import '../../../../features/chat/data/models/my_chats_response_model.dart'
    as chat;
import 'dart:convert' as convert;

import 'handling_market_notifications.dart';

@pragma('vm:entry-point')
class LocalNotificationService {
  static final _localNotificationPlugin = FlutterLocalNotificationsPlugin();
  final String _androidChannelId = r'$_$_1_$_$';
  final String _androidChannelName = "Notification";

  static FlutterLocalNotificationsPlugin get localNotificationPlugin =>
      _localNotificationPlugin;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
            LocalNotificationService().getAndroidChannel);

    await _localNotificationPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: _onSelectNotification,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  @pragma('vm:entry-point')
  Future<void> showNotificationWithPayload(
      {required RemoteMessage message}) async {
    if(HandlingMarketNotifications.checkIfTheNotificationIsNotRelatedToChat(message)){
      await _localNotificationPlugin.show(
          0,
          'Title',
          'Body',
          _notificationDetails(),
          payload: convert.jsonEncode(message.data['message']));
      return ;
    }
    Map RemoteMessage = convert.jsonDecode(message.data['data']);
    chat.Message myMessage = chat.Message.fromJson(RemoteMessage["message"]);
    String prevMessageId = RemoteMessage['prev_message_id'].toString();
    String type = myMessage.messageType!.name.toString();
    await _localNotificationPlugin.show(
        0,
        myMessage.channel?.channelName ?? 'No Channel Name',
        type == 'TextMessage'
            ? myMessage.messageContent!.content.toString()
            : type == 'ImageMessage'
                ? 'Photo'
                : type == 'VoiceMessage'
                    ? 'Voice'
                    : type == 'VideoMessage'
                        ? 'Video'
                        : 'File',
        _notificationDetails(),
        payload:
            '${convert.jsonEncode(RemoteMessage['message'])},,${prevMessageId}');
  }

  static void sendIReceivedTheMessage(String channelId) async {
    HttpOverrides.global = MyHttpOverrides();
    GetIt.I<ChatBloc>()
        .add(NotifyThatIReceivedMessageEvent(channelId: channelId));
  }

  @pragma('vm:entry-point')
  Future<void> uploadingNotification(
      maxProgress, progress, isUploading, bool isUploadingSuccess) async {
    if (isUploading) {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              "uploading files", "Uploading Files Notifications",
              channelDescription: "show to user progress for uploading files",
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.max,
              onlyAlertOnce: true,
              showProgress: true,
              maxProgress: maxProgress,
              progress: progress,
              autoCancel: false);

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _localNotificationPlugin.show(
        5,
        'Uploading story',
        '',
        platformChannelSpecifics,
      );
    } else {
      final IosNotificationDetails = DarwinNotificationDetails();
      _localNotificationPlugin.cancel(5);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          const AndroidNotificationDetails(
        "files",
        "Files Notifications",
        channelDescription: "Inform user files uploaded",
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
      );

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics , iOS: IosNotificationDetails);
      await _localNotificationPlugin.show(
        5,
        isUploadingSuccess ? 'upload story success' : 'upload story failed',
        '',
        platformChannelSpecifics,
      );
    }
  }


  @pragma('vm:entry-point')
  static void _onSelectNotification(NotificationResponse notificationResponse) {
    if(!notificationResponse.payload!.contains(',,')){
      HandlingMarketNotifications.dealWithNotificationFromMarket(convert.jsonDecode(notificationResponse.payload.toString()));
      return;
    }
    chat.Message myMessage = chat.Message.fromJson(
        convert.jsonDecode(notificationResponse.payload!.split(',,')[0]));
    String prevMessageId = notificationResponse.payload!.split(',,')[1];

    handleOpenChatPageFromNotificationInBackground(prevMessageId,
        message: myMessage);
  }

  _notificationDetails() {
    final channel = LocalNotificationService().getAndroidChannel;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      ticker: 'ticker',
      importance: channel.importance,
      priority: Priority.max,
      playSound: channel.playSound,
      enableVibration: channel.enableVibration,
    );
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    return NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
  }

  AndroidNotificationChannel get getAndroidChannel =>
      AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName, // title
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
}
