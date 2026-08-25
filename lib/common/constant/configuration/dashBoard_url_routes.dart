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
  static final getUsersEP = 'users'.shopScope();
  static final getProducts = 'products'.shopScope();
  static final getBoutiques = 'boutiques'.shopScope();
  static final getOrders = 'orders'.shopScope();
  static final changeOrderDetailStatusToConfirm =
      'orders/details/status/confirmed'.shopScope();
  static final changeOrderDetailStatusToPacked = 'orders/details/status/packed'
      .shopScope();
  static final changeOrderStatus = 'orders/status'.shopScope();
  static final getUserRolesEP = 'roles'.usersScope();
  static String deleteUserEP(String userId) => '$userId/delete'.usersScope();
  static final updateUserRoleEP = 'role/update'.usersScope();
  static final leaveShopEP = 'leave'.usersScope();
  static final String getGalleryImagesEP = '/products/images'.shopScope();

  /// One constant for both verbs: `GET` reads the shop profile,
  /// `PUT` replaces all five of its fields.
  static final String shopInfoEP = 'info'.shopScope();
  static final getPresignedUrlEP = 'uploads/presigned-url'.shopScope();
  // Seller stories are served by the stories server — see
  // `StoriesEndPoints.getSellerStoriesEP` / `addSellerStoryEP` /
  // `deleteSellerStoryEP`.
  static final vendorRequestsEP = 'vendor-requests'.shopScope();
  static String updateVendorRequestEP(int vendorRequestId) =>
      'vendor-requests'.shopScope();
}

abstract class DashBoardUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['MARKET_URL']!;
}
