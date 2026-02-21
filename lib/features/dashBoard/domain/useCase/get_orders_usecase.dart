import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class GetOrdersParams {
  final int page;
  GetOrdersParams({this.page = 1});
}

@injectable
class GetOrdersUseCase extends UseCase<GetSellerOrdersModel, GetOrdersParams> {
  final DashBoardRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, GetSellerOrdersModel>> call(GetOrdersParams params) {
    return repository.getOrders(page: params.page);
  }
}
