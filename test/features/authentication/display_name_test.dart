import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Change the display name
/// everywhere".
///
/// The user types one new name. Three backends have to hear about it, because
/// each of them keeps its own copy: the market shows it on orders, chat shows it
/// on messages, stories shows it on posts. Three separate calls means three
/// separate ways to fail, and the app has to survive the middle of that — the
/// two that worked stay changed, and the screen is told the change did not
/// finish.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  /// A signed-in user who can reach all three name endpoints.
  SessionPrefs signedIn() {
    return SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..chatTokenValue = 'chat-token'
      ..storiesTokenValue = 'stories-token'
      ..idTokenValue = 'otp-id-token'
      ..phoneNumberValue = '+963931234567'
      ..myMarketNameValue = 'Old Name'
      ..myChatNameValue = 'Old Name'
      ..myStoriesNameValue = 'Old Name';
  }

  /// All three name endpoints answering yes.
  Map<String, List<ScriptedReply>> allThreeSucceed() {
    return <String, List<ScriptedReply>>{
      MarketEndPoints.updateNameEP: <ScriptedReply>[
        const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
      ],
      ChatEndPoints.updateUserNameEP: <ScriptedReply>[
        const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
      ],
      StoriesEndPoints.updateUserEP: <ScriptedReply>[
        const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
      ],
    };
  }

  test('UpdateNameEvent, UpdateChatUserNameEvent and UpdateStoriesUserEvent '
      'each hit their own backend', () async {
    harness = buildAuthFlowHarness(
      prefs: signedIn(),
      routes: allThreeSucceed(),
    );

    // The market-only event. It changes the market copy and nothing else.
    harness.bloc.add(UpdateNameEvent(name: 'New Name'));
    await pumpEventQueue();

    expect(harness.bloc.state.updateNameStatus, UpdateNameStatus.success);
    expect(harness.adapter.callsTo(MarketEndPoints.updateNameEP), 1);
    expect(
      harness.adapter.urlOf(MarketEndPoints.updateNameEP),
      contains(TestServers.market),
      reason: 'a verified phone routes the marketGO call to the market host',
    );
    expect(
      harness.adapter.callsTo(ChatEndPoints.updateUserNameEP),
      0,
      reason: 'UpdateNameEvent is the market one — it speaks for no one else',
    );

    // The chat event carries the change on to the market and stories copies.
    harness.bloc.add(UpdateChatUserNameEvent(name: 'New Name'));
    await pumpEventQueue();

    expect(
      harness.bloc.state.updateChatUserNameStatus,
      UpdateChatUserNameStatus.success,
    );
    expect(harness.adapter.callsTo(ChatEndPoints.updateUserNameEP), 1);
    expect(harness.adapter.callsTo(StoriesEndPoints.updateUserEP), 1);
    expect(
      harness.adapter.callsTo(MarketEndPoints.updateNameEP),
      2,
      reason: 'the chat event updates the market copy too',
    );

    // Each call went to its own host with the name in it.
    expect(
      harness.adapter.urlOf(ChatEndPoints.updateUserNameEP),
      contains(TestServers.chatNest),
    );
    expect(
      harness.adapter.urlOf(StoriesEndPoints.updateUserEP),
      contains(TestServers.story),
    );
    expect(
      (harness.adapter.bodyOf(ChatEndPoints.updateUserNameEP)!
          as Map<String, dynamic>)['name'],
      'New Name',
    );
    expect(
      (harness.adapter.bodyOf(StoriesEndPoints.updateUserEP)!
          as Map<String, dynamic>)['name'],
      'New Name',
    );

    // All three stored copies now agree.
    expect(harness.prefs.myChatNameValue, 'New Name');
    expect(harness.prefs.myMarketNameValue, 'New Name');
    expect(harness.prefs.myStoriesNameValue, 'New Name');
  });

  test('a failure on one does not roll back the ones that succeeded, and the '
      'UI is told which failed', () async {
    final SessionPrefs prefs = signedIn();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        // Chat and market accept the new name; stories — the last step — does
        // not.
        ChatEndPoints.updateUserNameEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
        ],
        MarketEndPoints.updateNameEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
        ],
        StoriesEndPoints.updateUserEP: <ScriptedReply>[
          ScriptedReply(500, failureBody(message: 'stories is down')),
        ],
      },
    );

    harness.bloc.add(UpdateChatUserNameEvent(name: 'New Name'));
    await pumpEventQueue();
    // The failure path retries once, which is a second pass through the handler
    // — drain it here rather than leaving it to run after the bloc is closed.
    await pumpEventQueue();

    expect(
      harness.bloc.state.updateChatUserNameStatus,
      UpdateChatUserNameStatus.failure,
      reason: 'the screen must be able to say the change did not finish',
    );

    // The two that worked stay changed — there is no undo call, and inventing
    // one would mean three more chances to fail.
    expect(prefs.myChatNameValue, 'New Name');
    expect(prefs.myMarketNameValue, 'New Name');
    expect(
      prefs.myStoriesNameValue,
      'Old Name',
      reason: 'the copy that was never accepted keeps the old name',
    );

    // The retry has to be for the flow that failed. This handler used to re-add
    // `UpdateStoriesUserEvent`, which starts the stories-first chain: that ran
    // the stories update a second time and never retried the chat name at all.
    // Counting the calls is the only place the difference shows.
    expect(
      harness.adapter.callsTo(StoriesEndPoints.updateUserEP),
      1,
      reason: 'the failed step is not re-run by a chain it does not belong to',
    );
    expect(
      harness.adapter.callsTo(MarketEndPoints.updateNameEP),
      1,
      reason: 'and the step that already succeeded is not repeated either',
    );
  });
}
