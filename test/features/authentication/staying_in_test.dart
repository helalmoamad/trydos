import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Staying in".
///
/// Access tokens expire while the app is open. When one does, the network layer
/// pauses the failed request, asks the bloc for a refresh, and waits. Two things
/// then have to be true. The refresh must replace **only** the token of the
/// server that expired — renewing the market session must not touch the chat,
/// stories or comments tokens. And whatever happens, the coordinator must be
/// told, because a request that is never told anything waits for its timeout and
/// the screen behind it just stays empty.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  /// A signed-in user holding all four sessions.
  SessionPrefs signedIn() {
    return SessionPrefs()
      ..marketTokenValue = 'market-token-1'
      ..marketRefreshTokenValue = 'market-refresh-1'
      ..chatTokenValue = 'chat-token-1'
      ..chatRefreshTokenValue = 'chat-refresh-1'
      ..storiesTokenValue = 'stories-token-1'
      ..storiesRefreshTokenValue = 'stories-refresh-1'
      ..commentTokenValue = 'comment-token-1'
      ..commentRefreshTokenValue = 'comment-refresh-1'
      // Longer than seven characters, so market requests route to the market
      // host rather than the guest marketGO host.
      ..phoneNumberValue = '+963931234567'
      ..myMarketIdValue = '501';
  }

  test('RefreshTokenEvent replaces marketToken and leaves the other three '
      'untouched', () async {
    final SessionPrefs prefs = signedIn();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        AuthRoutes.marketRefreshVerified: <ScriptedReply>[
          ScriptedReply(
            200,
            authEnvelope(
              token: 'market-token-2',
              refreshToken: 'market-refresh-2',
            ),
          ),
        ],
      },
    );

    harness.bloc.add(const RefreshTokenEvent());
    await pumpEventQueue();

    expect(prefs.marketTokenValue, 'market-token-2');
    expect(
      prefs.marketRefreshTokenValue,
      'market-refresh-2',
      reason: 'the refresh token is single-use — the old one is now revoked',
    );

    // The point of the scenario: nothing else moved.
    expect(prefs.chatTokenValue, 'chat-token-1');
    expect(prefs.storiesTokenValue, 'stories-token-1');
    expect(prefs.commentTokenValue, 'comment-token-1');
    expect(prefs.chatRefreshTokenValue, 'chat-refresh-1');
    expect(prefs.storiesRefreshTokenValue, 'stories-refresh-1');
    expect(prefs.commentRefreshTokenValue, 'comment-refresh-1');

    // The old refresh token is what is presented, not the access token.
    final Map<String, dynamic> body =
        harness.adapter.bodyOf(AuthRoutes.marketRefreshVerified)!
            as Map<String, dynamic>;
    expect(body['refresh_token'], 'market-refresh-1');
  });

  test('the same holds for RefreshChatTokenEvent and RefreshStoriesTokenEvent',
      () async {
    final SessionPrefs prefs = signedIn();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        AuthRoutes.chatRefresh: <ScriptedReply>[
          ScriptedReply(
            200,
            chatLoginEnvelope(
              accessToken: 'chat-token-2',
              refreshToken: 'chat-refresh-2',
            ),
          ),
        ],
        AuthRoutes.storiesRefresh: <ScriptedReply>[
          ScriptedReply(
            200,
            storiesRefreshEnvelope(
              accessToken: 'stories-token-2',
              refreshToken: 'stories-refresh-2',
            ),
          ),
        ],
      },
    );

    harness.bloc.add(const RefreshChatTokenEvent());
    await pumpEventQueue();
    harness.bloc.add(const RefreshStoriesTokenEvent());
    await pumpEventQueue();

    expect(prefs.chatTokenValue, 'chat-token-2');
    expect(prefs.chatRefreshTokenValue, 'chat-refresh-2');
    expect(prefs.storiesTokenValue, 'stories-token-2');
    expect(prefs.storiesRefreshTokenValue, 'stories-refresh-2');

    // Neither of them went near the market or comments session.
    expect(prefs.marketTokenValue, 'market-token-1');
    expect(prefs.marketRefreshTokenValue, 'market-refresh-1');
    expect(prefs.commentTokenValue, 'comment-token-1');

    // Each refresh went to its own server. The two paths are nearly identical,
    // so the host is the only thing that proves it.
    expect(
      harness.adapter.urlOf(AuthRoutes.chatRefresh),
      contains(TestServers.chatNest),
    );
    expect(
      harness.adapter.urlOf(AuthRoutes.storiesRefresh),
      contains(TestServers.story),
    );
  });

  // ---------------------------------------------------------------------
  // "a failed refresh reports false to the coordinator so the waiting request
  // stops instead of hanging" — two ways a refresh can fail, one test each,
  // because each needs its own session and its own bloc.
  //
  // The third way — the refresh endpoint itself answering **401** — does not
  // release the waiter promptly, and that is a defect, not an oversight here.
  // The 401 goes back through `LoggerInterceptor`, which asks
  // `TokenRefreshCoordinator` for a market refresh; the coordinator sees one
  // already running and hands back its pending future; and that future is
  // completed by the very handler now waiting on it. The two only come apart
  // when the coordinator's own 20-second timeout fires. It is left out of the
  // suite because pinning it costs twenty real seconds per run — it is reported
  // instead (see `test/README.md`).
  // ---------------------------------------------------------------------

  test('a refresh with no stored refresh token reports false at once',
      () async {
    // This is the first run after an app update: there is nothing to exchange.
    final SessionPrefs prefs = signedIn()..marketRefreshTokenValue = '';
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.registerGuestEP: <ScriptedReply>[
          ScriptedReply(200, authEnvelope(token: 'guest-token')),
        ],
        MarketEndPoints.getCustomerInfoEP: <ScriptedReply>[
          ScriptedReply(200, customerInfoEnvelope()),
        ],
      },
    );

    // This is exactly what `LoggerInterceptor` does when a request comes back
    // 401: ask the coordinator, which dispatches the event and hands back a
    // future the paused request waits on.
    final Future<bool> waiting = TokenRefreshCoordinator.instance.refresh(
      RefreshScope.market,
      () => harness.bloc.add(const RefreshTokenEvent()),
    );

    expect(
      await waiting.timeout(const Duration(seconds: 5)),
      isFalse,
      reason: 'with no refresh token to present, the waiting request is told so '
          'at once rather than sitting until its own timeout fires',
    );
    // Let the guest-session recovery finish before the bloc is closed.
    await pumpEventQueue();
  });

  test('a refresh the server rejects reports false and keeps the old tokens',
      () async {
    final SessionPrefs prefs = signedIn();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        AuthRoutes.marketRefreshVerified: <ScriptedReply>[
          ScriptedReply(500, failureBody(message: 'refresh service is down')),
        ],
      },
    );

    final Future<bool> waiting = TokenRefreshCoordinator.instance.refresh(
      RefreshScope.market,
      () => harness.bloc.add(const RefreshTokenEvent()),
    );

    expect(
      await waiting.timeout(const Duration(seconds: 5)),
      isFalse,
      reason: 'a server error is reported back, not swallowed',
    );
    expect(
      prefs.marketTokenValue,
      'market-token-1',
      reason: 'a failed refresh keeps the tokens it could not replace',
    );
    expect(prefs.marketRefreshTokenValue, 'market-refresh-1');
  });

  test('ShowSessionExpiredEvent is emitted once, not once per failed request',
      () async {
    // A verified user — a guest gets a silent new session, only a real account
    // gets the dialog.
    final SessionPrefs prefs = signedIn()..marketRefreshTokenValue = '';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.registerGuestEP: <ScriptedReply>[
          ScriptedReply(
            200,
            authEnvelope(
              token: 'guest-token',
              user: userJson(id: 4242, name: 'guest', phone: '0',
                  isPhoneVerified: 0),
            ),
          ),
        ],
        MarketEndPoints.getCustomerInfoEP: <ScriptedReply>[
          ScriptedReply(
            200,
            customerInfoEnvelope(
              user: userJson(id: 4242, name: 'guest', phone: '0',
                  isPhoneVerified: 0),
            ),
          ),
        ],
      },
    );

    // Ten requests failing at once is the normal case, not the odd one: a screen
    // that fires ten calls on open gets ten 401s in the same moment.
    for (int i = 0; i < 10; i++) {
      harness.bloc.add(const RefreshTokenEvent());
    }
    await pumpEventQueue();

    expect(
      harness.bloc.state.sessionExpiredTick,
      1,
      reason: 'the dialog is shown once per expiry, not once per request — the '
          '10s throttle on RefreshTokenEvent drops the other nine',
    );
    expect(
      harness.bloc.state.sessionExpiredPhone,
      '+963931234567',
      reason: 'the phone is captured before register-guest resets it to "0", so '
          'the re-login dialog can prefill it',
    );
  });
}
