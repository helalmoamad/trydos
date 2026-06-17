import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/currencies_response_model.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;
import 'package:geodesy/geodesy.dart' as geod;
import 'package:trydos/features/home/data/models/get_order_rating_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart'
    hide BuyersCommentModel;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/data/models/notificaation_poroduct_types.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../../core/data/model/pagination_model.dart';

import '../../../data/models/check_availability_product_cart_model.dart';
import '../../../data/models/get_fqa_comments_model.dart';
import '../../../data/models/get_buyers_comments_model.dart';
import '../../../data/models/get_cart_item_model.dart';
import '../../../data/models/get_old_cart_model.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../../data/models/get_user_notifications_model.dart';
import '../../../data/models/starting_settings_response_model.dart';
import '../../../data/models/get_auth_product_details_model.dart';
import '../../../data/models/get_order_rating_model.dart' as order_rating;
part 'home_state.g.dart';

enum GetStartingSettingsStatus { init, loading, success, failure }

enum GetCountryBoundaryByIsoStatus { init, loading, success, failure }

enum GetProductDetailWithoutSimilarRelatedProductsStatus {
  init,
  loading,
  success,
  failure,
}

enum GetRelatedProductsStatus {
  init,
  loading,
  success,
  failure,
}

enum GetFullProductDetailsStatus { init, loading, success, failure }

enum SelectedVideoStatus { init, loading, success, failure }

//enum GetCommentForProductStatus { init, loading, success, failure }

enum GetCartItemsStatus { init, loading, success, available, failure }

enum CheckWithGetCartStatus {
  init,
  loading,
  successForCart,
  successForPlaceOrder,
  available,
  failure,
}

enum GetOLdCartItemsStatus { init, loading, success, failure }

enum GetAllowedCountriesStatus { init, loading, success, failure }

enum ConvertItemFromcartToOldCartStatus { init, loading, success, failure }

enum GetStoriesForProductStatus { init, loading, success, failure }

enum GetListOfProductsFoundedInCartStatus { init, loading, success, failure }

enum HideItemInOldCartStatus { init, loading, success, failure }

enum AddItemInCartStatus { init, loading, success, failure }

enum UpdateItemInCartStatus { init, loading, success, failure }

enum DeleteItemInCartStatus { init, loading, success, failure }

//enum AddCommentStatus { init, loading, success, failure }

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

enum AddProductIdToSaveRedeemTimerStatus { init, on, off }

enum EnableAddToCardAfterChangeVariantZero { init, loading, success, failure }

enum GetOrderRatingStatus { init, loading, success, failure }

enum UpdateOrderCommentRatingStatus { init, loading, success, failure }

enum UpdateLikeCommentRatingStatus { init, loading, success, failure }

enum DeleteOrderCommentRatingStatus { init, loading, success, failure }

enum TranslateCommentStatus { init, loading, success, failure }

enum CreateCommentRatingStatus { init, loading, success, failure }

enum CurrentSelectedColorForEveryProductStatus {
  init,
  loading,
  success,
  failure,
}

enum AuthProductDetailsStatus { init, loading, success, failure }

enum GetCurrenciesForWalletStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
@immutable
class HomeState extends Equatable {
  const HomeState({
    // this.storiesForProduct,
    this.getAndAddCountViewOfProductStatus = const {},
    this.addItemInCartStatus,
    this.convertItemFromcartToOldCartStatus =
        ConvertItemFromcartToOldCartStatus.init,
    this.hideItemInOldCartStatus,
    this.updateEmailappNotificationStatus,
    this.tapCommentIndex = -1,
    this.createCommentRatingStatus = CreateCommentRatingStatus.init,
    this.updateWhatsappNotificationStatus,
    this.translateCommentStatus = TranslateCommentStatus.init,
    //this.getCommentsFromAnalyticsPaginationModel,
    this.changeSizesForEveryProduct,
    this.getFqaCommentsPaginationModel,
    this.getBuyersCommentsPaginationModel,
    this.getOrderRatingComments = const [],
    this.uploadUserPhotoCloudinaryStatus,
    this.searchWithOutFilterOffset,
    this.updateProfileStatus,
    this.addProductIdToSaveRedeemTimerStatus =
        AddProductIdToSaveRedeemTimerStatus.init,
    this.getAllowedCountriesStatus,
    this.getProductDetailWithoutSimilarRelatedProductsStatus =
        GetProductDetailWithoutSimilarRelatedProductsStatus.init,
    this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
    this.relatedProducts,
    // this.getCommentForProductStatus = GetCommentForProductStatus.init,
    this.currentSelectedColorForEveryProductStatus,
    this.isChangedvariationWhenQtyZero = false,
    this.getOrderRatingStatus = GetOrderRatingStatus.init,
    this.getFullProductDetailsStatus = GetFullProductDetailsStatus.init,
    this.getRelatedProductsStatus = GetRelatedProductsStatus.init,
    //this.addCommentStatus = AddCommentStatus.init,
    this.startingSetting,
    this.sizesForEachColor = const [],
    this.colorsForEachProduct = const [],
    this.colorsQuantitiesForEachProduct = const [],
    this.sizesQuantitiesForEachColor = const [],
    this.isVariantRequestNotification = const [],
    this.deleteItemInCartStatus,
    this.oldcartCollection,
    this.enableAddToCardAfterChangeVariantZero,
    this.getCurrenciesForWalletStatus = GetCurrenciesForWalletStatus.init,
    this.walletCurrencies,
    this.getOldCartItemsStatus = GetOLdCartItemsStatus.init,
    this.getOldCartModel,
    this.countryCoordinatesBorders = const [],
    this.getUserNotificationModel,
    this.checkAvailabilityProductCartModel,
    this.currentPage = 0,
    this.productStatus,
    this.updateItemInCartStatus,
    //  this.productITemForCart = const {},
    this.getCartShippingItemsModel,
    //this.getCommentForProductModel = const {},
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
    //this.getListOfProductsFoundedInCartStatus =
    //    GetListOfProductsFoundedInCartStatus.init,
    this.getCurrencyForCountryModel,
    this.storiesCollections = const [],
    this.selectedVideoStatus = SelectedVideoStatus.init,
    this.storyLink,
    this.finishGetAllStory = false,
    this.storyOffset = 0,
    this.getStoryWithPagintionStatusLoading = false,
    this.currentStoryInEachCollection = const {},
    this.productIdToSaveRedeemTimer = const [],
    this.popularSearchTerm,
    this.updateOrderCommentRatingStatus = UpdateOrderCommentRatingStatus.init,
    this.updateLikeCommentRatingStatus = UpdateLikeCommentRatingStatus.init,
    this.deleteOrderCommentRatingStatus = DeleteOrderCommentRatingStatus.init,
    this.getCartOverviewStatus = GetCartOverviewStatus.init,
    this.checkAvailabilityProductCartStatus =
        CheckAvailabilityProductCartStatus.init,
    this.statusCodeOfCommentProcess = "",
    this.currentSlugToRefreshFromNotification,
    this.getCartItemsStatus = GetCartItemsStatus.init,
    this.checkWithGetCartStatus = CheckWithGetCartStatus.init,
    this.addOrRemoveLikeOfProductStatus = AddOrRemoveLikeOfProductStatus.init,
    this.getProductListingPaginationWithoutFiltersModel = const {},
    this.currentSelectedColorForEveryProduct = const {},
    this.notificationTypeForProductModel,
    this.getNotificationTypeProductStatus,
    this.likeForReplayComment,
    this.currentHeightWhenAddToBag = 0,
    // this.geColorsAndSizesForSearchModel,
    this.currentIndexForUpdateCart,
    this.getCountryBoundaryByIsoStatus,
    this.userInfo,
    this.finishLoadingAfterChangedVariationWhenQtyZero,
    this.listOfErrorSendedToMobileErrorLog = const [],
    this.cachedProductWithoutRelatedProductsModel = const {},
    this.getFirebaseSettingForNotificationStatus,
    this.firebaseSettingForNotificationModel,
    this.authProductDetailsStatus = AuthProductDetailsStatus.init,
    this.authProductDetailsModel,
  });

