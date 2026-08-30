import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/refresh_comment_token_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a valid (single-use) comments refresh token for a new
/// access + refresh token pair. `POST public_comment/auth/refresh-token`.
@injectable
class RefreshCommentTokenUseCase
    implements
        UseCase<RefreshCommentTokenResponseModel, RefreshCommentTokenParams> {
  RefreshCommentTokenUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, RefreshCommentTokenResponseModel>> call(
    RefreshCommentTokenParams params,
  ) async {
    return repository.refreshCommentToken(params.map);
  }
}

class RefreshCommentTokenParams {
  final String refreshToken;

  RefreshCommentTokenParams({required this.refreshToken});

  Map<String, dynamic> get map => {"refresh_token": refreshToken};
}
