import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:get_it/get_it.dart';
import 'package:trydos/main.dart';
import '../../../../base_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../../features/chat/presentation/manager/chat_bloc.dart';
import '../../../../features/chat/presentation/manager/chat_event.dart';
import '../../../../features/chat/presentation/pages/single_page_chat.dart';
import '../../../../firebase_options.dart';
import 'i_notification_factory.dart';
import 'local_notification_service.dart';
import 'notification_type.dart';
import '../notification_utils/payload_model.dart';
import 'notificaton_factory_impl.dart';
import '../../../../features/chat/data/models/my_chats_response_model.dart' as chat;
import 'package:trydos/main.dart' as main;
import 'dart:convert' as convert;
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

    fcmToken() async {
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

  Future<void> setupInteractedMessage() async {
    // if (initialMessage != null) {
    //   LocalNotificationService().showNotificationWithPayload(message: initialMessage);
    // }

    // handleTappedNotificationOnTerminatedState();
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('foreground message');
      print('onMessageOpenedApp');
      chat.Message myMessage = chat.Message.fromJson(
          convert.jsonDecode(event.data['message']));
      main.initialMessage=myMessage;
      navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (_)=> const BasePage()),(route) => false,);
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
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };


    } catch (e) {
      print(e);
      rethrow;
    }

    await _setForegroundNotificationPresentationOptions();

    await LocalNotificationService.initialize();
  }

}