  final GetFirebaseSettingForNotificationStatus?
  getFirebaseSettingForNotificationStatus;
  final GetCountryBoundaryByIsoStatus? getCountryBoundaryByIsoStatus;
  final FirebaseSettingForNotificationModel?
  firebaseSettingForNotificationModel;
  final DeleteOrderCommentRatingStatus deleteOrderCommentRatingStatus;
  final UpdateOrderCommentRatingStatus updateOrderCommentRatingStatus;
  final UpdateLikeCommentRatingStatus updateLikeCommentRatingStatus;
  final UpdateProfileStatus? updateProfileStatus;
  final GetOrderRatingStatus getOrderRatingStatus;
  final GetAllowedCountriesStatus? getAllowedCountriesStatus;
  final GetCurrenciesForWalletStatus getCurrenciesForWalletStatus;
  final CurrenciesForWalletResponseModel? walletCurrencies;
  //final PaginationModel<comment.Comment>?
  //   getCommentsFromAnalyticsPaginationModel;
  final Map<String, PaginationModel<FqaComment>>? getFqaCommentsPaginationModel;
  final Map<String, PaginationModel<BuyersComment>>?
  getBuyersCommentsPaginationModel;
  final GetStartingSettingsStatus getStartingSettingsStatus;
  final List<Products>? relatedProducts;
  final Map<String, int> currentSelectedColorForEveryProduct;
  // final GetCommentForProductStatus getCommentForProductStatus;
  final String? currentSlugToRefreshFromNotification;
  // final Map<String, product.Products> productITemForCart;
  final User? userInfo;
  final CreateCommentRatingStatus createCommentRatingStatus;
  final List<CollectionStoryModel> storiesCollections;
  final int currentPage;
  final int tapCommentIndex;
  final int? currentHeightWhenAddToBag;
  final SelectedVideoStatus selectedVideoStatus;
  final int storyOffset;
  final bool getStoryWithPagintionStatusLoading;
  final bool finishGetAllStory;
  final List<order_rating.Comment> getOrderRatingComments;
  final String? storyLink;
  final TranslateCommentStatus? translateCommentStatus;
  final String? statusCodeOfCommentProcess;
  final int? selectedCollection;
  final Map<int, int?> currentStoryInEachCollection;

  final AddProductIdToSaveRedeemTimerStatus?
  addProductIdToSaveRedeemTimerStatus;
  final CurrentSelectedColorForEveryProductStatus?
  currentSelectedColorForEveryProductStatus;
  final UploadUserPhotoCloudinaryStatus? uploadUserPhotoCloudinaryStatus;
  final List<String>? productIdToSaveRedeemTimer;
  final EnableAddToCardAfterChangeVariantZero?
  enableAddToCardAfterChangeVariantZero;

  final bool isChangedvariationWhenQtyZero;

  final ConvertItemFromcartToOldCartStatus convertItemFromcartToOldCartStatus;

  final GetNotificationTypeProductStatus? getNotificationTypeProductStatus;
  final HideItemInOldCartStatus? hideItemInOldCartStatus;

  final NotificationTypeForProductModel? notificationTypeForProductModel;
  final Map<String, GetAndAddCountViewOfProductStatus>
  getAndAddCountViewOfProductStatus;
  final List<PopularSearchTerm>? popularSearchTerm;
  // final GeColorsAndSizesForSearchModel? geColorsAndSizesForSearchModel;
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
  // final AddCommentStatus addCommentStatus;

  final AddOrRemoveLikeOfProductStatus addOrRemoveLikeOfProductStatus;

  final List<geod.LatLng> countryCoordinatesBorders;
  // String? idForRequest;
  final List<String>? searchHistory;
  final List<String> listOfErrorSendedToMobileErrorLog;

  final Map<String, String>? searchWithOutFilterOffset;
  final Map<String, Map<int, List<List<String>>>> addImagesToProductIdForCart;
  final Map<String, Map<String, String>>? addVariationToCartId;
  final Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
  productStatus;
  final List<cart.Cart>? cartCollection;

  final Map<String, int> cartIdsHurryUPTimerStarted;
  //  final GetListOfProductsFoundedInCartStatus
  //  getListOfProductsFoundedInCartStatus;
  final UpdateEmailappNotificationStatus? updateEmailappNotificationStatus;
  final UpdateWhatsappNotificationStatus? updateWhatsappNotificationStatus;
  final List<oldCart.OldCart>? oldcartCollection;

  final Map<String, bool> reRequestTheseProductListingInBoutiques;
  final Map<String, bool> reRequestProductWithFilters;
  final GetProductDetailWithoutSimilarRelatedProductsStatus
  getProductDetailWithoutSimilarRelatedProductsStatus;

  final GetFullProductDetailsStatus getFullProductDetailsStatus;
  final GetRelatedProductsStatus getRelatedProductsStatus;

