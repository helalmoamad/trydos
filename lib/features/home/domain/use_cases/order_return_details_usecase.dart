import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_order_details_return_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class OrderReturnDetailsUseCase
    extends UseCase<GetOrderReturntDetailsModel, GetOrderReturntDetailsParams> {
  final HomeRepository _homeRepository;

  OrderReturnDetailsUseCase(this._homeRepository);

  @override
  Future<Either<Failure, GetOrderReturntDetailsModel>> call(
      GetOrderReturntDetailsParams params) {
    return _homeRepository.getOrderReturnDetails(params.map);
  }
}

class GetOrderReturntDetailsParams {
  final String returnRequestId;

  GetOrderReturntDetailsParams({
    required this.returnRequestId,
  });
  Map<String, dynamic> get map => {
        "return_request_id": returnRequestId,
      };
}
