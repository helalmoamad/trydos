import 'package:flutter/foundation.dart';

/// Writes a message to the log **only in debug builds**.
///
/// `print()` keeps working in a release build, so anything printed there ends
/// up in the device log, where other tools and crash reporters can read it.
/// Debug messages in this app go through this function instead, so a release
/// build stays quiet.
///
/// Never pass a secret value (token, password, OTP) to this function. Log a
/// boolean or an id instead — the semgrep rule `trydos-sec-logs-sensitive-value`
/// checks for that.
///
/// [error] and [stackTrace] are optional, for use inside a `catch` block:
///
/// ```dart
/// try {
///   await something();
/// } catch (e, s) {
///   devLog('loading the cart failed', e, s);
/// }
/// ```
void devLog(Object? message, [Object? error, StackTrace? stackTrace]) {
  if (!kDebugMode) return;
  // This is the one place in the app where print() is allowed: the guard above
  // makes it unreachable in a release build.
  // nosemgrep: trydos-sec-print-in-production-code
  print(error == null ? '$message' : '$message: $error');
  if (stackTrace != null) {
    // Same guard as above.
    // nosemgrep: trydos-sec-print-in-production-code
    print(stackTrace);
  }
}
