// To parse this JSON data, do
//
//     final storeReturnRequestProductModel = storeReturnRequestProductModelFromJson(jsonString);

import 'dart:convert';

UpdateConfirmCancelReturnRequestModel storeReturnRequestProductModelFromJson(
        String str) =>
    UpdateConfirmCancelReturnRequestModel.fromJson(json.decode(str));

String storeReturnRequestProductModelToJson(
        UpdateConfirmCancelReturnRequestModel data) =>
    json.encode(data.toJson());

class UpdateConfirmCancelReturnRequestModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;

  UpdateConfirmCancelReturnRequestModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
  });

  UpdateConfirmCancelReturnRequestModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
  }) =>
      UpdateConfirmCancelReturnRequestModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
      );

  factory UpdateConfirmCancelReturnRequestModel.fromJson(
          Map<String, dynamic> json) =>
      UpdateConfirmCancelReturnRequestModel(
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
