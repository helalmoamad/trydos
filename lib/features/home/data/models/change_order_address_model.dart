// To parse this JSON data, do
//
//     final changeOrderAddressModel = changeOrderAddressModelFromJson(jsonString);

import 'dart:convert';

ChangeOrderAddressModel changeOrderAddressModelFromJson(String str) =>
    ChangeOrderAddressModel.fromJson(json.decode(str));

String changeOrderAddressModelToJson(ChangeOrderAddressModel data) =>
    json.encode(data.toJson());

class ChangeOrderAddressModel {
  final String? message;
  final bool? success;
  final int? statusCode;

  ChangeOrderAddressModel({
    this.message,
    this.success,
    this.statusCode,
  });

  ChangeOrderAddressModel copyWith({
    String? message,
    bool? success,
    int? statusCode,
  }) =>
      ChangeOrderAddressModel(
        message: message ?? this.message,
        success: success ?? this.success,
        statusCode: statusCode ?? this.statusCode,
      );

  factory ChangeOrderAddressModel.fromJson(Map<String, dynamic> json) =>
      ChangeOrderAddressModel(
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
