// To parse this JSON data, do
//
//     final videoCallRemoteResponseModel = videoCallRemoteResponseModelFromJson(jsonString);

import 'dart:convert';

VideoCallRemoteResponseModel videoCallRemoteResponseModelFromJson(String str) => VideoCallRemoteResponseModel.fromJson(json.decode(str));

String videoCallRemoteResponseModelToJson(VideoCallRemoteResponseModel data) => json.encode(data.toJson());

class VideoCallRemoteResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  dynamic message;
  dynamic detailedError;
  String? data;

  VideoCallRemoteResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  VideoCallRemoteResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    String? data,
  }) =>
      VideoCallRemoteResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory VideoCallRemoteResponseModel.fromJson(Map<String, dynamic> json) => VideoCallRemoteResponseModel(
    isSuccessful: json["isSuccessful"],
    hasContent: json["hasContent"],
    code: json["code"],
    message: json["message"],
    detailedError: json["detailed_error"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "hasContent": hasContent,
    "code": code,
    "message": message,
    "detailed_error": detailedError,
    "data": data,
  };
}
