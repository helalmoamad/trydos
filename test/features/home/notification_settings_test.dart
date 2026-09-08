import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/home_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Notification settings".
///
/// Three channels — email, push, WhatsApp — plus a frequency and a list of
/// topics. Each switch is its own endpoint, and every one of them answers with
/// the **whole** settings object, so a handler that stores the wrong answer
/// silently flips a switch the user did not touch.
///
/// The device registration is the other half: a phone is registered separately
/// on the market backend and on the chat backend. A device registered on market
/// but not on chat gets order updates and no messages, which looks like chat
/// being broken rather than a missing registration.
void main() {
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
      ..myMarketIdValue = '501'
      ..myChatIdValue = 77
      ..myStoriesIdValue = 88
      ..phoneNumberValue = '+963931234567';
  }

  test('GetFirebaseSettingForNotificationEvent loads the current switches',
      () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getMyFirebaseSettingsEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(
              email: 1,
              firebase: 0,
              whatsapp: 1,
              notificationFrequency: 'weekly',
              subscribed: const <String>['offers', 'orders'],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(const GetFirebaseSettingForNotificationEvent());
    await pumpEventQueue();

    expect(
      flow.transitionsOf(
        (HomeState s) => s.getFirebaseSettingForNotificationStatus,
      ),
      <GetFirebaseSettingForNotificationStatus?>[
        null,
        GetFirebaseSettingForNotificationStatus.loading,
        GetFirebaseSettingForNotificationStatus.success,
      ],
      reason: 'the switches screen shows a spinner while it reads them',
    );
    final settings =
        flow.bloc.state.firebaseSettingForNotificationModel?.data?.firebaseSettings;
    // The server sends these as numbers and the model keeps them as strings —
    // the screen compares against "1", so the exact form matters.
    expect(settings?.email, '1');
    expect(settings?.firebase, '0');
    expect(settings?.whatsapp, '1');
    expect(settings?.notificationFrequency, 'weekly');
    expect(settings?.subscribedTopics?.map((dynamic t) => t.name), <String>[
      'offers',
      'orders',
    ]);
  });

  test('UpdateEmailNotificationEvent, UpdateFirebaseNotificationEvent and '
      'UpdateWhatsappNotificationEvent each toggle only their own channel',
      () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        // Each endpoint answers with the state of the world after its own
        // change, so a handler that called the wrong one would show up as the
        // wrong channel moving.
        MarketEndPoints.updateEmailEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(email: 0, firebase: 1, whatsapp: 0),
          ),
        ],
        MarketEndPoints.updateFirebaseEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(email: 0, firebase: 0, whatsapp: 0),
          ),
        ],
        MarketEndPoints.updateWhatsappEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(email: 0, firebase: 0, whatsapp: 1),
          ),
        ],
      },
    );

    flow.bloc.add(const UpdateEmailNotificationEvent(email: 0));
    await pumpEventQueue();
    expect(
      flow.bloc.state.updateEmailappNotificationStatus,
      UpdateEmailappNotificationStatus.success,
    );
    expect(flow.adapter.callsTo(MarketEndPoints.updateEmailEP), 1);
    expect(
      flow.adapter.callsTo(MarketEndPoints.updateFirebaseEP),
      0,
      reason: 'turning email off must not touch push',
    );
    expect(
      (flow.adapter.bodyOf(MarketEndPoints.updateEmailEP)!
          as Map<String, dynamic>)['email'],
      0,
    );

    flow.bloc.add(const UpdateFirebaseNotificationEvent(firebase: 0));
    await pumpEventQueue();
    expect(flow.adapter.callsTo(MarketEndPoints.updateFirebaseEP), 1);

    flow.bloc.add(const UpdateWhatsappNotificationEvent(whatsapp: 1));
    await pumpEventQueue();
    expect(flow.adapter.callsTo(MarketEndPoints.updateWhatsappEP), 1);

    // Three calls, three endpoints, and the last answer is what is on screen.
    final settings =
        flow.bloc.state.firebaseSettingForNotificationModel?.data?.firebaseSettings;
    expect(settings?.whatsapp, '1');
    expect(settings?.email, '0');
    expect(settings?.firebase, '0');
  });

  test('UpdateNotificationFrequencyEvent stores the chosen frequency',
      () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.updateNotificationFrequencyEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(
              email: 1,
              firebase: 1,
              whatsapp: 0,
              notificationFrequency: 'monthly',
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      const UpdateNotificationFrequencyEvent(notificationFrequency: 'monthly'),
    );
    await pumpEventQueue();

    expect(
      (flow.adapter.bodyOf(MarketEndPoints.updateNotificationFrequencyEP)!
          as Map<String, dynamic>)['notification_frequency'],
      'monthly',
    );
    expect(
      flow.bloc.state.firebaseSettingForNotificationModel?.data
          ?.firebaseSettings?.notificationFrequency,
      'monthly',
    );
  });

  test('SubscribeTopicForNotificationEvent and '
      'UnSubscribeTopicForNotificationEvent are symmetric — unsubscribing after '
      'subscribing leaves no topic behind', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.subscribeTopicEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(
              email: 1,
              firebase: 1,
              whatsapp: 0,
              subscribed: const <String>['offers'],
              unsubscribed: const <String>[],
            ),
          ),
        ],
        MarketEndPoints.unsubscribeTopicEP: <ScriptedReply>[
          ScriptedReply(
            200,
            firebaseSettingsEnvelope(
              email: 1,
              firebase: 1,
              whatsapp: 0,
              subscribed: const <String>[],
              unsubscribed: const <String>['offers'],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      const SubscribeTopicForNotificationEvent(
        topic: 'offers',
        variant: 'new_arrivals',
      ),
    );
    await pumpEventQueue();

    var settings =
        flow.bloc.state.firebaseSettingForNotificationModel?.data?.firebaseSettings;
    expect(settings?.subscribedTopics?.map((dynamic t) => t.name), <String>[
      'offers',
    ]);
    expect(
      (flow.adapter.bodyOf(MarketEndPoints.subscribeTopicEP)!
          as Map<String, dynamic>)['variant'],
      'new-arrivals',
      reason: 'the underscore is rewritten to a dash on the way out — the topic '
          'name has to match what the unsubscribe below sends, or the two are '
          'not the same topic to the backend',
    );

    flow.bloc.add(
      const UnSubscribeTopicForNotificationEvent(
        topic: 'offers',
        variant: 'new_arrivals',
      ),
    );
    await pumpEventQueue();

    settings =
        flow.bloc.state.firebaseSettingForNotificationModel?.data?.firebaseSettings;
    expect(
      settings?.subscribedTopics,
      isEmpty,
      reason: 'nothing is left subscribed after the round trip',
    );
    expect(settings?.unsubscribedTopics?.map((dynamic t) => t.name), <String>[
      'offers',
    ]);
    expect(
      (flow.adapter.bodyOf(MarketEndPoints.unsubscribeTopicEP)!
          as Map<String, dynamic>)['variant'],
      'new-arrivals',
      reason: 'the same rewrite on both sides is what makes them symmetric',
    );
  });

  test('ChangeCountryLanguageForNotificationEvent sends the language the push '
      'should arrive in', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.changeCountryLanguageEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
        ],
      },
    );

    flow.bloc.add(
      const ChangeCountryLanguageForNotificationEvent(
        country: 'SY',
        languageCode: 'ar',
      ),
    );
    await pumpEventQueue();

    final Map<String, dynamic> body =
        flow.adapter.bodyOf(MarketEndPoints.changeCountryLanguageEP)!
            as Map<String, dynamic>;
    expect(
      body.values,
      contains('ar'),
      reason: 'push is composed on the server, so the language has to travel '
          'with the registration — nothing on the phone can translate it later',
    );
    expect(body.values, contains('SY'));
  });

  test('StoreFcmTokenOfMarketEvent, StoreFcmTokenInChatEvent and '
      'StoreFcmTokenInStoryEvent each register the device on their own backend',
      () async {
    // The market registration lives on `HomeBloc`.
    final SessionPrefs prefs = signedIn();
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.storeFcmOfMarketEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 'market-token-id'},
          }),
        ],
      },
    );

    flow.bloc.add(
      const StoreFcmTokenOfMarketEvent(userId: 501, fcmToken: 'device-token-1'),
    );
    await pumpEventQueue();

    expect(flow.adapter.callsTo(MarketEndPoints.storeFcmOfMarketEP), 1);
    expect(
      prefs.fcmMarketTokenIdValue,
      isNotNull,
      reason: 'the id is needed later to confirm the registration',
    );

    // A guest with no market id arrives as -1, and registering that would create
    // a row nobody can be reached through.
    flow.bloc.add(
      const StoreFcmTokenOfMarketEvent(userId: -1, fcmToken: 'device-token-1'),
    );
    await pumpEventQueue();
    expect(
      flow.adapter.callsTo(MarketEndPoints.storeFcmOfMarketEP),
      1,
      reason: 'a userId of -1 means "not signed in" and is dropped',
    );

    await tearDownHomeFlowHarness(home);
    home = null;

    // The chat and stories registrations live on `AuthBloc`, and each refuses to
    // run without the token of its own server — that is the guard that keeps a
    // registration from going out unauthenticated.
    final SessionPrefs authPrefs = signedIn();
    final AuthFlowHarness authFlow = auth = buildAuthFlowHarness(
      prefs: authPrefs,
      routes: <String, List<ScriptedReply>>{
        ChatEndPoints.storeFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 'chat-token-id'},
          }),
        ],
        MarketEndPoints.storeFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 'stories-token-id'},
          }),
        ],
      },
    );

    authFlow.bloc.add(
      const StoreFcmTokenInChatEvent(
        userId: 77,
        fcmToken: 'device-token-1',
        serverName: ServerName.chat,
      ),
    );
    await pumpEventQueue();

    expect(
      authFlow.adapter.callsTo(ChatEndPoints.storeFcmEP),
      1,
      reason: 'a device registered on market but not on chat gets no message '
          'push at all',
    );
    expect(
      authFlow.adapter.urlOf(ChatEndPoints.storeFcmEP),
      contains(TestServers.chatNest),
    );

    authFlow.bloc.add(
      const StoreFcmTokenInStoryEvent(
        userId: 88,
        fcmToken: 'device-token-1',
        serverName: ServerName.stories,
      ),
    );
    await pumpEventQueue();

    expect(authFlow.adapter.callsTo(MarketEndPoints.storeFcmEP), 1);
    expect(authPrefs.fcmTokenIdValue, isNotNull);
  });
}
