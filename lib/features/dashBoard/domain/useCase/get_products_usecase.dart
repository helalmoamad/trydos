import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetProductsUseCase extends UseCase<GetSellerProductsModel, NoParams> {
  final DashBoardRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, GetSellerProductsModel>> call(NoParams params) {
    return repository.getProducts();
  }
}
