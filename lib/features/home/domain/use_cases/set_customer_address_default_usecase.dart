import 'package:dartz/dartz.dart';

import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SetCustomerAddressDefaultUseCase
    extends UseCase<bool, SetCustomerAddressDefaultParams> {
  final HomeRepository repository;

  SetCustomerAddressDefaultUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetCustomerAddressDefaultParams params) {
    return repository.setCustomerAddressDefault(params.map);
  }
}

class SetCustomerAddressDefaultParams {
  final int addressId;

  SetCustomerAddressDefaultParams({required this.addressId});
  Map<String, dynamic> get map => {
        "address_id": addressId,
      };
}
