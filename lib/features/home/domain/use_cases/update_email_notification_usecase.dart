import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateEmailNotificationUseCase extends UseCase<
    FirebaseSettingForNotificationModel, UpdateEmailNotificationParams> {
  final HomeRepository repository;

  UpdateEmailNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>> call(
      UpdateEmailNotificationParams params) {
    return repository.updateEmailNotification(params.map);
  }
}

class UpdateEmailNotificationParams {
  final int email;

  UpdateEmailNotificationParams({required this.email});
  Map<String, dynamic> get map => {"email": email};
}
