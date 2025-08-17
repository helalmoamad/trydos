import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class OrderReturnRequestsViewUseCase extends UseCase<
    ReadOnlyMessageFromApiModel, OrderReturnRequestsViewParams> {
  final HomeRepository _homeRepository;

  OrderReturnRequestsViewUseCase(this._homeRepository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
      OrderReturnRequestsViewParams params) {
    return _homeRepository.orderReturnRequestsView(params.map);
  }
}

class OrderReturnRequestsViewParams {
  final String returnRequestId;

  OrderReturnRequestsViewParams({
    required this.returnRequestId,
  });
  Map<String, dynamic> get map => {
        "return_request_id": returnRequestId,
      };
}
