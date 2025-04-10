// To parse this JSON data, do
//
//     final udateProfileModel = udateProfileModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';

UpdateProfileModel udateProfileModelFromJson(String str) =>
    UpdateProfileModel.fromJson(json.decode(str));

String udateProfileModelToJson(UpdateProfileModel data) =>
    json.encode(data.toJson());

class UpdateProfileModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final User? data;

  UpdateProfileModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  UpdateProfileModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    User? data,
  }) =>
      UpdateProfileModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) =>
      UpdateProfileModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null ? null : User.fromJson(json["data"]),
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
