// To parse this JSON data, do
//
//     final listOfProductsFoundedInCartModel = listOfProductsFoundedInCartModelFromJson(jsonString);

import 'dart:convert';

import 'get_product_listing_without_filters_model.dart';

ListOfProductsFoundedInCartModel listOfProductsFoundedInCartModelFromJson(
        String str) =>
    ListOfProductsFoundedInCartModel.fromJson(json.decode(str));

String listOfProductsFoundedInCartModelToJson(
        ListOfProductsFoundedInCartModel data) =>
    json.encode(data.toJson());

class ListOfProductsFoundedInCartModel {
  final String? message;
  final List<Products>? data;

  ListOfProductsFoundedInCartModel({
    this.message,
    this.data,
  });

  ListOfProductsFoundedInCartModel copyWith({
    String? message,
    List<Products>? data,
  }) =>
      ListOfProductsFoundedInCartModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ListOfProductsFoundedInCartModel.fromJson(
          Map<String, dynamic> json) =>
      ListOfProductsFoundedInCartModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Products>.from(
                json["data"]!.map((x) => Products.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
