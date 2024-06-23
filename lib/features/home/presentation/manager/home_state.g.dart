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
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      reRequestTheseBoutiques:
          (json['reRequestTheseBoutiques'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
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
      getStoriesForProductStatus: $enumDecodeNullable(
              _$GetStoriesForProductStatusEnumMap,
              json['getStoriesForProductStatus']) ??
          GetStoriesForProductStatus.init,
      mainCategoriesResponseModel: json['mainCategoriesResponseModel'] == null
          ? null
          : MainCategoriesResponseModel.fromJson(
              json['mainCategoriesResponseModel'] as Map<String, dynamic>),
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
      'getMainCategoriesStatus':
          _$GetMainCategoriesStatusEnumMap[instance.getMainCategoriesStatus]!,
      'selectedCollection': instance.selectedCollection,
      'currentPage': instance.currentPage,
      'reRequestTheseBoutiques': instance.reRequestTheseBoutiques,
      'reRequestTheseProductListingInBoutiques':
          instance.reRequestTheseProductListingInBoutiques,
      'getProductDetailWithoutSimilarRelatedProductsStatus':
          _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[
              instance.getProductDetailWithoutSimilarRelatedProductsStatus]!,
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
      'getProductListingPaginationWithoutFiltersModel': instance
          .getProductListingPaginationWithoutFiltersModel
          .map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'mainCategoriesResponseModel':
          instance.mainCategoriesResponseModel?.toJson(),
      'getProductDetailWithoutRelatedProductsModel':
          instance.getProductDetailWithoutRelatedProductsModel?.toJson(),
      'startingSetting': instance.startingSetting?.toJson(),
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
