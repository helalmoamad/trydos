import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/elastic_url_routes.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/convert_item_from_oldCart_to_cart_model.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_coordinates_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_text_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_count_view_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_full_product_details_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/list_of_products_in_cart_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import '../../../../common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/api/methods/post.dart';
import '../models/customer_wallet_model.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_product_filters_model.dart';
import '../models/get_product_listing_with_filters_model.dart';
import '../models/get_story_for_product_model.dart';
import '../models/place_order_model.dart';

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
              StartingSettingsResponseModel.fromJson(response),
        ),
      ),
    );
    return getStartingSettings();
  }

  Future<GetProductDetailWithoutRelatedProductsModel>
      getProductDetailWithoutRelatedProducts(String productSlug) {
    GetClient<GetProductDetailWithoutRelatedProductsModel>
        getProductDetailWithoutRelatedProducts =
        GetClient<GetProductDetailWithoutRelatedProductsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductDetailWithoutRelatedProductsModel>(
        endpoint: MarketEndPoints.getProductDetailWithoutSimilarRelatedProducts(
            productSlug),
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

  Future<NotificationTypeForProductModel> getNotificationTypeForProduct() {
    GetClient<NotificationTypeForProductModel> getNotificationTypeForProduct =
        GetClient<NotificationTypeForProductModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<NotificationTypeForProductModel>(
        endpoint: MarketEndPoints.getNotificationTypeForProductEP,
        response: ResponseValue<NotificationTypeForProductModel>(
            fromJson: (response) {
          return NotificationTypeForProductModel.fromJson(response);
        }),
      ),
    );
    return getNotificationTypeForProduct();
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

  Future<ResponseOnlyMessageModel> deleteCustomerAddress(
      Map<String, dynamic> params) {
    PostClient<ResponseOnlyMessageModel> deleteCustomerAddress =
        PostClient<ResponseOnlyMessageModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ResponseOnlyMessageModel>(
        endpoint: MarketEndPoints.deleteCustomerAddressEP,
        data: params,
        response: ResponseValue<ResponseOnlyMessageModel>(
            fromJson: (response) =>
                ResponseOnlyMessageModel.fromJson(response)),
      ),
    );

    return deleteCustomerAddress();
  }

  Future<ResponseOnlyMessageModel> addCustomerAddress(
      Map<String, dynamic> params) {
    PostClient<ResponseOnlyMessageModel> addCustomerAddress =
        PostClient<ResponseOnlyMessageModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ResponseOnlyMessageModel>(
        endpoint: MarketEndPoints.addCustomerAddressEP,
        data: params,
        response: ResponseValue<ResponseOnlyMessageModel>(
            fromJson: (response) =>
                ResponseOnlyMessageModel.fromJson(response)),
      ),
    );

    return addCustomerAddress();
  }

  Future<FirebaseSettingForNotificationModel>
      changeCountryLanguageFornotification(Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel>
        changeCountryLanguageFornotification =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.changeCountryLanguageEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return changeCountryLanguageFornotification();
  }

  Future<FirebaseSettingForNotificationModel> getMyFirebaseSettings() {
    GetClient<FirebaseSettingForNotificationModel> getMyFirebaseSettings =
        GetClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.getMyFirebaseSettingsEP,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) {
          return FirebaseSettingForNotificationModel.fromJson(response);
        }),
      ),
    );
    return getMyFirebaseSettings();
  }

  Future<FirebaseSettingForNotificationModel> updateWhatsappNotification(
      Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel> updateWhatsappNotification =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.updateWhatsappEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return updateWhatsappNotification();
  }

  Future<FirebaseSettingForNotificationModel> updateFirebaseNotification(
      Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel> updateFirebaseNotification =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.updateFirebaseEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return updateFirebaseNotification();
  }

  Future<FirebaseSettingForNotificationModel> updateEmailNotification(
      Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel> updateEmailNotification =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.updateEmailEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return updateEmailNotification();
  }

  Future<FirebaseSettingForNotificationModel> updateNotificationFrequency(
      Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel>
        updateNotificationFrequency =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.updateNotificationFrequencyEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return updateNotificationFrequency();
  }

  Future<FirebaseSettingForNotificationModel> unSubscribeTopicFornotification(
      Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel>
        unSubscribeTopicFornotification =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.unsubscribeTopicEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return unSubscribeTopicFornotification();
  }

  Future<FirebaseSettingForNotificationModel> subscribeTopicFornotification(
      Map<String, dynamic> params) {
    PostClient<FirebaseSettingForNotificationModel>
        subscribeTopicFornotification =
        PostClient<FirebaseSettingForNotificationModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<FirebaseSettingForNotificationModel>(
        endpoint: MarketEndPoints.subscribeTopicEP,
        data: params,
        response: ResponseValue<FirebaseSettingForNotificationModel>(
            fromJson: (response) =>
                FirebaseSettingForNotificationModel.fromJson(response)),
      ),
    );

    return subscribeTopicFornotification();
  }

  Future<ResponseOnlyMessageModel> updateCustomerAddress(
      Map<String, dynamic> params) {
    PostClient<ResponseOnlyMessageModel> updateCustomerAddress =
        PostClient<ResponseOnlyMessageModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ResponseOnlyMessageModel>(
        endpoint: MarketEndPoints.updateCustomerAddressEP,
        data: params,
        response: ResponseValue<ResponseOnlyMessageModel>(
            fromJson: (response) =>
                ResponseOnlyMessageModel.fromJson(response)),
      ),
    );

    return updateCustomerAddress();
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
  Future<MainCategoriesResponseModel> getMainCategories(
      Map<String, dynamic> params) {
    ///// for test /////
    TestVariables.getMainCategoriesFlag = true;
    TestVariables.getMainCategoriesRequestCountFlag++;
    ////////////////////
    GetClient<MainCategoriesResponseModel> getMainCategories =
        GetClient<MainCategoriesResponseModel>(
      serverName: ServerName.elastic,
      //ServerName.elastic,
      requestPrams: RequestConfig<MainCategoriesResponseModel>(
        endpoint: ElasticEndPoints.getMainCategoriesEP,
        //ElasticEndPoints.getMainCategoriesEP,
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

  Future<GetListOfCustomerAddressesInfoModel> getCustomerAddresses() {
    GetClient<GetListOfCustomerAddressesInfoModel> getCustomerAddresses =
        GetClient<GetListOfCustomerAddressesInfoModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetListOfCustomerAddressesInfoModel>(
        endpoint: MarketEndPoints.getCustomerAddressesEP,
        response: ResponseValue<GetListOfCustomerAddressesInfoModel>(
            fromJson: (response) =>
                GetListOfCustomerAddressesInfoModel.fromJson(response)),
      ),
    );
    return getCustomerAddresses();
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

  Future<bool> sendErrorToMobileErrorLog(Map<String, dynamic> params) {
    PostClient<bool> sendErrorToMobileErrorLog = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.sendErrorToMobileErrorLogEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return sendErrorToMobileErrorLog();
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

  Future<PopularSearchTermsModel> getPopularSearchTerms() {
    GetClient<PopularSearchTermsModel> getPopularSearchTerms =
        GetClient<PopularSearchTermsModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<PopularSearchTermsModel>(
        endpoint: ElasticEndPoints.getPopularSearchTermsEP,
        response: ResponseValue<PopularSearchTermsModel>(
            fromJson: (response) => PopularSearchTermsModel.fromJson(response)),
      ),
    );
    return getPopularSearchTerms();
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
      //ServerName.elastic,
      requestPrams: RequestConfig<GetHomeBoutiquesModel>(
        endpoint: ElasticEndPoints.getHomeBoutiquesEP,
        //ElasticEndPoints.getHomeBoutiquesEP,
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

  Future<GetAddressByCoordinatesModel> getAddressByCoordinates(
      Map<String, dynamic> params) {
    PostClient<GetAddressByCoordinatesModel> getAddressByCoordinates =
        PostClient<GetAddressByCoordinatesModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetAddressByCoordinatesModel>(
        endpoint: ElasticEndPoints.getAddressByCoordinatesEP,
        data: params,
        response: ResponseValue<GetAddressByCoordinatesModel>(
            fromJson: (response) =>
                GetAddressByCoordinatesModel.fromJson(response)),
      ),
    );
    return getAddressByCoordinates();
  }

  Future<GetAddressByTextModel> getAddressByText(Map<String, dynamic> params) {
    PostClient<GetAddressByTextModel> getAddressByText =
        PostClient<GetAddressByTextModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetAddressByTextModel>(
        endpoint: ElasticEndPoints.getAddressByTextEP,
        data: params,
        response: ResponseValue<GetAddressByTextModel>(
            fromJson: (response) => GetAddressByTextModel.fromJson(response)),
      ),
    );
    return getAddressByText();
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

  Future<ReadOnlyMessageFromApiModel>
      requestForNotificationWhenProductBecameAvailable(
          Map<String, dynamic> params) {
    PostClient<ReadOnlyMessageFromApiModel>
        requestForNotificationWhenProductBecameAvailable =
        PostClient<ReadOnlyMessageFromApiModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
        endpoint:
            MarketEndPoints.requestForNotificationWhenProductBecameAvailableEP,
        data: params,
        response: ResponseValue<ReadOnlyMessageFromApiModel>(
            fromJson: (response) =>
                ReadOnlyMessageFromApiModel.fromJson(response)),
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

  Future<bool> storeFcmTokenOfMarket(Map<String, dynamic> params) {
    PostClient<bool> storeFcmTokenOfMarket = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
          endpoint: MarketEndPoints.storeFcmOfMarketEP,
          data: params,
          response: ResponseValue<bool>(returnValueOnSuccess: true)),
    );
    return storeFcmTokenOfMarket();
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

  Future<CustomerWalletModel> getCustomerWallet({
    required int limit,
    required int offset,
  }) {
    GetClient<CustomerWalletModel> getCustomerWallet =
        GetClient<CustomerWalletModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<CustomerWalletModel>(
        endpoint: MarketEndPoints.getCustomerWalletEP,
        queryParameters: {
          "limit": limit.toString(),
          "offset": offset.toString(),
        },
        response: ResponseValue<CustomerWalletModel>(
            fromJson: (response) => CustomerWalletModel.fromJson(response)),
      ),
    );

    return getCustomerWallet();
  }

  Future<OrdersGroupModel> placeOrder(
      {required Map<String, dynamic> params, required String paymentMethod}) {
    PostClient<OrdersGroupModel> placeOrder = PostClient<OrdersGroupModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrdersGroupModel>(
        endpoint: MarketEndPoints.placeOrderEP(paymentMethod),
        data: params,
        response: ResponseValue<OrdersGroupModel>(
          fromJson: (response) => OrdersGroupModel.fromJson(response),
        ),
      ),
    );

    return placeOrder();
  }

  Future<OrdersGroupModel> getOrdersByOrderGroupID({
    required String orderGroupID,
  }) {
    GetClient<OrdersGroupModel> getOrdersByOrderGroupID =
        GetClient<OrdersGroupModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrdersGroupModel>(
        endpoint: MarketEndPoints.getOrdersByOrderGroupEP,
        queryParameters: {
          "order_group_id": orderGroupID,
        },
        response: ResponseValue<OrdersGroupModel>(
            fromJson: (response) => OrdersGroupModel.fromJson(response)),
      ),
    );

    return getOrdersByOrderGroupID();
  }

  Future<OrdersGroupModel> getOrdersByCartGroupID({
    required String cartGroupID,
  }) {
    GetClient<OrdersGroupModel> getOrdersByCartGroupID =
        GetClient<OrdersGroupModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrdersGroupModel>(
        endpoint: MarketEndPoints.getOrdersByCartGroupEP,
        queryParameters: {
          "cart_group_id": cartGroupID,
        },
        response: ResponseValue<OrdersGroupModel>(
            fromJson: (response) => OrdersGroupModel.fromJson(response)),
      ),
    );

    return getOrdersByCartGroupID();
  }

  Future<OrdersGroupModel> checkAvailabilityProductCart() {
    GetClient<OrdersGroupModel> checkAvailabilityProductCart =
        GetClient<OrdersGroupModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrdersGroupModel>(
        endpoint: MarketEndPoints.checkAvailabilityProductCartEP,
        response: ResponseValue<OrdersGroupModel>(
            fromJson: (response) => OrdersGroupModel.fromJson(response)),
      ),
    );

    return checkAvailabilityProductCart();
  }
}
