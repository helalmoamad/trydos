import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateUserRoleUseCase extends UseCase<ReadOnlyMessageFromApiModel, UpdateUserRoleParams> {
  final DashBoardRepository repository;

  UpdateUserRoleUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(UpdateUserRoleParams params) {
    return repository.updateUserRole({
      'user_id': params.userId,
      'role_id': params.roleId,
    });
  }
}

class UpdateUserRoleParams {
  final String userId;
  final String roleId;

  UpdateUserRoleParams({
    required this.userId,
    required this.roleId,
  });
}
