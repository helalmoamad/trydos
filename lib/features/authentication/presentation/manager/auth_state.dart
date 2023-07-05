part of 'auth_bloc.dart';

enum CreateUserStatus { init, loading, success, failure }
enum LoginUserStatus { init, loading, success, failure }


class AuthState {
  const AuthState({
    this.createUserStatus = CreateUserStatus.init,
    this.loginUserStatus = LoginUserStatus.init,
  });

  final CreateUserStatus createUserStatus;
  final LoginUserStatus loginUserStatus;
  AuthState copyWith({
    final CreateUserStatus? createUserStatus,
    final LoginUserStatus? loginUserStatus
  }) {
    return AuthState(
      createUserStatus: createUserStatus ?? this.createUserStatus,
      loginUserStatus: loginUserStatus ?? this.loginUserStatus,
    );
  }
}
