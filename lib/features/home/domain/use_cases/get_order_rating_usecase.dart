import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/features/home/data/models/get_order_rating_model.dart'
    as order_rating;
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetOrderRatingUsecase extends UseCase<
    order_rating.GetOrderRatingFromAnalyticsModel, getOrderRatingParams> {
  final HomeRepository repository;

  GetOrderRatingUsecase(this.repository);

  @override
  Future<Either<Failure, order_rating.GetOrderRatingFromAnalyticsModel>> call(
      getOrderRatingParams params) {
    return repository.getOrderRating(params.map);
  }
}

class getOrderRatingParams {
  final List<int>? orderDetailIds;
  final String? userId;
  getOrderRatingParams({this.userId, this.orderDetailIds});
  Map<String, dynamic> get map =>
      {"order_detail_ids": orderDetailIds, "user_id": userId};
}
