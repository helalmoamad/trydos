import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class GetUsersParams {
  final int page;
  GetUsersParams({this.page = 1});
}

@injectable
class GetUsersUseCase extends UseCase<GetUsersModel, GetUsersParams> {
  final DashBoardRepository repository;

  GetUsersUseCase(this.repository);

  @override
  Future<Either<Failure, GetUsersModel>> call(GetUsersParams params) {
    return repository.getUsers(page: params.page);
  }
}
