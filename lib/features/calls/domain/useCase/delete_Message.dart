import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DeleteMessageUseCase extends UseCase<bool, DeleteMessageParams> {
  final CallsRepository repository;

  DeleteMessageUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteMessageParams params) {
    return repository.deleteMessage(params.map);
  }
}

class DeleteMessageParams {
  final String messageId;
  final int deleteFromAll;
  DeleteMessageParams({
    required this.deleteFromAll,
    required this.messageId,
  });
  Map<String, dynamic> get map =>
      {"id": messageId, "delete_for_all": deleteFromAll};
}
