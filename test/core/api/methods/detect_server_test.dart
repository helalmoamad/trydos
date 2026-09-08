import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../helpers/network_harness.dart';

/// Test ledger · wave 01 Core runtime · unit "Server and token resolution".
///
/// Decides which stored token every outgoing request carries. The grouping is
/// load-bearing: three hosts deliberately share one token, which is what lets a
/// single refresh cover all of them. Split that group by accident and a refresh
/// stops covering the hosts that depended on it.
void main() {
  late FakePrefs prefs;

  setUp(() {
    loadTestEnv();
    prefs = FakePrefs()
      ..marketTokenValue = 'market-token'
      ..chatTokenValue = 'chat-token'
      ..storiesTokenValue = 'stories-token'
      ..walletTokenValue = 'wallet-token'
      ..commentTokenValue = 'comment-token';
    GetIt.I.registerSingleton<PrefsRepository>(prefs);
  });

  tearDown(() => GetIt.I.reset());

  test('market, marketGO and dashBoard all read the same market token', () {
    // The interceptor refreshes these three under one `RefreshScope.market`.
    // That is only correct while they share a token.
    expect(getServerToken(ServerName.market), 'market-token');
    expect(getServerToken(ServerName.marketGO), 'market-token');
    expect(getServerToken(ServerName.dashBoard), 'market-token');
  });

  test('chat, stories, wallet and comment each read their own token', () {
    expect(getServerToken(ServerName.chat), 'chat-token');
    expect(getServerToken(ServerName.stories), 'stories-token');
    expect(getServerToken(ServerName.wallet), 'wallet-token');
    expect(getServerToken(ServerName.comment), 'comment-token');
    expect(getServerToken(ServerName.get_comment_token), 'comment-token');

    // No two of them may collapse onto the same value, or one refresh would
    // silently stand in for another.
    final List<String?> tokens = <String?>[
      getServerToken(ServerName.chat),
      getServerToken(ServerName.stories),
      getServerToken(ServerName.wallet),
    ];
    expect(tokens.toSet(), hasLength(3));
  });

  test('the public servers carry no bearer at all', () {
    // Sending a token to these is a leak, not a convenience.
    for (final ServerName server in <ServerName>[
      ServerName.elastic,
      ServerName.location,
      ServerName.cloudinary,
      ServerName.webApp,
      ServerName.gemini,
      ServerName.mediaServer,
    ]) {
      expect(getServerToken(server), isNull, reason: server.name);
    }
  });

  test('marketGO picks its host from the length of the stored phone number',
      () {
    // A stored number longer than 7 characters means a real registered user, who
    // belongs on the main market host.
    prefs.phoneNumberValue = '09912345678';
    expect(getBaseUriForSpecificServer(ServerName.marketGO),
        MarketUrls.baseUri);

    prefs.phoneNumberValue = '0991234';
    expect(getBaseUriForSpecificServer(ServerName.marketGO),
        MarketUrls.baseUriGo,
        reason: 'exactly 7 is still the guest host');

    prefs.phoneNumberValue = null;
    expect(getBaseUriForSpecificServer(ServerName.marketGO),
        MarketUrls.baseUriGo,
        reason: 'no stored number at all is a guest');

    // The two hosts must actually differ, or the branch proves nothing.
    expect(MarketUrls.baseUri, isNot(MarketUrls.baseUriGo));
  });
}
