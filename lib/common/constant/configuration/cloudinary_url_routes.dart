extension ScopeApi on String {
  String get _version =>'v1_1';
  String get _cloudinaryName => 'djooohujg';

  String noScope() => '$_version/$_cloudinaryName/$this';
}

abstract class CloudinaryEndPoints {
  static final uploadEP = 'upload'.noScope();
}

abstract class CloudinaryUrls {
  static final String _baseUri = 'https://api.cloudinary.com';
  static final String _loadPreset = 'v4h8xqns';

  static Uri get baseUri => Uri.parse(_baseUri);

  static String get LoadPreset => _loadPreset;
}
