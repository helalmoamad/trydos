import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Continue as guest".
///
/// Every first run of the app is a guest session: no phone, no password, just a
/// device id exchanged for a token. Everything a visitor does — browsing, the
/// cart — hangs off that session, so two things must hold. A guest register has
/// to leave a **complete** session behind (a token and an id), and a failed one
/// has to leave **nothing** behind, because a half-written session is worse than
/// no session: the app then carries an id it has no token for.
///
/// The third scenario is the upgrade path: the guest verifies a phone number and
/// becomes a real account without losing the cart they built as a guest.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  test('RegisterGuestEvent stores a usable token and a guest id', () async {
    harness = buildAuthFlowHarness(
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.registerGuestEP: <ScriptedReply>[
          ScriptedReply(
            200,
            authEnvelope(
              token: 'guest-access-token',
              refreshToken: 'guest-refresh-token',
              user: userJson(
                id: 4242,
                name: 'guest',
                phone: '0',
                isPhoneVerified: 0,
              ),
            ),
          ),
        ],
        // `GetCustomerInfoEvent` is dispatched by the handler under test; it is
        // covered on its own under "Edit the profile", so here it only has to
        // answer — with the same account, or it would overwrite what was stored.
        MarketEndPoints.getCustomerInfoEP: <ScriptedReply>[
          ScriptedReply(
            200,
            customerInfoEnvelope(
              user: userJson(
                id: 4242,
                name: 'guest',
                phone: '0',
                isPhoneVerified: 0,
              ),
            ),
          ),
        ],
      },
    );

    harness.bloc.add(RegisterGuestEvent(deviceId: 'device-1'));
    await pumpEventQueue();

    expect(
      harness.prefs.marketTokenValue,
      'guest-access-token',
      reason: 'the guest session is only usable if its access token is stored',
    );
    expect(
      harness.prefs.marketRefreshTokenValue,
      'guest-refresh-token',
      reason: 'without the refresh token the first 401 throws the guest out',
    );
    expect(
      harness.prefs.myMarketIdValue,
      '4242',
      reason: 'the cart and every later request are keyed by this id',
    );
    expect(
      harness.transitionsOf((AuthState s) => s.registerGuestStatus),
      <RegisterGuestStatus>[
        RegisterGuestStatus.init,
        RegisterGuestStatus.loading,
        RegisterGuestStatus.success,
      ],
    );

    // A brand-new guest has phone "0". The stored number is what routes market
    // requests between `market` and `marketGO`, so it must be reset, not left
    // holding the previous account's number.
    expect(harness.prefs.phoneNumberValue, '0');
    expect(
      harness.prefs.isVerifiedPhoneValue,
      isFalse,
      reason: 'a guest is never a verified phone',
    );
  });

  test('a failed register leaves no partial session — no token, no id',
      () async {
    final SessionPrefs prefs = SessionPrefs();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.registerGuestEP: <ScriptedReply>[
          ScriptedReply(500, failureBody(message: 'register-guest is down')),
        ],
      },
    );

    harness.bloc.add(RegisterGuestEvent(deviceId: 'device-1'));
    await pumpEventQueue();

    expect(
      harness.transitionsOf((AuthState s) => s.registerGuestStatus),
      <RegisterGuestStatus>[
        RegisterGuestStatus.init,
        RegisterGuestStatus.loading,
        RegisterGuestStatus.failure,
      ],
    );
    expect(
      prefs.marketTokenValue,
      isNull,
      reason: 'nothing may be written before the server said yes',
    );
    expect(prefs.marketRefreshTokenValue, isNull);
    expect(
      prefs.myMarketIdValue,
      isNull,
      reason: 'an id without a token is a session the app cannot use',
    );
    expect(
      prefs.myMarketNameValue,
      isNull,
      reason: 'the identity keys move together with the token, or not at all',
    );
  });

  test(
      'VerifyOtpFromGuestEvent turns the guest into a real account and keeps '
      'the cart that was built as a guest', () async {
    // The guest is already signed in — this is the session being upgraded.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'guest-access-token'
      ..marketRefreshTokenValue = 'guest-refresh-token'
      ..myMarketIdValue = '4242'
      ..phoneNumberValue = '0';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpFromGuestEP: <ScriptedReply>[
          ScriptedReply(
            200,
            authEnvelope(
              token: 'verified-access-token',
              refreshToken: 'verified-refresh-token',
              // The same id as the guest: this is the account keeping the cart.
              user: userJson(id: 4242, name: 'Yaser', phone: '+963931234567'),
            ),
          ),
        ],
        // Dispatched by the handler under test — it answers with the same
        // account so it cannot be what moved the stored id.
        MarketEndPoints.getCustomerInfoEP: <ScriptedReply>[
          ScriptedReply(
            200,
            customerInfoEnvelope(
              user: userJson(id: 4242, name: 'Yaser', phone: '+963931234567'),
            ),
          ),
        ],
      },
    );

    harness.bloc.add(
      VerifyOtpFromGuestEvent(verificationId: 'vid-1', otp: '123456'),
    );
    await pumpEventQueue();

    expect(
      harness.bloc.state.verifyOtpFromGuestStatus,
      VerifyOtpFromGuestStatus.success,
    );
    expect(
      prefs.marketTokenValue,
      'verified-access-token',
      reason: 'the guest token is replaced by the account token',
    );
    expect(prefs.myMarketNameValue, 'Yaser');
    expect(prefs.phoneNumberValue, '+963931234567');
    expect(
      prefs.isVerifiedPhoneValue,
      isTrue,
      reason: 'the account answered `is_phone_verified: 1`',
    );

    // The cart is the point of the upgrade: the market id did not change, and
    // the bloc asks the home bloc to read the cart back rather than clearing it.
    expect(
      prefs.myMarketIdValue,
      '4242',
      reason: 'a new id here would orphan everything the guest put in the cart',
    );
    expect(
      harness.home.eventsOf<GetCartItemEvent>(),
      hasLength(1),
      reason: 'the guest cart is read back under the now-verified session',
    );
    expect(harness.home.eventsOf<GetOldCartItemEvent>(), hasLength(1));
    expect(
      harness.home.eventsOf<ClearAllAppCashEvent>(),
      isEmpty,
      reason: 'upgrading a guest must never wipe what the guest collected',
    );
  });
}
