import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/api/base_api.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/service/language_service.dart';

import '../../helpers/network_harness.dart';

/// Test ledger · wave 01 Core runtime · unit "Request headers".
///
/// Every request the app makes is built here. The country header decides which
/// catalogue the user sees and the language header decides what language the
/// backend answers in, so a mistake shows up as wrong prices or wrong text
/// rather than as an error.
///
/// `BaseApi` is abstract; this is the smallest concrete subclass that lets the
/// constructor run.
class _TestApi extends BaseApi<void> {
  _TestApi(super.serverName);

  @override
  Future<void> call() async {}
}

void main() {
  late FakePrefs prefs;

  setUp(() {
    loadTestEnv();
    prefs = FakePrefs()
      ..marketTokenValue = 'market-token'
      ..chatTokenValue = 'chat-token'
      ..countryIsoValue = 'SY'
      ..userChoosedCountryIsoValue = 'IQ'
      ..userCountryIsAvailableValue = 0
      ..myMarketIdValue = 'market-id-9'
      ..xSellerIdValue = 'seller-id-4';

    GetIt.I.registerSingleton<PrefsRepository>(prefs);
    // A fresh Dio per test: the constructor writes into `client.options.headers`,
    // so a shared instance would carry one test's headers into the next.
    GetIt.I.registerSingleton<Dio>(Dio());

    LanguageService.languageCode = 'en';
    LanguageService.isKurdish = false;
  });

  tearDown(() => GetIt.I.reset());

  Map<String, dynamic> headersFor(ServerName server) =>
      _TestApi(server).options.headers ?? <String, dynamic>{};

  test('a server with a token gets a bearer, and the header leaks to the next',
      () {
    expect(headersFor(ServerName.market)[HttpHeaders.authorizationHeader],
        'Bearer market-token');

    expect(headersFor(ServerName.chat)[HttpHeaders.authorizationHeader],
        'Bearer chat-token',
        reason: 'each server carries its own token');

    // Documented defect, pinned deliberately. The constructor mutates the shared
    // `client.options.headers` in place and only ever ADDS the bearer:
    //
    //     if (token != null) { headers = client.options.headers ..[auth] = ... }
    //
    // With no token there is no `remove`, so the previous server's bearer is
    // still on the shared Dio options and goes out with the next request. A
    // market token can reach cloudinary, elastic or gemini this way.
    final Map<String, dynamic> publicServer = headersFor(ServerName.elastic);
    expect(publicServer[HttpHeaders.authorizationHeader], 'Bearer chat-token',
        reason: 'LEAK: a public server should carry no bearer at all');
  });

  test('cloudinary is built without the country, language or agent headers',
      () {
    // Checked on a fresh Dio so nothing is left over from another server.
    final Map<String, dynamic> headers = headersFor(ServerName.cloudinary);

    expect(headers.containsKey('country'), isFalse);
    expect(headers.containsKey('lang'), isFalse);
    expect(headers.containsKey('User-Agent'), isFalse);
  });

  test('the country header follows whether the user picked a country', () {
    prefs.userCountryIsAvailableValue = 0;
    expect(headersFor(ServerName.market)['country'], 'SY',
        reason: 'falls back to the detected country');

    GetIt.I.unregister<Dio>();
    GetIt.I.registerSingleton<Dio>(Dio());

    prefs.userCountryIsAvailableValue = 1;
    expect(headersFor(ServerName.market)['country'], 'IQ',
        reason: 'the country the user chose wins');
  });

  test('the language header collapses Kurdish and Arabic correctly', () {
    // Kurdish is stored as Arabic with a flag beside it, so the header builder
    // is the only place that can tell them apart.
    LanguageService.languageCode = 'ar';
    LanguageService.isKurdish = true;
    expect(headersFor(ServerName.market)['lang'], 'ku');

    LanguageService.isKurdish = false;
    expect(headersFor(ServerName.market)['lang'], 'ar');

    LanguageService.languageCode = 'tr';
    expect(headersFor(ServerName.market)['lang'], 'tr',
        reason: 'any other language passes through unchanged');
  });

  test('the seller and elastic headers go only to their own server', () {
    expect(headersFor(ServerName.elastic)['original-user-id'], 'market-id-9');
    expect(headersFor(ServerName.dashBoard)['X-Seller-ID'], 'seller-id-4');

    // On a fresh Dio, market asks for neither.
    GetIt.I.unregister<Dio>();
    GetIt.I.registerSingleton<Dio>(Dio());
    final Map<String, dynamic> market = headersFor(ServerName.market);
    expect(market.containsKey('original-user-id'), isFalse);
    expect(market.containsKey('X-Seller-ID'), isFalse);
  });
}
