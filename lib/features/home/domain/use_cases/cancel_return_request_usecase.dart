import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/confirm_return_request_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class CancelReturnRequestUseCase extends UseCase<
    ConfirmCancelReturnRequestModel, CancelReturnRequestParams> {
  final HomeRepository _homeRepository;

  CancelReturnRequestUseCase(this._homeRepository);

  @override
  Future<Either<Failure, ConfirmCancelReturnRequestModel>> call(
      CancelReturnRequestParams params) {
    return _homeRepository.cancelReturnRequest(params.map);
  }
}

class CancelReturnRequestParams {
  final List<String> returnRequestId;
  CancelReturnRequestParams({required this.returnRequestId});
  Map<String, dynamic> get map => {
        "return_request_ids": returnRequestId.toSet().toList(),
      };
}
