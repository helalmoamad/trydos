import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetProductDetailWithoutRelatedProductsUseCase
    implements UseCase<GetProductDetailWithoutRelatedProductsModel, String> {
  GetProductDetailWithoutRelatedProductsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>> call(
      String productId) async {
    return repository.getProductDetailWithoutSimilarRelatedProducts(productId);
  }
}
