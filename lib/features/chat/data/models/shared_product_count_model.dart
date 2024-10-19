// To parse this JSON data, do
//
//     final getSharedProductCountModel = getSharedProductCountModelFromJson(jsonString);

import 'dart:convert';

GetSharedProductCountModel getSharedProductCountModelFromJson(String str) =>
    GetSharedProductCountModel.fromJson(json.decode(str));

String getSharedProductCountModelToJson(GetSharedProductCountModel data) =>
    json.encode(data.toJson());

class GetSharedProductCountModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  GetSharedProductCountModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetSharedProductCountModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      GetSharedProductCountModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetSharedProductCountModel.fromJson(Map<String, dynamic> json) =>
      GetSharedProductCountModel(
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
  final String? productId;
  final int? sharedCount;

  Data({
    this.productId,
    this.sharedCount,
  });

  Data copyWith({
    String? productId,
    int? sharedCount,
  }) =>
      Data(
        productId: productId ?? this.productId,
        sharedCount: sharedCount ?? this.sharedCount,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        productId: json["product_id"],
        sharedCount: json["shared_count"],
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "shared_count": sharedCount,
      };
}
