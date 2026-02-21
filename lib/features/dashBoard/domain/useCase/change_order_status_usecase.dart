import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ChangeOrderStatusUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, ChangeOrderParams> {
  final DashBoardRepository repository;

  ChangeOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    ChangeOrderParams params,
  ) {
    return repository.changeOrderStatus(params.map);
  }
}

class ChangeOrderParams {
  final int order_id;
  final String status;
  ChangeOrderParams({required this.order_id, required this.status});
  Map<String, dynamic> get map => {"id": order_id, "status": status};
}
