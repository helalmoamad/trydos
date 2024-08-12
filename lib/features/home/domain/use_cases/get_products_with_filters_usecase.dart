import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_product_listing_with_filters_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetProductsWithFiltersUseCase
    implements
        UseCase<GetProductListingWithFiltersModel,
            GetProductsWithFiltersParams> {
  GetProductsWithFiltersUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductListingWithFiltersModel>> call(
      GetProductsWithFiltersParams params) async {
    return repository.getProductsWithFilters(params.map);
  }
}

class GetProductsWithFiltersParams {
  final String? category;
  final List<String>? prices;
  final List<String>? brands;
  final List<String>? colors;
  final List<String>? categories;
  final List<Map<String, dynamic>>? attributes;
  final String? searchText;
  final int? offset;
  final int? limit;
  final String? boutiqueSlug;
  final List<String>? boutiqueSlugs;
  final List<String>? categorySlugs;
  final List<String>? brandSlugs;
  GetProductsWithFiltersParams(
      {this.prices,
      this.brands,
      this.boutiqueSlugs,
      this.attributes,
      this.categories,
      this.colors,
      this.boutiqueSlug,
      this.searchText,
      this.offset,
      this.limit,
      this.brandSlugs,
      this.categorySlugs,
      this.category});

  Map<String, dynamic> get map => {
        "category": category,
        "prices": prices.toString(),
        "brands": brands.toString(),
        "attributes": attributes.toString(),
        "categories": categories.toString(),
        "colors": colors.toString(),
        "search_text": searchText,
        "offset": offset,
        "limit": limit,
        "boutique_slug": boutiqueSlug,
        "boutique_slugs": boutiqueSlugs.toString(),
        "category_slugs": categorySlugs.toString(),
        "brand_slugs": brandSlugs.toString()
      }..removeWhere((key, value) =>
          value == null ||
          value == 'null' ||
          value == [''].toString() ||
          value == [].toString() ||
          value == ["search"].toString() ||
          value == ['null'].toString() ||
          value == "");
}
