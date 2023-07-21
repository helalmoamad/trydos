import 'package:flutter/material.dart';


abstract class PrefsRepository {
  String? get token;

  int? get fcmTokenId;

  int? get myId;


  Future<bool> setToken(String token);

  Future<void> setFcmTokenId(int fcmTokenId);

  Future<bool> setMyId(int id);

  Future<bool> setTheme(ThemeMode themeMode);




  // Future<bool> setUser(User user);
  //
  // User? get user;

  Future<bool> clearUser();

  ThemeMode get getTheme;

  bool get registeredUser;

  void saveRequestsData(
      String url,
      Map<String, dynamic> response,
      Map<String, dynamic> headers,
      int? statusCode,
      String request,
      Map<String, dynamic>? query,
      Map<String, dynamic>? body);

  void clearAllRequests();

  void removeRequestFromCache(Map<String, dynamic> request);

  List<Map<String, dynamic>> getRequestsData();
}
