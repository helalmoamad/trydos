import 'dart:async';
import 'dart:developer';
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
import 'package:eraser/eraser.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:trydos/trydos_application.dart';
import 'package:uuid/uuid.dart';
import 'common/helper/helper_functions.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;
import 'features/chat/data/models/my_chats_response_model.dart';
import 'features/chat/presentation/manager/chat_event.dart';

@pragma('vm:entry-point')
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
    duration: 60000,
    extra: <String, dynamic>{
      'channel_id': data["message"]["channel_id"].toString(),
      'message_id': data["message"]["id"].toString(),
      'type': isVideo ? 'video' : 'voice'
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

bool declineCallBecauseOfNotificationButton = false;

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
      if (DateTime.now()
              .difference(HelperFunctions.getZonedDate(
                  DateTime.parse(data['message']['created_at'])))
              .inMinutes >=
          1) {
        return;
      }
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: '${message.data['type']} background  ${data['message_id']}');
      GetIt.I<CallsBloc>().add(
          UpdateCurrentActiveCallIdEvent(id: data["message"]["id"].toString()));
      FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
        switch (event!.event) {
          case Event.actionCallDecline:
            {
              HttpOverrides.global = MyHttpOverrides();
              if (!declineCallBecauseOfNotificationButton) {
                GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                    duration: 0,
                    payload: {'Target': 'Application  From terminated'},
                    messageId: data["message"]["id"].toString()));
              }
            }
            break;
          case Event.actionCallTimeout:
            {
              //  HttpOverrides.global = MyHttpOverrides();
              //  GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
              //  messageId: data["message"]["id"].toString()));
            }
            break;
        }
        declineCallBecauseOfNotificationButton = false;
      });
      showCallKitIncoming(data, currentUuid,
          isVideo: message.data['type'] == 'VideoCallEvent');
    } else if (message.data['type'] == 'RefuseCallEvent') {
      declineCallBecauseOfNotificationButton = true;
      Map<String, dynamic> data =
          convert.jsonDecode(message.data['data'].toString());

      if (data['duration_in_seconds']!.toString().contains("-1")) {
        GetIt.I<CallsBloc>().add(IcreaseMissedCallEvent());
      }
      if (data['message_id'].toString() !=
              GetIt.I<CallsBloc>().state.currentActiveCallId &&
          GetIt.I<CallsBloc>().state.currentActiveCallId != '-1') {
        return;
      }
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: 'RefuseCall for message backGround ${data['message_id']}');
      FlutterCallkitIncoming.endAllCalls();
      GetIt.I<CallsBloc>().add(UserInteractWithCall(rejectIt: true));
    } else if (message.data['type'] == 'AnswerCallEvent') {
      declineCallBecauseOfNotificationButton = true;
      Map<String, dynamic> data =
          convert.jsonDecode(message.data['data'].toString());
      if (data['message_id'].toString() !=
              GetIt.I<CallsBloc>().state.currentActiveCallId &&
          GetIt.I<CallsBloc>().state.currentActiveCallId != '-1') {
        return;
      }
      FlutterCallkitIncoming.endAllCalls();
      GetIt.I<CallsBloc>().add(UserInteractWithCall(rejectIt: false));
    } else if (message.data['type'] == 'ChannelReceivedEvent') {
      GetIt.I<PrefsRepository>()
          .setMessageReceivedStatusFromBackground(message.data['data']);
    } else if (message.data['type'] == 'ChannelWatchedEvent') {
      GetIt.I<PrefsRepository>()
          .setMessageWatchStatusFromBackground(message.data['data']);
    } else if (message.data['type'] == 'UpdatingMessageEvent') {
      GetIt.I<PrefsRepository>()
          .setRemovedMessageFromBackground(message.data['data']);
    } else if (message.data['type'] == 'ChannelUpdatedEvent') {
      Map<String, dynamic> data =
          convert.jsonDecode(message.data["data"].toString());
      GetIt.I<PrefsRepository>()
          .setMessageFromBackground(convert.jsonEncode(data['channel']));
    } else if (message.data['type'] == 'ChannelDeletedEvent') {
      Map<String, dynamic> data =
          convert.jsonDecode(message.data["data"].toString());
      GetIt.I<PrefsRepository>()
          .setRemovedChatFromBackground(data['channel_id']);
    } else {
      if (message.data['message'] == null) return;

      Message myMessage =
          Message.fromJson(convert.jsonDecode(message.data['message']));
      if (myMessage.senderUserId != GetIt.I<PrefsRepository>().myChatId) {
        GetIt.I<ChatBloc>().add(
            NotifyThatIReceivedMessageEvent(channelId: myMessage.channelId!));
      }
      GetIt.I<PrefsRepository>()
          .setMessageFromBackground(message.data['message']);
      if (myMessage.channel!.channelMembers!
                  .firstWhere((element) =>
                      element.userId == GetIt.I<PrefsRepository>().myChatId)
                  .mute !=
              1 &&
          myMessage.senderUserId != GetIt.I<PrefsRepository>().myChatId) {
        LocalNotificationService()
            .showNotificationWithPayload(message: message);
      }
    }
  } catch (e, st) {
    debugPrint(e.toString());
    debugPrint(st.toString());
  }
}

bool isDependencyInitialized = false;
bool isHydratedStorageInitialized = false;
Timer? timer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked = false;
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
  ]);
  Eraser.clearAllAppNotifications();
  GetIt.I<PrefsRepository>().removeMessageFromBackground();
  NotificationProcess().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  NotificationProcess().fcmToken();
  isDependencyInitialized = true;
  HttpOverrides.global = MyHttpOverrides();
  GetIt.I<AuthBloc>().add(GetUserCountryEvent());
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://1bd595d485776b0358f210ec75b3cfdf@o4506909037101056.ingest.us.sentry.io/4506909079896064';
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
