import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/create_comment_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class CreateOrderCommentRatingUseCase
    extends UseCase<CreateFqaCommentsModel, CreateOrderCommentRatingParams> {
  final HomeRepository repository;

  CreateOrderCommentRatingUseCase(this.repository);

  @override
  Future<Either<Failure, CreateFqaCommentsModel>> call(
    CreateOrderCommentRatingParams params,
  ) {
    return repository.createOrderCommentRating(params.map);
  }
}

class CreateOrderCommentRatingParams {
  final String? text;
  final String? productId;
  final String? variant;
  final String? rating;
  final String? orderDetailsId;
  final String? ownerType;
  final String? ownerId;
  final String? slug;
  final List<String>? images;
  CreateOrderCommentRatingParams({
    this.text,
    this.productId,
    this.rating,
    this.variant,
    this.ownerType,
    this.ownerId,
    this.images,
    this.slug,
    this.orderDetailsId,
  });
  Map<String, dynamic> get map => {
    "text": text,
    "user_id": GetIt.I<PrefsRepository>().myMarketId,
    "slug": slug,
    "comments_images_customer": images,
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
