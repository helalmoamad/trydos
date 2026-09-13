import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_flow_harness.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Opening the app".
///
/// Two things have to be true before the first screen is worth showing: the
/// app knows its **starting settings** — how many decimals a price has, how
/// long shipping takes, the minimum version it is allowed to run at — and it
/// has something to paint. Neither is fetched on the splash screen.
///
/// **Where the settings are asked for.** The ledger has this call gating the
/// first build. It does not: the only dispatch of `GetStartingSettingsEvent` in
/// the app is `CategoryBloc.requestAPIAfterHome()`, which runs *after* the home
/// categories answer (pinned in `home_screen_test.dart`). The home is already
/// on screen by then, painting with the settings the previous session
/// persisted. That is what the second test here is really about: the settings
/// are a value that survives a restart, not a gate.
void main() {
  HomeFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(harness);
    harness = null;
  });

  /// The server's answer, with the fields the app actually reads.
  Map<String, dynamic> startingSettingsEnvelope({
    int shippingDays = 3,
    num decimals = 2,
    int androidMinVersion = 10,
  }) =>
      <String, dynamic>{
        'isSuccessful': true,
        'code': 200,
        'data': <String, dynamic>{
          'starting-setting': <String, dynamic>{
            'shipping_duration_days': shippingDays,
            'decimal_point_settings': decimals,
            'android_min_version': androidMinVersion,
            'shipping_cost': 500,
          },
        },
      };

  test('GetStartingSettingsEvent stores the settings the whole app formats '
      'itself by', () async {
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getStartingSettingsEP: <ScriptedReply>[
          ScriptedReply(200, startingSettingsEnvelope(shippingDays: 5)),
        ],
      },
    );

    flow.bloc.add(const GetStartingSettingsEvent());
    await pumpEventQueue();

    expect(
      flow.transitionsOf((HomeState s) => s.getStartingSettingsStatus),
      <GetStartingSettingsStatus>[
        GetStartingSettingsStatus.init,
        GetStartingSettingsStatus.loading,
        GetStartingSettingsStatus.success,
      ],
      reason: 'the splash waits on this status, so the loading emit is part of '
          'the contract, not decoration',
    );
    expect(flow.bloc.state.startingSetting?.shippingDay, 5);
    expect(
      flow.bloc.state.startingSetting?.decimalPointSettings,
      2,
      reason: 'how many decimals every price on every screen is printed with',
    );
    expect(
      flow.bloc.state.startingSetting?.androidMinVersion,
      10,
      reason: 'and the version below which the app must refuse to run',
    );
  });

  test('a failed settings call leaves the previous session\'s settings in '
      'place, rather than a blank home', () async {
    // `HomeBloc` is hydrated and `startingSetting` is part of what it persists,
    // so the settings from the last successful run are already in the state
    // before the request goes out. The failure branch sets the status and
    // touches nothing else — which is what makes the fallback work. The ledger
    // calls this "the cached prefetch"; the mechanism is the hydrated state.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      hydratedSeed: <String, dynamic>{
        'HomeBloc': <String, dynamic>{
          'startingSetting': <String, dynamic>{
            'shipping_duration_days': 7,
            'decimal_point_settings': 3,
          },
        },
      },
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getStartingSettingsEP: <ScriptedReply>[
          const ScriptedReply(500, <String, dynamic>{'message': 'boom'}),
        ],
      },
    );

    expect(flow.bloc.state.startingSetting?.shippingDay, 7,
        reason: 'restored before anything is asked of the network');

    flow.bloc.add(const GetStartingSettingsEvent());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getStartingSettingsStatus,
      GetStartingSettingsStatus.failure,
    );
    expect(
      flow.bloc.state.startingSetting?.shippingDay,
      7,
      reason: 'a failed refresh must not wipe what the app is formatting with '
          '— prices with no decimals and a blank delivery estimate are worse '
          'than slightly stale ones',
    );
    expect(flow.bloc.state.startingSetting?.decimalPointSettings, 3);
  });

  test('ClearAllAppCashEvent empties the prefetch, and the next open fetches '
      'everything again', () async {
    // "Clear cache" in settings. It has to reach three places: the preferences
    // the home screen paints from, the listings held in `BoutiqueBloc`, and the
    // once-only statuses in `HomeBloc` that would otherwise stop the next open
    // from asking.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..mainCategoriesPrefetchValue = '{"data":{"mainCategories":[]}}'
      ..boutiquesPrefetch['women'] = '{"data":{"boutiques":[]}}'
      ..productsPrefetch['zara'] = '{"products":[]}'
      ..fiveFiltersPrefetch['zara'] = '{"filters":[]}';

    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getStartingSettingsEP: <ScriptedReply>[
          ScriptedReply(200, startingSettingsEnvelope()),
        ],
      },
    );
    // The handler tells the listings to clear themselves; record that.
    final FakeBoutiqueBloc boutique = FakeBoutiqueBloc();
    GetIt.I.registerSingleton<BoutiqueBloc>(boutique);

    flow.bloc.add(const GetStartingSettingsEvent());
    await pumpEventQueue();
    expect(
      flow.bloc.state.getStartingSettingsStatus,
      GetStartingSettingsStatus.success,
    );

    flow.bloc.add(const ClearAllAppCashEvent());
    await pumpEventQueue();

    expect(
      prefs.cacheWipes,
      containsAll(<String>[
        'productsOfEachBoutique',
        'boutiquesOfEachCategory',
        'fiveFiltersOfEachBoutique',
        'mainCategories',
      ]),
      reason: 'every prefetch the home screen paints from is dropped — leaving '
          'one behind is how "clear cache" ends up showing the old shop',
    );
    expect(prefs.productsPrefetch, isEmpty);
    expect(prefs.mainCategoriesPrefetchValue, isNull);

    expect(
      boutique.eventsOf<ClearAllBoutiquesEvent>(),
      hasLength(1),
      reason: 'the listings held in memory go too',
    );
    expect(
      flow.bloc.state.getStartingSettingsStatus,
      GetStartingSettingsStatus.init,
      reason: 'back to init, so the next open asks for the settings again '
          'instead of reading a status that says it already has them',
    );
    expect(flow.bloc.state.cartCollection, isEmpty);
  });
}
