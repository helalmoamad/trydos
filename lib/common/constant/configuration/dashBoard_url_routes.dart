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

  // ---------------------------------------------------------------------------
  // Locations — a shop's warehouses and pickup points.
  //
  // Six calls, two constants and three per-record functions. There is **no
  // delete endpoint**: a location can only be deactivated.
  //
  // Every write here is a `POST`, update included, so the shop id travels on
  // the request through `RequestConfig.extraHeaders`, which only `post.dart`
  // honours. No shared HTTP client is touched by this feature.
  // ---------------------------------------------------------------------------

  /// The collection. `GET` lists, `POST` creates — one path, two verbs.
  static final String shopLocationsEP = 'locations'.shopScope();

  /// The create form's country list. This call needs `CREATE_LOCATION`, so it
  /// runs only when the add form opens. Never build the list's country filter
  /// from it — a read-only member gets a 403.
  static final String shopLocationLookupsEP = 'locations/lookups'.shopScope();

  /// The id is an `int`, not a `String`. `deleteUserEP` is the *shape* to copy,
  /// not the *signature*: a `String` here would undo the model's typing at the
  /// exact boundary that builds the URL, since anything at all can be
  /// interpolated into a string path.
  static String shopLocationEditEP(int id) => 'locations/$id/edit'.shopScope();

  static String shopLocationUpdateEP(int id) =>
      'locations/$id/update'.shopScope();

  static String shopLocationChangeStatusEP(int id) =>
      'locations/$id/change-status'.shopScope();
}

abstract class DashBoardUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['MARKET_URL']!;
}
