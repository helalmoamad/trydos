import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/get_vendor_request_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

@injectable
class GetVendorRequestUseCase
    extends UseCase<GetVendorRequestModel, NoParams> {
  final DashBoardRepository repository;

  GetVendorRequestUseCase(this.repository);

  @override
  Future<Either<Failure, GetVendorRequestModel>> call(NoParams params) {
    return repository.getVendorRequest();
  }
}
