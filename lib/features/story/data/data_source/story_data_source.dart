import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/post.dart';
import '../../../../core/api/methods/get.dart';
import '../../presentation/bloc/story_bloc.dart';
import '../models/image_detail.dart';
import '../models/upload_story_response_model.dart';
import '../../data/models/get_stories_model.dart';

@injectable
class StoriesDataSource {
  Completer<ImageDetail> completer = Completer<ImageDetail>();
  Future<ImageDetail> loadWidthAndHeightForImage(
      {required String url,
      required int collectionId,
      Function? onError}) async {
    completer = Completer<ImageDetail>();
    Image image;
    image = Image(
      image: CachedNetworkImageProvider(url),
    );
    try {
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener(
            (
              ImageInfo imageInfo,
              bool _,
            ) {
              final dimensions = ImageDetail(
                width: imageInfo.image.width,
                height: imageInfo.image.height,
              );
              if (completer.isCompleted == false) {
                completer.complete(dimensions);
              }
            },
            onError: (exception, stackTrace) {
              if (onError != null) onError();
            },
          ));
    } catch (e, s) {
      GetIt.I<StoryBloc>().add(LoadFailureEvent(collectionId: collectionId));
    }
    return completer.future;
  }

  Future<GetStoriesModel> getStories() {
    ///// for test /////
    TestVariables.getStoriesFlag = true;
    TestVariables.getStoriesRequestCountFlag++;
    ////////////////////
    GetClient<GetStoriesModel> getStories = GetClient<GetStoriesModel>(
      serverName: ServerName.stories,
      requestPrams: RequestConfig<GetStoriesModel>(
        endpoint: StoriesEndPoints.getStoriesEP,
        response: ResponseValue<GetStoriesModel>(
            fromJson: (response) => GetStoriesModel.fromJson(response)),
      ),
    );

    return getStories();
  }

  Future<UploadStoryResponseModel> uploadStory(Map<String, dynamic> params) {
    PostClient<UploadStoryResponseModel> uploadStory =
        PostClient<UploadStoryResponseModel>(
      onSendProgress: (count, total) {},
      requestPrams: RequestConfig<UploadStoryResponseModel>(
        // sendTimeout: Duration(seconds: 10),
        endpoint: StoriesEndPoints.uploadStoriesEP,
        data: params['data'],
        response: ResponseValue<UploadStoryResponseModel>(
            fromJson: (response) =>
                UploadStoryResponseModel.fromJson(response)),
      ),
      serverName: ServerName.stories,
    );
    // uploadStory.call();
    return uploadStory();
  }

  Future<Either<int, CollectionStoryModel>> addStoryToOurServer(
      Map<String, dynamic> params) {
    PostClient<Either<int, CollectionStoryModel>> addStoryToOurServer =
        PostClient<Either<int, CollectionStoryModel>>(
      requestPrams: RequestConfig<Either<int, CollectionStoryModel>>(
          endpoint: StoriesEndPoints.addStoryToOurServerEP,
          data: params,
          response: ResponseValue<Either<int, CollectionStoryModel>>(
              fromJson: (response) {
            if (response['data']['id'] != null)
              return Left(response['data']['id']);
            return Right(CollectionStoryModel.fromJson(response['data']));
          })),
      serverName: ServerName.stories,
    );
    // uploadStory.call();
    return addStoryToOurServer();
  }

  Future<bool> increaseViewers(Map<String, dynamic> params) {
    GetClient<bool> addStoryToOurServer = GetClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: StoriesEndPoints.increaseViewersEP(params['storyId']),
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
      serverName: ServerName.stories,
    );
    // uploadStory.call();
    return addStoryToOurServer();
  }
}
