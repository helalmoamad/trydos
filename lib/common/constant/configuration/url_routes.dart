extension ScopeApi on String {
  String get _api => 'api';

  String get _previousVersion => 'v1';
  String get _currentVersion => 'v2';

  String noScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/$this';

  String usersScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/users/$this';

  String channelsScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/channels/$this';

  String messagesScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/messages/$this';

  String firebaseTokensScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/firebase_tokens${this !='' ? '/$this': ''}';
}

abstract class EndPoints {
  ///! ----< user >----
  ///
  static final loginEP = 'login'.usersScope();
  static final getMyContactsEP = 'my_contacts'.usersScope();
  static final saveContactsEP = 'save_contacts'.usersScope();

  ///! ----< No scope >----
  static final createUserEP = 'create_user'.noScope();
  static final uploadFileEP = 'upload_file'.noScope();

///! ----< channels ( chats )  >----
///
  static final getMyChatsEP = 'my_channels'.channelsScope(current: true);
  static String readAllMessagesEP(String channelId) => '$channelId/watched'.channelsScope(current: true);
  static String receiveMessageEP(String channelId) => '$channelId/received'.channelsScope(current: true);

  ///! ----< messages >----
  ///
  static final sendMessageEP = 'send'.messagesScope();
  ///! ----< firebase tokens >----
  ///
  static final storeFcmEP = ''.firebaseTokensScope();
  static String deleteFcmEP(int id) => id.toString().firebaseTokensScope();

}

abstract class Urls {
  static String get baseUrl => _baseUrlDev;
  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static const String _baseUrlDev = 'https://chating_staging_trydos.trydos.tech';
  static const String _baseUrlDevWithHttp = 'http://chating_staging_trydos.trydos.tech';
}
