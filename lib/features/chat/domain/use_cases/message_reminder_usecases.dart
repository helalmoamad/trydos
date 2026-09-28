import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/message_reminder_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// ينشئ تذكيراً على رسالة، أو يحدّث وقت تذكير قائم.
///
/// إن كان للرسالة تذكير نشط يُحدَّث وقته ويبقى `id` كما هو — فلا حاجة لحذف
/// القديم أوّلاً.
@injectable
class CreateMessageReminderUseCase
    extends UseCase<MessageReminderItem, CreateMessageReminderParams> {
  final ChatRepository repository;

  CreateMessageReminderUseCase(this.repository);

  @override
  Future<Either<Failure, MessageReminderItem>> call(
    CreateMessageReminderParams params,
  ) {
    return repository.createMessageReminder(params.map);
  }
}

class CreateMessageReminderParams {
  final String messageId;
  final DateTime remindAt;

  CreateMessageReminderParams({
    required this.messageId,
    required this.remindAt,
  });

  /// `remind_at` بصيغة ISO8601 وبالتوقيت العالمي: الخادم يرفض الماضي، وإرسال
  /// وقت محلي بلا منطقة زمنية يجعل القبول رهن فارق ساعات الجهاز.
  Map<String, dynamic> get map => {
    "message_id": messageId,
    "remind_at": remindAt.toUtc().toIso8601String(),
  };
}

/// تذكيراتي التي لم يحن وقتها بعد، الأقرب أولاً.
@injectable
class GetMyRemindersUseCase
    extends UseCase<List<MessageReminderItem>, NoParams> {
  final ChatRepository repository;

  GetMyRemindersUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageReminderItem>>> call(NoParams params) {
    return repository.getMyReminders();
  }
}

/// يلغي تذكيراً. يأخذ **معرّف التذكير** لا معرّف الرسالة.
@injectable
class DeleteMessageReminderUseCase
    extends UseCase<bool, DeleteMessageReminderParams> {
  final ChatRepository repository;

  DeleteMessageReminderUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteMessageReminderParams params) {
    return repository.deleteMessageReminder(params.map);
  }
}

class DeleteMessageReminderParams {
  final String reminderId;

  DeleteMessageReminderParams({required this.reminderId});

  Map<String, dynamic> get map => {"reminder_id": reminderId};
}
