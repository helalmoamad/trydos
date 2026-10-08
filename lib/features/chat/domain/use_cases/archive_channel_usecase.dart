import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/channel_archive_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// يؤرشف محادثة أو يلغي أرشفتها.
///
/// الأرشفة شخصية للمستخدم الحالي: لا يراها بقيّة الأعضاء، ولا يُرسل إشعار.
/// وهذا يعني أيضاً أنها **لا تُزامَن بين أجهزة المستخدم نفسه** إلّا عند إعادة
/// جلب `my_channels`.
@injectable
class ArchiveChannelUseCase
    extends UseCase<ChannelArchiveModel, ArchiveChannelParams> {
  final ChatRepository repository;

  ArchiveChannelUseCase(this.repository);

  @override
  Future<Either<Failure, ChannelArchiveModel>> call(
    ArchiveChannelParams params,
  ) {
    return repository.archiveChannel(params.map);
  }
}

class ArchiveChannelParams {
  final String channelId;
  final bool archived;

  ArchiveChannelParams({required this.channelId, required this.archived});

  /// `archived` **رقم** `0|1`. الخادم يرفض `"false"` نصّاً بـ400، ونرسلها
  /// صراحةً دائماً بدل الاتّكال على الافتراضي (`1`).
  Map<String, dynamic> get map => {
    "channel_id": channelId,
    "archived": archived ? 1 : 0,
  };
}
