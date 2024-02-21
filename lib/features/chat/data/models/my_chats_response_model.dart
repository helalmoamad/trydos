import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/data/model/pagination_model.dart';

MyChatsResponseModel myChatsResponseModelFromJson(String str) =>
    MyChatsResponseModel.fromJson(json.decode(str));

String myChatsResponseModelToJson(MyChatsResponseModel data) =>
    json.encode(data.toJson());

class MyChatsResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final List<dynamic>? detailedError;
  final Data? data;

  MyChatsResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  factory MyChatsResponseModel.fromJson(Map<String, dynamic> json) =>
      MyChatsResponseModel(
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
  final List<Chat>? chats;
  final List<Chat>? pinnedChats;
  final bool missedFcmToken;

  Data({
    this.chats,
    this.pinnedChats,
    required this.missedFcmToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      chats: json["channels"] == null
          ? []
          : List<Chat>.from(json["channels"]!.map((x) => Chat.fromJson(x))),
      pinnedChats: json["pinned_channels"] == null
          ? []
          : List<Chat>.from(
              json["pinned_channels"]!.map((x) => Chat.fromJson(x))),
      missedFcmToken: json['missed_fcm_token']);

  Map<String, dynamic> toJson() => {
        "channels": chats == null
            ? []
            : List<dynamic>.from(chats!.map((x) => x.toJson())),
        "pinned_channels": pinnedChats == null
            ? []
            : List<dynamic>.from(pinnedChats!.map((x) => x)),
      };
}

class SenderInfo {
  final int? id;
  final String? name;

  SenderInfo({
    this.id,
    this.name,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) =>
      SenderInfo(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {};
}

class Message {
  final String? id;
  final String? localId;
  final String? localParentMessageId;
  final int? senderUserId;
  final int? receiverUserId;
  final String? channelId;
  final DateTime? createdAt;
  final MessageType? messageType;
  final String? parentMessageId;
  final int? isForward;
  final MessageContent? messageContent;
  final List<MediaMessageContent>? mediaMessageContent;
  final List<MessageStatus>? messageStatus;
  final Chat? channel;
  final Message? parentMessage;
  final File? file;
  bool isFirstMessageForThisDay;
  bool isFirstMessage;
  bool isDateMessage;
  String dateValue;

  Message({
    this.isFirstMessageForThisDay = false,
    this.isDateMessage = false,
    this.dateValue = '',
    this.isFirstMessage = false,
    this.id,
    this.senderUserId,
    this.localParentMessageId,
    this.receiverUserId,
    this.channelId,
    this.createdAt,
    this.messageType,
    this.file,
    this.localId,
    this.parentMessageId,
    this.isForward,
    this.messageContent,
    this.messageStatus,
    this.mediaMessageContent,
    this.channel,
    this.parentMessage,
  });

  Message copyWith({
    final bool? isFirstMessageForThisDay,
    final bool? isFirstMessage,
    final String? id,
    final String? localId,
    final String? localParentMessageId,
    final int? senderUserId,
    final int? receiverUserId,
    final String? channelId,
    final DateTime? createdAt,
    final MessageType? messageType,
    final String? parentMessageId,
    final int? isForward,
    final MessageContent? messageContent,
    final List<MediaMessageContent>? mediaMessageContent,
    final List<MessageStatus>? messageStatus,
    final Chat? channel,
    final Message? parentMessage,
    final File? file,
  }) {
    return Message(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      localParentMessageId: localParentMessageId ?? this.localParentMessageId,
      senderUserId: senderUserId ?? this.senderUserId,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      channelId: channelId ?? this.channelId,
      createdAt: createdAt ?? this.createdAt,
      messageType: messageType ?? this.messageType,
      file: file ?? this.file,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      isForward: isForward ?? this.isForward,
      messageContent: messageContent ?? this.messageContent,
      isFirstMessageForThisDay:
          isFirstMessageForThisDay ?? this.isFirstMessageForThisDay,
      isFirstMessage: isFirstMessage ?? this.isFirstMessage,
      messageStatus: messageStatus ?? this.messageStatus,
      mediaMessageContent: mediaMessageContent ?? this.mediaMessageContent,
      channel: channel ?? this.channel,
      parentMessage: parentMessage ?? this.parentMessage,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"].toString(),
        senderUserId: json["sender_user_id"],
        receiverUserId: json["receiver_user_id"],
        channelId: json["channel_id"].toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        messageType: json["message_type"] == null
            ? null
            : MessageType.fromJson(json["message_type"]),
        parentMessageId: json["parent_message_id"]?.toString(),
        isForward: (json["is_forward"] is bool)
            ? (json["is_forward"] ? 1 : 0)
            : json["is_forward"],
        mediaMessageContent: json["message_type"]["name"] == "TextMessage"
            ? null
            : json["message_content"] == null
                ? []
                : List<MediaMessageContent>.from(json["message_content"]!
                    .map((x) => MediaMessageContent.fromJson(x))),
        messageContent: json["message_type"]["name"] != "TextMessage"
            ? null
            : json["message_content"] == null
                ? null
                : MessageContent.fromJson(json["message_content"]),
        messageStatus: json["message_status"] == null
            ? []
            : List<MessageStatus>.from(
                json["message_status"]!.map((x) => MessageStatus.fromJson(x))),
        channel:
            json["channel"] == null ? null : Chat.fromJson(json["channel"]),
        parentMessage: json["parent_message"] != null
            ? Message.fromJson(json["parent_message"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sender_user_id": senderUserId,
        "receiver_user_id": receiverUserId,
        "channel_id": channelId,
        "created_at": createdAt?.toIso8601String(),
        "message_type": messageType?.toJson(),
        "parent_message_id": parentMessageId,
        "is_forward": isForward,
        "message_content": messageContent?.toJson(),
        "message_status": messageStatus == null
            ? []
            : List<dynamic>.from(messageStatus!.map((x) => x.toJson())),
        "channel": channel?.toJson(),
        "parent_message": parentMessage,
      };
}

class Chat {
  final String? id;
  final String? channelName;
  final String? photoPath;
  final String? localId;
  final int? totalUnreadMessageCount;
  final List<ChannelMember>? channelMembers;
  final List<Message>? messages;
  final PaginationStatus paginationStatus;
  final bool hasReachedMax;

  Chat({
    this.id,
    this.localId,
    this.photoPath,
    this.channelName,
    this.totalUnreadMessageCount,
    this.channelMembers,
    this.messages,
    this.paginationStatus = PaginationStatus.initial,
    this.hasReachedMax = false,
  });

  Chat copyWith({
    String? id,
    String? localId,
    dynamic photoPath,
    dynamic channelName,
    final PaginationStatus? paginationStatus,
    final bool? hasReachedMax,
    int? totalUnreadMessageCount,
    List<ChannelMember>? channelMembers,
    List<Message>? messages,
  }) =>
      Chat(
        id: id ?? this.id,
        localId: localId ?? this.localId,
        photoPath: photoPath ?? this.photoPath,
        channelName: channelName ?? this.channelName,
        totalUnreadMessageCount:
            totalUnreadMessageCount ?? this.totalUnreadMessageCount,
        channelMembers: channelMembers ?? this.channelMembers,
        messages: messages ?? this.messages,
        paginationStatus: paginationStatus ?? this.paginationStatus,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      );

  bool get isLoading => paginationStatus == PaginationStatus.loading;

  bool get isFailure => paginationStatus == PaginationStatus.failure;

  bool get isSuccess => paginationStatus == PaginationStatus.success;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"].toString(),
        photoPath: json["photo_path"],
        channelName: json["channel_name"],
        totalUnreadMessageCount: json["total_unread_message_count"],
        channelMembers: json["channel_members"] == null
            ? []
            : List<ChannelMember>.from(
                json["channel_members"]!.map((x) => ChannelMember.fromJson(x))),
        messages: json["messages"] == null
            ? []
            : List<Message>.from(
                json["messages"]!.map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "photo_path": photoPath,
        "total_unread_message_count": totalUnreadMessageCount,
        "channel_members": channelMembers == null
            ? []
            : List<dynamic>.from(channelMembers!.map((x) => x.toJson())),
        "messages": messages == null
            ? []
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
      };
}

class MediaMessageContent {
  final int? id;
  final String? filePath;
  final String? fileName;
  final String? messageId;
  final String? caption;

  MediaMessageContent({
    this.id,
    this.filePath,
    this.fileName,
    this.messageId,
    this.caption,
  });

  factory MediaMessageContent.fromJson(Map<String, dynamic> json) =>
      MediaMessageContent(
        id: json["id"],
        filePath: json["file_path"],
        fileName: json["file_name"],
        messageId: json["message_id"].toString(),
        caption: json["caption"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_path": filePath,
        "file_name": fileName,
        "message_id": messageId,
        "caption": caption,
      };
}

class MessageContent {
  final int? messageId;
  final String? content;

  MessageContent({
    this.messageId,
    this.content,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) => MessageContent(
        messageId: json["message_id"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "message_id": messageId,
        "content": content,
      };
}

class MessageStatus {
  final int? id;
  final int? userId;
  final dynamic isSent;
  final int? isReceived;
  final bool? isWatched;
  final DateTime? watchedAt;
  final DateTime? receivedAt;
  final DateTime? createdAt;

  MessageStatus({
    this.id,
    this.userId,
    this.isSent,
    this.isReceived,
    this.isWatched,
    this.watchedAt,
    this.receivedAt,
    this.createdAt,
  });

  MessageStatus copyWith({
    int? id,
    int? userId,
    dynamic isSent,
    int? isReceived,
    bool? isWatched,
    DateTime? watchedAt,
    DateTime? receivedAt,
    DateTime? createdAt,
  }) =>
      MessageStatus(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        isSent: isSent ?? this.isSent,
        isReceived: isReceived ?? this.isReceived,
        isWatched: isWatched ?? this.isWatched,
        watchedAt: watchedAt ?? this.watchedAt,
        receivedAt: receivedAt ?? this.receivedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  factory MessageStatus.fromJson(Map<String, dynamic> json) => MessageStatus(
        id: json["id"],
        userId: json["user_id"],
        isSent: json["is_sent"],
        isReceived: json["is_received"],
        isWatched: json["is_watched"],
        watchedAt: json["watched_at"] == null
            ? null
            : DateTime.parse(json["watched_at"]),
        receivedAt: json["received_at"] == null
            ? null
            : DateTime.parse(json["received_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "is_sent": isSent,
        "is_received": isReceived,
        "is_watched": isWatched,
        "watched_at": watchedAt?.toIso8601String(),
        "received_at": receivedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}

class MessageType {
  final String? name;

  MessageType({
    this.name,
  });

  factory MessageType.fromJson(Map<String, dynamic> json) => MessageType(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class ChannelMember {
  final String? channelId;
  final int? userId;
  final int? pin;
  final int? archived;
  final int? mute;
  final User? user;

  ChannelMember({
    this.channelId,
    this.userId,
    this.pin,
    this.archived,
    this.mute,
    this.user,
  });

  ChannelMember copyWith({
    String? channelId,
    int? userId,
    int? pin,
    int? archived,
    int? mute,
    User? user,
  }) =>
      ChannelMember(
        channelId: channelId ?? this.channelId,
        userId: userId ?? this.userId,
        pin: pin ?? this.pin,
        archived: archived ?? this.archived,
        mute: mute ?? this.mute,
        user: user ?? this.user,
      );

  factory ChannelMember.fromJson(Map<String, dynamic> json) => ChannelMember(
        channelId: json["channel_id"].toString(),
        userId: json["user_id"],
        pin: json["pin"],
        archived: json["archived"],
        mute: json["mute"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "channel_id": channelId,
        "user_id": userId,
        "pin": pin,
        "archived": archived,
        "mute": mute,
        "user": user?.toJson(),
      };
}

class User {
  final int? id;
  final String? mobilePhone;
  final dynamic photoPath;
  final String? name;

  User({
    this.id,
    this.mobilePhone,
    this.photoPath,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        mobilePhone: json["mobile_phone"],
        photoPath: json["photo_path"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mobile_phone": mobilePhone,
        "photo_path": photoPath,
        "name": name,
      };
}
