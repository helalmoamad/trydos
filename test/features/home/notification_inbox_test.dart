import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/home_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "The notification inbox".
///
/// The inbox is a paginated list the user scrolls. Two things decide whether it
/// behaves: a first load must **replace** the list rather than append to it (or
/// pulling to refresh doubles every row), and the order the server sent has to
/// survive, because ordering is the server's job and the app does not re-sort.
void main() {
  HomeFlowHarness? home;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(home);
    home = null;
  });

  SessionPrefs signedIn() {
    return SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..myMarketIdValue = '501'
      ..phoneNumberValue = '+963931234567';
  }

  test('GetUserNotificationEvent returns the list in the order the server sent '
      'it — newest first', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getUserNotificationsEP: <ScriptedReply>[
          ScriptedReply(
            200,
            userNotificationsEnvelope(
              notifications: <Map<String, dynamic>>[
                notificationItem(
                  id: 3,
                  title: 'newest',
                  createdAt: '2026-09-05T12:00:00Z',
                ),
                notificationItem(
                  id: 2,
                  title: 'middle',
                  createdAt: '2026-09-04T12:00:00Z',
                ),
                notificationItem(
                  id: 1,
                  title: 'oldest',
                  createdAt: '2026-09-03T12:00:00Z',
                ),
              ],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(GetUserNotificationEvent(getWithPagination: false));
    await pumpEventQueue();

    final model = flow.bloc.state.getUserNotificationModel!;
    expect(model.paginationStatus, PaginationStatus.success);
    expect(
      model.items.map((dynamic n) => n.title),
      <String>['newest', 'middle', 'oldest'],
      reason: 'the app does not re-sort — whatever order the server sends is '
          'what the user sees, so the handler must not disturb it',
    );

    // Three rows is fewer than a page, so there is nothing more to fetch and the
    // list must stop asking.
    expect(
      model.hasReachedMax,
      isTrue,
      reason: 'a short page is the last page',
    );
  });

  test('a first load replaces the list instead of appending to it', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getUserNotificationsEP: <ScriptedReply>[
          ScriptedReply(
            200,
            userNotificationsEnvelope(
              notifications: <Map<String, dynamic>>[
                notificationItem(id: 1, title: 'first run'),
              ],
            ),
          ),
          ScriptedReply(
            200,
            userNotificationsEnvelope(
              notifications: <Map<String, dynamic>>[
                notificationItem(id: 2, title: 'second run'),
              ],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(GetUserNotificationEvent(getWithPagination: false));
    await pumpEventQueue();
    expect(flow.bloc.state.getUserNotificationModel!.items, hasLength(1));

    // Pull to refresh: not a pagination call.
    flow.bloc.add(GetUserNotificationEvent(getWithPagination: false));
    await pumpEventQueue();

    expect(
      flow.bloc.state.getUserNotificationModel!.items.map((dynamic n) => n.title),
      <String>['second run'],
      reason: 'refreshing shows the server\'s list, not the old one with the '
          'new one stuck on the end',
    );
  });

  test('SendAcceptOfNotificationMarketEvent marks one as accepted and does not '
      're-send for the same id', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.sendAcceptOfNotificationMarketEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'isSuccessful': true,
            'message': 'accepted',
          }),
        ],
      },
    );

    flow.bloc.add(
      SendAcceptOfNotificationMarketEvent(firebaseTokenId: 'token-id-1'),
    );
    await pumpEventQueue();

    expect(
      flow.adapter.callsTo(MarketEndPoints.sendAcceptOfNotificationMarketEP),
      1,
    );
    expect(
      flow.adapter.headersOf(
        MarketEndPoints.sendAcceptOfNotificationMarketEP,
      )?['authorization'],
      'Bearer market-token',
      reason: 'the confirmation is tied to the signed-in account',
    );

    // The same greeting arriving a second time — a re-delivery, or the app
    // opened again from the same notification.
    flow.bloc.add(
      SendAcceptOfNotificationMarketEvent(firebaseTokenId: 'token-id-1'),
    );
    await pumpEventQueue();

    expect(
      flow.adapter.callsTo(MarketEndPoints.sendAcceptOfNotificationMarketEP),
      1,
      reason: 'the id was already confirmed, so nothing goes out again',
    );

    // A different token is a different confirmation and must still be sent.
    flow.bloc.add(
      SendAcceptOfNotificationMarketEvent(firebaseTokenId: 'token-id-2'),
    );
    await pumpEventQueue();

    expect(
      flow.adapter.callsTo(MarketEndPoints.sendAcceptOfNotificationMarketEP),
      2,
      reason: 'the guard is per id, not a one-shot latch for the whole run',
    );
  });

  test('a confirmation the server refused can be sent again', () async {
    // The guard must not swallow the retry: an id is only "confirmed" once the
    // server said so, or a failed attempt would leave the device token
    // unvalidated for the rest of the run with nothing able to try again.
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: signedIn(),
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.sendAcceptOfNotificationMarketEP: <ScriptedReply>[
          const ScriptedReply(500, <String, dynamic>{
            'isSuccessful': false,
            'message': 'validate_token is down',
          }),
          const ScriptedReply(200, <String, dynamic>{
            'isSuccessful': true,
            'message': 'accepted',
          }),
        ],
      },
    );

    flow.bloc.add(
      SendAcceptOfNotificationMarketEvent(firebaseTokenId: 'token-id-1'),
    );
    await pumpEventQueue();
    // The handler retries once on its own, and that retry is what proves the
    // id was released again after the failure.
    await pumpEventQueue();

    expect(
      flow.adapter.callsTo(MarketEndPoints.sendAcceptOfNotificationMarketEP),
      2,
      reason: 'the first attempt failed, so the second was allowed through',
    );
  });
}
