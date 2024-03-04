import 'package:flutter/material.dart';

import '../../../features/chat/data/models/my_chats_response_model.dart';

abstract class PrefsRepository {
  String? get chatToken;
  String? get marketToken;
  String? get storiesToken;
  String? get countryName;
  int? get fcmTokenId;

  int? get myChatId;

  int? get myStoriesId;

  String? get myMarketId;

  List<Message>? get getTheMessageFromBackground;

  bool? get isVerifiedPhone;

  String? get myChatName;

  String? get myChatPhoto;

  String? get myMarketName;

  String? get myPhoneNumber;

  String? get verificationId;

  String? get otpCode;

  Future<bool> setVerifiedPhone(bool verifiedPhone);
  Future<bool> setCountryName(String? countryName);

  Future<bool> setVerificationId(String verificationId);

  Future<bool> setOtpCode(String otpToken);

  Future<bool> setChatToken(String token);

  Future<bool> setMarketToken(String token);

  Future<bool> setStoriesToken(String token);

  Future<bool> setMyChatName(String name);

  Future<bool> setMyChatPhoto(String? photo);

  Future<bool> setPhoneNumber(String phoneNumber);

  Future<void> setFcmTokenId(int fcmTokenId);

  Future<bool> setMyChatId(int id);

  Future<bool> setMessageFromBackground(String message);

  Future<bool> setMyStoriesId(int id);

  Future<bool> setMyMarketId(String id);

  Future<bool> setMyMarketName(String name);

  Future<bool> setTheme(ThemeMode themeMode);

  Future<bool> setAFilePathExist(String filePath);
  Future<bool> removeAFilePathExist(String filePath);

  List<String> getExistenceFiles();

  bool isAFilePathExist(String filePath);

  String? getTheLocalPathForFile(String filePath);

  Future<bool> addFcmToken(String fcmToken);

  List<String> get getFcmTokens;

  // Future<bool> setUser(User user);
  //
  // User? get user;

  Future<bool> clearUser();

  Future<bool> removeMessageFromBackground();

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
      {String? error , String? responseTime});

  void clearAllRequests();

  void removeRequestFromCache(Map<String, dynamic> request);

  List<Map<String, dynamic>> getRequestsData();

}
