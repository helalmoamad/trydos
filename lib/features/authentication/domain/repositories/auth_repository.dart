import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/create_user_response_model.dart';
import '../../data/models/login_user_response_model.dart';
import '../../data/models/send_otp_response_model.dart';
import '../../data/models/store_fcm_token_response_model.dart';
import '../../data/models/verify_guest_phone_response_model.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure,CreateUserResponseModel>> createUser(Map<String , dynamic> params);
  Future<Either<Failure,LoginUserResponseModel>> loginUser(Map<String , dynamic> params);
  Future<Either<Failure,LoginUserResponseModel>> loginToStore(Map<String , dynamic> params);
  Future<Either<Failure,LoginUserResponseModel>> loginToStories(Map<String , dynamic> params);
  Future<Either<Failure,bool>> deleteFcmToken(Map<String , dynamic> params);
  Future<Either<Failure,StoreFcmTokenResponseModel>> storeFcmToken(Map<String , dynamic> params);
  Future<Either<Failure,SendOtpResponseModel>> sendOtp(Map<String , dynamic> params);
  Future<Either<Failure,VerifyOtpSignUpAndInResponseModel>> verifyOtpSignIn(Map<String , dynamic> params);
  Future<Either<Failure,VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(Map<String , dynamic> params);
  Future<Either<Failure,VerifyGuestPhoneResponseModel>> verifyGuestPhone(Map<String , dynamic> params);
}
