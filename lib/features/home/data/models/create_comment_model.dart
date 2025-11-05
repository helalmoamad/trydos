// To parse this JSON data, do
//
//     final creatFqaCommentsModel = creatFqaCommentsModelFromJson(jsonString);

import 'dart:convert';

CreateFqaCommentsModel creatFqaCommentsModelFromJson(String str) =>
    CreateFqaCommentsModel.fromJson(json.decode(str));

String creatFqaCommentsModelToJson(CreateFqaCommentsModel data) =>
    json.encode(data.toJson());

class CreateFqaCommentsModel {
  final String? commentId;
  final String? status;
  final String? message;
  final Data? data;
  final DateTime? createdAt;

  CreateFqaCommentsModel({
    this.commentId,
    this.status,
    this.message,
    this.data,
    this.createdAt,
  });

  CreateFqaCommentsModel copyWith({
    String? commentId,
    String? status,
    String? message,
    Data? data,
    DateTime? createdAt,
  }) =>
      CreateFqaCommentsModel(
        commentId: commentId ?? this.commentId,
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
        createdAt: createdAt ?? this.createdAt,
      );

  factory CreateFqaCommentsModel.fromJson(Map<String, dynamic> json) =>
      CreateFqaCommentsModel(
        commentId: json["comment_id"],
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "comment_id": commentId,
        "status": status,
        "message": message,
        "data": data?.toJson(),
        "created_at": createdAt?.toIso8601String(),
      };
}

class Data {
  final String? commentId;
  final String? productId;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final String? text;
  final dynamic rating;
  final String? variant;
  final String? userType;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? verifiedPhone;

  Data({
    this.commentId,
    this.productId,
    this.userId,
    this.userName,
    this.userAvatar,
    this.text,
    this.rating,
    this.variant,
    this.userType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.verifiedPhone,
  });

  Data copyWith({
    String? commentId,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? text,
    dynamic rating,
    String? variant,
    String? userType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? verifiedPhone,
  }) =>
      Data(
        commentId: commentId ?? this.commentId,
        productId: productId ?? this.productId,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userAvatar: userAvatar ?? this.userAvatar,
        text: text ?? this.text,
        rating: rating ?? this.rating,
        variant: variant ?? this.variant,
        userType: userType ?? this.userType,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        verifiedPhone: verifiedPhone ?? this.verifiedPhone,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        commentId: json["comment_id"],
        productId: json["product_id"],
        userId: json["user_id"],
        userName: json["user_name"],
        userAvatar: json["user_avatar"],
        text: json["text"],
        rating: json["rating"],
        variant: json["variant"],
        userType: json["user_type"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        verifiedPhone: json["verified_phone"],
      );

  Map<String, dynamic> toJson() => {
        "comment_id": commentId,
        "product_id": productId,
        "user_id": userId,
        "user_name": userName,
        "user_avatar": userAvatar,
        "text": text,
        "rating": rating,
        "variant": variant,
        "user_type": userType,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "verified_phone": verifiedPhone,
      };
}
