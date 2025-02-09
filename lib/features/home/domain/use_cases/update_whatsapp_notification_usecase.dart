import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateWhatsappNotificationUseCase extends UseCase<
    FirebaseSettingForNotificationModel, UpdateWhatsappNotificationParams> {
  final HomeRepository repository;

  UpdateWhatsappNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>> call(
      UpdateWhatsappNotificationParams params) {
    return repository.updateWhatsappNotification(params.map);
  }
}

class UpdateWhatsappNotificationParams {
  final int whatsapp;

  UpdateWhatsappNotificationParams({required this.whatsapp});
  Map<String, dynamic> get map => {"whatsapp": whatsapp};
}
