import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class AddUserUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, AddUserParam> {
  final DashBoardRepository repository;

  AddUserUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    AddUserParam params,
  ) {
    return repository.addUser(params.map);
  }
}

class AddUserParam {
  final String phone;
  final String role_id;
  final String seller_id;
  AddUserParam({
    required this.phone,
    required this.role_id,
    required this.seller_id,
  });
  Map<String, dynamic> get map => {
    "phone": phone,
    "role_id": role_id,
    "seller_id": seller_id,
  };
}
