import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/login_to_chat_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class DeleteFcmUseCase implements UseCase<bool, DeleteFcmParams> {
  DeleteFcmUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(
      DeleteFcmParams params) async {
    return repository.deleteFcmToken(params.map);
  }
}

class DeleteFcmParams {
  int fcmTokenId;

  DeleteFcmParams({
    required this.fcmTokenId,
  });
  Map<String, dynamic> get map =>{
    "id" :fcmTokenId,
  };
}
