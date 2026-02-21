import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'dart:convert';
GetFullProductDetailsModel getFullProductDetailsModelFromJson(String str) => GetFullProductDetailsModel.fromJson(json.decode(str));

String getFullProductDetailsModelToJson(GetFullProductDetailsModel data) => json.encode(data.toJson());

class GetFullProductDetailsModel {
  final Products? productItem;
  final GetProductDetailWithoutRelatedProductsModel? getProductDetailWithoutRelatedProductsModel;

  GetFullProductDetailsModel({
    this.productItem,
    this.getProductDetailWithoutRelatedProductsModel,
  });
  GetFullProductDetailsModel copyWith({
    Products? productItem,
    GetProductDetailWithoutRelatedProductsModel? getProductDetailWithoutRelatedProductsModel,
  }) =>
      GetFullProductDetailsModel(
        productItem: productItem ?? this.productItem,
        getProductDetailWithoutRelatedProductsModel: getProductDetailWithoutRelatedProductsModel ?? this.getProductDetailWithoutRelatedProductsModel,
      );

  factory GetFullProductDetailsModel.fromJson(Map<String, dynamic> json) => GetFullProductDetailsModel(
    productItem: json["data"] == null ? null : Products.fromJson(json["data"]),
    getProductDetailWithoutRelatedProductsModel:  GetProductDetailWithoutRelatedProductsModel.fromJson(json),
  );

  Map<String, dynamic> toJson() => {
    "message": productItem?.toJson(),
    "data": getProductDetailWithoutRelatedProductsModel?.toJson(),
  };
}