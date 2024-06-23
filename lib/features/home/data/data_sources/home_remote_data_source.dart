import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import '../../../../common/constant/configuration/market_url_routes.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/api/methods/post.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_story_for_product_model.dart';

@injectable
class HomeRemoteDatasource {
  Future<StartingSettingsResponseModel> getStartingSettings() {
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

  Future<MainCategoriesResponseModel> getMainCategories() {
    GetClient<MainCategoriesResponseModel> getMainCategories =
        GetClient<MainCategoriesResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<MainCategoriesResponseModel>(
        endpoint: MarketEndPoints.getMainCategoriesEP,
        response: ResponseValue<MainCategoriesResponseModel>(
            fromJson: (response) =>
                MainCategoriesResponseModel.fromJson(response)),
      ),
    );
    return getMainCategories();
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

  /*Future<HomeSectionResponseModel> getHomeSections(
      Map<String, dynamic> params) {
    GetClient<HomeSectionResponseModel> getHomeSections =
        GetClient<HomeSectionResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<HomeSectionResponseModel>(
        endpoint: MarketEndPoints.getHomeSectionsEP,
        queryParameters: params,
        response: ResponseValue<HomeSectionResponseModel>(
            fromJson: (response) =>
                HomeSectionResponseModel.fromJson(response)),
      ),
    );
    return getHomeSections();
  }*/

  Future<GetHomeBoutiquesModel> getHomeBoutiques(Map<String, dynamic> params) {
    PostClient<GetHomeBoutiquesModel> getHomeSections =
        PostClient<GetHomeBoutiquesModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetHomeBoutiquesModel>(
        endpoint: MarketEndPoints.getHomeBoutiqesEP,
        data: params,
        response: ResponseValue<GetHomeBoutiquesModel>(
            fromJson: (response) => GetHomeBoutiquesModel.fromJson(response)),
      ),
    );
    print("----------------------------------");

    return getHomeSections();
  }
}
