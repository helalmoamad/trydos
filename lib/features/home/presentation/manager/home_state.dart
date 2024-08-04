import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart' as boutiques_model;

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

enum SelectedVideoStatus { init, loading, success, failure }

enum GetProductFiltersStatus { init, loading, success, failure }

enum GetCommentForProductStatus { init, loading, success, failure }

enum GetMainCategoriesStatus { init, loading, success, failure }

enum GetCartItemsStatus { init, loading, success, failure }

enum GetStoriesForProductStatus { init, loading, success, failure }

enum GetHomeBoutiqesStatus { init, loading, success, failure }

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }

enum GetProductListingStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
class HomeState {
  HomeState({
    this.storiesForProduct,
    this.getProductDetailWithoutSimilarRelatedProductsStatus =
        GetProductDetailWithoutSimilarRelatedProductsStatus.init,
    this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
    this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
    this.getCommentForProductStatus = GetCommentForProductStatus.init,
    this.startingSetting,
    this.sizes = const [],
    this.getProductFiltersStatus =const {},
    this.getProductFiltersModel=const {},
    this.choosedFiltersByUser=const {},
    this.appliedFiltersByUser=const {},
    this.currentPage = 0,
    this.productStatus,
    this.productITemForCart,
    this.getCartShippingItemsModel,
    this.reRequestTheseBoutiques = const {},
    this.getCommentForProductModel = const {},
    this.reRequestTheseProductListingInBoutiques = const {},
    this.reRequestProductWithFilters = const {},
    this.getProductListingStatus = GetProductListingStatus.init,
    this.selectedCollection,
    this.cartCollection = const {},
    this.getProductListingWithFiltersPaginationModels  =const {},
    this.getStoriesForProductStatus = GetStoriesForProductStatus.init,
    this.mainCategoriesResponseModel,
    this.CurrentColorSizeForCart,
    this.currentQuantityForCart,
    this.addImagesToProductIdForCart = const {},
    this.searchHistory,
    this.getAllowedCountriesModel,
    this.getCurrencyForCountryModel,
    this.ListitemForAddToCart,
    this.countOfProductExpectedByFiltering,
    this.getCartItemsStatus = GetCartItemsStatus.init,
    this.getProductDetailWithoutRelatedProductsModel,
    this.getProductListingPaginationWithoutFiltersModel = const {},
    this.currentSelectedColorForEveryProduct = const {},
    this.cachedProductWithoutRelatedProductsModel = const {},
    this.getHomeBoutiquesPaginationObjectByMainCategory = const {},
  });

  final GetStartingSettingsStatus getStartingSettingsStatus;
  final Map<String, int> currentSelectedColorForEveryProduct;
  final GetCommentForProductStatus getCommentForProductStatus;
  final Map<String, product.Products>? productITemForCart;
  final GetMainCategoriesStatus getMainCategoriesStatus;
  final List<ImageForAddToCart>? ListitemForAddToCart;
  final GetCurrencyForCountryModel? getCurrencyForCountryModel;
  final GetAllowedCountriesModel? getAllowedCountriesModel;
  final Map<String , GetProductFiltersStatus> getProductFiltersStatus;
  final Map<String , PaginationModel<product.Products>?> getProductListingWithFiltersPaginationModels;
  final Map<String,get_filters.GetProductFiltersModel?> getProductFiltersModel;
  final Map<String,get_filters.GetProductFiltersModel?> appliedFiltersByUser;
  final Map<String,get_filters.GetProductFiltersModel?> choosedFiltersByUser;
  int? selectedCollection;
  int currentPage;
  List<String>? searchHistory;
  Map<String, Map<int, List<String>>> addImagesToProductIdForCart;
  Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
      productStatus;
  Map<String, List<cart.Cart>>? cartCollection;
  final Map<String, bool> reRequestTheseBoutiques;
  final Map<String, bool> reRequestTheseProductListingInBoutiques;
  final Map<String, bool> reRequestProductWithFilters;
  final GetProductDetailWithoutSimilarRelatedProductsStatus
      getProductDetailWithoutSimilarRelatedProductsStatus;

  final GetCartItemsStatus getCartItemsStatus;
  final GetProductListingStatus getProductListingStatus;
  GetStoriesForProductStatus getStoriesForProductStatus;
  final Map<String, PaginationModel<boutiques_model.Boutique>>
      getHomeBoutiquesPaginationObjectByMainCategory;
  List<Story>? storiesForProduct;
  List<String>? sizes;
  int? countOfProductExpectedByFiltering;

  final Map<String, PaginationModel<product.Products>>
      getProductListingPaginationWithoutFiltersModel;
  final cart.GetCartShippingItemsModel? getCartShippingItemsModel;
  final Map<String, GetCommentForProductModel> getCommentForProductModel;

  final MainCategoriesResponseModel? mainCategoriesResponseModel;
  final GetProductDetailWithoutRelatedProductsModel?
      getProductDetailWithoutRelatedProductsModel;

  final StartingSetting? startingSetting;
  Map<String, String>? CurrentColorSizeForCart;
  Map<String, List<int>>? currentQuantityForCart;
  final Map<String, GetProductDetailWithoutRelatedProductsModel>
      cachedProductWithoutRelatedProductsModel;

