import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpInProfileUseCase
    implements
        UseCase<VerifyOtpInProfileResponseModel, VerifyOtpInProfileParams> {
  VerifyOtpInProfileUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpInProfileResponseModel>> call(
      VerifyOtpInProfileParams params) async {
    return repository.verifyOtpInProfile(params.map);
  }
}

class VerifyOtpInProfileParams {
  String verificationId;
  String otp;

  VerifyOtpInProfileParams({
    required this.verificationId,
    required this.otp,
  });
  Map<String, dynamic> get map => {
        "otp": otp,
        "verificationId": verificationId,
      };
}
