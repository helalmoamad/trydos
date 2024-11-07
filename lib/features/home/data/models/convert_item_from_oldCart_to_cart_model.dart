// To parse this JSON data, do
//
//     final convertItemFromOldCartToCartModel = convertItemFromOldCartToCartModelFromJson(jsonString);

import 'dart:convert';

ConvertItemFromOldCartToCartModel convertItemFromOldCartToCartModelFromJson(
        String str) =>
    ConvertItemFromOldCartToCartModel.fromJson(json.decode(str));

String convertItemFromOldCartToCartModelToJson(
        ConvertItemFromOldCartToCartModel data) =>
    json.encode(data.toJson());

class ConvertItemFromOldCartToCartModel {
  final Message? message;
  final Data? data;

  ConvertItemFromOldCartToCartModel({
    this.message,
    this.data,
  });

  ConvertItemFromOldCartToCartModel copyWith({
    Message? message,
    Data? data,
  }) =>
      ConvertItemFromOldCartToCartModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ConvertItemFromOldCartToCartModel.fromJson(
          Map<String, dynamic> json) =>
      ConvertItemFromOldCartToCartModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Data {
  final int? id;
  final double? offerPrice;

  Data({
    this.id,
    this.offerPrice,
  });

  Data copyWith({
    int? id,
    double? offerPrice,
  }) =>
      Data(
        id: id ?? this.id,
        offerPrice: offerPrice ?? this.offerPrice,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        offerPrice: double.tryParse(json["offer_price"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "offer_price": offerPrice,
      };
}

class Message {
  final String? message;

  Message({
    this.message,
  });

  Message copyWith({
    String? message,
  }) =>
      Message(
        message: message ?? this.message,
      );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
