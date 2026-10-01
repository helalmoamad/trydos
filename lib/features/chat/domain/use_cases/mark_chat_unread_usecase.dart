import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/channel_unread_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// يعلّم محادثة كغير مقروءة.
///
/// يرفع الخادم العدّاد إلى واحد **على الأقل**، ولا يرسل إشعاراً لأحد. والعودة
/// إلى «مقروءة» تتمّ بمسار القراءة القائم `ReadAllMessagesEvent`.
@injectable
class MarkChatUnreadUseCase
    extends UseCase<ChannelUnreadModel, MarkChatUnreadParams> {
  final ChatRepository repository;

  MarkChatUnreadUseCase(this.repository);

  @override
  Future<Either<Failure, ChannelUnreadModel>> call(
    MarkChatUnreadParams params,
  ) {
    return repository.markChatUnread(params.map);
  }
}

class MarkChatUnreadParams {
  final String channelId;

  MarkChatUnreadParams({required this.channelId});

  /// المعرّف يذهب في المسار لا في الجسم — الطلب بلا جسم إطلاقاً.
  Map<String, dynamic> get map => {"channel_id": channelId};
}
