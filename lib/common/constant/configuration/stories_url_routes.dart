extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'v1';

  String get _prefix => '/stories/public/$_api/${_currentVersion}';

  String usersScope() => '$_prefix/users/$this';
}

abstract class StoriesEndPoints {
  static final loginEP = 'login'.usersScope();
}

abstract class StoriesUrls {
  static String get baseUrl => _baseUrlDev;
  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static const String _baseUrlDev = 'https://stories_staging.trydos.tech';
  static const String _baseUrlDevWithHttp = 'http://stories_staging.trydos.tech';
}
