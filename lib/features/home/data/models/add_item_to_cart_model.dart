// To parse this JSON data, do
//
//     final addItemToCartModel = addItemToCartModelFromJson(jsonString);

import 'dart:convert';

AddItemToCartModel addItemToCartModelFromJson(String str) =>
    AddItemToCartModel.fromJson(json.decode(str));

String addItemToCartModelToJson(AddItemToCartModel data) =>
    json.encode(data.toJson());

class AddItemToCartModel {
  final String? message;
  final Data? data;

  AddItemToCartModel({
    this.message,
    this.data,
  });

  AddItemToCartModel copyWith({
    String? message,
    Data? data,
  }) =>
      AddItemToCartModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory AddItemToCartModel.fromJson(Map<String, dynamic> json) =>
      AddItemToCartModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final int? idCart;

  Data({
    this.idCart,
  });

  Data copyWith({
    int? idCart,
  }) =>
      Data(
        idCart: idCart ?? this.idCart,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        idCart: json["id_cart"],
      );

  Map<String, dynamic> toJson() => {
        "id_cart": idCart,
      };
}