  HomeState copyWith(
      {final GetStartingSettingsStatus? getStartingSettingsStatus,
      final GetMainCategoriesStatus? getMainCategoriesStatus,
      int? totalProductNumber,
      Map<String, Map<int, List<String>>>? addImagesToProductIdForCart,
      final List<ImageForAddToCart>? ListitemForAddToCart,
      final GetAllowedCountriesModel? getAllowedCountriesModel,
      final GetCurrencyForCountryModel? getCurrencyForCountryModel,
      final GetCommentForProductStatus? getCommentForProductStatus,
      final GetCartItemsStatus? getCartItemsStatus,
      Map<int, int?>? currentStoryInEachCollection,
      final GetProductDetailWithoutRelatedProductsModel?
          getProductDetailWithoutRelatedProductsModel,
      int? selectedCollection,
      List<String>? sizes,
      List<String>? searchHistory,
      Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>?
          productStatus,
      Map<String, List<int>>? currentQuantityForCart,
      Map<String, List<cart.Cart>>? cartCollection,
      Map<String, String>? CurrentColorSizeForCart,
      final Map<String, bool>? reRequestTheseBoutiques,
      final Map<String, product.Products>? productITemForCart,
      final cart.GetCartShippingItemsModel? getCartShippingItemsModel,
      final Map<String, bool>? reRequestTheseProductListingInBoutiques,
      final Map<String, bool>? reRequestProductWithFilters,
      final GetProductListingStatus? getProductListingStatus,
      final StartingSetting? startingSetting,
      final MainCategoriesResponseModel? mainCategoriesResponseModel,
      final Map<String, PaginationModel<boutiques_model.Boutique>>?
          getHomeBoutiquesPaginationObjectByMainCategory,
      final Map<String, GetProductDetailWithoutRelatedProductsModel>?
          cachedProductWithoutRelatedProductsModel,
      SelectedVideoStatus? selectedVideoStatus,
      GetStoriesForProductStatus? getStoriesForProductStatus,
      final GetProductDetailWithoutSimilarRelatedProductsStatus?
          getProductDetailWithoutSimilarRelatedProductsStatus,
      final Map<String, int>? currentSelectedColorForEveryProduct,
      int? currentPage,
      int? countOfProductExpectedByFiltering,
      List<Story>? storiesForProduct,
        final Map<String , GetProductFiltersStatus>? getProductFiltersStatus,
        final Map<String , PaginationModel<product.Products>?>? getProductListingWithFiltersPaginationModels,
      final Map<String,get_filters.GetProductFiltersModel?>? getProductFiltersModel,
      final Map<String,get_filters.GetProductFiltersModel?>? appliedFiltersByUser,
      final Map<String,get_filters.GetProductFiltersModel?>? choosedFiltersByUser,
      final Map<String, PaginationModel<product.Products>>?
          getProductListingPaginationWithoutFiltersModel,
      final Map<String, GetCommentForProductModel>?
          getCommentForProductModel}) {
    return HomeState(
        getCommentForProductModel:
            getCommentForProductModel ?? this.getCommentForProductModel,
        sizes: sizes ?? this.sizes,
        countOfProductExpectedByFiltering: countOfProductExpectedByFiltering ?? this.countOfProductExpectedByFiltering,
        ListitemForAddToCart: ListitemForAddToCart ?? this.ListitemForAddToCart,
        getCurrencyForCountryModel:
            getCurrencyForCountryModel ?? this.getCurrencyForCountryModel,
        addImagesToProductIdForCart:
            addImagesToProductIdForCart ?? this.addImagesToProductIdForCart,
        cartCollection: cartCollection ?? this.cartCollection,
        getProductFiltersStatus:
            getProductFiltersStatus ?? this.getProductFiltersStatus,
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels ??
                this.getProductListingWithFiltersPaginationModels,
        currentQuantityForCart:
            currentQuantityForCart ?? this.currentQuantityForCart,
        productITemForCart: productITemForCart ?? this.productITemForCart,
        CurrentColorSizeForCart:
            CurrentColorSizeForCart ?? this.CurrentColorSizeForCart,
        choosedFiltersByUser:  choosedFiltersByUser ?? this.choosedFiltersByUser,
        appliedFiltersByUser: appliedFiltersByUser ?? this.appliedFiltersByUser,
        getProductFiltersModel:  getProductFiltersModel ?? this.getProductFiltersModel,
        searchHistory: searchHistory ?? this.searchHistory,
        getCartShippingItemsModel:
            getCartShippingItemsModel ?? this.getCartShippingItemsModel,
        getCommentForProductStatus:
            getCommentForProductStatus ?? this.getCommentForProductStatus,
        getProductListingStatus:
            getProductListingStatus ?? this.getProductListingStatus,
        currentSelectedColorForEveryProduct: currentSelectedColorForEveryProduct ??
            this.currentSelectedColorForEveryProduct,
        getCartItemsStatus: getCartItemsStatus ?? this.getCartItemsStatus,
        reRequestTheseBoutiques:
            reRequestTheseBoutiques ?? this.reRequestTheseBoutiques,
        reRequestTheseProductListingInBoutiques: reRequestTheseProductListingInBoutiques ??
            this.reRequestTheseProductListingInBoutiques,
      reRequestProductWithFilters: reRequestProductWithFilters ??
            this.reRequestProductWithFilters,
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
        cachedProductWithoutRelatedProductsModel: cachedProductWithoutRelatedProductsModel ??
            this.cachedProductWithoutRelatedProductsModel,
        getProductDetailWithoutRelatedProductsModel:
            getProductDetailWithoutRelatedProductsModel ??
                this.getProductDetailWithoutRelatedProductsModel,
        productStatus: productStatus ?? this.productStatus,
        getAllowedCountriesModel: getAllowedCountriesModel ?? this.getAllowedCountriesModel,
    );
  }

  factory HomeState.fromJson(Map<String, dynamic> data) =>
      _$HomeStateFromJson(data);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);
}
