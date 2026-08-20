import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/UploadedExcelFileModel.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

@injectable
class GetUploadedExcelFilesUsecase
    extends
        UseCase<UploadedExcelFilesResponseModel, GetUploadedExcelFilesParams> {
  final DashBoardRepository repository;

  GetUploadedExcelFilesUsecase(this.repository);

  @override
  Future<Either<Failure, UploadedExcelFilesResponseModel>> call(
    GetUploadedExcelFilesParams params,
  ) {
    return repository.getUploadedExcelFiles(page: params.page);
  }
}

class GetUploadedExcelFilesParams {
  final int page;
  GetUploadedExcelFilesParams({this.page = 1});
}
