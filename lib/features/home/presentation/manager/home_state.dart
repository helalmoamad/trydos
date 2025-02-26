import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
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
import '../../../../core/data/model/pagination_model.dart';
import '../../data/models/apply_coupon_model.dart';
import '../../data/models/check_availability_product_cart_model.dart';
import '../../data/models/customer_wallet_model.dart';
import '../../data/models/get_cart_item_model.dart';
import '../../data/models/get_old_cart_model.dart';
import '../../data/models/get_product_filters_model.dart' as get_filters;
import '../../data/models/get_product_filters_model.dart';
import '../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../data/models/main_categories_response_model.dart';
import '../../data/models/place_order_model.dart';
import '../../data/models/starting_settings_response_model.dart';

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

enum GetProductFiltersStatus { init, loading, success, failure }

enum GetCommentForProductStatus { init, loading, success, failure }

enum GetMainCategoriesStatus { init, loading, success, failure }

enum GetCartItemsStatus { init, loading, success, failure }

enum GetOLdCartItemsStatus { init, loading, success, failure }

enum ConvertItemFromOldcartToCartStatus { init, loading, success, failure }

enum GetStoriesForProductStatus { init, loading, success, failure }

enum SendRequestToGeminiStatus { init, loading, success, failure }

enum GetListOfProductsFoundedInCartStatus { init, loading, success, failure }

enum GetHomeBoutiqesStatus { init, loading, success, failure }

enum HideItemInOldCartStatus { init, loading, success, failure }

enum AddItemInCartStatus { init, loading, success, failure }

enum UpdateItemInCartStatus { init, loading, success, failure }

enum DeleteItemInCartStatus { init, loading, success, failure }

