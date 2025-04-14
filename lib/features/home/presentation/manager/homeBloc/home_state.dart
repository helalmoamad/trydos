import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_coordinates_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_text_model.dart';

import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart'
    as boutiques_model;
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;

import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../data/models/apply_coupon_model.dart';
import '../../../data/models/check_availability_product_cart_model.dart';
import '../../../data/models/customer_wallet_model.dart';
import '../../../data/models/get_cart_item_model.dart';

import '../../../data/models/get_old_cart_model.dart';
import '../../../data/models/get_orders_model.dart';
import '../../../data/models/get_product_filters_model.dart' as get_filters;
import '../../../data/models/get_product_filters_model.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../../data/models/get_user_notifications_model.dart';
import '../../../data/models/main_categories_response_model.dart';
import '../../../data/models/place_order_model.dart';
import '../../../data/models/starting_settings_response_model.dart';

part 'home_state.g.dart';

enum GetStartingSettingsStatus { init, loading, success, failure }

enum GetProductDetailWithoutSimilarRelatedProductsStatus {
  init,
  loading,
  success,
  failure
}

enum GetFullProductDetailsStatus { init, loading, success, failure }

enum SelectedVideoStatus { init, loading, success, failure }

enum GetCommentForProductStatus { init, loading, success, failure }

enum GetCartItemsStatus { init, loading, success, available, failure }

enum CheckWithGetCartStatus {
  init,
  loading,
  successForCart,
  successForPlaceOrder,
  available,
  failure
}

enum GetOLdCartItemsStatus { init, loading, success, failure }

enum ConvertItemFromOldcartToCartStatus { init, loading, success, failure }

enum GetStoriesForProductStatus { init, loading, success, failure }

enum GetListOfProductsFoundedInCartStatus { init, loading, success, failure }

enum HideItemInOldCartStatus { init, loading, success, failure }

enum AddItemInCartStatus { init, loading, success, failure }

enum UpdateItemInCartStatus { init, loading, success, failure }

enum DeleteItemInCartStatus { init, loading, success, failure }

enum AddCommentStatus { init, loading, success, failure }

enum UploadUserPhotoCloudinaryStatus { init, loading, success, failure }

enum GetNotificationTypeProductStatus { init, loading, success, failure }

enum AddAddressToOrderStatus { init, loading, success, failure }

enum EditAddressToOrderStatus { init, loading, success, failure }

enum GetCustomerAddressesStatus { init, loading, success, failure }

enum RemoveAddressToOrderStatus { init, loading, success, failure }

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }

enum AddOrRemoveLikeOfProductStatus { init, loading, success, failure }

enum GetAddressByTextStatus { init, loading, success, failure }

enum GetAddressByCoordinatesStatus { init, loading, success, failure }

enum GetCustomerWalletStatus { init, loading, success, failure }

enum GetProductListingStatus { init, loading, success, failure }

enum GetAndAddCountViewOfProductStatus { init, loading, success, failure }

enum ChangeSizesForEveryProduct { init, loading, success, failure }

enum GetFirebaseSettingForNotificationStatus { init, loading, success, failure }

enum UpdateWhatsappNotificationStatus { init, loading, success, failure }

enum UpdateEmailappNotificationStatus { init, loading, success, failure }

enum PlaceOrderStatus { init, loading, success, failure, unavailable }

enum GetOrdersByOrderGroupIDStatus { init, loading, success, failure }

enum GetOrdersByCartGroupIDStatus { init, loading, success, failure }

enum CheckAvailabilityProductCartStatus { init, loading, success, failure }

enum ApplyCouponStatus { init, loading, success, failure }

enum GetCartOverviewStatus { init, loading, success, failure }

enum UpdateProfileStatus { init, loading, success, failure }

enum SetCustomerAddressDefaultStatus { init, loading, success, failure }

enum EnableAddToCardAfterChangeVariantZero { init, loading, success, failure }

enum CurrentSelectedColorForEveryProductStatus {
  init,
  loading,
  success,
  failure
}

