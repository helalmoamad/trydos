
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_guest_phone_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateChatUserNameUseCase implements UseCase<bool, UpdateChatUserNameParams> {
  UpdateChatUserNameUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(
      UpdateChatUserNameParams params) async {
    return repository.updateChatUserName(params.map);
  }
}

class UpdateChatUserNameParams {
  String name;

  UpdateChatUserNameParams({
    required this.name,
  });
  Map<String, dynamic> get map =>{
    "name" :name,
  };
}
