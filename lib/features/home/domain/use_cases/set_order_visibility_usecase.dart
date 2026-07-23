import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SetOrderVisibilityUseCase extends UseCase<bool, SetOrderVisibilityParams> {
  final HomeRepository repository;

  SetOrderVisibilityUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetOrderVisibilityParams params) {
    return repository.setOrderVisibility(params.orderId, params.map);
  }
}

class SetOrderVisibilityParams {
  final String orderId;
  final bool isHidden;

  SetOrderVisibilityParams({required this.orderId, this.isHidden = true});

  Map<String, dynamic> get map => {"is_hidden": isHidden};
}

@injectable
class SetOrderDetailVisibilityUseCase
    extends UseCase<bool, SetOrderDetailVisibilityParams> {
  final HomeRepository repository;

  SetOrderDetailVisibilityUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetOrderDetailVisibilityParams params) {
    return repository.setOrderDetailVisibility(params.detailId, params.map);
  }
}

class SetOrderDetailVisibilityParams {
  final String detailId;
  final bool isHidden;

  SetOrderDetailVisibilityParams({required this.detailId, this.isHidden = true});

  Map<String, dynamic> get map => {"is_hidden": isHidden};
}
