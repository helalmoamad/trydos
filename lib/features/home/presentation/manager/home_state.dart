import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';

import '../../../../core/data/model/pagination_model.dart';
import '../../data/models/get_product_listing_without_filters_model.dart';
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

enum GetMainCategoriesStatus { init, loading, success, failure }

enum GetHomeSectionsStatus { init, loading, success, failure }

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
class HomeState {
  HomeState(
      {this.getProductDetailWithoutSimilarRelatedProductsStatus =
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
      this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
      this.getProductsWithoutFiltersStatus =
          GetProductsWithoutFiltersStatus.init,
      this.startingSetting,
      this.currentIndex = 0,
      this.mainCategoriesResponseModel,
      this.getProductDetailWithoutRelatedProductsModel,
      this.getProductListingWithoutFiltersModel,
      this.getHomeSectionsPaginationObject = const {}});

  final GetStartingSettingsStatus getStartingSettingsStatus;
  int currentIndex = 0;
  final GetMainCategoriesStatus getMainCategoriesStatus;

  final GetProductDetailWithoutSimilarRelatedProductsStatus
      getProductDetailWithoutSimilarRelatedProductsStatus;

  final Map<String, PaginationModel<HomeSectionDataObject>>
      getHomeSectionsPaginationObject;

  final GetProductsWithoutFiltersStatus getProductsWithoutFiltersStatus;

  final GetProductListingWithoutFiltersModel?
      getProductListingWithoutFiltersModel;

  final MainCategoriesResponseModel? mainCategoriesResponseModel;
  final GetProductDetailWithoutRelatedProductsModel?
      getProductDetailWithoutRelatedProductsModel;

  final StartingSetting? startingSetting;
  HomeState copyWith(
      {final GetStartingSettingsStatus? getStartingSettingsStatus,
      final GetMainCategoriesStatus? getMainCategoriesStatus,
      final GetProductDetailWithoutRelatedProductsModel?
          getProductDetailWithoutRelatedProductsModel,
      final StartingSetting? startingSetting,
      final MainCategoriesResponseModel? mainCategoriesResponseModel,
      final Map<String, PaginationModel<HomeSectionDataObject>>?
          getHomeSectionsPaginationObject,
      final GetProductsWithoutFiltersStatus? getProductsWithoutFiltersStatus,
      final GetProductDetailWithoutSimilarRelatedProductsStatus?
          getProductDetailWithoutSimilarRelatedProductsStatus,
      int? currentIndex,
      final GetProductListingWithoutFiltersModel?
          getProductListingWithoutFiltersModel}) {
    return HomeState(
        currentIndex: currentIndex ?? this.currentIndex,
        getProductDetailWithoutSimilarRelatedProductsStatus:
            getProductDetailWithoutSimilarRelatedProductsStatus ??
                this.getProductDetailWithoutSimilarRelatedProductsStatus,
        getStartingSettingsStatus:
            getStartingSettingsStatus ?? this.getStartingSettingsStatus,
        getMainCategoriesStatus:
            getMainCategoriesStatus ?? this.getMainCategoriesStatus,
        getHomeSectionsPaginationObject: getHomeSectionsPaginationObject ??
            this.getHomeSectionsPaginationObject,
        startingSetting: startingSetting ?? this.startingSetting,
        mainCategoriesResponseModel:
            mainCategoriesResponseModel ?? this.mainCategoriesResponseModel,
        getProductsWithoutFiltersStatus: getProductsWithoutFiltersStatus ??
            this.getProductsWithoutFiltersStatus,
        getProductListingWithoutFiltersModel:
            getProductListingWithoutFiltersModel ??
                this.getProductListingWithoutFiltersModel,
        getProductDetailWithoutRelatedProductsModel:
            getProductDetailWithoutRelatedProductsModel ??
                this.getProductDetailWithoutRelatedProductsModel);
  }

  factory HomeState.fromJson(Map<String, dynamic> data) =>
      _$HomeStateFromJson(data);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);
}
