import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_provinces_by_iso_model.dart';

import '../repositories/home_repository.dart';

@injectable
class GetProvincesByIsoUseCase
    extends UseCase<GetProvincesByIsoModel, NoParams> {
  final HomeRepository repository;

  GetProvincesByIsoUseCase(this.repository);

  @override
  Future<Either<Failure, GetProvincesByIsoModel>> call(NoParams params) {
    return repository.getProvincesByIso();
  }
}
