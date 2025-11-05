import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/elastic_url_routes.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/api/methods/delete.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/core/api/methods/put.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/convert_item_from_cart_to_oldCart_model.dart';
import 'package:trydos/features/home/data/models/create_comment_model.dart';
import 'package:trydos/features/home/data/models/create_return_request_model.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_coordinates_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_text_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_boundary_cordinates_by_iso_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_colors_and_sizes_model.dart';
import 'package:trydos/features/home/data/models/get_count_view_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_full_product_details_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_provinces_by_iso_model.dart';
import 'package:trydos/features/home/data/models/list_of_products_in_cart_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/confirm_return_request_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/data/models/update_profile_model.dart';
import 'package:trydos/features/home/data/models/update_return_request_model.dart';
import 'package:trydos/features/home/data/models/upload_user_photo_model.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../common/constant/configuration/market_url_routes.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/api/methods/post.dart';
import '../models/apply_coupon_model.dart';
import '../models/check_availability_product_cart_model.dart';
import '../models/customer_wallet_model.dart';
import '../models/get_orders_model.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_product_filters_model.dart';
import '../models/get_product_listing_with_filters_model.dart';
import '../models/get_story_for_product_model.dart';
import '../models/get_user_notifications_model.dart';
import '../models/place_order_model.dart';
import '../models/cancel_order_item_model.dart';
import '../models/cancel_order_model.dart';
import '../models/change_order_address_model.dart';
import '../models/color_size_for_product.dart';
import '../models/order_comment_model.dart';
import '../models/return_reasons_model.dart';
import '../models/upload_images_for_return_product_model.dart';
import '../models/return_request_product_model.dart';
import 'package:trydos/features/home/data/models/get_order_details_return_model.dart';
import 'package:trydos/features/home/data/models/get_auth_product_details_model.dart';
import 'package:trydos/features/home/data/models/get_order_rating_model.dart'
    as order_rating;
