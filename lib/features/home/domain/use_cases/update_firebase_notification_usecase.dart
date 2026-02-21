import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateFirebaseNotificationUseCase extends UseCase<
    FirebaseSettingForNotificationModel, UpdateFirebaseNotificationParams> {
  final HomeRepository repository;

  UpdateFirebaseNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>> call(
      UpdateFirebaseNotificationParams params) {
    return repository.updateFirebaseNotification(params.map);
  }
}

class UpdateFirebaseNotificationParams {
  final int firebase;

  UpdateFirebaseNotificationParams({required this.firebase});
  Map<String, dynamic> get map => {"firebase": firebase};
}
