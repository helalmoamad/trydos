import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpSignUpUseCase implements UseCase<VerifyOtpSignUpAndInResponseModel, VerifyOtpSignUpParams> {
  VerifyOtpSignUpUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
      VerifyOtpSignUpParams params) async {
    return repository.verifyOtpSignUp(params.map);
  }
}

class VerifyOtpSignUpParams {
  String verificationId;
  String otp;
  String? name;

  VerifyOtpSignUpParams({
    required this.verificationId,
    required this.otp,
    this.name,
  });
  Map<String, dynamic> get map =>{
    "otp" :otp,
    "name" :name,
    "verificationId" :verificationId,
  };
}
