import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

class ChangeOrderDetailStatusToPackedParams {
  final int orderDetailId;
  ChangeOrderDetailStatusToPackedParams({
    required this.orderDetailId,
  });
}

@injectable
class ChangeOrderDetailStatusToPackedUseCase extends UseCase<NewOrdersResponse, ChangeOrderDetailStatusToPackedParams> {
  final DashBoardRepository repository;

  ChangeOrderDetailStatusToPackedUseCase(this.repository);

  @override
  Future<Either<Failure, NewOrdersResponse>> call(ChangeOrderDetailStatusToPackedParams params) {
    return repository.ChangeOrderDetailStatusToPacked({'order_detail_id': params.orderDetailId});
  }
}
