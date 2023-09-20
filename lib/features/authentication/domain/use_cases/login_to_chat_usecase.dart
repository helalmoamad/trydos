import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_user_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginToChatUseCase implements UseCase<LoginUserResponseModel, LoginToChatParams> {
  LoginToChatUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginUserResponseModel>> call(
      LoginToChatParams params) async {
    return repository.loginUser(params.map);
  }
}

class LoginToChatParams {
  String? mobilePhone;
  String? password;

  LoginToChatParams({
    this.mobilePhone,
    this.password,
  });
  Map<String, dynamic> get map =>{
    "mobile_phone" :mobilePhone,
    "password" :password,
  };
}
