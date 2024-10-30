import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import '../../../../common/constant/configuration/prefs_key.dart';
import '../../../config/theme/app_theme.dart';
import '../../domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;

class PrefsRepositoryImpl extends PrefsRepository {
  PrefsRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<bool> setChatToken(String token) =>
      _preferences.setString(PrefsKey.chatToken, token);

  @override
  String? get chatToken => _preferences.getString(PrefsKey.chatToken);

  @override
  Future<bool> setUserChoosedCountryIso(String? countryIso) =>
      _preferences.setString(PrefsKey.currentCountry, countryIso!);

  @override
  String? get userChoosedCountryIso =>
      _preferences.getString(PrefsKey.currentCountry);

  @override
  String? get marketToken => _preferences.getString(PrefsKey.marketToken);

  @override
  Future<bool> setMarketToken(String token) =>
      _preferences.setString(PrefsKey.marketToken, token);

  @override
  Future<bool> setStoriesToken(String token) =>
      _preferences.setString(PrefsKey.storiesToken, token);

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
  Future<bool> setTheme(ThemeMode themeMode) =>
      _preferences.setString(PrefsKey.theme, themeMode.name);

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
      {String? error,
      String? responseTime}) {
    Map<String, dynamic> requestAndResponse;
    if (error == null || error == 'null' || error == '') {
      requestAndResponse = {
        'url': url,
        'request': request,
        'response': response,
        'headers': headers,
        'query': query,
        'body': body,
        'statusCode': statusCode,
        'response_time': responseTime
      };
    } else {
      requestAndResponse = {
        'flutter_error': error,
      };
    }
    List<Map<String, dynamic>> previousRequests = getRequestsData();
    if (previousRequests.length == 80) {
      previousRequests.removeAt(0);
    }
    previousRequests.add(requestAndResponse);
    _preferences.setString('requests_json',
        convert.jsonEncode({'requests_data': previousRequests}));
  }

  @override
  clearAllRequests() {
    _preferences.setString(
        'requests_json', convert.jsonEncode({'requests_data': []}));
  }

  @override
  removeRequestFromCache(Map<String, dynamic> request) {
    String? requestsJson = _preferences.getString('requests_json');
    if (requestsJson == null) {
      return;
    }
    Map<String, dynamic> data = convert.jsonDecode(requestsJson);
    var list =
        List<Map<String, dynamic>>.from(data['requests_data']!.map((x) => x));
    list.remove(request);
    _preferences.setString(
        'requests_json', convert.jsonEncode({'requests_data': list}));
  }

  @override
  List<Map<String, dynamic>> getRequestsData() {
    String? requestsJson = _preferences.getString('requests_json');
    if (requestsJson == null) {
      return [];
    }
    Map<String, dynamic> data = convert.jsonDecode(requestsJson);
    return List<Map<String, dynamic>>.from(
        data['requests_data']!.map((x) => x));
  }

  @override
  Future<bool> setMyChatId(int id) =>
      _preferences.setInt(PrefsKey.userChatId, id);

  @override
  int? get myChatId => _preferences.getInt(PrefsKey.userChatId);

  @override
  String? get myChatName => _preferences.getString(PrefsKey.chatName);

  @override
  int? get fcmTokenId => _preferences.getInt(PrefsKey.fcmTokenId);

  @override
  Future<bool> setFcmTokenId(int fcmTokenId) =>
      _preferences.setInt(PrefsKey.fcmTokenId, fcmTokenId);

  @override
  Future<bool> setMyChatName(String name) =>
      _preferences.setString(PrefsKey.chatName, name);

  @override
  // TODO: implement myPhoneNumber
  String? get myPhoneNumber => _preferences.getString(PrefsKey.phoneNumber);

  @override
  Future<bool> setPhoneNumber(String phoneNumber) =>
      _preferences.setString(PrefsKey.phoneNumber, phoneNumber);

  @override
  Future<bool> clearVerificationId() =>
      _preferences.remove(PrefsKey.verificationId);

  @override
  Future<bool> setVerificationId(String verificationId) =>
      _preferences.setString(PrefsKey.verificationId, verificationId);

  @override
  String? get verificationId => _preferences.getString(PrefsKey.verificationId);

  @override
  int? get myStoriesId => _preferences.getInt(PrefsKey.userStoriesId);

  @override
  Future<bool> setMyStoriesId(int id) =>
      _preferences.setInt(PrefsKey.userStoriesId, id);

  @override
  String? get otpCode => _preferences.getString(PrefsKey.otpCode);

  @override
  Future<bool> setOtpCode(String otpCode) =>
      _preferences.setString(PrefsKey.otpCode, otpCode);

  @override
  bool? get isVerifiedPhone => _preferences.getBool(PrefsKey.verifiedPhone);

  @override
  Future<bool> setVerifiedPhone(bool verifiedPhone) =>
      _preferences.setBool(PrefsKey.verifiedPhone, verifiedPhone);

  @override
  List<String> getExistenceFiles() =>
      _preferences.getStringList(PrefsKey.existenceFiles) ?? [];

  @override
  bool isAFilePathExist(String filePath, String chatId) {
    List<String> files = getExistenceFiles();
    String path = files.firstWhere(
        (element) => (element.contains(filePath.split(" ")[0]) &&
            element.contains('"${chatId}"' + ":")),
        orElse: () => '');
    return path != '';
  }

  @override
  Future<bool> setAFilePathExist(String filePath, String chatId) {
    List<String> files = getExistenceFiles();
    if (!isAFilePathExist(filePath, chatId)) {
      filePath = convert.jsonEncode({chatId: filePath});
      files.add(filePath);
    }

    return _preferences.setStringList(PrefsKey.existenceFiles, files);
  }

  Future<bool> removeAFilePathExist(String filePath, String chatId) {
    List<String> files = getExistenceFiles();

    files.removeWhere((element) => (element.contains(filePath.split(" ")[0]) &&
        element.contains('"${chatId}"' + ":")));
    return _preferences.setStringList(PrefsKey.existenceFiles, files);
  }

  @override
  // TODO: implement deviceIp
  String? get countryIso => _preferences.getString('countryIso');

  @override
  Future<bool> setCountryIso(String? countryIso) =>
      _preferences.setString('countryIso', countryIso!);

  @override
  String? getTheLocalPathForFile(String filePath, String chatId) {
    List<String> files = getExistenceFiles();

    String path =
        files.firstWhere((element) {
          if( element.contains('"${chatId}"' + ":" )){
            Map paths = convert.jsonDecode(element);
            return paths[chatId].toString().startsWith(filePath);
          }
          return false;
        });

    Map paths = convert.jsonDecode(path);
    return paths[chatId].toString().split(' ').length > 1
        ? paths[chatId].split(' ')[1]
        : null;
  }

  @override
  List<String>? getTheLocalPathForChannel(String chatId) {
    List<String> files = getExistenceFiles();

    List<String> paths = [];
    files.forEach((element) {
      Map fiePath = convert.jsonDecode(element);

      if (fiePath.keys.contains(chatId)) {
        if (fiePath[chatId].toString().split(' ').length > 1) {
          paths.add(fiePath[chatId]);
        }
      }
    });

    return paths.reversed.toList();
  }

  @override
  String? get myMarketId => _preferences.getString(PrefsKey.userMarketId);

  @override
  Future<bool> setMyMarketId(String id) =>
      _preferences.setString(PrefsKey.userMarketId, id);

  @override
  String? get myMarketName => _preferences.getString(PrefsKey.marketName);

  @override
  Future<bool> setMyMarketName(String name) =>
      _preferences.setString(PrefsKey.marketName, name);

  @override
  String? get myChatPhoto => _preferences.getString(PrefsKey.chatPhoto);

  @override
  Future<bool> setMyChatPhoto(String? photo) =>
      _preferences.setString(PrefsKey.chatPhoto, photo ?? 'null');

  @override
  Future<bool> addFcmToken(String fcmToken) {
    List<String> tokens = getFcmTokens;
    if (tokens.contains(fcmToken)) return Future.value(true);
    tokens.add(fcmToken);
    return _preferences.setStringList(PrefsKey.fcmToken, tokens);
  }

  @override
  List<String> get getFcmTokens =>
      _preferences.getStringList(PrefsKey.fcmToken) ?? [];

  @override
  List<Message>? get getTheMessageFromBackground => _preferences
      .getStringList('message')
      ?.map((e) => Message.fromJson(convert.jsonDecode(e)))
      .toList();

  @override
  Future<bool> removeMessageFromBackground() => _preferences.remove('message');

  @override
  Future<bool> removeMessageWatchStatusFromBackground() =>
      _preferences.remove('messageWatchStatus');

  @override
  Future<bool> removeMessageReceivedStatusFromBackground() =>
      _preferences.remove('messageReceivedStatus');

  @override
  Future<bool> removeRemovedMessageFromBackground() =>
      _preferences.remove('removedMessage');

  @override
  Future<bool> setMessageFromBackground(String message) {
    List<String> list = _preferences.getStringList('message') ?? [];
    list.add(message);
    return _preferences.setStringList('message', list);
  }

  @override
  List<Chat>? get getTheChatsToEditFromBackground => _preferences
      .getStringList('chat')
      ?.map((e) => Chat.fromJson(convert.jsonDecode(e)))
      .toList();

  @override
  Future<bool> removeChatToEditFromBackground() => _preferences.remove('chat');

  @override
  Future<bool> setChatToEditFromBackground(String chat) {
    List<String> list = _preferences.getStringList('chat') ?? [];
    list.add(chat);
    return _preferences.setStringList('chat', list);
  }

  List<Map>? get getTheRemovedMessageFromBackground => _preferences
      .getStringList('removedMessage')
      ?.map((e) => (convert.jsonDecode(e)) as Map)
      .toList();

  @override
  // TODO: implement getTheRemovedMessageFromBackground
  List<Map>? get getTheMessageWatchStatusFromBackground => _preferences
      .getStringList('messageWatchStatus')
      ?.map((e) => (convert.jsonDecode(e)) as Map)
      .toList();

  @override
  // TODO: implement getTheRemovedMessageFromBackground
  List<Map>? get getTheMessageReceivedStatusFromBackground => _preferences
      .getStringList('messageReceivedStatus')
      ?.map((e) => (convert.jsonDecode(e)) as Map)
      .toList();

  @override
  Future<bool> setRemovedMessageFromBackground(String data) {
    List<String> list = _preferences.getStringList('removedMessage') ?? [];
    list.add(data);
    return _preferences.setStringList('removedMessage', list);
  }

  @override
  Future<bool> setMessageWatchStatusFromBackground(String data) {
    List<String> list = _preferences.getStringList('messageWatchStatus') ?? [];
    list.add(data);
    return _preferences.setStringList('messageWatchStatus', list);
  }

  @override
  Future<bool> setMessageReceivedStatusFromBackground(String data) {
    List<String> list =
        _preferences.getStringList('messageReceivedStatus') ?? [];
    list.add(data);
    return _preferences.setStringList('messageReceivedStatus', list);
  }

  @override
  Future<bool> removeAllFilePathExistInChat(String chatId) {
    List<String> files = getExistenceFiles();
    files.removeWhere((element) => element.contains('"${chatId}"' + ":"));

    return _preferences.setStringList(PrefsKey.existenceFiles, files);
  }

  @override
  List<String>? get getTheChatsIdsToRemoveFromBackground =>
      _preferences.getStringList('removedChats');

  @override
  Future<bool> removeChatsFromBackground() =>
      _preferences.remove('removedChats');

  @override
  Future<bool> setRemovedChatFromBackground(String removedChatId) {
    List<String> list = _preferences.getStringList('removedChats') ?? [];
    list.add(removedChatId);
    return _preferences.setStringList('removedChats', list);
  }

  @override
  String? get myStoriesName => _preferences.getString(PrefsKey.storiesName);

  @override
  Future<bool> setMyStoriesName(String name) =>
      _preferences.setString(PrefsKey.storiesName, name);

  @override
  // TODO: implement durtion
  int? get getdurtion {
    return _preferences.getInt("duration");
  }

  @override
  Future<bool> setDuration(int duration) {
    return _preferences.setInt("duration", duration);
  }

  @override
  // TODO: implement currentEvent
  String? get currentEvent {
    return _preferences.getString(PrefsKey.currentEvent);
  }

  @override
  Future<bool> setCurrentEvent(String currentEvent) {
    return _preferences.setString(PrefsKey.currentEvent, currentEvent);
  }

  @override
  Future<bool> removeCurrentEvent() async {
    return await _preferences.remove(PrefsKey.currentEvent);
  }

  @override
  String? get serverTime {
    return _preferences.getString("ServerTime");
  }

  @override
  Future<bool> setServerTime(DateTime serverTime) {
    return _preferences.setString("ServerTime", serverTime.toString());
  }

  @override
  // TODO: implement sessionId
  String? get sessionId {
    return _preferences.getString(PrefsKey.sessionId);
  }

  @override
  Future<bool> setSessionId(String sessionId) {
    return _preferences.setString(PrefsKey.sessionId, sessionId);
  }

  @override
  Future<bool> clearTokenForMarket() {
    return _preferences.remove(PrefsKey.marketToken);
  }

  @override
  Future<bool> clearTokensForChatAndStory() {
    _preferences.remove(PrefsKey.chatToken);
    return _preferences.remove(PrefsKey.storiesToken);
  }

  @override
  bool? get isTimerForOtpRunning =>
      _preferences.getBool(PrefsKey.isTimerRunningId);

  @override
  Future<bool> setTimerForOtpRunning(bool isRunning) =>
      _preferences.setBool(PrefsKey.isTimerRunningId, isRunning);

  @override
  Future<bool> removeStoriesName() => _preferences.remove(PrefsKey.storiesName);

  @override
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable) {
    return _preferences.setInt(
        PrefsKey.userCountryIsAvailable, userCountryAvailable);
  }

  @override
  int? get userCountryIsAvailable =>
      _preferences.getInt(PrefsKey.userCountryIsAvailable);

  @override
  // TODO: implement language
  String? get language => _preferences.getString(PrefsKey.language);

  @override
  Future<bool> setLanguage(String? language) {
    return _preferences.setString(PrefsKey.language, language!);
  }

  @override
  String? get getChatUrl => _preferences.getString(PrefsKey.chatUrl);

  @override
  String? get getMarketUrl => _preferences.getString(PrefsKey.marketUrl);

  @override
  String? get getStoryUrl => _preferences.getString(PrefsKey.storyUrl);

  @override
  Future<bool> setChatUrl(String url) =>
      _preferences.setString(PrefsKey.chatUrl, url);

  @override
  Future<bool> setMarketUrl(String url) =>
      _preferences.setString(PrefsKey.marketUrl, url);

  @override
  Future<bool> setStoryUrl(String url) =>
      _preferences.setString(PrefsKey.storyUrl, url);

  @override
  Future<bool> setViewedProducts(String productId) async {
    List<String> list = getviewedProductsProducts();
    list.add(productId);
    return await _preferences.setStringList(PrefsKey.viewedProducts, list);
  }

  @override
  List<String> getviewedProductsProducts() {
    List<String> list =
        _preferences.getStringList(PrefsKey.viewedProducts) ?? [];

    return list;
  }

  @override
  Future<bool> removeViewedProducts() async {
    return await _preferences.remove(PrefsKey.viewedProducts);
  }

  @override
  Future<bool> setViewedBoutiques(String boutiqueId) async {
    List<String> list = getviewedProductsBoutiques();
    list.add(boutiqueId);
    return await _preferences.setStringList(PrefsKey.viewedBoutiques, list);
  }

  @override
  List<String> getviewedProductsBoutiques() {
    List<String> list =
        _preferences.getStringList(PrefsKey.viewedBoutiques) ?? [];

    return list;
  }

  @override
  Future<bool> removeViewedBoutiques() async {
    return await _preferences.remove(PrefsKey.viewedBoutiques);
  }

// @override

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
