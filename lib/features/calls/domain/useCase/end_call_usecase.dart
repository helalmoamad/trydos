import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class EndCallUseCase extends UseCase<bool, EndCallParams> {
  final CallsRepository repository;
  EndCallUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(EndCallParams params) {
    return repository.endCall(params.map);
  }
}

class EndCallParams {
  final String userId;

  EndCallParams({required this.userId});

  Map<String, dynamic> get map => {"user_id": userId};
}
