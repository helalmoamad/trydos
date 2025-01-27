import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_comment_for_product_model.dart';

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
