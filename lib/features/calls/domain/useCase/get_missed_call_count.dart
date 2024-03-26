import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/calls/data/models/missed_call_count.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetMissedCalCountUseCase extends UseCase<MissedCallCountModel, NoParams> {
  final CallsRepository repository;

  GetMissedCalCountUseCase(this.repository);

  @override
  Future<Either<Failure, MissedCallCountModel>> call(NoParams params) {
    return repository.getMissedCallCount();
  }
}
