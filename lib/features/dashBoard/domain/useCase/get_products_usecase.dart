import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

class GetProductsParams {
  final int page;
  GetProductsParams({this.page = 1});
}

@injectable
class GetProductsUseCase extends UseCase<GetSellerProductsModel, GetProductsParams> {
  final DashBoardRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, GetSellerProductsModel>> call(GetProductsParams params) {
    return repository.getProducts(page: params.page);
  }
}
