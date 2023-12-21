

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class ReadAllMessagesUseCase extends UseCase<bool , ReadAllMessagesParams>{
  final ChatRepository repository;

  ReadAllMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ReadAllMessagesParams params) {
    return repository.readAllMessages(params.map);
  }

}
class ReadAllMessagesParams{
  final String channelId;

  ReadAllMessagesParams({
    required this.channelId,
  });
  Map<String, dynamic> get map =>{
    "id" :channelId,
  };
}