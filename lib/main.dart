import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/utils/pusher_chat.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'common/constant/configuration/url_routes.dart';
import 'core/domin/repositories/prefs_repository.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LocalNotificationService().showNotificationWithPayload(message: message);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked =false;
Message? initialMessage;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  await NotificationProcess().init();
  await  NotificationProcess().setupInteractedMessage();
  NotificationProcess().fcmToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AssetPicker.registerObserve();
  PhotoManager.setLog(true);
  log( GetIt.I<PrefsRepository>().token.toString());
  // FlutterError.onError = (FlutterErrorDetails error) {
  //   GetIt.I<Dio>().post(EndPoints.createBugEP, data: {
  //     "user_id": GetIt.I<PrefsRepository>().myId,
  //     "title": "flutter error",
  //     "description": error.toString()
  //   });
  // };
  // Isolate.current.addErrorListener(RawReceivePort((pair) async {
  //   final List<dynamic> errorAndStacktrace = pair;
  // }).sendPort);
  HttpOverrides.global =  MyHttpOverrides();
  runApp( TrydosApplication(navKey: navigatorKey,));
}


