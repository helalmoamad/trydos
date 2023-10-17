import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:trydos/core/data/model/upload_file_cloudinary_response.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../../features/story/data/models/upload_story_cloudinary_response.dart';
import '../../../features/story/domain/repository/story_repository.dart';

@injectable
class UploadFileCloudinaryUseCase extends UseCase<
    UploadFileCloudinaryResponseModel, UploadFileCloudinaryParams> {
  final CommonUseRepository repository;

  UploadFileCloudinaryUseCase(this.repository);

  @override
  Future<Either<Failure, UploadFileCloudinaryResponseModel>> call(
      UploadFileCloudinaryParams params) async {
    // TODO: implement call

    final Map<String, dynamic> map = await params.map();

    return repository.uploadFileCloudinary(map);
  }
}

class UploadFileCloudinaryParams {
  UploadFileCloudinaryParams(
      {required this.file,
      required this.isWhenComplete,
      required this.isSendProgress});

  File file;
  bool isWhenComplete;

  bool isSendProgress;

  Future<Map<String, dynamic>> map() async {
    var data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
      ),
      "upload_preset": CloudinaryUrls.LoadPreset
    });
    return {'data': data ,'isWhenComplete':isWhenComplete,'isSendProgress':isSendProgress };
  }
}
