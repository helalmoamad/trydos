import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart'
    as boutiques_model;
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;

import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';

import '../../../../core/data/model/pagination_model.dart';
import '../../data/models/get_cart_item_model.dart';
import '../../data/models/get_home_boutiqes_model.dart';
import '../../data/models/get_product_filters_model.dart' as get_filters;
import '../../data/models/get_product_listing_with_filters_model.dart'
    as get_product_with_filter;
import '../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../data/models/main_categories_response_model.dart';
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

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }

enum AddOrRemoveLikeOfProductStatus { init, loading, success, failure }

enum GetProductListingStatus { init, loading, success, failure }

enum GetAndAddCountViewOfProductStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
@immutable
class HomeState extends Equatable {
  const HomeState({
    this.storiesForProduct,
    this.getAndAddCountViewOfProductStatus = const {},
    this.addItemInCartStatus,
    this.convertItemFromOldcartToCartStatus,
    this.hideItemInOldCartStatus,
    this.searchWithOutFilterOffset,
    this.searchWithFilterOffset,
    this.getProductDetailWithoutSimilarRelatedProductsStatus =
        GetProductDetailWithoutSimilarRelatedProductsStatus.init,
    this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
    this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
    this.getCommentForProductStatus = GetCommentForProductStatus.init,
    this.getFullProductDetailsStatus = GetFullProductDetailsStatus.init,
    this.addCommentStatus = AddCommentStatus.init,
    this.startingSetting,
    this.sizes = const [],
    this.sizesQuantities = const [],
    this.isSizeRequestNotification = const [],
    this.deleteItemInCartStatus,
    this.oldcartCollection,
    this.getOldCartItemsStatus = GetOLdCartItemsStatus.init,
    this.getOldCartModel,
    this.isGettingProductListingWithPagination = false,
    this.isGettingProductListingWithPaginationForAppearProduct = false,
    this.getProductFiltersStatus = const {},
    this.getProductFiltersModel = const {},
    this.choosedFiltersByUser = const {},
    this.appliedFiltersByUser = const {},
    this.currentPage = 0,
    this.productStatus,
    this.updateItemInCartStatus,
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
    this.cartCollection = const {},
    //this.idForRequest,
    this.getProductListingWithFiltersPaginationModels = const {},
    this.getStoriesForProductStatus = GetStoriesForProductStatus.init,
    this.mainCategoriesResponseModel,
    this.sendRequestToGeminiStatus = SendRequestToGeminiStatus.init,
    this.CurrentColorSizeForCart,
    this.currentQuantityForCart,
    this.addImagesToProductIdForCart = const {},
    this.searchHistory,
    this.cashedOrginalBoutique = false,
    this.getAllowedCountriesModel,
    this.currentIndexForMainCategoryEvent = 0,
    this.prefAppliedFilterForExtendFilter,
    this.fromSearchForSearchWithGemini = false,
    this.ListitemForAddToCart,
    this.getListOfProductsFoundedInCartStatus =
        GetListOfProductsFoundedInCartStatus.init,
    this.getCurrencyForCountryModel,
    this.isExpandedForListingPage = false,
    this.countOfProductExpectedByFiltering,
    this.getCartItemsStatus = GetCartItemsStatus.init,
    this.getProductDetailWithoutRelatedProductsModel,
    this.addOrRemoveLikeOfProductStatus = AddOrRemoveLikeOfProductStatus.init,
    this.getProductListingPaginationWithoutFiltersModel = const {},
    this.getProductListingWithFiltersPaginationWithPrefetchModels = const {},
    this.getProductFiltersWithPrefetchModel = const {},
    this.currentSelectedColorForEveryProduct = const {},
    this.boutiquesThatDidPrefetch = const {},
    this.boutiquesForEveryMainCategoryThatDidPrefetch = const {},
    this.cachedProductWithoutRelatedProductsModel = const {},
    this.getHomeBoutiquesPaginationObjectByMainCategory = const {},
  });

