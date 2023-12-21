// To parse this JSON data, do
//
//     final loginToStoriesResponseModel = loginToStoriesResponseModelFromJson(jsonString);

import 'dart:convert';

LoginToStoriesResponseModel loginToStoriesResponseModelFromJson(String str) => LoginToStoriesResponseModel.fromJson(json.decode(str));

String loginToStoriesResponseModelToJson(LoginToStoriesResponseModel data) => json.encode(data.toJson());

class LoginToStoriesResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  LoginToStoriesResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  LoginToStoriesResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      LoginToStoriesResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory LoginToStoriesResponseModel.fromJson(Map<String, dynamic> json) => LoginToStoriesResponseModel(
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
  final String? mobilePhone;
  final dynamic name;
  final dynamic username;
  final dynamic originalUserId;
  final dynamic photoPath;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;
  final String? accessToken;

  Data({
    this.mobilePhone,
    this.name,
    this.username,
    this.originalUserId,
    this.photoPath,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.accessToken,
  });

  Data copyWith({
    String? mobilePhone,
    dynamic name,
    dynamic username,
    dynamic originalUserId,
    dynamic photoPath,
    DateTime? updatedAt,
    DateTime? createdAt,
    int? id,
    String? accessToken,
  }) =>
      Data(
        mobilePhone: mobilePhone ?? this.mobilePhone,
        name: name ?? this.name,
        username: username ?? this.username,
        originalUserId: originalUserId ?? this.originalUserId,
        photoPath: photoPath ?? this.photoPath,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        id: id ?? this.id,
        accessToken: accessToken ?? this.accessToken,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    mobilePhone: json["mobile_phone"],
    name: json["name"],
    username: json["username"],
    originalUserId: json["original_user_id"],
    photoPath: json["photo_path"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
    accessToken: json["access_token"],
  );

  Map<String, dynamic> toJson() => {
    "mobile_phone": mobilePhone,
    "name": name,
    "username": username,
    "original_user_id": originalUserId,
    "photo_path": photoPath,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
    "access_token": accessToken,
  };
}
