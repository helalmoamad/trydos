import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/place_order_model.dart';

@injectable
class PlaceOrderUsecase extends UseCase<PlaceOrderModel, PlaceOrderParams> {
  final HomeRepository repository;

  PlaceOrderUsecase(this.repository);

  @override
  Future<Either<Failure, PlaceOrderModel>> call(
    PlaceOrderParams params,
  ) {
    return repository.placeOrder(
      params: params.map,
      paymentMethod: params.paymentMethod,
    );
  }
}

class PlaceOrderParams {
  final int addressId;
  final String orderNote;
  final String paymentMethod;
  final int payByWallet;

  PlaceOrderParams({
    required this.addressId,
    required this.orderNote,
    required this.paymentMethod,
    required this.payByWallet,
  });
  Map<String, dynamic> get map => {
        "address_id": addressId,
        "order_note": orderNote,
        "pay_by_wallet": payByWallet,
      };
}
