// To parse this JSON data, do
//
//     final createReturnReqestModel = createReturnReqestModelFromJson(jsonString);

import 'dart:convert';

CreateReturnReqestModel createReturnReqestModelFromJson(String str) =>
    CreateReturnReqestModel.fromJson(json.decode(str));

String createReturnReqestModelToJson(CreateReturnReqestModel data) =>
    json.encode(data.toJson());

class CreateReturnReqestModel {
  final bool? isSuccessful;
  final int? code;
  final String? message;
  final Data? data;

  CreateReturnReqestModel({
    this.isSuccessful,
    this.code,
    this.message,
    this.data,
  });

  CreateReturnReqestModel copyWith({
    bool? isSuccessful,
    int? code,
    String? message,
    Data? data,
  }) =>
      CreateReturnReqestModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        code: code ?? this.code,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CreateReturnReqestModel.fromJson(Map<String, dynamic> json) =>
      CreateReturnReqestModel(
        isSuccessful: json["isSuccessful"],
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "code": code,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final int? returnRequestId;

  Data({
    this.returnRequestId,
  });

  Data copyWith({
    int? returnRequestId,
  }) =>
      Data(
        returnRequestId: returnRequestId ?? this.returnRequestId,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        returnRequestId: json["return_request_id"],
      );

  Map<String, dynamic> toJson() => {
        "return_request_id": returnRequestId,
      };
}
