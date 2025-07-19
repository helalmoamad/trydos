import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/cancel_order_item_model.dart';

@injectable
class CancelOrderItemUsecase
    extends UseCase<CancelOrderItemModel, CancelOrderItemParams> {
  final HomeRepository repository;

  CancelOrderItemUsecase(this.repository);

  @override
  Future<Either<Failure, CancelOrderItemModel>> call(
    CancelOrderItemParams params,
  ) {
    return repository.cancelOrderItem(params.map);
  }
}

class CancelOrderItemParams {
  final String orderId;
  final String detailId;
  final String qty;

  CancelOrderItemParams({
    required this.orderId,
    required this.detailId,
    required this.qty,
  });

  Map<String, dynamic> get map => {
        "order_id": orderId,
        "detail_id": detailId,
        "qty": qty,
      };
}
