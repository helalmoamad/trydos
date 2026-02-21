/*
// To parse this JSON data, do
//
//     final getCommentsFromAnalyticsModel = getCommentsFromAnalyticsModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

GetCommentsFromAnalyticsModel getCommentsFromAnalyticsModelFromJson(
        String str) =>
    GetCommentsFromAnalyticsModel.fromJson(json.decode(str));

String getCommentsFromAnalyticsModelToJson(
        GetCommentsFromAnalyticsModel data) =>
    json.encode(data.toJson());

class GetCommentsFromAnalyticsModel {
  final Data? data;
  final int? code;
  final List<dynamic>? offset;

  GetCommentsFromAnalyticsModel({
    this.data,
    this.code,
    this.offset,
  });

  GetCommentsFromAnalyticsModel copyWith({
    Data? data,
    int? code,
    List<dynamic>? offset,
  }) =>
      GetCommentsFromAnalyticsModel(
        data: data ?? this.data,
        code: code ?? this.code,
        offset: offset ?? this.offset,
      );

  factory GetCommentsFromAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      GetCommentsFromAnalyticsModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        code: json["code"],
        offset: json["offset"] == null
            ? []
            : List<dynamic>.from(json["offset"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "code": code,
        "offset":
            offset == null ? [] : List<dynamic>.from(offset!.map((x) => x)),
      };
}

class Data {
  final List<Comment>? comments;
  final int? total;
  final List<dynamic>? searchAfter;

  Data({
    this.comments,
    this.total,
    this.searchAfter,
  });

  Data copyWith({
    List<Comment>? comments,
    int? total,
    List<dynamic>? searchAfter,
  }) =>
      Data(
        comments: comments ?? this.comments,
        total: total ?? this.total,
        searchAfter: searchAfter ?? this.searchAfter,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        comments: json["comments"] == null
            ? []
            : List<Comment>.from(
                json["comments"]!.map((x) => Comment.fromJson(x))),
        total: json["total"],
        searchAfter: json["searchAfter"] == null
            ? []
            : List<dynamic>.from(json["searchAfter"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "comments": comments == null
            ? []
            : List<dynamic>.from(comments!.map((x) => x.toJson())),
        "total": total,
        "searchAfter": searchAfter == null
            ? []
            : List<dynamic>.from(searchAfter!.map((x) => x)),
      };
}

class Comment {
  final String? id;
  final Customer? customer;
  final String? productId;
  final String? comment;
  final DateTime? createdAt;

  Comment({
    this.id,
    this.customer,
    this.productId,
    this.comment,
    this.createdAt,
  });

  Comment copyWith({
    String? id,
    Customer? customer,
    String? productId,
    String? comment,
    DateTime? createdAt,
  }) =>
      Comment(
        id: id ?? this.id,
        customer: customer ?? this.customer,
        productId: productId ?? this.productId,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"].toString(),
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        productId: json["product_id"].toString(),
        comment: json["comment"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer": customer?.toJson(),
        "product_id": productId,
        "comment": comment,
        "created_at": createdAt?.toIso8601String(),
      };
}

class Customer {
  final String? id;
  final String? name;
  final String? image;

  Customer({
    this.id,
    this.name,
    this.image,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? image,
  }) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
        image: json["image"]?.contains("cloudinary")
            ? json["image"]
            : ("${dotenv.env['Images_Url']}" + (json["image"])),
      );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "image": image};
}
*/
