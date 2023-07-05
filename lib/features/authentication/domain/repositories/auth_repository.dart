import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../chat/data/models/create_user_response_model.dart';
import '../../../chat/data/models/login_user_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure,CreateUserResponseModel>> createUser(Map<String , dynamic> params);
  Future<Either<Failure,LoginUserResponseModel>> loginUser(Map<String , dynamic> params);
}
