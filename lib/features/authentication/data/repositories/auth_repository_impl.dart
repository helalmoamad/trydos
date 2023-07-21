import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

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

}