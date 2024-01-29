import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

import '../../data/models/agora_token_remote_response_model.dart';
import '../../data/models/make_call_response_model.dart';

@injectable
class GetAgoraTokenUseCase extends UseCase<GetAgoraTokenResponseModel, String> {
  final CallsRepository repository;

  GetAgoraTokenUseCase(this.repository);

  @override
  Future<Either<Failure, GetAgoraTokenResponseModel>> call(String  ChatId) {
    return repository.getAgoraToken(ChatId: ChatId);
  }
}

