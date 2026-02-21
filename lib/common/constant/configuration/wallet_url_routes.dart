import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  //String get _api => 'api';

  //String get _currentVersion => 'v1';
  //  String get _Version10 => 'v10';

  String authScope() => 'auth/phone/$this';
}

abstract class WalletEndPoints {
  static final loginWithIdTokenEP = 'login-with-id-token'.authScope();
  static const createWalletEP = "wallets";
  static const currenciesEP = "currencies";
  static const walletBalanceEP = "wallets/myAcounts";
}

abstract class WalletUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['WALLET_URL']!;
}
