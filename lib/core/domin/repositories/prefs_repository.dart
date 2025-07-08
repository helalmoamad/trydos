import 'package:flutter/material.dart';

import '../../../features/chat/data/models/my_chats_response_model.dart';

abstract class PrefsRepository {
  String? get chatToken;
  String? get marketToken;
  String? get storiesToken;
  String? get countryIso;
  String? get userChoosedCountryIso;
  int? get fcmTokenId;
  String? get serverTime;
  int? get myChatId;

  int? get myStoriesId;
  int? get userCountryIsAvailable;

  String? get myMarketId;
  bool? get isLogInToChat;

  List<Message>? get getTheMessageFromBackground;
  List<String>? get getTheChatsIdsToRemoveFromBackground;
  List<String>? get getNotificationIdsToRemoveAfterplaceOrder;
  List<String>? get getImageUrlHasPrefeched;
  List<String>? get getTagsInUrlToFilter;
  String? get getNotificationTypeFromTerminated;
  List<Map>? get getTheRemovedMessageFromBackground;
  List<Map>? get getTheMessageWatchStatusFromBackground;
  List<Map>? get getTheMessageReceivedStatusFromBackground;

  List<Chat>? get getTheChatsToEditFromBackground;

  bool? get isTimerForOtpRunning;

  bool? get isVerifiedPhone;
  bool? get isFoundDataCashed;
  bool? get isVerifiedPhonePeforeExpiredToken;
  bool? get isTokenExpired;
  bool? get isRequestNotificationPermission;
  bool? get isSmartlookStarted;

  String? get myStoriesName;

  String? get myChatName;

  String? get myChatPhoto;
  String? get myProfilePhoto;
  String? get myMarketName;

  String? get getMarketUrl;
  String? get getStoryUrl;
  String? get getChatUrl;

  String? get myPhoneNumber;

  String? get currentEvent;
  String? get language;

  String? get verificationId;
  String? get sessionId;
  String? get otpCode;
  String? get idToken;
  int? get getdurtion;

  String? getPrefechOfMainCategoryInHomePage();
  Future<bool> setPrefechOfMainCategoryInHomePage(String value);
  Future<bool> removeMainCategoryWhenOpenApp();
  Future<bool> setNotificationIdsToRemoveAfterplaceOrder(String id);

  String? getPrefechOfBoutiquesForEachMainCategoryInHomePage(String key);
  Future<bool> setPrefechOfBoutiquesForEachMainCategoryInHomePage(
      String key, String value);
  Future<bool> removeMainCategoryHasPerfechedWhenOpenApp(bool allCategory);
  Future<bool> setIsFoundDataCashed(bool isFoundDataCashed);
  Future<bool> setMainCategoryHasPerfechedToRemoveItWhenOpenApp(String key);
  String? getPrefechOfProductsForEachBoutiqueInHomePage(String key);
  Future<bool> setPrefechOfProductsForEachBoutiqueInHomePage(
      String key, String value);
  Future<bool> setBoutiqueHasPerfechedToRemoveItWhenOpenApp(String key);
  Future<bool> removeBoutiqueHasPerfechedWhenOpenApp(bool allBoutique);
  List<String>? getFiveFilterForEachBoutiqueHasPrefechInHomePage();
  String? getPrefechForFiveFilterForEachBoutiqueInHomePage(String key);
  Future<bool> setPrefechForFiveFilterForEachBoutiqueInHomePage(
      String key, String value);
  Future<bool> setFiveFilterHasPerfechedToRemoveItWhenOpenApp(String key);
  Future<bool> removeFiveFilterHasPerfechedWhenOpenApp();

  Future<bool> setVerifiedPhone(bool verifiedPhone);
  Future<bool> setRequestNotificationPermission(
      bool requestNotificationPermission);
  Future<bool> setVerifiedPhonePeforeExpiredToken(
      bool verifiedPhonePeforeExpiredToken);
  Future<bool> setTokenExpired(bool tokenExpired);
  Future<bool> setTimerForOtpRunning(bool isRunning);
  Future<bool> setDuration(int duration);
  Future<bool> setLanguage(String? language);
  Future<bool> setNotificationTypesFromTerminated(
      String? notificationTypeFromTerminated);
  Future<bool> setCountryIso(String? countryIso);
  Future<bool> setImageUrlHasPrefeched(String? url);
  Future<bool> setUserChoosedCountryIso(String? countryIso);

