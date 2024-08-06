// To parse this JSON data, do
//
//     final changeChatPropertyModel = changeChatPropertyModelFromJson(jsonString);

import 'dart:convert';

ChangeChatPropertyModel changeChatPropertyModelFromJson(String str) =>
    ChangeChatPropertyModel.fromJson(json.decode(str));

String changeChatPropertyModelToJson(ChangeChatPropertyModel data) =>
    json.encode(data.toJson());

class ChangeChatPropertyModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Map<String, dynamic>? data;

  ChangeChatPropertyModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  ChangeChatPropertyModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Map<String, dynamic>? data,
  }) =>
      ChangeChatPropertyModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory ChangeChatPropertyModel.fromJson(Map<String, dynamic> json) =>
      ChangeChatPropertyModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: Map.from(json["data"]!)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": Map.from(data!).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
