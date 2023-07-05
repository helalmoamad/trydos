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
  Future<bool> setToken(String token) => _preferences.setString(PrefsKey.token, token);

  @override
  String? get token => _preferences.getString(PrefsKey.token);

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
    await _preferences.remove(PrefsKey.token);
    return _preferences.remove(PrefsKey.user);
  }

  @override
  bool get registeredUser => token != null;

  @override
  void saveRequestsData(
      String url,
      Map<String, dynamic> response,
      Map<String, dynamic> headers,
      int? statusCode,
      String request,
      Map<String, dynamic>? query,
      Map<String, dynamic>? body) {
    Map<String, dynamic> requestAndResponse = {
      'url': url,
      'request': request,
      'response': response,
      'headers': headers,
      'query': query,
      'body': body,
      'statusCode': statusCode
    };
    List<Map<String, dynamic>> previousRequests = getRequestsData();
    if (previousRequests.length == 60) {
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
  Future<bool> setUserId(int id) => _preferences.setString(PrefsKey.userId, id.toString());

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
