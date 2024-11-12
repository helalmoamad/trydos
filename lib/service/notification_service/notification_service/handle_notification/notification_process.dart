import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:get_it/get_it.dart';
import '../../../../base_page.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../features/chat/data/models/my_chats_response_model.dart';
import '../../../../features/chat/presentation/manager/chat_bloc.dart';
import '../../../../features/chat/presentation/manager/chat_event.dart';
import '../../../../firebase_options.dart';
import 'handling_market_notifications.dart';
import 'i_notification_factory.dart';
import 'local_notification_service.dart';
import 'notification_type.dart';
import '../notification_utils/payload_model.dart';
import 'notificaton_factory_impl.dart';
import 'dart:convert' as convert;

class NotificationProcess {
  static NotificationProcess? _instance;
  static String? myFcmToken;

  NotificationProcess._singleton();

  factory NotificationProcess() =>
      _instance ??= NotificationProcess._singleton();

  handleNotificationForLocal(String? payload) {
    if (payload != null) {
      final PayloadModel payloadModel =
          PayloadModel.fromJson(jsonDecode(payload));
      INotificationFactory factory = NotificationFactoryImpl();
      NotificationType notification =
          factory.getNotificationType(NotificationTypeName.delivery);
      notification.executeNotification(payloadModel);
    }
  }

  Future fcmToken() async {
    myFcmToken = await FirebaseMessaging.instance.getToken();
    print(
        "44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444${myFcmToken}******");
    if (myFcmToken != null) {
      GetIt.I<PrefsRepository>().addFcmToken(myFcmToken!);
    }
    log(myFcmToken.toString());
  }

  void onRefreshToken() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('onRefreshToken: $token');
    });
  }

  Future<void> _setForegroundNotificationPresentationOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  requestPermission() async {
    if (!Platform.isIOS) {
      return;
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  setupInteractedMessage() {
    print(
        "-*******444444444444444444444444444----------------*****************---------------***********---------");
    handleTappedNotificationOnTerminatedState();
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if(HandlingMarketNotifications.checkIfTheNotificationIsNotRelatedToChat(event)){
        HandlingMarketNotifications.dealWithNotificationFromMarket(convert.jsonDecode(event.data['data']));
        return;
      }
      Map remoteMessage = convert.jsonDecode(event.data['data']);
      handleOpenChatPageFromNotificationInBackground(
          remoteMessage['prev_message_id'],
          message: Message.fromJson(remoteMessage['message']));
    });
  }

  handleTappedNotificationOnTerminatedState() async {
    fln.NotificationAppLaunchDetails? details = await LocalNotificationService
        .localNotificationPlugin
        .getNotificationAppLaunchDetails();

    if (details != null) {
      if (details.didNotificationLaunchApp) {
        Message myMessage = Message.fromJson(convert
            .jsonDecode(details.notificationResponse!.payload!.split(',,')[0]));
        print(myMessage.messageContent?.content);
        GetIt.I<ChatBloc>().add(GetChatsEvent(
            chatToNavigateFromTerminated: myMessage.channel, limit: 10));
      }
    }
  }

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('firebase error $e');
      rethrow;
    }
    await _setForegroundNotificationPresentationOptions();

    await LocalNotificationService.initialize();
  }
}
