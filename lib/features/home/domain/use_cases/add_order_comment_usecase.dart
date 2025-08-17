import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/order_comment_model.dart';

@injectable
class AddOrderCommentUseCase
    extends UseCase<OrderCommentModel, AddOrderCommentParams> {
  final HomeRepository repository;

  AddOrderCommentUseCase(this.repository);

  @override
  Future<Either<Failure, OrderCommentModel>> call(
      AddOrderCommentParams params) {
    return repository.addOrderComment(params.map);
  }
}

class AddOrderCommentParams {
  final String comment;
  final String customerId;
  final String orderDetailsId;
  final String productId;
  final String starRating;

  AddOrderCommentParams({
    required this.comment,
    required this.customerId,
    required this.orderDetailsId,
    required this.productId,
    required this.starRating,
  });

  Map<String, dynamic> get map => {
        "comment": comment,
        "customer_id": customerId,
        "order_details_id": orderDetailsId,
        "product_id": productId,
        "star_rating": starRating,
      };
}
