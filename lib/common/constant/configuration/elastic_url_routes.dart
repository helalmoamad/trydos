import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _api => 'api';

  String get _previousVersion => 'v1';

  String get _currentVersion => 'v2';

  String noScope({bool current = false}) => '$_api/$this';

  String elasticScope() => '$_api/products/$this';
}

abstract class ElasticEndPoints {
  static final searchWithFilterElasticEP = 'products'.elasticScope();
  static final searchWithoutFilterElasticEP = 'products'.elasticScope();
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