enum AddCommentStatus { init, loading, success, failure }

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
      this.searchWithOutFilterOffset,
      this.searchWithFilterOffset,
      this.getProductDetailWithoutSimilarRelatedProductsStatus =
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
      this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
      this.getCommentForProductStatus = GetCommentForProductStatus.init,
      this.editAddressToOrderStatus,
      this.addAddressToOrderStatus,
      this.removeAddressToOrderStatus,
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
      this.getOldCartItemsStatus = GetOLdCartItemsStatus.init,
      this.getOldCartModel,
      this.isGettingProductListingWithPagination = false,
      this.isGettingProductListingWithPaginationForAppearProduct = false,
      this.getProductFiltersStatus = const {},
      this.getProductFiltersModel = const {},
      this.choosedFiltersByUser = const {},
      this.getAddressByCoordinatesModel,
      this.customerWalletModel,
      this.placeOrderModel,
      this.applyCouponModel,
      this.getOrdersByOrderGroupIDModel,
      this.getOrdersByCartGroupIDModel,
      this.checkAvailabilityProductCartModel,
      this.appliedFiltersByUser = const {},
      this.currentPage = 0,
      this.productStatus,
      this.updateItemInCartStatus,
      this.getCustomerAddressStatus,
      this.theReplyFromGemini,
      this.productITemForCart = const {},
      this.getCartShippingItemsModel,
      this.reRequestTheseBoutiques = const {},
      this.getCommentForProductModel = const {},
      this.reRequestTheseProductListingInBoutiques = const {},
      this.reRequestProductWithFilters = const {},
      this.getProductListingStatus = GetProductListingStatus.init,
      this.selectedCollection,
      this.productContentForStatusOfOpeningProductDetailsDirectly,
      this.cartCollection = const [],
      //this.idForRequest,
      this.getProductListingWithFiltersPaginationModels = const {},
      this.getStoriesForProductStatus = GetStoriesForProductStatus.init,
      this.mainCategoriesResponseModel,
      this.sendRequestToGeminiStatus = SendRequestToGeminiStatus.init,
      this.currentColorSizeForCart,
      this.currentQuantityForCart,
      this.addImagesToProductIdForCart = const {},
      this.searchHistory,
      this.cashedOrginalBoutique = false,
      this.getAllowedCountriesModel,
      this.currentIndexForMainCategoryEvent = -1,
      //   this.moveUrlFromElasticToMarketServer = false,
      this.prefAppliedFilterForExtendFilter,
      this.cartIdsHurryUPTimerStarted = const {},
      this.fromSearchForSearchWithGemini = false,
      this.listitemForAddToCart,
      this.getListOfProductsFoundedInCartStatus =
          GetListOfProductsFoundedInCartStatus.init,
      this.getCurrencyForCountryModel,
      this.isExpandedForListingPage = false,
      this.popularSearchTerm,
      this.getAddressByCoordinatesStatus,
      this.getCustomerWalletStatus,
      this.placeOrderStatus = PlaceOrderStatus.init,
      this.applyCouponStatus = ApplyCouponStatus.init,
      this.getOrdersByOrderGroupIDStatus = GetOrdersByOrderGroupIDStatus.init,
      this.getOrdersByCartGroupIDStatus = GetOrdersByCartGroupIDStatus.init,
      this.checkAvailabilityProductCartStatus =
          CheckAvailabilityProductCartStatus.init,
      this.getAddressByTextStatus,
      this.countOfProductExpectedByFiltering,
      this.getCartItemsStatus = GetCartItemsStatus.init,
      this.getProductDetailWithoutRelatedProductsModel,
      this.addOrRemoveLikeOfProductStatus = AddOrRemoveLikeOfProductStatus.init,
      this.getProductListingPaginationWithoutFiltersModel = const {},
      this.getProductListingWithFiltersPaginationWithPrefetchModels = const {},
      this.getProductFiltersWithPrefetchModel = const {},
      this.currentSelectedColorForEveryProduct = const {},
      this.boutiquesThatDidPrefetch = const {},
      this.notificationTypeForProductModel,
      this.getNotificationTypeProductStatus,
      this.listOfAddressInfoClassToSave = const [],
      this.listOfErrorSendedToMobileErrorLog = const [],
      this.boutiquesForEveryMainCategoryThatDidPrefetch = const {},
      this.cachedProductWithoutRelatedProductsModel = const {},
      this.getHomeBoutiquesPaginationObjectByMainCategory = const {},
      this.getFirebaseSettingForNotificationStatus,
      this.firebaseSettingForNotificationModel});

  final Map<String, bool> boutiquesThatDidPrefetch;
  final GetFirebaseSettingForNotificationStatus?
      getFirebaseSettingForNotificationStatus;
  final FirebaseSettingForNotificationModel?
      firebaseSettingForNotificationModel;
  final Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch;
  final GetStartingSettingsStatus getStartingSettingsStatus;
  final Map<String, int> currentSelectedColorForEveryProduct;
  final GetCommentForProductStatus getCommentForProductStatus;
  final Map<String, product.Products> productITemForCart;
  final ConvertItemFromOldcartToCartStatus? convertItemFromOldcartToCartStatus;
  final GetMainCategoriesStatus getMainCategoriesStatus;
  final GetNotificationTypeProductStatus? getNotificationTypeProductStatus;
  final HideItemInOldCartStatus? hideItemInOldCartStatus;
  final GetCustomerAddressesStatus? getCustomerAddressStatus;
  final NotificationTypeForProductModel? notificationTypeForProductModel;
  final Map<String, GetAndAddCountViewOfProductStatus>
      getAndAddCountViewOfProductStatus;
  final List<PopularSearchTerm>? popularSearchTerm;
  final List<ResultSearch>? resultSearch;
  final GetAddressByCoordinatesModel? getAddressByCoordinatesModel;
  final CustomerWalletModel? customerWalletModel;
  final OrdersGroupModel? placeOrderModel;
  final PlaceOrderStatus? placeOrderStatus;
  final ApplyCouponModel? applyCouponModel;
  final ApplyCouponStatus? applyCouponStatus;
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
  final Map<String, GetProductFiltersStatus> getProductFiltersStatus;
  final Map<String, PaginationModel<product.Products>?>
      getProductListingWithFiltersPaginationModels;
  final List<CustomerAddressesInfo>? listOfAddressInfoClassToSave;
  final GetCurrencyForCountryModel? getCurrencyForCountryModel;
  final Map<String, PaginationModel<product.Products>?>
      getProductListingWithFiltersPaginationWithPrefetchModels;
  final SendRequestToGeminiStatus sendRequestToGeminiStatus;
  final AddItemInCartStatus? addItemInCartStatus;
  final UpdateItemInCartStatus? updateItemInCartStatus;
  final DeleteItemInCartStatus? deleteItemInCartStatus;
  final AddCommentStatus addCommentStatus;

  final Map<String, get_filters.GetProductFiltersModel?> getProductFiltersModel;
  final Map<String, get_filters.GetProductFiltersModel?>
      getProductFiltersWithPrefetchModel;
  final AddOrRemoveLikeOfProductStatus addOrRemoveLikeOfProductStatus;
  final Map<String, get_filters.GetProductFiltersModel?> appliedFiltersByUser;
  final Map<String, get_filters.GetProductFiltersModel?> choosedFiltersByUser;
  final int? selectedCollection;
  final int currentPage;

  final bool? isExpandedForListingPage;

  final bool isGettingProductListingWithPagination;
  final bool isGettingProductListingWithPaginationForAppearProduct;

  // String? idForRequest;
  final List<String>? searchHistory;
  final List<String> listOfErrorSendedToMobileErrorLog;
  final Map<String, String>? searchWithFilterOffset;
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

  final Map<String, bool> reRequestTheseBoutiques;
  final Map<String, bool> reRequestTheseProductListingInBoutiques;
  final Map<String, bool> reRequestProductWithFilters;
  final GetProductDetailWithoutSimilarRelatedProductsStatus
      getProductDetailWithoutSimilarRelatedProductsStatus;

  final GetFullProductDetailsStatus getFullProductDetailsStatus;
  final String? theReplyFromGemini;

  final GetCartItemsStatus getCartItemsStatus;
  final GetOLdCartItemsStatus getOldCartItemsStatus;
  final Products? productContentForStatusOfOpeningProductDetailsDirectly;

  final GetProductListingStatus getProductListingStatus;
  final GetStoriesForProductStatus getStoriesForProductStatus;
  final Map<String, PaginationModel<boutiques_model.Boutique>>
      getHomeBoutiquesPaginationObjectByMainCategory;
  final List<Story>? storiesForProduct;
  final List<String>? sizesForEachColor;
  final List<String>? colorsForEachProduct;
  final List<int>? sizesQuantitiesForEachColor;
  final List<int>? colorsQuantitiesForEachProduct;
  final List<String> isVariantRequestNotification;
  final Map<String, int>? countOfProductExpectedByFiltering;
  final get_filters.Filter? prefAppliedFilterForExtendFilter;
  final Map<String, PaginationModel<product.Products>>
      getProductListingPaginationWithoutFiltersModel;
  final cart.GetCartShippingItemsModel? getCartShippingItemsModel;
  final oldCart.GetOldCartModel? getOldCartModel;
  final Map<String, GetCommentForProductModel> getCommentForProductModel;

  final MainCategoriesResponseModel? mainCategoriesResponseModel;
  final GetProductDetailWithoutRelatedProductsModel?
      getProductDetailWithoutRelatedProductsModel;
  final ChangeSizesForEveryProduct? changeSizesForEveryProduct;
  final bool cashedOrginalBoutique;
  final int currentIndexForMainCategoryEvent;
  final StartingSetting? startingSetting;
  final Map<String, String>? currentColorSizeForCart;
  final bool? fromSearchForSearchWithGemini;
  final Map<String, List<int>>? currentQuantityForCart;
  final Map<String, GetProductDetailWithoutRelatedProductsModel>
      cachedProductWithoutRelatedProductsModel;

  @override
  List<Object?> get props => [
        boutiquesThatDidPrefetch,
        boutiquesForEveryMainCategoryThatDidPrefetch,
        getStartingSettingsStatus,
        currentSelectedColorForEveryProduct,
        getListOfProductsFoundedInCartStatus,
        getCommentForProductStatus,
        productITemForCart,
        getMainCategoriesStatus,
        oldcartCollection,
        convertItemFromOldcartToCartStatus,
        getOldCartModel,
        getOldCartItemsStatus,
        editAddressToOrderStatus,
        addAddressToOrderStatus,
        notificationTypeForProductModel,
        removeAddressToOrderStatus,
        getCustomerAddressStatus,
        listitemForAddToCart,
        getAllowedCountriesModel,
        getProductFiltersStatus,
        popularSearchTerm,
        getProductListingWithFiltersPaginationModels,
        getCurrencyForCountryModel,
        sendRequestToGeminiStatus,
        theReplyFromGemini,
        cartIdsHurryUPTimerStarted,
        addCommentStatus,
        changeSizesForEveryProduct,
        hideItemInOldCartStatus,
        // moveUrlFromElasticToMarketServer,
        cashedOrginalBoutique,
        listOfAddressInfoClassToSave,
        getAddressByCoordinatesStatus,
        updateEmailappNotificationStatus,
        updateWhatsappNotificationStatus,

        getCustomerWalletStatus,
        placeOrderStatus,
        placeOrderModel,
        applyCouponStatus,
        applyCouponModel,
        getOrdersByOrderGroupIDStatus,
        getOrdersByOrderGroupIDModel,
        getOrdersByCartGroupIDStatus,
        getOrdersByCartGroupIDModel,

        checkAvailabilityProductCartStatus,
        checkAvailabilityProductCartModel,

        getAddressByTextStatus,
        listOfErrorSendedToMobileErrorLog,
        productContentForStatusOfOpeningProductDetailsDirectly,
        getProductListingWithFiltersPaginationWithPrefetchModels,
        getProductFiltersModel,
        getProductFiltersWithPrefetchModel,
        getAndAddCountViewOfProductStatus,
        appliedFiltersByUser,
        choosedFiltersByUser,
        selectedCollection,
        currentPage,
        sizesQuantitiesForEachColor,
        isExpandedForListingPage,
        isGettingProductListingWithPagination,
        isGettingProductListingWithPaginationForAppearProduct,
        searchHistory,
        addImagesToProductIdForCart,
        productStatus,
        cartCollection,
        fromSearchForSearchWithGemini,
        resultSearch,
        reRequestTheseBoutiques,
        reRequestTheseProductListingInBoutiques,
        reRequestProductWithFilters,
        getProductDetailWithoutSimilarRelatedProductsStatus,
        getCartItemsStatus,
        getProductListingStatus,
        getStoriesForProductStatus,
        getHomeBoutiquesPaginationObjectByMainCategory,
        storiesForProduct,
        sizesForEachColor,
        getFullProductDetailsStatus,
        countOfProductExpectedByFiltering,
        prefAppliedFilterForExtendFilter,
        getProductListingPaginationWithoutFiltersModel,
        getCartShippingItemsModel,
        getCommentForProductModel,
        mainCategoriesResponseModel,
        getProductDetailWithoutRelatedProductsModel,
        updateItemInCartStatus,
        addItemInCartStatus,
        appliedFiltersByUser,
        addImagesToProductIdForCart,
        deleteItemInCartStatus,
        updateItemInCartStatus,
        currentSelectedColorForEveryProduct,
        isVariantRequestNotification,
        selectedCollection,
        cashedOrginalBoutique,
        currentIndexForMainCategoryEvent,
        startingSetting,
        currentColorSizeForCart,
        getAddressByCoordinatesModel,
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
      final GetMainCategoriesStatus? getMainCategoriesStatus,
      final GetAddressByCoordinatesModel? getAddressByCoordinatesModel,
      final CustomerWalletModel? customerWalletModel,
      final OrdersGroupModel? placeOrderModel,
      final PlaceOrderStatus? placeOrderStatus,
      final ApplyCouponModel? applyCouponModel,
      final ApplyCouponStatus? applyCouponStatus,
      final OrdersGroupModel? getOrdersByOrderGroupIDModel,
      final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus,
      final OrdersGroupModel? getOrdersByCartGroupIDModel,
      final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus,
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
      final GetCustomerAddressesStatus? getCustomerAddressesStatus,
      final List<ResultSearch>? resultSearch,
      final List<String>? listOfErrorSendedToMobileErrorLog,
      final NotificationTypeForProductModel? notificationTypeForProductModel,
      final Map<String, String>? searchWithFilterOffset,
      final GetListOfProductsFoundedInCartStatus?
          getListOfProductsFoundedInCartStatus,
      final List<CustomerAddressesInfo>? listOfAdressInfoClassToSave,
      final RemoveAddressToOrderStatus? removeAddressToOrderStatus,
      final EditAddressToOrderStatus? editAddressToOrderStatus,
      final AddAddressToOrderStatus? addAddressToOrderStatus,
      final Map<String, String>? searchWithOutFilterOffset,
      final Map<String, get_filters.GetProductFiltersModel?>?
          getProductFiltersWithPrefetchModel,
      final GetAddressByTextStatus? getAddressByTextStatus,
      final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus,
      final GetCustomerWalletStatus? getCustomerWalletStatus,
      final Map<String, GetAndAddCountViewOfProductStatus>?
          getAndAddCountViewOfProductStatus,
      bool? cashedOrginalBoutique,
      final List<PopularSearchTerm>? popularSearchTerm,
      final List<String>? cartIdsSubsecribedToTopicHurryUP,
      bool? isExpandedForLidtingPage,
      final Map<String, int>? cartIdsHurryUPTimerStarted,
      final bool? fromSearchForSearchWithGemini,
      final ChangeSizesForEveryProduct? changeSizesForEveryProduct,
      // String? idForRequest,

      get_filters.Filter? prefAppliedFilterForExtendFilter,
      final Map<String, bool>? boutiquesThatDidPrefetch,
      final Map<String, bool>? boutiquesForEveryMainCategoryThatDidPrefetch,
      Map<String, Map<int, List<String>>>? addImagesToProductIdForCart,
      final List<ImageForAddToCart>? listitemForAddToCart,
      final GetAllowedCountriesModel? getAllowedCountriesModel,
      final Map<String, PaginationModel<product.Products>?>?
          getProductListingWithFiltersPaginationWithPrefetchModels,
      final GetCommentForProductStatus? getCommentForProductStatus,
      final AddOrRemoveLikeOfProductStatus? addOrRemoveLikeOfProductStatus,
      final bool? isGettingProductListingWithPagination,
      final GetCartItemsStatus? getCartItemsStatus,
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
      final String? theReplyFromGemini,
      final bool? isGettingProductListingWithPaginationForAppearProduct,
      int? currentIndexForMainCategoryEvent,
      List<String>? searchHistory,
      Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
          productStatus,
      Map<String, List<int>>? currentQuantityForCart,
      List<cart.Cart>? cartCollection,
      List<oldCart.OldCart>? oldCartCollection,
      Map<String, String>? CurrentColorSizeForCart,
      final Map<String, bool>? reRequestTheseBoutiques,
      final SendRequestToGeminiStatus? sendRequestToGeminiStatus,
      final Map<String, product.Products>? productITemForCart,
      final cart.GetCartShippingItemsModel? getCartShippingItemsModel,
      final oldCart.GetOldCartModel? getOldCartModel,
      final Map<String, bool>? reRequestTheseProductListingInBoutiques,
      final Map<String, bool>? reRequestProductWithFilters,
      final GetProductListingStatus? getProductListingStatus,
      final StartingSetting? startingSetting,
      final GetCurrencyForCountryModel? getCurrencyForCountryModel,
      final MainCategoriesResponseModel? mainCategoriesResponseModel,
      final Map<String, PaginationModel<boutiques_model.Boutique>>?
          getHomeBoutiquesPaginationObjectByMainCategory,
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
      Map<String, int>? countOfProductExpectedByFiltering,
      List<Story>? storiesForProduct,
      final Map<String, GetProductFiltersStatus>? getProductFiltersStatus,
      final Map<String, PaginationModel<product.Products>?>?
          getProductListingWithFiltersPaginationModels,
      final Map<String, get_filters.GetProductFiltersModel?>?
          getProductFiltersModel,
      final Map<String, get_filters.GetProductFiltersModel?>?
          appliedFiltersByUser,
      final Map<String, get_filters.GetProductFiltersModel?>?
          choosedFiltersByUser,
      final Map<String, PaginationModel<product.Products>>?
          getProductListingPaginationWithoutFiltersModel,
      final Map<String, GetCommentForProductModel>?
          getCommentForProductModel}) {
    return HomeState(
      boutiquesForEveryMainCategoryThatDidPrefetch:
          boutiquesForEveryMainCategoryThatDidPrefetch ??
              this.boutiquesForEveryMainCategoryThatDidPrefetch,

      getAndAddCountViewOfProductStatus: getAndAddCountViewOfProductStatus ??
          this.getAndAddCountViewOfProductStatus,

      getAddressByCoordinatesModel:
          getAddressByCoordinatesModel ?? this.getAddressByCoordinatesModel,
      customerWalletModel: customerWalletModel ?? this.customerWalletModel,
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
      notificationTypeForProductModel: notificationTypeForProductModel ??
          this.notificationTypeForProductModel,
      listOfAddressInfoClassToSave:
          listOfAdressInfoClassToSave ?? this.listOfAddressInfoClassToSave,
      removeAddressToOrderStatus:
          removeAddressToOrderStatus ?? this.removeAddressToOrderStatus,

      firebaseSettingForNotificationModel:
          firebaseSettingForNotificationModel ??
              this.firebaseSettingForNotificationModel,
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
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      applyCouponModel: applyCouponModel ?? this.applyCouponModel,
      applyCouponStatus: applyCouponStatus ?? this.applyCouponStatus,
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
      isGettingProductListingWithPagination:
          isGettingProductListingWithPagination ??
              this.isGettingProductListingWithPagination,
      cartIdsHurryUPTimerStarted:
          cartIdsHurryUPTimerStarted ?? this.cartIdsHurryUPTimerStarted,
      boutiquesThatDidPrefetch:
          boutiquesThatDidPrefetch ?? this.boutiquesThatDidPrefetch,
      // idForRequest: idForRequest ?? this.idForRequest,
      cashedOrginalBoutique:
          cashedOrginalBoutique ?? this.cashedOrginalBoutique,
      isExpandedForListingPage:
          isExpandedForLidtingPage ?? this.isExpandedForListingPage,
      theReplyFromGemini: theReplyFromGemini ?? this.theReplyFromGemini,
      getListOfProductsFoundedInCartStatus:
          getListOfProductsFoundedInCartStatus ??
              this.getListOfProductsFoundedInCartStatus,
      productContentForStatusOfOpeningProductDetailsDirectly:
          productContentForStatusOfOpeningProductDetailsDirectly ??
              this.productContentForStatusOfOpeningProductDetailsDirectly,
      countOfProductExpectedByFiltering: countOfProductExpectedByFiltering ??
          this.countOfProductExpectedByFiltering,
      listitemForAddToCart: listitemForAddToCart ?? this.listitemForAddToCart,
      addImagesToProductIdForCart:
          addImagesToProductIdForCart ?? this.addImagesToProductIdForCart,
      cartCollection: cartCollection ?? this.cartCollection,
      oldcartCollection: oldCartCollection ?? this.oldcartCollection,
      getOldCartItemsStatus:
          getOldCartItemsStatus ?? this.getOldCartItemsStatus,

      getOldCartModel: getOldCartModel ?? this.getOldCartModel,
      getProductFiltersStatus:
          getProductFiltersStatus ?? this.getProductFiltersStatus,
      addItemInCartStatus: addItemInCartStatus ?? this.addItemInCartStatus,
      sendRequestToGeminiStatus:
          sendRequestToGeminiStatus ?? this.sendRequestToGeminiStatus,
      getProductListingWithFiltersPaginationModels:
          getProductListingWithFiltersPaginationModels ??
              this.getProductListingWithFiltersPaginationModels,

      prefAppliedFilterForExtendFilter: prefAppliedFilterForExtendFilter ??
          this.prefAppliedFilterForExtendFilter,

      getCurrencyForCountryModel:
          getCurrencyForCountryModel ?? this.getCurrencyForCountryModel,
      getProductFiltersWithPrefetchModel: getProductFiltersWithPrefetchModel ??
          this.getProductFiltersWithPrefetchModel,
      getProductListingWithFiltersPaginationWithPrefetchModels:
          getProductListingWithFiltersPaginationWithPrefetchModels ??
              this.getProductListingWithFiltersPaginationWithPrefetchModels,
      isGettingProductListingWithPaginationForAppearProduct:
          isGettingProductListingWithPaginationForAppearProduct ??
              this.isGettingProductListingWithPaginationForAppearProduct,
      currentQuantityForCart:
          currentQuantityForCart ?? this.currentQuantityForCart,
      currentIndexForMainCategoryEvent: currentIndexForMainCategoryEvent ??
          this.currentIndexForMainCategoryEvent,
      productITemForCart: productITemForCart ?? this.productITemForCart,
      currentColorSizeForCart:
          CurrentColorSizeForCart ?? this.currentColorSizeForCart,
      choosedFiltersByUser: choosedFiltersByUser ?? this.choosedFiltersByUser,
      appliedFiltersByUser: appliedFiltersByUser ?? this.appliedFiltersByUser,
      getProductFiltersModel:
          getProductFiltersModel ?? this.getProductFiltersModel,
      searchHistory: searchHistory ?? this.searchHistory,
      getCartShippingItemsModel:
          getCartShippingItemsModel ?? this.getCartShippingItemsModel,
      fromSearchForSearchWithGemini:
          fromSearchForSearchWithGemini ?? this.fromSearchForSearchWithGemini,
      getCommentForProductStatus:
          getCommentForProductStatus ?? this.getCommentForProductStatus,
      getProductListingStatus:
          getProductListingStatus ?? this.getProductListingStatus,
      currentSelectedColorForEveryProduct:
          currentSelectedColorForEveryProduct ??
              this.currentSelectedColorForEveryProduct,
      getCartItemsStatus: getCartItemsStatus ?? this.getCartItemsStatus,
      reRequestTheseBoutiques:
          reRequestTheseBoutiques ?? this.reRequestTheseBoutiques,
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
      getMainCategoriesStatus:
          getMainCategoriesStatus ?? this.getMainCategoriesStatus,
      getHomeBoutiquesPaginationObjectByMainCategory:
          getHomeBoutiquesPaginationObjectByMainCategory ??
              this.getHomeBoutiquesPaginationObjectByMainCategory,
      startingSetting: startingSetting ?? this.startingSetting,
      mainCategoriesResponseModel:
          mainCategoriesResponseModel ?? this.mainCategoriesResponseModel,
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
      searchWithFilterOffset:
          searchWithFilterOffset ?? this.searchWithFilterOffset,
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
