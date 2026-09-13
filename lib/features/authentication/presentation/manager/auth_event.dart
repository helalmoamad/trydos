part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class CreateUserEvent extends AuthEvent {
  final String? name;
  final String? mobilePhone;
  final String? password;

  const CreateUserEvent({this.name, this.mobilePhone, this.password});

  @override
  // TODO: implement props
  List<Object?> get props => [name, mobilePhone, password];
}

class LoginToChatEvent extends AuthEvent {
  final String? mobilePhone;
  final String? otpIdToken;
  final String? originalUserId;
  final String fcmToken;
  final String? name;
  const LoginToChatEvent({
    this.mobilePhone,
    this.otpIdToken,
    this.originalUserId,
    this.name,
    required this.fcmToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    mobilePhone,
    otpIdToken,
    fcmToken,
    originalUserId,
    name,
  ];
}

class DeleteFcmTokenFromChatEvent extends AuthEvent {
  final String fcmToken;

  const DeleteFcmTokenFromChatEvent({required this.fcmToken});

  @override
  // TODO: implement props
  List<Object?> get props => [fcmToken];
}

class StoreFcmTokenInStoryEvent extends AuthEvent {
  final int userId;
  final String fcmToken;
  final ServerName serverName;

  const StoreFcmTokenInStoryEvent({
    required this.userId,
    required this.fcmToken,
    required this.serverName,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken, serverName];
}

class StoreFcmTokenInChatEvent extends AuthEvent {
  final int userId;
  final String fcmToken;
  final ServerName serverName;

  const StoreFcmTokenInChatEvent({
    required this.userId,
    required this.fcmToken,
    required this.serverName,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken, serverName];
}

class DeleteFcmTokenEvent extends AuthEvent {
  final int userId;
  final String fcmToken;

  const DeleteFcmTokenEvent({required this.userId, required this.fcmToken});

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken];
}

class GenerateTokenForCommentEvent extends AuthEvent {
  final String? userId;
  final String? mobilePhone;
  final String? otpIdToken;
  GenerateTokenForCommentEvent({
    this.userId,
    this.mobilePhone,
    this.otpIdToken,
  });
  @override
  List<Object?> get props => [userId, mobilePhone, otpIdToken];
}

class SendOtpEvent extends AuthEvent {
  final int isViaWhatsApp;
  final String phone;

  const SendOtpEvent({required this.phone, required this.isViaWhatsApp});
  @override
  // TODO: implement props
  List<Object?> get props => [phone, isViaWhatsApp];
}

class VerifyOtpSignInEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  final String phone;

  VerifyOtpSignInEvent({
    required this.verificationId,
    required this.otp,
    required this.phone,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [otp, verificationId, phone];
}

class VerifyOtpSignUpEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  final String? name;

  VerifyOtpSignUpEvent({
    required this.verificationId,
    required this.otp,
    this.name,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [otp, name, verificationId];
}

class VerifyOtpFromGuestEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  VerifyOtpFromGuestEvent({required this.verificationId, required this.otp});

  @override
  // TODO: implement props
  List<Object?> get props => [verificationId, otp];
}

class VerifyOtpInProfileEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  VerifyOtpInProfileEvent({required this.verificationId, required this.otp});

  @override
  // TODO: implement props
  List<Object?> get props => [verificationId, otp];
}

class RegisterGuestEvent extends AuthEvent {
  final String deviceId;
  final String? oldGuestUserId;
  RegisterGuestEvent({required this.deviceId, this.oldGuestUserId});

  @override
  // TODO: implement props
  List<Object?> get props => [deviceId];
}

/// Exchanges the stored refresh token for a new access + refresh pair
/// (dispatched on a market 401). Falls back to [RegisterGuestEvent] when no
/// refresh token is stored or the refresh itself is rejected.
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();

  @override
  List<Object?> get props => [];
}

class RefreshChatTokenEvent extends AuthEvent {
  const RefreshChatTokenEvent();

  @override
  List<Object?> get props => [];
}

/// Exchanges the stored stories refresh token for a new access + refresh pair
/// (dispatched on a stories 401). Falls back to [RegisterGuestEvent] when no
/// refresh token is stored or the refresh itself is rejected.
class RefreshStoriesTokenEvent extends AuthEvent {
  const RefreshStoriesTokenEvent();

  @override
  List<Object?> get props => [];
}

/// Exchanges the stored comments refresh token for a new access + refresh pair
/// (dispatched on a comments 401). Falls back to [RegisterGuestEvent] when no
/// refresh token is stored or the refresh itself is rejected — the same
/// recovery the market, chat and stories refresh events use.
class RefreshCommentTokenEvent extends AuthEvent {
  const RefreshCommentTokenEvent();

  @override
  List<Object?> get props => [];
}

/// Signals base_page to show the "session expired" dialog for a verified user
/// whose refresh failed. Carries the account's phone to prefill the re-login.
class ShowSessionExpiredEvent extends AuthEvent {
  final String? phone;
  const ShowSessionExpiredEvent({this.phone});

  @override
  List<Object?> get props => [phone];
}

class UpdateNameEvent extends AuthEvent {
  final String? name;

  UpdateNameEvent({this.name});

  @override
  // TODO: implement props
  List<Object?> get props => [name];
}

class UpdateChatUserNameEvent extends AuthEvent {
  final String name;

  UpdateChatUserNameEvent({required this.name});

  @override
  // TODO: implement props
  List<Object?> get props => [name];
}

class UpdateStoriesUserEvent extends AuthEvent {
  final String? name;
  final String? phone;
  final String? photo;
  UpdateStoriesUserEvent({this.name, this.phone, this.photo});

  @override
  // TODO: implement props
  List<Object?> get props => [name];
}

class GetCustomerInfoEvent extends AuthEvent {
  GetCustomerInfoEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoginToStoriesEvent extends AuthEvent {
  final String? otpIdToken;
  final String? phone;
  final String? name;
  final String? originalUserId;

  LoginToStoriesEvent({
    this.phone,
    this.name,
    this.otpIdToken,
    this.originalUserId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [otpIdToken, phone, originalUserId, name];
}

class LoginToWalletEvent extends AuthEvent {
  final String? otpIdToken;
  final String? phone;
  final String? name;
  LoginToWalletEvent({this.otpIdToken, this.phone, this.name});
  @override
  List<Object?> get props => [otpIdToken, phone, name];
}

class GetUserCountryEvent extends AuthEvent {
  GetUserCountryEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CreateWalletEvent extends AuthEvent {
  CreateWalletEvent();
  @override
  List<Object?> get props => [];
}