@JsonSerializable(explicitToJson: true)
@immutable
class HomeState extends Equatable {
  const HomeState(
      {this.storiesForProduct,
      this.getAndAddCountViewOfProductStatus = const {},
      this.addItemInCartStatus,
      this.convertItemFromOldcartToCartStatus,
      this.resultSearch = const [],
      this.hideItemInOldCartStatus,
      this.updateEmailappNotificationStatus,
      this.updateWhatsappNotificationStatus,
      this.changeSizesForEveryProduct,
      this.uploadUserPhotoCloudinaryStatus,
      this.searchWithOutFilterOffset,
      this.updateProfileStatus,
      this.getProductDetailWithoutSimilarRelatedProductsStatus =
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
      this.getCommentForProductStatus = GetCommentForProductStatus.init,
      this.editAddressToOrderStatus,
      this.currentSelectedColorForEveryProductStatus,
      this.addAddressToOrderStatus,
      this.removeAddressToOrderStatus,
      this.isChangedvariationWhenQtyZero = false,
      this.getFullProductDetailsStatus = GetFullProductDetailsStatus.init,
      this.addCommentStatus = AddCommentStatus.init,
      this.startingSetting,
      this.sizesForEachColor = const [],
      this.colorsForEachProduct = const [],
      this.colorsQuantitiesForEachProduct = const [],
      this.sizesQuantitiesForEachColor = const [],
      this.isVariantRequestNotification = const [],
      this.deleteItemInCartStatus,
      this.oldcartCollection,
      this.enableAddToCardAfterChangeVariantZero,
      this.getOldCartItemsStatus = GetOLdCartItemsStatus.init,
      this.getOldCartModel,
      this.getAddressByCoordinatesModel,
      this.customerWalletModel,
      this.setCustomerAddressDefaultStatus,
      this.placeOrderModel,
      this.applyCouponModel,
      this.getUserNotificationModel,
      this.getOrdersModel,
      this.getOrdersByOrderGroupIDModel,
      this.getOrdersByCartGroupIDModel,
      this.checkAvailabilityProductCartModel,
      this.currentPage = 0,
      this.productStatus,
      this.updateItemInCartStatus,
      this.getCustomerAddressStatus,
      this.productITemForCart = const {},
      this.getCartShippingItemsModel,
      this.getCommentForProductModel = const {},
      this.reRequestTheseProductListingInBoutiques = const {},
      this.reRequestProductWithFilters = const {},
      this.getProductListingStatus = GetProductListingStatus.init,
      this.selectedCollection,
      this.productContentForStatusOfOpeningProductDetailsDirectly,
      this.cartCollection = const [],
      //this.idForRequest,

      this.getStoriesForProductStatus = GetStoriesForProductStatus.init,
      this.currentColorSizeForCart,
      this.currentQuantityForCart,
      this.addImagesToProductIdForCart = const {},
      this.searchHistory,
      this.currentAddressChoosed,
      this.getAllowedCountriesModel,

      //   this.moveUrlFromElasticToMarketServer = false,

      this.cartIdsHurryUPTimerStarted = const {},
      this.listitemForAddToCart,
      this.getListOfProductsFoundedInCartStatus =
          GetListOfProductsFoundedInCartStatus.init,
      this.getCurrencyForCountryModel,
      this.popularSearchTerm,
      this.getAddressByCoordinatesStatus,
      this.getCustomerWalletStatus,
      this.placeOrderStatus = PlaceOrderStatus.init,
      this.applyCouponStatus = ApplyCouponStatus.init,
      this.getCartOverviewStatus = GetCartOverviewStatus.init,
      this.getOrdersByOrderGroupIDStatus = GetOrdersByOrderGroupIDStatus.init,
      this.getOrdersByCartGroupIDStatus = GetOrdersByCartGroupIDStatus.init,
      this.checkAvailabilityProductCartStatus =
          CheckAvailabilityProductCartStatus.init,
      this.getAddressByTextStatus,
      this.getCartItemsStatus = GetCartItemsStatus.init,
      this.checkWithGetCartStatus = CheckWithGetCartStatus.init,
      this.getProductDetailWithoutRelatedProductsModel,
      this.addOrRemoveLikeOfProductStatus = AddOrRemoveLikeOfProductStatus.init,
      this.getProductListingPaginationWithoutFiltersModel = const {},
      this.currentSelectedColorForEveryProduct = const {},
      this.notificationTypeForProductModel,
      this.getNotificationTypeProductStatus,
      this.currentIndexForUpdateCart,
      this.listOfAddressInfoClassToSave = const [],
      this.userInfo,
      this.listOfErrorSendedToMobileErrorLog = const [],
      this.cachedProductWithoutRelatedProductsModel = const {},
      this.getFirebaseSettingForNotificationStatus,
      this.firebaseSettingForNotificationModel});

