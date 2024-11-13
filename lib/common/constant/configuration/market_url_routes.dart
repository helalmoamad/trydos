import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'new_v1';
  String get _Version10 => 'v10';

  String phoneScope() => '$_api/${_currentVersion}/phone/$this';

  String authFirebaseScope() => '$_api/${_currentVersion}/auth/firebase/$this';

  String authScope() => '$_api/${_currentVersion}/auth/$this';
  String countryScope() => '$_api/${_currentVersion}/$this';
  String customerScope() => '$_api/${_currentVersion}/customer/$this';
  String productsScope() => '$_api/${_currentVersion}/mobile/search/$this';
  String productScope() => '$_api/${_currentVersion}/mobile/product/$this';
  String mobileScope() => '$_api/${_currentVersion}/mobile/$this';
  String likeScope() => '$_api/${_currentVersion}/product_likes/$this';

  String productScopeWeb() => '$_api/${_currentVersion}/web/product/$this';
  String homeScope() => '$_api/${_currentVersion}/mobile/home/$this';
  String cartScope() => '$_api/${_currentVersion}/cart/$this';
  String oldCartScope() => '$_api/${_currentVersion}/old-cart/$this';

  String searchScope() => '$_api/${_currentVersion}/products/$this';
  String notificationScope() => '$_api/${_currentVersion}/notifications';

  String firebaseTokensScope({bool current = false}) =>
      '$_api/${_currentVersion}/firebase_tokens${this != '' ? '/$this' : ''}';

}

abstract class MarketEndPoints {
  static String getProductDetailWithoutSimilarRelatedProducts(
          String productId) =>
      "details_without_similar_related_products/$productId".productScope();
  static String getFullProductDetailsEP(String productId) =>
      "details/$productId".productScope();


  static final sendOtpEP = 'send_otp'.phoneScope();
  static final getCartItemEP = 'cart_shipping'.cartScope();
  static final getProductListInCartEP =
      'product_list_in_cart_and_old_cart'.cartScope();

  static final getOldCartItemsEP = 'get_old_cart'.oldCartScope();
  static final hideItemsInOldCartEP = 'hide'.oldCartScope();
  static final convertItemInOldCartToCartEP = 'convert_to_cart'.oldCartScope();
  static final addItemCartItemEP = 'add'.cartScope();
  static final updateItemCartItemEP = 'update'.cartScope();
  static final requestForNotificationWhenProductBecameAvailableEP =
      ''.notificationScope();
  static final removeItemCartItemEP = 'remove'.cartScope();
  static final verifyOtpSignInEP = 'verify_otp_singin'.phoneScope();
  static final verifyOtpSignUpEP = 'verify_otp_signup'.phoneScope();
  static final verifyOtpFromGuestEP = 'verify_otp_from_guest'.phoneScope();
  static final verifyGuestPhoneEP = 'verify-guest-phone'.authFirebaseScope();
  static final registerEP = 'register'.authScope();
  static final registerGuestEP = 'register-guest'.authScope();
  static final deleteLikeOFProductEP = 'delete'.likeScope();
  static final addLikeOFProductEP = 'store'.likeScope();

  static final loginEP = 'login'.phoneScope();
  static final getAllowesdCountriesEP = "countries".countryScope();
  static final updateNameEP = 'update-name'.customerScope();
  static final getCustomerInfoEP = 'info'.customerScope();
  static final getStartingSettingsEP = 'startingSettings'.homeScope();
  static final getHomeSectionsEP = 'home_sections'.homeScope();
  static final getBrandEP = 'brands'.homeScope();
  static final getCurrencyEP = 'currency'.homeScope();

  static final getCategoryEP = 'categories'.homeScope();

  static final getHomeBoutiqesEP = 'boutiques'.homeScope();
  static final addCommentEP = 'product_comment'.customerScope();
  static String getCommentForProductEP(String productId) =>
      'likesCommentsSharesDetails/$productId'.productScope();
  static final getMainCategoriesEP = 'mainCategories'.homeScope();
  static final getMainCategoriesRelatedWithBoutiquesEP =
      'mainCategoriesRelatedWithBoutique'.homeScope();

  static final getProductFiltersEP = 'filters'.productsScope();
  static final getSearchResultEP = 'search'.searchScope();

  static final getProductListingWithoutFiltersEP = 'products'.mobileScope();
  static final getProductListingWithFiltersEP = 'with_filter'.productsScope();

  static final storeFcmEP = ''.firebaseTokensScope();

}

abstract class MarketUrls {
  static String get baseUrl => _baseUrlDev;

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['MARKET_URL']!;
  static const String _baseUrlDevWithHttp =
      'http://market_under_dev_backend.trydos.dev';
}