  final GetCartItemsStatus getCartItemsStatus;
  final CheckWithGetCartStatus checkWithGetCartStatus;
  final GetOLdCartItemsStatus getOldCartItemsStatus;
  final Products? productContentForStatusOfOpeningProductDetailsDirectly;

  final GetProductListingStatus getProductListingStatus;
  final GetStoriesForProductStatus getStoriesForProductStatus;

  //final List<Story>? storiesForProduct;
  final List<String>? sizesForEachColor;
  final List<String>? colorsForEachProduct;
  final List<int>? sizesQuantitiesForEachColor;
  final List<int>? colorsQuantitiesForEachProduct;
  final List<String> isVariantRequestNotification;
  final bool? finishLoadingAfterChangedVariationWhenQtyZero;
  final Map<String, PaginationModel<product.Products>>
  getProductListingPaginationWithoutFiltersModel;
  final cart.GetCartShippingItemsModel? getCartShippingItemsModel;
  final oldCart.GetOldCartModel? getOldCartModel;
  // final Map<String, GetCommentForProductModel> getCommentForProductModel;

  final ChangeSizesForEveryProduct? changeSizesForEveryProduct;

  final int? currentIndexForUpdateCart;
  final StartingSetting? startingSetting;
  final Map<String, String>? currentColorSizeForCart;

  final Map<String, List<int>>? currentQuantityForCart;
  final Map<String, GetProductDetailWithoutRelatedProductsModel>
  cachedProductWithoutRelatedProductsModel;
  final bool? likeForReplayComment;
  final AuthProductDetailsStatus authProductDetailsStatus;
  final GetAuthProductDetailsModel? authProductDetailsModel;

  @override
  List<Object?> get props => [
    getStartingSettingsStatus,
    relatedProducts,
    storyLink,
    currentSelectedColorForEveryProduct,
    // getListOfProductsFoundedInCartStatus,
    //  getCommentForProductStatus,
    // productITemForCart,
    oldcartCollection,
    likeForReplayComment,
    convertItemFromcartToOldCartStatus,
    getOldCartModel,
    getCurrenciesForWalletStatus,
    walletCurrencies,
    getOldCartItemsStatus,
    notificationTypeForProductModel,
    updateProfileStatus,
    currentSelectedColorForEveryProductStatus,
    listitemForAddToCart,
    getOrderRatingStatus,
    getAllowedCountriesModel,
    userInfo,
    popularSearchTerm,
    getCurrencyForCountryModel,
    enableAddToCardAfterChangeVariantZero,
    cartIdsHurryUPTimerStarted,
    createCommentRatingStatus,
    currentSlugToRefreshFromNotification,
    currentStoryInEachCollection,
    finishLoadingAfterChangedVariationWhenQtyZero,
    // getCommentsFromAnalyticsPaginationModel,
    // addCommentStatus,
    getFqaCommentsPaginationModel,
    getBuyersCommentsPaginationModel,
    getOrderRatingComments,
    changeSizesForEveryProduct,
    hideItemInOldCartStatus,

    // moveUrlFromElasticToMarketServer,
    updateEmailappNotificationStatus,
    updateWhatsappNotificationStatus,
    updateLikeCommentRatingStatus,

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

    // storiesForProduct,
    sizesForEachColor,
    getFullProductDetailsStatus,
    getRelatedProductsStatus,

    getProductListingPaginationWithoutFiltersModel,
    getCartShippingItemsModel,

    //    getCommentForProductModel,
    addItemInCartStatus,
    addVariationToCartId,
    deleteItemInCartStatus,
    updateItemInCartStatus,

    isVariantRequestNotification,
    selectedCollection,

    startingSetting,
    currentIndexForUpdateCart,
    currentColorSizeForCart,
    addProductIdToSaveRedeemTimerStatus,
    isChangedvariationWhenQtyZero,
    getFirebaseSettingForNotificationStatus,
    getCountryBoundaryByIsoStatus,
    storiesCollections,
    currentQuantityForCart,
    countryCoordinatesBorders,
    firebaseSettingForNotificationModel,
    cachedProductWithoutRelatedProductsModel,
    addOrRemoveLikeOfProductStatus,
    productIdToSaveRedeemTimer,
    tapCommentIndex,
    getAllowedCountriesStatus,
    //   geColorsAndSizesForSearchModel
    authProductDetailsStatus,
    deleteOrderCommentRatingStatus,
    updateOrderCommentRatingStatus,
    authProductDetailsModel,
    selectedVideoStatus,
    statusCodeOfCommentProcess,
    finishGetAllStory,
    translateCommentStatus,
    storyOffset,
    currentHeightWhenAddToBag,
    getStoryWithPagintionStatusLoading,
  ];

