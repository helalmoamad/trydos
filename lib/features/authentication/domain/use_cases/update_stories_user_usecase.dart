
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_guest_phone_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateStoriesUserUseCase implements UseCase<bool, UpdateStoriesUserParams> {
  UpdateStoriesUserUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(
      UpdateStoriesUserParams params) async {
    return repository.updateStoriesUser(params.map);
  }
}

class UpdateStoriesUserParams {
  String name;

  UpdateStoriesUserParams({
    required this.name,
  });
  Map<String, dynamic> get map =>{
    "name" :name,
  };
}
