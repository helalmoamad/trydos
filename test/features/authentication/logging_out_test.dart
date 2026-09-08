import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Logging out" — the bloc
/// half.
///
/// The storage half of this unit is in
/// `test/core/data/repository/prefs_repository_impl_test.dart`. This file covers
/// the one scenario that is about events: unregistering the device so a
/// logged-out phone stops receiving push.
///
/// A device is registered on **two** backends — the market one and the chat one
/// — so it has to be unregistered from both. A device left registered keeps
/// getting messages for an account nobody is signed into any more, which is a
/// privacy problem, not a cosmetic one.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  test('DeleteFcmTokenFromChatEvent unregisters the device from chat',
      () async {
    final SessionPrefs prefs = SessionPrefs()
      ..chatTokenValue = 'chat-token'
      ..marketTokenValue = 'market-token'
      ..phoneNumberValue = '+963931234567';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        ChatEndPoints.deleteFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
        ],
      },
    );

    harness.bloc.add(
      const DeleteFcmTokenFromChatEvent(fcmToken: 'device-token-1'),
    );
    await pumpEventQueue();

    expect(harness.adapter.callsTo(ChatEndPoints.deleteFcmEP), 1);
    expect(
      harness.adapter.urlOf(ChatEndPoints.deleteFcmEP),
      contains(TestServers.chatNest),
    );
    expect(
      (harness.adapter.bodyOf(ChatEndPoints.deleteFcmEP)!
          as Map<String, dynamic>)['token'],
      'device-token-1',
      reason: 'the server needs to know which device to forget',
    );
  });

  test('with no chat session the chat unregister is skipped rather than sent '
      'unauthenticated', () async {
    // Logging out of an account that never reached chat: there is no token to
    // authenticate the call, so sending it would only produce a 401.
    final SessionPrefs prefs = SessionPrefs()..marketTokenValue = 'market-token';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        ChatEndPoints.deleteFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
        ],
      },
    );

    harness.bloc.add(
      const DeleteFcmTokenFromChatEvent(fcmToken: 'device-token-1'),
    );
    await pumpEventQueue();

    expect(harness.adapter.callsTo(ChatEndPoints.deleteFcmEP), 0);
  });

  test('DeleteFcmTokenEvent does nothing — the market registration is never '
      'removed', () async {
    // Characterisation of a defect, not approval of it.
    //
    // The ledger expects both `DeleteFcmTokenEvent` and
    // `DeleteFcmTokenFromChatEvent` to run on logout, so the device stops
    // receiving push from both backends. `DeleteFcmTokenEvent` is declared in
    // `auth_event.dart:86` and that is all: `AuthBloc`'s constructor registers no
    // `on<DeleteFcmTokenEvent>`, so it falls through to the catch-all
    // `on<AuthEvent>((event, emit) {})` and is dropped. Nothing in `lib/`
    // dispatches it either — `base_page.dart:948` sends only the chat one.
    //
    // The market device token therefore stays registered after a logout, and
    // the phone keeps receiving market push for an account nobody is signed
    // into. This test will fail the day a handler is added, which is what makes
    // the defect impossible to fix silently.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..chatTokenValue = 'chat-token'
      ..myMarketIdValue = '501'
      ..phoneNumberValue = '+963931234567';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.storeFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 1},
          }),
        ],
        ChatEndPoints.deleteFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
        ],
      },
    );

    harness.bloc.add(
      const DeleteFcmTokenEvent(userId: 501, fcmToken: 'device-token-1'),
    );
    await pumpEventQueue();

    expect(
      harness.adapter.callCount,
      0,
      reason: 'the event has no handler, so no request is made at all',
    );
  });
}
