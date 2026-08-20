import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DownloadexceltemplateUsecase extends UseCase<String, DownloadexceltemplateParams> {
  final DashBoardRepository repository;

  DownloadexceltemplateUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(DownloadexceltemplateParams params) {
    return repository.downloadexceltemplate(params.categoryId);
  }
}

class DownloadexceltemplateParams {
  final int categoryId;
  DownloadexceltemplateParams({required this.categoryId});
}
