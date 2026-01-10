import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class DeleteFcmFromChatUseCase implements UseCase<bool, DeleteFcmParams> {
  DeleteFcmFromChatUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(DeleteFcmParams params) async {
    return repository.deleteFcmTokenFromChat(params.map);
  }
}

class DeleteFcmParams {
  String fcmToken;

  DeleteFcmParams({required this.fcmToken});
  Map<String, dynamic> get map => {"token": fcmToken};
}
