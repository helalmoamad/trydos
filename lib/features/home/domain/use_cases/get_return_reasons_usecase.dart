import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/return_reasons_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class GetReturnReasonsUseCase extends UseCase<ReturnReasonsModel, NoParams> {
  final HomeRepository repository;

  GetReturnReasonsUseCase(this.repository);

  @override
  Future<Either<Failure, ReturnReasonsModel>> call(NoParams params) {
    return repository.getReturnReasons();
  }
}
