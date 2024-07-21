import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/authentication/domain/repositories/auth_repository.dart';
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
