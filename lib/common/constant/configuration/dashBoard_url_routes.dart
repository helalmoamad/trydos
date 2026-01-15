import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'v1';
  //  String get _Version10 => 'v10';

  String shopScope() => '$_api/${_currentVersion}/shop/$this';
  String usersScope() => '$_api/${_currentVersion}/shop/users/$this';
}

abstract class DashBoardEndPoints {
  static final getUserPermissionEP = 'auth/permissions'.shopScope();
  static final addUserEP = 'add'.usersScope();
  static final getUsersEP = ''.usersScope();
  static final getProducts = 'products'.shopScope();
  static final getBoutiques = 'boutiques'.shopScope();
  static final getOrders = 'orders'.shopScope();
  static final changeOrderStatus = 'orders/status'.shopScope();
  static final getUserRolesEP = 'roles'.usersScope();
}

abstract class DashBoardUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['MARKET_URL']!;
}