  HomeState copyWith({
    final List<Products>? relatedProducts,
    final GetStartingSettingsStatus? getStartingSettingsStatus,
    final GetFirebaseSettingForNotificationStatus?
    getFirebaseSettingForNotificationStatus,
    final GetAllowedCountriesStatus? getAllowedCountriesStatus,
    final TranslateCommentStatus? translateCommentStatus,
    final DeleteOrderCommentRatingStatus? deleteOrderCommentRatingStatus,
    final UpdateOrderCommentRatingStatus? updateOrderCommentRatingStatus,
    final UpdateLikeCommentRatingStatus? updateLikeCommentRatingStatus,
    final GetCountryBoundaryByIsoStatus? getCoutryBoundaryByIsoStatus,
    final FirebaseSettingForNotificationModel?
    firebaseSettingForNotificationModel,
    final GetCurrenciesForWalletStatus? getCurrenciesForWalletStatus,
    final CurrenciesForWalletResponseModel? walletCurrencies,
    final List<String>? productIdToSaveRedeemTimer,
    final int? currentHeightWhenAddToBag,
    final bool? isChangedVariationWhenQtyZero,
    final bool? finishLoadingAfterChangedVariationWhenQtyZero,
    final List<CollectionStoryModel>? storiesCollections,
    final String? statusCodeOfCommentProcess,
    int? currentPage,
    SelectedVideoStatus? selectedVideoStatus,
    final CreateCommentRatingStatus? createCommentRatingStatus,
    final int? tapCommentIndex,
    final bool? likeForReplayComment,
    final GetOrderRatingStatus? getOrderRatingStatus,
    int? storyOffset,
    bool? getStoryWithPagintionStatusLoading,
    final Map<String, PaginationModel<FqaComment>>?
    getFqaCommentsPaginationModel,
    final Map<String, PaginationModel<BuyersComment>>?
    getBuyersCommentsPaginationModel,
    bool? finishGetAllStory,
    String? storyLink,
    int? selectedCollection,
    Map<int, int?>? currentStoryInEachCollection,
    final List<geod.LatLng>? countryCoordinatesBorders,
    final AddProductIdToSaveRedeemTimerStatus?
    addProductIdToSaveRedeemTimerStatus,
    final List<order_rating.Comment>? getOrderRatingComments,
    //final PaginationModel<comment.Comment>?
    //    getCommentsFromAnalyticsPaginationModel,
    final EnableAddToCardAfterChangeVariantZero?
    enableAddToCardAfterChangeVariantZero,
    final UpdateProfileStatus? updateProfileStatus,
    final String? currentSlugToRefreshFromNotification,
    final User? userInfo,
    final UploadUserPhotoCloudinaryStatus? uploadUserPhotoCloudinaryStatus,
    final PaginationModel<NotificationItemModel>? getUserNotificationModel,
    final GetCartOverviewStatus? getCartOverviewStatus,
    // final GeColorsAndSizesForSearchModel? geColorsAndSizesForSearchModel,
    final CurrentSelectedColorForEveryProductStatus?
    currentSelectedColorForEveryProductStatus,
    final Map<String, Map<String, String>>? addVariationToCartId,
    final CheckAvailabilityProductCartModel? checkAvailabilityProductCartModel,
    final CheckAvailabilityProductCartStatus?
    checkAvailabilityProductCartStatus,
    final AddItemInCartStatus? addItemInCartStatus,
    final HideItemInOldCartStatus? hideItemInOldCartStatus,
    final ConvertItemFromcartToOldCartStatus?
    convertItemFromcartToOldCartStatus,
    final GetNotificationTypeProductStatus? getNotificationTypeProductStatus,
    // final bool? moveUrlFromElasticToMarketServer,
    final UpdateItemInCartStatus? updateItemInCartStatus,
    final List<String>? listOfErrorSendedToMobileErrorLog,
    final NotificationTypeForProductModel? notificationTypeForProductModel,
    //final GetListOfProductsFoundedInCartStatus?
    //    getListOfProductsFoundedInCartStatus,
    final List<CustomerAddressesInfo>? listOfAdressInfoClassToSave,
    final Map<String, String>? searchWithOutFilterOffset,
    final Map<String, GetAndAddCountViewOfProductStatus>?
    getAndAddCountViewOfProductStatus,
    final List<PopularSearchTerm>? popularSearchTerm,
    final List<String>? cartIdsSubsecribedToTopicHurryUP,
    final Map<String, int>? cartIdsHurryUPTimerStarted,
    final ChangeSizesForEveryProduct? changeSizesForEveryProduct,

    // String? idForRequest,
    Map<String, Map<int, List<List<String>>>>? addImagesToProductIdForCart,
    final List<ImageForAddToCart>? listitemForAddToCart,
    final GetAllowedCountriesModel? getAllowedCountriesModel,
    //final GetCommentForProductStatus? getCommentForProductStatus,
    final AddOrRemoveLikeOfProductStatus? addOrRemoveLikeOfProductStatus,
    final GetCartItemsStatus? getCartItemsStatus,
    final CheckWithGetCartStatus? checkWithGetCartStatus,
    final UpdateEmailappNotificationStatus? updateEmailappNotificationStatus,
    final UpdateWhatsappNotificationStatus? updateWhatsappNotificationStatus,
    final GetOLdCartItemsStatus? getOldCartItemsStatus,
    // final AddCommentStatus? addCommentStatus,
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
    //final Map<String, product.Products>? productITemForCart,
    final cart.GetCartShippingItemsModel? getCartShippingItemsModel,
    final oldCart.GetOldCartModel? getOldCartModel,
    final Map<String, bool>? reRequestTheseProductListingInBoutiques,
    final Map<String, bool>? reRequestProductWithFilters,
    final StartingSetting? startingSetting,
    final GetCurrencyForCountryModel? getCurrencyForCountryModel,
    final Map<String, GetProductDetailWithoutRelatedProductsModel>?
    cachedProductWithoutRelatedProductsModel,
    GetStoriesForProductStatus? getStoriesForProductStatus,
    GetFullProductDetailsStatus? getFullProductDetailsStatus,
    final GetProductDetailWithoutSimilarRelatedProductsStatus?
    getProductDetailWithoutSimilarRelatedProductsStatus,
    final DeleteItemInCartStatus? deleteItemInCartStatus,
    final Map<String, int>? currentSelectedColorForEveryProduct,
    final GetRelatedProductsStatus? getRelatedProductsStatus,

    //List<Story>? storiesForProduct,
    final Map<String, PaginationModel<product.Products>>?
    getProductListingPaginationWithoutFiltersModel,
    //final Map<String, GetCommentForProductModel>? getCommentForProductModel,
    AuthProductDetailsStatus? authProductDetailsStatus,
    GetAuthProductDetailsModel? authProductDetailsModel,
  }) {
    return HomeState(
      getAndAddCountViewOfProductStatus:
          getAndAddCountViewOfProductStatus ??
          this.getAndAddCountViewOfProductStatus,

      enableAddToCardAfterChangeVariantZero:
          enableAddToCardAfterChangeVariantZero ??
          this.enableAddToCardAfterChangeVariantZero,
      updateOrderCommentRatingStatus:
          updateOrderCommentRatingStatus ?? this.updateOrderCommentRatingStatus,
      getCurrenciesForWalletStatus:
          getCurrenciesForWalletStatus ?? this.getCurrenciesForWalletStatus,
      walletCurrencies: walletCurrencies ?? this.walletCurrencies,
      updateLikeCommentRatingStatus:
          updateLikeCommentRatingStatus ?? this.updateLikeCommentRatingStatus,
      likeForReplayComment: likeForReplayComment ?? this.likeForReplayComment,
      deleteOrderCommentRatingStatus:
          deleteOrderCommentRatingStatus ?? this.deleteOrderCommentRatingStatus,
      addVariationToCartId: addVariationToCartId ?? this.addVariationToCartId,
      updateProfileStatus: updateProfileStatus ?? this.updateProfileStatus,
      uploadUserPhotoCloudinaryStatus:
          uploadUserPhotoCloudinaryStatus ??
          this.uploadUserPhotoCloudinaryStatus,
      userInfo: userInfo ?? this.userInfo,
      translateCommentStatus:
          translateCommentStatus ?? this.translateCommentStatus,
      createCommentRatingStatus:
          createCommentRatingStatus ?? this.createCommentRatingStatus,
      statusCodeOfCommentProcess:
          statusCodeOfCommentProcess ?? this.statusCodeOfCommentProcess,
      getCountryBoundaryByIsoStatus:
          getCoutryBoundaryByIsoStatus ?? this.getCountryBoundaryByIsoStatus,
      currentSlugToRefreshFromNotification:
          currentSlugToRefreshFromNotification ??
          this.currentSlugToRefreshFromNotification,
      tapCommentIndex: tapCommentIndex ?? this.tapCommentIndex,
      selectedVideoStatus: selectedVideoStatus ?? this.selectedVideoStatus,
      getOrderRatingStatus: getOrderRatingStatus ?? this.getOrderRatingStatus,

      storyLink: storyLink ?? this.storyLink,
      storiesCollections: storiesCollections ?? this.storiesCollections,
      currentPage: currentPage ?? this.currentPage,
      storyOffset: storyOffset ?? this.storyOffset,
      finishGetAllStory: finishGetAllStory ?? this.finishGetAllStory,
      getOrderRatingComments:
          getOrderRatingComments ?? this.getOrderRatingComments,
      getStoryWithPagintionStatusLoading:
          getStoryWithPagintionStatusLoading ??
          this.getStoryWithPagintionStatusLoading,
      currentStoryInEachCollection:
          currentStoryInEachCollection ?? this.currentStoryInEachCollection,
      selectedCollection: selectedCollection ?? this.selectedCollection,
      productIdToSaveRedeemTimer:
          productIdToSaveRedeemTimer ?? this.productIdToSaveRedeemTimer,
      getFqaCommentsPaginationModel:
          getFqaCommentsPaginationModel ?? this.getFqaCommentsPaginationModel,
      getBuyersCommentsPaginationModel:
          getBuyersCommentsPaginationModel ??
          this.getBuyersCommentsPaginationModel,
      countryCoordinatesBorders:
          countryCoordinatesBorders ?? this.countryCoordinatesBorders,
      // getCommentsFromAnalyticsPaginationModel:
      //    getCommentsFromAnalyticsPaginationModel ??
      //        this.getCommentsFromAnalyticsPaginationModel,
      hideItemInOldCartStatus:
          hideItemInOldCartStatus ?? this.hideItemInOldCartStatus,

      addProductIdToSaveRedeemTimerStatus:
          addProductIdToSaveRedeemTimerStatus ??
          this.addProductIdToSaveRedeemTimerStatus,
      getAllowedCountriesStatus:
          getAllowedCountriesStatus ?? this.getAllowedCountriesStatus,
      //  geColorsAndSizesForSearchModel:
      //      geColorsAndSizesForSearchModel ?? this.geColorsAndSizesForSearchModel,
      //  getCommentForProductModel:
      //    getCommentForProductModel ?? this.getCommentForProductModel,
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

      notificationTypeForProductModel:
          notificationTypeForProductModel ??
          this.notificationTypeForProductModel,
      firebaseSettingForNotificationModel:
          firebaseSettingForNotificationModel ??
          this.firebaseSettingForNotificationModel,
      isChangedvariationWhenQtyZero:
          isChangedVariationWhenQtyZero ?? this.isChangedvariationWhenQtyZero,

      changeSizesForEveryProduct:
          changeSizesForEveryProduct ?? this.changeSizesForEveryProduct,

      getNotificationTypeProductStatus:
          getNotificationTypeProductStatus ??
          this.getNotificationTypeProductStatus,

      currentIndexForUpdateCart:
          currentIndexForUpdateCart ?? this.currentIndexForUpdateCart,

      getUserNotificationModel:
          getUserNotificationModel ?? this.getUserNotificationModel,
      getCartOverviewStatus:
          getCartOverviewStatus ?? this.getCartOverviewStatus,

      checkAvailabilityProductCartModel:
          checkAvailabilityProductCartModel ??
          this.checkAvailabilityProductCartModel,
      checkAvailabilityProductCartStatus:
          checkAvailabilityProductCartStatus ??
          this.checkAvailabilityProductCartStatus,
      finishLoadingAfterChangedVariationWhenQtyZero:
          finishLoadingAfterChangedVariationWhenQtyZero ??
          this.finishLoadingAfterChangedVariationWhenQtyZero,
      addOrRemoveLikeOfProductStatus:
          addOrRemoveLikeOfProductStatus ?? this.addOrRemoveLikeOfProductStatus,
      convertItemFromcartToOldCartStatus:
          convertItemFromcartToOldCartStatus ??
          this.convertItemFromcartToOldCartStatus,
      popularSearchTerm: popularSearchTerm ?? this.popularSearchTerm,
      listOfErrorSendedToMobileErrorLog:
          listOfErrorSendedToMobileErrorLog ??
          this.listOfErrorSendedToMobileErrorLog,
      //   moveUrlFromElasticToMarketServer: moveUrlFromElasticToMarketServer ??
      //     this.moveUrlFromElasticToMarketServer,
      sizesForEachColor: sizesForEachColor ?? this.sizesForEachColor,
      getFullProductDetailsStatus:
          getFullProductDetailsStatus ?? this.getFullProductDetailsStatus,

          getRelatedProductsStatus:
          getRelatedProductsStatus ?? this.getRelatedProductsStatus,
      sizesQuantitiesForEachColor:
          sizesQuantitiesForEachColor ?? this.sizesQuantitiesForEachColor,

      //  addCommentStatus: addCommentStatus ?? this.addCommentStatus,
      isVariantRequestNotification:
          isVariantRequestNotification ?? this.isVariantRequestNotification,

      cartIdsHurryUPTimerStarted:
          cartIdsHurryUPTimerStarted ?? this.cartIdsHurryUPTimerStarted,

      // idForRequest: idForRequest ?? this.idForRequest,

      // getListOfProductsFoundedInCartStatus:
      //    getListOfProductsFoundedInCartStatus ??
      //      this.getListOfProductsFoundedInCartStatus,
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
      currentHeightWhenAddToBag:
          currentHeightWhenAddToBag ?? this.currentHeightWhenAddToBag,

      getOldCartModel: getOldCartModel ?? this.getOldCartModel,

      addItemInCartStatus: addItemInCartStatus ?? this.addItemInCartStatus,

      getCurrencyForCountryModel:
          getCurrencyForCountryModel ?? this.getCurrencyForCountryModel,

      currentQuantityForCart:
          currentQuantityForCart ?? this.currentQuantityForCart,

      //   productITemForCart: productITemForCart ?? this.productITemForCart,
      currentColorSizeForCart:
          currentColorSizeForCart ?? this.currentColorSizeForCart,

      searchHistory: searchHistory ?? this.searchHistory,
      getCartShippingItemsModel:
          getCartShippingItemsModel ?? this.getCartShippingItemsModel,

      //getCommentForProductStatus:
      //   getCommentForProductStatus ?? this.getCommentForProductStatus,
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

      getProductDetailWithoutSimilarRelatedProductsStatus:
          getProductDetailWithoutSimilarRelatedProductsStatus ??
          this.getProductDetailWithoutSimilarRelatedProductsStatus,
      getStartingSettingsStatus:
          getStartingSettingsStatus ?? this.getStartingSettingsStatus,


    relatedProducts: relatedProducts ?? this.relatedProducts,

      startingSetting: startingSetting ?? this.startingSetting,

      getProductListingPaginationWithoutFiltersModel:
          getProductListingPaginationWithoutFiltersModel ??
          this.getProductListingPaginationWithoutFiltersModel,
      updateEmailappNotificationStatus:
          updateEmailappNotificationStatus ??
          this.updateEmailappNotificationStatus,
      updateWhatsappNotificationStatus:
          updateWhatsappNotificationStatus ??
          this.updateWhatsappNotificationStatus,
      cachedProductWithoutRelatedProductsModel:
          cachedProductWithoutRelatedProductsModel ??
          this.cachedProductWithoutRelatedProductsModel,
      deleteItemInCartStatus:
          deleteItemInCartStatus ?? this.deleteItemInCartStatus,

      searchWithOutFilterOffset:
          searchWithOutFilterOffset ?? this.searchWithOutFilterOffset,

      productStatus: productStatus ?? this.productStatus,
      getAllowedCountriesModel:
          getAllowedCountriesModel ?? this.getAllowedCountriesModel,
      authProductDetailsStatus:
          authProductDetailsStatus ?? this.authProductDetailsStatus,
      authProductDetailsModel:
          authProductDetailsModel ?? this.authProductDetailsModel,
    );
  }

  factory HomeState.fromJson(Map<String, dynamic> data) =>
      _$HomeStateFromJson(data);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);
}
