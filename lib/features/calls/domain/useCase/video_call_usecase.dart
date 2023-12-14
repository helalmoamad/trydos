import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

import '../../data/models/video_call_ersponse_model.dart';

@injectable
class VideoCallUseCase extends UseCase<VideoCallRemoteResponseModel, String> {
  final CallsRepository repository;

  VideoCallUseCase(this.repository);

  @override
  Future<Either<Failure, VideoCallRemoteResponseModel>> call(String  ChatId) {
    return repository.videoCall(ChatId: ChatId);
  }
}

