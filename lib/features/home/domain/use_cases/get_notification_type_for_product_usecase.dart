import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetNotificationTypeProductUseCase
    implements UseCase<NotificationTypeForProductModel, NoParams> {
  GetNotificationTypeProductUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, NotificationTypeForProductModel>> call(
      NoParams params) async {
    return repository.getNotificationTypeForProduct();
  }
}
