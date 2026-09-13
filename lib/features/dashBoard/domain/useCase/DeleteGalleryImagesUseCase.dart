// lib/features/dashBoard/domain/useCase/delete_gallery_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class DeleteGalleryImagesParams {
  final List<int> ids;
  DeleteGalleryImagesParams({required this.ids});
}

@injectable
class DeleteGalleryImagesUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, DeleteGalleryImagesParams> {
  final DashBoardRepository repository;

  DeleteGalleryImagesUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    DeleteGalleryImagesParams params,
  ) {
    return repository.deleteGalleryImages(params.ids);
  }
}