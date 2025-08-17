import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
//  String noScope() => '$_version/$_cloudinaryName/$this';
}

abstract class WebAppEndPoints {
  static final imageSearchEP = "api/image-search";
  static final mainCategoriesEP = "api/home/mainCategories";
  static final homeBoutiquesEP = "api/home/boutiques";
  static final searchProductEP = "api/products/searchInCatalog";
  static final productFeaturedEP = "api/products/featured";
  static String productDetailsEP(String slug) =>
      "api/mobile/product/details_without_similar_related_products/${slug}";
  //  static final imageSearchEP = "api/image-search";
}

abstract class WebUrls {
  static final String _baseUri = dotenv.env['WEB_APP']!;
  static final String _loadPreset = dotenv.env['WEB_APP']!;

  static Uri get baseUri => Uri.parse(_baseUri);

  static String get LoadPreset => _loadPreset;
}
