import 'dart:async';
import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:uuid/uuid.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // if (!isDependencyInitialized) {
  //   await configureDependencies();
  //   isDependencyInitialized = true;
  // }
  Map<String, dynamic> data =
  convert.jsonDecode(message!.data['data'].toString());
  debugPrint("cvxvvkhgka${message.data}");
  if (message.data['type'] == 'VideoCallEvent') {
    var currentUuid = Uuid().v4();
    CallKitParams callKitParams = CallKitParams(
      id: currentUuid,
      nameCaller: data['payload']['callerName'],
      appName: 'Trydos',
      avatar: 'https://i.pravatar.cc/100',
      handle:    data['payload']['mobilePhone'] ,
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 10000,
      extra: <String, dynamic>{'channel_id': data['channel_id']},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call"),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  } //
//     debugPrint(message.data.toString());
//     Map<String, dynamic> data =
//         convert.jsonDecode(message!.data['data'].toString());
//
// // UUID
// // debugPrint(
//     //     'VideoCallEvent ${data['channel_id'].toString() ?? 'EmptyVideoCallEvent'}');
//     // debugPrint(' ${data ?? 'EmptyVideoCallEvent'}');
//     //
//     // Chat currentChat = GetIt.I<ChatBloc>().state
//     //     .chats
//     //     .firstWhere((element) => element.id == data['channel_id'].toString());
//     //
//     // debugPrint("myChatId${GetIt.I<PrefsRepository>().myChatId}");
//     // debugPrint("chatVideoEvent${currentChat.id}");
//     // debugPrint("szcjtyj${GetIt.I<ChatBloc>().state.chats}");
//     //
//     // ChannelMember currentCaller = GetIt.I<ChatBloc>()
//     //     .state
//     //     .chats
//     //     .firstWhere((element) => element.id == data['channel_id'].toString())
//     //     .channelMembers!
//     //     .firstWhere((element) =>
//     //         element.user!.id != GetIt.I<PrefsRepository>().myChatId);
//     // String callerName = currentCaller.user!.contactUser == null
//     //     ? (currentCaller.user!.name == null
//     //         ? 'unKnown'
//     //         : currentCaller.user!.name!)
//     //     : (currentCaller.user!.name == null
//     //         ? currentCaller.user!.contactUser!.mobilePhone!
//     //         : currentCaller.user!.contactUser!.name!);
//     // String photoPath = currentCaller.user == null
//     //     ? 'https://i.imgur.com/KwrDil8b.jpg'
//     //     : (currentCaller.user!.photoPath ?? 'https://i.imgur.com/KwrDil8b.jpg');
//     CallEvent callEvent = CallEvent(
//         sessionId: Uuid().v1(),
//         callType: 1,
//         callerId: 2,
//         callerName: data['payload']['callerName'],
//         opponentsIds: {2},
//         callPhoto: data['payload']['callerPhoto'] == null
//             ? ''
//             : data['payload']['callerPhoto'],
//         userInfo: {
//           "callerName": data['payload']['callerName'],
//           "photoPath": data['payload']['callerPhoto'] == null
//               ? 'https://i.imgur.com/KwrDil8b.jpg'
//               : data['payload']['callerPhoto'],
//           'channel_id': data['channel_id'].toString()
//         });
//
//     await ConnectycubeFlutterCallKit.showCallNotification(callEvent);
//     debugPrint('asxsdas');
//   }
  else {
    debugPrint('sdaxcv,s');
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

int applicationVersion = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);

  // onCallRejectedWhenTerminated
  //ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated = _onCallRejected;
  //ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated = _onCallAccepted;

  // ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    configureDependencies(),
    NotificationProcess().init(),
    NotificationProcess().setupInteractedMessage(),
  ]);
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
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