import 'package:trydos/features/home/data/models/get_fqa_comments_model.dart';
import 'package:trydos/features/home/data/models/get_buyers_comments_model.dart';

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

  Future<GetProvincesByIsoModel> getProvincesByIso() {
    ///// for test /////

    ////////////////////
    GetClient<GetProvincesByIsoModel> getProvincesByIso =
        GetClient<GetProvincesByIsoModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<GetProvincesByIsoModel>(
        endpoint: ElasticEndPoints.getProvincesByIsoEP,
        response: ResponseValue<GetProvincesByIsoModel>(
          fromJson: (response) => GetProvincesByIsoModel.fromJson(response),
        ),
      ),
    );
    return getProvincesByIso();
  }

  /*Future<comment.GetCommentsFromAnalyticsModel> getCommentsFromAnalytics(
      Map<String, dynamic> params) {
    GetClient<comment.GetCommentsFromAnalyticsModel> getCommentsFromAnalytics =
        GetClient<comment.GetCommentsFromAnalyticsModel>(
      serverName: ServerName.comment,
      requestPrams: RequestConfig<comment.GetCommentsFromAnalyticsModel>(
        endpoint: WebAppEndPoints.getCommentsFromAnalyticsEP,
        queryParameters: params,
        response: ResponseValue<comment.GetCommentsFromAnalyticsModel>(
          fromJson: (response) =>
              comment.GetCommentsFromAnalyticsModel.fromJson(response),
        ),
      ),
    );
    return getCommentsFromAnalytics();
  }*/

  Future<GetFqaCommentsModel> getFqaComments(Map<String, dynamic> params) {
    GetClient<GetFqaCommentsModel> getFqaComments =
        GetClient<GetFqaCommentsModel>(
      serverName: ServerName.comment,
      requestPrams: RequestConfig<GetFqaCommentsModel>(
        endpoint: WebAppEndPoints.getFqaCommentsEP,
        queryParameters: params,
        response: ResponseValue<GetFqaCommentsModel>(
          fromJson: (response) => GetFqaCommentsModel.fromJson(response),
        ),
      ),
    );
    return getFqaComments();
  }

  Future<GetBuyersCommentsModel> getBuyersComments(
      Map<String, dynamic> params) {
    GetClient<GetBuyersCommentsModel> getBuyersComments =
        GetClient<GetBuyersCommentsModel>(
      serverName: ServerName.comment,
      requestPrams: RequestConfig<GetBuyersCommentsModel>(
        endpoint: WebAppEndPoints.getBuyersCommentsEP,
        queryParameters: params,
        response: ResponseValue<GetBuyersCommentsModel>(
          fromJson: (response) => GetBuyersCommentsModel.fromJson(response),
        ),
      ),
    );
    return getBuyersComments();
  }

  Future<order_rating.GetOrderRatingFromAnalyticsModel> getOrderRating(
      Map<String, dynamic> params) {
    PostClient<order_rating.GetOrderRatingFromAnalyticsModel> getOrderRating =
        PostClient<order_rating.GetOrderRatingFromAnalyticsModel>(
      serverName: ServerName.comment,
      requestPrams:
          RequestConfig<order_rating.GetOrderRatingFromAnalyticsModel>(
        endpoint: WebAppEndPoints.getOrderRatingEP,
        data: params,
        response: ResponseValue<order_rating.GetOrderRatingFromAnalyticsModel>(
            fromJson: (response) =>
                order_rating.GetOrderRatingFromAnalyticsModel.fromJson(
                    response)),
      ),
    );
    return getOrderRating();
  }

  Future<CreateFqaCommentsModel> createOrderCommentRating(
      Map<String, dynamic> params) {
    PostClient<CreateFqaCommentsModel> createOrderRating =
        PostClient<CreateFqaCommentsModel>(
      serverName: ServerName.get_comment_token,
      requestPrams: RequestConfig<CreateFqaCommentsModel>(
        endpoint: WebAppEndPoints.createOrderRatingEP,
        data: params,
        response: ResponseValue<CreateFqaCommentsModel>(
            fromJson: (response) => CreateFqaCommentsModel.fromJson(response)),
      ),
    );
    return createOrderRating();
  }

  Future<ResponseOnlyMessageModel> updateOrderCommentRating(
      Map<String, dynamic> params) {
    PutClient<ResponseOnlyMessageModel> updateOrderCommentRating =
        PutClient<ResponseOnlyMessageModel>(
      serverName: ServerName.get_comment_token,
      requestPrams: RequestConfig<ResponseOnlyMessageModel>(
        endpoint: WebAppEndPoints.updateOrderRatingEP(params['id']),
        data: params,
        response: ResponseValue<ResponseOnlyMessageModel>(
            fromJson: (response) =>
                ResponseOnlyMessageModel.fromJson(response)),
      ),
    );
    return updateOrderCommentRating();
  }

  Future<ResponseOnlyMessageModel> deleteOrderCommentRating(
      Map<String, dynamic> params) {
    DeleteClient<ResponseOnlyMessageModel> deleteOrderCommentRating =
        DeleteClient<ResponseOnlyMessageModel>(
      serverName: ServerName.get_comment_token,
      requestPrams: RequestConfig<ResponseOnlyMessageModel>(
        endpoint: WebAppEndPoints.deleteOrderRatingEP(params['id']),
        response: ResponseValue<ResponseOnlyMessageModel>(
            fromJson: (response) =>
                ResponseOnlyMessageModel.fromJson(response)),
      ),
    );
    return deleteOrderCommentRating();
  }

  Future<OrderCommentModel> addOrderComment(Map<String, dynamic> params) {
    PostClient<OrderCommentModel> addOrderComment =
        PostClient<OrderCommentModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrderCommentModel>(
        endpoint: MarketEndPoints.addOrderCommentEP,
        data: params,
        response: ResponseValue<OrderCommentModel>(
            fromJson: (response) => OrderCommentModel.fromJson(response)),
      ),
    );
    return addOrderComment();
  }

  Future<OrderCommentModel> updateOrderComment(Map<String, dynamic> params) {
    PostClient<OrderCommentModel> updateOrderComment =
        PostClient<OrderCommentModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrderCommentModel>(
        endpoint: MarketEndPoints.updateOrderCommentEP,
        data: params,
        response: ResponseValue<OrderCommentModel>(
            fromJson: (response) => OrderCommentModel.fromJson(response)),
      ),
    );
    return updateOrderComment();
  }

  Future<CountryBoundaryByIsoModel> getCountryBoundaryByIso(String iso) {
    GetClient<CountryBoundaryByIsoModel> getCountryBoundaryByIso =
        GetClient<CountryBoundaryByIsoModel>(
      serverName: ServerName.elastic,
      requestPrams: RequestConfig<CountryBoundaryByIsoModel>(
        endpoint: ElasticEndPoints.countryBoundaryByIsoEP(iso),
        response: ResponseValue<CountryBoundaryByIsoModel>(
          fromJson: (response) => CountryBoundaryByIsoModel.fromJson(response),
        ),
      ),
    );
    return getCountryBoundaryByIso();
  }

  Future<GetProductDetailWithoutRelatedProductsModel>
      getProductDetailWithoutRelatedProducts(String productSlug) {
    GetClient<GetProductDetailWithoutRelatedProductsModel>
        getProductDetailWithoutRelatedProducts =
        GetClient<GetProductDetailWithoutRelatedProductsModel>(
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<GetProductDetailWithoutRelatedProductsModel>(
        endpoint: WebAppEndPoints.productDetailsEP(productSlug),
        response: ResponseValue<GetProductDetailWithoutRelatedProductsModel>(
            fromJson: (response) {
          return GetProductDetailWithoutRelatedProductsModel.fromJson(response);
        }),
      ),
    );
    return getProductDetailWithoutRelatedProducts();
  }

  Future<ReadOnlyMessageFromApiModel> updateLikeSocialSharedProducts(
      Map<String, dynamic> params) {
    GetClient<ReadOnlyMessageFromApiModel> updateLikeSocialSharedProducts =
        GetClient<ReadOnlyMessageFromApiModel>(
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
        queryParameters: params,
        endpoint: WebAppEndPoints.editSocialProductEP,
        response:
            ResponseValue<ReadOnlyMessageFromApiModel>(fromJson: (response) {
          return ReadOnlyMessageFromApiModel.fromJson(response);
        }),
      ),
    );
    return updateLikeSocialSharedProducts();
  }

  Future<GeColorsAndSizesForSearchModel> getColorsAndSizesForSearch() {
    GetClient<GeColorsAndSizesForSearchModel> getColorsAndSizesForSearch =
        GetClient<GeColorsAndSizesForSearchModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GeColorsAndSizesForSearchModel>(
        endpoint: MarketEndPoints.getColorsAndSizesForSearchEP,
        response:
            ResponseValue<GeColorsAndSizesForSearchModel>(fromJson: (response) {
          return GeColorsAndSizesForSearchModel.fromJson(response);
        }),
      ),
    );
    return getColorsAndSizesForSearch();
  }

  Future<GetFullProductDetailsModel> getFullProductDetails(String productSlug) {
    GetClient<GetFullProductDetailsModel> getFullProductDetails =
        GetClient<GetFullProductDetailsModel>(
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<GetFullProductDetailsModel>(
        endpoint: WebAppEndPoints.productDetailsEP(productSlug),
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

  /* Future<GetCommentForProductModel> getCommentForProduct(String productId) {
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
  }*/

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
      serverName: ServerName.webApp,
      //ServerName.elastic,
      requestPrams: RequestConfig<MainCategoriesResponseModel>(
        endpoint: WebAppEndPoints.mainCategoriesEP,
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
        queryParameters: {
          "country": (GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
              ? GetIt.I<PrefsRepository>().userChoosedCountryIso
              : GetIt.I<PrefsRepository>().countryIso),
          "lang": (LanguageService.languageCode == 'ar'
              ? LanguageService.isKurdish
                  ? "ku"
                  : 'ar'
              : LanguageService.languageCode)
        },
        response: ResponseValue<GetCurrencyForCountryModel>(
            fromJson: (response) =>
                GetCurrencyForCountryModel.fromJson(response)),
      ),
    );
    return getCurrencyForCountry();
  }

  Future<UpdateProfileModel> updateProfile(Map<String, dynamic> params) {
    PostClient<UpdateProfileModel> updateProfile =
        PostClient<UpdateProfileModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<UpdateProfileModel>(
        endpoint: MarketEndPoints.updateProfileEP,
        data: params,
        response: ResponseValue<UpdateProfileModel>(
            fromJson: (response) => UpdateProfileModel.fromJson(response)),
      ),
    );
    return updateProfile();
  }

  Future<UploadUserPhotoModel> uploadUserPhoto(Map<String, dynamic> params) {
    PostClient<UploadUserPhotoModel> uploadUserPhoto =
        PostClient<UploadUserPhotoModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<UploadUserPhotoModel>(
        endpoint: MarketEndPoints.uploadUserPhotoModelEP,
        data: params['data'],
        response: ResponseValue<UploadUserPhotoModel>(
            fromJson: (response) => UploadUserPhotoModel.fromJson(response)),
      ),
    );
    return uploadUserPhoto();
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
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<GetProductFiltersModel>(
        endpoint: WebAppEndPoints.searchProductEP,
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
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: WebAppEndPoints.searchProductEP,
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

  Future<GetProductListingWithFiltersModel> getFeaturedProducts(
      Map<String, dynamic> params) {
    GetClient<GetProductListingWithFiltersModel> getFeaturedProducts =
        GetClient<GetProductListingWithFiltersModel>(
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: WebAppEndPoints.productFeaturedEP,
        /*serverName: ServerName.market,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: MarketEndPoints.getProductListingWithFiltersEP,*/
        queryParameters: params,
        response: ResponseValue<GetProductListingWithFiltersModel>(
            fromJson: (response) =>
                GetProductListingWithFiltersModel.fromJson(response)),
      ),
    );

    return getFeaturedProducts();
  }

  Future<GetProductListingWithFiltersModel> getRecommendedProducts(
      Map<String, dynamic> params) {
    GetClient<GetProductListingWithFiltersModel> getRecommendedProducts =
        GetClient<GetProductListingWithFiltersModel>(
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<GetProductListingWithFiltersModel>(
        endpoint: WebAppEndPoints.productRecommendedEP,
        queryParameters: params,
        response: ResponseValue<GetProductListingWithFiltersModel>(
            fromJson: (response) =>
                GetProductListingWithFiltersModel.fromJson(response)),
      ),
    );

    return getRecommendedProducts();
  }

  /* Future<Comment> addComment(Map<String, dynamic> params) {
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
  }*/

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
      serverName: ServerName.webApp,
      //ServerName.elastic,
      requestPrams: RequestConfig<GetHomeBoutiquesModel>(
        endpoint: WebAppEndPoints.homeBoutiquesEP,
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

  Future<ConvertItemFromCartToOldCartModel> convertItemInCartToOldCart(
      Map<String, dynamic> params) {
    PostClient<ConvertItemFromCartToOldCartModel> convertItemInCartToOldCart =
        PostClient<ConvertItemFromCartToOldCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ConvertItemFromCartToOldCartModel>(
        endpoint: MarketEndPoints.convertItemInCartToOldCartEP,
        data: params,
        response: ResponseValue<ConvertItemFromCartToOldCartModel>(
            fromJson: (response) =>
                ConvertItemFromCartToOldCartModel.fromJson(response)),
      ),
    );
    return convertItemInCartToOldCart();
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

  Future<bool> setCustomerAddressDefault(Map<String, dynamic> params) {
    PostClient<bool> setCustomerAddressDefault = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.setCustomerAddressDefaultEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return setCustomerAddressDefault();
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

  Future<CheckAvailabilityProductCartModel> checkAvailabilityProductCart() {
    GetClient<CheckAvailabilityProductCartModel> checkAvailabilityProductCart =
        GetClient<CheckAvailabilityProductCartModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<CheckAvailabilityProductCartModel>(
        endpoint: MarketEndPoints.checkAvailabilityProductCartEP,
        response: ResponseValue<CheckAvailabilityProductCartModel>(
            fromJson: (response) =>
                CheckAvailabilityProductCartModel.fromJson(response)),
      ),
    );

    return checkAvailabilityProductCart();
  }

  Future<ApplyCouponModel> applyCoupon({
    required String code,
  }) {
    GetClient<ApplyCouponModel> applyCoupon = GetClient<ApplyCouponModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ApplyCouponModel>(
        endpoint: MarketEndPoints.applyCouponEP,
        queryParameters: {
          "code": code,
        },
        response: ResponseValue<ApplyCouponModel>(
            fromJson: (response) => ApplyCouponModel.fromJson(response)),
      ),
    );

    return applyCoupon();
  }

  Future<GetCartShippingItemsModel> getCartOverview() {
    GetClient<GetCartShippingItemsModel> getCartOverview =
        GetClient<GetCartShippingItemsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetCartShippingItemsModel>(
        endpoint: MarketEndPoints.getCartOverviewEP,
        response: ResponseValue<GetCartShippingItemsModel>(
            fromJson: (response) =>
                GetCartShippingItemsModel.fromJson(response)),
      ),
    );

    return getCartOverview();
  }

  Future<GetUserNotificationsModel> getUserNotifications({
    required int page,
  }) {
    GetClient<GetUserNotificationsModel> getUserNotifications =
        GetClient<GetUserNotificationsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetUserNotificationsModel>(
        endpoint: MarketEndPoints.getUserNotificationsEP,
        queryParameters: {
          "page": page.toString(),
        },
        response: ResponseValue<GetUserNotificationsModel>(
            fromJson: (response) =>
                GetUserNotificationsModel.fromJson(response)),
      ),
    );

    return getUserNotifications();
  }

  Future<OrderModel> getOrders({
    required Map<String, dynamic> params,
  }) {
    GetClient<OrderModel> getOrders = GetClient<OrderModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<OrderModel>(
        endpoint: MarketEndPoints.getOrderListEP,
        queryParameters: params,
        response: ResponseValue<OrderModel>(
            fromJson: (response) => OrderModel.fromJson(response)),
      ),
    );

    return getOrders();
  }

  Future<CancelOrderItemModel> cancelOrderItem(Map<String, dynamic> params) {
    PostClient<CancelOrderItemModel> cancelOrderItem =
        PostClient<CancelOrderItemModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<CancelOrderItemModel>(
        endpoint: MarketEndPoints.cancelOrderItemEP,
        data: params,
        response: ResponseValue<CancelOrderItemModel>(
            fromJson: (response) => CancelOrderItemModel.fromJson(response)),
      ),
    );

    return cancelOrderItem();
  }

  Future<CancelOrderModel> cancelOrder(Map<String, dynamic> params) {
    PostClient<CancelOrderModel> cancelOrder = PostClient<CancelOrderModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<CancelOrderModel>(
        endpoint: MarketEndPoints.cancelOrderEP,
        data: params,
        response: ResponseValue<CancelOrderModel>(
            fromJson: (response) => CancelOrderModel.fromJson(response)),
      ),
    );

    return cancelOrder();
  }

  Future<ChangeOrderAddressModel> changeOrderAddress(
      Map<String, dynamic> params) {
    PostClient<ChangeOrderAddressModel> changeOrderAddress =
        PostClient<ChangeOrderAddressModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ChangeOrderAddressModel>(
        endpoint: MarketEndPoints.changeOrderAddressEP,
        data: params,
        response: ResponseValue<ChangeOrderAddressModel>(
            fromJson: (response) => ChangeOrderAddressModel.fromJson(response)),
      ),
    );

    return changeOrderAddress();
  }

  Future<ColorSizeForProductModel> getProductColorSizeSyncAttribute(String id) {
    GetClient<ColorSizeForProductModel> getProductColorSizeSyncAttribute =
        GetClient<ColorSizeForProductModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ColorSizeForProductModel>(
        endpoint: MarketEndPoints.getProductColorSizeSyncAttributeEP(id),
        response: ResponseValue<ColorSizeForProductModel>(
            fromJson: (response) =>
                ColorSizeForProductModel.fromJson(response)),
      ),
    );

    return getProductColorSizeSyncAttribute();
  }

  Future<ReadOnlyMessageFromApiModel> changeOrderItemVariant(
      Map<String, dynamic> params) {
    PostClient<ReadOnlyMessageFromApiModel> changeOrderItemVariant =
        PostClient<ReadOnlyMessageFromApiModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
        endpoint: MarketEndPoints.changeOrderItemVariantEP,
        data: params,
        response: ResponseValue<ReadOnlyMessageFromApiModel>(
            fromJson: (response) =>
                ReadOnlyMessageFromApiModel.fromJson(response)),
      ),
    );
    return changeOrderItemVariant();
  }

  Future<ReturnReasonsModel> getReturnReasons() {
    GetClient<ReturnReasonsModel> getReturnReasons =
        GetClient<ReturnReasonsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ReturnReasonsModel>(
        endpoint: MarketEndPoints.getReturnReasonsEP,
        response: ResponseValue<ReturnReasonsModel>(
            fromJson: (response) => ReturnReasonsModel.fromJson(response)),
      ),
    );

    return getReturnReasons();
  }

  Future<UploadImagesForReturnProductModel> uploadImagesForReturnProduct(
      Map<String, dynamic> params) {
    PostClient<UploadImagesForReturnProductModel> uploadImagesForReturnProduct =
        PostClient<UploadImagesForReturnProductModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<UploadImagesForReturnProductModel>(
        endpoint: MarketEndPoints.uploadImagesForReturnProductEP,
        data: params['data'],
        response: ResponseValue<UploadImagesForReturnProductModel>(
            fromJson: (response) =>
                UploadImagesForReturnProductModel.fromJson(response)),
      ),
    );

    return uploadImagesForReturnProduct();
  }

  Future<StoreReturnRequestProductModel> storeReturnRequestProduct(
      Map<String, dynamic> params) {
    PostClient<StoreReturnRequestProductModel> storeReturnRequestProduct =
        PostClient<StoreReturnRequestProductModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<StoreReturnRequestProductModel>(
        endpoint: MarketEndPoints.storeReturnRequestProductEP,
        data: params,
        response: ResponseValue<StoreReturnRequestProductModel>(
            fromJson: (response) =>
                StoreReturnRequestProductModel.fromJson(response)),
      ),
    );

    return storeReturnRequestProduct();
  }

  Future<UpdateReturnRequestModel> updateReturnRequestProduct(
      Map<String, dynamic> params) {
    PostClient<UpdateReturnRequestModel> updateReturnRequestProduct =
        PostClient<UpdateReturnRequestModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<UpdateReturnRequestModel>(
        endpoint: MarketEndPoints.updateReturnRequestProductEP,
        data: params,
        response: ResponseValue<UpdateReturnRequestModel>(
            fromJson: (response) =>
                UpdateReturnRequestModel.fromJson(response)),
      ),
    );

    return updateReturnRequestProduct();
  }

  Future<ConfirmCancelReturnRequestModel> cancelReturnRequest(
      Map<String, dynamic> params) {
    PostClient<ConfirmCancelReturnRequestModel> cancelReturnRequest =
        PostClient<ConfirmCancelReturnRequestModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ConfirmCancelReturnRequestModel>(
        endpoint: MarketEndPoints.cancelReturnRequestEP,
        data: params,
        response: ResponseValue<ConfirmCancelReturnRequestModel>(
            fromJson: (response) =>
                ConfirmCancelReturnRequestModel.fromJson(response)),
      ),
    );

    return cancelReturnRequest();
  }

  Future<CreateReturnReqestModel> storeReturnRequest(
      Map<String, dynamic> params) {
    GetClient<CreateReturnReqestModel> storeReturnRequest =
        GetClient<CreateReturnReqestModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<CreateReturnReqestModel>(
        endpoint: MarketEndPoints.storeReturnRequestEP,
        queryParameters: params,
        response: ResponseValue<CreateReturnReqestModel>(
            fromJson: (response) => CreateReturnReqestModel.fromJson(response)),
      ),
    );
    return storeReturnRequest();
  }

  Future<ConfirmCancelReturnRequestModel> cancelReturnRequestProduct(
      Map<String, dynamic> params) {
    GetClient<ConfirmCancelReturnRequestModel> cancelReturnRequestProduct =
        GetClient<ConfirmCancelReturnRequestModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ConfirmCancelReturnRequestModel>(
        endpoint: MarketEndPoints.cancelReturnRequestProductEP,
        queryParameters: params,
        response: ResponseValue<ConfirmCancelReturnRequestModel>(
            fromJson: (response) =>
                ConfirmCancelReturnRequestModel.fromJson(response)),
      ),
    );

    return cancelReturnRequestProduct();
  }

  Future<ConfirmCancelReturnRequestModel> confirmReturnRequest(
      Map<String, dynamic> params) {
    PostClient<ConfirmCancelReturnRequestModel> confirmReturnRequest =
        PostClient<ConfirmCancelReturnRequestModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ConfirmCancelReturnRequestModel>(
        endpoint: MarketEndPoints.confirmReturnRequestEP,
        data: params,
        response: ResponseValue<ConfirmCancelReturnRequestModel>(
            fromJson: (response) =>
                ConfirmCancelReturnRequestModel.fromJson(response)),
      ),
    );

    return confirmReturnRequest();
  }

  Future<ReadOnlyMessageFromApiModel> searchByImageFromGemini(
      Map<String, dynamic> params) {
    PostClient<ReadOnlyMessageFromApiModel> searchByImageFromGemini =
        PostClient<ReadOnlyMessageFromApiModel>(
      serverName: ServerName.webApp,
      requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
        endpoint: WebAppEndPoints.imageSearchEP,
        data: params["data"],
        response: ResponseValue<ReadOnlyMessageFromApiModel>(
            fromJson: (response) =>
                ReadOnlyMessageFromApiModel.fromJson(response)),
      ),
    );

    return searchByImageFromGemini();
  }

  Future<ReadOnlyMessageFromApiModel> orderReturnRequestsView(
      Map<String, dynamic> params) {
    GetClient<ReadOnlyMessageFromApiModel> orderReturnRequestsView =
        GetClient<ReadOnlyMessageFromApiModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
        endpoint: MarketEndPoints.orderReturnRequestsViewEP,
        queryParameters: params,
        response: ResponseValue<ReadOnlyMessageFromApiModel>(
            fromJson: (response) =>
                ReadOnlyMessageFromApiModel.fromJson(response)),
      ),
    );

    return orderReturnRequestsView();
  }

  Future<GetOrderReturntDetailsModel> getOrderReturnDetails(
      Map<String, dynamic> params) {
    GetClient<GetOrderReturntDetailsModel> getOrderReturnDetailsClient =
        GetClient<GetOrderReturntDetailsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetOrderReturntDetailsModel>(
        endpoint: MarketEndPoints.orderReturnDetailsEP,
        queryParameters: params,
        response: ResponseValue<GetOrderReturntDetailsModel>(
          fromJson: (response) =>
              GetOrderReturntDetailsModel.fromJson(response),
        ),
      ),
    );
    return getOrderReturnDetailsClient();
  }

  Future<GetAuthProductDetailsModel> getAuthProductDetails(String productSlug) {
    GetClient<GetAuthProductDetailsModel> client =
        GetClient<GetAuthProductDetailsModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetAuthProductDetailsModel>(
        endpoint: MarketEndPoints.getAuthProductDetailsEP(productSlug),
        response: ResponseValue<GetAuthProductDetailsModel>(
          fromJson: (response) => GetAuthProductDetailsModel.fromJson(response),
        ),
      ),
    );
    return client();
  }
}
