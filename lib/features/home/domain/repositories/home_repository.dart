import 'package:dartz/dartz.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/convert_item_from_oldCart_to_cart_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_brand_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_count_likes_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_count_view_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_is_liked_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/list_of_products_in_cart_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/get_full_product_details_model.dart';
import '../../data/models/get_product_filters_model.dart';
import '../../data/models/get_product_listing_with_filters_model.dart';
import '../../data/models/get_story_for_product_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings();
  Future<Either<Failure, GetCartShippingItemsModel>> getCartShippingItem();
  // Future<Either<Failure, GetBrandModel>> getBrand();
//Future<Either<Failure, GetCategoryModel>> getCategory();

  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories();
  // Future<Either<Failure, GetIsLikedOFProductModel>> getIsLikedOFProduct(
//      Map<String, dynamic> params);
  Future<Either<Failure, bool>> addLikeOFProduct(Map<String, dynamic> params);
  Future<Either<Failure, bool>> deleteLikeOFProduct(
      Map<String, dynamic> params);
  Future<Either<Failure, GetProductFiltersModel>> getProductFilters(
      Map<String, dynamic> params);
  /* Future<Either<Failure, HomeSectionResponseModel>> getHomeSections(
      Map<String, dynamic> params);*/
  Future<Either<Failure, GetHomeBoutiquesModel>> getHomeBoutiqes(
      Map<String, dynamic> params);
  Future<Either<Failure, ListOfProductsFoundedInCartModel>>
      getProductsListInCart();

  Future<Either<Failure, GetAllowedCountriesModel>> getAllowCountries();
  Future<Either<Failure, GetStoryForProductModel>> getStories(String productId);
  Future<Either<Failure, GetProductListingWithoutFiltersModel>>
      getProductsWithoutFilters(Map<String, dynamic> params);
  Future<Either<Failure, GetProductListingWithFiltersModel>>
      getProductsWithFilters(Map<String, dynamic> params);
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>>
      getProductDetailWithoutSimilarRelatedProducts(String productId);
  Future<Either<Failure, GetFullProductDetailsModel>> getFullProductDetails(
      String productId);
  Future<Either<Failure, GetCommentForProductModel>> geCommentForProduct(
      String productId);
  Future<Either<Failure, AddItemToCartModel>> addItemToCart(
      Map<String, dynamic> params);
  Future<Either<Failure, GetOldCartModel>> getOldCartItems();

  Future<Either<Failure, GetCurrencyForCountryModel>> getCurrencyForCountry();
  Future<Either<Failure, UpdateItemInCartModel>> UpdateItemToCart(
      Map<String, dynamic> params);
  Future<Either<Failure, GetCountViewOfProductModel>>
      getAndAddCountViewOfProduct(Map<String, dynamic> params);

  Future<Either<Failure, bool>> hideItemsInOldCart(Map<String, dynamic> params);

  Future<Either<Failure, ConvertItemFromOldCartToCartModel>>
      convertItemInOldCartToCart(Map<String, dynamic> params);
  Future<Either<Failure, bool>> removeItemToCart(Map<String, dynamic> params);
  Future<Either<Failure, Comment>> addComment(Map<String, dynamic> params);
  Future<Either<Failure, bool>>
      requestForNotificationWhenProductBecameAvailable(
          Map<String, dynamic> params);

  /* Future<Either<Failure, SearchResultModel>> getSearchResult(
      Map<String, dynamic> params);*/
}
