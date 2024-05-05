import 'package:dartz/dartz.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';

import '../../../../core/error/failures.dart';

abstract class HomeRepository {
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings();
  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories();
  Future<Either<Failure, HomeSectionResponseModel>> getHomeSections(
      Map<String, dynamic> params);
  Future<Either<Failure, GetProductListingWithoutFiltersModel>>
      getProductsWithoutFilters(Map<String, dynamic> params);
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>>
      getProductDetailWithoutSimilarRelatedProducts(String productId);
}
