import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

class RelatedProductsResponse {
  final RelatedProductsData data;
  final bool isSuccessful;
  final int code;

  RelatedProductsResponse({
    required this.data,
    required this.isSuccessful,
    required this.code,
  });

  factory RelatedProductsResponse.fromJson(Map<String, dynamic> json) {
    return RelatedProductsResponse(
      data: RelatedProductsData.fromJson(json['data']),
      isSuccessful: json['isSuccessful'],
      code: json['code'],
    );
  }
}

class RelatedProductsData {
  final List<Products> products;
  final List<int> offset;
  final int totalSize;

  RelatedProductsData({
    required this.products,
    required this.offset,
    required this.totalSize,
  });

  factory RelatedProductsData.fromJson(Map<String, dynamic> json) {
    return RelatedProductsData(
      products: (json['products'] as List)
          .map((e) => Products.fromJson(e))
          .toList(),
      offset: (json['offset'] as List).map((e) => (e as num).toInt()).toList(),
      totalSize: json['total_size'],
    );
  }
}
