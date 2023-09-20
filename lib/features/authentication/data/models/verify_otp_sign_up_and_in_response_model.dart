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
  final String? idToken;
  final int? userType;
  final String? token;
  final String? expiresAt;
  final User? user;

  Data({
    this.idToken,
    this.userType,
    this.token,
    this.expiresAt,
    this.user,
  });

  Data copyWith({
    String? idToken,
    int? userType,
    String? token,
    String? expiresAt,
    User? user,
  }) =>
      Data(
        idToken: idToken ?? this.idToken,
        userType: userType ?? this.userType,
        token: token ?? this.token,
        expiresAt: expiresAt ?? this.expiresAt,
        user: user ?? this.user,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idToken: json["id_token"],
    userType: json["user_type"],
    token: json["token"],
    expiresAt: json["expires_at"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
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
  final String? fName;
  final String? lName;
  final String? email;
  final String? deviceId;
  final String? phone;
  final String? countryDialCode;
  final String? gender;
  final String? birthdate;
  final int? isEmailVerified;
  final int? isPhoneVerified;
  final String? temporaryToken;
  final int? walletBalance;
  final String? walletBalanceFormatted;
  final dynamic points;
  final String? image;
  final String? lastOtpIdToken;

  User({
    this.id,
    this.name,
    this.fName,
    this.lName,
    this.email,
    this.deviceId,
    this.phone,
    this.countryDialCode,
    this.gender,
    this.birthdate,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.temporaryToken,
    this.walletBalance,
    this.walletBalanceFormatted,
    this.points,
    this.image,
    this.lastOtpIdToken,
  });

  User copyWith({
    int? id,
    String? name,
    String? fName,
    String? lName,
    String? email,
    String? deviceId,
    String? phone,
    String? countryDialCode,
    String? gender,
    String? birthdate,
    int? isEmailVerified,
    int? isPhoneVerified,
    String? temporaryToken,
    int? walletBalance,
    String? walletBalanceFormatted,
    dynamic points,
    String? image,
    String? lastOtpIdToken,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        fName: fName ?? this.fName,
        lName: lName ?? this.lName,
        email: email ?? this.email,
        deviceId: deviceId ?? this.deviceId,
        phone: phone ?? this.phone,
        countryDialCode: countryDialCode ?? this.countryDialCode,
        gender: gender ?? this.gender,
        birthdate: birthdate ?? this.birthdate,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
        temporaryToken: temporaryToken ?? this.temporaryToken,
        walletBalance: walletBalance ?? this.walletBalance,
        walletBalanceFormatted: walletBalanceFormatted ?? this.walletBalanceFormatted,
        points: points ?? this.points,
        image: image ?? this.image,
        lastOtpIdToken: lastOtpIdToken ?? this.lastOtpIdToken,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    fName: json["f_name"],
    lName: json["l_name"],
    email: json["email"],
    deviceId: json["device_id"],
    phone: json["phone"],
    countryDialCode: json["country_dial_code"],
    gender: json["gender"],
    birthdate: json["birthdate"],
    isEmailVerified: json["is_email_verified"],
    isPhoneVerified: json["is_phone_verified"],
    temporaryToken: json["temporary_token"],
    walletBalance: json["wallet_balance"],
    walletBalanceFormatted: json["wallet_balance_formatted"],
    points: json["points"],
    image: json["image"],
    lastOtpIdToken: json["last_otp_id_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "f_name": fName,
    "l_name": lName,
    "email": email,
    "device_id": deviceId,
    "phone": phone,
    "country_dial_code": countryDialCode,
    "gender": gender,
    "birthdate": birthdate,
    "is_email_verified": isEmailVerified,
    "is_phone_verified": isPhoneVerified,
    "temporary_token": temporaryToken,
    "wallet_balance": walletBalance,
    "wallet_balance_formatted": walletBalanceFormatted,
    "points": points,
    "image": image,
    "last_otp_id_token": lastOtpIdToken,
  };
}
