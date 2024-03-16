import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/get_stories_model.dart' ;
import '../repository/story_repository.dart';

@injectable
class AddStoryToOurServerUseCase extends UseCase<Either<int , CollectionStoryModel>,AddStoryToOurServerParams>
{
  final StoryRepository repository;

  AddStoryToOurServerUseCase(this.repository);

  @override
  Future<Either<Failure, Either<int , CollectionStoryModel>>> call(AddStoryToOurServerParams params) {
    return repository.addStoryToOurServer(params.map);
  }


}

class AddStoryToOurServerParams{
  const AddStoryToOurServerParams({required this.filePath , required this.isVideo});

  final String filePath;
  final int isVideo;

  Map<String , dynamic> get map =>{
    'file_path' : filePath,
    'is_video' : isVideo
  };
}