import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import '../../../../common/constant/configuration/prefs_key.dart';
import '../../../config/theme/app_theme.dart';
import '../../domin/repositories/prefs_repository.dart';
import 'dart:convert' as convert;

import '../../utils/json_size_cap.dart';

class PrefsRepositoryImpl extends PrefsRepository {
  PrefsRepositoryImpl(
    this._preferences,
    this._secureStorage, {
    String? initialChatToken,
    String? initialWalletToken,
    String? initialMarketToken,
    String? initialStoriesToken,
    String? initialTokenForComment,
  }) : _cachedChatToken = initialChatToken,
       _cachedWalletToken = initialWalletToken,
       _cachedMarketToken = initialMarketToken,
       _cachedStoriesToken = initialStoriesToken,
       _cachedTokenForComment = initialTokenForComment;

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  /// In-memory cache for the chat token loaded from secure storage at startup.
  String? _cachedChatToken;

  /// In-memory cache for the wallet token loaded from secure storage at startup.
  String? _cachedWalletToken;

  /// In-memory cache for the market token loaded from secure storage at startup.
  String? _cachedMarketToken;

  /// In-memory cache for the stories token loaded from secure storage at startup.
  String? _cachedStoriesToken;

  /// In-memory cache for token-for-comment loaded from secure storage at startup.
  String? _cachedTokenForComment;

  @override
  Future<bool> setChatToken(String token) async {
    await _secureStorage.write(key: PrefsKey.chatToken, value: token);
    _cachedChatToken = token;
    return true;
  }

  @override
  String? get chatToken => _cachedChatToken;

  @override
  Future<bool> setUserChoosedCountryIso(String? countryIso) =>
      _preferences.setString(PrefsKey.currentCountry, countryIso!);

  @override
  Future<bool> setAllowedToUploadStories(bool allowedToUploadStories) {
    return _preferences.setBool(
      PrefsKey.allowedToUploadStories,
      allowedToUploadStories,
    );
  }

  @override
  bool getAllowedToUploadStories() {
    return _preferences.getBool(PrefsKey.allowedToUploadStories) ?? false;
  }

  @override
  String? get userChoosedCountryIso =>
      _preferences.getString(PrefsKey.currentCountry);

  @override
  String? get marketToken => _cachedMarketToken;

  @override
  Future<bool> setMarketToken(String? token) async {
    await _secureStorage.write(key: PrefsKey.marketToken, value: token ?? "");
    _cachedMarketToken = token ?? "";
    return true;
  }

  @override
  Future<bool> setMarketRefreshToken(String? token) async {
    await _secureStorage.write(
      key: PrefsKey.marketRefreshToken,
      value: token ?? "",
    );
    return true;
  }

  @override
  Future<String?> getMarketRefreshToken() {
    return _secureStorage.read(key: PrefsKey.marketRefreshToken);
  }

  @override
  Future<bool> setStoriesToken(String token) async {
    await _secureStorage.write(key: PrefsKey.storiesToken, value: token);
    _cachedStoriesToken = token;
    return true;
  }

  @override
  Future<bool> setWalletToken(String token) async {
    if (kDebugMode) print("Saving wallet token: $token");
    await _secureStorage.write(key: PrefsKey.walletToken, value: token);
    _cachedWalletToken = token;
    return true;
  }

  @override
  String? get walletToken => _cachedWalletToken;

