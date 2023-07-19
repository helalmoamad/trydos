import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'core/domin/repositories/prefs_repository.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LocalNotificationService().showNotificationWithPayload(message: message);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
RemoteMessage? initialMessage;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  await NotificationProcess().init();
  initialMessage = await  NotificationProcess().setupInteractedMessage();
  NotificationProcess().fcmToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AssetPicker.registerObserve();
  PhotoManager.setLog(true);
  log( GetIt.I<PrefsRepository>().token.toString());
  // FlutterError.onError = (FlutterErrorDetails error) {};
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   return true;
  // };
  // Isolate.current.addErrorListener(RawReceivePort((pair) async {
  //   final List<dynamic> errorAndStacktrace = pair;
  // }).sendPort);
  HttpOverrides.global =  MyHttpOverrides();
  runApp( TrydosApplication(navKey: navigatorKey,));
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

