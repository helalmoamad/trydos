import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_user_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginToStoriesUseCase implements UseCase<LoginUserResponseModel, LoginToStoriesParams> {
  LoginToStoriesUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginUserResponseModel>> call(
      LoginToStoriesParams params) async {
    return repository.loginToStories(params.map);
  }
}

class LoginToStoriesParams {
  String? otpIdToken;
  String? phone;

  LoginToStoriesParams({
    this.phone,
    this.otpIdToken,
  });
  Map<String, dynamic> get map =>{
    "otp_id_token" :phone,
    "mobile_phone" :phone,
  };
}
