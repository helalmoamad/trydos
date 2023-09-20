import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/send_otp_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_guest_phone_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';

import '../../../../core/api/handling_exception.dart';
import '../../../../core/error/failures.dart';
import '../models/create_user_response_model.dart';
import '../models/login_user_response_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';
import '../models/store_fcm_token_response_model.dart';


@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository with HandlingExceptionRequest {
  AuthRepositoryImpl(this.dataSource);

  final AuthRemoteDatasource dataSource;

  @override
  Future<Either<Failure, CreateUserResponseModel>> createUser(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.createUser(params));
  }

  @override
  Future<Either<Failure, LoginUserResponseModel>> loginUser(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.loginUser(params));
  }

  @override
  Future<Either<Failure, bool>> deleteFcmToken(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.deleteFcmToken(params));
  }

  @override
  Future<Either<Failure, StoreFcmTokenResponseModel>> storeFcmToken(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.storeFcmToken(params));
  }

  @override
  Future<Either<Failure, SendOtpResponseModel>> sendOtp(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.sendOtp(params));
  }


  @override
  Future<Either<Failure, VerifyGuestPhoneResponseModel>> verifyGuestPhone(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.verifyGuestPhone(params));
  }

  @override
  Future<Either<Failure, LoginUserResponseModel>> loginToStore(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.loginToStore(params));
  }

  @override
  Future<Either<Failure, LoginUserResponseModel>> loginToStories(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.loginToStories(params));
  }

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignIn(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.verifyOtpSignIn(params));
  }

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.verifyOtpSignUp(params));
  }

}