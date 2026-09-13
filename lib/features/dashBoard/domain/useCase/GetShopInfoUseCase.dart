import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/GetShopInfoModel.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetShopInfoUseCase extends UseCase<GetShopInfoModel, NoParams> {
  final DashBoardRepository repository;

  GetShopInfoUseCase(this.repository);

  @override
  Future<Either<Failure, GetShopInfoModel>> call(NoParams params) {
    return repository.getShopInfo();
  }
}
