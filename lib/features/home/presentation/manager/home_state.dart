part of 'home_bloc.dart';

enum GetStartingSettingsStatus { init, loading, success, failure }

enum GetMainCategoriesStatus { init, loading, success, failure }

enum GetHomeSectionsStatus { init, loading, success, failure }

enum GetProductsWithoutFiltersStatus { init, loading, success, failure }

class HomeState {
  HomeState({
    this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
    this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
    this.getProductsWithoutFiltersStatus = GetProductsWithoutFiltersStatus.init,
    this.startingSetting ,
    this.getProductListingWithoutFiltersModel ,
    this.getHomeSectionsStatus = GetHomeSectionsStatus.init,
  });

  final GetStartingSettingsStatus getStartingSettingsStatus;

  final GetMainCategoriesStatus getMainCategoriesStatus;

  final GetHomeSectionsStatus getHomeSectionsStatus;

  final GetProductsWithoutFiltersStatus getProductsWithoutFiltersStatus;

  final GetProductListingWithoutFiltersModel? getProductListingWithoutFiltersModel;

  final StartingSetting? startingSetting ;

  HomeState copyWith({
    final GetStartingSettingsStatus? getStartingSettingsStatus,

    final GetMainCategoriesStatus? getMainCategoriesStatus,

    final GetHomeSectionsStatus? getHomeSectionsStatus,

    final StartingSetting? startingSetting ,

    final GetProductsWithoutFiltersStatus? getProductsWithoutFiltersStatus,

    final GetProductListingWithoutFiltersModel? getProductListingWithoutFiltersModel
  }) {
    return HomeState(
      getStartingSettingsStatus: getStartingSettingsStatus ??
          this.getStartingSettingsStatus,
      getMainCategoriesStatus: getMainCategoriesStatus ??
          this.getMainCategoriesStatus,
      getHomeSectionsStatus: getHomeSectionsStatus ??
          this.getHomeSectionsStatus,
        startingSetting : startingSetting ?? this.startingSetting,
        getProductsWithoutFiltersStatus : getProductsWithoutFiltersStatus ?? this.getProductsWithoutFiltersStatus,
      getProductListingWithoutFiltersModel : getProductListingWithoutFiltersModel ?? this.getProductListingWithoutFiltersModel,
    );
  }
}
