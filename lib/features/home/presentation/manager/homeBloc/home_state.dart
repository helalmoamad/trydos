import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
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
import '../../../data/models/get_cart_item_model.dart';
import '../../../data/models/get_old_cart_model.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../../data/models/get_user_notifications_model.dart';
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

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }

enum AddOrRemoveLikeOfProductStatus { init, loading, success, failure }

enum GetProductListingStatus { init, loading, success, failure }

enum GetAndAddCountViewOfProductStatus { init, loading, success, failure }

enum ChangeSizesForEveryProduct { init, loading, success, failure }

enum GetFirebaseSettingForNotificationStatus { init, loading, success, failure }

enum UpdateWhatsappNotificationStatus { init, loading, success, failure }

enum UpdateEmailappNotificationStatus { init, loading, success, failure }

enum CheckAvailabilityProductCartStatus { init, loading, success, failure }

enum GetCartOverviewStatus { init, loading, success, failure }

enum UpdateProfileStatus { init, loading, success, failure }

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
      this.currentSelectedColorForEveryProductStatus,
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
      this.getUserNotificationModel,
      this.checkAvailabilityProductCartModel,
      this.currentPage = 0,
      this.productStatus,
      this.updateItemInCartStatus,
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
      this.addVariationToCartId = const {},
      this.addImagesToProductIdForCart = const {},
      this.searchHistory,
      this.getAllowedCountriesModel,

      //   this.moveUrlFromElasticToMarketServer = false,

      this.cartIdsHurryUPTimerStarted = const {},
      this.listitemForAddToCart,
      this.getListOfProductsFoundedInCartStatus =
          GetListOfProductsFoundedInCartStatus.init,
      this.getCurrencyForCountryModel,
      this.popularSearchTerm,
      this.getCartOverviewStatus = GetCartOverviewStatus.init,
      this.checkAvailabilityProductCartStatus =
          CheckAvailabilityProductCartStatus.init,
      this.getCartItemsStatus = GetCartItemsStatus.init,
      this.checkWithGetCartStatus = CheckWithGetCartStatus.init,
      this.getProductDetailWithoutRelatedProductsModel,
      this.addOrRemoveLikeOfProductStatus = AddOrRemoveLikeOfProductStatus.init,
      this.getProductListingPaginationWithoutFiltersModel = const {},
      this.currentSelectedColorForEveryProduct = const {},
      this.notificationTypeForProductModel,
      this.getNotificationTypeProductStatus,
      this.currentIndexForUpdateCart,
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

  final NotificationTypeForProductModel? notificationTypeForProductModel;
  final Map<String, GetAndAddCountViewOfProductStatus>
      getAndAddCountViewOfProductStatus;
  final List<PopularSearchTerm>? popularSearchTerm;

  final PaginationModel<NotificationItemModel>? getUserNotificationModel;

  final GetCartOverviewStatus? getCartOverviewStatus;

  final CheckAvailabilityProductCartModel? checkAvailabilityProductCartModel;
  final CheckAvailabilityProductCartStatus? checkAvailabilityProductCartStatus;

  final List<ImageForAddToCart>? listitemForAddToCart;

  //final bool moveUrlFromElasticToMarketServer;
  final GetAllowedCountriesModel? getAllowedCountriesModel;

  final GetCurrencyForCountryModel? getCurrencyForCountryModel;

  final AddItemInCartStatus? addItemInCartStatus;
  final UpdateItemInCartStatus? updateItemInCartStatus;
  final DeleteItemInCartStatus? deleteItemInCartStatus;
  final AddCommentStatus addCommentStatus;

  final AddOrRemoveLikeOfProductStatus addOrRemoveLikeOfProductStatus;

  final int? selectedCollection;
  final int currentPage;

  // String? idForRequest;
  final List<String>? searchHistory;
  final List<String> listOfErrorSendedToMobileErrorLog;

  final Map<String, String>? searchWithOutFilterOffset;
  final Map<String, Map<int, List<String>>> addImagesToProductIdForCart;
  final Map<String, Map<String, String>>? addVariationToCartId;
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
        notificationTypeForProductModel,
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

        updateEmailappNotificationStatus,
        updateWhatsappNotificationStatus,

        getUserNotificationModel,

        getCartOverviewStatus,

        checkAvailabilityProductCartStatus,
        checkAvailabilityProductCartModel,

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
        addVariationToCartId,
        deleteItemInCartStatus,
        updateItemInCartStatus,
        currentSelectedColorForEveryProduct,
        isVariantRequestNotification,
        selectedCollection,

        startingSetting,
        currentIndexForUpdateCart,
        currentColorSizeForCart,

        isChangedvariationWhenQtyZero,
        getFirebaseSettingForNotificationStatus,

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
      final EnableAddToCardAfterChangeVariantZero?
          enableAddToCardAfterChangeVariantZero,
      final UpdateProfileStatus? updateProfileStatus,
      final User? userInfo,
      final UploadUserPhotoCloudinaryStatus? uploadUserPhotoCloudinaryStatus,
      final PaginationModel<NotificationItemModel>? getUserNotificationModel,
      final GetCartOverviewStatus? getCartOverviewStatus,
      final CurrentSelectedColorForEveryProductStatus?
          currentSelectedColorForEveryProductStatus,
      final Map<String, Map<String, String>>? addVariationToCartId,
      final CheckAvailabilityProductCartModel?
          checkAvailabilityProductCartModel,
      final CheckAvailabilityProductCartStatus?
          checkAvailabilityProductCartStatus,
      final AddItemInCartStatus? addItemInCartStatus,
      final HideItemInOldCartStatus? hideItemInOldCartStatus,
      final ConvertItemFromOldcartToCartStatus?
          convertItemFromOldcartToCartStatus,
      final GetNotificationTypeProductStatus? getNotificationTypeProductStatus,
      // final bool? moveUrlFromElasticToMarketServer,
      final UpdateItemInCartStatus? updateItemInCartStatus,
      final List<String>? listOfErrorSendedToMobileErrorLog,
      final NotificationTypeForProductModel? notificationTypeForProductModel,
      final GetListOfProductsFoundedInCartStatus?
          getListOfProductsFoundedInCartStatus,
      final List<CustomerAddressesInfo>? listOfAdressInfoClassToSave,
      final Map<String, String>? searchWithOutFilterOffset,
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

      enableAddToCardAfterChangeVariantZero:
          enableAddToCardAfterChangeVariantZero ??
              this.enableAddToCardAfterChangeVariantZero,
      addVariationToCartId: addVariationToCartId ?? this.addVariationToCartId,
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
      notificationTypeForProductModel: notificationTypeForProductModel ??
          this.notificationTypeForProductModel,
      firebaseSettingForNotificationModel:
          firebaseSettingForNotificationModel ??
              this.firebaseSettingForNotificationModel,
      isChangedvariationWhenQtyZero:
          isChangedvariationWhenQtyZero ?? this.isChangedvariationWhenQtyZero,

      changeSizesForEveryProduct:
          changeSizesForEveryProduct ?? this.changeSizesForEveryProduct,

      getNotificationTypeProductStatus: getNotificationTypeProductStatus ??
          this.getNotificationTypeProductStatus,

      currentIndexForUpdateCart:
          currentIndexForUpdateCart ?? this.currentIndexForUpdateCart,

      getUserNotificationModel:
          getUserNotificationModel ?? this.getUserNotificationModel,
      getCartOverviewStatus:
          getCartOverviewStatus ?? this.getCartOverviewStatus,

      checkAvailabilityProductCartModel: checkAvailabilityProductCartModel ??
          this.checkAvailabilityProductCartModel,
      checkAvailabilityProductCartStatus: checkAvailabilityProductCartStatus ??
          this.checkAvailabilityProductCartStatus,

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
