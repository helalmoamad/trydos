// To parse this JSON data, do
//
//     final storeReturnRequestProductModel = storeReturnRequestProductModelFromJson(jsonString);

import 'dart:convert';

ConfirmCancelReturnRequestModel storeReturnRequestProductModelFromJson(
        String str) =>
    ConfirmCancelReturnRequestModel.fromJson(json.decode(str));

String storeReturnRequestProductModelToJson(
        ConfirmCancelReturnRequestModel data) =>
    json.encode(data.toJson());

class ConfirmCancelReturnRequestModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;

  ConfirmCancelReturnRequestModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
  });

  ConfirmCancelReturnRequestModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
  }) =>
      ConfirmCancelReturnRequestModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
      );

  factory ConfirmCancelReturnRequestModel.fromJson(Map<String, dynamic> json) =>
      ConfirmCancelReturnRequestModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"] ?? json["data"],
        detailedError: json["detailed_error"],
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
      };
}
