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
        data: json["data"] == null || json["data"] == ""
            ? null
            : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final int? idCart;
  final int? status;

  Data({
    this.idCart,
    this.status,
  });

  Data copyWith({
    int? idCart,
    int? status,
  }) =>
      Data(
        idCart: idCart ?? this.idCart,
        status: status ?? this.status,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        idCart: json["id_cart"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id_cart": idCart,
        "status": status,
      };
}
