import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_boundary_cordinates_by_iso_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class CountryBoundaryByIsoUseCase
    implements UseCase<CountryBoundaryByIsoModel, NoParams> {
  CountryBoundaryByIsoUseCase(this.repository);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final HomeRepository repository;

  @override
  Future<Either<Failure, CountryBoundaryByIsoModel>> call(
      NoParams params) async {
    String? iso = prefsRepository.userCountryIsAvailable == 1
        ? prefsRepository.userChoosedCountryIso
        : prefsRepository.countryIso;
    return repository.getCountryBoundaryByIso(iso ?? "");
  }
}
