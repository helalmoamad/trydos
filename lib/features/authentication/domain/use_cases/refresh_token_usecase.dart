import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a valid (single-use) refresh token for a new
/// access + refresh token pair. `POST /api/v1/auth/refresh-token`.
@injectable
class RefreshTokenUseCase
    implements UseCase<VerifyOtpSignUpAndInResponseModel, RefreshTokenParams> {
  RefreshTokenUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
      RefreshTokenParams params) async {
    return repository.refreshToken(params.map);
  }
}

class RefreshTokenParams {
  final String refreshToken;

  RefreshTokenParams({required this.refreshToken});

  Map<String, dynamic> get map => {"refresh_token": refreshToken};
}
