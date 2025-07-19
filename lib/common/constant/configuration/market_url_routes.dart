import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _currentVersion => 'v1';
  String get _Version10 => 'v10';

  String phoneScope() => '$_api/${_currentVersion}/auth/phone/$this';

  String authFirebaseScope() => '$_api/${_currentVersion}/auth/firebase/$this';

  String authScope() => '$_api/${_currentVersion}/auth/$this';
  String webScope() => '$_api/${_currentVersion}/web/$this';
  String storageScope() => '$_api/${_currentVersion}/storage/$this';
  String errorScope() => '$_api/${_currentVersion}/mobile_error_log/$this';
  String countryScope() => '$_api/${_currentVersion}/$this';
  String customerScope() => '$_api/${_currentVersion}/customer/$this';
  String productsScope() => '$_api/${_currentVersion}/mobile/search/$this';
  String productScope() => '$_api/${_currentVersion}/mobile/product/$this';
  String mobileScope() => '$_api/${_currentVersion}/mobile/$this';
  String likeScope() => '$_api/${_currentVersion}/product_likes/$this';
  String productScopeWeb() => '$_api/${_currentVersion}/web/product/$this';
  String homeScope() => '$_api/${_currentVersion}/mobile/home/$this';
  String colorsSizesScope() => '$_api/${_currentVersion}/mobile/$this';
  String cartScope() => '$_api/${_currentVersion}/cart/$this';
  String oldCartScope() => '$_api/${_currentVersion}/old-cart/$this';
  String searchScope() => '$_api/${_currentVersion}/products/$this';
  String notificationScope() =>
      '$_api/${_currentVersion}/product_notification/$this';
  String userNotificationScope() =>
      '$_api/${_currentVersion}/user-notifications/$this';
  String couponScope() => '$_api/${_currentVersion}/coupon/$this';
  String firebaseTokensScope({bool current = false}) =>
      '$_api/${_currentVersion}/firebase_device_tokens${this != '' ? '/$this' : ''}';
}

abstract class MarketEndPoints {
  static String getProductDetailWithoutSimilarRelatedProducts(
          String productId) =>
      "details_without_similar_related_products/$productId".productScope();

  ////
  static String getFullProductDetailsEP(String productId) =>
      "details/$productId".productScope();
  static final getColorsAndSizesForSearchEP =
      "get-colors-and-sizes".colorsSizesScope();
  static final deleteCustomerAddressEP = "address/delete".customerScope();
  static final updateCustomerAddressEP = "address/update".customerScope();
  static final addCustomerAddressEP = "address/add".customerScope();
  static final getCustomerAddressesEP = "address/list".customerScope();
  static final getOrderListEP = "order/list".customerScope();
  static final uploadUserPhotoModelEP = "storage-upload".storageScope();
  static final updateProfileEP = "update-profile".customerScope();
  static final setCustomerAddressDefaultEP =
      "address/set-default".customerScope();
  static final getCustomerWalletEP = "wallet/list".customerScope();

  static final getUserNotificationsEP = "get".userNotificationScope();

  static final getOrdersByOrderGroupEP =
      "order/getOrdersByOrderGroupID".customerScope();
  static final getOrdersByCartGroupEP =
      "order/getOrdersByCartGroupID".customerScope();

  static final cancelOrderItemEP = "order/cancel-item".customerScope();
  static final cancelOrderEP = "order/cancel".customerScope();
  static final changeOrderAddressEP = "order/change-address".customerScope();

  static String placeOrderEP(String paymentMethod) =>
      "order/checkout/$paymentMethod".customerScope();

  static final unsubscribeTopicEP = "unsubscribe_topic".firebaseTokensScope();
  static final subscribeTopicEP = "subscribe_topic".firebaseTokensScope();
  static final updateWhatsappEP = "update_whatsapp".firebaseTokensScope();
  static final updateFirebaseEP = "update_firebase".firebaseTokensScope();
  static final updateEmailEP = "update_email".firebaseTokensScope();
  static final updateNotificationFrequencyEP =
      "update_notification_frequency".firebaseTokensScope();
  static final changeCountryLanguageEP =
      "change_country_language".firebaseTokensScope();
  static final getMyFirebaseSettingsEP =
      "my_firebase_settings".firebaseTokensScope();
  static final sendErrorToMobileErrorLogEP = 'store'.errorScope();
  static final sendOtpEP = 'send_otp'.phoneScope();
  static final getCartItemEP = 'cart_shipping'.cartScope();
  static final getProductListInCartEP =
      'product_list_in_cart_and_old_cart'.cartScope();
  static final checkAvailabilityProductCartEP =
      'check_availability_product_cart'.cartScope();
  static final getCartOverviewEP = 'cart_overview'.cartScope();

  static final storeFcmOfMarketEP = 'firebase_device_tokens'.countryScope();
  static final getNotificationTypeForProductEP =
      'notification_types/customer-notification-to-choose'.webScope();
//******************************************** */
  static final getOldCartItemsEP = 'get_old_cart'.oldCartScope();
  static final hideItemsInOldCartEP = 'hide'.oldCartScope();
  static final convertItemInCartToOldCartEP = 'convert_to_old'.cartScope();
  static final addItemCartItemEP = 'add'.cartScope();
  static final updateItemCartItemEP = 'update'.cartScope();
  static final requestForNotificationWhenProductBecameAvailableEP =
      'store'.notificationScope();
  static final removeItemCartItemEP = 'remove'.cartScope();
  static final verifyOtpSignInEP = 'verify_otp_singin'.phoneScope();
  static final verifyOtpSignUpEP = 'verify_otp_signup'.phoneScope();
  static final verifyOtpInProfileEP = 'verify_otp'.phoneScope();
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

  static final applyCouponEP = 'apply'.couponScope();

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
