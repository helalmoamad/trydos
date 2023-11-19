

import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';

import '../../../../common/constant/configuration/market_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/detect_server.dart';

@injectable
class HomeRemoteDatasource {

  Future<StartingSettingsResponseModel> getStartingSettings() {
    GetClient<StartingSettingsResponseModel> getStartingSettings = GetClient<
        StartingSettingsResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<StartingSettingsResponseModel>(
        endpoint: MarketEndPoints.getStartingSettingsEP,
        response: ResponseValue<StartingSettingsResponseModel>(
            fromJson: (response) => StartingSettingsResponseModel.fromJson(response)
        ),
      ),
    );
    return getStartingSettings();
  }
  Future<MainCategoriesResponseModel> getMainCategories() {
    GetClient<MainCategoriesResponseModel> getMainCategories = GetClient<
        MainCategoriesResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<MainCategoriesResponseModel>(
        endpoint: MarketEndPoints.getMainCategoriesEP,
        response: ResponseValue<MainCategoriesResponseModel>(
            fromJson: (response) => MainCategoriesResponseModel.fromJson(response)
        ),
      ),
    );
    return getMainCategories();
  }
  Future<HomeSectionResponseModel> getHomeSections(Map<String , dynamic> params) {
    GetClient<HomeSectionResponseModel> getHomeSections = GetClient<
        HomeSectionResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<HomeSectionResponseModel>(
        endpoint: MarketEndPoints.getHomeSectionsEP,
        queryParameters: params,
        response: ResponseValue<HomeSectionResponseModel>(
            fromJson: (response) => HomeSectionResponseModel.fromJson(response)
        ),
      ),
    );
    return getHomeSections();
  }
}