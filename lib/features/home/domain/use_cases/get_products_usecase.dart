import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetProductsWithoutFiltersUseCase
    implements
        UseCase<GetProductListingWithoutFiltersModel,
            GetProductsWithoutFiltersParams> {
  GetProductsWithoutFiltersUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductListingWithoutFiltersModel>> call(
      GetProductsWithoutFiltersParams params) async {
    return repository.getProductsWithoutFilters(params.map);
  }
}

class GetProductsWithoutFiltersParams {
  final String? category;
  final List<String>? prices;
  final List<int>? brands;
  final List<Map<String, dynamic>>? attributes;
  final String? searchText;
  final int? offset;
  final int? limit;
  final String? boutiqueSlug;
  GetProductsWithoutFiltersParams(
      {this.prices,
      this.brands,
      this.attributes,
      this.boutiqueSlug,
      this.searchText,
      this.offset,
      this.limit,
      this.category});

  Map<String, dynamic> get map => {
        "category": category,
        "prices": prices,
        "brands": brands,
        "attributes": attributes,
        "search_text": searchText,
        "offset": offset,
        "limit": limit,
        "boutique_slug": boutiqueSlug
      }..removeWhere((key, value) => value == null);
}
