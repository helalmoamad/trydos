

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class SendMessageUseCase extends UseCase<bool , SendMessageParams>{
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendMessageParams params) {
    return repository.sendMessage(params.map);
  }

}
class SendMessageParams{
  final int? receiverUserId;
  final int? receiverRoleId;
  final int? senderRoleId;
  final String? content;
  final List<Map<String , dynamic>>? mediaContent;
  final int? parentMessageId;
  final String? messageType;
  final bool? isForward;
  final Map<String , dynamic >? extraFields;

  SendMessageParams({
    this.receiverUserId,
    this.receiverRoleId,
    this.senderRoleId,
    this.content,
    this.mediaContent,
    this.parentMessageId,
    this.messageType,
    this.isForward,
    this.extraFields,
  });
  Map<String, dynamic> get map=> {
    "receiver_user_id": receiverUserId,
    "receiver_role_id":receiverRoleId,
    "sender_role_id":senderRoleId,
    "content": messageType!='TextMessage' ? mediaContent : content,
    "parent_message_id": parentMessageId,
    "message_type": messageType,
    "is_forward":isForward,
    "extra_fields":extraFields
  };
  }