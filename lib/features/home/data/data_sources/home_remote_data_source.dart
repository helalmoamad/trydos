import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/elastic_url_routes.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/convert_item_from_oldCart_to_cart_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_count_likes_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_count_view_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_full_product_details_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_is_liked_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/list_of_products_in_cart_model.dart';

import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import '../../../../common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/api/methods/post.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_product_filters_model.dart';
import '../models/get_product_listing_with_filters_model.dart';
import '../models/get_story_for_product_model.dart';

@injectable
class HomeRemoteDatasource {
  Future<StartingSettingsResponseModel> getStartingSettings() {
    ///// for test /////
    TestVariables.getStartingSettingsFlag = true;
    TestVariables.getStartingSettingsRequestCountFlag++;
    ////////////////////
    GetClient<StartingSettingsResponseModel> getStartingSettings =
        GetClient<StartingSettingsResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<StartingSettingsResponseModel>(
        endpoint: MarketEndPoints.getStartingSettingsEP,
        response: ResponseValue<StartingSettingsResponseModel>(
            fromJson: (response) =>
                StartingSettingsResponseModel.fromJson(response)),
      ),
    );
    return getStartingSettings();
  }

  Future<GetProductDetailWithoutRelatedProductsModel>
      getProductDetailWithoutRelatedProducts(String productId) {
    GetClient<GetProductDetailWithoutRelatedProductsModel>
        getProductDetailWithoutRelatedProducts =
        GetClient<GetProductDetailWithoutRelatedProductsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductDetailWithoutRelatedProductsModel>(
        endpoint: MarketEndPoints.getProductDetailWithoutSimilarRelatedProducts(
            productId),
        response: ResponseValue<GetProductDetailWithoutRelatedProductsModel>(
            fromJson: (response) {
          print('qqqqqqq ${response.toString()}');
          return GetProductDetailWithoutRelatedProductsModel.fromJson(response);
        }),
      ),
    );
    return getProductDetailWithoutRelatedProducts();
  }

  Future<GetFullProductDetailsModel> getFullProductDetails(String productId) {
    GetClient<GetFullProductDetailsModel> getFullProductDetails =
        GetClient<GetFullProductDetailsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetFullProductDetailsModel>(
        endpoint: MarketEndPoints.getFullProductDetailsEP(productId),
        response:
            ResponseValue<GetFullProductDetailsModel>(fromJson: (response) {
          return GetFullProductDetailsModel.fromJson(response);
        }),
      ),
    );
    return getFullProductDetails();
  }

  Future<GetCommentForProductModel> getCommentForProduct(String productId) {
    GetClient<GetCommentForProductModel> getCommentForProduct =
        GetClient<GetCommentForProductModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetCommentForProductModel>(
        endpoint: MarketEndPoints.getCommentForProductEP(productId),
        response:
            ResponseValue<GetCommentForProductModel>(fromJson: (response) {
          print('ddddddddddd ${response.toString()}');
          return GetCommentForProductModel.fromJson(response);
        }),
      ),
    );
    return getCommentForProduct();
  }

  Future<GetProductListingWithoutFiltersModel> getProductsWithoutFilters(
      Map<String, dynamic> params) {
    PostClient<GetProductListingWithoutFiltersModel> getProductsWithoutFilters =
        PostClient<GetProductListingWithoutFiltersModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductListingWithoutFiltersModel>(
        endpoint: MarketEndPoints.getProductListingWithoutFiltersEP,
        data: params,
        response: ResponseValue<GetProductListingWithoutFiltersModel>(
            fromJson: (response) =>
                GetProductListingWithoutFiltersModel.fromJson(response)),
      ),
    );

    return getProductsWithoutFilters();
  }

  /* Future<GetCategoryModel> getCategory() {
    GetClient<GetCategoryModel> getCategory = GetClient<GetCategoryModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetCategoryModel>(
        endpoint: MarketEndPoints.getCategoryEP,
        response: ResponseValue<GetCategoryModel>(
            fromJson: (response) => GetCategoryModel.fromJson(response)),
      ),
    );

    return getCategory();
  }*/

  /* Future<GetBrandModel> getBrand() {
    GetClient<GetBrandModel> getBrand = GetClient<GetBrandModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetBrandModel>(
        endpoint: MarketEndPoints.getBrandEP,
        response: ResponseValue<GetBrandModel>(
            fromJson: (response) => GetBrandModel.fromJson(response)),
      ),
    );

    return getBrand();
  }
*/
  Future<MainCategoriesResponseModel> getMainCategories() {
    ///// for test /////
    TestVariables.getMainCategoriesFlag = true;
    TestVariables.getMainCategoriesRequestCountFlag++;
    ////////////////////
    GetClient<MainCategoriesResponseModel> getMainCategories =
        GetClient<MainCategoriesResponseModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<MainCategoriesResponseModel>(
        endpoint: ElasticEndPoints.getMainCategoriesEP,
        // MarketEndPoints.getMainCategoriesRelatedWithBoutiquesEP,
        response: ResponseValue<MainCategoriesResponseModel>(
            fromJson: (response) =>
                MainCategoriesResponseModel.fromJson(response)),
      ),
    );
    return getMainCategories();
  }

  Future<GetCurrencyForCountryModel> getCurrencyForCountry() {
    GetClient<GetCurrencyForCountryModel> getCurrencyForCountry =
        GetClient<GetCurrencyForCountryModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetCurrencyForCountryModel>(
        endpoint: MarketEndPoints.getCurrencyEP,
        response: ResponseValue<GetCurrencyForCountryModel>(
            fromJson: (response) =>
                GetCurrencyForCountryModel.fromJson(response)),
      ),
    );
    return getCurrencyForCountry();
  }

  Future<GetProductFiltersModel> getProductFilters(
      Map<String, dynamic> params) {
    GetClient<GetProductFiltersModel> getProductFilters =
        GetClient<GetProductFiltersModel>(
      /*  serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductFiltersModel>(
        endpoint: MarketEndPoints.getProductFiltersEP,*/
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetProductFiltersModel>(
        endpoint: ElasticEndPoints.searchWithoutFilterElasticEP,
        queryParameters: params,
        response: ResponseValue<GetProductFiltersModel>(
            fromJson: (response) => GetProductFiltersModel.fromJson(response)),
      ),
    );
    return getProductFilters();
  }

  Future<GetProductListingWithFiltersModel> getProductsWithFilters(
      Map<String, dynamic> params) {
    GetClient<GetProductListingWithFiltersModel> getProductsWithFilters =
        GetClient<GetProductListingWithFiltersModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: ElasticEndPoints.searchWithFilterElasticEP,
        /*serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: MarketEndPoints.getProductListingWithFiltersEP,*/
        queryParameters: params,
        response: ResponseValue<GetProductListingWithFiltersModel>(
            fromJson: (response) =>
                GetProductListingWithFiltersModel.fromJson(response)),
      ),
    );

    return getProductsWithFilters();
  }

  Future<Comment> addComment(Map<String, dynamic> params) {
    PostClient<Comment> addComment = PostClient<Comment>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<Comment>(
        endpoint: MarketEndPoints.addCommentEP,
        data: params,
        response: ResponseValue<Comment>(
            fromJson: (response) =>
                Comment.fromJson(response['data']['comment'])),
      ),
    );
    return addComment();
  }

  Future<GetStoryForProductModel> getStories(String productId) {
    GetClient<GetStoryForProductModel> getStories =
        GetClient<GetStoryForProductModel>(
      serverName: ServerName.stories,
      requestPrams: RequestConfig<GetStoryForProductModel>(
        endpoint: StoriesEndPoints.getStoriesForProsuctEP(productId),
        response: ResponseValue<GetStoryForProductModel>(
            fromJson: (response) => GetStoryForProductModel.fromJson(response)),
      ),
    );

    return getStories();
  }

  Future<GetOldCartModel> getOldCartItems() {
    GetClient<GetOldCartModel> getStories = GetClient<GetOldCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetOldCartModel>(
        endpoint: MarketEndPoints.getOldCartItemsEP,
        response: ResponseValue<GetOldCartModel>(
            fromJson: (response) => GetOldCartModel.fromJson(response)),
      ),
    );

    return getStories();
  }

  Future<GetCartShippingItemsModel> getCartShippingItems() {
    GetClient<GetCartShippingItemsModel> getCartShippingItems =
        GetClient<GetCartShippingItemsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetCartShippingItemsModel>(
        endpoint: MarketEndPoints.getCartItemEP,
        response: ResponseValue<GetCartShippingItemsModel>(
            fromJson: (response) =>
                GetCartShippingItemsModel.fromJson(response)),
      ),
    );
    return getCartShippingItems();
  }

  Future<GetHomeBoutiquesModel> getHomeBoutiques(Map<String, dynamic> params) {
    ///// for test /////
    TestVariables.getBoutiquesFlag = true;
    TestVariables.getBoutiquesRequestCountFlag++;
    ////////////////////
    GetClient<GetHomeBoutiquesModel> getHomeBoutiques =
        GetClient<GetHomeBoutiquesModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetHomeBoutiquesModel>(
        endpoint: ElasticEndPoints.getHomeBoutiquesEP,
        // MarketEndPoints.getHomeBoutiqesEP,
        queryParameters: params,
        response: ResponseValue<GetHomeBoutiquesModel>(
            fromJson: (response) => GetHomeBoutiquesModel.fromJson(response)),
      ),
    );

    return getHomeBoutiques();
  }

  Future<ListOfProductsFoundedInCartModel> getProductsListInCart() {
    GetClient<ListOfProductsFoundedInCartModel> getProductsListInCart =
        GetClient<ListOfProductsFoundedInCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ListOfProductsFoundedInCartModel>(
        endpoint: MarketEndPoints.getProductListInCartEP,
        response: ResponseValue<ListOfProductsFoundedInCartModel>(
            fromJson: (response) =>
                ListOfProductsFoundedInCartModel.fromJson(response)),
      ),
    );
    return getProductsListInCart();
  }

  Future<AddItemToCartModel> addItemToCart(Map<String, dynamic> params) {
    PostClient<AddItemToCartModel> addItemToCart =
        PostClient<AddItemToCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<AddItemToCartModel>(
        endpoint: MarketEndPoints.addItemCartItemEP,
        data: params,
        response: ResponseValue<AddItemToCartModel>(
            fromJson: (response) => AddItemToCartModel.fromJson(response)),
      ),
    );
    return addItemToCart();
  }

  Future<bool> hideItemsInOldCart(Map<String, dynamic> params) {
    PostClient<bool> hideItemsInOldCart = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.hideItemsInOldCartEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return hideItemsInOldCart();
  }

  Future<ConvertItemFromOldCartToCartModel> convertItemInOldCartToCart(
      Map<String, dynamic> params) {
    PostClient<ConvertItemFromOldCartToCartModel> convertItemInOldCartToCart =
        PostClient<ConvertItemFromOldCartToCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ConvertItemFromOldCartToCartModel>(
        endpoint: MarketEndPoints.convertItemInOldCartToCartEP,
        data: params,
        response: ResponseValue<ConvertItemFromOldCartToCartModel>(
            fromJson: (response) =>
                ConvertItemFromOldCartToCartModel.fromJson(response)),
      ),
    );
    return convertItemInOldCartToCart();
  }

  Future<bool> removeItemToCart(Map<String, dynamic> params) {
    PostClient<bool> removeItemToCart = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.removeItemCartItemEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return removeItemToCart();
  }

  Future<GetCountViewOfProductModel> getAndAddCountViewOfProduct(
      Map<String, dynamic> params) {
    PostClient<GetCountViewOfProductModel> getAndAddCountViewOfProduct =
        PostClient<GetCountViewOfProductModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetCountViewOfProductModel>(
        endpoint: ElasticEndPoints.getAndAddCountViewOfProductEP,
        data: params,
        response: ResponseValue<GetCountViewOfProductModel>(
            fromJson: (response) =>
                GetCountViewOfProductModel.fromJson(response)),
      ),
    );
    return getAndAddCountViewOfProduct();
  }

  Future<UpdateItemInCartModel> updateItemInCart(Map<String, dynamic> params) {
    PostClient<UpdateItemInCartModel> updateItemInCart =
        PostClient<UpdateItemInCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<UpdateItemInCartModel>(
        endpoint: MarketEndPoints.updateItemCartItemEP,
        data: params,
        response: ResponseValue<UpdateItemInCartModel>(
            fromJson: (response) => UpdateItemInCartModel.fromJson(response)),
      ),
    );
    return updateItemInCart();
  }

  Future<bool> requestForNotificationWhenProductBecameAvailable(
      Map<String, dynamic> params) {
    PostClient<bool> requestForNotificationWhenProductBecameAvailable =
        PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint:
            MarketEndPoints.requestForNotificationWhenProductBecameAvailableEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return requestForNotificationWhenProductBecameAvailable();
  }

  /* Future<SearchResultModel> getSearchResult(Map<String, dynamic> params) {
    GetClient<SearchResultModel> getSearchResult = GetClient<SearchResultModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<SearchResultModel>(
        endpoint: MarketEndPoints.getSearchResultEP,
        queryParameters: params,
        response: ResponseValue<SearchResultModel>(
            fromJson: (response) => SearchResultModel.fromJson(response)),
      ),
    );

    return getSearchResult();
  }*/

  Future<GetAllowedCountriesModel> getAllowedCountries() {
    ///// for test /////
    TestVariables.getAllowedCountriesFlag = true;
    TestVariables.getAllowedCountriesRequestCountFlag++;
    ////////////////////
    GetClient<GetAllowedCountriesModel> verifyOtpSignIn =
        GetClient<GetAllowedCountriesModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetAllowedCountriesModel>(
        endpoint: MarketEndPoints.getAllowesdCountriesEP,
        response: ResponseValue<GetAllowedCountriesModel>(
            fromJson: (response) =>
                GetAllowedCountriesModel.fromJson(response)),
      ),
    );
    return verifyOtpSignIn();
  }

  Future<bool> addLikeOFProduct(Map<String, dynamic> params) {
    PostClient<bool> addLikeOFProduct = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.addLikeOFProductEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return addLikeOFProduct();
  }

  Future<bool> deleteLikeOFProduct(Map<String, dynamic> params) {
    PostClient<bool> deleteLikeOFProduct = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.deleteLikeOFProductEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return deleteLikeOFProduct();
  }
}
