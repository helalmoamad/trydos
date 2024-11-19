// To parse this JSON data, do
//
//     final readOnlyMessageFromApiModel = readOnlyMessageFromApiModelFromJson(jsonString);

import 'dart:convert';

ReadOnlyMessageFromApiModel readOnlyMessageFromApiModelFromJson(String str) =>
    ReadOnlyMessageFromApiModel.fromJson(json.decode(str));

String readOnlyMessageFromApiModelToJson(ReadOnlyMessageFromApiModel data) =>
    json.encode(data.toJson());

class ReadOnlyMessageFromApiModel {
  final String? message;

  ReadOnlyMessageFromApiModel({
    this.message,
  });

  ReadOnlyMessageFromApiModel copyWith({
    String? message,
  }) =>
      ReadOnlyMessageFromApiModel(
        message: message ?? this.message,
      );

  factory ReadOnlyMessageFromApiModel.fromJson(Map<String, dynamic> json) =>
      ReadOnlyMessageFromApiModel(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
