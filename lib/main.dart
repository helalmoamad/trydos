import 'dart:async';
import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("cvxvvkhgka${message.data}");
  if (message.data['type'] == 'VideoCallEvent') {
    debugPrint('sdas');
    CallEvent callEvent = CallEvent(
        sessionId: '20',
        callType: 1,
        callerId: 2,
        callerName: 'Caller Name',
        opponentsIds: {2},
        callPhoto: 'https://i.imgur.com/KwrDil8b.jpg',
        userInfo: {'customParameter1': 'value1'});

    await ConnectycubeFlutterCallKit.showCallNotification(callEvent);
    debugPrint('asxsdas');
  } else {
    debugPrint('sdaxcv,s');

    if (!isDependencyInitialized) {
      await configureDependencies();
      isDependencyInitialized = true;
    }
    LocalNotificationService().showNotificationWithPayload(message: message);
  }
}

bool isDependencyInitialized = false;
Timer? timer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked = false;
Message? initialMessage;
//todo this list will store on it the api's that we try to load it and returned a failure for the first time so we check if it's not  in this list we try to reload it
List<String> isFailedTheFirstTime = [];

@pragma('vm:entry-point')
Future<void> _onCallRejected(CallEvent callEvent) async {
  debugPrint("callaczx${callEvent.callerName}");
  debugPrint("callaczx${callEvent.callPhoto}");
  // callEvent.
}

@pragma('vm:entry-point')
Future<void> _onCallAccepted(CallEvent callEvent) async {
  // the call was accepted
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);

  // onCallRejectedWhenTerminated
  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated = _onCallRejected;
  ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated = _onCallAccepted;

  // ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    configureDependencies(),
    NotificationProcess().init(),
    NotificationProcess().setupInteractedMessage(),
  ]);
  ConnectycubeFlutterCallKit.instance.init(ringtone: 'ringtone1');
  NotificationProcess().fcmToken();
  isDependencyInitialized = true;
  HttpOverrides.global = MyHttpOverrides();
  GetIt.I<AuthBloc>().add(GetUserCountryEvent());
  RemoteMessage? openedMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    initialMessage =
        Message.fromJson(convert.jsonDecode(openedMessage!.data['message']));
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterError.onError = (FlutterErrorDetails error) {
    GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: error.toString());
  };
  runApp(TrydosApplication(
    navKey: navigatorKey,
  ));
}
