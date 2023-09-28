part of 'auth_bloc.dart';

enum CreateUserStatus { init, loading, success, failure }
enum LoginToChatStatus { init, loading, success, failure }
enum LoginToStoriesStatus { init, loading, success, failure }
enum SendOtpStatus { init, loading, success, failure }
enum VerifyOtpSignUpStatus { init, loading, success, failure }
enum VerifyOtpSignInStatus { init, loading, success, failure }
enum VerifyGuestPhoneStatus { init, loading, success, failure }
enum RegisterGuestStatus { init, loading, success, failure }


class AuthState {
  const AuthState({
    this.createUserStatus = CreateUserStatus.init,
    this.loginToChatStatus = LoginToChatStatus.init,
    this.sendOtpStatus = SendOtpStatus.init,
    this.marketUser ,
    this.signInErrorMessage ,
    this.signUpErrorMessage ,
    this.registerGuestStatus = RegisterGuestStatus.init,
    this.verifyOtpSignUpStatus = VerifyOtpSignUpStatus.init,
    this.verifyOtpSignInStatus = VerifyOtpSignInStatus.init,
    this.verifyGuestPhoneStatus = VerifyGuestPhoneStatus.init,
    this.loginToStoriesStatus = LoginToStoriesStatus.init,
  });

  final CreateUserStatus createUserStatus;
  final LoginToChatStatus loginToChatStatus;
  final LoginToStoriesStatus loginToStoriesStatus;
  final SendOtpStatus sendOtpStatus;
  final VerifyOtpSignUpStatus verifyOtpSignUpStatus;
  final VerifyOtpSignInStatus verifyOtpSignInStatus;
  final VerifyGuestPhoneStatus verifyGuestPhoneStatus;
  final RegisterGuestStatus registerGuestStatus;
  final User? marketUser;
  final String? signInErrorMessage;
  final String? signUpErrorMessage;
  AuthState copyWith({
    final CreateUserStatus? createUserStatus,
    final LoginToChatStatus? loginToChatStatus,
    final LoginToStoriesStatus? loginToStoriesStatus,
    final SendOtpStatus? sendOtpStatus,
    final String? signInErrorMessage,
    final RegisterGuestStatus? registerGuestStatus,
    final String? signUpErrorMessage,
    final User? marketUser,
    final VerifyOtpSignUpStatus? verifyOtpSignUpStatus,
    final VerifyOtpSignInStatus? verifyOtpSignInStatus,
    final VerifyGuestPhoneStatus? verifyGuestPhoneStatus
  }) {
    return AuthState(
      createUserStatus: createUserStatus ?? this.createUserStatus,
      loginToChatStatus: loginToChatStatus ?? this.loginToChatStatus,
      loginToStoriesStatus: loginToStoriesStatus ?? this.loginToStoriesStatus,
      registerGuestStatus: registerGuestStatus ?? this.registerGuestStatus,
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      signUpErrorMessage: signUpErrorMessage ?? this.signUpErrorMessage,
      signInErrorMessage: signInErrorMessage ?? this.signInErrorMessage,
      marketUser: marketUser ?? this.marketUser,
      verifyOtpSignUpStatus: verifyOtpSignUpStatus ?? this.verifyOtpSignUpStatus,
      verifyOtpSignInStatus: verifyOtpSignInStatus ?? this.verifyOtpSignInStatus,
      verifyGuestPhoneStatus: verifyGuestPhoneStatus ?? this.verifyGuestPhoneStatus,
    );
  }
}
