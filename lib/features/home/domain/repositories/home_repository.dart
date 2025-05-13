import 'package:dartz/dartz.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/convert_item_from_oldCart_to_cart_model.dart';
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
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_provinces_by_iso_model.dart';
import 'package:trydos/features/home/data/models/list_of_products_in_cart_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/data/models/update_profile_model.dart';
import 'package:trydos/features/home/data/models/upload_user_photo_model.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/apply_coupon_model.dart';
import '../../data/models/check_availability_product_cart_model.dart';
import '../../data/models/customer_wallet_model.dart';
import '../../data/models/get_full_product_details_model.dart';
import '../../data/models/get_orders_model.dart';
import '../../data/models/get_product_filters_model.dart';
import '../../data/models/get_product_listing_with_filters_model.dart';
import '../../data/models/get_story_for_product_model.dart';
import '../../data/models/get_user_notifications_model.dart';
import '../../data/models/place_order_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings();
  Future<Either<Failure, GetCartShippingItemsModel>> getCartShippingItem();
  // Future<Either<Failure, GetBrandModel>> getBrand();
//Future<Either<Failure, GetCategoryModel>> getCategory();

  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories(
      Map<String, dynamic> params);
  // Future<Either<Failure, GetIsLikedOFProductModel>> getIsLikedOFProduct(
//      Map<String, dynamic> params);
  Future<Either<Failure, bool>> addLikeOFProduct(Map<String, dynamic> params);
  Future<Either<Failure, bool>> deleteLikeOFProduct(
      Map<String, dynamic> params);
  Future<Either<Failure, GetProductFiltersModel>> getProductFilters(
      Map<String, dynamic> params);
  Future<Either<Failure, bool>> sendErrorToMobileErrorLog(
      Map<String, dynamic> params);

  /* Future<Either<Failure, HomeSectionResponseModel>> getHomeSections(
      Map<String, dynamic> params);*/
  Future<Either<Failure, GetHomeBoutiquesModel>> getHomeBoutiqes(
      Map<String, dynamic> params);

  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateWhatsappNotification(Map<String, dynamic> params);
  Future<Either<Failure, UpdateProfileModel>> updateProfile(
      Map<String, dynamic> params);
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateFirebaseNotification(Map<String, dynamic> params);
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateEmailNotification(Map<String, dynamic> params);
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      updateNotificationFrequency(Map<String, dynamic> params);
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      changeCountryLanguageFornotification(Map<String, dynamic> params);

  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      unSubscribeTopicFornotification(Map<String, dynamic> params);
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      subscribeTopicFornotification(Map<String, dynamic> params);
  Future<Either<Failure, FirebaseSettingForNotificationModel>>
      getMyFirebaseSettings();
  Future<Either<Failure, CountryBoundaryByIsoModel>> getCountryBoundaryByIso();
  Future<Either<Failure, NotificationTypeForProductModel>>
      getNotificationTypeForProduct();

  Future<Either<Failure, GeColorsAndSizesForSearchModel>>
      getColorsAndSizesForSearch();
  Future<Either<Failure, ListOfProductsFoundedInCartModel>>
      getProductsListInCart();
  Future<Either<Failure, bool>> storeFcmTokenOfMarket(
      Map<String, dynamic> params);
  Future<Either<Failure, PopularSearchTermsModel>> getPopularSearchTerms();
  Future<Either<Failure, GetListOfCustomerAddressesInfoModel>>
      getCustomerAddresses();
  Future<Either<Failure, GetProvincesByIsoModel>> getProvincesByIso();
  Future<Either<Failure, GetAllowedCountriesModel>> getAllowCountries();
  Future<Either<Failure, GetStoryForProductModel>> getStories(String productId);
  Future<Either<Failure, GetProductListingWithoutFiltersModel>>
      getProductsWithoutFilters(Map<String, dynamic> params);
  Future<Either<Failure, UploadUserPhotoModel>> uploadUserPhoto(
      Map<String, dynamic> params);
  Future<Either<Failure, GetProductListingWithFiltersModel>>
      getProductsWithFilters(Map<String, dynamic> params);
  Future<Either<Failure, GetProductListingWithFiltersModel>>
      getFeaturedProducts(Map<String, dynamic> params);
  Future<Either<Failure, ResponseOnlyMessageModel>> addCustomerAddress(
      Map<String, dynamic> params);
  Future<Either<Failure, GetAddressByTextModel>> getAddressByText(
      Map<String, dynamic> params);
  Future<Either<Failure, GetAddressByCoordinatesModel>> getAddressByCoordinates(
      Map<String, dynamic> params);
  Future<Either<Failure, ResponseOnlyMessageModel>> updateCustomerAddress(
      Map<String, dynamic> params);
  Future<Either<Failure, ResponseOnlyMessageModel>> deleteCustomerAddress(
      Map<String, dynamic> params);
  Future<Either<Failure, GetProductDetailWithoutRelatedProductsModel>>
      getProductDetailWithoutSimilarRelatedProducts(String productSlug);
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
  Future<Either<Failure, bool>> setCustomerAddressDefault(
      Map<String, dynamic> params);
  Future<Either<Failure, ConvertItemFromOldCartToCartModel>>
      convertItemInOldCartToCart(Map<String, dynamic> params);
  Future<Either<Failure, bool>> removeItemToCart(Map<String, dynamic> params);
  Future<Either<Failure, Comment>> addComment(Map<String, dynamic> params);
  Future<Either<Failure, ReadOnlyMessageFromApiModel>>
      requestForNotificationWhenProductBecameAvailable(
          Map<String, dynamic> params);

  Future<Either<Failure, CustomerWalletModel>> getCustomerWallet({
    required int limit,
    required int offset,
  });

  Future<Either<Failure, OrdersGroupModel>> placeOrder({
    required Map<String, dynamic> params,
    required String paymentMethod,
  });

  Future<Either<Failure, OrdersGroupModel>> getOrdersByOrderGroupID({
    required String orderGroupID,
  });

  Future<Either<Failure, OrdersGroupModel>> getOrdersByCartGroupID({
    required String cartGroupID,
  });

  Future<Either<Failure, CheckAvailabilityProductCartModel>>
      checkAvailabilityProductCart();

  Future<Either<Failure, ApplyCouponModel>> applyCoupon({
    required String code,
  });

  Future<Either<Failure, GetCartShippingItemsModel>> getCartOverview();

  Future<Either<Failure, GetUserNotificationsModel>> getUserNotifications({
    required int page,
  });

  Future<Either<Failure, OrderModel>> getOrders(
      {required Map<String, dynamic> params});
}
