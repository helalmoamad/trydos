import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `POST {STORIES_API}/api/v1/stories/add-seller-story`
class CreateSellerStoryParams {
  /// The logged-in user id (NOT the shop id).
  final int userId;

  /// The shop the story belongs to.
  final int sellerId;

  /// Full media url: `MEDIA_SERVER_URL` + the path returned by the upload.
  final String filePath;
  final bool isVideo;
  final String? link;
  final int? productId;
  final String? productSlug;

  /// Note the singular `second` in the json key — that is what the API expects.
  final int videoDurationInSecond;
  final int? orderDetailId;

  const CreateSellerStoryParams({
    required this.userId,
    required this.sellerId,
    required this.filePath,
    required this.isVideo,
    this.link,
    this.productId,
    this.productSlug,
    this.videoDurationInSecond = 0,
    this.orderDetailId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'seller_id': sellerId,
    'file_path': filePath,
    'is_video': isVideo ? 1 : 0,
    'link': (link != null && link!.trim().isNotEmpty) ? link!.trim() : null,
    'product_id': productId,
    'product_slug': productSlug,
    'video_duration_in_second': videoDurationInSecond,
    'order_detail_id': orderDetailId,
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
