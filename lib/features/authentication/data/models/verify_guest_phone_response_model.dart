// To parse this JSON data, do
//
//     final verifyOtpFromGuestResponseModel = verifyOtpFromGuestResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';

VerifyOtpFromGuestResponseModel verifyOtpFromGuestResponseModelFromJson(
        String str) =>
    VerifyOtpFromGuestResponseModel.fromJson(json.decode(str));

String verifyOtpFromGuestResponseModelToJson(
        VerifyOtpFromGuestResponseModel data) =>
    json.encode(data.toJson());

class VerifyOtpFromGuestResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  VerifyOtpFromGuestResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  VerifyOtpFromGuestResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      VerifyOtpFromGuestResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory VerifyOtpFromGuestResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyOtpFromGuestResponseModel(
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
  final bool? alreadyExists;
  final bool? loggedInFromAnotherDevice;
  final String? idToken;
  final int? userType;
  final String? token;
  final String? expiresAt;

  /// Single-use refresh token (30d TTL) returned alongside the access token;
  /// must replace the stored one whenever a new pair is issued.
  final String? refreshToken;
  final User? user;

  Data({
    this.alreadyExists,
    this.loggedInFromAnotherDevice,
    this.idToken,
    this.userType,
    this.token,
    this.expiresAt,
    this.refreshToken,
    this.user,
  });

  Data copyWith({
    bool? alreadyExists,
    bool? loggedInFromAnotherDevice,
    String? idToken,
    int? userType,
    String? token,
    String? expiresAt,
    String? refreshToken,
    User? user,
  }) =>
      Data(
        alreadyExists: alreadyExists ?? this.alreadyExists,
        loggedInFromAnotherDevice:
            loggedInFromAnotherDevice ?? this.loggedInFromAnotherDevice,
        idToken: idToken ?? this.idToken,
        userType: userType ?? this.userType,
        token: token ?? this.token,
        expiresAt: expiresAt ?? this.expiresAt,
        refreshToken: refreshToken ?? this.refreshToken,
        user: user ?? this.user,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        alreadyExists: json["already_exists"],
        loggedInFromAnotherDevice: json["Logged_in_from_another_device"],
        idToken: json["id_token"],
        userType: json["user_type"],
        token: json["token"],
        expiresAt: json["expires_at"],
        refreshToken: json["refresh_token"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "already_exists": alreadyExists,
        "Logged_in_from_another_device": loggedInFromAnotherDevice,
        "id_token": idToken,
        "user_type": userType,
        "token": token,
        "expires_at": expiresAt,
        "refresh_token": refreshToken,
        "user": user?.toJson(),
      };
}
