import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SubscribeTopicFornotificationUseCase extends UseCase<
    FirebaseSettingForNotificationModel, SubscribeTopicForNotificationParams> {
  final HomeRepository repository;

  SubscribeTopicFornotificationUseCase(this.repository);

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>> call(
      SubscribeTopicForNotificationParams params) {
    return repository.subscribeTopicFornotification(params.map);
  }
}

class SubscribeTopicForNotificationParams {
  final String topic;

  SubscribeTopicForNotificationParams({required this.topic});
  Map<String, dynamic> get map => {"topic": topic};
}
