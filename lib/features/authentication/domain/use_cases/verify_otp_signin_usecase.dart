import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../../../service/notification_service/notification_service/handle_notification/notification_process.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpSignInUseCase implements UseCase<VerifyOtpSignUpAndInResponseModel, VerifyOtpSignInParams> {
  VerifyOtpSignInUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
      VerifyOtpSignInParams params) async {
    return repository.verifyOtpSignIn(params.map);
  }
}

class VerifyOtpSignInParams {
  String verificationId;
  String otp;

  VerifyOtpSignInParams({
    required this.verificationId,
    required this.otp,
  });
  Map<String, dynamic> get map =>{
    "otp" :otp,
    "verificationId" :verificationId,
  };
}
