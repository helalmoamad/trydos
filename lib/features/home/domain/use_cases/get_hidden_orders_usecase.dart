import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_hidden_orders_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetHiddenOrdersUseCase extends UseCase<GetHiddenOrdersModel, NoParams> {
  final HomeRepository repository;

  GetHiddenOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, GetHiddenOrdersModel>> call(NoParams params) {
    return repository.getHiddenOrders();
  }
}
