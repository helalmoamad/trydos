import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/getRelatedProducts.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class GetRelatedProductsUseCase extends UseCase<RelatedProductsResponse, GetRelatedProductsParams> {
  final HomeRepository repository;

  GetRelatedProductsUseCase(this.repository);

  @override
  Future<Either<Failure, RelatedProductsResponse>> call(
    GetRelatedProductsParams params,
  ) {
    return repository.getRelatedProducts(
      productSlug: params.productSlug,
      color: params.color,
    );
  }
}

class GetRelatedProductsParams {
  final int productSlug;
  final String color;

  GetRelatedProductsParams({
    required this.productSlug,
    required this.color,
  });
}