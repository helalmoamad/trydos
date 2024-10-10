import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_comment_for_product_model.dart';
import '../repositories/home_repository.dart';

@injectable
class RequestForNotificationWhenProductBecameAvailableUseCase
    implements UseCase<bool, RequestForNotificationWhenProductBecameAvailableParams> {
  RequestForNotificationWhenProductBecameAvailableUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, bool>> call(
      RequestForNotificationWhenProductBecameAvailableParams params) async {
    return repository.requestForNotificationWhenProductBecameAvailable(params.map);
  }
}

class RequestForNotificationWhenProductBecameAvailableParams {
  final String productId;
  final int notificationTypeId;
  final String variant;
  final String userId;

  RequestForNotificationWhenProductBecameAvailableParams(this.productId, this.notificationTypeId, this.variant, this.userId);

  Map<String, dynamic> get map =>
      {
        "product_id": productId,
        "user_id": userId,
        "variant": variant,
        "notification_type_id": notificationTypeId,
      };
}