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
  final int? offset;
  final int? limit;
  final String? boutiqueSlug;
  final List<String>? prices;
  final List<String>? brands;
  final List<String>? colors;
  final List<String>? categories;
  final List<Map<String, dynamic>>? attributes;

  GetProductsFiltersParams(
      {this.boutiqueSlug,
      this.offset,
      this.prices,
      this.brands,
      this.attributes,
      this.categories,
      this.colors,
      this.limit,
      this.category});

  Map<String, dynamic> get map => {
        "category": category,
        "offset": offset,
        "limit": limit,
        "prices": prices.toString(),
        "brands": brands.toString(),
        "attributes": attributes.toString(),
        "categories": categories.toString(),
        "colors": colors.toString(),
        "boutique_slug": boutiqueSlug
      };
}
