import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:uuid/uuid.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;
import 'features/chat/presentation/manager/chat_event.dart';

showCallKitIncoming(Map<String, dynamic> data, String currentUuid,
    {required bool isVideo}) async {
  CallKitParams callKitParams = CallKitParams(
    id: currentUuid,
    nameCaller: data["message"]['channel']["channel_name"] ?? 'Un Known',
    appName: 'Trydos',
    avatar: data["message"]['channel']["photo_path"] ??
        'https://trydos.s3.ap-south-1.amazonaws.com/images/5TPxSXKGAv3kLkbKIz5noTTmaZBwXNtSpJMoh7lE.jpg',
    handle: data['payload']['mobilePhone'],
    type: isVideo ? 1 : 0,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    duration: 30000,
    extra: <String, dynamic>{
      'channel_id': data["message"]["channel_id"].toString(),
      'message_id': data["message"]["id"].toString()
    },
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl:
            'https://trydos.s3.ap-south-1.amazonaws.com/images/5TPxSXKGAv3kLkbKIz5noTTmaZBwXNtSpJMoh7lE.jpg',
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
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!isHydratedStorageInitialized) {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
    isHydratedStorageInitialized = true;
  }
  if (!isDependencyInitialized) {
    await configureDependencies();
    isDependencyInitialized = true;
  }
  try {
    if (message.data['type'] == 'VideoCallEvent' ||
        message.data['type'] == 'VoiceCallEvent') {
      String currentUuid = const Uuid().v4();
      Map<String, dynamic> data =
          convert.jsonDecode(message.data['data'].toString());
      showCallKitIncoming(data, currentUuid,
          isVideo: message.data['type'] == 'VideoCallEvent');
      FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
        switch (event!.event) {
          case Event.actionCallDecline:
            {
              HttpOverrides.global = MyHttpOverrides();
              GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                  messageId: data["message"]["id"].toString()));
            }
            break;
          case Event.actionCallTimeout:
            {
              HttpOverrides.global = MyHttpOverrides();
              GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                  messageId: data["message"]["id"].toString()));
            }
            break;
        }
      });
    } else if (message.data['type'] == 'RefuseCallEvent') {
      // if (message.data['data']['message_id'].toString() !=
      //     GetIt.I<CallsBloc>().state.currentActiveCallId) {
      //   return;
      // }
      FlutterCallkitIncoming.endAllCalls();
      GetIt.I<CallsBloc>().add(UserInteractWithCall(rejectIt: true));
    } else if (message.data['type'] == 'AnswerCallEvent') {
      FlutterCallkitIncoming.endAllCalls();
      GetIt.I<CallsBloc>().add(UserInteractWithCall(rejectIt: false));
    } else if (message.data['type'] == 'ChannelReceivedEvent') {
      Map<String, dynamic> data =
          convert.jsonDecode(message.data['data'].toString());
      GetIt.I<ChatBloc>().add(ReceiveMessageFromPusherEvent(
          data['channel_id'].toString(),
          data['auth_user_id'],
          data['last_message_id']));
    } else if (message.data['type'] == 'ChannelWatchedEvent') {
      Map<String, dynamic> data =
          convert.jsonDecode(message.data['data'].toString());
      GetIt.I<ChatBloc>().add(WatchedMessageFromPusherEvent(
          data['channel_id'].toString(),
          data['auth_user_id'],
          data['last_message_id']));
    } else {
      LocalNotificationService().showNotificationWithPayload(message: message);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

bool isDependencyInitialized = false;
bool isHydratedStorageInitialized = false;
Timer? timer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked = false;
Message? initialMessage;
//todo this list will store on it the api's that we try to load it and returned a failure for the first time so we check if it's not  in this list we try to reload it
List<String> isFailedTheFirstTime = [];
List<String> apisMustNotToRequest = [];
int applicationVersion = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  isHydratedStorageInitialized = true;
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    configureDependencies(),
    NotificationProcess().init(),
    NotificationProcess().setupInteractedMessage(),
  ]);
  if (GetIt.I<PrefsRepository>().chatToken != null) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
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
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://acdee1eeba745183d0772f009e22eb40@o4506524017688576.ingest.sentry.io/4506524024176640';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(DefaultAssetBundle(
      bundle: SentryAssetBundle(),
      child: TrydosApplication(
        navKey: navigatorKey,
      ),
    )),
  );
}
