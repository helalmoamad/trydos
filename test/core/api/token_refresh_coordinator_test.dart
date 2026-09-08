import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';

/// Test ledger · wave 01 Core runtime · unit "Refresh coordinator".
///
/// Ten requests can fail with 401 in the same moment. Every one of them asks for
/// a refresh, exactly one refresh must actually run, and all ten must be
/// released together once it answers. If that collapsing breaks, the app fires
/// one refresh per in-flight request; if the release breaks, a request hangs
/// until the user gives up. These six tests pin both sides down.
void main() {
  final TokenRefreshCoordinator coordinator = TokenRefreshCoordinator.instance;

  // The coordinator is a process-wide singleton and exposes no reset hook, so a
  // test that walked away from a waiting scope would hand that state to the next
  // test. Drain every scope and let the internal cleanup run.
  tearDown(() async {
    for (final RefreshScope scope in RefreshScope.values) {
      coordinator.complete(scope, false);
    }
    await pumpEventQueue();
  });

  test('refresh calls start once and returns a future that is still pending',
      () async {
    int startCalls = 0;
    final Future<bool> pending =
        coordinator.refresh(RefreshScope.market, () => startCalls++);

    expect(startCalls, 1, reason: 'the refresh is dispatched straight away');

    bool settled = false;
    unawaited(pending.then((_) => settled = true));
    await pumpEventQueue();
    expect(settled, isFalse,
        reason: 'nothing has reported an outcome yet, so the caller waits');

    coordinator.complete(RefreshScope.market, true);
    expect(await pending, isTrue);
  });

  test('a second caller for the same scope joins the running refresh', () async {
    int startCalls = 0;
    void start() => startCalls++;

    final Future<bool> first = coordinator.refresh(RefreshScope.chat, start);
    final Future<bool> second = coordinator.refresh(RefreshScope.chat, start);

    expect(startCalls, 1, reason: 'the second caller must not start a refresh');
    expect(identical(first, second), isTrue,
        reason: 'both callers wait on the very same future');

    coordinator.complete(RefreshScope.chat, true);
    expect(await first, isTrue);
    expect(await second, isTrue);
  });

  test('complete(true) resolves every caller waiting on that scope', () async {
    int startCalls = 0;
    final List<Future<bool>> callers = <Future<bool>>[
      for (int i = 0; i < 10; i++)
        coordinator.refresh(RefreshScope.market, () => startCalls++),
    ];

    expect(startCalls, 1, reason: 'ten parallel 401s share one refresh');

    coordinator.complete(RefreshScope.market, true);
    expect(await Future.wait(callers), everyElement(isTrue),
        reason: 'all ten requests are released to retry');
  });

  test('a refresh nobody answers gives up after 20 seconds and resolves false',
      () {
    // The bloc throttles its refresh events, so a dispatched event can be
    // dropped and never answered. Move the clock instead of waiting for it.
    fakeAsync((FakeAsync async) {
      bool? outcome;
      coordinator
          .refresh(RefreshScope.stories, () {})
          .then((bool value) => outcome = value);

      async.elapse(const Duration(seconds: 19));
      async.flushMicrotasks();
      expect(outcome, isNull, reason: 'still inside the 20 second budget');

      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(outcome, isFalse,
          reason: 'a dropped refresh must not hang the request forever');
    });
  });

  test('a start callback that throws resolves false instead of hanging', () {
    // `AuthBloc` can already be closed when the network layer asks for a
    // refresh; `add` then throws and nothing would ever report an outcome.
    //
    // Held inside `fakeAsync` with the clock deliberately never moved: waiting
    // out the 20 second timeout would also end in `false`, so only an answer
    // that arrives with zero elapsed time proves the throw was handled here.
    fakeAsync((FakeAsync async) {
      bool? outcome;
      coordinator
          .refresh(
            RefreshScope.comment,
            () => throw StateError('Cannot add new events after calling close'),
          )
          .then((bool value) => outcome = value);

      async.flushMicrotasks();
      expect(outcome, isFalse,
          reason: 'handled at once, without falling through to the timeout');
    });
  });

  test('completing one scope leaves the other scopes waiting', () async {
    bool marketSettled = false;
    bool chatSettled = false;

    final Future<bool> market =
        coordinator.refresh(RefreshScope.market, () {});
    final Future<bool> chat = coordinator.refresh(RefreshScope.chat, () {});
    unawaited(market.then((_) => marketSettled = true));
    unawaited(chat.then((_) => chatSettled = true));

    coordinator.complete(RefreshScope.chat, true);
    await pumpEventQueue();

    expect(chatSettled, isTrue);
    expect(marketSettled, isFalse,
        reason: 'a chat refresh must not release a market request');

    coordinator.complete(RefreshScope.market, true);
    expect(await market, isTrue);
  });
}
