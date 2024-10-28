import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'v1';

  String get _prefix => '/stories/public/$_api/${_currentVersion}';

  String storiesScope() => '$_prefix/stories/$this';
  String usersScope() => '$_prefix/users/$this';
}

abstract class StoriesEndPoints {
  static final loginEP = 'login'.usersScope();

  static final updateUserEP = 'update'.usersScope();
// ----<stories scope>----
  static final getStoriesEP = 'users_stories'.storiesScope();
  static String getStoriesForProsuctEP(String productId) =>
      'product_stories/$productId'.storiesScope();

  static final uploadStoriesEP = 'upload_story'.storiesScope();
  static final addStoryToOurServerEP = 'add_story'.storiesScope();
  static String increaseViewersEP(String storyId) =>
      'increase_viewers'.storiesScope() + '/$storyId';
}

abstract class StoriesUrls {
  static String get baseUrl => _baseUrlDev;
  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);
  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['STORY_URL']!;
  static const String _baseUrlDevWithHttp =
      'https://stories_staging.trydos.dev/';
}
