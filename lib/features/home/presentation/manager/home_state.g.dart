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
      getProductsWithoutFiltersStatus: $enumDecodeNullable(
              _$GetProductsWithoutFiltersStatusEnumMap,
              json['getProductsWithoutFiltersStatus']) ??
          GetProductsWithoutFiltersStatus.init,
      startingSetting: json['startingSetting'] == null
          ? null
          : StartingSetting.fromJson(
              json['startingSetting'] as Map<String, dynamic>),
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
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      mainCategoriesResponseModel: json['mainCategoriesResponseModel'] == null
          ? null
          : MainCategoriesResponseModel.fromJson(
              json['mainCategoriesResponseModel'] as Map<String, dynamic>),
      getProductListingWithoutFiltersModel:
          json['getProductListingWithoutFiltersModel'] == null
              ? null
              : GetProductListingWithoutFiltersModel.fromJson(
                  json['getProductListingWithoutFiltersModel']
                      as Map<String, dynamic>),
      getHomeSectionsPaginationObject:
          (json['getHomeSectionsPaginationObject'] as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    PaginationModel<HomeSectionDataObject>.fromJson(
                        e as Map<String, dynamic>,
                        (value) => HomeSectionDataObject.fromJson(
                            value as Map<String, dynamic>))),
              ) ??
              const {},
    );

Map<String, dynamic> _$HomeStateToJson(HomeState instance) => <String, dynamic>{
      'getStartingSettingsStatus': _$GetStartingSettingsStatusEnumMap[
          instance.getStartingSettingsStatus]!,
      'currentIndex': instance.currentIndex,
      'getMainCategoriesStatus':
          _$GetMainCategoriesStatusEnumMap[instance.getMainCategoriesStatus]!,
      'getProductDetailWithoutSimilarRelatedProductsStatus':
          _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[
              instance.getProductDetailWithoutSimilarRelatedProductsStatus]!,
      'getHomeSectionsPaginationObject':
          instance.getHomeSectionsPaginationObject.map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'getProductsWithoutFiltersStatus':
          _$GetProductsWithoutFiltersStatusEnumMap[
              instance.getProductsWithoutFiltersStatus]!,
      'getProductListingWithoutFiltersModel':
          instance.getProductListingWithoutFiltersModel?.toJson(),
      'mainCategoriesResponseModel':
          instance.mainCategoriesResponseModel?.toJson(),
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

const _$GetProductsWithoutFiltersStatusEnumMap = {
  GetProductsWithoutFiltersStatus.init: 'init',
  GetProductsWithoutFiltersStatus.loading: 'loading',
  GetProductsWithoutFiltersStatus.success: 'success',
  GetProductsWithoutFiltersStatus.failure: 'failure',
};
