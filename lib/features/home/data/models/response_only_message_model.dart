// To parse this JSON data, do
//
//     final responseOnlyMessageModel = responseOnlyMessageModelFromJson(jsonString);

import 'dart:convert';

ResponseOnlyMessageModel responseOnlyMessageModelFromJson(String str) =>
    ResponseOnlyMessageModel.fromJson(json.decode(str));

String responseOnlyMessageModelToJson(ResponseOnlyMessageModel data) =>
    json.encode(data.toJson());

class ResponseOnlyMessageModel {
  final String? message;

  ResponseOnlyMessageModel({
    this.message,
  });

  ResponseOnlyMessageModel copyWith({
    String? message,
  }) =>
      ResponseOnlyMessageModel(
        message: message ?? this.message,
      );

  factory ResponseOnlyMessageModel.fromJson(Map<String, dynamic> json) =>
      ResponseOnlyMessageModel(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
