import 'package:json_annotation/json_annotation.dart';

import '../../../../core/data/model/pagination_model.dart';
import '../../data/models/get_product_listing_without_filters_model.dart';
import '../../data/models/home_sections_response_model.dart';
import '../../data/models/main_categories_response_model.dart';
import '../../data/models/starting_settings_response_model.dart';
part 'home_state.g.dart';

enum GetStartingSettingsStatus { init, loading, success, failure }

enum GetMainCategoriesStatus { init, loading, success, failure }

enum GetHomeSectionsStatus { init, loading, success, failure }

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }
@JsonSerializable()
class HomeState {
  HomeState({
    this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
    this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
    this.getProductsWithoutFiltersStatus = GetProductsWithoutFiltersStatus.init,
    this.startingSetting ,
    this.mainCategoriesResponseModel ,
    this.getProductListingWithoutFiltersModel ,
    this.getHomeSectionsPaginationObject = const {}
  });

  final GetStartingSettingsStatus getStartingSettingsStatus;

  final GetMainCategoriesStatus getMainCategoriesStatus;


  final Map<String , PaginationModel<HomeSectionDataObject>> getHomeSectionsPaginationObject;

  final GetProductsWithoutFiltersStatus getProductsWithoutFiltersStatus;

  final GetProductListingWithoutFiltersModel? getProductListingWithoutFiltersModel;

  final MainCategoriesResponseModel? mainCategoriesResponseModel;
  final StartingSetting? startingSetting ;

  HomeState copyWith({
    final GetStartingSettingsStatus? getStartingSettingsStatus,

    final GetMainCategoriesStatus? getMainCategoriesStatus,


    final StartingSetting? startingSetting ,
    final MainCategoriesResponseModel? mainCategoriesResponseModel,

    final Map<String , PaginationModel<HomeSectionDataObject>>? getHomeSectionsPaginationObject,
    final GetProductsWithoutFiltersStatus? getProductsWithoutFiltersStatus,

    final GetProductListingWithoutFiltersModel? getProductListingWithoutFiltersModel
  }) {
    return HomeState(
      getStartingSettingsStatus: getStartingSettingsStatus ??
          this.getStartingSettingsStatus,
      getMainCategoriesStatus: getMainCategoriesStatus ??
          this.getMainCategoriesStatus,
      getHomeSectionsPaginationObject: getHomeSectionsPaginationObject ??
          this.getHomeSectionsPaginationObject,
        startingSetting : startingSetting ?? this.startingSetting,
      mainCategoriesResponseModel : mainCategoriesResponseModel ?? this.mainCategoriesResponseModel,
        getProductsWithoutFiltersStatus : getProductsWithoutFiltersStatus ?? this.getProductsWithoutFiltersStatus,
      getProductListingWithoutFiltersModel : getProductListingWithoutFiltersModel ?? this.getProductListingWithoutFiltersModel,
    );
  }

  factory HomeState.fromJson(Map<String,dynamic> data) => _$HomeStateFromJson(data);

  Map<String,dynamic> toJson() => _$HomeStateToJson(this);
}
