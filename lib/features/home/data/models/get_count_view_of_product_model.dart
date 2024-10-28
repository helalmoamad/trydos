// To parse this JSON data, do
//
//     final getCountViewOfProductModel = getCountViewOfProductModelFromJson(jsonString);

import 'dart:convert';

GetCountViewOfProductModel getCountViewOfProductModelFromJson(String str) =>
    GetCountViewOfProductModel.fromJson(json.decode(str));

String getCountViewOfProductModelToJson(GetCountViewOfProductModel data) =>
    json.encode(data.toJson());

class GetCountViewOfProductModel {
  final int? viewCount;
  final String? message;

  GetCountViewOfProductModel({
    this.viewCount,
    this.message,
  });

  GetCountViewOfProductModel copyWith({
    int? viewCount,
    String? message,
  }) =>
      GetCountViewOfProductModel(
        viewCount: viewCount ?? this.viewCount,
        message: message ?? this.message,
      );

  factory GetCountViewOfProductModel.fromJson(Map<String, dynamic> json) =>
      GetCountViewOfProductModel(
        viewCount: json["view_count"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "view_count": viewCount,
        "message": message,
      };
}
