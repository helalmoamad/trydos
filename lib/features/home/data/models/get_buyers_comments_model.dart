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

  GetBuyersCommentsModel({this.data, this.code});

  GetBuyersCommentsModel copyWith({Data? data, int? code}) =>
      GetBuyersCommentsModel(data: data ?? this.data, code: code ?? this.code);

  factory GetBuyersCommentsModel.fromJson(Map<String, dynamic> json) =>
      GetBuyersCommentsModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {"data": data?.toJson(), "code": code};
}

class Data {
  final List<BuyersComment>? buyersComments;
  final int? total;
  final List<dynamic>? offset;

  Data({this.buyersComments, this.total, this.offset});

  Data copyWith({
    List<BuyersComment>? buyersComments,
    int? total,
    List<dynamic>? offset,
  }) => Data(
    buyersComments: buyersComments ?? this.buyersComments,
    total: total ?? this.total,
    offset: offset ?? this.offset,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    buyersComments: json["buyers_comments"] == null
        ? []
        : List<BuyersComment>.from(
            json["buyers_comments"]!.map((x) => BuyersComment.fromJson(x)),
          ),
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
    "offset": offset == null ? [] : List<dynamic>.from(offset!.map((x) => x)),
  };
}

class BuyersComment {
  final String? id;
  final Customer? customer;
  final String? productId;
  final String? comment;
  final String? commentTran;
  final String? variant;
  final DateTime? createdAt;
  final int? totalLikes;
  final bool? isLiked;
  final bool? recommendation;
  final bool? goodQualitycomment;
  final bool? trueSize;
  final bool? isTran;
  final double? starRating;
  final String? orderDetailsId;

  BuyersComment({
    this.id,
    this.customer,
    this.trueSize,
    this.productId,
    this.totalLikes,
    this.isLiked,
    this.comment,
    this.commentTran,
    this.goodQualitycomment,
    this.variant,
    this.createdAt,
    this.recommendation,
    this.isTran,
    this.starRating,
    this.orderDetailsId,
  });

  BuyersComment copyWith({
    String? id,
    Customer? customer,
    String? productId,
    bool? goodQualitycomment,
    String? comment,
    String? commentTran,
    String? variant,
    bool? recommendation,
    DateTime? createdAt,
    double? starRating,
    bool? trueSize,
    int? totalLikes,
    bool? isTran,
    bool? isLiked,
    String? orderDetailsId,
  }) => BuyersComment(
    id: id ?? this.id,
    customer: customer ?? this.customer,
    productId: productId ?? this.productId,
    comment: comment ?? this.comment,
    commentTran: commentTran ?? this.commentTran,
    variant: variant ?? this.variant,
    createdAt: createdAt ?? this.createdAt,
    goodQualitycomment: goodQualitycomment ?? this.goodQualitycomment,
    starRating: starRating ?? this.starRating,
    trueSize: trueSize ?? this.trueSize,
    isTran: isTran ?? this.isTran,
    totalLikes: totalLikes ?? this.totalLikes,
    isLiked: isLiked ?? this.isLiked,
    recommendation: recommendation ?? this.recommendation,
    orderDetailsId: orderDetailsId ?? this.orderDetailsId,
  );

  factory BuyersComment.fromJson(Map<String, dynamic> json) => BuyersComment(
    id: json["id"].toString(),
    customer: json["customer"] == null
        ? null
        : Customer.fromJson(json["customer"]),
    productId: json["product_id"],
    trueSize: json["true_size"],
    isTran: false,
    comment: json["comment"],
    goodQualitycomment: json["good_quality_comment"],
    totalLikes: json["total_likes"],
    isLiked: json["is_liked"],
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
    "good_quality_comment": goodQualitycomment,
    "comment": comment,
    "variant": variant,
    "created_at": createdAt?.toIso8601String(),
    "star_rating": starRating,
    "true_size": trueSize,
    "recommendation": recommendation,
    "order_details_id": orderDetailsId,
    "total_likes": totalLikes,
    "is_liked": isLiked,
  };
}

class Customer {
  final String? id;
  final String? name;
  final String? image;

  Customer({this.id, this.name, this.image});

  Customer copyWith({String? id, String? name, String? image}) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image ?? this.image,
  );

  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer(id: json["id"], name: json["name"], image: json["image"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "image": image};
}
