

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/my_chats_response_model.dart';
@injectable
class GetMessagesBetweenUseCase extends UseCase<List<Message> , GetMessagesBetweenParams>{
  final ChatRepository repository;

  GetMessagesBetweenUseCase(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesBetweenParams params) {
    return repository.getMessagesBetween(params.map);
  }

}
class GetMessagesBetweenParams{
  final String channelId;
  final String firstMessageId;
  final String secondMessageId;
  const GetMessagesBetweenParams( {required this.firstMessageId,
    required this.secondMessageId,
    required this.channelId});
  Map<String, dynamic> get map =>{
      "channel_id": channelId,
      "first_message_id": firstMessageId,
      "second_message_id": secondMessageId,
  };
}