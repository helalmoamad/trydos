// To parse this JSON data, do
//
//     final geFqaCommentsModel = geFqaCommentsModelFromJson(jsonString);

import 'dart:convert';

GetFqaCommentsModel geFqaCommentsModelFromJson(String str) =>
    GetFqaCommentsModel.fromJson(json.decode(str));

String geFqaCommentsModelToJson(GetFqaCommentsModel data) =>
    json.encode(data.toJson());

class GetFqaCommentsModel {
  final Data? data;
  final int? code;

  GetFqaCommentsModel({
    this.data,
    this.code,
  });

  GetFqaCommentsModel copyWith({
    Data? data,
    int? code,
  }) =>
      GetFqaCommentsModel(
        data: data ?? this.data,
        code: code ?? this.code,
      );

  factory GetFqaCommentsModel.fromJson(Map<String, dynamic> json) =>
      GetFqaCommentsModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "code": code,
      };
}

class Data {
  final List<FqaComment>? fqaComments;
  final int? total;
  final List<dynamic>? offset;

  Data({
    this.fqaComments,
    this.total,
    this.offset,
  });

  Data copyWith({
    List<FqaComment>? fqaComments,
    int? total,
    List<dynamic>? offset,
  }) =>
      Data(
        fqaComments: fqaComments ?? this.fqaComments,
        total: total ?? this.total,
        offset: offset ?? this.offset,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        fqaComments: json["fqa_comments"] == null
            ? []
            : List<FqaComment>.from(
                json["fqa_comments"]!.map((x) => FqaComment.fromJson(x))),
        total: json["total"],
        offset: json["offset"] == null
            ? []
            : List<dynamic>.from(json["offset"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "fqa_comments": fqaComments == null
            ? []
            : List<dynamic>.from(fqaComments!.map((x) => x.toJson())),
        "total": total,
        "offset":
            offset == null ? [] : List<dynamic>.from(offset!.map((x) => x)),
      };
}

class FqaComment {
  final String? id;
  final CommentCustomer? customer;
  final String? productId;
  final String? comment;
  final String? variant;
  final DateTime? createdAt;
  final bool? hasReply;
  final String? sellerReply;
  final String? sellerName;
  final DateTime? replyCreatedAt;

  FqaComment({
    this.id,
    this.customer,
    this.productId,
    this.comment,
    this.variant,
    this.createdAt,
    this.hasReply,
    this.sellerReply,
    this.sellerName,
    this.replyCreatedAt,
  });

  FqaComment copyWith({
    String? id,
    CommentCustomer? customer,
    String? productId,
    String? comment,
    String? variant,
    DateTime? createdAt,
    bool? hasReply,
    String? sellerReply,
    String? sellerName,
    DateTime? replyCreatedAt,
  }) =>
      FqaComment(
        id: id ?? this.id,
        customer: customer ?? this.customer,
        productId: productId ?? this.productId,
        comment: comment ?? this.comment,
        variant: variant ?? this.variant,
        createdAt: createdAt ?? this.createdAt,
        hasReply: hasReply ?? this.hasReply,
        sellerReply: sellerReply ?? this.sellerReply,
        sellerName: sellerName ?? this.sellerName,
        replyCreatedAt: replyCreatedAt ?? this.replyCreatedAt,
      );

  factory FqaComment.fromJson(Map<String, dynamic> json) => FqaComment(
        id: json["id"].toString(),
        customer: json["customer"] == null
            ? null
            : CommentCustomer.fromJson(json["customer"]),
        productId: json["product_id"],
        comment: json["comment"],
        variant: json["variant"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        hasReply: json["has_reply"],
        sellerReply: json["seller_reply"],
        sellerName: json["seller_name"],
        replyCreatedAt: json["reply_created_at"] == null
            ? null
            : DateTime.parse(json["reply_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer": customer?.toJson(),
        "product_id": productId,
        "comment": comment,
        "variant": variant,
        "created_at": createdAt?.toIso8601String(),
        "has_reply": hasReply,
        "seller_reply": sellerReply,
        "seller_name": sellerName,
        "reply_created_at": replyCreatedAt?.toIso8601String(),
      };
}

class CommentCustomer {
  final String? id;
  final String? name;
  final String? image;

  CommentCustomer({
    this.id,
    this.name,
    this.image,
  });

  CommentCustomer copyWith({
    String? id,
    String? name,
    String? image,
  }) =>
      CommentCustomer(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory CommentCustomer.fromJson(Map<String, dynamic> json) =>
      CommentCustomer(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
