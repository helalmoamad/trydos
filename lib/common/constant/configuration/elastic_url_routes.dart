import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _previousVersion => 'v1';

  String get _currentVersion => 'v2';

  String noScope({bool current = false}) => '$_api/$this';

  String productsScope() => '$_api/products/$this';
  String homeScope() => '$_api/home/$this';
  String addressesScope() => '$_api/addresses/$this';
}

abstract class ElasticEndPoints {
  static final getPopularSearchTermsEP = 'popular-search'.productsScope();
  static final searchWithFilterElasticEP = 'searchInCatalog'.productsScope();
  static final getFeaturedProductEP = 'featured'.productsScope();
  static final searchWithoutFilterElasticEP = 'searchInCatalog'.productsScope();
  static final getAndAddCountViewOfProductEP = 'view'.productsScope();
  static final getMainCategoriesEP = "mainCategories".homeScope();
  static final getHomeBoutiquesEP = "boutiques".homeScope();
  static final getAddressByTextEP = "get-address-by-text".addressesScope();
  static final getProvincesByIsoEP = "get-provinces-by-iso".addressesScope();
  static final countryBoundaryByIsoEP =
      "CountryBoundaryByIso/${GetIt.I<PrefsRepository>().userCountryIsAvailable == 1 ? GetIt.I<PrefsRepository>().userChoosedCountryIso : GetIt.I<PrefsRepository>().countryIso}"
          .addressesScope();
  static final getAddressByCoordinatesEP =
      "get-address-by-coordinates".addressesScope();
}

abstract class ElasticUrls {
  static String get baseUrl => _baseUrlDev;

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);
  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['ELASTIC_URL']!;
  static const String _baseUrlDevWithHttp =
      'https://recomende_elasticsearch_engin.trydos.dev';
}
