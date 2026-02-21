import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/change_order_address_model.dart';

@injectable
class ChangeOrderAddressUsecase
    extends UseCase<ChangeOrderAddressModel, ChangeOrderAddressParams> {
  final HomeRepository repository;

  ChangeOrderAddressUsecase(this.repository);

  @override
  Future<Either<Failure, ChangeOrderAddressModel>> call(
    ChangeOrderAddressParams params,
  ) {
    return repository.changeOrderAddress(params.map);
  }
}

class ChangeOrderAddressParams {
  final String orderGroupId;
  final String newShippingAddressId;

  ChangeOrderAddressParams({
    required this.orderGroupId,
    required this.newShippingAddressId,
  });

  Map<String, dynamic> get map => {
        "order_group_id": orderGroupId,
        "new_shipping_address_id": newShippingAddressId,
      };
}
