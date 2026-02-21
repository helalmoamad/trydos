// To parse this JSON data, do
//
//     final deleteStoryModel = deleteStoryModelFromJson(jsonString);

import 'dart:convert';

DeleteStoryModel deleteStoryModelFromJson(String str) =>
    DeleteStoryModel.fromJson(json.decode(str));

String deleteStoryModelToJson(DeleteStoryModel data) =>
    json.encode(data.toJson());

class DeleteStoryModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  DeleteStoryModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  DeleteStoryModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      DeleteStoryModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory DeleteStoryModel.fromJson(Map<String, dynamic> json) =>
      DeleteStoryModel(
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
  final int? success;
  final String? message;

  Data({
    this.success,
    this.message,
  });

  Data copyWith({
    int? success,
    String? message,
  }) =>
      Data(
        success: success ?? this.success,
        message: message ?? this.message,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
