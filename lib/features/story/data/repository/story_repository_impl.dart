import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/api.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import 'package:trydos/features/story/data/models/upload_story_cloudinary_response.dart';
import 'package:trydos/features/story/data/models/upload_story_response_model.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repository/story_repository.dart';
import '../data_source/story_data_source.dart';
import '../models/image_detail.dart';

@LazySingleton(as: StoryRepository)
class StoryRepositoryImpl extends StoryRepository
    with HandlingExceptionRequest {
  final StoriesDataSource storyDataSource;

  StoryRepositoryImpl(this.storyDataSource);

  @override
  Future<Either<Failure, GetStoriesModel>> getStories() {
    return handlingExceptionRequest(tryCall: storyDataSource.getStories);
  }

  @override
  Future<Either<Failure, ImageDetail>> loadWidthAndHeight({required String url}) async{
    ImageDetail result = await storyDataSource.loadWidthAndHeightForImage(
        url: url,
        onError: () {
          GetIt.I<StoryBloc>().add(LoadFailureEvent());
        });
    return Right(result);

  }

  @override
  Future<Either<Failure, UploadStoryResponseModel>> uploadStory(Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall:()=> storyDataSource.uploadStory(params) );

  }




}
