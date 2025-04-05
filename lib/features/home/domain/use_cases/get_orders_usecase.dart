import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_orders_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetOrdersUseCase implements UseCase<OrderModel, int> {
  GetOrdersUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, OrderModel>> call(int offset) async {
    return repository.getOrders(offset: offset);
  }
}
