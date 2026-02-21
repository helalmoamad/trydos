import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/cancel_order_model.dart';

@injectable
class CancelOrderUsecase extends UseCase<CancelOrderModel, CancelOrderParams> {
  final HomeRepository repository;

  CancelOrderUsecase(this.repository);

  @override
  Future<Either<Failure, CancelOrderModel>> call(
    CancelOrderParams params,
  ) {
    return repository.cancelOrder(params.map);
  }
}

class CancelOrderParams {
  final String orderId;

  CancelOrderParams({
    required this.orderId,
  });

  Map<String, dynamic> get map => {
        "order_id": orderId,
      };
}
