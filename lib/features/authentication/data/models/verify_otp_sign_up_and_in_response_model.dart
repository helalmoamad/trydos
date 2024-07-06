// To parse this JSON data, do
//
//     final verifyOtpSignUpAndInResponseModel = verifyOtpSignUpAndInResponseModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpSignUpAndInResponseModel verifyOtpSignUpAndInResponseModelFromJson(String str) => VerifyOtpSignUpAndInResponseModel.fromJson(json.decode(str));

String verifyOtpSignUpAndInResponseModelToJson(VerifyOtpSignUpAndInResponseModel data) => json.encode(data.toJson());

class VerifyOtpSignUpAndInResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  VerifyOtpSignUpAndInResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  VerifyOtpSignUpAndInResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      VerifyOtpSignUpAndInResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory VerifyOtpSignUpAndInResponseModel.fromJson(Map<String, dynamic> json) => VerifyOtpSignUpAndInResponseModel(
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
  final bool? alreadyExist;
  final String? idToken;
  final int? userType;
  final String? token;
  final String? expiresAt;
  final User? user;

  Data({
    this.alreadyExist,
    this.idToken,
    this.userType,
    this.token,
    this.expiresAt,
    this.user,
  });

  Data copyWith({
    bool? alreadyExist,
    String? idToken,
    int? userType,
    String? token,
    String? expiresAt,
    User? user,
  }) =>
      Data(
        alreadyExist: alreadyExist ?? this.alreadyExist,
        idToken: idToken ?? this.idToken,
        userType: userType ?? this.userType,
        token: token ?? this.token,
        expiresAt: expiresAt ?? this.expiresAt,
        user: user ?? this.user,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    alreadyExist: json["already_exists"],
    idToken: json["id_token"],
    userType: json["user_type"],
    token: json["token"],
    expiresAt: json["expires_at"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "already_exists": alreadyExist,
    "id_token": idToken,
    "user_type": userType,
    "token": token,
    "expires_at": expiresAt,
    "user": user?.toJson(),
  };
}



class User {
  final int? id;
  final String? name;
  final String? phone;
  final int? isPhoneVerified;
  final String? lastOtpIdToken;

  User({
    this.id,
    this.name,
    this.phone,
    this.isPhoneVerified,
    this.lastOtpIdToken,
  });

  User copyWith({
    int? id,
    String? name,
    String? phone,
    int? isPhoneVerified,
    String? lastOtpIdToken,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
        lastOtpIdToken: lastOtpIdToken ?? this.lastOtpIdToken,
      );

  User userFromJson(String str) => User.fromJson(json.decode(str));

  String userToJson(User data) => json.encode(data.toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
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
