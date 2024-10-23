// To parse this JSON data, do
//
//     final getCommentForProduct = getCommentForProductFromJson(jsonString);

import 'dart:convert';

GetCommentForProductModel getCommentForProductFromJson(String str) =>
    GetCommentForProductModel.fromJson(json.decode(str));

String getCommentForProductToJson(GetCommentForProductModel data) =>
    json.encode(data.toJson());

class GetCommentForProductModel {
  final String? message;
  final CommentsForProduct? commentsForProduct;

  GetCommentForProductModel({
    this.message,
    this.commentsForProduct,
  });

  GetCommentForProductModel copyWith({
    String? message,
    CommentsForProduct? data,
  }) =>
      GetCommentForProductModel(
        message: message ?? this.message,
        commentsForProduct: data ?? this.commentsForProduct,
      );

  factory GetCommentForProductModel.fromJson(Map<String, dynamic> json) =>
      GetCommentForProductModel(
        message: json["message"],
        commentsForProduct: json["data"] == null
            ? null
            : CommentsForProduct.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": commentsForProduct?.toJson(),
      };
}

class CommentsForProduct {
  final int? id;
  final int? commentsCount;
  final List<Comment>? comments;

  CommentsForProduct({
    this.id,
    this.commentsCount,
    this.comments,
  });

  CommentsForProduct copyWith({
    int? id,
    int? commentsCount,
    List<Comment>? comments,
  }) =>
      CommentsForProduct(
        id: id ?? this.id,
        commentsCount: commentsCount ?? this.commentsCount,
        comments: comments ?? this.comments,
      );

  factory CommentsForProduct.fromJson(Map<String, dynamic> json) =>
      CommentsForProduct(
        id: json["id"],
        commentsCount: json["comments_count"],
        comments: json["comments"] == null
            ? []
            : List<Comment>.from(
                json["comments"]!.map((x) => Comment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comments_count": commentsCount,
        "comments": comments == null
            ? []
            : List<dynamic>.from(comments!.map((x) => x.toJson())),
      };
}

class Comment {
  final int? id;
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
    int? id,
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
        id: json["id"],
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        productId: json["product_id"]?.toString(),
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
        id: json["id"].toString(),
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
