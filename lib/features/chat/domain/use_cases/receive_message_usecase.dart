

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class ReceiveMessageUseCase extends UseCase<bool , ReceiveMessageParams>{
  final ChatRepository repository;

  ReceiveMessageUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ReceiveMessageParams params) {
    return repository.receiveMessage(params.map);
  }

}
class ReceiveMessageParams{
  final String channelId;

  ReceiveMessageParams({
    required this.channelId,
  });
  Map<String, dynamic> get map =>{
    "id" :channelId,
  };
}