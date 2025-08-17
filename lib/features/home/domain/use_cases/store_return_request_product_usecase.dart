import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/return_request_product_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class StoreReturnRequestProductUseCase extends UseCase<
    StoreReturnRequestProductModel, ReturnRequestProductParams> {
  final HomeRepository _homeRepository;

  StoreReturnRequestProductUseCase(this._homeRepository);

  @override
  Future<Either<Failure, StoreReturnRequestProductModel>> call(
      ReturnRequestProductParams params) {
    return _homeRepository.storeReturnRequestProduct(params.map);
  }
}

class ReturnRequestProductParams {
  final String productId;
  final String orderDetailId;
  final String returnRequestId;
  final String isForExchange;
  final String quantity;
  final String returnRequestReasonId;
  final String details;
  final List<String> images;

  ReturnRequestProductParams({
    required this.productId,
    required this.orderDetailId,
    required this.returnRequestId,
    required this.isForExchange,
    required this.quantity,
    required this.returnRequestReasonId,
    required this.details,
    required this.images,
  });
  Map<String, dynamic> get map => {
        "product_id": productId,
        "order_detail_id": orderDetailId,
        "return_request_id": returnRequestId,
        "is_for_exchange": isForExchange,
        "quantity": quantity,
        "return_request_reason_id": returnRequestReasonId,
        "details": details,
        "images": images,
      };
}
