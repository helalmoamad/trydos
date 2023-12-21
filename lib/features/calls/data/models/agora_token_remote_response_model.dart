// To parse this JSON data, do
//
//     final getAgoraTokenResponseModel = getAgoraTokenResponseModelFromJson(jsonString);

import 'dart:convert';

GetAgoraTokenResponseModel getAgoraTokenResponseModelFromJson(String str) => GetAgoraTokenResponseModel.fromJson(json.decode(str));

String getAgoraTokenResponseModelToJson(GetAgoraTokenResponseModel data) => json.encode(data.toJson());

class GetAgoraTokenResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  dynamic message;
  dynamic detailedError;
  String? data;

  GetAgoraTokenResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetAgoraTokenResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    String? data,
  }) =>
      GetAgoraTokenResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetAgoraTokenResponseModel.fromJson(Map<String, dynamic> json) => GetAgoraTokenResponseModel(
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
