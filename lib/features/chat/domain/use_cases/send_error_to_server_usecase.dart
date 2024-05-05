import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SendErrorToServerUseCase extends UseCase<bool, SendErrorParams> {
  final ChatRepository repository;

  SendErrorToServerUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendErrorParams params) {
    return repository.SendErrorChatToServer(params.map);
  }
}

class SendErrorParams {
  String error;
  String pageName;

  SendErrorParams({required this.error, required this.pageName});
  Map<String, dynamic> get map =>
      {"error_description": error, "error_page": pageName};
}
