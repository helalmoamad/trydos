extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'new_v1';
  String get _Version10 => 'v10';

  String phoneScope() => '$_api/${_currentVersion}/phone/$this';

  String authFirebaseScope() => '$_api/${_currentVersion}/auth/firebase/$this';

  String authScope() => '$_api/${_currentVersion}/auth/$this';

  String customerScope() => '$_api/${_currentVersion}/customer/$this';
  String productsScope() => '$_api/${_currentVersion}/mobile/products/$this';
  String productScope() => '$_api/${_currentVersion}/mobile/product/$this';
  String mobileScope() => '$_api/${_currentVersion}/mobile/$this';
  String productScopeWeb() => '$_api/${_currentVersion}/web/product/$this';
  String homeScope() => '$_api/${_currentVersion}/mobile/home/$this';
  String cartScope() => '$_api/${_currentVersion}/cart/$this';
}

abstract class MarketEndPoints {
  static String getProductDetailWithoutSimilarRelatedProducts(
          String productId) =>
      "details_without_similar_related_products/$productId".productScope();

  static final sendOtpEP = 'send_otp'.phoneScope();
  static final getCartItemEP = 'cart_shipping'.cartScope();
  static final addItemCartItemEP = 'add'.cartScope();
  static final updateItemCartItemEP = 'update'.cartScope();
  static final removeItemCartItemEP = 'remove'.cartScope();
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
  static final getHomeBoutiqesEP = 'boutiques'.homeScope();
  static String getCommentForProductEP(String productId) =>
      'likesCommentsSharesDetails/$productId'.productScopeWeb();
  static final getMainCategoriesEP = 'mainCategories'.homeScope();
  static final getMainCategoriesRelatedWithBoutiquesEP =
      'mainCategoriesRelatedWithBoutique'.homeScope();

  static final getProductFiltersEP = 'filters'.productsScope();
  static final getProductListingWithoutFiltersEP = 'products'.mobileScope();
  static final getProductListingWithFiltersEP = 'with_filter'.productsScope();
}

abstract class MarketUrls {
  static String get baseUrl => _baseUrlDev;

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static const String _baseUrlDev = 'https://market_staging.antiksef.online';
  static const String _baseUrlDevWithHttp =
      'http://market_staging.antiksef.online';
}