  final GetFirebaseSettingForNotificationStatus?
      getFirebaseSettingForNotificationStatus;
  final FirebaseSettingForNotificationModel?
      firebaseSettingForNotificationModel;
  final UpdateProfileStatus? updateProfileStatus;

  final GetStartingSettingsStatus getStartingSettingsStatus;
  final Map<String, int> currentSelectedColorForEveryProduct;
  final GetCommentForProductStatus getCommentForProductStatus;
  final Map<String, product.Products> productITemForCart;
  final User? userInfo;
  final CurrentSelectedColorForEveryProductStatus?
      currentSelectedColorForEveryProductStatus;
  final UploadUserPhotoCloudinaryStatus? uploadUserPhotoCloudinaryStatus;

  final EnableAddToCardAfterChangeVariantZero?
      enableAddToCardAfterChangeVariantZero;
  final bool isChangedvariationWhenQtyZero;

  final ConvertItemFromOldcartToCartStatus? convertItemFromOldcartToCartStatus;

  final GetNotificationTypeProductStatus? getNotificationTypeProductStatus;
  final HideItemInOldCartStatus? hideItemInOldCartStatus;
  final GetCustomerAddressesStatus? getCustomerAddressStatus;
  final NotificationTypeForProductModel? notificationTypeForProductModel;
  final Map<String, GetAndAddCountViewOfProductStatus>
      getAndAddCountViewOfProductStatus;
  final List<PopularSearchTerm>? popularSearchTerm;
  final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus;
  final List<ResultSearch>? resultSearch;
  final GetAddressByCoordinatesModel? getAddressByCoordinatesModel;
  final CustomerWalletModel? customerWalletModel;
  final OrdersGroupModel? placeOrderModel;
  final PlaceOrderStatus? placeOrderStatus;
  final ApplyCouponModel? applyCouponModel;
  final ApplyCouponStatus? applyCouponStatus;

  final PaginationModel<NotificationItemModel>? getUserNotificationModel;
  final PaginationModel<OrderListModel>? getOrdersModel;

  final GetCartOverviewStatus? getCartOverviewStatus;
  final OrdersGroupModel? getOrdersByOrderGroupIDModel;
  final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus;
  final OrdersGroupModel? getOrdersByCartGroupIDModel;
  final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus;

  final CheckAvailabilityProductCartModel? checkAvailabilityProductCartModel;
  final CheckAvailabilityProductCartStatus? checkAvailabilityProductCartStatus;

  final List<ImageForAddToCart>? listitemForAddToCart;
  final GetAddressByTextStatus? getAddressByTextStatus;
  final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus;
  final GetCustomerWalletStatus? getCustomerWalletStatus;
  //final bool moveUrlFromElasticToMarketServer;
  final GetAllowedCountriesModel? getAllowedCountriesModel;
  final RemoveAddressToOrderStatus? removeAddressToOrderStatus;
  final EditAddressToOrderStatus? editAddressToOrderStatus;
  final AddAddressToOrderStatus? addAddressToOrderStatus;

  final List<CustomerAddressesInfo>? listOfAddressInfoClassToSave;
  final GetCurrencyForCountryModel? getCurrencyForCountryModel;

  final AddItemInCartStatus? addItemInCartStatus;
  final UpdateItemInCartStatus? updateItemInCartStatus;
  final DeleteItemInCartStatus? deleteItemInCartStatus;
  final AddCommentStatus addCommentStatus;

  final AddOrRemoveLikeOfProductStatus addOrRemoveLikeOfProductStatus;

  final int? selectedCollection;
  final int currentPage;
  final int? currentAddressChoosed;

  // String? idForRequest;
  final List<String>? searchHistory;
  final List<String> listOfErrorSendedToMobileErrorLog;

  final Map<String, String>? searchWithOutFilterOffset;
  final Map<String, Map<int, List<String>>> addImagesToProductIdForCart;
  final Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
      productStatus;
  final List<cart.Cart>? cartCollection;

  final Map<String, int> cartIdsHurryUPTimerStarted;
  final GetListOfProductsFoundedInCartStatus
      getListOfProductsFoundedInCartStatus;
  final UpdateEmailappNotificationStatus? updateEmailappNotificationStatus;
  final UpdateWhatsappNotificationStatus? updateWhatsappNotificationStatus;
  final List<oldCart.OldCart>? oldcartCollection;

  final Map<String, bool> reRequestTheseProductListingInBoutiques;
  final Map<String, bool> reRequestProductWithFilters;
  final GetProductDetailWithoutSimilarRelatedProductsStatus
      getProductDetailWithoutSimilarRelatedProductsStatus;

