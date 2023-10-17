


import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/upload_story_cloudinary_response.dart';
import '../repository/story_repository.dart';

@injectable
class UploadStoryCloudinaryUseCase extends UseCase<UploadStoryCloudinaryResponseModel,UploadStoryCloudinaryParams>
{

  final StoryRepository repository;
  UploadStoryCloudinaryUseCase(this.repository);


  @override
  Future<Either<Failure, UploadStoryCloudinaryResponseModel>> call(UploadStoryCloudinaryParams params) async{
    // TODO: implement call

    final Map<String,dynamic> map=await params.map();

    return repository.uploadCloudinaryStory(map);



  }

}
class UploadStoryCloudinaryParams{


  UploadStoryCloudinaryParams({required this.file });
  File file;
  Future<Map<String, dynamic>> map() async {
var data=FormData.fromMap(
    {
      "file": await MultipartFile.fromFile(
        file.path,
      ),
      "upload_preset": CloudinaryUrls.LoadPreset
    }
);
    return {
      'data': data
    };
  }}
