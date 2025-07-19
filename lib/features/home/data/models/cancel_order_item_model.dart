// To parse this JSON data, do
//
//     final cancelOrderItemModel = cancelOrderItemModelFromJson(jsonString);

import 'dart:convert';

CancelOrderItemModel cancelOrderItemModelFromJson(String str) =>
    CancelOrderItemModel.fromJson(json.decode(str));

String cancelOrderItemModelToJson(CancelOrderItemModel data) =>
    json.encode(data.toJson());

class CancelOrderItemModel {
  final String? message;
  final bool? success;
  final int? statusCode;

  CancelOrderItemModel({
    this.message,
    this.success,
    this.statusCode,
  });

  CancelOrderItemModel copyWith({
    String? message,
    bool? success,
    int? statusCode,
  }) =>
      CancelOrderItemModel(
        message: message ?? this.message,
        success: success ?? this.success,
        statusCode: statusCode ?? this.statusCode,
      );

  factory CancelOrderItemModel.fromJson(Map<String, dynamic> json) =>
      CancelOrderItemModel(
        message: json["message"],
        success: json["success"],
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "success": success,
        "status_code": statusCode,
      };
}
