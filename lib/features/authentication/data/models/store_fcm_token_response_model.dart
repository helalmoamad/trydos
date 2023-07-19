// To parse this JSON data, do
//
//     final storeFcmTokenResponseModel = storeFcmTokenResponseModelFromJson(jsonString);

import 'dart:convert';

StoreFcmTokenResponseModel storeFcmTokenResponseModelFromJson(String str) => StoreFcmTokenResponseModel.fromJson(json.decode(str));

String storeFcmTokenResponseModelToJson(StoreFcmTokenResponseModel data) => json.encode(data.toJson());

class StoreFcmTokenResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  StoreFcmTokenResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  factory StoreFcmTokenResponseModel.fromJson(Map<String, dynamic> json) => StoreFcmTokenResponseModel(
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
  final int? id;
  final int? userId;
  final String? token;
  final String? authToken;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;

  Data({
    this.id,
    this.userId,
    this.token,
    this.authToken,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    userId: json["user_id"],
    token: json["token"],
    authToken: json["auth_token"],
    isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
    isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "token": token,
    "auth_token": authToken,
    "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
    "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
  };
}
