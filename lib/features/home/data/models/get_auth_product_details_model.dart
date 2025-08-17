// To parse this JSON data, do
//
//     final getAuthProductDetailsModel = getAuthProductDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';

GetAuthProductDetailsModel getAuthProductDetailsModelFromJson(String str) =>
    GetAuthProductDetailsModel.fromJson(json.decode(str));

String getAuthProductDetailsModelToJson(GetAuthProductDetailsModel data) =>
    json.encode(data.toJson());

class GetAuthProductDetailsModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetAuthProductDetailsModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetAuthProductDetailsModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      GetAuthProductDetailsModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetAuthProductDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetAuthProductDetailsModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data?.toJson(),
      };
}

class Data {
  final int? id;
  // final List<Variation>? variation;
  final bool? isLiked;

  Data({
    this.id,
    //   this.variation,
    this.isLiked,
  });

  Data copyWith({
    int? id,
    //  List<Variation>? variation,
    bool? isLiked,
  }) =>
      Data(
        id: id ?? this.id,
        //     variation: variation ?? this.variation,
        isLiked: isLiked ?? this.isLiked,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        /*    variation: json["variation"] == null
            ? []
            : List<Variation>.from(
                json["variation"]!.map((x) => Variation.fromJson(x))),*/
        isLiked: json["is_liked"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        /*  "variation": variation == null
            ? []
            : List<dynamic>.from(variation!.map((x) => x.toJson())),*/
        "is_liked": isLiked,
      };
}
