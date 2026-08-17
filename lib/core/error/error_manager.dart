import 'package:flutter/foundation.dart' hide Category;

class ErrorManager {
  static final Map<String, int> _retryCounts = {};

  /// تحدد هل يجب إعادة المحاولة بناءً على كود الخطأ واسم الحدث
  static bool shouldRetry(String eventName, int statusCode) {
    int maxRetries = 1;
    if (kDebugMode)
      print(
        'statusCode:-----------------------------------------------------------9999---- $statusCode',
      );

    if (statusCode == 0 ||
        statusCode == 429 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504) {
      if (kDebugMode)
        print(
          'statusCode:--------------------------------------------------------------- $statusCode',
        );
      maxRetries = 2;
    }
    // 401 has no special allowance any more. `LoggerInterceptor` now refreshes
    // the token and replays the failed request itself, so a 401 only reaches an
    // event when that already failed — repeating it four times would just fire
    // four more refreshes. The single default retry is kept for the one case
    // that still benefits: a multipart upload, which the interceptor cannot
    // replay (its stream is consumed), but which succeeds when the event
    // rebuilds it with the token the refresh just stored.
    int currentCount = _retryCounts[eventName] ?? 0;
    bool canRetry = currentCount < maxRetries;

    return canRetry;
  }

  /// زيادة عداد المحاولات
  static void incrementRetry(String eventName) {
    _retryCounts[eventName] = (_retryCounts[eventName] ?? 0) + 1;
  }

  /// تصفير عداد المحاولات
  static void resetRetry(String eventName) {
    _retryCounts[eventName] = 0;
  }

  /// الحصول على عدد المحاولات الحالي
  static int getRetryCount(String eventName) {
    return _retryCounts[eventName] ?? 0;
  }

  /// تنظيف جميع العدادات
  static void clearAllRetries() {
    _retryCounts.clear();
  }
}
