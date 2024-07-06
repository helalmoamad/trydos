import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';

import '../../../../core/data/model/pagination_model.dart';
import '../../data/models/get_product_filters_model.dart';
import '../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../data/models/home_sections_response_model.dart';
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

enum GetProductFiltersStatus { loading, success, failure }

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
    this.sizes,
    this.getProductFiltersStatus = GetProductFiltersStatus.loading,
    this.getProductFiltersModel,
    this.currentPage = 0,
    this.productITemForCart = const {},
    this.getCartShippingItemsModel,
    this.reRequestTheseBoutiques = const {},
    this.getCommentForProductModel = const {},
    this.reRequestTheseProductListingInBoutiques = const {},
    this.getProductListingStatus = GetProductListingStatus.init,
    this.selectedCollection,
    this.cartCollection = const {},
    this.getStoriesForProductStatus = GetStoriesForProductStatus.init,
    this.mainCategoriesResponseModel,
    this.CurrentColorSizeForCart,
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
  final Map<String, Products> productITemForCart;
  final GetMainCategoriesStatus getMainCategoriesStatus;
  final GetProductFiltersStatus getProductFiltersStatus;
  final GetProductFiltersModel? getProductFiltersModel;
  int? selectedCollection;
  int currentPage;
  Map<String, List<cart.Cart>>? cartCollection;
  final Map<String, bool> reRequestTheseBoutiques;
  final Map<String, bool> reRequestTheseProductListingInBoutiques;
  final GetProductDetailWithoutSimilarRelatedProductsStatus
      getProductDetailWithoutSimilarRelatedProductsStatus;
  final GetCartItemsStatus getCartItemsStatus;
  final GetProductListingStatus getProductListingStatus;
  GetStoriesForProductStatus getStoriesForProductStatus;
  final Map<String, PaginationModel<Boutique>>
      getHomeBoutiquesPaginationObjectByMainCategory;
  List<Story>? storiesForProduct;
  List<String>? sizes;
  final Map<String, PaginationModel<product.Products>>
      getProductListingPaginationWithoutFiltersModel;
  final cart.GetCartShippingItemsModel? getCartShippingItemsModel;
  final Map<String, GetCommentForProductModel> getCommentForProductModel;

  final MainCategoriesResponseModel? mainCategoriesResponseModel;
  final GetProductDetailWithoutRelatedProductsModel?
      getProductDetailWithoutRelatedProductsModel;

  final StartingSetting? startingSetting;
  Map<String, String>? CurrentColorSizeForCart;
  final Map<String, GetProductDetailWithoutRelatedProductsModel>
      cachedProductWithoutRelatedProductsModel;

  HomeState copyWith(
      {final GetStartingSettingsStatus? getStartingSettingsStatus,
      final GetMainCategoriesStatus? getMainCategoriesStatus,
      final GetCommentForProductStatus? getCommentForProductStatus,
      final GetCartItemsStatus? getCartItemsStatus,
      Map<int, int?>? currentStoryInEachCollection,
      final GetProductDetailWithoutRelatedProductsModel?
          getProductDetailWithoutRelatedProductsModel,
      int? selectedCollection,
      List<String>? sizes,
      Map<String, List<cart.Cart>>? cartCollection,
      Map<String, String>? CurrentColorSizeForCart,
      final GetProductFiltersStatus? getProductFiltersStatus,
      final GetProductFiltersModel? getProductFiltersModel,
      final Map<String, bool>? reRequestTheseBoutiques,
      final Map<String, Products>? productITemForCart,
      final cart.GetCartShippingItemsModel? getCartShippingItemsModel,
      final Map<String, bool>? reRequestTheseProductListingInBoutiques,
      final GetProductListingStatus? getProductListingStatus,
      final StartingSetting? startingSetting,
      final MainCategoriesResponseModel? mainCategoriesResponseModel,
      final Map<String, PaginationModel<Boutique>>?
          getHomeBoutiquesPaginationObjectByMainCategory,
      final Map<String, GetProductDetailWithoutRelatedProductsModel>?
          cachedProductWithoutRelatedProductsModel,
      SelectedVideoStatus? selectedVideoStatus,
      GetStoriesForProductStatus? getStoriesForProductStatus,
      final GetProductDetailWithoutSimilarRelatedProductsStatus?
          getProductDetailWithoutSimilarRelatedProductsStatus,
      final Map<String, int>? currentSelectedColorForEveryProduct,
      int? currentPage,
      List<Story>? storiesForProduct,
      final Map<String, PaginationModel<product.Products>>?
          getProductListingPaginationWithoutFiltersModel,
      final Map<String, GetCommentForProductModel>?
          getCommentForProductModel}) {
    return HomeState(
        getCommentForProductModel:
            getCommentForProductModel ?? this.getCommentForProductModel,
        sizes: sizes ?? this.sizes,
        cartCollection: cartCollection ?? this.cartCollection,
        productITemForCart: productITemForCart ?? this.productITemForCart,
        CurrentColorSizeForCart:
            CurrentColorSizeForCart ?? this.CurrentColorSizeForCart,
        getProductFiltersStatus:
            getProductFiltersStatus ?? this.getProductFiltersStatus,
        getProductFiltersModel:
            getProductFiltersModel ?? this.getProductFiltersModel,
        getCartShippingItemsModel:
            getCartShippingItemsModel ?? this.getCartShippingItemsModel,
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
        getProductDetailWithoutRelatedProductsModel:
            getProductDetailWithoutRelatedProductsModel ??
                this.getProductDetailWithoutRelatedProductsModel);
  }

  factory HomeState.fromJson(Map<String, dynamic> data) =>
      _$HomeStateFromJson(data);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);
}
