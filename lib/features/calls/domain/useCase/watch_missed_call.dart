import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

@injectable
class WatchMissedCallUseCase extends UseCase<bool, NoParams> {
  final CallsRepository repository;

  WatchMissedCallUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.watchMissedCall();
  }
}
