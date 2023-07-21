import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_user_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase implements UseCase<LoginUserResponseModel, LoginParams> {
  LoginUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginUserResponseModel>> call(
      LoginParams params) async {
    return repository.loginUser(params.map);
  }
}

class LoginParams {
  String? mobilePhone;
  String? password;

  LoginParams({
    this.mobilePhone,
    this.password,
  });
  Map<String, dynamic> get map =>{
    "mobile_phone" :mobilePhone,
    "password" :password,
  };
}
