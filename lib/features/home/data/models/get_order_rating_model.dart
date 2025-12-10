// To parse this JSON data, do
//
//     final getOrderRatingModel = getOrderRatingModelFromJson(jsonString);

import 'dart:convert';

GetOrderRatingFromAnalyticsModel getOrderRatingModelFromJson(String str) =>
    GetOrderRatingFromAnalyticsModel.fromJson(json.decode(str));

String getOrderRatingModelToJson(GetOrderRatingFromAnalyticsModel data) =>
    json.encode(data.toJson());

class GetOrderRatingFromAnalyticsModel {
  final Data? data;
  final int? code;

  GetOrderRatingFromAnalyticsModel({this.data, this.code});

  GetOrderRatingFromAnalyticsModel copyWith({Data? data, int? code}) =>
      GetOrderRatingFromAnalyticsModel(
        data: data ?? this.data,
        code: code ?? this.code,
      );

  factory GetOrderRatingFromAnalyticsModel.fromJson(
    Map<String, dynamic> json,
  ) => GetOrderRatingFromAnalyticsModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {"data": data?.toJson(), "code": code};
}

class Data {
  final List<Comment>? comments;
  final int? total;
  final List<dynamic>? searchAfter;

  Data({this.comments, this.total, this.searchAfter});

  Data copyWith({
    List<Comment>? comments,
    int? total,
    List<dynamic>? searchAfter,
  }) => Data(
    comments: comments ?? this.comments,
    total: total ?? this.total,
    searchAfter: searchAfter ?? this.searchAfter,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    comments: json["comments"] == null
        ? []
        : List<Comment>.from(json["comments"]!.map((x) => Comment.fromJson(x))),
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
  final List<String>? images;
  final double? starRating;
  final String? orderDetailsId;

  Comment({
    this.id,
    this.customer,
    this.productId,
    this.comment,
    this.images,
    this.createdAt,
    this.starRating,
    this.orderDetailsId,
  });

  Comment copyWith({
    String? id,
    Customer? customer,
    String? productId,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    double? starRating,
    String? orderDetailsId,
  }) => Comment(
    id: id ?? this.id,
    customer: customer ?? this.customer,
    productId: productId ?? this.productId,
    comment: comment ?? this.comment,
    images: images ?? this.images,
    createdAt: createdAt ?? this.createdAt,
    starRating: starRating ?? this.starRating,
    orderDetailsId: orderDetailsId ?? this.orderDetailsId,
  );

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json["id"],
    customer: json["customer"] == null
        ? null
        : Customer.fromJson(json["customer"]),
    productId: json["product_id"],
    comment: json["comment"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    images: json["comments_images_customer"] == null
        ? []
        : List<String>.from(json["comments_images_customer"]!.map((x) => x)),
    starRating: json["star_rating"]?.toDouble(),
    orderDetailsId: json["order_details_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer": customer?.toJson(),
    "product_id": productId,
    "comment": comment,
    "created_at": createdAt?.toIso8601String(),
    "star_rating": starRating,
    "order_details_id": orderDetailsId,
    "comments_images_customer": images == null
        ? []
        : List<dynamic>.from(images!.map((x) => x)),
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
