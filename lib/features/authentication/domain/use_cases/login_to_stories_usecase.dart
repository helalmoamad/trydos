import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_to_chat_response_model.dart';
import '../../data/models/login_to_stories_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginToStoriesUseCase implements UseCase<LoginToStoriesResponseModel, LoginToStoriesParams> {
  LoginToStoriesUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginToStoriesResponseModel>> call(
      LoginToStoriesParams params) async {
    return repository.loginToStories(params.map);
  }
}

class LoginToStoriesParams {
  String? otpIdToken;
  String? phone;
  String? name;
  String? originalUserId;

  LoginToStoriesParams({
    this.phone,
    this.otpIdToken,
     this.name,
    this.originalUserId,
  });
  Map<String, dynamic> get map =>{
    "otp_id_token" :otpIdToken,
    "mobile_phone" :phone,
    "name" :name,
    "original_user_id" :originalUserId,
  };
}
