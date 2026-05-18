import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/data/model/upload_file_media_server_response.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

@injectable
class UploadFileMediaServerUseCase
    extends
        UseCase<
          UploadFileMediaServerResponseModel,
          UploadFileMediaServerParams
        > {
  final CommonUseRepository repository;

  UploadFileMediaServerUseCase(this.repository);

  @override
  Future<Either<Failure, UploadFileMediaServerResponseModel>> call(
    UploadFileMediaServerParams params,
  ) async {
    final Map<String, dynamic> map = await params.map();
    return repository.uploadFileMediaServer(map);
  }
}

class UploadFileMediaServerParams {
  UploadFileMediaServerParams({
    required this.file,
    this.folder,
    this.isStory = false,
    required this.usingOnUploadingFinishedFunction,
    required this.usingSendProgressFunction,
  });

  File file;
  String? folder;
  bool isStory = false;
  bool usingOnUploadingFinishedFunction;
  bool usingSendProgressFunction;

  Future<Map<String, dynamic>> map() async {
    final Map<String, dynamic> formFields = {
      "file": await MultipartFile.fromFile(file.path),
    };
    if (folder != null && folder!.isNotEmpty) {
      formFields["folder"] = folder!;
    }
    var data = FormData.fromMap(formFields);
    return {
      'data': data,
      'isStory': isStory,
      'usingOnUploadingFinishedFunction': usingOnUploadingFinishedFunction,
      'usingSendProgressFunction': usingSendProgressFunction,
    };
  }
}
