

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/data/models/login_to_chat_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class DeleteChatUseCase extends UseCase<bool , DeleteChatParams>{
  final ChatRepository repository;

  DeleteChatUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteChatParams params) {
    return repository.deleteChat(params.map);
  }

}
class DeleteChatParams{
  final String channelId;

  DeleteChatParams({
    required this.channelId,
  });
  Map<String, dynamic> get map =>{
    "id" :channelId,
  };
}