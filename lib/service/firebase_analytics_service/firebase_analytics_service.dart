import 'dart:io';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:trydos/service/language_service.dart';
import '../../core/domin/repositories/prefs_repository.dart';

class FirebaseAnalyticsService {
  ////////////////////////////////////////
  // static Future<void> logScreen({
  //   required String screen,
  //   Map<String, String>? extraParams,
  // }) async {
  //   try {
  //     await FirebaseAnalytics.instance.logScreenView(
  //       screenName: screen,
  //       parameters: {
  //         'our_user_id': GetIt.I<PrefsRepository>().myMarketId ?? 'empty',
  //         'our_session_id': GetIt.I<PrefsRepository>().sessionId.toString(),
  //         'time_stamp': DateTime.now()
  //             .toUtc()
  //             .add(
  //                 Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0))
  //             .toString(),
  //         'device_language': LanguageService.languageCode == 'ar'
  //             ? 'ae'
  //             : LanguageService.languageCode,
  //         'country_name': GetIt.I<PrefsRepository>().countryIso.toString(),
  //         if (extraParams != null) ...extraParams,
  //       },
  //     );
  //   } catch (e, st) {
  //     debugPrint(
  //         '////logScreen Error ////////// ${e.toString()} //////////////////');
  //     debugPrint(st.toString());
  //   }
  // }

  static Future<void> logEventForSession({
    required String eventName,
    Map<String, String>? extraParams,
    bool isForApi = false,
    required String executedEventName,
  }) async {
    final sessionId = Random().nextInt(1000000).toString();

    try {
      final prefs = GetIt.I<PrefsRepository>();

      final baseProperties = <String, dynamic>{
        'event_id': Random().nextInt(1000000).toString(),
        'timestamp_now': DateTime.now()
            .toUtc()
            .add(Duration(minutes: prefs.getdurtion ?? 0))
            .toString(),
        "user_id_guest": (prefs.isVerifiedPhone ?? false)
            ? null
            : prefs.myMarketId.toString(),
        "user_id_verified": !(prefs.isVerifiedPhone ?? false)
            ? null
            : prefs.myMarketId.toString(),
        'device_language': LanguageService.isKurdish
            ? 'ku'
            : LanguageService.languageCode,
        "operating_system": Platform.isIOS ? "ios" : "Android",
        "platform_source": "mobile",
        'session_id': sessionId,
        "interaction_type": eventName,
        'country_name':
            ((prefs.userCountryIsAvailable == 1
                ? prefs.userChoosedCountryIso
                : prefs.countryIso) ??
            ""),
      };

      // merge extra params
      if (extraParams != null) {
        baseProperties.addAll(extraParams);
      }

      baseProperties.removeWhere((key, value) => value == null);

      /// 🔵 POSTHOG (full event like Firebase)
      await sendToPosthog(eventName: eventName, baseParams: baseProperties);

      /// 🟢 FIREBASE
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: baseProperties,
      );
    } catch (e, st) {
      debugPrint('//// log Event Error //// ${e.toString()}');
      debugPrint(st.toString());
    }
  }

  static Future<void> sendToPosthog({
    required String eventName,
    required Map<String, dynamic> baseParams,
  }) async {
    try {
      final Map<String, Object> properties = baseParams.map(
        (key, value) => MapEntry(key, value as Object),
      );

      await Posthog().capture(eventName: eventName, properties: properties);
    } catch (e, st) {
      debugPrint('PostHog Error: $e');
      debugPrint(st.toString());
    }
  }

  // static Future<void> startAnalyticsSession() async {
  //   String sessionId = Uuid().v4();
  //   await GetIt.I<PrefsRepository>().setSessionId(sessionId);
  //   /////////////////////////
  //   try {
  //     await FirebaseAnalytics.instance.logEvent(
  //       name: AnalyticsEventsConst.startSession,
  //       parameters: {
  //         'our_session_id': GetIt.I<PrefsRepository>().sessionId.toString(),
  //         'session_startAt': DateTime.now()
  //             .toUtc()
  //             .add(
  //                 Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0))
  //             .toString(),
  //       },
  //     );

  //     await GetIt.I<PrefsRepository>().removeCurrentEvent();
  //     await GetIt.I<PrefsRepository>().removeViewedProducts();
  //     await GetIt.I<PrefsRepository>().removeViewedBoutiques();
  //   } catch (e, st) {
  //     debugPrint(
  //         '//// startAnalyticsSession Error ////////// ${e.toString()} //////////////////');
  //     debugPrint(st.toString());
  //   }
  // }
}
