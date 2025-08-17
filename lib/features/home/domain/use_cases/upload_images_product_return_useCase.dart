import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'package:trydos/features/home/data/models/upload_images_for_return_product_model.dart';

import 'package:trydos/features/home/data/models/upload_user_photo_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UploadImagesProductReturnUseCase extends UseCase<
    UploadImagesForReturnProductModel, UpdateImagesForReturnProductParams> {
  final HomeRepository repository;

  UploadImagesProductReturnUseCase(this.repository);

  @override
  Future<Either<Failure, UploadImagesForReturnProductModel>> call(
      UpdateImagesForReturnProductParams params) async {
    final Map<String, dynamic> map = await params.map();
    return repository.uploadImagesForReturnProduct(map);
  }
}

class UpdateImagesForReturnProductParams {
  final String path;

  final File image;

  UpdateImagesForReturnProductParams({
    required this.path,
    required this.image,
  });
  Future<Map<String, dynamic>> map() async {
    String fileName = image.path.split('/').last;
    String mimeType = mime(fileName) ?? '';
    String mimee = mimeType.split('/')[0];
    String type = mimeType.split('/')[1];
    return {
      'data': FormData.fromMap({
        "image": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType(mimee, type),
        ),
        "custom_file_path": image.path,
        "path": path
      }),
    };
  }
}
