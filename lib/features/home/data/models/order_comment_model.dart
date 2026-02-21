// To parse this JSON data, do
//
//     final orderCommentModel = orderCommentModelFromJson(jsonString);

import 'dart:convert';

OrderCommentModel orderCommentModelFromJson(String str) =>
    OrderCommentModel.fromJson(json.decode(str));

String orderCommentModelToJson(OrderCommentModel data) =>
    json.encode(data.toJson());

class OrderCommentModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final OrderCommentData? data;

  OrderCommentModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  OrderCommentModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    OrderCommentData? data,
  }) =>
      OrderCommentModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory OrderCommentModel.fromJson(Map<String, dynamic> json) =>
      OrderCommentModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null
            ? null
            : OrderCommentData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data?.toJson(),
      };
}

class OrderCommentData {
  final int? id;
  final String? comment;
  final double? starRating;

  OrderCommentData({
    this.id,
    this.comment,
    this.starRating,
  });

  OrderCommentData copyWith({
    int? id,
    String? comment,
    double? starRating,
  }) =>
      OrderCommentData(
        id: id ?? this.id,
        comment: comment ?? this.comment,
        starRating: starRating ?? this.starRating,
      );

  factory OrderCommentData.fromJson(Map<String, dynamic> json) =>
      OrderCommentData(
        id: json["id"],
        comment: json["comment"],
        starRating: json["star_rating"] == null
            ? null
            : double.parse(json["star_rating"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment,
        "star_rating": starRating,
      };
}
