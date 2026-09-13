import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "AuthBloc contract" — the
/// hydration scenario.
///
/// The ledger files "hydrated `toJson`/`fromJson` round-trips, and an old stored
/// payload still loads instead of crashing on launch" under `AuthBloc`. There is
/// nothing to test there: `AuthBloc` is a plain `Bloc` and persists nothing (see
/// `test/features/authentication/auth_bloc_contract_test.dart`). `HomeBloc` is
/// the bloc that actually persists, so the scenario is written against it.
///
/// This is the highest-stakes deserialisation in the app. `fromJson` runs in the
/// **constructor**, on launch, before any screen exists — so a payload the
/// current release cannot read is not a wrong screen, it is an app that will not
/// start, on a device that already has the update installed and cannot roll
/// back.
void main() {
  HomeFlowHarness? home;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(home);
    home = null;
  });

  test('toJson and fromJson round-trip', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      routes: <String, List<ScriptedReply>>{},
    );

    flow.bloc.add(
      SaveUserInfoFromAuthEvent(
        userInfo: User(
          id: 501,
          name: 'Yaser',
          phone: '+963931234567',
          email: 'y@example.com',
          isPhoneVerified: 1,
          // The token has to be present for the scrub below to be observable
          // at all. Without it the assertion passes whether or not the code
          // scrubs anything.
          lastOtpIdToken: 'header.payload.signature',
        ),
      ),
    );
    await pumpEventQueue();

    // The bloc persisted on its own, without being asked.
    expect(
      flow.storage.writeCount,
      greaterThan(0),
      reason: 'every emit is written — that is what makes it hydrated',
    );

    final Map<String, dynamic>? written =
        flow.bloc.toJson(flow.bloc.state);
    expect(written, isNotNull);

    final HomeState? restored = flow.bloc.fromJson(written!);
    expect(restored, isNotNull);
    expect(restored!.userInfo?.id, 501);
    expect(restored.userInfo?.name, 'Yaser');
    expect(restored.userInfo?.phone, '+963931234567');

    // The OTP id token is scrubbed on the way out on purpose: it is auth
    // material, it lives in secure storage, and the hydrated box is plaintext.
    expect(
      flow.bloc.state.userInfo?.lastOtpIdToken,
      'header.payload.signature',
      reason: 'the in-memory state keeps the token — only the on-disk copy is '
          'scrubbed, so nothing that needs it in this session breaks',
    );
    expect(
      (written['userInfo'] as Map<dynamic, dynamic>?)?['last_otp_id_token'],
      isNull,
      reason: 'a JWT must not be rewritten into the plaintext box on every emit',
    );

    // And the same holds for what the bloc actually wrote, not only for the map
    // this test asked for by hand.
    final Map<dynamic, dynamic>? persisted =
        flow.storage.contents['HomeBloc'] as Map<dynamic, dynamic>?;
    expect(
      (persisted?['userInfo'] as Map<dynamic, dynamic>?)?['last_otp_id_token'],
      isNull,
    );
  });

  test('an old stored payload still loads instead of crashing on launch',
      () async {
    // The oldest possible payload: an object with none of the keys this release
    // adds. Anything the release added has to have a default, or a device that
    // updates cannot open the app at all.
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      hydratedSeed: <String, dynamic>{
        'HomeBloc': <String, dynamic>{'userInfo': <String, dynamic>{'id': 42}},
      },
      routes: <String, List<ScriptedReply>>{},
    );

    // Constructing the bloc is the test: `fromJson` ran inside it.
    expect(
      flow.bloc.state.userInfo?.id,
      42,
      reason: 'what the old payload did carry is restored',
    );
    expect(
      flow.bloc.state.compareProducts,
      isEmpty,
      reason: 'a field the old release never wrote comes back as its default, '
          'not as null',
    );
    // Not every missing field defaults to a value — the nullable ones come back
    // null, and the screens that read them already handle that. What matters is
    // that neither shape throws while the bloc is being built.
    expect(flow.bloc.state.listitemForAddToCart, isNull);
  });

  test('a payload that is not a HomeState at all does not stop the app',
      () async {
    // A corrupt box — a partial write, or a payload from a release whose shape
    // changed. `HydratedBloc` catches the error from `fromJson` and falls back
    // to the initial state; nothing here may throw out of the constructor.
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      hydratedSeed: <String, dynamic>{
        'HomeBloc': <String, dynamic>{'userInfo': 'this used to be an object'},
      },
      routes: <String, List<ScriptedReply>>{},
    );

    expect(
      flow.bloc.state.userInfo,
      isNull,
      reason: 'the app opens on a clean state rather than not opening',
    );
  });
}
