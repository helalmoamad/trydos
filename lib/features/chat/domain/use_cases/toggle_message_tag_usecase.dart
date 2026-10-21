import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/message_tag_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// يضيف وسماً إلى رسالة أو يزيله.
///
/// الوسم مشترك بين أعضاء القناة: الخادم يبثّ `UpdatingMessageEvent` إلى بقية
/// الأعضاء بعد التغيير — بعكس التذكير الشخصي.
@injectable
class ToggleMessageTagUseCase
    extends UseCase<MessageTagToggleResult, ToggleMessageTagParams> {
  final ChatRepository repository;

  ToggleMessageTagUseCase(this.repository);

  @override
  Future<Either<Failure, MessageTagToggleResult>> call(
    ToggleMessageTagParams params,
  ) {
    return repository.toggleMessageTag(params.map);
  }
}

class ToggleMessageTagParams {
  final String messageId;
  final String tag;

  /// `true` إضافة، `false` إزالة.
  final bool add;

  ToggleMessageTagParams({
    required this.messageId,
    required this.tag,
    required this.add,
  });

  /// الوسم مقلَّم ومحدود بـ[MessageTag.maxLength]: الخادم يرفض ما تجاوزه
  /// بـ400، ومسافةٌ زائدة تصنع وسماً ثانياً يبدو مطابقاً للعين.
  Map<String, dynamic> get map => {
    "message_id": messageId,
    "tag": normalizeTag(tag),
    "action": add ? "add" : "remove",
  };

  /// يوحّد صيغة الوسم قبل الإرسال أو المقارنة.
  static String normalizeTag(String value) {
    final String trimmed = value.trim();
    return trimmed.length > MessageTag.maxLength
        ? trimmed.substring(0, MessageTag.maxLength)
        : trimmed;
  }
}
