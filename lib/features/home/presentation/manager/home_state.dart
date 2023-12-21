part of 'home_bloc.dart';

enum GetStartingSettingsStatus { init, loading, success, failure }

enum GetMainCategoriesStatus { init, loading, success, failure }

enum GetHomeSectionsStatus { init, loading, success, failure }

class HomeState {
  HomeState({
    this.getStartingSettingsStatus = GetStartingSettingsStatus.init,
    this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
    this.startingSetting ,
    this.getHomeSectionsStatus = GetHomeSectionsStatus.init,
  });

  final GetStartingSettingsStatus getStartingSettingsStatus;

  final GetMainCategoriesStatus getMainCategoriesStatus;

  final GetHomeSectionsStatus getHomeSectionsStatus;

  final StartingSetting? startingSetting ;

  HomeState copyWith({
    final GetStartingSettingsStatus? getStartingSettingsStatus,

    final GetMainCategoriesStatus? getMainCategoriesStatus,

    final GetHomeSectionsStatus? getHomeSectionsStatus,

    final StartingSetting? startingSetting ,
  }) {
    return HomeState(
      getStartingSettingsStatus: getStartingSettingsStatus ??
          this.getStartingSettingsStatus,
      getMainCategoriesStatus: getMainCategoriesStatus ??
          this.getMainCategoriesStatus,
      getHomeSectionsStatus: getHomeSectionsStatus ??
          this.getHomeSectionsStatus,
        startingSetting : startingSetting ?? this.startingSetting
    );
  }
}
