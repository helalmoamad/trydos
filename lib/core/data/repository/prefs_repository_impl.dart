import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constant/configuration/prefs_key.dart';
import '../../../config/theme/app_theme.dart';
import '../../domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;


class PrefsRepositoryImpl extends PrefsRepository {
  PrefsRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<bool> setChatToken(String token) => _preferences.setString(PrefsKey.chatToken, token);

  @override
  String? get chatToken => _preferences.getString(PrefsKey.chatToken);

  @override
  String? get marketToken => _preferences.getString(PrefsKey.marketToken);

  @override
  Future<bool> setMarketToken(String token) => _preferences.setString(PrefsKey.marketToken, token);

  @override
  Future<bool> setStoriesToken(String token) => _preferences.setString(PrefsKey.storiesToken, token);

  @override
  String? get storiesToken => _preferences.getString(PrefsKey.storiesToken);

  @override
  ThemeMode get getTheme {
    final res = _preferences.getString(PrefsKey.theme);
    if (res == null) {
      setTheme(defaultAppTheme);
      return defaultAppTheme;
    }
    return defaultAppTheme;
    //return mapAppThemeMode[res]!;
  }

  @override
  Future<bool> setTheme(ThemeMode themeMode) => _preferences.setString(PrefsKey.theme, themeMode.name);

  @override
  Future<bool> clearUser() async {
    await _preferences.remove(PrefsKey.chatToken);
    await _preferences.remove(PrefsKey.marketToken);
    await _preferences.remove(PrefsKey.storiesToken);
    return _preferences.remove(PrefsKey.user);
  }

  @override
  bool get registeredToChat => chatToken != null;

  @override
  void saveRequestsData(
      String? url,
      Map<String, dynamic>? response,
      Map<String, dynamic>? headers,
      int? statusCode,
      String? request,
      Map<String, dynamic>? query,
      Map<String, dynamic>? body,
  {String? error}
      ) {
    Map<String, dynamic> requestAndResponse ;
    if(error == null || error == 'null' || error == ''){
      requestAndResponse={
        'url': url,
        'request': request,
        'response': response,
        'headers': headers,
        'query': query,
        'body': body,
        'statusCode': statusCode
      };
    }else{
      requestAndResponse={
        'flutter_error': error,
      };
    }
    List<Map<String, dynamic>> previousRequests = getRequestsData();
    if (previousRequests.length == 80) {
      previousRequests.removeAt(0);
    }
    previousRequests.add(requestAndResponse);
    _preferences.setString(
        'requests_json',
         convert.jsonEncode({'requests_data': previousRequests}));
  }
  @override
  clearAllRequests(){
    _preferences.setString(
         'requests_json',
         convert.jsonEncode({'requests_data': []}));
  }
  @override
  removeRequestFromCache(Map<String,dynamic> request) {
    String? requestsJson = _preferences.getString('requests_json');
    if (requestsJson == null) {
      return ;
    }
    Map<String, dynamic> data = convert.jsonDecode(requestsJson);
    var list= List<Map<String, dynamic>>.from(data['requests_data']!.map((x) => x));
    list.remove(request);
    _preferences.setString(
        'requests_json',
        convert.jsonEncode({'requests_data': list}));
  }
  @override
  List<Map<String, dynamic>> getRequestsData() {
    String? requestsJson = _preferences.getString('requests_json');
    if (requestsJson == null) {
      return [];
    }
    Map<String, dynamic> data = convert.jsonDecode(requestsJson);
    return List<Map<String, dynamic>>.from(data['requests_data']!.map((x) => x));
  }

  @override
  Future<bool> setMyChatId(int id) => _preferences.setInt(PrefsKey.userChatId, id);

  @override
  int? get myChatId => _preferences.getInt(PrefsKey.userChatId);
  @override
  String? get myChatName => _preferences.getString(PrefsKey.chatName);


  @override
  int? get fcmTokenId => _preferences.getInt(PrefsKey.fcmTokenId);

  @override
  Future<bool> setFcmTokenId(int fcmTokenId) => _preferences.setInt(PrefsKey.fcmTokenId, fcmTokenId);

  @override
  Future<bool> setMyChatName(String name) => _preferences.setString(PrefsKey.chatName, name);

  @override
  // TODO: implement myPhoneNumber
  String? get myPhoneNumber => _preferences.getString(PrefsKey.phoneNumber);

  @override
  Future<bool> setPhoneNumber(String phoneNumber) => _preferences.setString(PrefsKey.phoneNumber, phoneNumber);

  @override
  Future<bool> clearVerificationId() => _preferences.remove(PrefsKey.verificationId);

  @override
  Future<bool> setVerificationId(String verificationId) => _preferences.setString(PrefsKey.verificationId, verificationId);

  @override
  String? get verificationId => _preferences.getString(PrefsKey.verificationId);


  @override
  int? get myStoriesId => _preferences.getInt(PrefsKey.userStoriesId);

  @override
  Future<bool> setMyStoriesId(int id) => _preferences.setInt(PrefsKey.userStoriesId, id);

  @override
  String? get otpCode => _preferences.getString(PrefsKey.otpCode);

  @override
  Future<bool> setOtpCode(String otpCode) => _preferences.setString(PrefsKey.otpCode, otpCode);

  @override
  bool? get isVerifiedPhone => _preferences.getBool(PrefsKey.verifiedPhone);

  @override
  Future<bool> setVerifiedPhone(bool verifiedPhone) => _preferences.setBool(PrefsKey.verifiedPhone, verifiedPhone);

  @override
  List<String> getExistenceFiles() => _preferences.getStringList(PrefsKey.existenceFiles) ?? [];

  @override
  bool isAFilePathExist(String filePath) {
    List<String> files = getExistenceFiles();
    return files.contains(filePath);
  }

  @override
  Future<bool> setAFilePathExist(String filePath) {
    List<String> files = getExistenceFiles();
    files.add(filePath);
    return _preferences.setStringList(PrefsKey.existenceFiles , files);
  }

  @override
  // TODO: implement deviceIp
  String? get countryName => _preferences.getString('countryName');

  @override
  Future<bool> setCountryName(String? countryName) =>_preferences.setString('countryName', countryName!);






  // @override
  // // TODO: implement localMessages
  // List<Map<String,dynamic>> get localMessages {
  //   String? messages = _preferences.getString(PrefsKey.messages);
  //   if (messages == null) {
  //     return [];
  //   }
  //   Map<String, dynamic> data = convert.jsonDecode(messages);
  //   return List<Map<String, dynamic>>.from(data['messages']!.map((x) => x));
  // }

  // @override
  // void saveMessage(Map<String,dynamic> message) {
  //   List<Map<String, dynamic>> messages = localMessages ;
  //   messages.insert(0 , message);
  //   _preferences.setString(
  //       'messages',
  //       convert.jsonEncode({'messages': messages}));
  // }

  // @override
  // void clearAllMessages() => _preferences.remove(PrefsKey.messages);

  // @override
  // User? get user {
  //   final user = _preferences.getString(PrefsKey.user);
  //   if (user == null) {
  //     return null;
  //   }
  //   return User.fromJson(json.decode(user));
  // }
  //
  // @override
  // Future<bool> setUser(User user) async {
  //   if(user.bearerToken != null) {
  //     await _setToken(user.bearerToken!);
  //   }
  //
  //   return _preferences.setString(PrefsKey.user, json.encode(user));
  // }

  // @override
  // bool get hasUser => user != null;
}
