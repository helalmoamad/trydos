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
  final String? response;
  ReadOnlyMessageFromApiModel({this.message, this.response});

  ReadOnlyMessageFromApiModel copyWith({String? message, String? response}) =>
      ReadOnlyMessageFromApiModel(
        message: message ?? this.message,
        response: response ?? this.response,
      );

  factory ReadOnlyMessageFromApiModel.fromJson(Map<String, dynamic> json) =>
      ReadOnlyMessageFromApiModel(
        message: json["message"] == null ? json["detail"] : json["message"],
        response: json["response"],
      );

  Map<String, dynamic> toJson() => {"message": message, "response": response};
}
