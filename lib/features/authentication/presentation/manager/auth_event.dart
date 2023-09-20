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
  final String? password;
  final String fcmToken;
  const LoginToChatEvent({
    this.mobilePhone,
    this.password,
    required this.fcmToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [mobilePhone, password, fcmToken];
}
class StoreFcmTokenEvent extends AuthEvent {
  final int userId;
  final String fcmToken;

  const StoreFcmTokenEvent({
    required this.userId,
    required this.fcmToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken];
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

class SendOtpEvent extends AuthEvent{
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
class VerifyOtpSignInEvent extends AuthEvent{
  final String verificationId;
  final String otp;

  VerifyOtpSignInEvent({
    required this.verificationId,
    required this.otp,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [otp, verificationId];
}

class VerifyOtpSignUpEvent extends AuthEvent{
  final String verificationId;
  final String otp;

  VerifyOtpSignUpEvent({
    required this.verificationId,
    required this.otp,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [otp, verificationId];
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

class LoginToMarketEvent extends AuthEvent {
  final String? phone;
  final String? deviceId;
  final String? password;

  LoginToMarketEvent({
    this.phone,
    this.password,
    this.deviceId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [phone , deviceId , password];
}

class LoginToStoriesEvent extends AuthEvent {
  final String? otpIdToken;
  final String? phone;

  LoginToStoriesEvent({
    this.phone,
    this.otpIdToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [otpIdToken , phone];
}