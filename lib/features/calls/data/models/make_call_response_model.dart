// To parse this JSON data, do
//
//     final videoCallRemoteResponseModel = videoCallRemoteResponseModelFromJson(jsonString);

import 'dart:convert';

import '../../../chat/data/models/my_chats_response_model.dart';

MakeCallRemoteResponseModel makeCallRemoteResponseModelFromJson(String str) => MakeCallRemoteResponseModel.fromJson(json.decode(str));

String makeCallRemoteResponseModelToJson(MakeCallRemoteResponseModel data) => json.encode(data.toJson());

class MakeCallRemoteResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  dynamic message;
  dynamic detailedError;
  Data? data;

  MakeCallRemoteResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  MakeCallRemoteResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      MakeCallRemoteResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory MakeCallRemoteResponseModel.fromJson(Map<String, dynamic> json) => MakeCallRemoteResponseModel(
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
  Message? message;
  String? token;

  Data({
    this.message,
    this.token,
  });

  Data copyWith({
    Message? message,
    String? token,
  }) =>
      Data(
        message: message ?? this.message,
        token: token ?? this.token,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    message: json["message"] == null ? null : Message.fromJson(json["message"]),
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "message": message?.toJson(),
    "token": token,
  };
}