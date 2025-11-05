// To parse this JSON data, do
//
//     final geBuyersCommentsModel = geBuyersCommentsModelFromJson(jsonString);

import 'dart:convert';

GetBuyersCommentsModel geBuyersCommentsModelFromJson(String str) =>
    GetBuyersCommentsModel.fromJson(json.decode(str));

String geBuyersCommentsModelToJson(GetBuyersCommentsModel data) =>
    json.encode(data.toJson());

class GetBuyersCommentsModel {
  final Data? data;
  final int? code;

  GetBuyersCommentsModel({
    this.data,
    this.code,
  });

  GetBuyersCommentsModel copyWith({
    Data? data,
    int? code,
  }) =>
      GetBuyersCommentsModel(
        data: data ?? this.data,
        code: code ?? this.code,
      );

  factory GetBuyersCommentsModel.fromJson(Map<String, dynamic> json) =>
      GetBuyersCommentsModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "code": code,
      };
}

class Data {
  final List<BuyersComment>? buyersComments;
  final int? total;
  final List<dynamic>? offset;

  Data({
    this.buyersComments,
    this.total,
    this.offset,
  });

  Data copyWith({
    List<BuyersComment>? buyersComments,
    int? total,
    List<dynamic>? offset,
  }) =>
      Data(
        buyersComments: buyersComments ?? this.buyersComments,
        total: total ?? this.total,
        offset: offset ?? this.offset,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        buyersComments: json["buyers_comments"] == null
            ? []
            : List<BuyersComment>.from(
                json["buyers_comments"]!.map((x) => BuyersComment.fromJson(x))),
        total: json["total"],
        offset: json["offset"] == null
            ? []
            : List<dynamic>.from(json["offset"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "buyers_comments": buyersComments == null
            ? []
            : List<dynamic>.from(buyersComments!.map((x) => x.toJson())),
        "total": total,
        "offset":
            offset == null ? [] : List<dynamic>.from(offset!.map((x) => x)),
      };
}

class BuyersComment {
  final String? id;
  final Customer? customer;
  final String? productId;
  final String? comment;
  final String? variant;
  final DateTime? createdAt;
  final bool? recommendation;
  final double? starRating;
  final String? orderDetailsId;

  BuyersComment({
    this.id,
    this.customer,
    this.productId,
    this.comment,
    this.variant,
    this.createdAt,
    this.recommendation,
    this.starRating,
    this.orderDetailsId,
  });

  BuyersComment copyWith({
    String? id,
    Customer? customer,
    String? productId,
    String? comment,
    String? variant,
    bool? recommendation,
    DateTime? createdAt,
    double? starRating,
    String? orderDetailsId,
  }) =>
      BuyersComment(
        id: id ?? this.id,
        customer: customer ?? this.customer,
        productId: productId ?? this.productId,
        comment: comment ?? this.comment,
        variant: variant ?? this.variant,
        createdAt: createdAt ?? this.createdAt,
        starRating: starRating ?? this.starRating,
        recommendation: recommendation ?? this.recommendation,
        orderDetailsId: orderDetailsId ?? this.orderDetailsId,
      );

  factory BuyersComment.fromJson(Map<String, dynamic> json) => BuyersComment(
        id: json["id"].toString(),
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        productId: json["product_id"],
        comment: json["comment"],
        recommendation: json["recommendation"],
        variant: json["variant"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        starRating: double.tryParse(json["star_rating"].toString()),
        orderDetailsId: json["order_details_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer": customer?.toJson(),
        "product_id": productId,
        "comment": comment,
        "variant": variant,
        "created_at": createdAt?.toIso8601String(),
        "star_rating": starRating,
        "recommendation": recommendation,
        "order_details_id": orderDetailsId,
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
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