  @override
  String? get storiesToken => _cachedStoriesToken;

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
    await _secureStorage.delete(key: PrefsKey.chatToken);
    await _secureStorage.delete(key: PrefsKey.walletToken);
    await _secureStorage.delete(key: PrefsKey.marketToken);
    await _secureStorage.delete(key: PrefsKey.storiesToken);
    await _secureStorage.delete(key: PrefsKey.tokenForComment);
    _cachedChatToken = null;
    _cachedWalletToken = null;
    _cachedMarketToken = null;
    _cachedStoriesToken = null;
    _cachedTokenForComment = null;
    return _preferences.remove(PrefsKey.user);
  }

  @override
  bool get registeredToChat => chatToken != null;

  /// Max number of diagnostic request entries kept in storage.
  static const int _maxStoredRequests = 20;

  /// Per-field size cap (in encoded chars). Larger response/body payloads are
  /// replaced by a small placeholder so the on-disk blob stays tiny — the whole
  /// history is decoded + re-encoded on every request, so its size directly
  /// drives main-thread cost.
  static const int _maxFieldChars = 8000;

  /// Returns [value] as-is when its JSON is small, otherwise a lightweight
  /// placeholder. Keeps the diagnostics readable while preventing huge
  /// responses (product listings/details) from bloating the store.
  dynamic _capFieldForStorage(dynamic value) {
    if (value == null) return null;
    try {
      // `exceeds` records the cap, not the real size: knowing the payload went
      // past the cap is the whole point, and measuring by how much would mean
      // encoding all of it again.
      return jsonExceedsCap(value, _maxFieldChars)
          ? {'_truncated': true, 'exceeds': _maxFieldChars}
          : value;
    } catch (_) {
      // Not JSON-encodable (e.g. FormData) — store a marker instead of failing.
      return {'_truncated': true};
    }
  }

  /// In-memory copy of the diagnostic request log. Mutated on every request
  /// (O(1)); the expensive encode + disk write is debounced (see below), so the
  /// per-request main-thread cost drops to a list append.
  List<Map<String, dynamic>>? _requestsCache;

  /// Pending debounced flush of [_requestsCache] to storage.
  Timer? _requestsFlushTimer;

  /// How long to batch request-log writes before persisting.
  static const Duration _requestsFlushDelay = Duration(seconds: 3);

  /// Loads the request log from storage into memory once, then reuses it.
  List<Map<String, dynamic>> _ensureRequestsLoaded() {
    if (_requestsCache != null) return _requestsCache!;
    final requestsJson = _preferences.getString('requests_json');
    if (requestsJson == null) {
      return _requestsCache = [];
    }
    try {
      final data = convert.jsonDecode(requestsJson);
      _requestsCache = List<Map<String, dynamic>>.from(
        (data['requests_data'] as List).map((x) => x),
      );
    } catch (_) {
      _requestsCache = [];
    }
    return _requestsCache!;
  }

  /// (Re)schedule persisting the request log after [_requestsFlushDelay].
  void _scheduleRequestsFlush() {
    _requestsFlushTimer?.cancel();
    _requestsFlushTimer = Timer(_requestsFlushDelay, _flushRequests);
  }

  /// Encode + write the in-memory request log to storage (the heavy step,
  /// now run at most once per [_requestsFlushDelay] instead of every request).
  void _flushRequests() {
    _requestsFlushTimer?.cancel();
    _requestsFlushTimer = null;
    try {
      _preferences.setString(
        'requests_json',
        convert.jsonEncode({'requests_data': _requestsCache ?? []}),
      );
    } catch (_) {}
  }

  @override
  void saveRequestsData(
    String? url,
    Map<String, dynamic>? response,
    Map<String, dynamic>? headers,
    int? statusCode,
    String? request,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body, {
    String? error,
    String? responseTime,
  }) {
    Map<String, dynamic> requestAndResponse;
    final bool isError = !(error == null || error == 'null' || error == '');
    if (!isError) {
      requestAndResponse = {
        'url': url,
        'request': request,
        'response': _capFieldForStorage(response),
        'headers': headers,
        'query': query,
        'body': _capFieldForStorage(body),
        'statusCode': statusCode,
        'response_time': responseTime,
      };
    } else {
      requestAndResponse = {'flutter_error': error};
    }
    final requests = _ensureRequestsLoaded();
    // Keep the newest [_maxStoredRequests] entries (>= guards against an
    // already-oversized list from older builds).
    while (requests.length >= _maxStoredRequests) {
      requests.removeAt(0);
    }
    requests.add(requestAndResponse);
    // Errors are persisted immediately (they must survive a crash/kill);
    // normal request logs are batched to keep the hot path cheap.
    if (isError) {
      _flushRequests();
    } else {
      _scheduleRequestsFlush();
    }
  }

  @override
  clearAllRequests() {
    _requestsCache = [];
    _flushRequests();
  }

  @override
  removeRequestFromCache(Map<String, dynamic> request) {
    final requests = _ensureRequestsLoaded();
    requests.remove(request);
    _scheduleRequestsFlush();
  }

  @override
  List<Map<String, dynamic>> getRequestsData() {
    // Return a fresh copy so callers can mutate their view without corrupting
    // the in-memory cache (e.g. HomeBloc's error reporting removes entries).
    return List<Map<String, dynamic>>.from(_ensureRequestsLoaded());
  }

  @override
  Future<bool> setMyChatId(int id) =>
      _preferences.setInt(PrefsKey.userChatId, id);

  @override
  int? get myChatId => _preferences.getInt(PrefsKey.userChatId);

  @override
  String? get myChatName => _preferences.getString(PrefsKey.chatName);

  @override
  String? get fcmTokenId => _preferences.getString(PrefsKey.fcmTokenId);
  @override
  String? get fcmMarketTokenId =>
      _preferences.getString(PrefsKey.fcmMarketTokenId);
  /* @override
  String? get alaaWebForCall => _preferences.getString("alaa");*/
  @override
  Future<bool> setFcmTokenId(String fcmTokenId) =>
      _preferences.setString(PrefsKey.fcmTokenId, fcmTokenId);
  @override
  Future<bool> setFcmMarketTokenId(String fcmMarketTokenId) =>
      _preferences.setString(PrefsKey.fcmMarketTokenId, fcmMarketTokenId);

  /* @override
  Future<bool> setAlaaWebForCall(String url) =>
      _preferences.setString("alaa", url);*/

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
      (element) =>
          (element.contains(filePath.split(" ")[0]) &&
          element.contains('"${chatId}"' + ":")),
      orElse: () => '',
    );
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

    files.removeWhere(
      (element) =>
          (element.contains(filePath.split(" ")[0]) &&
          element.contains('"${chatId}"' + ":")),
    );
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

    String path = files.firstWhere((element) {
      if (element.contains('"${chatId}"' + ":")) {
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
  String? get myChatPhoto {
    String? photo = _preferences.getString(PrefsKey.chatPhoto);
    if (photo == "" || photo == null) {
      return null;
    }
    return photo.contains("cloudinary") || photo.contains("media_server")
        ? photo
        : ("${dotenv.env['Media_S3_Server']}" + photo);
  }

  @override
  Future<bool> setMyChatPhoto(String? photo) =>
      _preferences.setString(PrefsKey.chatPhoto, photo ?? "");

  @override
  Future<bool> addFcmToken(String fcmToken) {
    List<String> tokens = [];

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
  Future<bool> clearTokenForMarket() async {
    _cachedMarketToken = null;
    await _secureStorage.delete(key: PrefsKey.marketToken);
    return true;
  }

  @override
  Future<bool> clearTokensForChatAndStory() async {
    await _secureStorage.delete(key: PrefsKey.chatToken);
    await _secureStorage.delete(key: PrefsKey.storiesToken);
    _cachedChatToken = null;
    _cachedStoriesToken = null;
    return true;
  }

  @override
  bool? get isTimerForOtpRunning =>
      _preferences.getBool(PrefsKey.isTimerRunningId);

  @override
  Future<bool> setTimerForOtpRunning(bool isRunning) =>
      _preferences.setBool(PrefsKey.isTimerRunningId, isRunning);
  @override
  int? get otpTimerEndTime => _preferences.getInt(PrefsKey.otpTimerEndTime);

  @override
  Future<bool> setOtpTimerEndTime(int endTime) =>
      _preferences.setInt(PrefsKey.otpTimerEndTime, endTime);

  @override
  Future<bool> removeOtpTimerEndTime() =>
      _preferences.remove(PrefsKey.otpTimerEndTime);

  @override
  Future<bool> removeStoriesName() => _preferences.remove(PrefsKey.storiesName);

  @override
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable) {
    return _preferences.setInt(
      PrefsKey.userCountryIsAvailable,
      userCountryAvailable,
    );
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

  @override
  Future<String?> getNotificationTypeFromTerminated() async {
    await _preferences.reload();
    return _preferences.getString(PrefsKey.notificationTypeFromTerminated);
  }

  @override
  Future<bool> setNotificationTypesFromTerminated(
    String? notificationTypeFromTerminated,
  ) async {
    return await _preferences.setString(
      PrefsKey.notificationTypeFromTerminated,
      notificationTypeFromTerminated ?? "",
    );
  }

  @override
  // TODO: implement isTokenExpired
  bool? get isTokenExpired => _preferences.getBool(PrefsKey.tokenExpired);

  @override
  Future<bool> setTokenExpired(bool tokenExpired) =>
      _preferences.setBool(PrefsKey.tokenExpired, tokenExpired);
  @override
  Future<bool> setLogInToChat(bool isLogInToChat) =>
      _preferences.setBool(PrefsKey.isLogInToChat, isLogInToChat);

  @override
  Future<bool> setIsCearteWallet(bool isCreate) =>
      _preferences.setBool(PrefsKey.createWallet, isCreate);

  @override
  // TODO: implement isVerifiedPhonePeforeExpiredToken
  bool? get isLogInToChat => _preferences.getBool(PrefsKey.isLogInToChat);

  @override
  // TODO: implement isVerifiedPhonePeforeExpiredToken
  bool? get isCreateWallet => _preferences.getBool(PrefsKey.createWallet);
  @override
  // TODO: implement isVerifiedPhonePeforeExpiredToken
  bool? get isVerifiedPhonePeforeExpiredToken =>
      _preferences.getBool(PrefsKey.verifiedPhonePeforeExpiredToken);
  @override
  Future<bool> setVerifiedPhonePeforeExpiredToken(
    bool verifiedPhonePeforeExpiredToken,
  ) => _preferences.setBool(
    PrefsKey.verifiedPhonePeforeExpiredToken,
    verifiedPhonePeforeExpiredToken,
  );

  @override
  Future<bool> setTopicThatAlreadySubsecribed(String topic) async {
    List<String> list = topicThatAlreadySubsecribed();
    list.add(topic);
    return await _preferences.setStringList(PrefsKey.topicSubsecribe, list);
  }

  @override
  // TODO: implement topicThatAlreadySubsecribed
  List<String> topicThatAlreadySubsecribed() {
    List<String> list =
        _preferences.getStringList(PrefsKey.topicSubsecribe) ?? [];

    return list;
  }

  @override
  Future<bool> removeTopicThatAlreadySubsecribed(String topic) {
    List<String> topics = topicThatAlreadySubsecribed();

    topics.removeWhere((element) => (element.contains(topic)));
    return _preferences.setStringList(PrefsKey.topicSubsecribe, topics);
  }

  @override
  bool? get onMessageRun => _preferences.getBool(PrefsKey.onMessageRun);

  @override
  Future<bool> setOnMessageRun(bool onMessageRun) =>
      _preferences.setBool(PrefsKey.onMessageRun, onMessageRun);

  @override
  // TODO: implement isRequestNotificationPermission
  bool? get isRequestNotificationPermission =>
      _preferences.getBool(PrefsKey.requestNotificationPermission);

  @override
  Future<bool> setRequestNotificationPermission(
    bool requestNotificationPermission,
  ) => _preferences.setBool(
    PrefsKey.requestNotificationPermission,
    requestNotificationPermission,
  );

  @override
  String? getPrefechOfBoutiquesForEachMainCategoryInHomePage(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<bool> setPrefechOfBoutiquesForEachMainCategoryInHomePage(
    String key,
    String value,
  ) {
    setMainCategoryHasPerfechedToRemoveItWhenOpenApp(key);
    return _preferences.setString(key, value);
  }

  @override
  Future<bool> setMainCategoryHasPerfechedToRemoveItWhenOpenApp(String key) {
    List<String> list =
        _preferences.getStringList(
          PrefsKey.mainCatogryForEachBoutiquePrefech,
        ) ??
        [];
    if (!list.contains(key)) {
      list.add(key);
    }

    return _preferences.setStringList(
      PrefsKey.mainCatogryForEachBoutiquePrefech,
      list,
    );
  }

  @override
  Future<bool> removeMainCategoryHasPerfechedWhenOpenApp(bool allCategory) {
    List<String> list =
        _preferences.getStringList(
          PrefsKey.mainCatogryForEachBoutiquePrefech,
        ) ??
        [];
    List<String> newList =
        _preferences.getStringList(
          PrefsKey.mainCatogryForEachBoutiquePrefech,
        ) ??
        [];
    _preferences.remove(PrefsKey.mainCatogryForEachBoutiquePrefech);
    if (allCategory) {
      list.forEach((element) {
        _preferences.remove(element);
      });
      return Future.value(true);
    } else {
      if (list.length > 6) {
        for (var i = 5; i < list.length; i++) {
          if (list[i] != "Empty") {
            _preferences.remove(list[i]);
            newList.remove(list[i]);
          }
        }
      }

      return _preferences.setStringList(
        PrefsKey.mainCatogryForEachBoutiquePrefech,
        newList,
      );
    }
  }

  @override
  bool get isCallkitPermissionRequested =>
      _preferences.getBool(PrefsKey.isCallkitPermissionRequested) ?? false;

  @override
  Future<bool> setCallkitPermissionRequested(bool value) =>
      _preferences.setBool(PrefsKey.isCallkitPermissionRequested, value);

  @override
  String? getPrefechOfProductsForEachBoutiqueInHomePage(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<bool> setBoutiqueHasPerfechedToRemoveItWhenOpenApp(String key) async {
    List<String> list =
        await _preferences.getStringList(PrefsKey.productPrefech) ?? [];

    if (!list.contains(key)) {
      list.add(key);
    }
    return await _preferences.setStringList(PrefsKey.productPrefech, list);
  }

  @override
  Future<bool> setPrefechOfProductsForEachBoutiqueInHomePage(
    String key,
    String value,
  ) {
    setBoutiqueHasPerfechedToRemoveItWhenOpenApp(key);
    return _preferences.setString(key, value);
  }

  @override
  Future<bool> removeBoutiqueHasPerfechedWhenOpenApp(bool allBoutique) {
    List<String> list =
        _preferences.getStringList(PrefsKey.productPrefech) ?? [];
    List<String> newList =
        _preferences.getStringList(PrefsKey.productPrefech) ?? [];
    _preferences.remove(PrefsKey.productPrefech);
    if (allBoutique) {
      list.forEach((element) {
        _preferences.remove(element);
      });
      return Future.value(true);
    } else {
      if (list.length > 10) {
        for (var i = 10; i < list.length; i++) {
          if (!(list[i].contains("*featured*") ||
              list[i].contains("*flashDeal*"))) {
            _preferences.remove(list[i]);
            newList.remove(list[i]);
          }
        }
      }
      return _preferences.setStringList(PrefsKey.productPrefech, newList);
    }
  }

  @override
  Future<bool> clear() async {
    _cachedChatToken = null;
    _cachedWalletToken = null;
    _cachedMarketToken = null;
    _cachedStoriesToken = null;
    _cachedTokenForComment = null;
    await _secureStorage.delete(key: PrefsKey.chatToken);
    await _secureStorage.delete(key: PrefsKey.walletToken);
    await _secureStorage.delete(key: PrefsKey.marketToken);
    await _secureStorage.delete(key: PrefsKey.storiesToken);
    await _secureStorage.delete(key: PrefsKey.tokenForComment);
    return _preferences.clear();
  }

  @override
  String? getPrefechForFiveFilterForEachBoutiqueInHomePage(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<bool> removeFiveFilterHasPerfechedWhenOpenApp() {
    List<String> list =
        _preferences.getStringList(PrefsKey.fiveFilterPrefech) ?? [];
    list.forEach((element) {
      _preferences.remove(element);
    });

    return _preferences.remove(PrefsKey.fiveFilterPrefech);
  }

  @override
  Future<bool> setFiveFilterHasPerfechedToRemoveItWhenOpenApp(String key) {
    List<String> list =
        _preferences.getStringList(PrefsKey.fiveFilterPrefech) ?? [];

    list.add(key);
    return _preferences.setStringList(PrefsKey.fiveFilterPrefech, list);
  }

  @override
  Future<bool> setPrefechForFiveFilterForEachBoutiqueInHomePage(
    String key,
    String value,
  ) {
    setFiveFilterHasPerfechedToRemoveItWhenOpenApp(key);
    return _preferences.setString(key, value);
  }

  @override
  List<String>? getFiveFilterForEachBoutiqueHasPrefechInHomePage() {
    List<String> list =
        _preferences.getStringList(PrefsKey.fiveFilterPrefech) ?? [];
    return list;
  }

  @override
  String? getPrefechOfMainCategoryInHomePage() {
    return _preferences.getString(PrefsKey.mainCatogryPrefech);
  }

  @override
  Future<bool> removeMainCategoryWhenOpenApp() {
    return _preferences.remove(PrefsKey.mainCatogryPrefech);
  }

  @override
  Future<bool> setPrefechOfMainCategoryInHomePage(String value) {
    return _preferences.setString(PrefsKey.mainCatogryPrefech, value);
  }

  @override
  // TODO: implement idToken
  String? get idToken => _preferences.getString(PrefsKey.idToken);

  @override
  Future<bool> setIdToken(String idToken) {
    return _preferences.setString(PrefsKey.idToken, idToken);
  }

  @override
  // TODO: implement myProfilePhoto
  String? get myProfilePhoto {
    if (_preferences.getString(PrefsKey.profilePhoto) == "" ||
        _preferences.getString(PrefsKey.profilePhoto) == null) {
      return null;
    }
    String photo = "";
    photo = _preferences.getString(PrefsKey.profilePhoto) ?? "";
    photo = (photo.contains("cloudinary") || photo.contains("media_server")
        ? photo
        : ("${dotenv.env['Media_S3_Server']}" + photo));
    if (kDebugMode) print(photo);
    return photo;
  }

  @override
  Future<bool> setMyProfilePhoto(String? photo) =>
      _preferences.setString(PrefsKey.profilePhoto, photo ?? '');

  @override
  // TODO: implement getNotificationIdsToRemoveAfterplaceOrder
  List<String>? get getNotificationIdsToRemoveAfterplaceOrder {
    List<String> list =
        _preferences.getStringList(PrefsKey.notificationsIds) ?? [];
    return list;
  }

  @override
  Future<bool> setNotificationIdsToRemoveAfterplaceOrder(String id) {
    List<String> list =
        _preferences.getStringList(PrefsKey.notificationsIds) ?? [];

    list.add(id);
    return _preferences.setStringList(PrefsKey.notificationsIds, list);
  }

  @override
  Future<bool> removeNotificationIdsToRemoveAfterplaceOrder() {
    return _preferences.remove(PrefsKey.notificationsIds);
  }

  @override
  String getOrderCoupon() {
    return _preferences.getString(PrefsKey.coupon) ?? '';
  }

  @override
  Future<bool> removeOrderCoupon() {
    return _preferences.remove(PrefsKey.coupon);
  }

  @override
  Future<bool> setOrderCoupon(String coupon) {
    return _preferences.setString(PrefsKey.coupon, coupon);
  }

  @override
  // TODO: implement getImageUrlHasPrefeched
  List<String>? get getImageUrlHasPrefeched {
    List<String> list = _preferences.getStringList(PrefsKey.imagesUrls) ?? [];
    return list;
  }

  @override
  Future<bool> setImageUrlHasPrefeched(String? url) {
    List<String> list = _preferences.getStringList(PrefsKey.imagesUrls) ?? [];
    if (list.length == 300) {
      list.removeLast();
      list.insert(0, url ?? "");
    } else {
      list.insert(0, url ?? "");
    }

    return _preferences.setStringList(PrefsKey.imagesUrls, list);
  }

  @override
  // TODO: implement getTagsInUrlToFilter
  List<String>? get getTagsInUrlToFilter =>
      _preferences.getStringList(PrefsKey.tagsFilters);

  @override
  Future<bool> setTagsInUrlToFilter(List<String> tags) {
    return _preferences.setStringList(PrefsKey.tagsFilters, tags);
  }

  @override
  // TODO: implement isFoundDataCashed
  bool? get isFoundDataCashed => _preferences.getBool(PrefsKey.foundDataCashed);

  @override
  Future<bool> setIsFoundDataCashed(bool isFoundDataCashed) {
    return _preferences.setBool(PrefsKey.foundDataCashed, isFoundDataCashed);
  }

  @override
  Future<bool> setRedeemDateForProduct(String productId, String seconds) {
    Map<String, dynamic> map =
        _preferences.getString(PrefsKey.redeemDateForProducts) != null &&
            _preferences.getString(PrefsKey.redeemDateForProducts) != '"{}"'
        ? convert.jsonDecode(
            _preferences.getString(PrefsKey.redeemDateForProducts) ?? '{}',
          )
        : {};
    if (!map.containsKey(productId)) {
      map.addAll({
        productId: (DateTime.now().add(
          Duration(seconds: int.tryParse(seconds) ?? 0),
        )).toString(),
      });
    }
    if (kDebugMode) print(map);

    return _preferences.setString(
      PrefsKey.redeemDateForProducts,
      convert.jsonEncode(map),
    );
  }

  @override
  DateTime? getRedeemDateForProduct(String productId) {
    if (_preferences.getString(PrefsKey.redeemDateForProducts) == null ||
        _preferences.getString(PrefsKey.redeemDateForProducts) == '"{}"') {
      return null;
    }
    Map<String, dynamic> map = convert.jsonDecode(
      _preferences.getString(PrefsKey.redeemDateForProducts) ?? '{}',
    );
    return map[productId] != null ? DateTime.tryParse(map[productId]!) : null;
  }

  @override
  Future<bool> removeRedeemDateForAnyProductFinished() {
    if (_preferences.getString(PrefsKey.redeemDateForProducts) == null ||
        _preferences.getString(PrefsKey.redeemDateForProducts) == '"{}"') {
      return Future.value(true);
    }
    Map<String, dynamic> map = convert.jsonDecode(
      _preferences.getString(PrefsKey.redeemDateForProducts) ?? '{}',
    );
    Map<String, dynamic> afterRemove = convert.jsonDecode(
      _preferences.getString(PrefsKey.redeemDateForProducts) ?? '{}',
    );
    map.forEach((key, value) {
      if (DateTime.parse(value).isBefore(DateTime.now())) {
        afterRemove.remove(key);
      }
    });
    return _preferences.setString(
      PrefsKey.redeemDateForProducts,
      convert.jsonEncode(afterRemove),
    );
  }

  @override
  int? getRedeemSecondRemainingForProduct(String productId) {
    if (_preferences.getString(PrefsKey.redeemSecondRemainForProducts) ==
            null ||
        _preferences.getString(PrefsKey.redeemSecondRemainForProducts) ==
            '"{}"') {
      return null;
    }
    Map<String, dynamic> map = convert.jsonDecode(
      _preferences.getString(PrefsKey.redeemSecondRemainForProducts) ?? '{}',
    );
    return map[productId] != null
        ? int.tryParse((map[productId] ?? "0").toString())
        : null;
  }

  @override
  String? get tokenForComment => _cachedTokenForComment;
  @override
  Future<bool> setTokenForComment(String token) async {
    await _secureStorage.write(key: PrefsKey.tokenForComment, value: token);
    _cachedTokenForComment = token;
    return true;
  }

  @override
  Future<bool> setRedeemSecondRemainingForProduct(
    String productId,
    int secondsLeft,
  ) {
    Map<String, dynamic> map =
        _preferences.getString(PrefsKey.redeemSecondRemainForProducts) !=
                null &&
            _preferences.getString(PrefsKey.redeemSecondRemainForProducts) !=
                '"{}"'
        ? convert.jsonDecode(
            _preferences.getString(PrefsKey.redeemSecondRemainForProducts) ??
                '{}',
          )
        : {};
    if (secondsLeft <= 0) {
      map.remove(productId);
    } else {
      map[productId] = secondsLeft.toString();
    }
    return _preferences.setString(
      PrefsKey.redeemSecondRemainForProducts,
      convert.jsonEncode(map),
    );
  }

  @override
  Future<bool> resetAllRedeemTimer() {
    _preferences.setString(
      PrefsKey.redeemDateForProducts,
      convert.jsonEncode("{}"),
    );

    return _preferences.setString(PrefsKey.redeemSecondRemainForProducts, "{}");
  }

  @override
  // TODO: implement myContactDetails
  String? get myContactDetails =>
      _preferences.getString(PrefsKey.myContactDetail);

  @override
  Future<bool> setContactDetails(String? contactDetails) {
    return _preferences.setString(
      PrefsKey.myContactDetail,
      contactDetails ?? "",
    );
  }

  @override
  Future<bool> setXSellerId(String id) {
    return _preferences.setString(PrefsKey.xSellerId, id);
  }

  @override
  String? get getXSellerId {
    return _preferences.getString(PrefsKey.xSellerId);
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
