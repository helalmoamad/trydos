

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/authentication/domain/repositories/auth_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class GetCustomerInfoUseCase implements UseCase<User , NoParams>{
  final AuthRepository repository;

  GetCustomerInfoUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getCustomerInfo();
  }

}