import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Verify the OTP".
///
/// The six digits the user types are the moment the app decides who they are.
/// Three different endpoints answer them — sign-in for an account that exists,
/// sign-up for one that does not, and the in-profile check for a phone the
/// signed-in user is proving. Each one has to leave the stored session in a
/// state the rest of the app can trust, and a wrong code has to leave it
/// **untouched**.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  test('VerifyOtpSignInEvent stores the market token', () async {
    harness = buildAuthFlowHarness(
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpSignInEP: <ScriptedReply>[
          ScriptedReply(
            200,
            authEnvelope(
              token: 'signin-access-token',
              refreshToken: 'signin-refresh-token',
              idToken: 'signin-id-token',
              user: userJson(id: 501, phone: '+963931234567'),
            ),
          ),
        ],
        // The customer-info refresh that sign-in fires answers with the same
        // account, so it cannot be what stored the id asserted below.
        ...fanOutRoutes(
          customerInfo: customerInfoEnvelope(
            user: userJson(id: 501, phone: '+963931234567'),
          ),
        ),
      },
    );

    harness.bloc.add(
      VerifyOtpSignInEvent(
        verificationId: 'vid-1',
        otp: '123456',
        phone: '+963931234567',
      ),
    );
    await pumpEventQueue();

    expect(
      harness.transitionsOf((AuthState s) => s.verifyOtpSignInStatus),
      <VerifyOtpSignInStatus>[
        VerifyOtpSignInStatus.init,
        VerifyOtpSignInStatus.loading,
        VerifyOtpSignInStatus.success,
      ],
      reason: 'the six digits are checked behind a spinner, and the screen only '
          'moves on when the answer arrives',
    );
    expect(harness.prefs.marketTokenValue, 'signin-access-token');
    expect(
      harness.prefs.marketRefreshTokenValue,
      'signin-refresh-token',
      reason: 'the refresh token is what keeps the account signed in later',
    );
    expect(
      harness.prefs.idTokenValue,
      'signin-id-token',
      reason: 'the other three servers are logged into with this id token',
    );
    expect(harness.prefs.myMarketIdValue, '501');
    expect(
      harness.bloc.state.marketUser?.phone,
      '+963931234567',
      reason: 'the screen reads the user off the state, not off storage',
    );
  });

  test('VerifyOtpSignUpEvent creates the account first, then stores the token',
      () async {
    final SessionPrefs prefs = SessionPrefs();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpSignUpEP: <ScriptedReply>[
          ScriptedReply(
            200,
            authEnvelope(
              token: 'signup-access-token',
              refreshToken: 'signup-refresh-token',
              idToken: 'signup-id-token',
              // A brand-new account: the server says it did not exist before.
              alreadyExists: false,
              user: userJson(id: 900, name: 'Nour', phone: '+963939999999'),
            ),
          ),
        ],
        ...fanOutRoutes(
          customerInfo: customerInfoEnvelope(
            user: userJson(id: 900, name: 'Nour', phone: '+963939999999'),
          ),
        ),
      },
    );

    harness.bloc.add(
      VerifyOtpSignUpEvent(
        verificationId: 'vid-1',
        otp: '654321',
        name: 'Nour',
      ),
    );
    await pumpEventQueue();

    expect(
      harness.bloc.state.verifyOtpSignUpStatus,
      VerifyOtpSignUpStatus.success,
    );
    // The account is created by the sign-up endpoint itself: the name the user
    // chose is part of the request, and the session only exists because that
    // call came back 200.
    final Map<String, dynamic> body =
        harness.adapter.bodyOf(MarketEndPoints.verifyOtpSignUpEP)!
            as Map<String, dynamic>;
    expect(body['name'], 'Nour');
    expect(
      harness.adapter.callsTo(MarketEndPoints.verifyOtpSignUpEP),
      1,
      reason: 'one account, one call — a repeat would create a second one',
    );

    expect(prefs.marketTokenValue, 'signup-access-token');
    expect(prefs.marketRefreshTokenValue, 'signup-refresh-token');
    expect(prefs.myMarketIdValue, '900');
    expect(prefs.myMarketNameValue, 'Nour');
    expect(
      prefs.otpCodeValue,
      '654321',
      reason: 'sign-up is the one flow that keeps the code it used',
    );
  });

  test('a wrong code returns Left and stores nothing at all', () async {
    final SessionPrefs prefs = SessionPrefs();

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpSignInEP: <ScriptedReply>[
          ScriptedReply(400, failureBody(message: 'invalid code')),
        ],
      },
    );

    harness.bloc.add(
      VerifyOtpSignInEvent(
        verificationId: 'vid-1',
        otp: '000000',
        phone: '+963931234567',
      ),
    );
    await pumpEventQueue();

    expect(
      harness.bloc.state.verifyOtpSignInStatus,
      VerifyOtpSignInStatus.failure,
    );
    expect(prefs.marketTokenValue, isNull);
    expect(prefs.marketRefreshTokenValue, isNull);
    expect(prefs.idTokenValue, isNull);
    expect(prefs.myMarketIdValue, isNull);
    expect(
      prefs.isVerifiedPhoneValue,
      isNull,
      reason: 'a rejected code proves nothing about the phone',
    );
    // Nothing downstream may act on a session that was never created. The home
    // bloc does hear about the failure itself — `LoggerInterceptor` reports
    // every error through `SendErrorToMobileErrorLogEvent` — but none of the
    // events that assume a signed-in user.
    expect(harness.home.eventsOf<SaveUserInfoFromAuthEvent>(), isEmpty);
    expect(harness.home.eventsOf<GetCartItemEvent>(), isEmpty);
    expect(harness.home.eventsOf<GetCurrencyForCountryEvent>(), isEmpty);
  });

  test(
      'VerifyOtpInProfileEvent stores the fresh id token and keeps the session '
      'alive', () async {
    // A signed-in user proving a phone number from inside their profile. Every
    // token they already hold has to survive it.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..chatTokenValue = 'chat-token'
      ..storiesTokenValue = 'stories-token'
      ..commentTokenValue = 'comment-token'
      ..phoneNumberValue = '+963931234567'
      ..idTokenValue = 'old-id-token';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpInProfileEP: <ScriptedReply>[
          ScriptedReply(
            200,
            verifyOtpInProfileEnvelope(
              phone: '+963931111111',
              idToken: 'profile-id-token',
            ),
          ),
        ],
      },
    );

    harness.bloc.add(
      VerifyOtpInProfileEvent(verificationId: 'vid-1', otp: '123456'),
    );
    await pumpEventQueue();

    expect(
      harness.bloc.state.verifyOtpInProfileStatus,
      VerifyOtpInProfileStatus.success,
    );
    expect(
      prefs.idTokenValue,
      'profile-id-token',
      reason: 'the profile update that follows is authorised with this token',
    );

    // The session is untouched — this check proves a phone, it does not start a
    // new session.
    expect(prefs.marketTokenValue, 'market-token');
    expect(prefs.chatTokenValue, 'chat-token');
    expect(prefs.storiesTokenValue, 'stories-token');
    expect(prefs.commentTokenValue, 'comment-token');

    // Characterisation, not approval. The ledger expects this event to change
    // the stored phone number. It does not: `_onVerifyOtpInProfileEvent` reads
    // only `id_token` off a response that also carries `phone`, and the number
    // is changed later by the profile update. This assertion will fail the day
    // the handler starts storing it — which is the point of writing it down.
    expect(
      prefs.phoneNumberValue,
      '+963931234567',
      reason: 'the handler ignores the `phone` the server sent back',
    );
  });
}