  final GetFullProductDetailsStatus getFullProductDetailsStatus;

  final GetCartItemsStatus getCartItemsStatus;
  final CheckWithGetCartStatus checkWithGetCartStatus;
  final GetOLdCartItemsStatus getOldCartItemsStatus;
  final Products? productContentForStatusOfOpeningProductDetailsDirectly;

  final GetProductListingStatus getProductListingStatus;
  final GetStoriesForProductStatus getStoriesForProductStatus;

  final List<Story>? storiesForProduct;
  final List<String>? sizesForEachColor;
  final List<String>? colorsForEachProduct;
  final List<int>? sizesQuantitiesForEachColor;
  final List<int>? colorsQuantitiesForEachProduct;
  final List<String> isVariantRequestNotification;

  final Map<String, PaginationModel<product.Products>>
      getProductListingPaginationWithoutFiltersModel;
  final cart.GetCartShippingItemsModel? getCartShippingItemsModel;
  final oldCart.GetOldCartModel? getOldCartModel;
  final Map<String, GetCommentForProductModel> getCommentForProductModel;

  final GetProductDetailWithoutRelatedProductsModel?
      getProductDetailWithoutRelatedProductsModel;
  final ChangeSizesForEveryProduct? changeSizesForEveryProduct;

  final int? currentIndexForUpdateCart;
  final StartingSetting? startingSetting;
  final Map<String, String>? currentColorSizeForCart;

  final Map<String, List<int>>? currentQuantityForCart;
  final Map<String, GetProductDetailWithoutRelatedProductsModel>
      cachedProductWithoutRelatedProductsModel;

  @override
  List<Object?> get props => [
        getStartingSettingsStatus,
        currentSelectedColorForEveryProduct,
        getListOfProductsFoundedInCartStatus,
        getCommentForProductStatus,
        productITemForCart,

        oldcartCollection,
        convertItemFromOldcartToCartStatus,
        getOldCartModel,
        getOldCartItemsStatus,
        editAddressToOrderStatus,
        addAddressToOrderStatus,
        notificationTypeForProductModel,
        removeAddressToOrderStatus,
        getCustomerAddressStatus,
        updateProfileStatus,
        currentSelectedColorForEveryProductStatus,
        listitemForAddToCart,
        getAllowedCountriesModel,

        userInfo,
        popularSearchTerm,

        getCurrencyForCountryModel,

        enableAddToCardAfterChangeVariantZero,

        cartIdsHurryUPTimerStarted,
        addCommentStatus,
        changeSizesForEveryProduct,
        hideItemInOldCartStatus,
        // moveUrlFromElasticToMarketServer,

        listOfAddressInfoClassToSave,
        getAddressByCoordinatesStatus,
        updateEmailappNotificationStatus,
        updateWhatsappNotificationStatus,

        getCustomerWalletStatus,
        placeOrderStatus,
        placeOrderModel,
        applyCouponStatus,
        applyCouponModel,
        getUserNotificationModel,
        getOrdersModel,
        getCartOverviewStatus,
        getOrdersByOrderGroupIDStatus,
        getOrdersByOrderGroupIDModel,
        getOrdersByCartGroupIDStatus,
        getOrdersByCartGroupIDModel,

        checkAvailabilityProductCartStatus,
        checkAvailabilityProductCartModel,

        getAddressByTextStatus,
        listOfErrorSendedToMobileErrorLog,
        uploadUserPhotoCloudinaryStatus,

        productContentForStatusOfOpeningProductDetailsDirectly,

        getAndAddCountViewOfProductStatus,

        selectedCollection,
        currentPage,
        sizesQuantitiesForEachColor,

        searchHistory,
        addImagesToProductIdForCart,
        productStatus,
        cartCollection,
        setCustomerAddressDefaultStatus,

        resultSearch,

        reRequestTheseProductListingInBoutiques,
        reRequestProductWithFilters,
        getProductDetailWithoutSimilarRelatedProductsStatus,
        getCartItemsStatus,
        checkWithGetCartStatus,
        getProductListingStatus,
        getStoriesForProductStatus,

        storiesForProduct,
        sizesForEachColor,
        getFullProductDetailsStatus,

        getProductListingPaginationWithoutFiltersModel,
        getCartShippingItemsModel,
        getCommentForProductModel,

        getProductDetailWithoutRelatedProductsModel,

        addItemInCartStatus,

        addImagesToProductIdForCart,
        deleteItemInCartStatus,
        updateItemInCartStatus,
        currentAddressChoosed,
        currentSelectedColorForEveryProduct,
        isVariantRequestNotification,
        selectedCollection,

        startingSetting,
        currentIndexForUpdateCart,
        currentColorSizeForCart,
        getAddressByCoordinatesModel,
        isChangedvariationWhenQtyZero,
        getFirebaseSettingForNotificationStatus,
        customerWalletModel,
        currentQuantityForCart,
        firebaseSettingForNotificationModel,
        cachedProductWithoutRelatedProductsModel,
        addOrRemoveLikeOfProductStatus
      ];

