import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetAllowedCountryUseCase
    implements UseCase<GetAllowedCountriesModel, NoParams> {
  final HomeRepository repository;

  GetAllowedCountryUseCase(this.repository);

  @override
  Future<Either<Failure, GetAllowedCountriesModel>> call(NoParams params) {
    return repository.getAllowCountries();
  }
}
