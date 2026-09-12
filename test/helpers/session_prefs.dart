import 'network_harness.dart';

/// Test ledger · wave 02 Account and session — the stored-session fake.
///
/// [FakePrefs] covers what the network layer reads. The account flows write far
/// more than they read: four tokens, four refresh tokens, three identities, the
/// phone, the profile photo and a handful of flags. This subclass keeps all of
/// that in plain fields.
///
/// Every token has its **own field**, exactly as the real repository gives each
/// one its own key. That is the point of the wave gate: a bug that writes the
/// chat token into the market slot must show up here as the wrong field
/// changing, not as "a token was stored".
class SessionPrefs extends FakePrefs {
  // ---------------------------------------------------------------- tokens
  /// The refresh token of each server, under its own name.
  String? marketRefreshTokenValue;
  String? chatRefreshTokenValue;
  String? storiesRefreshTokenValue;
  String? commentRefreshTokenValue;

  @override
  Future<bool> setMarketToken(String? token) async {
    marketTokenValue = token ?? '';
    return true;
  }

  @override
  Future<bool> setChatToken(String token) async {
    chatTokenValue = token;
    return true;
  }

  @override
  Future<bool> setStoriesToken(String token) async {
    storiesTokenValue = token;
    return true;
  }

  @override
  Future<bool> setTokenForComment(String token) async {
    commentTokenValue = token;
    return true;
  }

  @override
  Future<bool> setWalletToken(String token) async {
    walletTokenValue = token;
    walletTokenSetTo = token;
    return true;
  }

  @override
  Future<bool> setMarketRefreshToken(String? token) async {
    marketRefreshTokenValue = token ?? '';
    return true;
  }

  @override
  Future<String?> getMarketRefreshToken() async => marketRefreshTokenValue;

  @override
  Future<bool> setChatRefreshToken(String? token) async {
    chatRefreshTokenValue = token ?? '';
    return true;
  }

  @override
  Future<String?> getChatRefreshToken() async => chatRefreshTokenValue;

  @override
  Future<bool> setStoriesRefreshToken(String? token) async {
    storiesRefreshTokenValue = token ?? '';
    return true;
  }

  @override
  Future<String?> getStoriesRefreshToken() async => storiesRefreshTokenValue;

  @override
  Future<bool> setCommentRefreshToken(String? token) async {
    commentRefreshTokenValue = token ?? '';
    return true;
  }

  @override
  Future<String?> getCommentRefreshToken() async => commentRefreshTokenValue;

  // -------------------------------------------------------------- identity
  String? myMarketNameValue;
  int? myChatIdValue;
  String? myChatNameValue;
  String? myChatPhotoValue;
  int? myStoriesIdValue;
  String? myStoriesNameValue;
  String? myProfilePhotoValue;
  String? idTokenValue;
  String? otpCodeValue;
  String? verificationIdValue;

  @override
  Future<bool> setMyMarketId(String id) async {
    myMarketIdValue = id;
    return true;
  }

  @override
  String? get myMarketName => myMarketNameValue;

  @override
  Future<bool> setMyMarketName(String name) async {
    myMarketNameValue = name;
    return true;
  }

  @override
  int? get myChatId => myChatIdValue;

  @override
  Future<bool> setMyChatId(int id) async {
    myChatIdValue = id;
    return true;
  }

  @override
  String? get myChatName => myChatNameValue;

  @override
  Future<bool> setMyChatName(String name) async {
    myChatNameValue = name;
    return true;
  }

  @override
  String? get myChatPhoto => myChatPhotoValue;

  @override
  Future<bool> setMyChatPhoto(String? photo) async {
    myChatPhotoValue = photo;
    return true;
  }

  @override
  int? get myStoriesId => myStoriesIdValue;

  @override
  Future<bool> setMyStoriesId(int id) async {
    myStoriesIdValue = id;
    return true;
  }

  @override
  String? get myStoriesName => myStoriesNameValue;

  @override
  Future<bool> setMyStoriesName(String name) async {
    myStoriesNameValue = name;
    return true;
  }

  @override
  String? get myProfilePhoto => myProfilePhotoValue;

  @override
  Future<bool> setMyProfilePhoto(String? photo) async {
    myProfilePhotoValue = photo;
    return true;
  }

  @override
  Future<bool> setPhoneNumber(String phoneNumber) async {
    phoneNumberValue = phoneNumber;
    return true;
  }

  @override
  String? get idToken => idTokenValue;

