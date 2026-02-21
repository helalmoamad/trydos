
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/upload_file_response_model.dart';
import '../repositories/chat_repository.dart';

@injectable
class UploadFileUseCase extends UseCase<UploadFileResponseModel , UploadFileParams>{
  final ChatRepository repository;

  UploadFileUseCase(this.repository);

  @override
  Future<Either<Failure, UploadFileResponseModel>> call(UploadFileParams params) async {
    final Map<String,dynamic> map=await params.map();
    return repository.uploadFile(map);
  }

}
class UploadFileParams{

  UploadFileParams(this.file , this.filePath);
  File file;
  final String filePath;
  Future<Map<String, dynamic>> map() async {
    String fileName = file.path.split('/').last;
    String mimeType = mime(fileName) ?? '';
    String mimee = mimeType.split('/')[0];
    String type = mimeType.split('/')[1];
    return {
      'data': FormData.fromMap(
          {
            "file": await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType(mimee, type),
            ),
            "custom_file_path": filePath
          }
      )
    };
  }
}