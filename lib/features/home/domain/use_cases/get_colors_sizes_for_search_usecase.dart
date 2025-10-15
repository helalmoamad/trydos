import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_colors_and_sizes_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetColorsAndSizesForSearchUseCase
    implements UseCase<GeColorsAndSizesForSearchModel, NoParams> {
  GetColorsAndSizesForSearchUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GeColorsAndSizesForSearchModel>> call(
      NoParams params) async {
    return repository.getColorsAndSizesForSearch();
  }
}
