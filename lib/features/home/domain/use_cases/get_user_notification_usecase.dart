import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_user_notifications_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetUserNotificationUseCase
    implements UseCase<GetUserNotificationsModel, int> {
  GetUserNotificationUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetUserNotificationsModel>> call(int page) async {
    return repository.getUserNotifications(page: page);
  }
}
