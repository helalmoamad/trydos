import 'dart:async';
import 'dart:io';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:dio/dio.dart';

import 'package:flutter/services.dart';
import 'dart:developer' as dev;
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
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
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
import 'package:video_player/video_player.dart';
import 'common/helper/helper_functions.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;
import 'features/chat/data/models/my_chats_response_model.dart';
import 'features/chat/presentation/manager/chat_event.dart';

@pragma('vm:entry-point')
showCallKitIncoming(
  Map<String, dynamic> data,
  String currentUuid, {
  required bool isVideo,
  required bool isPrivate,
}) async {
  CallKitParams callKitParams = CallKitParams(
    id: currentUuid,
    nameCaller: data["message"]['channel']["channel_name"] ?? 'Un Known',
    appName: 'Trydos',
    avatar:
        data["message"]['channel']["photo_path"] ??
        'https://trydos.s3.ap-south-1.amazonaws.com/images/5TPxSXKGAv3kLkbKIz5noTTmaZBwXNtSpJMoh7lE.jpg',
    handle: data['payload']['mobilePhone'],
    type: isVideo ? 1 : 0,
    textAccept: isVideo ? 'Accept Video' : 'Accept Call',
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
      'type': isVideo ? 'video' : 'voice',
      'is_private': isPrivate,
    },
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: AndroidParams(
      isCustomNotification: true,
      isImportant: true,
      isShowFullLockedScreen: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: isVideo ? '#2D1B4B' : '#0955fa',
      backgroundUrl:
          'https://trydos.s3.ap-south-1.amazonaws.com/images/5TPxSXKGAv3kLkbKIz5noTTmaZBwXNtSpJMoh7lE.jpg',
      actionColor: isVideo ? '#FF1744' : '#4CAF50',
      incomingCallNotificationChannelName: "Incoming Call",
      missedCallNotificationChannelName: "Missed Call",

      // ✅ إضافة خاصية الصوت القوي والاهتزاز
    ),
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
  if (!isHydratedStorageInitialized) {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
    isHydratedStorageInitialized = true;
  }

  if (!isLoadDotenvFile) {
    await dotenv.load();
    isLoadDotenvFile = true;
  }

  HttpOverrides.global = MyHttpOverrides();

  if (!isDependencyInitialized) {
    await configureDependencies();
    isDependencyInitialized = true;
  }
  try {
    if (HandlingMarketNotifications.checkIfTheNotificationIsNotRelatedToChat(
      message,
    )) {
      LocalNotificationService().showNotificationWithPayload(
        message: message,
        fromBackGround: 1,
      );
      return;
    }
    Map<String, dynamic> remoteMessage = convert.jsonDecode(
      message.data['data'],
    );
    if (remoteMessage['type'] == 'VideoCallEvent' ||
        remoteMessage['type'] == 'VoiceCallEvent') {
      String currentUuid = const Uuid().v4();
      Map<String, dynamic> data = remoteMessage["message"];
      print("FFFFFFFFFFFFFFFDDDDDDDDDDDDDDDDDDDDDDD${data}");
      if (DateTime.now()
              .difference(
                HelperFunctions.getZonedDate(
                  DateTime.parse(data['created_at']),
                ),
              )
              .inMinutes >=
          1) {
        return;
      }
      print("FFFFFFFFFFFFFFFDDDDDDDDDDDDDDDDDDDDDD//////////D${data}");
      GetIt.I<PrefsRepository>().saveRequestsData(
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        error: '${message.data['type']} background  ${data['message_id']}',
      );

      GetIt.I<CallsBloc>().add(
        UpdateCurrentActiveCallIdEvent(id: data["id"].toString()),
      );

      FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
        print("CALLKIT EVENT: ${event?.event.toString()}");
        print("CALLKIT BODY: ${event?.body.toString()}");

        switch (event!.event) {
          case Event.actionCallAccept:
            {
              // ✅ معالج قبول المكالمة - فتح التطبيق والانتقال لشاشة المكالمة
              print(
                "FFFFFFFFFFFFFFFDDDDDDDDDDDDDDDDDDDDDD///*/*** actionCallAccept triggered",
              );
              try {
                print("Event body: ${event.body}");
                print("Event body type: ${event.body.runtimeType}");
                print("Extra data: ${event.body['extra']}");
                print("Extra type: ${event.body['extra'].runtimeType}");

                // ✅ الحصول على بيانات المكالمة من extra - تحويل صحيح للنوع
                final extraData = event.body['extra'];

                if (extraData != null) {
                  // تحويل من Map<Object?, Object?> إلى Map<String, dynamic>
                  final callData = Map<String, dynamic>.from(extraData as Map);
                  print("Call data from extra: $callData");

                  final channelId = callData['channel_id']?.toString() ?? '';
                  final messageId = callData['message_id']?.toString() ?? '';
                  final type = callData['type']?.toString() ?? 'voice';

                  print(
                    "Extracted: channel=$channelId, message=$messageId, type=$type",
                  );

                  // تحديث ID المكالمة النشطة
                  GetIt.I<CallsBloc>().add(
                    UpdateCurrentActiveCallIdEvent(id: messageId),
                  );

                  print(
                    "✅ Call accepted successfully - waiting for app to open",
                  );
                } else {
                  print(
                    "❌ extraData is null - cannot extract call information",
                  );
                }
              } catch (e, stackTrace) {
                print("❌ Error in actionCallAccept: $e");
                print("Stack trace: $stackTrace");
              }
            }
            break;
          case Event.actionCallDecline:
            {
              HttpOverrides.global = MyHttpOverrides();
              if (!declineCallBecauseOfNotificationButton) {
                GetIt.I<CallsBloc>().add(
                  RejectVideoCallEvent(
                    duration: 0,
                    payload: {'Target': 'Application  From terminated'},
                    messageId: data["id"].toString(),
                  ),
                );
              }
            }
            break;
          case Event.actionCallTimeout:
            {
              HttpOverrides.global = MyHttpOverrides();
              if (!declineCallBecauseOfNotificationButton) {
                GetIt.I<CallsBloc>().add(
                  RejectVideoCallEvent(
                    duration: 0,
                    payload: {'Target': 'Application  From terminated'},
                    messageId: data["id"].toString(),
                  ),
                );
              }
            }
            break;
          default:
            break;
        }
        declineCallBecauseOfNotificationButton = false;
      });
      showCallKitIncoming(
        remoteMessage,
        currentUuid,
        isVideo: remoteMessage['type'] == 'VideoCallEvent',
        isPrivate: remoteMessage['is_private'] ?? false,
      );
    } else if (remoteMessage['type'] == 'RefuseCallEvent') {
      declineCallBecauseOfNotificationButton = true;
      Map<String, dynamic> data = remoteMessage;
      if (data['duration_in_seconds'] == null) {
        GetIt.I<CallsBloc>().add(IcreaseMissedCallEvent());
      } else if (data['duration_in_seconds']!.toString().contains("-1")) {
        GetIt.I<CallsBloc>().add(IcreaseMissedCallEvent());
      }

      if (data['message_id'].toString() !=
              GetIt.I<CallsBloc>().state.currentActiveCallId &&
          GetIt.I<CallsBloc>().state.currentActiveCallId != '-1') {
        return;
      }
      GetIt.I<PrefsRepository>().saveRequestsData(
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        error: 'RefuseCall for message backGround ${data['message_id']}',
      );
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
      GetIt.I<PrefsRepository>().setMessageReceivedStatusFromBackground(
        message.data['data'],
      );
    } else if (remoteMessage['type'] == 'ChannelWatchedEvent') {
      GetIt.I<PrefsRepository>().setMessageWatchStatusFromBackground(
        message.data['data'],
      );
    } else if (remoteMessage['type'] == 'UpdatingMessageEvent') {
      GetIt.I<PrefsRepository>().setRemovedMessageFromBackground(
        message.data['data'],
      );
    } else if (remoteMessage['type'] == 'ChannelUpdatedEvent') {
      Map<String, dynamic> data = remoteMessage;
      GetIt.I<PrefsRepository>().setMessageFromBackground(
        convert.jsonEncode(data['channel']),
      );
    } else if (remoteMessage['type'] == 'ChannelDeletedEvent') {
      Map<String, dynamic> data = remoteMessage;
      GetIt.I<PrefsRepository>().setRemovedChatFromBackground(
        data['channel_id'].toString(),
      );
    } else {
      if (remoteMessage['message'] == null) return;
      Message myMessage = Message.fromJson(remoteMessage['message']);
      if (myMessage.senderUserId != GetIt.I<PrefsRepository>().myChatId) {
        GetIt.I<ChatBloc>().add(
          NotifyThatIReceivedMessageEvent(channelId: myMessage.channelId!),
        );
      }
      print(
        "DDDDDDDDDDDDDDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFQQQQQQQQQQQQQQQQQQQQQQQQ//////////////////////******",
      );
      GetIt.I<PrefsRepository>().setMessageFromBackground(
        convert.jsonEncode(remoteMessage['message']),
      );
      if (myMessage.channel!.channelMembers!
                  .firstWhere(
                    (element) =>
                        element.userId == GetIt.I<PrefsRepository>().myChatId,
                  )
                  .mute !=
              1 &&
          myMessage.senderUserId != GetIt.I<PrefsRepository>().myChatId) {
        LocalNotificationService().showNotificationWithPayload(
          message: message,
          fromBackGround: 1,
        );
      }
    }
  } catch (e, st) {
    debugPrint(e.toString());
    debugPrint(st.toString());
  }
}

