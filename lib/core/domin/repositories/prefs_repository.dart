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

  List<Message>? get getTheMessageFromBackground;
  List<String>? get getTheChatsIdsToRemoveFromBackground;
  List<Map>? get getTheRemovedMessageFromBackground;
  List<Map>? get getTheMessageWatchStatusFromBackground;
  List<Map>? get getTheMessageReceivedStatusFromBackground;

  List<Chat>? get getTheChatsToEditFromBackground;

  bool? get isTimerForOtpRunning;

  bool? get isVerifiedPhone;

  String? get myStoriesName;

  String? get myChatName;

  String? get myChatPhoto;

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
  int? get getdurtion;
  Future<bool> setVerifiedPhone(bool verifiedPhone);
  Future<bool> setTimerForOtpRunning(bool isRunning);
  Future<bool> setDuration(int duration);
  Future<bool> setLanguage(String? language);
  Future<bool> setCountryIso(String? countryIso);
  Future<bool> setUserChoosedCountryIso(String? countryIso);

  Future<bool> setVerificationId(String verificationId);
  Future<bool> setSessionId(String sessionId);

  Future<bool> setOtpCode(String otpToken);
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable);
  Future<bool> setChatToken(String token);

  Future<bool> setMarketToken(String token);

  Future<bool> setStoriesToken(String token);

  Future<bool> setServerTime(DateTime serverTime);

  Future<bool> setMyChatName(String name);

  Future<bool> setMyStoriesName(String name);

  Future<bool> setMyChatPhoto(String? photo);

  Future<bool> setPhoneNumber(String phoneNumber);

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
  List<String> getviewedProductsProducts();
  Future<bool> removeViewedProducts();

  Future<bool> setViewedBoutiques(String boutiqueId);
  List<String> getviewedProductsBoutiques();
  Future<bool> removeViewedBoutiques();

  Future<bool> setTheme(ThemeMode themeMode);

  Future<bool> setAFilePathExist(String filePath, String chatId);
  Future<bool> removeAFilePathExist(String filePath, String chatId);
  Future<bool> removeAllFilePathExistInChat(String chatId);

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
}
