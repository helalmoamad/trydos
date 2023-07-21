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

class LoginEvent extends AuthEvent {
  final String? mobilePhone;
  final String? password;
  final String fcmToken;
  const LoginEvent({
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