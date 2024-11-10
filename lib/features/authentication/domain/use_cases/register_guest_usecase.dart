import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterGuestUseCase implements UseCase<VerifyOtpSignUpAndInResponseModel, RegisterGuestParams> {
  RegisterGuestUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
      RegisterGuestParams params) async {
    return repository.registerGuest(params.map);
  }
}

class RegisterGuestParams {
  String deviceId;

  RegisterGuestParams({
    required this.deviceId,
  });
  Map<String, dynamic> get map =>{
    "device_id" :deviceId,
  };
}