  @override
  Future<bool> setIdToken(String idToken) async {
    idTokenValue = idToken;
    return true;
  }

  @override
  String? get otpCode => otpCodeValue;

  @override
  Future<bool> setOtpCode(String otpToken) async {
    otpCodeValue = otpToken;
    return true;
  }

  @override
  String? get verificationId => verificationIdValue;

  @override
  Future<bool> setVerificationId(String verificationId) async {
    verificationIdValue = verificationId;
    return true;
  }

  @override
  Future<bool> clearVerificationId() async {
    verificationIdValue = null;
    return true;
  }

  // ----------------------------------------------------------------- flags
  bool? isVerifiedPhoneValue;
  bool? isLogInToChatValue;
  bool? isCreateWalletValue;
  String? languageValue;
  String? fcmTokenIdValue;
  String? fcmMarketTokenIdValue;
  bool? isTimerForOtpRunningValue;
  int? otpTimerEndTimeValue;

  /// The stored device tokens.
  ///
  /// The real `addFcmToken` **replaces** the whole list with the one token it
  /// was given — it does not append, despite the name. `addFcmToken('')` is how
  /// logging out clears it, and it leaves a list holding one empty string, not
  /// an empty list. The fake copies that, or a test would pass here and fail on
  /// a device.
  final List<String> fcmTokens = <String>[];

  @override
  bool? get isVerifiedPhone => isVerifiedPhoneValue;

  @override
  Future<bool> setVerifiedPhone(bool verifiedPhone) async {
    isVerifiedPhoneValue = verifiedPhone;
    return true;
  }

  @override
  bool? get isLogInToChat => isLogInToChatValue;

  @override
  Future<bool> setLogInToChat(bool isLogInToChat) async {
    isLogInToChatValue = isLogInToChat;
    return true;
  }

  @override
  bool? get isCreateWallet => isCreateWalletValue;

  @override
  Future<bool> setIsCearteWallet(bool isCreate) async {
    isCreateWalletValue = isCreate;
    return true;
  }

  @override
  String? get language => languageValue;

  @override
  Future<bool> setLanguage(String? language) async {
    languageValue = language;
    return true;
  }

  @override
  String? get fcmTokenId => fcmTokenIdValue;

  @override
  Future<void> setFcmTokenId(String fcmTokenId) async {
    fcmTokenIdValue = fcmTokenId;
  }

  @override
  String? get fcmMarketTokenId => fcmMarketTokenIdValue;

  @override
  Future<void> setFcmMarketTokenId(String fcmMarketTokenId) async {
    fcmMarketTokenIdValue = fcmMarketTokenId;
  }

  @override
  List<String> get getFcmTokens => fcmTokens;

  @override
  Future<bool> addFcmToken(String fcmToken) async {
    fcmTokens
      ..clear()
      ..add(fcmToken);
    return true;
  }

  @override
  bool? get isTimerForOtpRunning => isTimerForOtpRunningValue;

  @override
  Future<bool> setTimerForOtpRunning(bool isRunning) async {
    isTimerForOtpRunningValue = isRunning;
    return true;
  }

  @override
  int? get otpTimerEndTime => otpTimerEndTimeValue;

  @override
  Future<bool> setOtpTimerEndTime(int endTime) async {
    otpTimerEndTimeValue = endTime;
    return true;
  }

  @override
  Future<bool> removeOtpTimerEndTime() async {
    otpTimerEndTimeValue = null;
    return true;
  }

  // -------------------------------------------------------------- location
  @override
  Future<bool> setCountryIso(String? countryIso) async {
    countryIsoValue = countryIso;
    return true;
  }

  @override
  Future<bool> setUserChoosedCountryIso(String? countryIso) async {
    userChoosedCountryIsoValue = countryIso;
    return true;
  }

