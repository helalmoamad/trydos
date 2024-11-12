import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_product_filters_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetProductFiltersUseCase
    implements UseCase<GetProductFiltersModel, GetProductsFiltersParams> {
  GetProductFiltersUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetProductFiltersModel>> call(
      GetProductsFiltersParams params) async {
    return repository.getProductFilters(params.map);
  }
}

class GetProductsFiltersParams {
  final String? category;
  final List<String>? prices;
  final List<String>? brands;
  final List<String>? colors;
  final List<Map<String, dynamic>>? attributes;
  final String? searchText;
  final String? offset;
  //final int? offset;
  final int? limit;
  final String? scroll_id;
  final String? boutiqueSlug;
  final List<String>? boutiqueSlugs;
  final List<String>? categorySlugs;
  final List<String>? brandSlugs;
  GetProductsFiltersParams(
      {this.prices,
      this.brands,
      this.boutiqueSlugs,
      this.attributes,
      this.colors,
      this.boutiqueSlug,
      this.searchText,
      this.scroll_id,
      this.offset,
      this.limit,
      this.brandSlugs,
      this.categorySlugs,
      this.category});

  Map<String, dynamic> get map => {
        "category": category,
        "price": prices.toString(),
        "brands": brands.toString(),
        "attributes": attributes.toString(),
        "colors": colors.toString(),
        "search_text":
            searchText == "" || searchText == null ? null : '"${searchText}"',
        "offset": " ",
        // "scroll_id": scroll_id,
        "with_products": '${false}',
        //"limit": "10",
        "boutique_slug": boutiqueSlug,
        "boutique_slugs": boutiqueSlugs.toString(),
        "category_slugs": categorySlugs.toString(),
        "brand_slugs": brandSlugs.toString()
      }..removeWhere((key, value) =>
          value == null ||
          value == 'null' ||
          value == [].toString() ||
          value == [''].toString() ||
          value == ["null"].toString() ||
          value == ["search"].toString() ||
          value == "");
}
