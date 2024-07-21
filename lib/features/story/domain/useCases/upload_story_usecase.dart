
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/features/story/domain/repository/story_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/upload_story_response_model.dart';

@injectable
class UploadStoryUseCase extends UseCase<UploadStoryResponseModel , UploadStoryParams>{
  final StoryRepository repository;

  UploadStoryUseCase(this.repository);

  @override
  Future<Either<Failure, UploadStoryResponseModel>> call(UploadStoryParams params) async {


      final Map<String,dynamic>   map=await params.map();
      return repository.uploadStory(map);


  }
}
class UploadStoryParams{

  UploadStoryParams({required this.file });
  File file;
  Future<Map<String, dynamic>> map() async {

    String fileName = file.path.split('/').last;
    String mimeType = mime(fileName) ?? '';
    String mimee = mimeType.split('/')[0];
    int checkWitherVideoOrNot=mimee=='image'?0:1;
    String type = mimeType.split('/')[1];

    return {
      'data': FormData.fromMap(
          {
            "file": await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType(mimee, type),
            ),
            "is_video": checkWitherVideoOrNot
          }
      )
    };
  }
}