import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/data/models/update_confirm_return_request_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class CancelReturnRequestProductUseCase extends UseCase<
    UpdateConfirmCancelReturnRequestModel, CancelReturnRequestProductParams> {
  final HomeRepository _homeRepository;

  CancelReturnRequestProductUseCase(this._homeRepository);

  @override
  Future<Either<Failure, UpdateConfirmCancelReturnRequestModel>> call(
      CancelReturnRequestProductParams params) {
    return _homeRepository.cancelReturnRequestProduct(params.map);
  }
}

class CancelReturnRequestProductParams {
  final String returnRequestProductId;
  CancelReturnRequestProductParams({required this.returnRequestProductId});
  Map<String, dynamic> get map => {
        "return_request_product_id": returnRequestProductId,
      };
}
