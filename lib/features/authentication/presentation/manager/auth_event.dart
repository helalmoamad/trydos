part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class CreateUserEvent extends AuthEvent {
  final String? name;
  final String? mobilePhone;
  final String? password;

  const CreateUserEvent({
    this.name,
    this.mobilePhone,
    this.password,
  });

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
  List<Object?> get props =>
      [mobilePhone, otpIdToken, fcmToken, originalUserId, name];
}

class StoreFcmTokenEvent extends AuthEvent {
  final int userId;
  final String fcmToken;
  final ServerName serverName ;

  const StoreFcmTokenEvent({
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

  const DeleteFcmTokenEvent({
    required this.userId,
    required this.fcmToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken];
}

class SendOtpEvent extends AuthEvent {
  final int isViaWhatsApp;
  final String phone;

  const SendOtpEvent({
    required this.phone,
    required this.isViaWhatsApp,
  });
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

  VerifyOtpSignUpEvent(
      {required this.verificationId, required this.otp, this.name});
  @override
  // TODO: implement props
  List<Object?> get props => [otp, name, verificationId];
}

class VerifyGuestPhoneEvent extends AuthEvent {
  final String idToken;

  VerifyGuestPhoneEvent({
    required this.idToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [idToken];
}

class RegisterGuestEvent extends AuthEvent {
  final String deviceId;

  RegisterGuestEvent({
    required this.deviceId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [deviceId];
}

class UpdateNameEvent extends AuthEvent {
  final String name;

  UpdateNameEvent({
    required this.name,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [name];
}

class UpdateChatUserNameEvent extends AuthEvent {
  final String name;

  UpdateChatUserNameEvent({
    required this.name,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [name];
}

class UpdateStoriesUserEvent extends AuthEvent {
  final String name;

  UpdateStoriesUserEvent({
    required this.name,
  });

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

class GetUserCountryEvent extends AuthEvent {
  GetUserCountryEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
