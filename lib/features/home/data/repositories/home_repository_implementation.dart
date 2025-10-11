import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';

import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/apply_coupon_model.dart';
import 'package:trydos/features/home/data/models/convert_item_from_cart_to_oldCart_model.dart';
import 'package:trydos/features/home/data/models/customer_wallet_model.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_coordinates_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_text_model.dart';

import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_boundary_cordinates_by_iso_model.dart';

import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_colors_and_sizes_model.dart';

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';

import 'package:trydos/features/home/data/models/get_count_view_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import 'package:trydos/features/home/data/models/get_full_product_details_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';

import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/data/models/get_order_details_return_model.dart';
import 'package:trydos/features/home/data/models/get_orders_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_provinces_by_iso_model.dart';
import 'package:trydos/features/home/data/models/get_user_notifications_model.dart';
import 'package:trydos/features/home/data/models/create_return_request_model.dart';
import 'package:trydos/features/home/data/models/list_of_products_in_cart_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import 'package:trydos/features/home/data/models/place_order_model.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/cancel_order_item_model.dart';
import 'package:trydos/features/home/data/models/cancel_order_model.dart';
import 'package:trydos/features/home/data/models/change_order_address_model.dart';
import 'package:trydos/features/home/data/models/color_size_for_product.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/data/models/confirm_return_request_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/data/models/update_profile_model.dart';
import 'package:trydos/features/home/data/models/update_return_request_model.dart';
import 'package:trydos/features/home/data/models/upload_images_for_return_product_model.dart';
import 'package:trydos/features/home/data/models/return_request_product_model.dart';
import 'package:trydos/features/home/data/models/upload_user_photo_model.dart';
import 'package:trydos/features/home/data/models/get_auth_product_details_model.dart';

