import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DeleteUserUseCase extends UseCase<ReadOnlyMessageFromApiModel, DeleteUserParams> {
  final DashBoardRepository repository;

  DeleteUserUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(DeleteUserParams params) {
    return repository.deleteUser(params.userId);
  }
}

class DeleteUserParams {
  final String userId;

  DeleteUserParams({required this.userId});
}
