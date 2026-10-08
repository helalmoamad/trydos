

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

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

  /// `true` يجلب **المؤرشفة وحدها**، وغيابه يجلب غير المؤرشفة وحدها.
  ///
  /// **منطقي هنا** (`boolean`)، بعكس نقطة الأرشفة نفسها التي تأخذ `0|1`
  /// رقماً. النوع الخطأ في أيّهما يعيد 400.
  final bool? archived;

  const GetMyChatsParams({
    this.timeStamp,
    this.limit,
    this.messagesLimit,
    this.archived,
  });

  Map<String , dynamic> get map => {
   'limit' : limit.toString(),
   'messages_limit' : messagesLimit.toString(),
   'timestamp' : timeStamp?.toIso8601String(),
   if (archived != null) 'archived' : archived,
  }..removeWhere((key, value) => value == 'null' || value == null);
}