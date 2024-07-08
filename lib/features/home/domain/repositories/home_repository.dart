import 'package:dartz/dartz.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/get_product_filters_model.dart';
import '../../data/models/get_product_listing_with_filters_model.dart';
import '../../data/models/get_story_for_product_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings();
  Future<Either<Failure, GetCartShippingItemsModel>> getCartShippingItem();

  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories();
  Future<Either<Failure, GetProductFiltersModel>> getProductFilters(Map<String, dynamic> params);
  /* Future<Either<Failure, HomeSectionResponseModel>> getHomeSections(
      Map<String, dynamic> params);*/
  Future<Either<Failure, GetHomeBoutiquesModel>> getHomeBoutiqes(
      Map<String, dynamic> params);
  Future<Either<Failure, GetStoryForProductModel>> getStories(String productId);
  Future<Either<Failure, GetProductListingWithoutFiltersModel>>
      getProductsWithoutFilters(Map<String, dynamic> params);
  Future<Either<Failure, GetProductListingWithFiltersModel>>
  getProductsWithFilters(Map<String, dynamic> params);
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>>
      getProductDetailWithoutSimilarRelatedProducts(String productId);
  Future<Either<Failure, GetCommentForProductModel>> geCommentForProduct(
      String productId);
  Future<Either<Failure, bool>> addItemToCart(Map<String, dynamic> params);
}
