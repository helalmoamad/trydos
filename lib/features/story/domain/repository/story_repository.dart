import 'package:dartz/dartz.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/story/data/models/upload_story_response_model.dart';

import '../../data/models/get_stories_model.dart';
import '../../data/models/image_detail.dart';

abstract  class StoryRepository
{
Future<Either<Failure,GetStoriesModel>> getStories();

Future<Either<Failure, ImageDetail>> loadWidthAndHeight(
    {required String url});
Future<Either<Failure,UploadStoryResponseModel>> uploadStory(Map<String , dynamic> params);

} 