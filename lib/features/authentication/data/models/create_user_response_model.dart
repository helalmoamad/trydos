
import 'dart:convert';

CreateUserResponseModel createUserResponseModelFromJson(String str) => CreateUserResponseModel.fromJson(json.decode(str));

String createUserResponseModelToJson(CreateUserResponseModel data) => json.encode(data.toJson());

class CreateUserResponseModel {
  String mobilePhone;
  String? name;
  String? username;
  DateTime? updatedAt;
  DateTime? createdAt;
  int id;

  CreateUserResponseModel({
    required this.mobilePhone,
    this.name,
    this.username,
    this.updatedAt,
    this.createdAt,
    required this.id,
  });

  factory CreateUserResponseModel.fromJson(Map<String, dynamic> json) => CreateUserResponseModel(
    mobilePhone: json["mobile_phone"],
    name: json["name"],
    username: json["username"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "mobile_phone": mobilePhone,
    "name": name,
    "username": username,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}
