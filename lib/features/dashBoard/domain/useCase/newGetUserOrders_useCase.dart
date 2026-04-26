import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class NewGetOrdersParams {
  final int page;
  final String? status;
  NewGetOrdersParams({this.page = 1, this.status});
}

@injectable
class NewGetOrdersUseCase
    extends UseCase<NewOrdersResponse, NewGetOrdersParams> {
  final DashBoardRepository repository;

  NewGetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, NewOrdersResponse>> call(NewGetOrdersParams params) {
    return repository.newGetOrders(page: params.page, status: params.status);
  }
}
