

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/my_chats_response_model.dart';
@injectable
class GetMyChatsUseCase extends UseCase<MyChatsResponseModel , GetMyChatsParams>{
  final ChatRepository repository;

  GetMyChatsUseCase(this.repository);

  @override
  Future<Either<Failure, MyChatsResponseModel>> call(GetMyChatsParams params) {
    return repository.getChats(params.map);
  }

}

class GetMyChatsParams{
  final DateTime? timeStamp;
  final int? limit;
  final int? messagesLimit;
  const GetMyChatsParams({this.timeStamp , this.limit , this.messagesLimit});

  Map<String , dynamic> get map => {
   'limit' : limit.toString(),
   'messages_limit' : messagesLimit.toString(),
   'timestamp' : timeStamp?.toIso8601String(),
  }..removeWhere((key, value) => value == 'null' || value == null);
}