// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeState _$HomeStateFromJson(Map<String, dynamic> json) => HomeState(
      storiesForProduct: (json['storiesForProduct'] as List<dynamic>?)
          ?.map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
      getProductDetailWithoutSimilarRelatedProductsStatus: $enumDecodeNullable(
              _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap,
              json['getProductDetailWithoutSimilarRelatedProductsStatus']) ??
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      getStartingSettingsStatus: $enumDecodeNullable(
              _$GetStartingSettingsStatusEnumMap,
              json['getStartingSettingsStatus']) ??
          GetStartingSettingsStatus.init,
      getMainCategoriesStatus: $enumDecodeNullable(
              _$GetMainCategoriesStatusEnumMap,
              json['getMainCategoriesStatus']) ??
          GetMainCategoriesStatus.init,
      getCommentForProductStatus: $enumDecodeNullable(
              _$GetCommentForProductStatusEnumMap,
              json['getCommentForProductStatus']) ??
          GetCommentForProductStatus.init,
      startingSetting: json['startingSetting'] == null
          ? null
          : StartingSetting.fromJson(
              json['startingSetting'] as Map<String, dynamic>),
      sizes:
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      getSearchResultStatus: $enumDecodeNullable(
              _$GetSearchResultStatusEnumMap, json['getSearchResultStatus']) ??
          GetSearchResultStatus.init,
      searchResultModel: json['searchResultModel'] == null
          ? null
          : get_product_with_filter.GetProductListingWithFiltersModel.fromJson(
              json['searchResultModel'] as Map<String, dynamic>),
      getProductFiltersStatus: $enumDecodeNullable(
              _$GetProductFiltersStatusEnumMap,
              json['getProductFiltersStatus']) ??
          GetProductFiltersStatus.init,
      getProductFiltersModel: json['getProductFiltersModel'] == null
          ? null
          : get_filters.GetProductFiltersModel.fromJson(
              json['getProductFiltersModel'] as Map<String, dynamic>),
      choosedFiltersByUser: json['choosedFiltersByUser'] == null
          ? null
          : get_filters.GetProductFiltersModel.fromJson(
              json['choosedFiltersByUser'] as Map<String, dynamic>),
      appliedFiltersByUser: json['appliedFiltersByUser'] == null
          ? null
          : get_filters.GetProductFiltersModel.fromJson(
              json['appliedFiltersByUser'] as Map<String, dynamic>),
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      brands: (json['brands'] as List<dynamic>?)
          ?.map((e) => brand.Brand.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => category.Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      productITemForCart:
          (json['productITemForCart'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, Products.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      getCartShippingItemsModel: json['getCartShippingItemsModel'] == null
          ? null
          : GetCartShippingItemsModel.fromJson(
              json['getCartShippingItemsModel'] as Map<String, dynamic>),
      reRequestTheseBoutiques:
          (json['reRequestTheseBoutiques'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      getCommentForProductModel: (json['getCommentForProductModel']
                  as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                GetCommentForProductModel.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      reRequestTheseProductListingInBoutiques:
          (json['reRequestTheseProductListingInBoutiques']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      getProductListingStatus: $enumDecodeNullable(
              _$GetProductListingStatusEnumMap,
              json['getProductListingStatus']) ??
          GetProductListingStatus.init,
      selectedCollection: (json['selectedCollection'] as num?)?.toInt(),
      cartCollection: (json['cartCollection'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) => Cart.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      getProductListingWithFiltersPaginationModels:
          json['getProductListingWithFiltersPaginationModels'] == null
              ? null
              : PaginationModel<Products>.fromJson(
                  json['getProductListingWithFiltersPaginationModels']
                      as Map<String, dynamic>,
                  (value) => Products.fromJson(value as Map<String, dynamic>)),
      boutiques: (json['boutiques'] as List<dynamic>?)
          ?.map((e) => Boutique.fromJson(e as Map<String, dynamic>))
          .toList(),
      getStoriesForProductStatus: $enumDecodeNullable(
              _$GetStoriesForProductStatusEnumMap,
              json['getStoriesForProductStatus']) ??
          GetStoriesForProductStatus.init,
      mainCategoriesResponseModel: json['mainCategoriesResponseModel'] == null
          ? null
          : MainCategoriesResponseModel.fromJson(
              json['mainCategoriesResponseModel'] as Map<String, dynamic>),
      CurrentColorSizeForCart:
          (json['CurrentColorSizeForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      selectedBoutiqueBrandCategorySlugsForSearch:
          (json['selectedBoutiqueBrandCategorySlugsForSearch']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
      currentQuantityForCart:
          (json['currentQuantityForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
      ),
      searchHistory: (json['searchHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      getCartItemsStatus: $enumDecodeNullable(
              _$GetCartItemsStatusEnumMap, json['getCartItemsStatus']) ??
          GetCartItemsStatus.init,
      getProductDetailWithoutRelatedProductsModel:
          json['getProductDetailWithoutRelatedProductsModel'] == null
              ? null
              : GetProductDetailWithoutRelatedProductsModel.fromJson(
                  json['getProductDetailWithoutRelatedProductsModel']
                      as Map<String, dynamic>),
      getProductListingPaginationWithoutFiltersModel:
          (json['getProductListingPaginationWithoutFiltersModel']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    PaginationModel<Products>.fromJson(
                        e as Map<String, dynamic>,
                        (value) =>
                            Products.fromJson(value as Map<String, dynamic>))),
              ) ??
              const {},
      currentSelectedColorForEveryProduct:
          (json['currentSelectedColorForEveryProduct'] as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      cachedProductWithoutRelatedProductsModel:
          (json['cachedProductWithoutRelatedProductsModel']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    GetProductDetailWithoutRelatedProductsModel.fromJson(
                        e as Map<String, dynamic>)),
              ) ??
              const {},
      getHomeBoutiquesPaginationObjectByMainCategory:
          (json['getHomeBoutiquesPaginationObjectByMainCategory']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    PaginationModel<Boutique>.fromJson(
                        e as Map<String, dynamic>,
                        (value) =>
                            Boutique.fromJson(value as Map<String, dynamic>))),
              ) ??
              const {},
    );

Map<String, dynamic> _$HomeStateToJson(HomeState instance) => <String, dynamic>{
      'getStartingSettingsStatus': _$GetStartingSettingsStatusEnumMap[
          instance.getStartingSettingsStatus]!,
      'currentSelectedColorForEveryProduct':
          instance.currentSelectedColorForEveryProduct,
      'getCommentForProductStatus': _$GetCommentForProductStatusEnumMap[
          instance.getCommentForProductStatus]!,
      'productITemForCart':
          instance.productITemForCart.map((k, e) => MapEntry(k, e.toJson())),
      'getMainCategoriesStatus':
          _$GetMainCategoriesStatusEnumMap[instance.getMainCategoriesStatus]!,
      'getProductFiltersStatus':
          _$GetProductFiltersStatusEnumMap[instance.getProductFiltersStatus]!,
      'getProductListingWithFiltersPaginationModels':
          instance.getProductListingWithFiltersPaginationModels?.toJson(
        (value) => value.toJson(),
      ),
      'getProductFiltersModel': instance.getProductFiltersModel?.toJson(),
      'appliedFiltersByUser': instance.appliedFiltersByUser?.toJson(),
      'choosedFiltersByUser': instance.choosedFiltersByUser?.toJson(),
      'getSearchResultStatus':
          _$GetSearchResultStatusEnumMap[instance.getSearchResultStatus]!,
      'selectedCollection': instance.selectedCollection,
      'currentPage': instance.currentPage,
      'searchHistory': instance.searchHistory,
      'selectedBoutiqueBrandCategorySlugsForSearch':
          instance.selectedBoutiqueBrandCategorySlugsForSearch,
      'cartCollection': instance.cartCollection
          ?.map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
      'reRequestTheseBoutiques': instance.reRequestTheseBoutiques,
      'reRequestTheseProductListingInBoutiques':
          instance.reRequestTheseProductListingInBoutiques,
      'getProductDetailWithoutSimilarRelatedProductsStatus':
          _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[
              instance.getProductDetailWithoutSimilarRelatedProductsStatus]!,
      'getCartItemsStatus':
          _$GetCartItemsStatusEnumMap[instance.getCartItemsStatus]!,
      'getProductListingStatus':
          _$GetProductListingStatusEnumMap[instance.getProductListingStatus]!,
      'getStoriesForProductStatus': _$GetStoriesForProductStatusEnumMap[
          instance.getStoriesForProductStatus]!,
      'getHomeBoutiquesPaginationObjectByMainCategory': instance
          .getHomeBoutiquesPaginationObjectByMainCategory
          .map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'storiesForProduct':
          instance.storiesForProduct?.map((e) => e.toJson()).toList(),
      'sizes': instance.sizes,
      'boutiques': instance.boutiques?.map((e) => e.toJson()).toList(),
      'getProductListingPaginationWithoutFiltersModel': instance
          .getProductListingPaginationWithoutFiltersModel
          .map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'getCartShippingItemsModel': instance.getCartShippingItemsModel?.toJson(),
      'getCommentForProductModel': instance.getCommentForProductModel
          .map((k, e) => MapEntry(k, e.toJson())),
      'mainCategoriesResponseModel':
          instance.mainCategoriesResponseModel?.toJson(),
      'getProductDetailWithoutRelatedProductsModel':
          instance.getProductDetailWithoutRelatedProductsModel?.toJson(),
      'searchResultModel': instance.searchResultModel?.toJson(),
      'startingSetting': instance.startingSetting?.toJson(),
      'categories': instance.categories?.map((e) => e.toJson()).toList(),
      'brands': instance.brands?.map((e) => e.toJson()).toList(),
      'CurrentColorSizeForCart': instance.CurrentColorSizeForCart,
      'currentQuantityForCart': instance.currentQuantityForCart,
      'cachedProductWithoutRelatedProductsModel': instance
          .cachedProductWithoutRelatedProductsModel
          .map((k, e) => MapEntry(k, e.toJson())),
    };

const _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap = {
  GetProductDetailWithoutSimilarRelatedProductsStatus.init: 'init',
  GetProductDetailWithoutSimilarRelatedProductsStatus.loading: 'loading',
  GetProductDetailWithoutSimilarRelatedProductsStatus.success: 'success',
  GetProductDetailWithoutSimilarRelatedProductsStatus.failure: 'failure',
};

const _$GetStartingSettingsStatusEnumMap = {
  GetStartingSettingsStatus.init: 'init',
  GetStartingSettingsStatus.loading: 'loading',
  GetStartingSettingsStatus.success: 'success',
  GetStartingSettingsStatus.failure: 'failure',
};

const _$GetMainCategoriesStatusEnumMap = {
  GetMainCategoriesStatus.init: 'init',
  GetMainCategoriesStatus.loading: 'loading',
  GetMainCategoriesStatus.success: 'success',
  GetMainCategoriesStatus.failure: 'failure',
};

const _$GetCommentForProductStatusEnumMap = {
  GetCommentForProductStatus.init: 'init',
  GetCommentForProductStatus.loading: 'loading',
  GetCommentForProductStatus.success: 'success',
  GetCommentForProductStatus.failure: 'failure',
};

const _$GetSearchResultStatusEnumMap = {
  GetSearchResultStatus.init: 'init',
  GetSearchResultStatus.loading: 'loading',
  GetSearchResultStatus.success: 'success',
  GetSearchResultStatus.failure: 'failure',
};

const _$GetProductFiltersStatusEnumMap = {
  GetProductFiltersStatus.init: 'init',
  GetProductFiltersStatus.loading: 'loading',
  GetProductFiltersStatus.success: 'success',
  GetProductFiltersStatus.failure: 'failure',
};

const _$GetProductListingStatusEnumMap = {
  GetProductListingStatus.init: 'init',
  GetProductListingStatus.loading: 'loading',
  GetProductListingStatus.success: 'success',
  GetProductListingStatus.failure: 'failure',
};

const _$GetStoriesForProductStatusEnumMap = {
  GetStoriesForProductStatus.init: 'init',
  GetStoriesForProductStatus.loading: 'loading',
  GetStoriesForProductStatus.success: 'success',
  GetStoriesForProductStatus.failure: 'failure',
};

const _$GetCartItemsStatusEnumMap = {
  GetCartItemsStatus.init: 'init',
  GetCartItemsStatus.loading: 'loading',
  GetCartItemsStatus.success: 'success',
  GetCartItemsStatus.failure: 'failure',
};
