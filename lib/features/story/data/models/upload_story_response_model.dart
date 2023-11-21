// To parse this JSON data, do
//
//     final uploadStoryResponseModel = uploadStoryResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';

UploadStoryResponseModel uploadStoryResponseModelFromJson(String str) => UploadStoryResponseModel.fromJson(json.decode(str));

String uploadStoryResponseModelToJson(UploadStoryResponseModel data) => json.encode(data.toJson());

class UploadStoryResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  dynamic message;
  dynamic detailedError;
  Story? data;

  UploadStoryResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  UploadStoryResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Story? data,
  }) =>
      UploadStoryResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory UploadStoryResponseModel.fromJson(Map<String, dynamic> json) {

//    Fluttertoast.showToast(msg: json.toString());
    return  UploadStoryResponseModel(
      isSuccessful: json["isSuccessful"],
      hasContent: json["hasContent"],
      code: json["code"],
      message: json["message"],
      detailedError: json["detailed_error"],
      data: json["data"] == null ? null : Story.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "hasContent": hasContent,
    "code": code,
    "message": message,
    "detailed_error": detailedError,
    "data": data?.toJson(),
  };
}

