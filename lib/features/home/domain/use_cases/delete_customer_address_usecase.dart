import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DeleteCustomerAddressUseCase
    extends UseCase<ResponseOnlyMessageModel, DeleteCustomerAddressParams> {
  final HomeRepository repository;

  DeleteCustomerAddressUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> call(
      DeleteCustomerAddressParams params) {
    return repository.deleteCustomerAddress(params.map);
  }
}

class DeleteCustomerAddressParams {
  final int addressId;

  DeleteCustomerAddressParams({required this.addressId});
  Map<String, dynamic> get map => {
        "address_id": addressId,
      };
}