  Future<bool> setVerificationId(String verificationId);
  Future<bool> setSessionId(String sessionId);

  Future<bool> setOtpCode(String otpToken);
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable);
  Future<bool> setChatToken(String token);

  Future<bool> setMarketToken(String? token);

  Future<bool> setStoriesToken(String token);

  Future<bool> setLogInToChat(bool isLogInToChat);

  Future<bool> setOnMessageRun(bool onMessageRun);

  Future<bool> setIsSmartlookStarted(bool isSmartlookStarted);

  Future<bool> setServerTime(DateTime serverTime);

  Future<bool> setMyChatName(String name);

  Future<bool> setMyStoriesName(String name);
  Future<bool> setMyProfilePhoto(String? photo);
  Future<bool> setMyChatPhoto(String? photo);

  Future<bool> setPhoneNumber(String phoneNumber);
  Future<bool> setIdToken(String idToken);
  Future<void> setFcmTokenId(int fcmTokenId);

  Future<bool> setMyChatId(int id);

  Future<bool> setMessageFromBackground(String message);
  Future<bool> setRemovedMessageFromBackground(String removedMessage);
  Future<bool> setRemovedChatFromBackground(String removedChatId);
  Future<bool> setMessageWatchStatusFromBackground(String MessageStatus);
  Future<bool> setMessageReceivedStatusFromBackground(String MessageStatus);

  Future<bool> setChatToEditFromBackground(String chat);

  Future<bool> setMyStoriesId(int id);

  Future<bool> setMarketUrl(String url);
  Future<bool> setStoryUrl(String url);
  Future<bool> setChatUrl(String url);

  Future<bool> setMyMarketId(String id);

  Future<bool> setMyMarketName(String name);
  Future<bool> setCurrentEvent(String currentEvent);
  Future<bool> removeCurrentEvent();

  Future<bool> setViewedProducts(String productId);
  Future<bool> clear();
  List<String> getviewedProductsProducts();
  Future<bool> removeViewedProducts();
  Future<bool> removeNotificationIdsToRemoveAfterplaceOrder();
  List<String> topicThatAlreadySubsecribed();
  Future<bool> setViewedBoutiques(String boutiqueId);
  Future<bool> setTagsInUrlToFilter(List<String> tags);
  List<String> getviewedProductsBoutiques();
  Future<bool> removeViewedBoutiques();

  Future<bool> setTheme(ThemeMode themeMode);

  Future<bool> setAFilePathExist(String filePath, String chatId);
  Future<bool> removeAFilePathExist(String filePath, String chatId);
  Future<bool> removeAllFilePathExistInChat(String chatId);
  Future<bool> setTopicThatAlreadySubsecribed(String topic);
  Future<bool> removeTopicThatAlreadySubsecribed(String topic);
  List<String> getExistenceFiles();
  List<String>? getTheLocalPathForChannel(String chatId);
  bool isAFilePathExist(String filePath, String chatId);

  String? getTheLocalPathForFile(String filePath, String chatId);

  Future<bool> addFcmToken(String fcmToken);

  List<String> get getFcmTokens;

  // Future<bool> setUser(User user);
  //
  // User? get user;

  Future<bool> clearUser();
  bool? get onMessageRun;
  Future<bool> removeStoriesName();

  Future<bool> clearTokensForChatAndStory();

  Future<bool> clearTokenForMarket();

  Future<bool> removeMessageFromBackground();
  Future<bool> removeChatsFromBackground();
  Future<bool> removeRemovedMessageFromBackground();
  Future<bool> removeMessageWatchStatusFromBackground();
  Future<bool> removeMessageReceivedStatusFromBackground();

  Future<bool> removeChatToEditFromBackground();

  Future<bool> clearVerificationId();

  ThemeMode get getTheme;

  bool get registeredToChat;

  void saveRequestsData(
      String? url,
      Map<String, dynamic>? response,
      Map<String, dynamic>? headers,
      int? statusCode,
      String? request,
      Map<String, dynamic>? query,
      Map<String, dynamic>? body,
      {String? error,
      String? responseTime});

  void clearAllRequests();

  void removeRequestFromCache(Map<String, dynamic> request);

  List<Map<String, dynamic>> getRequestsData();

  Future<bool> setOrderCoupon(String coupon);
  String getOrderCoupon();
  Future<bool> removeOrderCoupon();
}
