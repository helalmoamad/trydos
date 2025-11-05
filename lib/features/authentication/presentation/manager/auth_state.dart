part of 'auth_bloc.dart';

enum CreateUserStatus { init, loading, success, failure }

enum LoginToChatStatus { init, loading, success, failure }

enum LoginToStoriesStatus { init, loading, success, failure }

enum SendOtpStatus { init, loading, success, failure }

enum VerifyOtpSignUpStatus { init, loading, success, failure }

enum VerifyOtpSignInStatus { init, loading, success, failure }

enum VerifyOtpInProfileStatus { init, loading, success, failure }

enum VerifyOtpFromGuestStatus { init, loading, success, failure }

enum RegisterGuestStatus { init, loading, success, failure }

enum UpdateNameStatus { init, loading, success, failure }

enum UpdateStoriesUserStatus { init, loading, success, failure }

enum UpdateChatUserNameStatus { init, loading, success, failure }

enum GetCustomerInfoStatus { init, loading, success, failure }

enum GenerateTokenForCommentStatus { init, loading, success, failure }

enum GetCustomerCountryStatus { loading, success, failure }

class AuthState {
  const AuthState({
    this.createUserStatus = CreateUserStatus.init,
    this.loginToChatStatus = LoginToChatStatus.init,
    this.sendOtpStatus = SendOtpStatus.init,
    this.marketUser,
    this.countryName,
    this.signInErrorMessage,
    this.sendOtpError,
    this.signUpErrorMessage,
    this.getUserCountryResponseModel,
    this.generateTokenForCommentStatus = GenerateTokenForCommentStatus.init,
    this.registerGuestStatus = RegisterGuestStatus.init,
    this.verifyOtpSignUpStatus = VerifyOtpSignUpStatus.init,
    this.verifyOtpSignInStatus = VerifyOtpSignInStatus.init,
    this.verifyOtpFromGuestStatus = VerifyOtpFromGuestStatus.init,
    this.loginToStoriesStatus = LoginToStoriesStatus.init,
    this.getCustomerInfoStatus = GetCustomerInfoStatus.init,
    this.updateNameStatus = UpdateNameStatus.init,
    this.verifyOtpInProfileStatus,
    this.getCustomerCountryStatus = GetCustomerCountryStatus.loading,
    this.updateStoriesUserStatus = UpdateStoriesUserStatus.init,
    this.updateChatUserNameStatus = UpdateChatUserNameStatus.init,
  });

  final CreateUserStatus createUserStatus;
  final LoginToChatStatus loginToChatStatus;
  final LoginToStoriesStatus loginToStoriesStatus;
  final SendOtpStatus sendOtpStatus;
  final VerifyOtpInProfileStatus? verifyOtpInProfileStatus;
  final VerifyOtpSignUpStatus verifyOtpSignUpStatus;
  final VerifyOtpSignInStatus verifyOtpSignInStatus;
  final VerifyOtpFromGuestStatus verifyOtpFromGuestStatus;
  final RegisterGuestStatus registerGuestStatus;
  final UpdateNameStatus updateNameStatus;
  final UpdateStoriesUserStatus updateStoriesUserStatus;
  final GetCustomerInfoStatus getCustomerInfoStatus;
  final UpdateChatUserNameStatus updateChatUserNameStatus;
  final GetCustomerCountryStatus getCustomerCountryStatus;
  final User? marketUser;
  final GetUserCountryResponseModel? getUserCountryResponseModel;
  final String? signInErrorMessage;
  final String? signUpErrorMessage;
  final GenerateTokenForCommentStatus generateTokenForCommentStatus;
  final String? sendOtpError;
  final String? countryName;
  AuthState copyWith(
      {final CreateUserStatus? createUserStatus,
      final LoginToChatStatus? loginToChatStatus,
      final LoginToStoriesStatus? loginToStoriesStatus,
      final SendOtpStatus? sendOtpStatus,
      final String? signInErrorMessage,
      final String? countryName,
      final GetUserCountryResponseModel? getUserCountryResponseModel,
      final GenerateTokenForCommentStatus? generateTokenForCommentStatus,
      final GetCustomerCountryStatus? getCustomerCountryStatus,
      final RegisterGuestStatus? registerGuestStatus,
      final VerifyOtpInProfileStatus? verifyOtpInProfileStatus,
      final GetCustomerInfoStatus? getCustomerInfoStatus,
      final UpdateChatUserNameStatus? updateChatUserNameStatus,
      final String? signUpErrorMessage,
      final String? sendOtpError,
      final UpdateNameStatus? updateNameStatus,
      final User? marketUser,
      final VerifyOtpSignUpStatus? verifyOtpSignUpStatus,
      final UpdateStoriesUserStatus? updateStoriesUserStatus,
      final VerifyOtpSignInStatus? verifyOtpSignInStatus,
      final VerifyOtpFromGuestStatus? verifyOtpFromGuestStatus}) {
    return AuthState(
      updateChatUserNameStatus:
          updateChatUserNameStatus ?? this.updateChatUserNameStatus,
      updateStoriesUserStatus:
          updateStoriesUserStatus ?? this.updateStoriesUserStatus,
      createUserStatus: createUserStatus ?? this.createUserStatus,
      countryName: countryName ?? this.countryName,
      sendOtpError: sendOtpError ?? this.sendOtpError,
      loginToChatStatus: loginToChatStatus ?? this.loginToChatStatus,
      loginToStoriesStatus: loginToStoriesStatus ?? this.loginToStoriesStatus,
      registerGuestStatus: registerGuestStatus ?? this.registerGuestStatus,
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      getUserCountryResponseModel:
          getUserCountryResponseModel ?? this.getUserCountryResponseModel,
      getCustomerInfoStatus:
          getCustomerInfoStatus ?? this.getCustomerInfoStatus,
      generateTokenForCommentStatus:
          generateTokenForCommentStatus ?? this.generateTokenForCommentStatus,
      verifyOtpInProfileStatus:
          verifyOtpInProfileStatus ?? this.verifyOtpInProfileStatus,
      signUpErrorMessage: signUpErrorMessage ?? this.signUpErrorMessage,
      signInErrorMessage: signInErrorMessage ?? this.signInErrorMessage,
      marketUser: marketUser ?? this.marketUser,
      getCustomerCountryStatus:
          getCustomerCountryStatus ?? this.getCustomerCountryStatus,
      updateNameStatus: updateNameStatus ?? this.updateNameStatus,
      verifyOtpSignUpStatus:
          verifyOtpSignUpStatus ?? this.verifyOtpSignUpStatus,
      verifyOtpSignInStatus:
          verifyOtpSignInStatus ?? this.verifyOtpSignInStatus,
      verifyOtpFromGuestStatus:
          verifyOtpFromGuestStatus ?? this.verifyOtpFromGuestStatus,
    );
  }
}
