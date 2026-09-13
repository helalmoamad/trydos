import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/error/error_manager.dart';

/// Test ledger · wave 01 Core runtime · unit "Retry policy".
///
/// Decides how many times a failed event may be sent again. Too few and a
/// flaky network shows an error the user did not need to see; too many and one
/// dead endpoint turns into a storm of identical requests.
void main() {
  // The counters are static and outlive a single test.
  setUp(ErrorManager.clearAllRetries);
  tearDown(ErrorManager.clearAllRetries);

  test('the default budget is one retry', () {
    const String event = 'GetOrdersEvent';

    expect(ErrorManager.shouldRetry(event, 404), isTrue,
        reason: 'the first failure is allowed one more go');

    ErrorManager.incrementRetry(event);
    expect(ErrorManager.getRetryCount(event), 1);
    expect(ErrorManager.shouldRetry(event, 404), isFalse,
        reason: 'the single retry is spent');
  });

  test('a network-shaped failure raises the budget to two', () {
    // 0 is "no response at all", the rest are the gateway and rate-limit codes.
    // These are the failures worth trying again; a 404 is not.
    for (final int statusCode in <int>[0, 429, 502, 503, 504]) {
      final String event = 'Event$statusCode';

      expect(ErrorManager.shouldRetry(event, statusCode), isTrue);
      ErrorManager.incrementRetry(event);
      expect(ErrorManager.shouldRetry(event, statusCode), isTrue,
          reason: '$statusCode gets a second retry');
      ErrorManager.incrementRetry(event);
      expect(ErrorManager.shouldRetry(event, statusCode), isFalse,
          reason: '$statusCode stops after two');
    }
  });

  test('401 gets no extra budget', () {
    // Deliberate: the interceptor already refreshes the token and replays the
    // request, so a 401 that still reaches an event means that path failed.
    // Repeating it would only fire more refreshes.
    const String event = 'PlaceOrderEvent';

    expect(ErrorManager.shouldRetry(event, 401), isTrue);
    ErrorManager.incrementRetry(event);
    expect(ErrorManager.shouldRetry(event, 401), isFalse,
        reason: '401 must keep the default budget of one, not the network budget');
  });

  test('counters are kept per event name and never mix', () {
    const String first = 'GetCartItemEvent';
    const String second = 'GetOrdersEvent';

    ErrorManager.incrementRetry(first);
    expect(ErrorManager.getRetryCount(first), 1);
    expect(ErrorManager.getRetryCount(second), 0,
        reason: 'one exhausted event must not block a different one');
    expect(ErrorManager.shouldRetry(first, 404), isFalse);
    expect(ErrorManager.shouldRetry(second, 404), isTrue);

    ErrorManager.resetRetry(first);
    expect(ErrorManager.getRetryCount(first), 0);
    expect(ErrorManager.shouldRetry(first, 404), isTrue,
        reason: 'a reset gives the event its budget back');
  });
}
