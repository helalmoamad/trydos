import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

class ChangeOrderDetailStatusParams {
  final int orderDetailId;
  ChangeOrderDetailStatusParams({
    required this.orderDetailId,
  });
}

@injectable
class ChangeOrderDetailStatusToConfirmedUseCase extends UseCase<NewOrdersResponse, ChangeOrderDetailStatusParams> {
  final DashBoardRepository repository;

  ChangeOrderDetailStatusToConfirmedUseCase(this.repository);

  @override
  Future<Either<Failure, NewOrdersResponse>> call(ChangeOrderDetailStatusParams params) {
    return repository.ChangeOrderDetailStatusToConfirmed({'order_detail_id': params.orderDetailId});
  }
}
