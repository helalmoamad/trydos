import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateNotificationFrequencyUseCase extends UseCase<
    FirebaseSettingForNotificationModel, UpdateNotificationFrequencyParams> {
  final HomeRepository repository;

  UpdateNotificationFrequencyUseCase(this.repository);

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>> call(
      UpdateNotificationFrequencyParams params) {
    return repository.updateNotificationFrequency(params.map);
  }
}

class UpdateNotificationFrequencyParams {
  final String notificationFrequency;

  UpdateNotificationFrequencyParams({required this.notificationFrequency});
  Map<String, dynamic> get map =>
      {"notification_frequency": notificationFrequency};
}
