import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class GetBoutiquesParams {
  final int page;
  GetBoutiquesParams({this.page = 1});
}

@injectable
class GetBoutiquesUseCase extends UseCase<GetSellerBoutiquesModel, GetBoutiquesParams> {
  final DashBoardRepository repository;

  GetBoutiquesUseCase(this.repository);

  @override
  Future<Either<Failure, GetSellerBoutiquesModel>> call(GetBoutiquesParams params) {
    return repository.getBoutiques(page: params.page);
  }
}
