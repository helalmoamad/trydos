import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

class FirebaseAnalyticsService {
  ////////////////////////////////////////
  static Future<void> logScreen({required String screen}) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: screen);
  }

  static Future<void> logEventForSession({
    required String eventName,
    required String userID,
    required String user_name,
    required String clickedButtonName,
    Map<String, String>? extraParams,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {
          'user_id': userID,
          'user_name': user_name,
          'clicked_button_name': clickedButtonName,
          if (extraParams != null) ...extraParams,
        },
      );
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
    }
  }

  static Future<void> logEventForViewedProducts({
    required String eventName,
    required String productId,
    required String productName,
    required List<String>? productCategoriesId,
    Map<String, String>? extraParams,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {
          'product_id': productId,
          'product_name': productName,
          'product_category': json.encode(productCategoriesId),
          if (extraParams != null) ...extraParams,
        },
      );
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
    }
  }
}
