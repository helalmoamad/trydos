import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _previousVersion => 'v1';

  String get _currentVersion => 'v2';

  String noScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/$this';

  String bugsScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/bugs/$this';

  String usersScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/users/$this';

  String channelsScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/channels/$this';

  String channelMembersScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/channel_members/$this';

  String messagesScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/messages/$this';

  String firebaseTokensScope({bool current = false}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/firebase_tokens${this != '' ? '/$this' : ''}';

  String elasticScope({bool current = true}) =>
      '$_api/${current ? _currentVersion : _previousVersion}/elastic/$this';
}

abstract class ChatEndPoints {
  ///! ----< user >----
  ///
  static final sendErrorChatToServer = 'mobile_error_log/chat'.usersScope();
  static final loginEP = 'login'.usersScope();
  static final updateUserNameEP = 'update_user_name'.usersScope();
  static final getMyContactsEP = 'my_contacts'.usersScope();
  static final saveContactsEP = 'save_contacts'.usersScope();
  static final myCallReg = 'my_calls'.channelsScope();

  ///! ----< No scope >----
  static final createUserEP = 'create_user'.noScope();
  static final uploadFileEP = 'upload_file'.noScope();

  ///! ----< bugs >----
  static final createBugEP = 'create'.noScope();

  ///! ----< channels ( chats )  >----
  ///
  static final getMyChatsEP = 'my_channels'.channelsScope(current: true);
  static final deleteChatEP = 'destroy'.channelsScope();
  static final deleteMessage = 'destroy'.messagesScope();
  static final getDateTime = 'get_date_time'.channelsScope();
  static final missedCallCount = 'missed_cals_of_user'.messagesScope();
  static final watchMissedCall = 'wached_all_calls'.messagesScope();

  static String readAllMessagesEP(String channelId) =>
      '$channelId/watched'.channelsScope();
  static String getMediaCount(String channelId) =>
      '$channelId/media_counts'.channelsScope();

  static String receiveMessageEP(String channelId) =>
      '$channelId/received'.channelsScope();

  ///! ----< channel Members  >----
  ///
  static final setChatPropertyEP = 'set'.channelMembersScope();
  static final shareProductOnAppsEP = 'share_product_on_apps'.elasticScope();

  ///! ----< messages >----
  ///
  static final sendMessageEP = 'send'.messagesScope();
  static final getMessagesBetweenEP =
      'get_all_messages_between_two_messages'.messagesScope();
  static final shareProductWithChannelsOrContacts =
      'share_product'.messagesScope();
  static String getMessagesForChatEP(String channelId) =>
      'messages_of_channel/$channelId'.messagesScope();

  ///! ----< firebase tokens >----
  ///
  static final storeFcmEP = ''.firebaseTokensScope();

  static String deleteFcmEP(int id) => id.toString().firebaseTokensScope();

  ///! ----< video calls >----
  ///
  /// }/api/v1/messages/video_call
  static String videoCallEP = 'video_call'.messagesScope();
  static String voiceCallEP = 'voice_call'.messagesScope();

  static String answer_call(String messageId) {
    return 'answer_call/$messageId'.messagesScope();
  }

  static String refuseCall(String messageId) {
    return 'refuse_call/$messageId'.messagesScope();
  }

  static String getSharedProductCount(String ProductId) {
    return 'shared_count/$ProductId'.elasticScope();
  }

  static String inAnotherCall(String ChatId) {
    return '$ChatId/in_another_call'.channelsScope();
  }

  static String getAgoraToken(String ChatId) {
    return '$ChatId/agora_token'.channelsScope();
  }
}

abstract class ChatUrls {
  static String get baseUrl => _baseUrlDev;

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);
  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['CHAT_URL']!;
  static const String _baseUrlDevWithHttp =
      'http://chating_staging_trydos.trydos.dev';
}
