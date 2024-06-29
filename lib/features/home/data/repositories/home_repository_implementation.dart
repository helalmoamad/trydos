import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/data/models/login_to_stories_response_model.dart';
import 'package:trydos/features/authentication/data/models/send_otp_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_guest_phone_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';

import '../../../../core/api/handling_exception.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_data_source.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_story_for_product_model.dart';
import '../models/starting_settings_response_model.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl extends HomeRepository with HandlingExceptionRequest {
  HomeRepositoryImpl(this.dataSource);

  final HomeRemoteDatasource dataSource;

  @override
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings() {
    return handlingExceptionRequest(tryCall: dataSource.getStartingSettings);
  }

  @override
  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories() {
    return handlingExceptionRequest(tryCall: dataSource.getMainCategories);
  }

  /*@override
  Future<Either<Failure, HomeSectionResponseModel>> getHomeSections(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getHomeSections(params));
  }*/
  @override
  Future<Either<Failure, GetHomeBoutiquesModel>> getHomeBoutiqes(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getHomeBoutiques(params));
  }

  @override
  Future<Either<Failure, GetProductListingWithoutFiltersModel>>
      getProductsWithoutFilters(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getProductsWithoutFilters(params));
  }

  @override
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>>
      getProductDetailWithoutSimilarRelatedProducts(String productId) {
    return handlingExceptionRequest(
        tryCall: () =>
            dataSource.getProductDetailWithoutRelatedProducts(productId));
  }

  @override
  Future<Either<Failure, GetStoryForProductModel>> getStories(
      String productId) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getStories(productId));
  }

  @override
  Future<Either<Failure, GetCommentForProductModel>> geCommentForProduct(
      String productId) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getCommentForProduct(productId));
  }

  @override
  Future<Either<Failure, GetCartShippingItemsModel>> getCartShippingItem() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.GetCartShippingItems());
  }
}
