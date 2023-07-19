import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:trydos/main.dart';
import '../../../../features/chat/presentation/pages/single_page_chat.dart';
import '../../../../firebase_options.dart';
import 'i_notification_factory.dart';
import 'local_notification_service.dart';
import 'notification_type.dart';
import '../notification_utils/payload_model.dart';
import 'notificaton_factory_impl.dart';
class NotificationProcess {
  static NotificationProcess? _instance;
  static String? myFcmToken;
  NotificationProcess._singleton();

  factory NotificationProcess() => _instance ??= NotificationProcess._singleton();

  handleNotificationForLocal(String? payload) {
    if (payload != null) {
      final PayloadModel payloadModel = PayloadModel.fromJson(jsonDecode(payload));
      INotificationFactory factory = NotificationFactoryImpl();
      NotificationType notification = factory.getNotificationType(NotificationTypeName.delivery);
      notification.executeNotification(payloadModel);
    }
  }

   void fcmToken() async {
      myFcmToken = await FirebaseMessaging.instance.getToken();
      log(myFcmToken.toString());
  }

  void onRefreshToken() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print('onRefreshToken: $token');
    });
  }

  Future<void> _setForegroundNotificationPresentationOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
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

  Future<RemoteMessage?> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      LocalNotificationService().showNotificationWithPayload(message: initialMessage);
    }
    return initialMessage;

    handleTappedNotificationOnTerminatedState();

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      log('fore ground message');
      handleNotificationForLocal('');
    });
  }

  handleTappedNotificationOnTerminatedState() async {
    fln.NotificationAppLaunchDetails? details =
        await LocalNotificationService.localNotificationPlugin.getNotificationAppLaunchDetails();
    if (details != null) {
      if (details.didNotificationLaunchApp) {
        handleNotificationForLocal(details.notificationResponse?.payload);
      }
    }
  }

  Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      rethrow;
    }

    await _setForegroundNotificationPresentationOptions();

    await LocalNotificationService.initialize();
  }

}