import '../../../../core/api/handling_exception.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_data_source.dart';
import '../models/check_availability_product_cart_model.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_story_for_product_model.dart';
import '../models/starting_settings_response_model.dart';
import '../models/order_comment_model.dart';
import '../models/return_reasons_model.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl extends HomeRepository with HandlingExceptionRequest {
  HomeRepositoryImpl(this.dataSource);

  final HomeRemoteDatasource dataSource;

  @override
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings() {
    return handlingExceptionRequest(tryCall: dataSource.getStartingSettings);
  }

  Future<Either<Failure, GeColorsAndSizesForSearchModel>>
      getColorsAndSizesForSearch() {
    return handlingExceptionRequest(
        tryCall: dataSource.getColorsAndSizesForSearch);
  }

  @override
  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getMainCategories(params));
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>>
      updateLikeSocialSharedProducts(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateLikeSocialSharedProducts(params));
  }

  @override
  Future<Either<Failure, GetProductListingWithFiltersModel>>
      getRecommendedProducts(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getRecommendedProducts(params));
  }

  @override
  Future<Either<Failure, CountryBoundaryByIsoModel>> getCountryBoundaryByIso(
      String iso) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getCountryBoundaryByIso(iso));
  }

  @override
  Future<Either<Failure, ListOfProductsFoundedInCartModel>>
      getProductsListInCart() {
    return handlingExceptionRequest(tryCall: dataSource.getProductsListInCart);
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
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      changeCountryLanguageFornotification(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.changeCountryLanguageFornotification(params));
  }

  @override
  Future<Either<Failure, UpdateProfileModel>> updateProfile(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateProfile(params));
  }

  @override
  Future<Either<Failure, UploadUserPhotoModel>> uploadUserPhoto(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.uploadUserPhoto(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      unSubscribeTopicFornotification(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.unSubscribeTopicFornotification(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      subscribeTopicFornotification(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.subscribeTopicFornotification(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateWhatsappNotification(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateWhatsappNotification(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateFirebaseNotification(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateFirebaseNotification(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateEmailNotification(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateEmailNotification(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateNotificationFrequency(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateNotificationFrequency(params));
  }

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      getMyFirebaseSettings() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getMyFirebaseSettings());
  }

  @override
  Future<Either<Failure, NotificationTypeForProductModel>>
      getNotificationTypeForProduct() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getNotificationTypeForProduct());
  }

  @override
  Future<Either<Failure, GetProvincesByIsoModel>> getProvincesByIso() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getProvincesByIso());
  }

  @override
  Future<Either<Failure, bool>> sendErrorToMobileErrorLog(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.sendErrorToMobileErrorLog(params));
  }

  @override
  Future<Either<Failure, PopularSearchTermsModel>> getPopularSearchTerms() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getPopularSearchTerms());
  }

  @override
  Future<Either<Failure, GetProductListingWithoutFiltersModel>>
      getProductsWithoutFilters(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getProductsWithoutFilters(params));
  }

  @override
  Future<Either<Failure, GetCountViewOfProductModel>>
      getAndAddCountViewOfProduct(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getAndAddCountViewOfProduct(params));
  }

  @override
  Future<Either<Failure, bool>> hideItemsInOldCart(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.hideItemsInOldCart(params));
  }

  Future<Either<Failure, ConvertItemFromCartToOldCartModel>>
      convertItemInCartToOldCart(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.convertItemInCartToOldCart(params));
  }

  @override
  Future<Either<Failure, bool>> addLikeOFProduct(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.addLikeOFProduct(params));
  }

  @override
  Future<Either<Failure, GetOldCartModel>> getOldCartItems() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getOldCartItems());
  }

  @override
  Future<Either<Failure, bool>> deleteLikeOFProduct(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.deleteLikeOFProduct(params));
  }

  @override
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>>
      getProductDetailWithoutSimilarRelatedProducts(String productSlug) {
    return handlingExceptionRequest(
      tryCall: () =>
          dataSource.getProductDetailWithoutRelatedProducts(productSlug),
    );
  }

  @override
  Future<Either<Failure, GetStoryForProductModel>> getStories(
      String productId) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getStories(productId));
  }

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> addCustomerAddress(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.addCustomerAddress(params));
  }

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> updateCustomerAddress(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateCustomerAddress(params));
  }

  @override
  Future<Either<Failure, GetListOfCustomerAddressesInfoModel>>
      getCustomerAddresses() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getCustomerAddresses());
  }

  @override
  Future<Either<Failure, GetAddressByTextModel>> getAddressByText(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getAddressByText(params));
  }

  @override
  Future<Either<Failure, GetAddressByCoordinatesModel>> getAddressByCoordinates(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getAddressByCoordinates(params));
  }

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> deleteCustomerAddress(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.deleteCustomerAddress(params));
  }

  @override
  Future<Either<Failure, GetProductFiltersModel>> getProductFilters(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getProductFilters(params));
  }

  /* @override
  Future<Either<Failure, GetCommentForProductModel>> geCommentForProduct(
      String productId) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getCommentForProduct(productId));
  }*/

  @override
  Future<Either<Failure, GetCartShippingItemsModel>> getCartShippingItem() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getCartShippingItems());
  }

  @override
  Future<Either<Failure, AddItemToCartModel>> addItemToCart(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.addItemToCart(params));
  }

  @override
  Future<Either<Failure, GetProductListingWithFiltersModel>>
      getProductsWithFilters(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getProductsWithFilters(params));
  }

  @override
  Future<Either<Failure, GetProductListingWithFiltersModel>>
      getFeaturedProducts(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getFeaturedProducts(params));
  }

  @override
  Future<Either<Failure, bool>> removeItemToCart(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.removeItemToCart(params));
  }

  @override
  Future<Either<Failure, GetCurrencyForCountryModel>> getCurrencyForCountry() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getCurrencyForCountry());
  }

  @override
  Future<Either<Failure, bool>> setCustomerAddressDefault(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.setCustomerAddressDefault(params));
  }

  @override
  Future<Either<Failure, UpdateItemInCartModel>> UpdateItemToCart(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateItemInCart(params));
  }

