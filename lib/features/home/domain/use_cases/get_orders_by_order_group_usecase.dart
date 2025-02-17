import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/place_order_model.dart';

@injectable
class GetOrdersByOrderGroupIDUsecase extends UseCase<OrdersGroupModel, String> {
  final HomeRepository repository;

  GetOrdersByOrderGroupIDUsecase(this.repository);

  @override
  Future<Either<Failure, OrdersGroupModel>> call(
    String orderGroupIdD,
  ) {
    return repository.getOrdersByOrderGroupID(
      orderGroupIdD: orderGroupIdD,
    );
  }
}
