import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/create_return_request_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class StoreReturnRequestUseCase
    extends UseCase<CreateReturnReqestModel, ReturnRequestParams> {
  final HomeRepository _homeRepository;

  StoreReturnRequestUseCase(this._homeRepository);

  @override
  Future<Either<Failure, CreateReturnReqestModel>> call(
      ReturnRequestParams params) {
    return _homeRepository.storeReturnRequest(params.map);
  }
}

class ReturnRequestParams {
  final String orderId;
  final String isForExchange;
  final String isDraft;

  ReturnRequestParams({
    required this.orderId,
    required this.isForExchange,
    required this.isDraft,
  });
  Map<String, dynamic> get map => {
        "order_id": orderId,
        "is_for_exchange": isForExchange,
        "is_draft": isDraft,
      };
}
