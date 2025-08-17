// To parse this JSON data, do
//
//     final uploadUserPhotoModel = uploadUserPhotoModelFromJson(jsonString);

import 'dart:convert';

UploadImagesForReturnProductModel uploadImagesForReturnProductModelFromJson(
        String str) =>
    UploadImagesForReturnProductModel.fromJson(json.decode(str));

String uploadImagesForReturnProductModelToJson(
        UploadImagesForReturnProductModel data) =>
    json.encode(data.toJson());

class UploadImagesForReturnProductModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  UploadImagesForReturnProductModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  UploadImagesForReturnProductModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      UploadImagesForReturnProductModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory UploadImagesForReturnProductModel.fromJson(
          Map<String, dynamic> json) =>
      UploadImagesForReturnProductModel(
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
