import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_guest_phone_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyGuestPhoneUseCase implements UseCase<VerifyGuestPhoneResponseModel, VerifyGuestPhoneParams> {
  VerifyGuestPhoneUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyGuestPhoneResponseModel>> call(
      VerifyGuestPhoneParams params) async {
    return repository.verifyGuestPhone(params.map);
  }
}

class VerifyGuestPhoneParams {
  String idToken;

  VerifyGuestPhoneParams({
    required this.idToken,
  });
  Map<String, dynamic> get map =>{
    "id_token" :idToken,
  };
}
