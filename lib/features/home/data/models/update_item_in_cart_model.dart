// To parse this JSON data, do
//
//     final updateItemInCartModel = updateItemInCartModelFromJson(jsonString);

import 'dart:convert';

UpdateItemInCartModel updateItemInCartModelFromJson(String str) =>
    UpdateItemInCartModel.fromJson(json.decode(str));

String updateItemInCartModelToJson(UpdateItemInCartModel data) =>
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
  final int? qty;

  Data({
    this.qty,
  });

  Data copyWith({
    int? qty,
  }) =>
      Data(
        qty: qty ?? this.qty,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
        "qty": qty,
      };
}
