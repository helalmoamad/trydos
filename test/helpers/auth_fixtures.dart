/// Test ledger · wave 02 Account and session — the response bodies.
///
/// The market auth endpoints all answer with the same envelope: an
/// `isSuccessful` / `code` wrapper around a `data` object that carries the token
/// pair and the user. Writing that out in full in every test hides the one field
/// the test is actually about, so it is built here and each test overrides only
/// what it cares about.
library;

/// One user, as the market server sends it.
Map<String, dynamic> userJson({
  int id = 1,
  String? name = 'Fixture User',
  String? phone = '+000000000',
  String? image = '',
  int isPhoneVerified = 1,
  String? lastOtpIdToken = 'otp-id-token',
  bool isAllowedToUploadStory = false,
}) {
  return <String, dynamic>{
    'id': id,
    'name': name,
    'phone': phone,
    'alternative_phone': null,
    'email': null,
    'gender': null,
    'tall': null,
    'weight': null,
    'image': image,
    'is_phone_verified': isPhoneVerified,
    'last_otp_id_token': lastOtpIdToken,
    'is_allowed_to_upload_story': isAllowedToUploadStory,
  };
}

/// The market auth envelope — register-guest, sign-in, sign-up, verify-guest
/// and refresh-token all use it.
///
/// [alreadyExists] is written under both spellings the models read:
/// `already_exists` is what the servers send, and the sign-in / sign-up model
/// reads exactly that key, while the guest model reads it too. Passing `null`
/// leaves the key out, which is how a server that does not know the field
/// answers.
Map<String, dynamic> authEnvelope({
  String? token = 'market-access-token',
  String? refreshToken = 'market-refresh-token',
  String? idToken = 'otp-id-token',
  bool? alreadyExists = true,
  Map<String, dynamic>? user,
  int code = 200,
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': code,
    'message': null,
    'detailed_error': null,
    'data': <String, dynamic>{
      'already_exists': alreadyExists,
      'id_token': idToken,
      'user_type': 1,
      'token': token,
      'expires_at': '2030-01-01T00:00:00Z',
      'refresh_token': refreshToken,
      'user': user ?? userJson(),
    },
  };
}

/// What `send_otp` answers. The id the OTP screen later verifies against sits
/// inside `data`, spelled `verificationId` — camelCase, unlike its neighbours.
Map<String, dynamic> sendOtpEnvelope({String? verificationId = 'vid-1'}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{'verificationId': verificationId},
  };
}

/// What `verify_otp` (the in-profile one) answers: the phone it just proved and
/// a fresh OTP id token.
Map<String, dynamic> verifyOtpInProfileEnvelope({
  String? phone = '+000000000',
  String? idToken = 'fixture-id-token',
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{'phone': phone, 'id_token': idToken},
  };
}

/// What `customer/info` answers. The user sits two levels down, under
/// `data.customer_info` — the datasource reads exactly that path.
Map<String, dynamic> customerInfoEnvelope({Map<String, dynamic>? user}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{'customer_info': user ?? userJson()},
  };
}

/// What the chat server answers on login and on a chat-token refresh.
Map<String, dynamic> chatLoginEnvelope({
  int id = 1,
  String? accessToken = 'chat-access-token',
  String? refreshToken = 'chat-refresh-token',
  String? name = 'Fixture User',
  String? photoPath = '',
  String? mobilePhone = '000000000',
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'id': id,
      'name': name,
      'mobile_phone': mobilePhone,
      'photo_path': photoPath,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    },
  };
}

/// What the stories server answers on login.
Map<String, dynamic> storiesLoginEnvelope({
  int id = 2,
  String? accessToken = 'stories-access-token',
  String? refreshToken = 'stories-refresh-token',
  String? name = 'Fixture User',
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'id': id,
      'name': name,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    },
  };
}

/// What the comments server answers when it hands out or renews a token pair.
Map<String, dynamic> commentTokenEnvelope({
  String? token = 'comment-access-token',
  String? refreshToken = 'comment-refresh-token',
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'comments_token': token,
      'refresh_token': refreshToken,
    },
  };
}

/// What the stories server answers on a refresh.
///
/// The pair sits at the **root** here, not inside a `data` envelope — that is
/// what `RefreshStoriesTokenResponseModel` reads, and getting it wrong is how
/// an empty token ends up stored.
Map<String, dynamic> storiesRefreshEnvelope({
  String? accessToken = 'stories-access-token-2',
  String? refreshToken = 'stories-refresh-token-2',
}) {
  return <String, dynamic>{
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': 'Bearer',
    'expires_in': 3600,
  };
}

/// A plain failure body, for the paths that only look at the status code.
Map<String, dynamic> failureBody({String message = 'something went wrong'}) {
  return <String, dynamic>{
    'isSuccessful': false,
    'hasContent': false,
    'message': message,
  };
}
