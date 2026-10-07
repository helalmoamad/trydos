import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ChangeChatPropertyUseCase
    extends UseCase<ChangeChatPropertyModel, ChangeChatPropertyParams> {
  final ChatRepository repository;

  ChangeChatPropertyUseCase(this.repository);

  @override
  Future<Either<Failure, ChangeChatPropertyModel>> call(
    ChangeChatPropertyParams params,
  ) {
    return repository.changeChatProperty(params.map);
  }
}

class ChangeChatPropertyParams {
  final String channelId;
  final int? mute;
  final int? pin;
  final int? archive;
  final int userId;
  final int memberId;

  ChangeChatPropertyParams({
    required this.channelId,
    required this.memberId,
    this.archive,
    this.mute,
    required this.userId,
    this.pin,
  });
  Map<String, dynamic> get map => {
    "channel_id": channelId,
    "archived": archive,
    "user_id": userId,
    "pin": pin,
    "mute": mute,
    "id": memberId,
  };
}
