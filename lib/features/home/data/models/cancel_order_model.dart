// To parse this JSON data, do
//
//     final cancelOrderModel = cancelOrderModelFromJson(jsonString);

import 'dart:convert';

CancelOrderModel cancelOrderModelFromJson(String str) =>
    CancelOrderModel.fromJson(json.decode(str));

String cancelOrderModelToJson(CancelOrderModel data) =>
    json.encode(data.toJson());

class CancelOrderModel {
  final String? message;
  final bool? success;
  final int? statusCode;

  CancelOrderModel({
    this.message,
    this.success,
    this.statusCode,
  });

  CancelOrderModel copyWith({
    String? message,
    bool? success,
    int? statusCode,
  }) =>
      CancelOrderModel(
        message: message ?? this.message,
        success: success ?? this.success,
        statusCode: statusCode ?? this.statusCode,
      );

  factory CancelOrderModel.fromJson(Map<String, dynamic> json) =>
      CancelOrderModel(
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