bool isHydratedStorageInitialized = false;
// 🖼️ صور أثناء السكرول - تقليل للسلاسة
//final Semaphore imageBanner = Semaphore(1); // تقليل لمنع تأثير السكرول
//final Semaphore imageCategoryBoutiques = Semaphore(1); // تقليل من 2 → 1
//final Semaphore syncColorImages = Semaphore(1); // تقليل من 5 → 3
//final Semaphore productListingImages = Semaphore(1); // تقليل من 3 → 2
//final Semaphore categoryListingImages = Semaphore(1); // ممتاز
//final Semaphore brandListingImages = Semaphore(1); // ممتاز
//final Semaphore productDetailsImages = Semaphore(1); // ممتاز

// 📡 طلبات البيانات - زيادة للسرعة
//final Semaphore prefechMainCategory = Semaphore(5); // زيادة من 1 → 3
//final Semaphore prefechBoutiques = Semaphore(8); // ممتاز - كما فعلت
//final Semaphore prefechFiveFilter = Semaphore(3); // زيادة من 1 → 3
bool isLoadDotenvFile = false;
bool isDependencyInitialized = false;
Timer? timer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationClicked = false;
//todo this list will store on it the api's that we try to load it and returned a failure for the first time so we check if it's not  in this list we try to reload it
List<String> isFailedTheFirstTime = [];
List<String> apisMustNotToRequest = [];
List<String> productIdToSaveRedeemTimer = [];
//List<String> productSlugToSaveVideoTimer = [];
Map<String, VideoPlayerController> videoProductInListingController = {};
/*void clearvideoProductInListingController({required String productSlug}) {
  /* if (productSlug != "") {
    videoProductInListingController[productSlug]?.dispose();
    videoProductInListingController.remove(productSlug);
  } else {
    videoProductInListingController.forEach((key, value) => value.dispose());
    videoProductInListingController = {};
  }*/
}*/

