

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/my_chats_response_model.dart';
@injectable
class GetMessagesForChatUseCase extends UseCase<List<Message> , GetMessagesForChatParams>{
  final ChatRepository repository;

  GetMessagesForChatUseCase(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesForChatParams params) {
    return repository.getMessagesForChat(params.map);
  }

}
class GetMessagesForChatParams{
  final int lastMessageId;
  final int limit;
  final String channelId;
  const GetMessagesForChatParams({
    required this.lastMessageId ,
    required this.limit,
    required this.channelId,
  });
  Map<String, dynamic> get map =>{
    'data': {
      "message_id": lastMessageId,
      "limit": limit
    },
    'params':channelId
  };
}