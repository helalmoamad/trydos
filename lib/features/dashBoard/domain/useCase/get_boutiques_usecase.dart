import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetBoutiquesUseCase extends UseCase<GetSellerBoutiquesModel, NoParams> {
  final DashBoardRepository repository;

  GetBoutiquesUseCase(this.repository);

  @override
  Future<Either<Failure, GetSellerBoutiquesModel>> call(NoParams params) {
    return repository.getBoutiques();
  }
}