  @override
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable) async {
    userCountryIsAvailableValue = userCountryAvailable;
    return true;
  }

  @override
  Future<bool> setXSellerId(String id) async {
    xSellerIdValue = id;
    return true;
  }

  // ------------------------------------------------------ catalogue cache
  // Wave 03. The home screen paints from a prefetch kept in preferences — the
  // main categories, each category's boutiques, each boutique's first page —
  // and only then asks the network. Each cache has its own field here, the way
  // the real repository gives each its own key, so a test can tell which one
  // was written and which one was wiped.

  /// The main-category list, as the last successful load stored it.
  String? mainCategoriesPrefetchValue;

  /// Each main category's boutiques, keyed by category slug.
  final Map<String, String> boutiquesPrefetch = <String, String>{};

  /// Each boutique's first page of products, keyed by boutique slug + category.
  final Map<String, String> productsPrefetch = <String, String>{};

  /// The first five filters of each boutique, keyed the same way.
  final Map<String, String> fiveFiltersPrefetch = <String, String>{};

  /// Image urls already warmed, so they are not fetched twice.
  final List<String> prefetchedImageUrls = <String>[];

  /// Tags taken from a deep link, which narrow every listing request.
  List<String>? tagsInUrlToFilterValue;

  /// Which of the "remove on next open" wipes ran, in order.
  final List<String> cacheWipes = <String>[];

  @override
  String? getPrefechOfMainCategoryInHomePage() => mainCategoriesPrefetchValue;

  @override
  Future<bool> setPrefechOfMainCategoryInHomePage(String value) async {
    mainCategoriesPrefetchValue = value;
    return true;
  }

  @override
  String? getPrefechOfBoutiquesForEachMainCategoryInHomePage(String key) =>
      boutiquesPrefetch[key];

  @override
  Future<bool> setPrefechOfBoutiquesForEachMainCategoryInHomePage(
    String key,
    String value,
  ) async {
    boutiquesPrefetch[key] = value;
    return true;
  }

  @override
  String? getPrefechOfProductsForEachBoutiqueInHomePage(String key) =>
      productsPrefetch[key];

  @override
  Future<bool> setPrefechOfProductsForEachBoutiqueInHomePage(
    String key,
    String value,
  ) async {
    productsPrefetch[key] = value;
    return true;
  }

  @override
  List<String>? getFiveFilterForEachBoutiqueHasPrefechInHomePage() =>
      fiveFiltersPrefetch.keys.toList();

  @override
  String? getPrefechForFiveFilterForEachBoutiqueInHomePage(String key) =>
      fiveFiltersPrefetch[key];

  @override
  Future<bool> setPrefechForFiveFilterForEachBoutiqueInHomePage(
    String key,
    String value,
  ) async {
    fiveFiltersPrefetch[key] = value;
    return true;
  }

  @override
  List<String>? get getImageUrlHasPrefeched => prefetchedImageUrls;

  @override
  Future<bool> setImageUrlHasPrefeched(String? url) async {
    if (url != null) prefetchedImageUrls.add(url);
    return true;
  }

  @override
  List<String>? get getTagsInUrlToFilter => tagsInUrlToFilterValue;

  @override
  Future<bool> setMainCategoryHasPerfechedToRemoveItWhenOpenApp(
    String key,
  ) async =>
      true;

  @override
  Future<bool> setBoutiqueHasPerfechedToRemoveItWhenOpenApp(String key) async =>
      true;

  @override
  Future<bool> setFiveFilterHasPerfechedToRemoveItWhenOpenApp(
    String key,
  ) async =>
      true;

  @override
  Future<bool> removeMainCategoryWhenOpenApp() async {
    cacheWipes.add('mainCategories');
    mainCategoriesPrefetchValue = null;
    return true;
  }

  @override
  Future<bool> removeMainCategoryHasPerfechedWhenOpenApp(
    bool allCategory,
  ) async {
    cacheWipes.add('boutiquesOfEachCategory');
    boutiquesPrefetch.clear();
    return true;
  }

  @override
  Future<bool> removeBoutiqueHasPerfechedWhenOpenApp(bool allBoutique) async {
    cacheWipes.add('productsOfEachBoutique');
    productsPrefetch.clear();
    return true;
  }

  @override
  Future<bool> removeFiveFilterHasPerfechedWhenOpenApp() async {
    cacheWipes.add('fiveFiltersOfEachBoutique');
    fiveFiltersPrefetch.clear();
    return true;
  }

  /// The server-clock offset analytics stamps its events with. Every catalogue
  /// success fires an analytics event, which reads this; unanswered, the
  /// service's own `try` swallowed the throw and the test passed *through* a
  /// caught exception. No offset is the fresh-install value.
  @override
  int? get getdurtion => null;

  // ------------------------------------------------------------- diagnostics
  /// The request log the error reporter reads to attach "the last call before
  /// the crash". Empty is a valid state — it is what a fresh install has — and
  /// nothing in wave 02 asserts on it; it only has to answer.
  @override
  List<Map<String, dynamic>> getRequestsData() => <Map<String, dynamic>>[];
}
