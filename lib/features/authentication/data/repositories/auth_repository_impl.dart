import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/handling_exception.dart';
import '../../../../core/error/failures.dart';
import '../../../chat/data/models/create_user_response_model.dart';
import '../../../chat/data/models/login_user_response_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';


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

}