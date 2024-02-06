import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/get_stories_model.dart';
import '../repository/story_repository.dart';

@injectable
class IncreaseViewersUseCase extends UseCase<bool,IncreaseViewersParams>
{
  final StoryRepository repository;

  IncreaseViewersUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(IncreaseViewersParams params) {
    return repository.increaseViewers(params.map);
  }


}

class IncreaseViewersParams{
  const IncreaseViewersParams({required this.storyId});

  final String storyId;

  Map<String , dynamic> get map =>{
    'storyId' : storyId,
  };
}