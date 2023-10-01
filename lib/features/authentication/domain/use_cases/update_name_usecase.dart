import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_guest_phone_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateNameUseCase implements UseCase<bool, UpdateNameParams> {
  UpdateNameUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(
      UpdateNameParams params) async {
    return repository.updateName(params.map);
  }
}

class UpdateNameParams {
  String name;

  UpdateNameParams({
    required this.name,
  });
  Map<String, dynamic> get map =>{
    "name" :name,
  };
}
