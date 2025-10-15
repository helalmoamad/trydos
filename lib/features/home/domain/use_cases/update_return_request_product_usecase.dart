import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/update_return_request_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class UpdateReturnRequestProductUseCase extends UseCase<
    UpdateReturnRequestModel, UpdateReturnRequestProductParams> {
  final HomeRepository _homeRepository;

  UpdateReturnRequestProductUseCase(this._homeRepository);

  @override
  Future<Either<Failure, UpdateReturnRequestModel>> call(
      UpdateReturnRequestProductParams params) {
    return _homeRepository.updateReturnRequestProduct(params.map);
  }
}

class UpdateReturnRequestProductParams {
  final String id;

  final String quantity;
  final String returnRequestReasonId;
  final String details;
  final List<String> images;

  UpdateReturnRequestProductParams({
    required this.id,
    required this.quantity,
    required this.returnRequestReasonId,
    required this.details,
    required this.images,
  });
  Map<String, dynamic> get map => {
        "id": id,
        "return_request_reason_id": returnRequestReasonId,
        "quantity": quantity,
        "details": details,
        "images": images,
      };
}
