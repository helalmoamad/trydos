import 'package:dartz/dartz.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/authentication/data/models/login_to_stories_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/create_user_response_model.dart';
import '../../data/models/get_user_country_response_model.dart';
import '../../data/models/login_to_chat_response_model.dart';
import '../../data/models/send_otp_response_model.dart';
import '../../data/models/store_fcm_token_response_model.dart';
import '../../data/models/verify_guest_phone_response_model.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, CreateUserResponseModel>> createUser(
      Map<String, dynamic> params);
  Future<Either<Failure, LoginToChatResponseModel>> loginToChat(
      Map<String, dynamic> params);
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> loginToMarket(
      Map<String, dynamic> params);
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> registerGuest(
      Map<String, dynamic> params);
  Future<Either<Failure, LoginToStoriesResponseModel>> loginToStories(
      Map<String, dynamic> params);
  Future<Either<Failure, bool>> updateName(Map<String, dynamic> params);
  Future<Either<Failure, bool>> updateChatUserName(Map<String, dynamic> params);
  Future<Either<Failure, bool>> updateStoriesUser(Map<String, dynamic> params);
  Future<Either<Failure, bool>> deleteFcmToken(Map<String, dynamic> params);
  Future<Either<Failure, User>> getCustomerInfo();

  Future<Either<Failure, GetUserCountryResponseModel>> getUserCountry();
  Future<Either<Failure, StoreFcmTokenResponseModel>> storeFcmToken(
      Map<String, dynamic> params);
  Future<Either<Failure, SendOtpResponseModel>> sendOtp(
      Map<String, dynamic> params);
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignIn(
      Map<String, dynamic> params);
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(
      Map<String, dynamic> params);
  Future<Either<Failure, VerifyGuestPhoneResponseModel>> verifyGuestPhone(
      Map<String, dynamic> params);
}
