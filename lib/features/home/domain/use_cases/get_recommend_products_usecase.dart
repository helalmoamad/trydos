import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_product_listing_with_filters_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetRecommendProductsUseCase
    implements
        UseCase<GetProductListingWithFiltersModel, GetRecommendProductsParams> {
  GetRecommendProductsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductListingWithFiltersModel>> call(
    GetRecommendProductsParams params,
  ) async {
    return repository.getRecommendedProducts(params.map);
  }
}

class GetRecommendProductsParams {
  final List<double>? offset;
  final int? limit;
  final List<String>? categorySlugs;
  GetRecommendProductsParams({this.offset, this.limit, this.categorySlugs});

  Map<String, dynamic> get map =>
      {
        "offset": offset.isNullOrEmpty ? null : offset.toString(),
        "limit": "10",
        "user_id": GetIt.I<PrefsRepository>().myMarketId,
        "category_slugs": categorySlugs.toString(),
      }..removeWhere(
        (key, value) => value == null || value == 'null' || value == '',
      );
}