/*@override
  Future<Either<Failure, GetBrandModel>> getBrand() {
    return handlingExceptionRequest(tryCall: () => dataSource.getBrand());
  }

  @override
  Future<Either<Failure, GetCategoryModel>> getCategory() {
    return handlingExceptionRequest(tryCall: () => dataSource.getCategory());
  }*/

  /* Future<Either<Failure, SearchResultModel>> getSearchResult(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getSearchResult(params));
  */

  @override
  Future<Either<Failure, GetAllowedCountriesModel>> getAllowCountries() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getAllowedCountries());
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>>
      requestForNotificationWhenProductBecameAvailable(
          Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource
            .requestForNotificationWhenProductBecameAvailable(params));
  }

  @override
  Future<Either<Failure, GetFullProductDetailsModel>> getFullProductDetails(
      String productSlug) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getFullProductDetails(productSlug));
  }

  @override
  Future<Either<Failure, Comment>> addComment(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.addComment(params));
  }

  @override
  Future<Either<Failure, OrderCommentModel>> addOrderComment(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.addOrderComment(params));
  }

  @override
  Future<Either<Failure, OrderCommentModel>> updateOrderComment(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateOrderComment(params));
  }

  @override
  Future<Either<Failure, bool>> storeFcmTokenOfMarket(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.storeFcmTokenOfMarket(params));
  }

  @override
  Future<Either<Failure, CustomerWalletModel>> getCustomerWallet({
    required int limit,
    required int offset,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getCustomerWallet(limit: limit, offset: offset),
    );
  }

  @override
  Future<Either<Failure, OrdersGroupModel>> placeOrder({
    required Map<String, dynamic> params,
    required String paymentMethod,
  }) async {
    return handlingExceptionRequest(
      tryCall: () =>
          dataSource.placeOrder(params: params, paymentMethod: paymentMethod),
    );
  }

  @override
  Future<Either<Failure, OrdersGroupModel>> getOrdersByOrderGroupID({
    required String orderGroupID,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getOrdersByOrderGroupID(
        orderGroupID: orderGroupID,
      ),
    );
  }

  @override
  Future<Either<Failure, OrdersGroupModel>> getOrdersByCartGroupID({
    required String cartGroupID,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getOrdersByCartGroupID(
        cartGroupID: cartGroupID,
      ),
    );
  }

  @override
  Future<Either<Failure, CheckAvailabilityProductCartModel>>
      checkAvailabilityProductCart() {
    return handlingExceptionRequest(
      tryCall: () => dataSource.checkAvailabilityProductCart(),
    );
  }

  @override
  Future<Either<Failure, ApplyCouponModel>> applyCoupon({
    required String code,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.applyCoupon(code: code),
    );
  }

  @override
  Future<Either<Failure, GetCartShippingItemsModel>> getCartOverview() {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getCartOverview(),
    );
  }

  @override
  Future<Either<Failure, GetUserNotificationsModel>> getUserNotifications({
    required int page,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getUserNotifications(page: page),
    );
  }

  @override
  Future<Either<Failure, OrderModel>> getOrders({
    required Map<String, dynamic> params,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getOrders(params: params),
    );
  }

  @override
  Future<Either<Failure, CancelOrderItemModel>> cancelOrderItem(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.cancelOrderItem(params),
    );
  }

  @override
  Future<Either<Failure, CancelOrderModel>> cancelOrder(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.cancelOrder(params),
    );
  }

  @override
  Future<Either<Failure, ChangeOrderAddressModel>> changeOrderAddress(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.changeOrderAddress(params),
    );
  }

  @override
  Future<Either<Failure, ColorSizeForProductModel>>
      getProductColorSizeSyncAttribute(String id) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getProductColorSizeSyncAttribute(id),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> changeOrderItemVariant(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.changeOrderItemVariant(params));
  }

  @override
  Future<Either<Failure, ReturnReasonsModel>> getReturnReasons() {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getReturnReasons());
  }

  @override
  Future<Either<Failure, UploadImagesForReturnProductModel>>
      uploadImagesForReturnProduct(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.uploadImagesForReturnProduct(params));
  }

  @override
  Future<Either<Failure, StoreReturnRequestProductModel>>
      storeReturnRequestProduct(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.storeReturnRequestProduct(params));
  }

  @override
  Future<Either<Failure, UpdateReturnRequestModel>> updateReturnRequestProduct(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.updateReturnRequestProduct(params));
  }

  @override
  Future<Either<Failure, ConfirmCancelReturnRequestModel>> cancelReturnRequest(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.cancelReturnRequest(params));
  }

  @override
  Future<Either<Failure, CreateReturnReqestModel>> storeReturnRequest(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.storeReturnRequest(params));
  }

  @override
  Future<Either<Failure, ConfirmCancelReturnRequestModel>>
      cancelReturnRequestProduct(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.cancelReturnRequestProduct(params));
  }

  @override
  Future<Either<Failure, ConfirmCancelReturnRequestModel>> confirmReturnRequest(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.confirmReturnRequest(params));
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> orderReturnRequestsView(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.orderReturnRequestsView(params));
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> searchByImageFromGemini(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.searchByImageFromGemini(params));
  }

  @override
  Future<Either<Failure, GetOrderReturntDetailsModel>> getOrderReturnDetails(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getOrderReturnDetails(params),
    );
  }

  @override
  Future<Either<Failure, GetAuthProductDetailsModel>> getAuthProductDetails(
      String productSlug) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getAuthProductDetails(productSlug),
    );
  }
}
