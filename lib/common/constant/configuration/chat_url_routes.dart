extension ScopeApi on String {
  String get _api => 'api';

  String get _previousVersion => 'v1';
  String get _currentVersion => 'v2';

  String noScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/$this';

  String bugsScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/bugs/$this';

  String usersScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/users/$this';

  String channelsScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/channels/$this';

  String channelMembersScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/channel_members/$this';

  String messagesScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/messages/$this';

  String firebaseTokensScope({bool current=false}) => '$_api/${current ? _currentVersion : _previousVersion}/firebase_tokens${this !='' ? '/$this': ''}';
}

abstract class ChatEndPoints {
  ///! ----< user >----
  ///
  static final loginEP = 'login'.usersScope();
  static final getMyContactsEP = 'my_contacts'.usersScope();
  static final saveContactsEP = 'save_contacts'.usersScope();

  ///! ----< No scope >----
  static final createUserEP = 'create_user'.noScope();
  static final uploadFileEP = 'upload_file'.noScope();

  ///! ----< bugs >----
  static final createBugEP = 'create'.noScope();

///! ----< channels ( chats )  >----
///
  static final getMyChatsEP = 'my_channels'.channelsScope(current: true);
  static final deleteChatEP = 'destroy'.channelsScope();
  static String readAllMessagesEP(String channelId) => '$channelId/watched'.channelsScope();
  static String receiveMessageEP(String channelId) => '$channelId/received'.channelsScope();

  ///! ----< channel Members  >----
///
  static final setChatPropertyEP = 'set'.channelMembersScope();
  ///! ----< messages >----
  ///
  static final sendMessageEP = 'send'.messagesScope();
  static final getMessagesBetweenEP = 'get_all_messages_between_two_messages'.messagesScope();
  static String getMessagesForChatEP(String channelId) => 'messages_of_channel/$channelId'.messagesScope();
  ///! ----< firebase tokens >----
  ///
  static final storeFcmEP = ''.firebaseTokensScope();
  static String deleteFcmEP(int id) => id.toString().firebaseTokensScope();
  ///! ----< video calls >----
  ///
static String videoCall(String ChatId)
  {return    '$ChatId/video_call'.channelsScope();}
  static String answer_call(String ChatId)
  {return    '$ChatId/answer_call'.channelsScope();}
  static String getAgoraToken(String ChatId)
  {return    '$ChatId/agora_token'.channelsScope();}

}

abstract class ChatUrls {
  static String get baseUrl => _baseUrlDev;
  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static const String _baseUrlDev = 'https://chating_staging_trydos.trydos.tech';
  static const String _baseUrlDevWithHttp = 'http://chating_staging_trydos.trydos.tech';
}
