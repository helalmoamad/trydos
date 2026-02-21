import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SendMessageUseCase extends UseCase<Message, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) {
    return repository.sendMessage(params.map);
  }
}

class SendMessageParams {
  final int? receiverUserId;
  final String? content;
  final List<Map<String, dynamic>>? mediaContent;
  final String? parentMessageId;
  final String? messageType;
  final bool? isForward;

  final String? orderChatParticipantId;
  final String? channelId;

  final Map<String, dynamic>? extraFields;

  SendMessageParams({
    this.receiverUserId,
    this.content,
    this.mediaContent,
    this.channelId,
    this.parentMessageId,
    this.orderChatParticipantId,
    this.messageType,
    this.isForward,
    this.extraFields,
  });
  Map<String, dynamic> get map => {
    "receiver_user_id": receiverUserId,
    "order_chat_participant_id": orderChatParticipantId,
    "content": messageType != 'TextMessage' ? mediaContent : content,
    "parent_message_id": parentMessageId,
    "message_type": messageType,
    "cid": channelId,
    "is_forward": isForward,
    "extra_fields": extraFields,
  };
}
