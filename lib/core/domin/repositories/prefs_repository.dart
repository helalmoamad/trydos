import 'package:flutter/material.dart';

abstract class PrefsRepository {
  String? get chatToken;
  String? get marketToken;
  String? get storiesToken;

  int? get fcmTokenId;

  int? get myChatId;

  int? get myStoriesId;

  bool? get isVerifiedPhone;

  String? get myChatName;

  String? get myPhoneNumber;

  String? get verificationId;

  String? get otpCode;

  Future<bool> setVerifiedPhone(bool verifiedPhone);

  Future<bool> setVerificationId(String verificationId);

  Future<bool> setOtpCode(String otpToken);

  Future<bool> setChatToken(String token);

  Future<bool> setMarketToken(String token);

  Future<bool> setStoriesToken(String token);

  Future<bool> setMyChatName(String name);

  Future<bool> setPhoneNumber(String phoneNumber);

  Future<void> setFcmTokenId(int fcmTokenId);

  Future<bool> setMyChatId(int id);

  Future<bool> setMyStoriesId(int id);

  Future<bool> setTheme(ThemeMode themeMode);

  Future<bool> setAFilePathExist(String filePath);

  List<String> getExistenceFiles();

  bool isAFilePathExist(String filePath);

  // Future<bool> setUser(User user);
  //
  // User? get user;

  Future<bool> clearUser();

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
      {String? error});

  void clearAllRequests();

  void removeRequestFromCache(Map<String, dynamic> request);

  List<Map<String, dynamic>> getRequestsData();

}
