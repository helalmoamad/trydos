import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// تعديل نص رسالة نصية مُرسَلة.
///
/// يعيد الخادم الرسالة كاملة بعد التعديل، فنستبدل بها النسخة المحلية بدل
/// تركيب النص يدوياً — هكذا تصل معها الحقول التي يضيفها الخادم (`updated_at`،
/// `is_edited`) بلا عمل إضافي.
@injectable
class UpdateMessageUseCase extends UseCase<Message, UpdateMessageParams> {
  final ChatRepository repository;

  UpdateMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Message>> call(UpdateMessageParams params) {
    return repository.updateMessage(params.map);
  }
}

class UpdateMessageParams {
  final String messageId;
  final String content;

  UpdateMessageParams({required this.messageId, required this.content});

  /// هذان الحقلان فقط — الخادم يعيد 400 على أي حقل زائد.
  Map<String, dynamic> get map => {"id": messageId, "content": content};
}
