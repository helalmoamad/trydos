

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class SendMessageUseCase extends UseCase<Message , SendMessageParams>{
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) {
    return repository.sendMessage(params.map);
  }

}
class SendMessageParams{
  final int? receiverUserId;
  final String? content;
  final List<Map<String , dynamic>>? mediaContent;
  final String? parentMessageId;
  final String? messageType;
  final bool? isForward;
  final double? imageWidth;
  final double? imageHeight;
  final Map<String , dynamic >? extraFields;

  SendMessageParams({
    this.receiverUserId,
    this.content,
    this.mediaContent,
    this.parentMessageId,
    this.messageType,
    this.isForward,
    this.extraFields,
    this.imageWidth,
    this.imageHeight,
  });
  Map<String, dynamic> get map=> {
    "receiver_user_id": receiverUserId,
    "content": messageType!='TextMessage' ? mediaContent : content,
    "parent_message_id": parentMessageId,
    "message_type": messageType,
    "is_forward":isForward,
    "extra_fields":extraFields,
    "image_original_width":imageWidth,
    "image_original_Height":imageHeight,
  };
  }