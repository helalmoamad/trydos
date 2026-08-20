import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/getExcelCategoriesModel.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

@injectable
class GetexcelcategoriesUsecase extends UseCase<GetExcelCategoriesModel, NoParams> {
  final DashBoardRepository repository;

  GetexcelcategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, GetExcelCategoriesModel>> call(NoParams noParams) {
    return repository.getCategories();
  }
}
