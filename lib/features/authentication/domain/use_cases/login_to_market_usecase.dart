import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_user_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginToMarketUseCase implements UseCase<LoginUserResponseModel, LoginToMarketParams> {
  LoginToMarketUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginUserResponseModel>> call(
      LoginToMarketParams params) async {
    return repository.loginToStore(params.map);
  }
}

class LoginToMarketParams {
  String? phone;
  String? deviceId;
  String? password;

  LoginToMarketParams({
    this.phone,
    this.password,
    this.deviceId,
  });
  Map<String, dynamic> get map =>{
    "phone" :phone,
    "password" :password,
    "device_id" :deviceId,
    //"password" :password,x
  };
}
