import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/upload_images_for_return_product_model.dart';

import 'package:trydos/features/home/data/models/upload_user_photo_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SearchByImageFromGeminiUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, SearchByImagesParams> {
  final HomeRepository repository;

  SearchByImageFromGeminiUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
      SearchByImagesParams params) async {
    final Map<String, dynamic> map = await params.map();
    return repository.searchByImageFromGemini(map);
  }
}

class SearchByImagesParams {
  final File image;

  SearchByImagesParams({
    required this.image,
  });
  Future<Map<String, dynamic>> map() async {
    String fileName = image.path.split('/').last;
    String mimeType = mime(fileName) ?? '';
    String mimee = mimeType.split('/')[0];
    String type = mimeType.split('/')[1];
    return {
      'data': FormData.fromMap({
        "file": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType(mimee, type),
        ),
        "custom_file_path": image.path,
        "prompt":
            "Describe the product most clearly shown in this picture with no more than 5 words like: T-shirt black xxl",
        "language": LanguageService.languageCode
      }),
    };
  }
}
