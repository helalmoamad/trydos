// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ConvertItemFromCartToOldCartModel ConvertItemFromCartToOldCartFromJson(
        String str) =>
    ConvertItemFromCartToOldCartModel.fromJson(json.decode(str));

String ConvertItemFromCartToOldCartToJson(
        ConvertItemFromCartToOldCartModel data) =>
    json.encode(data.toJson());

class ConvertItemFromCartToOldCartModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final List<dynamic>? data;

  ConvertItemFromCartToOldCartModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  ConvertItemFromCartToOldCartModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    List<dynamic>? data,
  }) =>
      ConvertItemFromCartToOldCartModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory ConvertItemFromCartToOldCartModel.fromJson(
          Map<String, dynamic> json) =>
      ConvertItemFromCartToOldCartModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null
            ? []
            : List<dynamic>.from(json["data"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
      };
}
