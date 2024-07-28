/*import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetCategoryUseCase implements UseCase<GetCategoryModel, NoParams> {
  GetCategoryUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetCategoryModel>> call(NoParams params) async {
    return repository.getCategory();
  }
}
*/