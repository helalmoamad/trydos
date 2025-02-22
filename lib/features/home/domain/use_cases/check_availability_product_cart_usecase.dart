import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/check_availability_product_cart_model.dart';

@injectable
class CheckAvailabilityProductCartUsecase
    extends UseCase<CheckAvailabilityProductCartModel, NoParams> {
  final HomeRepository repository;

  CheckAvailabilityProductCartUsecase(this.repository);

  @override
  Future<Either<Failure, CheckAvailabilityProductCartModel>> call(
      NoParams params) {
    return repository.checkAvailabilityProductCart();
  }
}
