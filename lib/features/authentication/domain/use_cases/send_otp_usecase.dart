import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/send_otp_response_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_to_chat_response_model.dart';
import '../../data/models/store_fcm_token_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtpUseCase implements UseCase<SendOtpResponseModel, SendOtpParams> {
  SendOtpUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, SendOtpResponseModel>> call(
      SendOtpParams params) async {
    return repository.sendOtp(params.map);
  }
}

class SendOtpParams {
  int isViaWhatsApp;
  String phone; // start with +

  SendOtpParams({
    required this.phone,
    required this.isViaWhatsApp,
  });
  Map<String, dynamic> get map =>{
    "phone" :'${phone}',
    "is_via_whatsapp" :isViaWhatsApp.toString(),
  };
}
