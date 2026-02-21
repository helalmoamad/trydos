import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateOrderCommentRatingUseCase
    extends UseCase<ResponseOnlyMessageModel, UpdateOrderCommentRatingParams> {
  final HomeRepository repository;

  UpdateOrderCommentRatingUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> call(
    UpdateOrderCommentRatingParams params,
  ) {
    return repository.updateOrderCommentRating(params.map);
  }
}

class UpdateOrderCommentRatingParams {
  final String? text;
  final String? productId;
  final String? variant;
  final String? rating;
  final String? orderDetailsId;
  final String? commentId;
  final String? ownerType;
  final String? ownerId;
  final String? slug;
  final List<String>? images;

  UpdateOrderCommentRatingParams({
    this.text,
    this.productId,
    this.rating,
    this.commentId,
    this.ownerType,
    this.ownerId,
    this.images,
    this.slug,
    this.variant,
    this.orderDetailsId,
  });
  Map<String, dynamic> get map => {
    "id": commentId,
    "text": text,
    "slug": slug,
    "comments_images_customer": images,
    "user_id": GetIt.I<PrefsRepository>().myMarketId,
    "phone": GetIt.I<PrefsRepository>().myPhoneNumber,
    "user_avatar": GetIt.I<PrefsRepository>().myProfilePhoto
        ?.split("/v1")
        .toList()
        .last,
    "product_id": productId,
    "user_type": (GetIt.I<PrefsRepository>().isVerifiedPhone ?? false)
        ? "user"
        : "customer",
    "user_name": GetIt.I<PrefsRepository>().myMarketName,
    "variant": variant,
    "rating": rating,
    "order_details_id": orderDetailsId,
    "owner_type": ownerType,
    "owner_id": ownerId,
  };
}
