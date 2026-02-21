

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class ChangeChatPropertyUseCase extends UseCase<ChangeChatPropertyModel , ChangeChatPropertyParams>{
  final ChatRepository repository;

  ChangeChatPropertyUseCase(this.repository);

  @override
  Future<Either<Failure, ChangeChatPropertyModel>> call(ChangeChatPropertyParams params) {
    return repository.changeChatProperty(params.map);
  }

}
class ChangeChatPropertyParams{
  final String channelId;
  final int? mute;
  final int? pin;
  final int? archive;

  ChangeChatPropertyParams({
    required this.channelId,
    this.archive,
    this.mute,
    this.pin
  });
  Map<String, dynamic> get map =>{
    "channel_id" :channelId,
    "archived" :archive,
    "pin" :pin,
    "mute" :mute,
  };
}