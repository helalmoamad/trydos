import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetOldCartItemUseCase implements UseCase<GetOldCartModel, NoParams> {
  GetOldCartItemUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetOldCartModel>> call(NoParams params) async {
    return repository.getOldCartItems();
  }
}
