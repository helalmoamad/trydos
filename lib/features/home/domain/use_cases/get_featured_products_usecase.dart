import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_product_listing_with_filters_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetFeaturedProductsUseCase
    implements
        UseCase<GetProductListingWithFiltersModel, GetFeaturedProductsParams> {
  GetFeaturedProductsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductListingWithFiltersModel>> call(
      GetFeaturedProductsParams params) async {
    return repository.getFeaturedProducts(params.map);
  }
}

class GetFeaturedProductsParams {
  final List<double>? offset;
  final int? limit;

  GetFeaturedProductsParams({
    this.offset,
    this.limit,
  });

  Map<String, dynamic> get map => {
        "offset": offset.isNullOrEmpty ? null : offset.toString(),
        "limit": "20",
      }..removeWhere((key, value) => value == null || value == 'null');
}
