extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'new_v1';

  String phoneScope() => '$_api/${_currentVersion}/phone/$this';

  String authFirebaseScope() => '$_api/${_currentVersion}/auth/firebase/$this';

  String authScope() => '$_api/${_currentVersion}/auth/$this';

  String customerScope() => '$_api/${_currentVersion}/customer/$this';
  String productsScope() => '$_api/${_currentVersion}/products/$this';
  String homeScope() => '$_api/${_currentVersion}/mobile/home/$this';
}

abstract class MarketEndPoints {
  static final sendOtpEP = 'send_otp'.phoneScope();
  static final verifyOtpSignInEP = 'verify_otp_singin'.phoneScope();
  static final verifyOtpSignUpEP = 'verify_otp_signup'.phoneScope();
  static final verifyOtpFromGuestEP = 'verify_otp_from_guest'.phoneScope();
  static final verifyGuestPhoneEP = 'verify-guest-phone'.authFirebaseScope();
  static final registerEP = 'register'.authScope();
  static final registerGuestEP = 'register-guest'.authScope();
  static final loginEP = 'login'.phoneScope();
  static final updateNameEP = 'update-name'.customerScope();
  static final getCustomerInfoEP = 'info'.customerScope();
  static final getStartingSettingsEP = 'startingSettings'.homeScope();
  static final getHomeSectionsEP = 'home_sections'.homeScope();
  static final getMainCategoriesEP = 'mainCategories'.homeScope();
  static final getProductListingWithoutFiltersEP = 'with_colors_without_filter'.productsScope();
}

abstract class MarketUrls {
  static String get baseUrl => _baseUrlDev;

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static const String _baseUrlDev = 'https://market_staging.trydos.tech';
  static const String _baseUrlDevWithHttp = 'http://market_staging.trydos.tech';
}
