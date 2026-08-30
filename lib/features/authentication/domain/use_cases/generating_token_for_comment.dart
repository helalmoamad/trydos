import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/refresh_comment_token_response_model.dart';
import 'package:trydos/features/authentication/domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GeneratingTokenForCommentUseCase
    extends
        UseCase<
          RefreshCommentTokenResponseModel,
          GeneratingTokenForCommentParams
        > {
  final AuthRepository repository;
  GeneratingTokenForCommentUseCase(this.repository);
  @override
  Future<Either<Failure, RefreshCommentTokenResponseModel>> call(
    GeneratingTokenForCommentParams params,
  ) {
    return repository.generateTokenForComment(params.map);
  }
}

class GeneratingTokenForCommentParams {
  final String? userId;
  final String? mobilePhone;
  final String? otpIdToken;
  GeneratingTokenForCommentParams(
      {this.userId, this.mobilePhone, this.otpIdToken});
  Map<String, dynamic> get map =>
      {"user_id": userId, "phone": mobilePhone, "id_token": otpIdToken};
}
