import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/language_service.dart';
import 'package:uuid/uuid.dart';
import '../../core/domin/repositories/prefs_repository.dart';

class FirebaseAnalyticsService {
  ////////////////////////////////////////
  static Future<void> logScreen({
    required String screen,
    Map<String, String>? extraParams,
  }) async {
    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: screen,
        parameters: {
          'our_user_id': GetIt.I<PrefsRepository>().myMarketId ?? 'empty',
          'our_session_id': GetIt.I<PrefsRepository>().sessionId.toString(),
          'time_stamp': DateTime.now()
              .toUtc()
              .add(
                  Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0))
              .toString(),
          'device_language': LanguageService.languageCode == 'ar'
              ? 'ae'
              : LanguageService.languageCode,
          'country_name': GetIt.I<PrefsRepository>().countryIso.toString(),
          if (extraParams != null) ...extraParams,
        },
      );
    } catch (e, st) {
      debugPrint(
          '////logScreen Error ////////// ${e.toString()} //////////////////');
      debugPrint(st.toString());
    }
  }

  static Future<void> logEventForSession({
    required String eventName,
    required String executedEventName,
    Map<String, String>? extraParams,
    bool isForApi = false,
  }) async {
    try {
      /*  await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {
          'our_user_id': GetIt.I<PrefsRepository>().myMarketId ?? 'empty',
          'our_session_id': GetIt.I<PrefsRepository>().sessionId.toString(),
          'executed_event_name': isForApi ? 'null' : executedEventName,
          'time_stamp': DateTime.now()
              .toUtc()
              .add(
                  Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0))
              .toString(),
          'previous_event_name': isForApi
              ? 'null'
              : GetIt.I<PrefsRepository>().currentEvent.toString(),
          'device_language': LanguageService.languageCode == 'ar'
              ? 'ae'
              : LanguageService.languageCode,
          'country_name': GetIt.I<PrefsRepository>().countryIso.toString(),
          if (extraParams != null) ...extraParams,
        },
      ).then(
        (value) async {
          if (!isForApi) {
            await GetIt.I<PrefsRepository>().setCurrentEvent(executedEventName);
          
        },
      );*/
      ///////////////////////
    } catch (e, st) {
      debugPrint(
          '////log Event For Session Error ////////// ${e.toString()} //////////////////');
      debugPrint(st.toString());
    }
  }

  static Future<void> startAnalyticsSession() async {
    String sessionId = Uuid().v4();
    await GetIt.I<PrefsRepository>().setSessionId(sessionId);
    /////////////////////////
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: AnalyticsEventsConst.startSession,
        parameters: {
          'our_session_id': GetIt.I<PrefsRepository>().sessionId.toString(),
          'session_startAt': DateTime.now()
              .toUtc()
              .add(
                  Duration(minutes: GetIt.I<PrefsRepository>().getdurtion ?? 0))
              .toString(),
        },
      );

      await GetIt.I<PrefsRepository>().removeCurrentEvent();
      await GetIt.I<PrefsRepository>().removeViewedProducts();
      await GetIt.I<PrefsRepository>().removeViewedBoutiques();
    } catch (e, st) {
      debugPrint(
          '//// startAnalyticsSession Error ////////// ${e.toString()} //////////////////');
      debugPrint(st.toString());
    }
  }

  static Future<void> logEventForViewedProduct({
    required String eventName,
    required String productId,
    required String productName,
    required List<String>? productCategoriesId,
    Map<String, String>? extraParams,
  }) async {
    List<String> viewedProducts =
        GetIt.I<PrefsRepository>().getviewedProductsProducts();
    if (!viewedProducts.contains(productId)) {
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: eventName,
          parameters: {
            'our_user_id': GetIt.I<PrefsRepository>().myMarketId ?? 'empty',
            'product_id': productId,
            'product_name': productName,
            'product_category': json.encode(productCategoriesId),
            if (extraParams != null) ...extraParams,
          },
        ).then(
          (value) async {
            await GetIt.I<PrefsRepository>().setViewedProducts(productId);
          },
        );
      } catch (e, st) {
        debugPrint(
            '//// logEventForViewedProducts Error ////////// ${e.toString()} //////////////////');
        debugPrint(st.toString());
      }
    }
  }

  static Future<void> logEventForViewedBoutique({
    required String eventName,
    required String boutiqueId,
    required String boutiqueName,
    Map<String, String>? extraParams,
  }) async {
    List<String> viewedBoutiques =
        GetIt.I<PrefsRepository>().getviewedProductsBoutiques();

    if (!viewedBoutiques.contains(boutiqueId)) {
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: eventName,
          parameters: {
            'our_user_id': GetIt.I<PrefsRepository>().myMarketId ?? 'empty',
            'boutique_id': boutiqueId,
            'boutique_name': boutiqueName,
            if (extraParams != null) ...extraParams,
          },
        ).then(
          (value) async {
            await GetIt.I<PrefsRepository>().setViewedBoutiques(boutiqueId);
          },
        );
      } catch (e, st) {
        debugPrint(
            '//// log Event For Viewed Boutiques Error ////////// ${e.toString()} //////////////////');
        debugPrint(st.toString());
      }
    }
  }
}
