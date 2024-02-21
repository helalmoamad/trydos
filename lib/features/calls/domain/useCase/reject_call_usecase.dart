import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

@injectable
class RejectCallUseCase extends UseCase<bool, MakeRejectParams> {
  final CallsRepository repository;

  RejectCallUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(MakeRejectParams params) {
    return repository.rejectCall(params.map);
  }
}

class MakeRejectParams {
  final String messageId;
  final int duration;

  MakeRejectParams({required this.messageId, required this.duration});
  Map<String, dynamic> get map => {
        "data": {"duration_in_seconds": duration},
        'messageId': messageId,
      };
}
