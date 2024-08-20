import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_brand_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import '../../../../common/constant/configuration/market_url_routes.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../common/constant/widgets_key.dart';
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
    WidgetsKey.getStartingSettingsFlag = true;
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
    GetClient<GetProductDetailWithoutRelatedProductsModel> getStartingSettings =
        GetClient<GetProductDetailWithoutRelatedProductsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductDetailWithoutRelatedProductsModel>(
        endpoint: MarketEndPoints.getProductDetailWithoutSimilarRelatedProducts(
            productId),
        response: ResponseValue<GetProductDetailWithoutRelatedProductsModel>(
            fromJson: (response) =>
                GetProductDetailWithoutRelatedProductsModel.fromJson(response)),
      ),
    );
    return getStartingSettings();
  }

  Future<GetCommentForProductModel> getCommentForProduct(String productId) {
    GetClient<GetCommentForProductModel> getCommentForProduct =
        GetClient<GetCommentForProductModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetCommentForProductModel>(
        endpoint: MarketEndPoints.getCommentForProductEP(productId),
        response: ResponseValue<GetCommentForProductModel>(
            fromJson: (response) =>
                GetCommentForProductModel.fromJson(response)),
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

  Future<GetProductListingWithFiltersModel> getProductsWithFilters(
      Map<String, dynamic> params) {
    PostClient<GetProductListingWithFiltersModel> getProductsWithFilters =
        PostClient<GetProductListingWithFiltersModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: MarketEndPoints.getProductListingWithFiltersEP,
        data: params,
        response: ResponseValue<GetProductListingWithFiltersModel>(
            fromJson: (response) =>
                GetProductListingWithFiltersModel.fromJson(response)),
      ),
    );

    return getProductsWithFilters();
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
    WidgetsKey.getMainCategoriesFlag = true;
    ////////////////////
    GetClient<MainCategoriesResponseModel> getMainCategories =
        GetClient<MainCategoriesResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<MainCategoriesResponseModel>(
        endpoint: MarketEndPoints.getMainCategoriesRelatedWithBoutiquesEP,
        response: ResponseValue<MainCategoriesResponseModel>(
            fromJson: (response) =>
                MainCategoriesResponseModel.fromJson(response)),
      ),
    );
    return getMainCategories();
  }

  Future<GetProductFiltersModel> getProductFilters(
      Map<String, dynamic> params) {
    PostClient<GetProductFiltersModel> getProductFilters =
        PostClient<GetProductFiltersModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductFiltersModel>(
        endpoint: MarketEndPoints.getProductFiltersEP,
        data: params,
        response: ResponseValue<GetProductFiltersModel>(
            fromJson: (response) => GetProductFiltersModel.fromJson(response)),
      ),
    );
    return getProductFilters();
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
    WidgetsKey.getBoutiquesFlag = true;
    ////////////////////
    GetClient<GetHomeBoutiquesModel> getHomeBoutiques =
        GetClient<GetHomeBoutiquesModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetHomeBoutiquesModel>(
        endpoint: MarketEndPoints.getHomeBoutiqesEP,
        queryParameters: params,
        response: ResponseValue<GetHomeBoutiquesModel>(
            fromJson: (response) => GetHomeBoutiquesModel.fromJson(response)),
      ),
    );

    return getHomeBoutiques();
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

  Future<GetAllowedCountriesModel> getAllowedCountries() {
    ///// for test /////
    WidgetsKey.getAllowedCountriesFlag = true;
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
}
