

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class CreateUserUseCase implements UseCase<CreateUserResponseModel , CreateUserParams>{
  final ChatRepository repository;

  CreateUserUseCase(this.repository);

  @override
  Future<Either<Failure, CreateUserResponseModel>> call(CreateUserParams params) {
     return repository.createUser(params.map);
  }

}
class CreateUserParams{
  String? name;
  String? mobilePhone;
  String? password;

  CreateUserParams({
    this.name,
    this.mobilePhone,
    this.password,
  });
  Map<String, dynamic> get map =>{
    "name":name,
    "mobilePhone" :mobilePhone,
    "password" :password,
  };
}