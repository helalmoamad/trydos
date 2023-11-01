import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/app/blocs/sensitive_connectivity/connectivity_observer.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/service/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'features/chat/presentation/manager/chat_event.dart';
import 'dart:convert' as convert;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!isDependencyInitialized) {
    await configureDependencies();
    isDependencyInitialized = true;
  }
  LocalNotificationService().showNotificationWithPayload(message: message);
}

bool isDependencyInitialized = false;
Timer? timer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked = false;
Message? initialMessage;
//todo this list will store on it the api's that we try to load it and returned a failure for the first time so we check if it's in this list we try to reload it
List<String> isFailedTheFirstTime=[];


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  //todo initialization for local notification
  await NotificationService().initNotification();
  isDependencyInitialized = true;
  HttpOverrides.global = MyHttpOverrides();
  GetIt.I<AuthBloc>().add(GetUserCountryEvent());
  await NotificationProcess().init();
  if(Platform.isAndroid) {
    RemoteMessage? openedMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      initialMessage =
          Message.fromJson(convert.jsonDecode(openedMessage!.data['message']));
    }
    await NotificationProcess().setupInteractedMessage();
    await NotificationProcess().fcmToken();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  AssetPicker.registerObserve();
  PhotoManager.setLog(true);
  FlutterError.onError = (FlutterErrorDetails error) {
    GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: error.toString());
  };
  await dealWithTimer();
  runApp(TrydosApplication(navKey: navigatorKey,));
}

dealWithTimer() async {
  final PrefsRepository prefs = GetIt.I<PrefsRepository>();
  timer?.cancel();
  timer = Timer.periodic(const Duration(minutes: 2), (timer) {
    if ((ConnectivityObserver.currentEvent == ConnectivityResult.wifi ||
            ConnectivityObserver.currentEvent == ConnectivityResult.mobile) &&
        prefs.chatToken != null) {
      GetIt.I<ChatBloc>().add(const GetChatsEvent());
    }
  });
}
