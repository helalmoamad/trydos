import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/apply_coupon_model.dart';

@injectable
class ApplyCouponUsecase extends UseCase<ApplyCouponModel, String> {
  final HomeRepository repository;

  ApplyCouponUsecase(this.repository);

  @override
  Future<Either<Failure, ApplyCouponModel>> call(
    String code,
  ) {
    return repository.applyCoupon(
      code: code,
    );
  }
}