  HomeState copyWith(
      {final GetStartingSettingsStatus? getStartingSettingsStatus,
      final GetFirebaseSettingForNotificationStatus?
          getFirebaseSettingForNotificationStatus,
      final FirebaseSettingForNotificationModel?
          firebaseSettingForNotificationModel,
      final bool? isChangedvariationWhenQtyZero,
      final GetAddressByCoordinatesModel? getAddressByCoordinatesModel,
      final CustomerWalletModel? customerWalletModel,
      final EnableAddToCardAfterChangeVariantZero?
          enableAddToCardAfterChangeVariantZero,
      final OrdersGroupModel? placeOrderModel,
      final UpdateProfileStatus? updateProfileStatus,
      final User? userInfo,
      final PlaceOrderStatus? placeOrderStatus,
      final ApplyCouponModel? applyCouponModel,
      final ApplyCouponStatus? applyCouponStatus,
      final UploadUserPhotoCloudinaryStatus? uploadUserPhotoCloudinaryStatus,
      final PaginationModel<NotificationItemModel>? getUserNotificationModel,
      final PaginationModel<OrderListModel>? getOrdersModel,
      final GetCartOverviewStatus? getCartOverviewStatus,
      final CurrentSelectedColorForEveryProductStatus?
          currentSelectedColorForEveryProductStatus,
      final OrdersGroupModel? getOrdersByOrderGroupIDModel,
      final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus,
      final OrdersGroupModel? getOrdersByCartGroupIDModel,
      final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus,
      final CheckAvailabilityProductCartModel?
          checkAvailabilityProductCartModel,
      final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus,
      final CheckAvailabilityProductCartStatus?
          checkAvailabilityProductCartStatus,
      final AddItemInCartStatus? addItemInCartStatus,
      final HideItemInOldCartStatus? hideItemInOldCartStatus,
      final ConvertItemFromOldcartToCartStatus?
          convertItemFromOldcartToCartStatus,
      final GetNotificationTypeProductStatus? getNotificationTypeProductStatus,
      // final bool? moveUrlFromElasticToMarketServer,
      final UpdateItemInCartStatus? updateItemInCartStatus,
      final GetCustomerAddressesStatus? getCustomerAddressesStatus,
      final List<ResultSearch>? resultSearch,
      final List<String>? listOfErrorSendedToMobileErrorLog,
      final NotificationTypeForProductModel? notificationTypeForProductModel,
      final GetListOfProductsFoundedInCartStatus?
          getListOfProductsFoundedInCartStatus,
      final List<CustomerAddressesInfo>? listOfAdressInfoClassToSave,
      final RemoveAddressToOrderStatus? removeAddressToOrderStatus,
      final EditAddressToOrderStatus? editAddressToOrderStatus,
      final AddAddressToOrderStatus? addAddressToOrderStatus,
      final Map<String, String>? searchWithOutFilterOffset,
      final int? currentAddressChoosed,
      final GetAddressByTextStatus? getAddressByTextStatus,
      final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus,
      final GetCustomerWalletStatus? getCustomerWalletStatus,
      final Map<String, GetAndAddCountViewOfProductStatus>?
          getAndAddCountViewOfProductStatus,
      final List<PopularSearchTerm>? popularSearchTerm,
      final List<String>? cartIdsSubsecribedToTopicHurryUP,
      final Map<String, int>? cartIdsHurryUPTimerStarted,
      final ChangeSizesForEveryProduct? changeSizesForEveryProduct,
      // String? idForRequest,

      Map<String, Map<int, List<String>>>? addImagesToProductIdForCart,
      final List<ImageForAddToCart>? listitemForAddToCart,
      final GetAllowedCountriesModel? getAllowedCountriesModel,
      final GetCommentForProductStatus? getCommentForProductStatus,
      final AddOrRemoveLikeOfProductStatus? addOrRemoveLikeOfProductStatus,
      final GetCartItemsStatus? getCartItemsStatus,
      final CheckWithGetCartStatus? checkWithGetCartStatus,
      final UpdateEmailappNotificationStatus? updateEmailappNotificationStatus,
      final UpdateWhatsappNotificationStatus? updateWhatsappNotificationStatus,
      final GetOLdCartItemsStatus? getOldCartItemsStatus,
      Map<int, int?>? currentStoryInEachCollection,
      final AddCommentStatus? addCommentStatus,
      final GetProductDetailWithoutRelatedProductsModel?
          getProductDetailWithoutRelatedProductsModel,
      int? selectedCollection,
      final Products? productContentForStatusOfOpeningProductDetailsDirectly,
      List<String>? sizesForEachColor,
      List<int>? sizesQuantitiesForEachColor,
      List<String>? colorsForEachProduct,
      List<int>? colorsQuantitiesForProduct,
      List<String>? isVariantRequestNotification,
      int? currentIndexForUpdateCart,
      List<String>? searchHistory,
      Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
          productStatus,
      Map<String, List<int>>? currentQuantityForCart,
      List<cart.Cart>? cartCollection,
      List<oldCart.OldCart>? oldCartCollection,
      Map<String, String>? currentColorSizeForCart,
      final Map<String, product.Products>? productITemForCart,
      final cart.GetCartShippingItemsModel? getCartShippingItemsModel,
      final oldCart.GetOldCartModel? getOldCartModel,
      final Map<String, bool>? reRequestTheseProductListingInBoutiques,
      final Map<String, bool>? reRequestProductWithFilters,
      final StartingSetting? startingSetting,
      final GetCurrencyForCountryModel? getCurrencyForCountryModel,
      final Map<String, GetProductDetailWithoutRelatedProductsModel>?
          cachedProductWithoutRelatedProductsModel,
      SelectedVideoStatus? selectedVideoStatus,
      GetStoriesForProductStatus? getStoriesForProductStatus,
      GetFullProductDetailsStatus? getFullProductDetailsStatus,
      final GetProductDetailWithoutSimilarRelatedProductsStatus?
          getProductDetailWithoutSimilarRelatedProductsStatus,
      final DeleteItemInCartStatus? deleteItemInCartStatus,
      final Map<String, int>? currentSelectedColorForEveryProduct,
      int? currentPage,
      List<Story>? storiesForProduct,
      final Map<String, PaginationModel<product.Products>>?
          getProductListingPaginationWithoutFiltersModel,
      final Map<String, GetCommentForProductModel>?
          getCommentForProductModel}) {
    return HomeState(
      getAndAddCountViewOfProductStatus: getAndAddCountViewOfProductStatus ??
          this.getAndAddCountViewOfProductStatus,

      getAddressByCoordinatesModel:
          getAddressByCoordinatesModel ?? this.getAddressByCoordinatesModel,
      customerWalletModel: customerWalletModel ?? this.customerWalletModel,
      enableAddToCardAfterChangeVariantZero:
          enableAddToCardAfterChangeVariantZero ??
              this.enableAddToCardAfterChangeVariantZero,
      updateProfileStatus: updateProfileStatus ?? this.updateProfileStatus,
      uploadUserPhotoCloudinaryStatus: uploadUserPhotoCloudinaryStatus ??
          this.uploadUserPhotoCloudinaryStatus,
      userInfo: userInfo ?? this.userInfo,

      hideItemInOldCartStatus:
          hideItemInOldCartStatus ?? this.hideItemInOldCartStatus,
      getCommentForProductModel:
          getCommentForProductModel ?? this.getCommentForProductModel,
      getFirebaseSettingForNotificationStatus:
          getFirebaseSettingForNotificationStatus ??
              this.getFirebaseSettingForNotificationStatus,
      updateItemInCartStatus:
          updateItemInCartStatus ?? this.updateItemInCartStatus,
      colorsForEachProduct: colorsForEachProduct ?? this.colorsForEachProduct,
      colorsQuantitiesForEachProduct:
          colorsQuantitiesForProduct ?? this.colorsQuantitiesForEachProduct,
      currentSelectedColorForEveryProductStatus:
          currentSelectedColorForEveryProductStatus ??
              this.currentSelectedColorForEveryProductStatus,
      setCustomerAddressDefaultStatus: setCustomerAddressDefaultStatus ??
          this.setCustomerAddressDefaultStatus,
      notificationTypeForProductModel: notificationTypeForProductModel ??
          this.notificationTypeForProductModel,
      listOfAddressInfoClassToSave:
          listOfAdressInfoClassToSave ?? this.listOfAddressInfoClassToSave,
      removeAddressToOrderStatus:
          removeAddressToOrderStatus ?? this.removeAddressToOrderStatus,

      firebaseSettingForNotificationModel:
          firebaseSettingForNotificationModel ??
              this.firebaseSettingForNotificationModel,
      isChangedvariationWhenQtyZero:
          isChangedvariationWhenQtyZero ?? this.isChangedvariationWhenQtyZero,

      changeSizesForEveryProduct:
          changeSizesForEveryProduct ?? this.changeSizesForEveryProduct,
      addAddressToOrderStatus:
          addAddressToOrderStatus ?? this.addAddressToOrderStatus,
      resultSearch: resultSearch ?? this.resultSearch,
      getCustomerAddressStatus:
          getCustomerAddressesStatus ?? this.getCustomerAddressStatus,
      getNotificationTypeProductStatus: getNotificationTypeProductStatus ??
          this.getNotificationTypeProductStatus,
      editAddressToOrderStatus:
          editAddressToOrderStatus ?? this.editAddressToOrderStatus,
      getAddressByCoordinatesStatus:
          getAddressByCoordinatesStatus ?? this.getAddressByCoordinatesStatus,
      getCustomerWalletStatus:
          getCustomerWalletStatus ?? this.getCustomerWalletStatus,
      placeOrderModel: placeOrderModel ?? this.placeOrderModel,
      currentIndexForUpdateCart:
          currentIndexForUpdateCart ?? this.currentIndexForUpdateCart,
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      applyCouponModel: applyCouponModel ?? this.applyCouponModel,
      applyCouponStatus: applyCouponStatus ?? this.applyCouponStatus,

      getUserNotificationModel:
          getUserNotificationModel ?? this.getUserNotificationModel,

      getOrdersModel: getOrdersModel ?? this.getOrdersModel,
      getCartOverviewStatus:
          getCartOverviewStatus ?? this.getCartOverviewStatus,
      getOrdersByOrderGroupIDModel:
          getOrdersByOrderGroupIDModel ?? this.getOrdersByOrderGroupIDModel,
      getOrdersByOrderGroupIDStatus:
          getOrdersByOrderGroupIDStatus ?? this.getOrdersByOrderGroupIDStatus,
      getOrdersByCartGroupIDModel:
          getOrdersByCartGroupIDModel ?? this.getOrdersByCartGroupIDModel,
      getOrdersByCartGroupIDStatus:
          getOrdersByCartGroupIDStatus ?? this.getOrdersByCartGroupIDStatus,

      checkAvailabilityProductCartModel: checkAvailabilityProductCartModel ??
          this.checkAvailabilityProductCartModel,
      checkAvailabilityProductCartStatus: checkAvailabilityProductCartStatus ??
          this.checkAvailabilityProductCartStatus,

      getAddressByTextStatus:
          getAddressByTextStatus ?? this.getAddressByTextStatus,
      addOrRemoveLikeOfProductStatus:
          addOrRemoveLikeOfProductStatus ?? this.addOrRemoveLikeOfProductStatus,
      convertItemFromOldcartToCartStatus: convertItemFromOldcartToCartStatus ??
          this.convertItemFromOldcartToCartStatus,
      popularSearchTerm: popularSearchTerm ?? this.popularSearchTerm,
      listOfErrorSendedToMobileErrorLog: listOfErrorSendedToMobileErrorLog ??
          this.listOfErrorSendedToMobileErrorLog,
      //   moveUrlFromElasticToMarketServer: moveUrlFromElasticToMarketServer ??
      //     this.moveUrlFromElasticToMarketServer,
      sizesForEachColor: sizesForEachColor ?? this.sizesForEachColor,
      getFullProductDetailsStatus:
          getFullProductDetailsStatus ?? this.getFullProductDetailsStatus,
      sizesQuantitiesForEachColor:
          sizesQuantitiesForEachColor ?? this.sizesQuantitiesForEachColor,
      addCommentStatus: addCommentStatus ?? this.addCommentStatus,

      isVariantRequestNotification:
          isVariantRequestNotification ?? this.isVariantRequestNotification,

      cartIdsHurryUPTimerStarted:
          cartIdsHurryUPTimerStarted ?? this.cartIdsHurryUPTimerStarted,

      // idForRequest: idForRequest ?? this.idForRequest,

      getListOfProductsFoundedInCartStatus:
          getListOfProductsFoundedInCartStatus ??
              this.getListOfProductsFoundedInCartStatus,
      productContentForStatusOfOpeningProductDetailsDirectly:
          productContentForStatusOfOpeningProductDetailsDirectly ??
              this.productContentForStatusOfOpeningProductDetailsDirectly,

      listitemForAddToCart: listitemForAddToCart ?? this.listitemForAddToCart,
      addImagesToProductIdForCart:
          addImagesToProductIdForCart ?? this.addImagesToProductIdForCart,
      cartCollection: cartCollection ?? this.cartCollection,
      currentAddressChoosed:
          currentAddressChoosed ?? this.currentAddressChoosed,
      oldcartCollection: oldCartCollection ?? this.oldcartCollection,
      getOldCartItemsStatus:
          getOldCartItemsStatus ?? this.getOldCartItemsStatus,

      getOldCartModel: getOldCartModel ?? this.getOldCartModel,

      addItemInCartStatus: addItemInCartStatus ?? this.addItemInCartStatus,

      getCurrencyForCountryModel:
          getCurrencyForCountryModel ?? this.getCurrencyForCountryModel,

      currentQuantityForCart:
          currentQuantityForCart ?? this.currentQuantityForCart,

      productITemForCart: productITemForCart ?? this.productITemForCart,
      currentColorSizeForCart:
          currentColorSizeForCart ?? this.currentColorSizeForCart,

      searchHistory: searchHistory ?? this.searchHistory,
      getCartShippingItemsModel:
          getCartShippingItemsModel ?? this.getCartShippingItemsModel,

      getCommentForProductStatus:
          getCommentForProductStatus ?? this.getCommentForProductStatus,

      currentSelectedColorForEveryProduct:
          currentSelectedColorForEveryProduct ??
              this.currentSelectedColorForEveryProduct,
      getCartItemsStatus: getCartItemsStatus ?? this.getCartItemsStatus,
      checkWithGetCartStatus:
          checkWithGetCartStatus ?? this.checkWithGetCartStatus,

      reRequestTheseProductListingInBoutiques:
          reRequestTheseProductListingInBoutiques ??
              this.reRequestTheseProductListingInBoutiques,
      reRequestProductWithFilters:
          reRequestProductWithFilters ?? this.reRequestProductWithFilters,
      getStoriesForProductStatus:
          getStoriesForProductStatus ?? this.getStoriesForProductStatus,
      selectedCollection: selectedCollection ?? this.selectedCollection,
      getProductDetailWithoutSimilarRelatedProductsStatus:
          getProductDetailWithoutSimilarRelatedProductsStatus ??
              this.getProductDetailWithoutSimilarRelatedProductsStatus,
      getStartingSettingsStatus:
          getStartingSettingsStatus ?? this.getStartingSettingsStatus,
      currentPage: currentPage ?? this.currentPage,
      storiesForProduct: storiesForProduct ?? this.storiesForProduct,

      startingSetting: startingSetting ?? this.startingSetting,

      getProductListingPaginationWithoutFiltersModel:
          getProductListingPaginationWithoutFiltersModel ??
              this.getProductListingPaginationWithoutFiltersModel,
      updateEmailappNotificationStatus: updateEmailappNotificationStatus ??
          this.updateEmailappNotificationStatus,
      updateWhatsappNotificationStatus: updateWhatsappNotificationStatus ??
          this.updateWhatsappNotificationStatus,
      cachedProductWithoutRelatedProductsModel:
          cachedProductWithoutRelatedProductsModel ??
              this.cachedProductWithoutRelatedProductsModel,
      deleteItemInCartStatus:
          deleteItemInCartStatus ?? this.deleteItemInCartStatus,

      searchWithOutFilterOffset:
          searchWithOutFilterOffset ?? this.searchWithOutFilterOffset,
      getProductDetailWithoutRelatedProductsModel:
          getProductDetailWithoutRelatedProductsModel ??
              this.getProductDetailWithoutRelatedProductsModel,
      productStatus: productStatus ?? this.productStatus,
      getAllowedCountriesModel:
          getAllowedCountriesModel ?? this.getAllowedCountriesModel,
    );
  }

  factory HomeState.fromJson(Map<String, dynamic> data) =>
      _$HomeStateFromJson(data);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);
}
