import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

@injectable
class RejectCallUseCase extends UseCase<bool, String> {
  final CallsRepository repository;

  RejectCallUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String ChatId) {
    return repository.rejectCall(ChatId);
  }
}


