import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/app/blocs/sensitive_connectivity/connectivity_observer.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'features/chat/presentation/manager/chat_event.dart';
import 'dart:convert' as convert;
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if(!isDependencyInitialized){
    await configureDependencies();
    isDependencyInitialized=true;
  }
  LocalNotificationService().showNotificationWithPayload(message: message);
}
bool isDependencyInitialized=false;
 Timer? timer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked =false;
Message? initialMessage;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  isDependencyInitialized=true;
  await NotificationProcess().init();
  RemoteMessage? openedMessage = await FirebaseMessaging.instance.getInitialMessage();
  if(initialMessage != null){
    print('hello');
    initialMessage = Message.fromJson(
        convert.jsonDecode(openedMessage!.data['message']));
  }
  await  NotificationProcess().setupInteractedMessage();
  await NotificationProcess().fcmToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AssetPicker.registerObserve();
  PhotoManager.setLog(true);
  FlutterError.onError = (FlutterErrorDetails error) {
    GetIt.I<PrefsRepository>().saveRequestsData(
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        error: error.toString());
  };
  //   GetIt.I<Dio>().post(ChatEndPoints.createBugEP, data: {
  //     "user_id": GetIt.I<PrefsRepository>().myChatId,
  //     "title": "flutter error",
  //     "description": error.toString()
  //   });
  // };
  // Isolate.current.addErrorListener(RawReceivePort((pair) async {
  //   final List<dynamic> errorAndStacktrace = pair;
  // }).sendPort);
  HttpOverrides.global =  MyHttpOverrides();
  await dealWithTimer();
  runApp( TrydosApplication(navKey: navigatorKey,));
}

 dealWithTimer() async{
  final  PrefsRepository prefs = GetIt.I<PrefsRepository>();
  timer?.cancel();
  timer=Timer.periodic(const Duration(minutes: 2 ), (timer) {
    if((ConnectivityObserver.currentEvent==ConnectivityResult.wifi || ConnectivityObserver.currentEvent==ConnectivityResult.mobile) && prefs.chatToken!=null) {
      GetIt.I<ChatBloc>().add(const GetChatsEvent());
    }
  });
}


