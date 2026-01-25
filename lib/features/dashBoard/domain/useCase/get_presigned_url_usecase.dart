import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/get_presigned_url_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

@injectable
class GetPresignedUrlUseCase
    extends UseCase<GetPresignedUrlModel, GetPresignedUrlParams> {
  final DashBoardRepository repository;

  GetPresignedUrlUseCase(this.repository);

  @override
  Future<Either<Failure, GetPresignedUrlModel>> call(
    GetPresignedUrlParams params,
  ) {
    return repository.getPresignedUrl(params.mimeType);
  }
}

class GetPresignedUrlParams {
  final String mimeType;

  GetPresignedUrlParams({required this.mimeType});
}
