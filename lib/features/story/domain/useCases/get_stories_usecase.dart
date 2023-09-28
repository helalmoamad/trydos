import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/get_stories_model.dart';
import '../repository/story_repository.dart';

@injectable 
class GetStoryUseCase extends UseCase<GetStoriesModel,NoParams>
{
  final StoryRepository repository;

  GetStoryUseCase(this.repository);

  @override
  Future<Either<Failure, GetStoriesModel>> call(NoParams params) {
   return repository.getStories();
  }


}