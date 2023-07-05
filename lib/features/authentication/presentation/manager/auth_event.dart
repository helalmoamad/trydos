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

  const LoginEvent({
    this.mobilePhone,
    this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [mobilePhone, password];
}