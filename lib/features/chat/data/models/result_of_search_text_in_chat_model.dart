// To parse this JSON data, do
//
//     final resultOfSearchTextInChatModel = resultOfSearchTextInChatModelFromJson(jsonString);

import 'dart:convert';

ResultOfSearchTextInChatModel resultOfSearchTextInChatModelFromJson(
        String str) =>
    ResultOfSearchTextInChatModel.fromJson(json.decode(str));

String resultOfSearchTextInChatModelToJson(
        ResultOfSearchTextInChatModel data) =>
    json.encode(data.toJson());

class ResultOfSearchTextInChatModel {
  final List<String>? messagesIds;
  final String? offset;

  ResultOfSearchTextInChatModel({
    this.messagesIds,
    this.offset,
  });

  ResultOfSearchTextInChatModel copyWith({
    List<String>? messagesIds,
    String? offset,
  }) =>
      ResultOfSearchTextInChatModel(
        messagesIds: messagesIds ?? this.messagesIds,
        offset: offset ?? this.offset,
      );

  factory ResultOfSearchTextInChatModel.fromJson(Map<String, dynamic> json) =>
      ResultOfSearchTextInChatModel(
        messagesIds: json["messages_ids"] == null
            ? []
            : List<String>.from(json["messages_ids"]!.map((x) => x.toString())),
        offset: json["offset"] == null ? null : json["offset"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "messages_ids": messagesIds == null
            ? []
            : List<dynamic>.from(messagesIds!.map((x) => x.toString())),
        "offset": offset == null ? null : offset.toString(),
      };
}
