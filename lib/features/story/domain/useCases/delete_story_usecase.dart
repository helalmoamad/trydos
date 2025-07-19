import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/story/data/models/delete_story_model.dart';

import '../repository/story_repository.dart';

@injectable
class DeleteStoryUseCase extends UseCase<DeleteStoryModel, DeleteStoryParams> {
  final StoryRepository repository;

  DeleteStoryUseCase(this.repository);

  @override
  Future<Either<Failure, DeleteStoryModel>> call(DeleteStoryParams params) {
    return repository.deleteStory(params.map);
  }
}

class DeleteStoryParams {
  const DeleteStoryParams({required this.storyId});

  final String storyId;

  Map<String, dynamic> get map => {'story_id': storyId};
}
