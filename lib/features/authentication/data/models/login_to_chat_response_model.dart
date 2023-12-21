
import 'dart:convert';

LoginToChatResponseModel loginUserResponseModelFromJson(String str) => LoginToChatResponseModel.fromJson(json.decode(str));

String loginToChatResponseModel(LoginToChatResponseModel data) => json.encode(data.toJson());

class LoginToChatResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  String? message;
  dynamic detailedError;
  Data? data;

  LoginToChatResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  factory LoginToChatResponseModel.fromJson(Map<String, dynamic> json) => LoginToChatResponseModel(
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
  int? id;
  String? mobilePhone;
  dynamic photoPath;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? isLockedByAdminForDelete;
  int? isLockedByAdminForUpdate;
  String? name;
  dynamic username;
  String? accessToken;
  dynamic refreshToken;

  Data({
    this.id,
    this.mobilePhone,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.name,
    this.username,
    this.accessToken,
    this.refreshToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    mobilePhone: json["mobile_phone"],
    photoPath: json["photo_path"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
    isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
    name: json["name"],
    username: json["username"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mobile_phone": mobilePhone,
    "photo_path": photoPath,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
    "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
    "name": name,
    "username": username,
    "access_token": accessToken,
    "refresh_token": refreshToken,
  };
}
