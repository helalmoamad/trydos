// To parse this JSON data, do
//
//     final myCallsResponseModel = myCallsResponseModelFromJson(jsonString);

import 'dart:convert';

MyCallsResponseModel myCallsResponseModelFromJson(String str) =>
    MyCallsResponseModel.fromJson(json.decode(str));

String myCallsResponseModelToJson(MyCallsResponseModel data) =>
    json.encode(data.toJson());

class MyCallsResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final List<CallReg>? data;

  MyCallsResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  MyCallsResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    List<CallReg>? data,
  }) =>
      MyCallsResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory MyCallsResponseModel.fromJson(Map<String, dynamic> json) =>
      MyCallsResponseModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null
            ? []
            : List<CallReg>.from(json["data"]!.map((x) => CallReg.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CallReg {
  final String? id;
  final int? senderUserId;
  final dynamic senderMobilePhone;
  final int? receiverUserId;
  final String? channelId;
  final dynamic messageDescription;
  final dynamic extraFields;
  final String? parentMessageId;
  final int? isForward;
  final String? callStatus;
  final DateTime? createdAt;
  final int? deletedByUserId;
  final int? durationInSeconds;
  final dynamic messageContent;
  final MessageType? messageType;
  final SenderUser? senderUser;
  final Channel? channel;
  final dynamic parentMessage;
  final MessagesStatus? authMessageStatus;
  final List<MessagesStatus>? messagesStatus;
  final List<dynamic>? messageFiles;

  CallReg({
    this.id,
    this.senderUserId,
    this.senderMobilePhone,
    this.authMessageStatus,
    this.receiverUserId,
    this.channelId,
    this.messageDescription,
    this.extraFields,
    this.parentMessageId,
    this.isForward,
    this.callStatus,
    this.createdAt,
    this.durationInSeconds,
    this.deletedByUserId,
    this.messageContent,
    this.messageType,
    this.senderUser,
    this.channel,
    this.parentMessage,
    this.messagesStatus,
    this.messageFiles,
  });

  CallReg copyWith({
    String? id,
    int? senderUserId,
    dynamic senderMobilePhone,
    int? receiverUserId,
    String? channelId,
    dynamic messageDescription,
    dynamic extraFields,
    String? parentMessageId,
    int? isForward,
    String? callStatus,
    int? deletedByUserId,
    DateTime? createdAt,
    int? durationInSeconds,
    MessagesStatus? authMessageStatus,
    dynamic messageContent,
    MessageType? messageType,
    SenderUser? senderUser,
    Channel? channel,
    dynamic parentMessage,
    List<MessagesStatus>? messageStatus,
    List<dynamic>? messageFiles,
  }) =>
      CallReg(
        id: id ?? this.id,
        senderUserId: senderUserId ?? this.senderUserId,
        senderMobilePhone: senderMobilePhone ?? this.senderMobilePhone,
        receiverUserId: receiverUserId ?? this.receiverUserId,
        channelId: channelId ?? this.channelId,
        messageDescription: messageDescription ?? this.messageDescription,
        extraFields: extraFields ?? this.extraFields,
        parentMessageId: parentMessageId ?? this.parentMessageId,
        deletedByUserId: deletedByUserId ?? this.deletedByUserId,
        isForward: isForward ?? this.isForward,
        callStatus: callStatus ?? this.callStatus,
        createdAt: createdAt ?? this.createdAt,
        durationInSeconds: durationInSeconds ?? this.durationInSeconds,
        messageContent: messageContent ?? this.messageContent,
        messageType: messageType ?? this.messageType,
        senderUser: senderUser ?? this.senderUser,
        channel: channel ?? this.channel,
        authMessageStatus: authMessageStatus ?? this.authMessageStatus,
        parentMessage: parentMessage ?? this.parentMessage,
        messagesStatus: messageStatus ?? this.messagesStatus,
        messageFiles: messageFiles ?? this.messageFiles,
      );

  factory CallReg.fromJson(Map<String, dynamic> json) => CallReg(
        id: json["id"],
        senderUserId: json["sender_user_id"],
        senderMobilePhone: json["sender_mobile_phone"],
        receiverUserId: json["receiver_user_id"],
        channelId: json["channel_id"],
        deletedByUserId: json["deleted_by_user_id"],
        messageDescription: json["message_description"],
        extraFields: json["extra_fields"],
        parentMessageId: json["parent_message_id"],
        isForward: json["is_forward"],
        callStatus: json["call_status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        durationInSeconds: json["duration_in_seconds"],
        messageContent: json["message_content"],
        messageType: json["message_type"] == null
            ? null
            : MessageType.fromJson(json["message_type"]),
        senderUser: json["sender_user"] == null
            ? null
            : SenderUser.fromJson(json["sender_user"]),
        channel:
            json["channel"] == null ? null : Channel.fromJson(json["channel"]),
        parentMessage: json["parent_message"],
        authMessageStatus: json["auth_message_status"] == null
            ? null
            : MessagesStatus.fromJson(json["auth_message_status"]),
        messagesStatus: json["message_status"] == null
            ? []
            : List<MessagesStatus>.from(
                json["message_status"]!.map((x) => MessagesStatus.fromJson(x))),
        messageFiles: json["message_files"] == null
            ? []
            : List<dynamic>.from(json["message_files"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sender_user_id": senderUserId,
        "sender_mobile_phone": senderMobilePhone,
        "receiver_user_id": receiverUserId,
        "channel_id": channelId,
        "deleted_by_user_id": deletedByUserId,
        "message_description": messageDescription,
        "extra_fields": extraFields,
        "parent_message_id": parentMessageId,
        "is_forward": isForward,
        "call_status": callStatus,
        "auth_message_status": authMessageStatus?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "duration_in_seconds": durationInSeconds,
        "message_content": messageContent,
        "message_type": messageType?.toJson(),
        "sender_user": senderUser?.toJson(),
        "channel": channel?.toJson(),
        "parent_message": parentMessage,
        "message_status": messagesStatus == null
            ? []
            : List<dynamic>.from(messagesStatus!.map((x) => x.toJson())),
        "message_files": messageFiles == null
            ? []
            : List<dynamic>.from(messageFiles!.map((x) => x)),
      };
}

class Channel {
  final String? id;
  final String? channelName;
  final dynamic photoPath;
  final int? totalUnreadMessageCount;
  final DateTime? createdAt;
  final List<ChannelMember>? channelMembers;

  Channel({
    this.id,
    this.channelName,
    this.photoPath,
    this.totalUnreadMessageCount,
    this.createdAt,
    this.channelMembers,
  });

  Channel copyWith({
    String? id,
    String? channelName,
    dynamic photoPath,
    int? totalUnreadMessageCount,
    DateTime? createdAt,
    List<ChannelMember>? channelMembers,
  }) =>
      Channel(
        id: id ?? this.id,
        channelName: channelName ?? this.channelName,
        photoPath: photoPath ?? this.photoPath,
        totalUnreadMessageCount:
            totalUnreadMessageCount ?? this.totalUnreadMessageCount,
        createdAt: createdAt ?? this.createdAt,
        channelMembers: channelMembers ?? this.channelMembers,
      );

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json["id"],
        channelName: json["channel_name"]!,
        photoPath: json["photo_path"],
        totalUnreadMessageCount: json["total_unread_message_count"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        channelMembers: json["channel_members"] == null
            ? []
            : List<ChannelMember>.from(
                json["channel_members"]!.map((x) => ChannelMember.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_name": channelName,
        "photo_path": photoPath,
        "total_unread_message_count": totalUnreadMessageCount,
        "created_at": createdAt?.toIso8601String(),
        "channel_members": channelMembers == null
            ? []
            : List<dynamic>.from(channelMembers!.map((x) => x.toJson())),
      };
}

class ChannelMember {
  final int? id;
  final int? userId;
  final dynamic isAllowedToChat;
  final int? isAdmin;
  final int? mute;
  final int? archived;
  final int? pin;
  final DateTime? createdAt;

  ChannelMember({
    this.id,
    this.userId,
    this.isAllowedToChat,
    this.isAdmin,
    this.mute,
    this.archived,
    this.pin,
    this.createdAt,
  });

  ChannelMember copyWith({
    int? id,
    int? userId,
    dynamic isAllowedToChat,
    int? isAdmin,
    int? mute,
    int? archived,
    int? pin,
    DateTime? createdAt,
  }) =>
      ChannelMember(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        isAllowedToChat: isAllowedToChat ?? this.isAllowedToChat,
        isAdmin: isAdmin ?? this.isAdmin,
        mute: mute ?? this.mute,
        archived: archived ?? this.archived,
        pin: pin ?? this.pin,
        createdAt: createdAt ?? this.createdAt,
      );

  factory ChannelMember.fromJson(Map<String, dynamic> json) => ChannelMember(
        id: json["id"],
        userId: json["user_id"],
        isAllowedToChat: json["is_allowed_to_chat"],
        isAdmin: json["is_admin"],
        mute: json["mute"],
        archived: json["archived"],
        pin: json["pin"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "is_allowed_to_chat": isAllowedToChat,
        "is_admin": isAdmin,
        "mute": mute,
        "archived": archived,
        "pin": pin,
        "created_at": createdAt?.toIso8601String(),
      };
}

class MessagesStatus {
  final int? id;
  final int? userId;
  final dynamic isSent;
  final int? isReceived;
  final bool? isWatched;
  final DateTime? watchedAt;
  final DateTime? receivedAt;
  final DateTime? createdAt;
  final int? isDeleted;
  final bool? deleteForAll;
  final DateTime? messageDeletedAt;

  MessagesStatus({
    this.id,
    this.userId,
    this.isSent,
    this.isReceived,
    this.isWatched,
    this.watchedAt,
    this.receivedAt,
    this.createdAt,
    this.isDeleted,
    this.deleteForAll,
    this.messageDeletedAt,
  });

  MessagesStatus copyWith({
    int? id,
    int? userId,
    dynamic isSent,
    int? isReceived,
    bool? isWatched,
    DateTime? watchedAt,
    int? isDeleted,
    bool? deleteForAll,
    DateTime? messageDeletedAt,
    DateTime? receivedAt,
    DateTime? createdAt,
  }) =>
      MessagesStatus(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        isDeleted: isDeleted ?? this.isDeleted,
        deleteForAll: deleteForAll ?? this.deleteForAll,
        messageDeletedAt: messageDeletedAt ?? this.messageDeletedAt,
        isSent: isSent ?? this.isSent,
        isReceived: isReceived ?? this.isReceived,
        isWatched: isWatched ?? this.isWatched,
        watchedAt: watchedAt ?? this.watchedAt,
        receivedAt: receivedAt ?? this.receivedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  factory MessagesStatus.fromJson(Map<String, dynamic> json) => MessagesStatus(
        id: json["id"],
        isDeleted: json["is_deleted"],
        deleteForAll: json["delete_for_all"],
        messageDeletedAt: json["message_deleted_at"] == null
            ? null
            : DateTime.parse(json["message_deleted_at"]),
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
        "is_deleted": isDeleted,
        "delete_for_all": deleteForAll,
        "message_deleted_at": messageDeletedAt?.toIso8601String(),
        "is_received": isReceived,
        "is_watched": isWatched,
        "watched_at": watchedAt?.toIso8601String(),
        "received_at": receivedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}

class MessageType {
  final String? name;
  final String? eventName;
  final DateTime? createdAt;

  MessageType({
    this.name,
    this.eventName,
    this.createdAt,
  });

  MessageType copyWith({
    String? name,
    String? eventName,
    DateTime? createdAt,
  }) =>
      MessageType(
        name: name ?? this.name,
        eventName: eventName ?? this.eventName,
        createdAt: createdAt ?? this.createdAt,
      );

  factory MessageType.fromJson(Map<String, dynamic> json) => MessageType(
        name: json["name"],
        eventName: json["event_name"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "event_name": eventName,
        "created_at": createdAt?.toIso8601String(),
      };
}

class SenderUser {
  final int? id;
  final String? name;
  final String? username;
  final String? mobilePhone;
  final dynamic photoPath;
  final DateTime? createdAt;
  final dynamic accessToken;
  final ContactUser? contactUser;

  SenderUser({
    this.id,
    this.name,
    this.username,
    this.mobilePhone,
    this.photoPath,
    this.createdAt,
    this.accessToken,
    this.contactUser,
  });

  SenderUser copyWith({
    int? id,
    String? name,
    String? username,
    String? mobilePhone,
    dynamic photoPath,
    DateTime? createdAt,
    dynamic accessToken,
    ContactUser? contactUser,
  }) =>
      SenderUser(
        id: id ?? this.id,
        name: name ?? this.name,
        username: username ?? this.username,
        mobilePhone: mobilePhone ?? this.mobilePhone,
        photoPath: photoPath ?? this.photoPath,
        createdAt: createdAt ?? this.createdAt,
        accessToken: accessToken ?? this.accessToken,
        contactUser: contactUser ?? this.contactUser,
      );

  factory SenderUser.fromJson(Map<String, dynamic> json) => SenderUser(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        mobilePhone: json["mobile_phone"],
        photoPath: json["photo_path"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        accessToken: json["access_token"],
        contactUser: json["contact_user"] == null
            ? null
            : ContactUser.fromJson(json["contact_user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "mobile_phone": mobilePhone,
        "photo_path": photoPath,
        "created_at": createdAt?.toIso8601String(),
        "access_token": accessToken,
        "contact_user": contactUser?.toJson(),
      };
}

class ContactUser {
  final int? id;
  final int? userId;
  final String? name;
  final String? mobilePhone;
  final int? contactUserId;

  ContactUser({
    this.id,
    this.userId,
    this.name,
    this.mobilePhone,
    this.contactUserId,
  });

  ContactUser copyWith({
    int? id,
    int? userId,
    String? name,
    String? mobilePhone,
    int? contactUserId,
  }) =>
      ContactUser(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        mobilePhone: mobilePhone ?? this.mobilePhone,
        contactUserId: contactUserId ?? this.contactUserId,
      );

  factory ContactUser.fromJson(Map<String, dynamic> json) => ContactUser(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        mobilePhone: json["mobile_phone"],
        contactUserId: json["contact_user_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "mobile_phone": mobilePhone,
        "contact_user_id": contactUserId,
      };
}
