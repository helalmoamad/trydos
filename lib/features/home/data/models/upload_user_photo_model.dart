// To parse this JSON data, do
//
//     final uploadUserPhotoModel = uploadUserPhotoModelFromJson(jsonString);

import 'dart:convert';

UploadUserPhotoModel uploadUserPhotoModelFromJson(String str) =>
    UploadUserPhotoModel.fromJson(json.decode(str));

String uploadUserPhotoModelToJson(UploadUserPhotoModel data) =>
    json.encode(data.toJson());

class UploadUserPhotoModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  UploadUserPhotoModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  UploadUserPhotoModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      UploadUserPhotoModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory UploadUserPhotoModel.fromJson(Map<String, dynamic> json) =>
      UploadUserPhotoModel(
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
  final String? subPath;

  Data({
    this.subPath,
  });

  Data copyWith({
    String? subPath,
  }) =>
      Data(
        subPath: subPath ?? this.subPath,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        subPath: json["sub_path"],
      );

  Map<String, dynamic> toJson() => {
        "sub_path": subPath,
      };
}
