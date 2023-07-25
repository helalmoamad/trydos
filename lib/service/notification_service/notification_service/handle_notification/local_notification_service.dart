import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trydos/main.dart';
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
    chat.Message myMessage = chat.Message.fromJson(
        convert.jsonDecode(message.data['message']));
    await _localNotificationPlugin.show(
      0,
      myMessage.senderInfo!.name.toString(),
      myMessage.messageType!.name == 'TextMessage' ? myMessage.messageContent!.content.toString() : myMessage.messageType!.name =='ImageMessage' ? 'Photo' : 'Voice',
      _notificationDetails(),
      payload: message.data['message'],
    );
  }

  static void _onSelectNotification(NotificationResponse notificationResponse) {
    chat.Message myMessage = chat.Message.fromJson(
        convert.jsonDecode(notificationResponse.payload!));
    initialMessage=myMessage;
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
