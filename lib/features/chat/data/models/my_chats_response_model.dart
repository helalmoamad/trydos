// To parse this JSON data, do
//
//     final myChatsResponseModel = myChatsResponseModelFromJson(jsonString);

import 'dart:convert';

MyChatsResponseModel myChatsResponseModelFromJson(String str) => MyChatsResponseModel.fromJson(json.decode(str));

String myChatsResponseModelToJson(MyChatsResponseModel data) => json.encode(data.toJson());

class MyChatsResponseModel {
  String? name;
  String? mobilePhone;
  String? password;

  MyChatsResponseModel({
    this.name,
    this.mobilePhone,
    this.password,
  });

  factory MyChatsResponseModel.fromJson(Map<String, dynamic> json) => MyChatsResponseModel(
    name: json["name"],
    mobilePhone: json["mobile_phone"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "mobile_phone": mobilePhone,
    "password": password,
  };
}
