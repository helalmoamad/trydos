import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/elastic_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/home_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "Country and currency".
///
/// The country the app thinks the user is in decides three separate things: the
/// catalogue they see, the currency every price is printed in, and whether an
/// address they type is inside the delivery area. It is resolved once from the
/// IP, can be overridden by the user, and then rides along in a `country` header
/// on every later request — which is the part that is easy to break without
/// noticing, because the app keeps working, it just shows the wrong country's
/// shop.
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

  test('GetUserCountryEvent resolves the country and stores its ISO', () async {
    // The IP lookup runs on `AuthBloc`, against a public service — no token,
    // no market host.
    final SessionPrefs prefs = SessionPrefs();
    final AuthFlowHarness flow = auth = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        'ipwho.is': <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'success': true,
            'ip': '1.2.3.4',
            'country': 'Syria',
            'country_code': 'SY',
            'city': 'Damascus',
          }),
        ],
      },
    );

    flow.bloc.add(GetUserCountryEvent());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getCustomerCountryStatus,
      GetCustomerCountryStatus.success,
    );
    expect(
      prefs.countryIsoValue,
      'SY',
      reason: 'the ISO is what every later request is filtered by',
    );
    expect(
      flow.bloc.state.countryName,
      'Syria',
      reason: 'the readable name is what the country picker shows',
    );
    expect(
      flow.adapter.authOf('ipwho.is'),
      isNull,
      reason: 'a public lookup must not carry the account bearer',
    );
  });

  test('GetAllowedCountriesEvent returns only countries the app serves',
      () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getAllowesdCountriesEP: <ScriptedReply>[
          ScriptedReply(200, allowedCountriesEnvelope()),
        ],
      },
    );

    flow.bloc.add(GetAllowedCountriesEvent());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getAllowedCountriesStatus,
      GetAllowedCountriesStatus.success,
    );
    final List<String?> isos = (flow.bloc.state.getAllowedCountriesModel?.data
                ?.countries ??
            <dynamic>[])
        .map((dynamic c) => c.iso as String?)
        .toList();
    expect(
      isos,
      <String>['SY', 'IQ'],
      reason: 'the picker lists exactly what the server allows — a country the '
          'app cannot deliver to must never appear in it',
    );
  });

  test('choosing a country sets userChoosedCountryIso and the next request '
      'carries it in the country header', () async {
    // "Available" is the flag that says the user made a choice; without it the
    // header falls back to the IP-resolved ISO.
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..countryIsoValue = 'SY';

    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getCurrencyEP: <ScriptedReply>[
          ScriptedReply(200, currencyEnvelope()),
        ],
      },
    );

    await prefs.setUserChoosedCountryIso('IQ');
    await prefs.setUserCountryIsAvailable(1);

    flow.bloc.add(GetCurrencyForCountryEvent());
    await pumpEventQueue();

    expect(prefs.userChoosedCountryIsoValue, 'IQ');
    expect(
      flow.adapter.headersOf(MarketEndPoints.getCurrencyEP)?['country'],
      'IQ',
      reason: 'the chosen country wins over the one the IP suggested — this '
          'header is what the backend filters the whole catalogue by',
    );
  });

  test('GetCurrencyForCountryEvent drives the price format — the symbol and the '
      'decimals, not just the call', () async {
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getCurrencyEP: <ScriptedReply>[
          ScriptedReply(
            200,
            currencyEnvelope(
              symbol: 'ع.د',
              code: 'IQD',
              // Iraqi dinar prices are shown whole: the fixture's default of
              // zero decimals is the point of the assertion below.
              exchangeRate: 1310,
            ),
          ),
        ],
      },
    );

    flow.bloc.add(GetCurrencyForCountryEvent());
    await pumpEventQueue();

    final currency = flow.bloc.state.getCurrencyForCountryModel?.data?.currency;
    expect(currency?.symbol, 'ع.د');
    expect(currency?.code, 'IQD');
    expect(
      currency?.decimalDigits,
      0,
      reason: 'the number of decimals is part of the price, not decoration',
    );
    expect(currency?.exchangeRate, 1310);
  });

  test('a currency answer with no decimal_digits falls back to two', () async {
    // Older rows in the currency table have no `decimal_digits`. The model
    // parses that to 2 rather than to null, because null would crash every
    // price formatter on the screen.
    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: SessionPrefs()..marketTokenValue = 'market-token',
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.getCurrencyEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'isSuccessful': true,
            'code': 200,
            'data': <String, dynamic>{
              'currency': <String, dynamic>{
                'id': 3,
                'name': 'US Dollar',
                'symbol': r'$',
                'code': 'USD',
                'exchange_rate': 1,
              },
            },
          }),
        ],
      },
    );

    flow.bloc.add(GetCurrencyForCountryEvent());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getCurrencyForCountryModel?.data?.currency?.decimalDigits,
      2,
    );
  });

  test('GetCoutryBoundaryByIsoEvent returns the boundary used to validate an '
      'address', () async {
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-token'
      ..countryIsoValue = 'SY';

    final HomeFlowHarness flow = home = buildHomeFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        ElasticEndPoints.countryBoundaryByIsoEP('SY'): <ScriptedReply>[
          ScriptedReply(
            200,
            countryBoundaryEnvelope(
              points: const <List<double>>[
                <double>[35.0, 38.0],
                <double>[36.5, 39.5],
                <double>[34.0, 37.0],
              ],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(const GetCoutryBoundaryByIsoEvent());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getCountryBoundaryByIsoStatus,
      GetCountryBoundaryByIsoStatus.success,
    );
    expect(
      flow.bloc.state.countryCoordinatesBorders,
      hasLength(3),
      reason: 'the address form checks a dropped pin against these points',
    );
    expect(flow.bloc.state.countryCoordinatesBorders.first.latitude, 35.0);
    expect(flow.bloc.state.countryCoordinatesBorders.first.longitude, 38.0);

    // The lookup goes to the elastic host, and the ISO is part of the path — a
    // request for the wrong country would still come back 200 with the wrong
    // shape, so the url is the only place this can be checked.
    expect(
      flow.adapter.urlOf(ElasticEndPoints.countryBoundaryByIsoEP('SY')),
      contains(TestServers.elastic),
    );
  });
}
