import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "AuthBloc contract".
///
/// Every screen in the app reads `AuthState` to decide what to show. Two things
/// about it are load-bearing and easy to break by accident: what it looks like
/// before anything has happened, and what a failed sign-in is allowed to change.
///
/// **On hydration.** The ledger's third scenario asks for a `toJson` / `fromJson`
/// round-trip on this bloc. There is none to test: `AuthBloc` extends `Bloc`,
/// not `HydratedBloc`, so it persists nothing — see the last test here, which
/// pins that. The hydrated round-trip and the old-payload check are written
/// against `HomeBloc`, which is the bloc that actually persists its state, in
/// `test/features/home/home_state_hydration_test.dart`.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  test('the initial state is the documented one', () async {
    harness = buildAuthFlowHarness(routes: <String, List<ScriptedReply>>{});

    final AuthState state = harness.bloc.state;

    // Every status starts at `init` — nothing has been asked for yet, so no
    // screen may show a spinner or an error on first build.
    expect(state.createUserStatus, CreateUserStatus.init);
    expect(state.loginToChatStatus, LoginToChatStatus.init);
    expect(state.loginToStoriesStatus, LoginToStoriesStatus.init);
    expect(state.sendOtpStatus, SendOtpStatus.init);
    expect(state.verifyOtpSignUpStatus, VerifyOtpSignUpStatus.init);
    expect(state.verifyOtpSignInStatus, VerifyOtpSignInStatus.init);
    expect(state.verifyOtpFromGuestStatus, VerifyOtpFromGuestStatus.init);
    expect(state.registerGuestStatus, RegisterGuestStatus.init);
    expect(state.updateNameStatus, UpdateNameStatus.init);
    expect(state.updateStoriesUserStatus, UpdateStoriesUserStatus.init);
    expect(state.updateChatUserNameStatus, UpdateChatUserNameStatus.init);
    expect(state.getCustomerInfoStatus, GetCustomerInfoStatus.init);
    expect(
      state.generateTokenForCommentStatus,
      GenerateTokenForCommentStatus.init,
    );

    // Two that are deliberately not `init`, and both matter.
    expect(
      state.verifyOtpInProfileStatus,
      isNull,
      reason: 'this one is nullable and starts null — the profile screen tells '
          '"never asked" from "asked and failed" by the null',
    );
    expect(
      state.getCustomerCountryStatus,
      GetCustomerCountryStatus.loading,
      reason: 'the country lookup is fired at launch, so the state says loading '
          'from the start rather than flashing an empty country first',
    );

    // Nothing is known about the user yet.
    expect(state.marketUser, isNull);
    expect(state.countryName, isNull);
    expect(state.getUserCountryResponseModel, isNull);
    expect(state.signInErrorMessage, isNull);
    expect(state.signUpErrorMessage, isNull);
    expect(state.sendOtpError, isNull);
    expect(
      state.sessionExpiredTick,
      0,
      reason: 'the dialog is shown when this changes, so it must start at zero',
    );
    expect(state.sessionExpiredPhone, isNull);
  });

  test('a sign-in failure emits the error state and does NOT clear an existing '
      'session', () async {
    // Someone is already signed in — this is a second sign-in attempt failing,
    // for instance from the "session expired" dialog.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..marketRefreshTokenValue = 'market-refresh'
      ..chatTokenValue = 'chat-token'
      ..storiesTokenValue = 'stories-token'
      ..commentTokenValue = 'comment-token'
      ..myMarketIdValue = '501'
      ..myMarketNameValue = 'Yaser'
      ..phoneNumberValue = '+963931234567'
      ..isVerifiedPhoneValue = true;

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpSignInEP: <ScriptedReply>[
          ScriptedReply(400, failureBody(message: 'wrong code')),
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
    expect(
      harness.bloc.state.signInErrorMessage,
      isNotNull,
      reason: 'the screen needs something to put next to the input',
    );

    // The session that was already there is untouched. Clearing it here would
    // sign a working account out because a *different* attempt failed.
    expect(prefs.marketTokenValue, 'market-token');
    expect(prefs.marketRefreshTokenValue, 'market-refresh');
    expect(prefs.chatTokenValue, 'chat-token');
    expect(prefs.storiesTokenValue, 'stories-token');
    expect(prefs.commentTokenValue, 'comment-token');
    expect(prefs.myMarketIdValue, '501');
    expect(prefs.myMarketNameValue, 'Yaser');
    expect(prefs.isVerifiedPhoneValue, isTrue);
  });

  test('AuthBloc persists nothing, so every status is back to init on the next '
      'launch', () async {
    // Characterisation, and the reason the hydrated round-trip for this unit is
    // written against `HomeBloc` instead. `AuthBloc` is a plain `Bloc`: it has
    // no `toJson`/`fromJson`, and `AuthState` has none either. So a relaunch
    // starts from `const AuthState()` however the last session ended.
    //
    // That is not a defect — the session itself lives in secure storage, and a
    // status like `VerifyOtpSignInStatus.success` would be wrong to restore —
    // but it is worth stating, because "the bloc remembers" is a fair thing to
    // assume and it is not true here.
    harness = buildAuthFlowHarness(
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.sendOtpEP: <ScriptedReply>[
          ScriptedReply(200, sendOtpEnvelope()),
        ],
      },
    );

    // Asked of the built bloc, not of the two `Type` objects: comparing
    // `AuthBloc` to `HydratedBloc` as types is true for any two distinct
    // classes and would stay true if `AuthBloc` started extending it.
    expect(
      harness.bloc,
      isNot(isA<HydratedBloc<AuthEvent, AuthState>>()),
      reason: 'the instance itself is the thing that would gain persistence',
    );
    expect(
      harness.bloc,
      isNot(isA<HydratedMixin<AuthState>>()),
      reason: 'and the mixin is the other way it could arrive',
    );

    harness.bloc.add(
      const SendOtpEvent(phone: '+963931234567', isViaWhatsApp: 0),
    );
    await pumpEventQueue();
    expect(harness.bloc.state.sendOtpStatus, SendOtpStatus.success);

    // Nothing was written to hydrated storage, because the bloc never touches
    // it — `HydratedBloc.storage` was never even set for this harness, and
    // building the bloc did not complain.
    expect(
      () => HydratedBloc.storage,
      throwsA(isA<StorageNotFound>()),
      reason: 'a hydrated bloc could not have been built at all without one',
    );
  });
}
