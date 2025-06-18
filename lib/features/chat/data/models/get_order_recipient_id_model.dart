// To parse this JSON data, do
//
//     final getOrderRecipientIdModel = getOrderRecipientIdModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';

GetOrderRecipientIdModel getOrderRecipientIdModelFromJson(String str) =>
    GetOrderRecipientIdModel.fromJson(json.decode(str));

String getOrderRecipientIdModelToJson(GetOrderRecipientIdModel data) =>
    json.encode(data.toJson());

class GetOrderRecipientIdModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  GetOrderRecipientIdModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetOrderRecipientIdModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      GetOrderRecipientIdModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetOrderRecipientIdModel.fromJson(Map<String, dynamic> json) =>
      GetOrderRecipientIdModel(
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
  final Recipient? recipient;
  final ChatParticipant? chatParticipant;
  final Chat? chat;

  Data({
    this.recipient,
    this.chat,
    this.chatParticipant,
  });

  Data copyWith({
    Recipient? recipient,
    Chat? chat,
    ChatParticipant? chatParticipant,
  }) =>
      Data(
        chat: chat ?? this.chat,
        recipient: recipient ?? this.recipient,
        chatParticipant: chatParticipant ?? this.chatParticipant,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        recipient: json["recipient"] == null
            ? null
            : Recipient.fromJson(json["recipient"]),
        chatParticipant: json["chat_participant"] == null
            ? null
            : ChatParticipant.fromJson(json["chat_participant"]),
        chat: (json["channel"] == null || json["channel"] == {})
            ? null
            : Chat.fromJson(json["channel"]),
      );

  Map<String, dynamic> toJson() => {
        "recipient": recipient?.toJson(),
        "chat_participant": chatParticipant?.toJson(),
        "channel": chat?.toJson(),
      };
}

class ChatParticipant {
  final int? id;
  final int? deliveryUserId;
  final int? originalUserId;
  final int? orderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatParticipant({
    this.id,
    this.deliveryUserId,
    this.originalUserId,
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  ChatParticipant copyWith({
    int? id,
    int? deliveryUserId,
    int? originalUserId,
    int? orderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ChatParticipant(
        id: id ?? this.id,
        deliveryUserId: deliveryUserId ?? this.deliveryUserId,
        originalUserId: originalUserId ?? this.originalUserId,
        orderId: orderId ?? this.orderId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      ChatParticipant(
        id: json["id"],
        deliveryUserId: json["delivery_user_id"],
        originalUserId: json["original_user_id"],
        orderId: json["order_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "delivery_user_id": deliveryUserId,
        "original_user_id": originalUserId,
        "order_id": orderId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Recipient {
  final int? id;

  Recipient({
    this.id,
  });

  Recipient copyWith({
    int? id,
  }) =>
      Recipient(
        id: id ?? this.id,
      );

  factory Recipient.fromJson(Map<String, dynamic> json) => Recipient(
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}
