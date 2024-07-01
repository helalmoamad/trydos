import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_product_filters_model.dart';
import '../repositories/home_repository.dart';
@injectable
class GetProductFiltersUseCase implements UseCase< GetProductFiltersModel, NoParams> {
  GetProductFiltersUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductFiltersModel>> call(
      NoParams params) async {
    return repository.getProductFilters();
  }
}
