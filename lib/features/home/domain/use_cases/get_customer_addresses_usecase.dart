import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetCustomerAddressesUseCase
    implements UseCase<GetListOfCustomerAddressesInfoModel, NoParams> {
  GetCustomerAddressesUseCase(this.repository);
  final HomeRepository repository;
  @override
  Future<Either<Failure, GetListOfCustomerAddressesInfoModel>> call(
      NoParams params) async {
    return repository.getCustomerAddresses();
  }
}
