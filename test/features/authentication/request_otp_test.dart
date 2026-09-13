import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Request an OTP".
///
/// One tap on "send me a code" costs the company an SMS and the user a wait. So
/// two things matter: the id that comes back has to be stored, because the OTP
/// the user types is worthless without it, and a second tap inside the wait
/// window must not go out.
///
/// **A note on where the lock lives.** The ledger describes this as "`SendOtpEvent`
/// sets the timer flag so the resend button locks". It does not: the flag
/// (`setTimerForOtpRunning` / `setOtpTimerEndTime`) is written by the OTP screen
/// — `verify_otp.dart:74` and `first_registeration_page.dart:82` — and only
/// drives the countdown label. What actually stops a second request from
/// reaching the server is the bloc's `throttleDroppable(10s)` transformer on
/// `SendOtpEvent`. These tests pin the real mechanism from both ends: one asks
/// the bloc for two taps and counts the requests that left, and one drives the
/// transformer directly to watch the window reopen.
void main() {
  // Nullable on purpose: the last test drives the transformer alone and builds
  // no harness, so the shared tearDown must be able to see that.
  AuthFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  test('SendOtpEvent stores the verification id the typed code is checked with',
      () async {
    final SessionPrefs prefs = SessionPrefs()
      // Left over from a previous attempt: the handler must clear it before it
      // asks, so a failed send cannot leave a stale id behind to verify against.
      ..verificationIdValue = 'stale-vid';

    final AuthFlowHarness flow = harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.sendOtpEP: <ScriptedReply>[
          ScriptedReply(200, sendOtpEnvelope(verificationId: 'vid-fresh')),
        ],
      },
    );

    flow.bloc.add(
      const SendOtpEvent(phone: '+963931234567', isViaWhatsApp: 0),
    );
    await pumpEventQueue();

    expect(
      flow.transitionsOf((AuthState s) => s.sendOtpStatus),
      <SendOtpStatus>[
        SendOtpStatus.init,
        SendOtpStatus.loading,
        SendOtpStatus.success,
      ],
      reason: 'the screen shows a spinner between the tap and the answer — a '
          'handler that skipped `loading` would leave the button looking dead',
    );
    expect(
      prefs.verificationIdValue,
      'vid-fresh',
      reason: 'the code the user types is checked against this id',
    );

    // The phone and the channel are what the SMS gateway is told; a flipped
    // `is_via_whatsapp` sends the code down the wrong pipe.
    final Map<String, dynamic> body =
        flow.adapter.bodyOf(MarketEndPoints.sendOtpEP)!
            as Map<String, dynamic>;
    expect(body['phone'], '+963931234567');
    expect(body['is_via_whatsapp'], '0');
  });

  test('a failed send stores no verification id, so the user can try again',
      () async {
    final SessionPrefs prefs = SessionPrefs()..verificationIdValue = 'stale-vid';

    final AuthFlowHarness flow = harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.sendOtpEP: <ScriptedReply>[
          ScriptedReply(500, failureBody(message: 'sms gateway down')),
        ],
      },
    );

    flow.bloc.add(
      const SendOtpEvent(phone: '+963931234567', isViaWhatsApp: 0),
    );
    await pumpEventQueue();

    expect(
      flow.transitionsOf((AuthState s) => s.sendOtpStatus),
      <SendOtpStatus>[
        SendOtpStatus.init,
        SendOtpStatus.loading,
        SendOtpStatus.failure,
      ],
      reason: 'the failure path has to clear the spinner too',
    );
    expect(
      flow.bloc.state.sendOtpError,
      isNotNull,
      reason: 'the screen needs something to show, or the tap looks ignored',
    );
    expect(
      prefs.verificationIdValue,
      isNull,
      reason:
          'the stale id was cleared before the request and nothing replaced it '
          '— verifying against it would check the code of an older attempt',
    );
  });

  test('a second tap goes nowhere near the SMS gateway', () async {
    // The test below proves the transformer works. This one proves `AuthBloc`
    // actually uses it: without it the two taps below would be two SMS.
    final AuthFlowHarness flow = harness = buildAuthFlowHarness(
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.sendOtpEP: <ScriptedReply>[
          ScriptedReply(200, sendOtpEnvelope()),
          ScriptedReply(200, sendOtpEnvelope(verificationId: 'vid-2')),
        ],
      },
    );

    flow.bloc.add(
      const SendOtpEvent(phone: '+963931234567', isViaWhatsApp: 0),
    );
    flow.bloc.add(
      const SendOtpEvent(phone: '+963931234567', isViaWhatsApp: 0),
    );
    await pumpEventQueue();

    expect(
      flow.adapter.callsTo(MarketEndPoints.sendOtpEP),
      1,
      reason: 'an impatient double tap must cost one SMS, not two — the '
          'throttle is registered on the event, not left to the screen',
    );
    expect(
      flow.prefs.verificationIdValue,
      'vid-1',
      reason: 'and the id in hand is the one the sent code belongs to',
    );
  });

  test('a resend inside the throttle window is dropped, and allowed once it '
      'expires', () {
    // This drives `throttleDroppable` itself. Going through the bloc would need
    // the clock moved while a mocked http call is in flight; the transformer is
    // the piece that decides, and it can be asked directly.
    fakeAsync((FakeAsync async) {
      final StreamController<int> taps = StreamController<int>();
      final List<int> handled = <int>[];

      throttleDroppable<int>(const Duration(seconds: 10))(
        taps.stream,
        (int tap) async* {
          handled.add(tap);
        },
      ).listen(null);
      async.flushMicrotasks();

      taps.add(1);
      async.flushMicrotasks();
      expect(handled, <int>[1], reason: 'the first tap always goes out');

      // Still inside the window.
      async.elapse(const Duration(seconds: 4));
      taps.add(2);
      async.flushMicrotasks();
      expect(
        handled,
        <int>[1],
        reason: 'a second tap four seconds later must not cost another SMS',
      );

      // Past it.
      async.elapse(const Duration(seconds: 7));
      taps.add(3);
      async.flushMicrotasks();
      expect(
        handled,
        <int>[1, 3],
        reason: 'once the window is over the user may ask again',
      );

      taps.close();
      async.flushMicrotasks();
    });
  });
}
