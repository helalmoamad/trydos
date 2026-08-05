import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/login_to_chat_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a valid (single-use) refresh token for a new
/// access + refresh token pair. `POST /api/v1/auth/refresh-token`.
@injectable
class RefreshChatTokenUseCase
    implements UseCase<LoginToChatResponseModel, RefreshChatTokenParams> {
  RefreshChatTokenUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginToChatResponseModel>> call(
    RefreshChatTokenParams params,
  ) async {
    return repository.refreshChatToken(params.map);
  }
}

class RefreshChatTokenParams {
  final String refreshToken;

  RefreshChatTokenParams({required this.refreshToken});

  Map<String, dynamic> get map => {"refresh_token": refreshToken};
}