int applicationVersion = 120;
request() async {
  final Stopwatch stopWatch = Stopwatch();
  stopWatch.start();
  //await http.get(Uri.parse('http://market_under_dev_backend.trydos.dev/api/new_v1/mobile/home/mainCategories'));

  await Dio().getUri(Uri.parse('http://ip-api.com/json')).onError((e, st) {
    dev.log(e.toString());
    return Response(requestOptions: RequestOptions());
  });

  stopWatch.stop();
  dev.log('request time: ${stopWatch.elapsed.toString()}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ⚡ إعدادات محسنة لمنع التعليق عند أول فتح للتطبيق
  //_configureFirstLaunchOptimizations();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  isHydratedStorageInitialized = true;

  // 🎯 إعدادات بسيطة فقط - دع Flutter يدير الذاكرة!
  // _applySimpleScrollOptimizations();

  // debugPrint('✅ إزالة كل التدخلات الضارة - اعتماد كامل على Flutter');
  //debugPrint('🎯 إعدادات بسيطة: 50MB image cache، بدون مراقبة أو تنظيف قسري');

  HttpOverrides.global = MyHttpOverrides();
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    dotenv.load(),
    configureDependencies(),
  ]);

  await NotificationProcess().init();
  //GetIt.I<PreCachingImageBloc>().add(RemoveUrlThatNotUsedEvent());
  isLoadDotenvFile = true;

  await GetIt.I<PrefsRepository>().setOnMessageRun(false);

  GetIt.I<PrefsRepository>().removeMainCategoryHasPerfechedWhenOpenApp(false);

  //GetIt.I<PrefsRepository>().removeBoutiqueHasPerfechedWhenOpenApp(false);
  //GetIt.I<PrefsRepository>().removeFiveFilterHasPerfechedWhenOpenApp();
  //await Eraser.clearAllAppNotifications();
  // عدم مسح الرسائل عند فتح التطبيق من إشعار دردشة (terminated) حتى يقرأها base_page
  final launchDetails = await LocalNotificationService.localNotificationPlugin
      .getNotificationAppLaunchDetails();
  final isChatNotificationLaunch =
      launchDetails?.notificationResponse?.payload?.contains(
        '#prevMessageId#',
      ) ??
      false;
  if (!isChatNotificationLaunch) {
    await GetIt.I<PrefsRepository>().removeMessageFromBackground();
  }

  await NotificationProcess().setupInteractedMessage();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FirebaseAnalytics.instance.setSessionTimeoutDuration(
    const Duration(seconds: 20),
  );
  GetIt.I<PrefsRepository>().addFcmToken("");
  GetIt.I<PrefsRepository>().setTimerForOtpRunning(false);
  fetchServersUrlsFromSharedPreference();
  //* GetIt.I<PrefsRepository>().removeRedeemDateForAnyProductFinished();

  isDependencyInitialized = true;
  GetIt.I<AuthBloc>().add(GetUserCountryEvent());
  NotificationProcess().fcmToken(null, null, null, null);
  gemini.Gemini.init(apiKey: dotenv.env['Gemini']!);
  gemini.Gemini.enableDebugging = true;
  print('market token : ${(GetIt.I<PrefsRepository>().marketToken)}');
  debugPrint(
    'login _prefsRepository.chatToken${GetIt.I<PrefsRepository>().chatToken}',
  );
  debugPrint(
    'login _prefsRepository.marketToken${GetIt.I<PrefsRepository>().marketToken}',
  );
  debugPrint(
    'login _prefsRepository.storiesToken${GetIt.I<PrefsRepository>().storiesToken}',
  );
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DNS'];
      options.tracesSampleRate = 0.1;
      options.beforeBreadcrumb = (bread, hint) {
        if (bread?.category == "ui.scroll") {
          return null;
        }
        return bread;
      };
    },
    appRunner: () => runApp(
      DevicePreview(
        enabled: false, // !kReleaseMode,
        builder: (context) => DefaultAssetBundle(
          bundle: SentryAssetBundle(),
          child: TrydosApplication(navKey: navigatorKey),
        ),
      ),
    ),
  );
}

/// ⚡ إعدادات محسنة لمنع التعليق عند أول فتح للتطبيق
/*void _configureFirstLaunchOptimizations() {
  // تقليل حد الكاش للصور أثناء الفتحة الأولى
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      50 * 1024 * 1024; // 50MB بدلاً من 150MB
}

/// 🎯 تحسينات بسيطة ومضمونة للتمرير (بدلاً من المدراء المعقدين)
void _applySimpleScrollOptimizations() {
  try {
    // 📊 إعدادات كاش الصور الأساسية
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        50 * 1024 * 1024; // 50MB
    PaintingBinding.instance.imageCache.maximumSize = 200; // عدد الصور

    debugPrint('🎯 تم تطبيق التحسينات البسيطة للتمرير');
    debugPrint('📊 كاش الصور: 50MB، عدد الصور: 200');
    debugPrint('⚡ إزالة المدراء المعقدين لتحسين الأداء');
  } catch (e) {
    debugPrint('⚠️ خطأ في التحسينات البسيطة: $e');
  }
}*/

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
