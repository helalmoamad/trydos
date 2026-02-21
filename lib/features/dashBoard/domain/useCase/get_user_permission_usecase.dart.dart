import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetUserPermissionUseCase
    extends UseCase<GetUserPermissionModel, NoParams> {
  final DashBoardRepository repository;

  GetUserPermissionUseCase(this.repository);

  @override
  Future<Either<Failure, GetUserPermissionModel>> call(NoParams params) {
    return repository.getUserPermission();
  }
}
