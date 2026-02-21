// To parse this JSON data, do
//
//     final missedCallCount = missedCallCountFromJson(jsonString);

import 'dart:convert';

MissedCallCountModel missedCallCountFromJson(String str) =>
    MissedCallCountModel.fromJson(json.decode(str));

String missedCallCountToJson(MissedCallCountModel data) =>
    json.encode(data.toJson());

class MissedCallCountModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  MissedCallCountModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  MissedCallCountModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      MissedCallCountModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory MissedCallCountModel.fromJson(Map<String, dynamic> json) =>
      MissedCallCountModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
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

class Data {
  final int? missedCals;

  Data({
    this.missedCals,
  });

  Data copyWith({
    int? missedCals,
  }) =>
      Data(
        missedCals: missedCals ?? this.missedCals,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        missedCals: json["missed_cals"],
      );

  Map<String, dynamic> toJson() => {
        "missed_cals": missedCals,
      };
}