  final Map<String, bool> boutiquesThatDidPrefetch;
  final Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch;
  final GetStartingSettingsStatus getStartingSettingsStatus;
  final Map<String, int> currentSelectedColorForEveryProduct;
  final GetCommentForProductStatus getCommentForProductStatus;
  final Map<String, product.Products> productITemForCart;
  final ConvertItemFromOldcartToCartStatus? convertItemFromOldcartToCartStatus;
  final GetMainCategoriesStatus getMainCategoriesStatus;
  final HideItemInOldCartStatus? hideItemInOldCartStatus;
  final Map<String, GetAndAddCountViewOfProductStatus>
      getAndAddCountViewOfProductStatus;
  final List<ImageForAddToCart>? ListitemForAddToCart;
  final GetAllowedCountriesModel? getAllowedCountriesModel;
  final Map<String, GetProductFiltersStatus> getProductFiltersStatus;
  final Map<String, PaginationModel<product.Products>?>
      getProductListingWithFiltersPaginationModels;
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
  final Map<String, String>? searchWithFilterOffset;
  final Map<String, String>? searchWithOutFilterOffset;
  final Map<String, Map<int, List<String>>> addImagesToProductIdForCart;
  final Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
      productStatus;
  final Map<String, List<cart.Cart>>? cartCollection;
  final GetListOfProductsFoundedInCartStatus
      getListOfProductsFoundedInCartStatus;
  final Map<String, List<oldCart.OldCart>>? oldcartCollection;

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
  final List<String>? sizes;
  final List<int>? sizesQuantities;
  final List<String> isSizeRequestNotification;
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
  final bool cashedOrginalBoutique;
  final int currentIndexForMainCategoryEvent;
  final StartingSetting? startingSetting;
  final Map<String, String>? CurrentColorSizeForCart;
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
        ListitemForAddToCart,
        getAllowedCountriesModel,
        getProductFiltersStatus,
        getProductListingWithFiltersPaginationModels,
        getCurrencyForCountryModel,
        sendRequestToGeminiStatus,
        theReplyFromGemini,
        addCommentStatus,
        hideItemInOldCartStatus,
        cashedOrginalBoutique,
        productContentForStatusOfOpeningProductDetailsDirectly,
        getProductListingWithFiltersPaginationWithPrefetchModels,
        getProductFiltersModel,
        getProductFiltersWithPrefetchModel,
        getAndAddCountViewOfProductStatus,
        appliedFiltersByUser,
        choosedFiltersByUser,
        selectedCollection,
        currentPage,
        sizesQuantities,
        isExpandedForListingPage,
        isGettingProductListingWithPagination,
        isGettingProductListingWithPaginationForAppearProduct,
        searchHistory,
        addImagesToProductIdForCart,
        productStatus,
        cartCollection,
        fromSearchForSearchWithGemini,
        reRequestTheseBoutiques,
        reRequestTheseProductListingInBoutiques,
        reRequestProductWithFilters,
        getProductDetailWithoutSimilarRelatedProductsStatus,
        getCartItemsStatus,
        getProductListingStatus,
        getStoriesForProductStatus,
        getHomeBoutiquesPaginationObjectByMainCategory,
        storiesForProduct,
        sizes,
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
        isSizeRequestNotification,
        selectedCollection,
        cashedOrginalBoutique,
        currentIndexForMainCategoryEvent,
        startingSetting,
        CurrentColorSizeForCart,
        currentQuantityForCart,
        cachedProductWithoutRelatedProductsModel,
        addOrRemoveLikeOfProductStatus
      ];

  HomeState copyWith(
      {final GetStartingSettingsStatus? getStartingSettingsStatus,
      final GetMainCategoriesStatus? getMainCategoriesStatus,
      final AddItemInCartStatus? addItemInCartStatus,
      final HideItemInOldCartStatus? hideItemInOldCartStatus,
      final ConvertItemFromOldcartToCartStatus?
          convertItemFromOldcartToCartStatus,
      final UpdateItemInCartStatus? updateItemInCartStatus,
      final Map<String, String>? searchWithFilterOffset,
      final GetListOfProductsFoundedInCartStatus?
          getListOfProductsFoundedInCartStatus,
      final Map<String, String>? searchWithOutFilterOffset,
      final Map<String, get_filters.GetProductFiltersModel?>?
          getProductFiltersWithPrefetchModel,
      final Map<String, GetAndAddCountViewOfProductStatus>?
          getAndAddCountViewOfProductStatus,
      bool? cashedOrginalBoutique,
      bool? isExpandedForLidtingPage,
      final bool? fromSearchForSearchWithGemini,

      // String? idForRequest,

      get_filters.Filter? prefAppliedFilterForExtendFilter,
      final Map<String, bool>? boutiquesThatDidPrefetch,
      final Map<String, bool>? boutiquesForEveryMainCategoryThatDidPrefetch,
      Map<String, Map<int, List<String>>>? addImagesToProductIdForCart,
      final List<ImageForAddToCart>? ListitemForAddToCart,
      final GetAllowedCountriesModel? getAllowedCountriesModel,
      final Map<String, PaginationModel<product.Products>?>?
          getProductListingWithFiltersPaginationWithPrefetchModels,
      final GetCommentForProductStatus? getCommentForProductStatus,
      final AddOrRemoveLikeOfProductStatus? addOrRemoveLikeOfProductStatus,
      final bool? isGettingProductListingWithPagination,
      final GetCartItemsStatus? getCartItemsStatus,
      final GetOLdCartItemsStatus? getOldCartItemsStatus,
      Map<int, int?>? currentStoryInEachCollection,
      final AddCommentStatus? addCommentStatus,
      final GetProductDetailWithoutRelatedProductsModel?
          getProductDetailWithoutRelatedProductsModel,
      int? selectedCollection,
      Products? productContentForStatusOfOpeningProductDetailsDirectly,
      List<String>? sizes,
      List<int>? sizesQuantities,
      List<String>? isSizeRequestNotification,
      final String? theReplyFromGemini,
      final bool? isGettingProductListingWithPaginationForAppearProduct,
      int? currentIndexForMainCategoryEvent,
      List<String>? searchHistory,
      Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
          productStatus,
      Map<String, List<int>>? currentQuantityForCart,
      Map<String, List<cart.Cart>>? cartCollection,
      Map<String, List<oldCart.OldCart>>? oldCartCollection,
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
      hideItemInOldCartStatus:
          hideItemInOldCartStatus ?? this.hideItemInOldCartStatus,
      getCommentForProductModel:
          getCommentForProductModel ?? this.getCommentForProductModel,
      updateItemInCartStatus:
          updateItemInCartStatus ?? this.updateItemInCartStatus,
      addOrRemoveLikeOfProductStatus:
          addOrRemoveLikeOfProductStatus ?? this.addOrRemoveLikeOfProductStatus,
      convertItemFromOldcartToCartStatus: convertItemFromOldcartToCartStatus ??
          this.convertItemFromOldcartToCartStatus,

      sizes: sizes ?? this.sizes,
      getFullProductDetailsStatus:
          getFullProductDetailsStatus ?? this.getFullProductDetailsStatus,
      sizesQuantities: sizesQuantities ?? this.sizesQuantities,
      addCommentStatus: addCommentStatus ?? this.addCommentStatus,
      isSizeRequestNotification:
          isSizeRequestNotification ?? this.isSizeRequestNotification,
      isGettingProductListingWithPagination:
          isGettingProductListingWithPagination ??
              this.isGettingProductListingWithPagination,
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
      ListitemForAddToCart: ListitemForAddToCart ?? this.ListitemForAddToCart,
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
      CurrentColorSizeForCart:
          CurrentColorSizeForCart ?? this.CurrentColorSizeForCart,
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
