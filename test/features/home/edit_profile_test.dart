import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/home_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Edit the profile".
///
/// The profile is the one screen where the user changes their own data, and the
/// same data lives on three backends. Two rules hold it together. The update
/// sends **only what changed**, because an empty field in the request is a field
/// the server is being told to clear. And a photo is only stored once the upload
/// that produced it succeeded — a failed upload leaves the old picture in place
/// rather than a broken link.
void main() {
  // Nullable: the last scenario drives an `AuthBloc` event instead, so it
  // builds the other harness and this one stays unset.
  HomeFlowHarness? home;
  AuthFlowHarness? auth;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(home);
    home = null;
    await tearDownAuthFlowHarness(auth);
    auth = null;
  });

  SessionPrefs signedIn() {
    return SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..chatTokenValue = 'chat-token'
      ..storiesTokenValue = 'stories-token'
      ..idTokenValue = 'otp-id-token'
      ..myMarketIdValue = '501'
      ..myMarketNameValue = 'Old Name'
      ..myProfilePhotoValue = 'customers/profile/old.jpg'
      ..phoneNumberValue = '+963931234567';
  }

  test('UpdateProfileEvent sends only the fields that changed', () async {
    final SessionPrefs prefs = signedIn();
    final HomeFlowHarness harness = home = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.updateProfileEP: <ScriptedReply>[
          ScriptedReply(
            200,
            updateProfileEnvelope(
              user: userJson(id: 501, name: 'New Name'),
              message: 'saved',
            ),
          ),
        ],
      },
    );

    // The user edited the name and nothing else.
    harness.bloc.add(UpdateProfileEvent(name: 'New Name', idToken: 'otp-id-token'));
    await pumpEventQueue();

    expect(
      harness.transitionsOf((HomeState s) => s.updateProfileStatus),
      // Null, not `init`: this status is nullable and starts unset, unlike most
      // of its neighbours. The screen reads that as "never saved yet".
      <UpdateProfileStatus?>[
        null,
        UpdateProfileStatus.loading,
        UpdateProfileStatus.success,
      ],
      reason: 'the save button shows a spinner between the tap and the answer',
    );

    final Map<String, dynamic> body =
        harness.adapter.bodyOf(MarketEndPoints.updateProfileEP)!
            as Map<String, dynamic>;
    expect(body['name'], 'New Name');
    expect(body['id_token'], 'otp-id-token');
    expect(
      body.keys,
      unorderedEquals(<String>['name', 'id_token']),
      reason: 'every untouched field is dropped before the request — sending '
          'them as null or "" would tell the server to clear them',
    );

    // The saved answer is what the app then believes.
    expect(prefs.myMarketNameValue, 'New Name');
    expect(harness.bloc.state.userInfo?.name, 'New Name');
  });

  test('a name change is carried on to the chat and stories copies', () async {
    final SessionPrefs prefs = signedIn();
    final HomeFlowHarness harness = home = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.updateProfileEP: <ScriptedReply>[
          ScriptedReply(
            200,
            updateProfileEnvelope(user: userJson(id: 501, name: 'New Name')),
          ),
        ],
      },
    );

    harness.bloc.add(UpdateProfileEvent(name: 'New Name'));
    await pumpEventQueue();

    expect(
      harness.chat.eventsOf<UpdateProfileInChatEvent>(),
      hasLength(1),
      reason: 'the chat copy of the name is updated because a chat token exists',
    );
    expect(
      harness.auth.eventsOf<UpdateStoriesUserEvent>(),
      hasLength(1),
      reason: 'and the stories copy for the same reason',
    );
    expect(prefs.myStoriesNameValue, 'New Name');
  });

  test('UploadUserPhotoCloudinaryEvent uploads then stores the returned url, '
      'and a failed upload keeps the old photo', () async {
    final SessionPrefs prefs = signedIn();
    final HomeFlowHarness harness = home = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        // The upload itself is not scripted here: it needs a real file on disk
        // and a multipart body, and it is covered by wave 01's upload-pipeline
        // tests. What this scenario is about is what the *profile* does with the
        // answer, so the event is driven from its failure entry point and from a
        // profile update carrying an uploaded path.
        MarketEndPoints.updateProfileEP: <ScriptedReply>[
          ScriptedReply(
            200,
            updateProfileEnvelope(
              user: userJson(id: 501, image: 'customers/profile/new.jpg'),
            ),
          ),
        ],
      },
    );

    // The success path: the upload hands its sub-path to `UpdateProfileEvent`,
    // which is what actually stores the photo.
    harness.bloc.add(UpdateProfileEvent(image: 'customers/profile/new.jpg'));
    await pumpEventQueue();

    expect(
      prefs.myProfilePhotoValue,
      'customers/profile/new.jpg',
      reason: 'the stored photo is the one the server confirmed, not the one '
          'the phone uploaded',
    );
    // Only the file name is sent: the server owns the folder.
    expect(
      (harness.adapter.bodyOf(MarketEndPoints.updateProfileEP)!
          as Map<String, dynamic>)['image'],
      'new.jpg',
    );

    // The failure path. `LoggerInterceptor` re-dispatches the event with
    // `changeStatusToFailure` when the upload request errors, and that branch
    // must not touch the stored photo.
    harness.bloc.add(
      UploadUserPhotoCloudinaryEvent(
        // The file is never opened on this branch — the handler returns before
        // the upload — so a path that does not exist keeps the suite off disk.
        File('does-not-exist.jpg'),
        true,
      ),
    );
    await pumpEventQueue();

    expect(
      harness.bloc.state.uploadUserPhotoCloudinaryStatus,
      UploadUserPhotoCloudinaryStatus.failure,
      reason: 'the screen has to stop showing a spinner',
    );
    expect(
      prefs.myProfilePhotoValue,
      'customers/profile/new.jpg',
      reason: 'a failed upload leaves the photo the user already had',
    );
  });

  test('SaveUserInfoFromAuthEvent fills the profile from the session without a '
      'second request', () async {
    final HomeFlowHarness harness = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{},
    );

    harness.bloc.add(
      SaveUserInfoFromAuthEvent(
        userInfo: User(
          id: 501,
          name: 'Yaser',
          phone: '+963931234567',
          email: 'y@example.com',
          isPhoneVerified: 1,
        ),
      ),
    );
    await pumpEventQueue();

    expect(harness.bloc.state.userInfo?.id, 501);
    expect(harness.bloc.state.userInfo?.name, 'Yaser');
    expect(harness.bloc.state.userInfo?.email, 'y@example.com');
    expect(
      harness.adapter.callCount,
      0,
      reason: 'the sign-in answer already carried the user — asking again would '
          'be a second round trip on the slowest screen of the app',
    );
  });

  test('GetCustomerInfoEvent refreshes the stored profile', () async {
    // This event belongs to `AuthBloc`, not `HomeBloc`, even though the ledger
    // files it under the profile — it is what re-reads the account after a
    // sign-in, and it hands the fresh user to `HomeBloc`.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..phoneNumberValue = '+963931234567'
      ..myMarketNameValue = 'Stale Name'
      ..isVerifiedPhoneValue = false;

    final AuthFlowHarness flow = auth = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getCustomerInfoEP: <ScriptedReply>[
          ScriptedReply(
            200,
            customerInfoEnvelope(
              user: userJson(
                id: 501,
                name: 'Fresh Name',
                phone: '+963931234567',
              ),
            ),
          ),
        ],
      },
    );

    flow.bloc.add(GetCustomerInfoEvent());
    await pumpEventQueue();

    expect(flow.bloc.state.getCustomerInfoStatus, GetCustomerInfoStatus.success);
    expect(prefs.myMarketNameValue, 'Fresh Name');
    expect(
      prefs.myChatNameValue,
      'Fresh Name',
      reason: 'the refresh writes the name into all three stored copies',
    );
    expect(prefs.myStoriesNameValue, 'Fresh Name');
    expect(
      prefs.isVerifiedPhoneValue,
      isTrue,
      reason: 'the server is the authority on whether the phone is verified',
    );
    expect(
      flow.home.eventsOf<SaveUserInfoFromAuthEvent>(),
      hasLength(1),
      reason: 'the fresh user is handed straight to the profile screen',
    );
  });
}
