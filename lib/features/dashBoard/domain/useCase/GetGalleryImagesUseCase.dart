// lib/features/dashBoard/domain/useCase/get_gallery_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/GetGalleryImagesModel.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class GetGalleryImagesParams {
  final int page;
  final int perPage;
  final String? search;
  GetGalleryImagesParams({this.page = 1, this.perPage = 20, this.search});
}

@injectable
class GetGalleryImagesUseCase
    extends UseCase<GetGalleryImagesModel, GetGalleryImagesParams> {
  final DashBoardRepository repository;

  GetGalleryImagesUseCase(this.repository);

  @override
  Future<Either<Failure, GetGalleryImagesModel>> call(
    GetGalleryImagesParams params,
  ) {
    return repository.getGalleryImages(
      page: params.page,
      perPage: params.perPage,
      search: params.search,
    );
  }
}