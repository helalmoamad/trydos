import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

@injectable
class UploadFileToS3UseCase
    extends UseCase<ReadOnlyMessageFromApiModel, UploadFileToS3Params> {
  final DashBoardRepository repository;

  UploadFileToS3UseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    UploadFileToS3Params params,
  ) {
    return repository.uploadFileToS3(
      file: params.file,
      uploadUrl: params.uploadUrl,
      mimeType: params.mimeType,
    );
  }
}

class UploadFileToS3Params {
  final File file;
  final String uploadUrl;
  final String mimeType;

  UploadFileToS3Params({
    required this.file,
    required this.uploadUrl,
    required this.mimeType,
  });
}
