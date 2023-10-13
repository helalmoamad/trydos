import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/post.dart';

import '../../../../core/api/methods/get.dart';
import '../models/get_stories_model.dart';
import '../models/image_detail.dart';
import '../models/upload_story_response_model.dart';

@injectable
class StoriesDataSource {
  Completer<ImageDetail> completer = Completer<ImageDetail>();

  Future<ImageDetail> loadWidthAndHeightForImage(
      {required String url, Function? onError}) {
    completer = Completer<ImageDetail>();
    Image image;
    image = Image(image: CachedNetworkImageProvider(url),);

    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener(
          (ImageInfo imageInfo,
          bool _,) {
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
    return completer.future;
  }

  Future<GetStoriesModel> getStories() {
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


  Future<UploadStoryResponseModel> uploadStory(Map<String,dynamic> params) {

//Fluttertoast.s
      PostClient<UploadStoryResponseModel> uploadStory =
      PostClient<UploadStoryResponseModel>(requestPrams: RequestConfig<UploadStoryResponseModel>(
        endpoint: StoriesEndPoints.uploadStoriesEP,
        data: params['data'],

        response: ResponseValue<UploadStoryResponseModel>(
            fromJson: (response) => UploadStoryResponseModel.fromJson(response)

        ),
      ), serverName: ServerName.stories,);

    return uploadStory();
  }


}
