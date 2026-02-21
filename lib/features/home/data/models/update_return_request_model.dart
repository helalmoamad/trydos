// To parse this JSON data, do
//
//     final storeReturnRequestProductModel = storeReturnRequestProductModelFromJson(jsonString);

import 'dart:convert';

UpdateReturnRequestModel storeReturnRequestProductModelFromJson(String str) =>
    UpdateReturnRequestModel.fromJson(json.decode(str));

String storeReturnRequestProductModelToJson(UpdateReturnRequestModel data) =>
    json.encode(data.toJson());

class UpdateReturnRequestModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;

  UpdateReturnRequestModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
  });

  UpdateReturnRequestModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
  }) =>
      UpdateReturnRequestModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
      );

  factory UpdateReturnRequestModel.fromJson(Map<String, dynamic> json) =>
      UpdateReturnRequestModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["data"],
        detailedError: json["detailed_error"],
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "data": message,
        "detailed_error": detailedError,
      };
}
