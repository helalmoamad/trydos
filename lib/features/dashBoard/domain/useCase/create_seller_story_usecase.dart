import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class CreateSellerStoryParams {
  /// The S3 object key returned by the shared upload flow
  /// (`UploadDocumentEvent` -> `getPresignedUrl` -> `uploadFileToS3`).
  final String mediaKey;
  final String? link;

  CreateSellerStoryParams({required this.mediaKey, this.link});

  Map<String, dynamic> toJson() => {
    'key': mediaKey,
    if (link != null && link!.isNotEmpty) 'link': link,
  };
}

@injectable
class CreateSellerStoryUseCase
    extends UseCase<SellerStoryModel, CreateSellerStoryParams> {
  final DashBoardRepository repository;

  CreateSellerStoryUseCase(this.repository);

  @override
  Future<Either<Failure, SellerStoryModel>> call(
    CreateSellerStoryParams params,
  ) {
    return repository.createSellerStory(params.toJson());
  }
}
