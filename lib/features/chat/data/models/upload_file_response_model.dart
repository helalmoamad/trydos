// To parse this JSON data, do
//
//     final uploadFileResponseModel = uploadFileResponseModelFromJson(jsonString);

import 'dart:convert';

UploadFileResponseModel uploadFileResponseModelFromJson(String str) => UploadFileResponseModel.fromJson(json.decode(str));

String uploadFileResponseModelToJson(UploadFileResponseModel data) => json.encode(data.toJson());

class UploadFileResponseModel {
  const UploadFileResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  factory UploadFileResponseModel.fromJson(Map<String, dynamic> json) => UploadFileResponseModel(
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
  Data({
    this.filePath,
  });

  String? filePath;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    filePath: json["file_path"],
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
  };
}
