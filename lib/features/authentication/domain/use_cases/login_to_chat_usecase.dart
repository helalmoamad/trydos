import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_to_chat_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginToChatUseCase implements UseCase<LoginToChatResponseModel, LoginToChatParams> {
  LoginToChatUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginToChatResponseModel>> call(
      LoginToChatParams params) async {
    return repository.loginToChat(params.map);
  }
}

class LoginToChatParams {
  String? mobilePhone;
  String? otpIdToken;
  String? originalUserId;
  String? name;

  LoginToChatParams({
    this.mobilePhone,
    this.otpIdToken,
    this.originalUserId,
    this.name,
  });
  Map<String, dynamic> get map =>{
    "mobile_phone" :mobilePhone,
    "otp_id_token" :otpIdToken,
    "name" :name,
    "original_user_id" :originalUserId,
  };
}
