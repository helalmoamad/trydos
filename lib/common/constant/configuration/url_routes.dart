extension ScopeApi on String {
  String get _api => 'api';

  String get customerScope => '$_api/Customer/$this';
  String get basicRegistrationScope => '$_api/BasicRegistration/$this';
  String get cardScope => '$_api/Card/$this';
  String get cartScope => '$_api/Cart/$this';
  String get addressScope => '$_api/CustomerAddress/$this';
  String get productScope => '$_api/Product/$this';
  String get pioneerScope => '$_api/Pioneer/$this';
  String get pointsScope => '$_api/Points/$this';
  String get kitchenScope => '$_api/Kitchen/$this';
  String get reasonScope => '$_api/Reason/$this';
  String get searchWordScope => '$_api/SearchWord/$this';
  String get notificationScope => '$_api/Notification/$this';
  String get announcementScope => '$_api/Announcement/$this';
}

abstract class EndPoints {
  ///! ----< BasicRegistration >----
  ///
  static final customerAuthRegisterMobileNumberEP = 'RegisterMobileNumber'.basicRegistrationScope;
  static final customerRegisterVerificationCodeEP = 'RegisterVerficationCode'.basicRegistrationScope;

  ///! ----< Customer >----
  ///
  static final customerRegisterEP = 'Register'.customerScope;
  static final customerActionEP = 'AddCustomerFavoriteKitchens'.customerScope;
  static final editNameEP = 'UpdateUsername'.customerScope;
  static final editPhoneEP = 'UpdatePhoneNumber'.customerScope;
  static final getHomeDataEP = 'GetCustomerHomeData'.customerScope;
  static final getPioneerDetailsDataEP = 'GetPioneerProductWithDetails'.customerScope;
  static final getProfileDataEP = 'GetCustomerInformation'.customerScope;
  static final getFavoriteProductsEP = 'GetFavoritProducts'.customerScope;
  static final getFavoritePioneersEP = 'GetFavoritPioneers'.customerScope;
  static final addCustomerFavoriteKitchensEP = 'AddCustomerFavoriteKitchens'.customerScope;

  ///! ----< Cart >----
  ///
  static final addProductToCartEP = 'ActionCartToCustomer'.cartScope;
  static final removeProductFromCartEP = 'RemoveProductFromCart'.cartScope;
  static final clearCartEP = 'RemoveProductsFromCart'.cartScope;
  static final getCartInformationEP = 'Information'.cartScope;
  static final getDeleteAccountReasonsEP = 'GetAll'.reasonScope;
  static final deleteAccountEP = 'DeleteAccount'.customerScope;
  static final getSearchHistoryEP = 'GetSeachWord'.searchWordScope;
  static final removeSearchHistoryItemEP = 'RemovByIds'.searchWordScope;
  static final clearSearchHistoryEP = 'ClearHistory'.searchWordScope;

  ///! ----< Card >----
  ///
  static final addCardEP = 'ActionCardToCustomer'.cardScope;
  static final getAllCardEP = 'GetCardsToCustomer'.cardScope;
  static final deleteCardEP = 'RemoveCardToCustomer'.cardScope;

  ///! ----< Product >----
  ///
  static final getPioneerProductsEP = 'GetProducts'.productScope;
  static final makeProductFavoriteEP = 'ActionFavoriteProduct'.productScope;
  static final getProductDetailsEP = 'GetProductDetails'.productScope;

  ///! ----< CustomerAddress >----
  ///
  static final addAddressEP = 'CustomerAddressAction'.addressScope;
  static final getAllAddressEP = 'GetCustomerAddresses'.addressScope;
  static final deleteAddressEP = 'RemoveCustomerAddress'.addressScope;

  ///! ----< Kitchen >----
  ///
  static final kitchenGetAllKitchenEP = 'GetKitchensWithPagination'.kitchenScope;

  ///! ----< Announcement >----
  ///
  static final getAllAnnouncementEP = 'GetAll'.announcementScope;

  ///! ----< Notification >----
  ///
  static final getCustomerNotificationEP = 'GetCustomerNotification'.notificationScope;
  static final readNotificationEP = 'Read'.notificationScope;

  ///! ----< Pioneer >----
  ///
  static final makePioneerFavoriteEP = 'ActionFavoritePioneer'.pioneerScope;


  ///! ----< Points >----
  ///
  static final getCustomerPointsEP = 'GetCustomerPoints'.pointsScope;

}

abstract class Urls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static const String _baseUrlDev = 'http://100.24.7.52/';
}
