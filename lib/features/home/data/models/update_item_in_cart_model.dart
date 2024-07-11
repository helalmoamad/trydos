// To parse this JSON data, do
//
//     final updateItemInCartModel = updateItemInCartModelFromJson(jsonString);
import 'dart:convert';

UpdateItemInCartModel addItemToCartModelFromJson(String str) =>
    UpdateItemInCartModel.fromJson(json.decode(str));

String addItemToCartModelToJson(UpdateItemInCartModel data) =>
    json.encode(data.toJson());

class UpdateItemInCartModel {
  final String? message;
  final Data? data;

  UpdateItemInCartModel({
    this.message,
    this.data,
  });

  UpdateItemInCartModel copyWith({
    String? message,
    Data? data,
  }) =>
      UpdateItemInCartModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory UpdateItemInCartModel.fromJson(Map<String, dynamic> json) =>
      UpdateItemInCartModel(
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
