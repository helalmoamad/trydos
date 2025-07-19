import 'package:dartz/dartz.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/story/data/models/upload_story_response_model.dart';
import 'package:trydos/features/story/data/models/delete_story_model.dart';

import '../../data/models/image_detail.dart';
import '../../data/models/get_stories_model.dart';

abstract class StoryRepository {
  Future<Either<Failure, GetStoriesModel>> getStories(
      Map<String, dynamic> params);
  Future<Either<Failure, Either<int, CollectionStoryModel>>>
      addStoryToOurServer(Map<String, dynamic> params);
  Future<Either<Failure, bool>> increaseViewers(Map<String, dynamic> params);
  Future<Either<Failure, ImageDetail>> loadWidthAndHeight(
      {required String url, required int collectionId});
  Future<Either<Failure, Either<int, CollectionStoryModel>>> uploadStory(
      Map<String, dynamic> params);
  Future<Either<Failure, DeleteStoryModel>> deleteStory(
      Map<String, dynamic> params);
}
