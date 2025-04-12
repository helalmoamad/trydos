import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_orders_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetOrdersUseCase implements UseCase<OrderModel, GetOrdersParams> {
  GetOrdersUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, OrderModel>> call(
      GetOrdersParams getOrdersParams) async {
    return repository.getOrders(
      params: getOrdersParams.map,
    );
  }
}

class GetOrdersParams {
  final int offset;
  final String? status;

  GetOrdersParams({
    required this.offset,
    required this.status,
  });

  Map<String, dynamic> get map => {
        "offset": offset.toString(),
        "limit": '10',
        "order_status": status,
      };
}
