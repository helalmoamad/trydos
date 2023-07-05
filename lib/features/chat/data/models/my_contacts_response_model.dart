// To parse this JSON data, do
//
//     final myContactsResponseModel = myContactsResponseModelFromJson(jsonString);

import 'dart:convert';

MyContactsResponseModel myContactsResponseModelFromJson(String str) => MyContactsResponseModel.fromJson(json.decode(str));

String myContactsResponseModelToJson(MyContactsResponseModel data) => json.encode(data.toJson());

class MyContactsResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  String? message;
  String? detailedError;
  List<Contact>? contacts;

  MyContactsResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.contacts,
  });

  factory MyContactsResponseModel.fromJson(Map<String, dynamic> json) => MyContactsResponseModel(
    isSuccessful: json["isSuccessful"],
    hasContent: json["hasContent"],
    code: json["code"],
    message: json["message"],
    detailedError: json["detailed_error"],
    contacts: json["data"] == null ? [] : List<Contact>.from(json["data"]!.map((x) => Contact.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "hasContent": hasContent,
    "code": code,
    "message": message,
    "detailed_error": detailedError,
    "data": contacts == null ? [] : List<dynamic>.from(contacts!.map((x) => x.toJson())),
  };
}

class Contact {
  int? id;
  int? userId;
  String? name;
  String? mobilePhone;
  int? contactUserId;
  ContactUser? contactUser;

  Contact({
    this.id,
    this.userId,
    this.name,
    this.mobilePhone,
    this.contactUserId,
    this.contactUser,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json["id"],
    userId: json["user_id"],
    name: json["name"],
    mobilePhone: json["mobile_phone"],
    contactUserId: json["contact_user_id"],
    contactUser: json["contact_user"] == null ? null : ContactUser.fromJson(json["contact_user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "mobile_phone": mobilePhone,
    "contact_user_id": contactUserId,
    "contact_user": contactUser?.toJson(),
  };
}

class ContactUser {
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

  ContactUser({
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
  });

  factory ContactUser.fromJson(Map<String, dynamic> json) => ContactUser(
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
  };
}
