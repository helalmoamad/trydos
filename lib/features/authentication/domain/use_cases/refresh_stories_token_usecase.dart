import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/refresh_stories_token_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a valid (single-use) stories refresh token for a new
/// access + refresh token pair. `POST /api/v1/auth/refresh-token`.
///
/// The stories server answers this call **without** the usual
/// `{isSuccessful, code, data}` envelope, so it has its own response model
/// instead of the stories login one.
@injectable
class RefreshStoriesTokenUseCase
    implements
        UseCase<RefreshStoriesTokenResponseModel, RefreshStoriesTokenParams> {
  RefreshStoriesTokenUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, RefreshStoriesTokenResponseModel>> call(
    RefreshStoriesTokenParams params,
  ) async {
    return repository.refreshStoriesToken(params.map);
  }
}

class RefreshStoriesTokenParams {
  final String refreshToken;

  RefreshStoriesTokenParams({required this.refreshToken});

  Map<String, dynamic> get map => {"refresh_token": refreshToken};
}
