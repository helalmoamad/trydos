import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:flutter_gemini/flutter_gemini.dart' as gemini;
import 'package:get_it/get_it.dart';
import 'package:eraser/eraser.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:uuid/uuid.dart';
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
    missedCallNotification: const NotificationParams(
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
    ios: const IOSParams(
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
  HttpOverrides.global = MyHttpOverrides();
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
    Map<String, dynamic> remoteMessage =
        convert.jsonDecode(message.data['data']);
    if (remoteMessage['type'] == 'VideoCallEvent' ||
        remoteMessage['type'] == 'VoiceCallEvent') {
      String currentUuid = const Uuid().v4();
      Map<String, dynamic> data = remoteMessage["message"];
      if (DateTime.now()
              .difference(HelperFunctions.getZonedDate(
                  DateTime.parse(data['created_at'])))
              .inMinutes >=
          1) {
        return;
      }
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: '${message.data['type']} background  ${data['message_id']}');
      GetIt.I<CallsBloc>()
          .add(UpdateCurrentActiveCallIdEvent(id: data["id"].toString()));
      FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
        switch (event!.event) {
          case Event.actionCallDecline:
            {
              HttpOverrides.global = MyHttpOverrides();
              if (!declineCallBecauseOfNotificationButton) {
                GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                    duration: 0,
                    payload: {'Target': 'Application  From terminated'},
                    messageId: data["id"].toString()));
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
          default:
            break;
        }
        declineCallBecauseOfNotificationButton = false;
      });
      showCallKitIncoming(data, currentUuid,
          isVideo: remoteMessage['type'] == 'VideoCallEvent');
    } else if (remoteMessage['type'] == 'RefuseCallEvent') {
      declineCallBecauseOfNotificationButton = true;
      Map<String, dynamic> data = remoteMessage;

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
    } else if (remoteMessage['type'] == 'AnswerCallEvent') {
      declineCallBecauseOfNotificationButton = true;
      Map<String, dynamic> data = remoteMessage;
      if (data['message_id'].toString() !=
              GetIt.I<CallsBloc>().state.currentActiveCallId &&
          GetIt.I<CallsBloc>().state.currentActiveCallId != '-1') {
        return;
      }
      FlutterCallkitIncoming.endAllCalls();
      GetIt.I<CallsBloc>().add(UserInteractWithCall(rejectIt: false));
    } else if (remoteMessage['type'] == 'ChannelReceivedEvent') {
      GetIt.I<PrefsRepository>()
          .setMessageReceivedStatusFromBackground(message.data['data']);
    } else if (remoteMessage['type'] == 'ChannelWatchedEvent') {
      GetIt.I<PrefsRepository>()
          .setMessageWatchStatusFromBackground(message.data['data']);
    } else if (remoteMessage['type'] == 'UpdatingMessageEvent') {
      GetIt.I<PrefsRepository>()
          .setRemovedMessageFromBackground(message.data['data']);
    } else if (remoteMessage['type'] == 'ChannelUpdatedEvent') {
      Map<String, dynamic> data = remoteMessage;
      GetIt.I<PrefsRepository>()
          .setMessageFromBackground(convert.jsonEncode(data['channel']));
    } else if (remoteMessage['type'] == 'ChannelDeletedEvent') {
      Map<String, dynamic> data = remoteMessage;
      GetIt.I<PrefsRepository>()
          .setRemovedChatFromBackground(data['channel_id'].toString());
    } else {
      print(remoteMessage);
      print(
          "*/*********************************************${remoteMessage['message']}");

      if (remoteMessage['message'] == null) return;
      Message myMessage = Message.fromJson(remoteMessage['message']);
      if (myMessage.senderUserId != GetIt.I<PrefsRepository>().myChatId) {
        GetIt.I<ChatBloc>().add(
            NotifyThatIReceivedMessageEvent(channelId: myMessage.channelId!));
      }
      GetIt.I<PrefsRepository>().setMessageFromBackground(
          convert.jsonEncode(remoteMessage['message']));
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
  //WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  http.get(Uri.parse('https://market_under_dev_backend.trydos.dev/api/new_v1/mobile/product/details_without_similar_related_products/5548'),headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization' : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYWVmNzllYzQwM2JiYTU2NzE5MmM5MWIyZjI5MTQzMGE2ZDUxNzIyNDdmMjQ4ZTg4MWNmMzI0MTNhMTBmMzY0OWI4YWEzMTQxNzhlOTMwZGIiLCJpYXQiOjE3Mjc5NTg2OTYuODc4ODUyLCJuYmYiOjE3Mjc5NTg2OTYuODc4ODU1LCJleHAiOjE3NTk0OTQ2OTYuODY5NjA3LCJzdWIiOiI2MTkyIiwic2NvcGVzIjpbXX0.l86EJEaVsTZdb2SoUosW3HtFD8jWn4eixnNrilupXetmmvGdNnZU2uDBH9hxdfiHMk-DWIxEPFG0ij5GUrsA6g86pUUm0dIvEcySjCqjXSek7tgEOo0J2wOXPsuevSUuUY8Gk9v7bCvTM24Pv3agtIiHKRNC0PB57PuHOFNWJ6x8ZJxpS7X6dtfzQVrQ-FpxwLxFSaA2gAwcBaUDVaiIJfcNf2uj_FDdDuypwQbKd2izGpS-XGrFyv4VLMa7vu-XpxWN2mM6hECeLSagPag2rF6tiIlN9hLcSmzBqX_Zk96caSMSz8q7eTj11cHiDpQwHZGcFzGoxO8VMZv1-DB7dVlvXy-Q5836nSd5vRCvrVfToDEZ1S4K3Xf-xK5BZfenPZVeWPXMI5YsxQHPUCLWNSMOKriIy_5VpPpzlPwb5NIxHaCFrPIppg9OWNRyuEkOSYcZuxQQxbZ7Asrn2RyExPKoNhzq5nFMapFPJqtsBclytrTHX3pblRl_JJprIs4wVNsuJUWSLKuV3Hely_YiG4lhhR5gEjcUpQZGe2n_Wcj1NPJYxYcv-Vurx4Ctba4mAbblU0NYcJWFoVTU1WC2mXuCnnJ2R_f6DCCUDloUYJ5rptOZawEhb_ip4T_qLZSY35d0Fcz1gde1jOAl2JleXkJhxHWoEt7ZK3bjjJdyrwA'
  }, ).then((value){
    dev.log('ffffffffff ${value.body}');
  });
  http.get(Uri.parse('https://market_under_dev_backend.trydos.dev/api/new_v1/mobile/product/likesCommentsSharesDetails/5548'),).then((value){
    dev.log('ffffffffff2  ${value.body}');
  });
  return;
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  isHydratedStorageInitialized = true;
  HttpOverrides.global = MyHttpOverrides();
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    dotenv.load(fileName: ".env"),
    configureDependencies(),
    NotificationProcess().init(),
  ]);

  Eraser.clearAllAppNotifications();
  GetIt.I<PrefsRepository>().removeMessageFromBackground();
  NotificationProcess().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await FirebaseAnalytics.instance
      .setSessionTimeoutDuration(Duration(seconds: 20));
  String sessionId = Uuid().v4();
  GetIt.I<PrefsRepository>().setSessionId(sessionId);
  GetIt.I<PrefsRepository>().setTimerForOtpRunning(false);
  fetchServersUrlsFromSharedPreference();
  NotificationProcess().fcmToken();
  isDependencyInitialized = true;
  GetIt.I<AuthBloc>().add(GetUserCountryEvent());

  gemini.Gemini.init(
    apiKey: "AIzaSyDP0q_EapML_zg4ibE_p1NbWNlUa2DjefI",
  );
  gemini.Gemini.enableDebugging = true;
  print(GetIt.I<PrefsRepository>().marketToken);
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DNS'];
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: TrydosApplication(
          navKey: navigatorKey,
        ))),
  );
}

fetchServersUrlsFromSharedPreference() async {
  if (GetIt.I<PrefsRepository>().getMarketUrl != null) {
    MarketUrls.setBaseUrl = GetIt.I<PrefsRepository>().getMarketUrl!;
  }
  if (GetIt.I<PrefsRepository>().getChatUrl != null) {
    ChatUrls.setBaseUrl = GetIt.I<PrefsRepository>().getChatUrl!;
  }
  if (GetIt.I<PrefsRepository>().getStoryUrl != null) {
    StoriesUrls.setBaseUrl = GetIt.I<PrefsRepository>().getStoryUrl!;
  }
}
