// To parse this JSON data, do
//
//     final verifyOtpFromGuestResponseModel = verifyOtpFromGuestResponseModelFromJson(jsonString);

import 'dart:convert';

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
  final DataUser? user;

  Data({
    this.alreadyExists,
    this.loggedInFromAnotherDevice,
    this.idToken,
    this.userType,
    this.token,
    this.expiresAt,
    this.user,
  });

  Data copyWith({
    bool? alreadyExists,
    bool? loggedInFromAnotherDevice,
    String? idToken,
    int? userType,
    String? token,
    String? expiresAt,
    DataUser? user,
  }) =>
      Data(
        alreadyExists: alreadyExists ?? this.alreadyExists,
        loggedInFromAnotherDevice:
            loggedInFromAnotherDevice ?? this.loggedInFromAnotherDevice,
        idToken: idToken ?? this.idToken,
        userType: userType ?? this.userType,
        token: token ?? this.token,
        expiresAt: expiresAt ?? this.expiresAt,
        user: user ?? this.user,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        alreadyExists: json["already_exists"],
        loggedInFromAnotherDevice: json["Logged_in_from_another_device"],
        idToken: json["id_token"],
        userType: json["user_type"],
        token: json["token"],
        expiresAt: json["expires_at"],
        user: json["user"] == null ? null : DataUser.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "already_exists": alreadyExists,
        "Logged_in_from_another_device": loggedInFromAnotherDevice,
        "id_token": idToken,
        "user_type": userType,
        "token": token,
        "expires_at": expiresAt,
        "user": user?.toJson(),
      };
}

class DataUser {
  final int? id;
  final String? name;
  final String? phone;
  final int? isPhoneVerified;
  final String? lastOtpIdToken;

  DataUser({
    this.id,
    this.name,
    this.phone,
    this.isPhoneVerified,
    this.lastOtpIdToken,
  });

  DataUser copyWith({
    int? id,
    String? name,
    String? phone,
    int? isPhoneVerified,
    String? lastOtpIdToken,
  }) =>
      DataUser(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
        lastOtpIdToken: lastOtpIdToken ?? this.lastOtpIdToken,
      );

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        isPhoneVerified: json["is_phone_verified"],
        lastOtpIdToken: json["last_otp_id_token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "is_phone_verified": isPhoneVerified,
        "last_otp_id_token": lastOtpIdToken,
      };
}
