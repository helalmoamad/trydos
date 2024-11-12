import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_to_chat_response_model.dart';
import '../../data/models/store_fcm_token_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class StoreFcmUseCase implements UseCase<StoreFcmTokenResponseModel, StoreFcmParams> {
  StoreFcmUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, StoreFcmTokenResponseModel>> call(
      StoreFcmParams params) async {
    return repository.storeFcmToken(params.map);
  }
}

class StoreFcmParams {
  int userId;
  String fcmToken;
  ServerName serverName ;

  StoreFcmParams({
    required this.userId,
    required this.fcmToken,
    required this.serverName,
  });
  Map<String, dynamic> get map =>{
    "data": {
      "user_id": userId,
      "token": fcmToken,
    },
    "server_name" : serverName
  };
}
