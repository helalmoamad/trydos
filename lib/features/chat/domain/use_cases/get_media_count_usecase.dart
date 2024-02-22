import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/media_count.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetMediaCountUseCase extends UseCase<MediaCount, GetMediaCountParams> {
  final ChatRepository repository;

  GetMediaCountUseCase(this.repository);

  @override
  Future<Either<Failure, MediaCount>> call(GetMediaCountParams params) {
    return repository.getMediaCount(params.map);
  }
}

class GetMediaCountParams {
  final String channelId;

  const GetMediaCountParams({required this.channelId});
  Map<String, dynamic> get map => {
        "id": channelId,
      };
}
