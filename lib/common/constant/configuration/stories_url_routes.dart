import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'v1';

  String get _prefix => '/$_api/${_currentVersion}';

  String storiesScope() => '$_prefix/stories/$this';
  String usersScope() => '$_prefix/users/$this';
  String authScope() => '$_prefix/auth/$this';
}

abstract class StoriesEndPoints {
  static final loginEP = 'login'.usersScope();

  /// Exchanges the stored (single-use) stories refresh token for a new
  /// access + refresh pair. Owned by this file on purpose: the chat refresh
  /// borrows `MarketEndPoints.refreshTokenEP`, which would silently move the
  /// stories path if the market API version is ever bumped.
  static final refreshTokenEP = 'refresh-token'.authScope();

  static final updateUserEP = 'update'.usersScope();
  // ----<stories scope>----
  static final getStoriesEP = 'users_stories'.storiesScope();
  static String getStoriesForProsuctEP(String productId) =>
      'product_stories/$productId'.storiesScope();
  static final addStoryToOurServerEP = 'add_story'.storiesScope();
  static String increaseViewersEP(String storyId) =>
      'increase_viewers'.storiesScope() + '/$storyId';
  static final deleteStoryEP = 'delete_story'.storiesScope();
  static final reportStoryEP = 'report'.storiesScope();
  // ----<seller stories scope>----
  // Per-shop stories: they live on the stories server (STORY_URL + stories
  // token) and identify the shop through the `seller_id` field, so they must
  // NOT be routed through the dashBoard server / `X-Seller-ID` header.
  static final getSellerStoriesEP = 'seller-stories'.storiesScope();
  static final addSellerStoryEP = 'add-seller-story'.storiesScope();
  static final deleteSellerStoryEP = 'delete-seller-story'.storiesScope();
}

abstract class StoriesUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);
  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['STORY_URL']!;
}
