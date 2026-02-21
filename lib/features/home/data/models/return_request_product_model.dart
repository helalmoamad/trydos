// To parse this JSON data, do
//
//     final storeReturnRequestProductModel = storeReturnRequestProductModelFromJson(jsonString);

import 'dart:convert';

StoreReturnRequestProductModel storeReturnRequestProductModelFromJson(
        String str) =>
    StoreReturnRequestProductModel.fromJson(json.decode(str));

String storeReturnRequestProductModelToJson(
        StoreReturnRequestProductModel data) =>
    json.encode(data.toJson());

class StoreReturnRequestProductModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;

  StoreReturnRequestProductModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
  });

  StoreReturnRequestProductModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
  }) =>
      StoreReturnRequestProductModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
      );

  factory StoreReturnRequestProductModel.fromJson(Map<String, dynamic> json) =>
      StoreReturnRequestProductModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "detailed_error": detailedError,
        "data": message
      };
}
