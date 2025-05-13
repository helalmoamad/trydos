import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_boundary_cordinates_by_iso_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class CountryBoundaryByIsoUseCase
    implements UseCase<CountryBoundaryByIsoModel, NoParams> {
  CountryBoundaryByIsoUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, CountryBoundaryByIsoModel>> call(
      NoParams params) async {
    return repository.getCountryBoundaryByIso();
  }
}
