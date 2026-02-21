// To parse this JSON data, do
//
//     final sendOtpResponseModel = sendOtpResponseModelFromJson(jsonString);

import 'dart:convert';

SendOtpResponseModel sendOtpResponseModelFromJson(String str) => SendOtpResponseModel.fromJson(json.decode(str));

String sendOtpResponseModelToJson(SendOtpResponseModel data) => json.encode(data.toJson());

class SendOtpResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  SendOtpResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  SendOtpResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      SendOtpResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SendOtpResponseModel &&
        other.isSuccessful == isSuccessful &&
        other.hasContent == hasContent &&
        other.code == code &&
        other.message == message &&
        other.detailedError == detailedError &&
        other.data == data;
  }


  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) => SendOtpResponseModel(
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
  final String? verificationId;

  Data({
    this.verificationId,
  });

  Data copyWith({
    String? verificationId,
  }) =>
      Data(
        verificationId: verificationId ?? this.verificationId,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    verificationId: json["verificationId"],
  );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Data && other.verificationId == verificationId;
  }

  Map<String, dynamic> toJson() => {
    "verificationId": verificationId,
  };
}
