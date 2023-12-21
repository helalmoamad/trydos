// To parse this JSON data, do
//
//     final verifyOtpResponseModel = verifyOtpResponseModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponseModel verifyOtpResponseModelFromJson(String str) => VerifyOtpResponseModel.fromJson(json.decode(str));

String verifyOtpResponseModelToJson(VerifyOtpResponseModel data) => json.encode(data.toJson());

class VerifyOtpResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  VerifyOtpResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  VerifyOtpResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      VerifyOtpResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) => VerifyOtpResponseModel(
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
  final String? phone;
  final String? idToken;

  Data({
    this.phone,
    this.idToken,
  });

  Data copyWith({
    String? phone,
    String? idToken,
  }) =>
      Data(
        phone: phone ?? this.phone,
        idToken: idToken ?? this.idToken,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    phone: json["phone"],
    idToken: json["id_token"],
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "id_token": idToken,
  };
}
