// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeState _$HomeStateFromJson(Map<String, dynamic> json) => HomeState(
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
      startingSetting: json['startingSetting'] == null
          ? null
          : StartingSetting.fromJson(
              json['startingSetting'] as Map<String, dynamic>),
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      selectedCollection: (json['selectedCollection'] as num?)?.toInt(),
      storiesCollections: (json['storiesCollections'] as List<dynamic>?)
              ?.map((e) =>
                  CollectionStoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      selectedVideoStatus: $enumDecodeNullable(
              _$SelectedVideoStatusEnumMap, json['selectedVideoStatus']) ??
          SelectedVideoStatus.init,
      currentStoryInEachCollection:
          (json['currentStoryInEachCollection'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k), (e as num?)?.toInt()),
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
      'getMainCategoriesStatus':
          _$GetMainCategoriesStatusEnumMap[instance.getMainCategoriesStatus]!,
      'selectedCollection': instance.selectedCollection,
      'currentPage': instance.currentPage,
      'getProductDetailWithoutSimilarRelatedProductsStatus':
          _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[
              instance.getProductDetailWithoutSimilarRelatedProductsStatus]!,
      'getStoriesForProductStatus': _$GetStoriesForProductStatusEnumMap[
          instance.getStoriesForProductStatus]!,
      'getHomeBoutiquesPaginationObjectByMainCategory': instance
          .getHomeBoutiquesPaginationObjectByMainCategory
          .map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'selectedVideoStatus':
          _$SelectedVideoStatusEnumMap[instance.selectedVideoStatus]!,
      'storiesCollections':
          instance.storiesCollections.map((e) => e.toJson()).toList(),
      'currentStoryInEachCollection': instance.currentStoryInEachCollection
          .map((k, e) => MapEntry(k.toString(), e)),
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

const _$GetStoriesForProductStatusEnumMap = {
  GetStoriesForProductStatus.init: 'init',
  GetStoriesForProductStatus.loading: 'loading',
  GetStoriesForProductStatus.success: 'success',
  GetStoriesForProductStatus.failure: 'failure',
};

const _$SelectedVideoStatusEnumMap = {
  SelectedVideoStatus.init: 'init',
  SelectedVideoStatus.loading: 'loading',
  SelectedVideoStatus.success: 'success',
  SelectedVideoStatus.failure: 'failure',
};
