import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/order_comment_model.dart';

@injectable
class UpdateOrderCommentUseCase
    extends UseCase<OrderCommentModel, UpdateOrderCommentParams> {
  final HomeRepository repository;

  UpdateOrderCommentUseCase(this.repository);

  @override
  Future<Either<Failure, OrderCommentModel>> call(
      UpdateOrderCommentParams params) {
    return repository.updateOrderComment(params.map);
  }
}

class UpdateOrderCommentParams {
  final String comment;
  final String customerId;
  final String id;
  final String orderDetailsId;
  final String productId;
  final String starRating;

  UpdateOrderCommentParams({
    required this.comment,
    required this.customerId,
    required this.id,
    required this.orderDetailsId,
    required this.productId,
    required this.starRating,
  });

  Map<String, dynamic> get map => {
        "comment": comment,
        "customer_id": customerId,
        "id": id,
        "order_details_id": orderDetailsId,
        "product_id": productId,
        "star_rating": starRating,
      };
}
