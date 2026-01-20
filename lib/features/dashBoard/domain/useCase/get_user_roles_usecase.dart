import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetUserRolesUseCase extends UseCase<GetUserRolesModel, GetUserRolesParams> {
  final DashBoardRepository repository;

  GetUserRolesUseCase(this.repository);

  @override
  Future<Either<Failure, GetUserRolesModel>> call(GetUserRolesParams params) {
    return repository.getUserRoles(search: params.search, page: params.page);
  }
}

class GetUserRolesParams {
  final String? search;
  final int page;

  GetUserRolesParams({this.search, this.page = 1});
}
