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
  final List<Data>? data;

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
    List<Data>? data,
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
            : List<Data>.from(json["data"]!.map((x) => Data.fromJson(x))),
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

class Data {
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
  final int? durationInSeconds;
  final dynamic messageContent;
  final MessageType? messageType;
  final Channel? channel;
  final dynamic parentMessage;
  final List<MessageStatus>? messageStatus;
  final List<dynamic>? messageFiles;

  Data({
    this.id,
    this.senderUserId,
    this.senderMobilePhone,
    this.receiverUserId,
    this.channelId,
    this.messageDescription,
    this.extraFields,
    this.parentMessageId,
    this.isForward,
    this.callStatus,
    this.createdAt,
    this.durationInSeconds,
    this.messageContent,
    this.messageType,
    this.channel,
    this.parentMessage,
    this.messageStatus,
    this.messageFiles,
  });

  Data copyWith({
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
    DateTime? createdAt,
    int? durationInSeconds,
    dynamic messageContent,
    MessageType? messageType,
    Channel? channel,
    dynamic parentMessage,
    List<MessageStatus>? messageStatus,
    List<dynamic>? messageFiles,
  }) =>
      Data(
        id: id ?? this.id,
        senderUserId: senderUserId ?? this.senderUserId,
        senderMobilePhone: senderMobilePhone ?? this.senderMobilePhone,
        receiverUserId: receiverUserId ?? this.receiverUserId,
        channelId: channelId ?? this.channelId,
        messageDescription: messageDescription ?? this.messageDescription,
        extraFields: extraFields ?? this.extraFields,
        parentMessageId: parentMessageId ?? this.parentMessageId,
        isForward: isForward ?? this.isForward,
        callStatus: callStatus ?? this.callStatus,
        createdAt: createdAt ?? this.createdAt,
        durationInSeconds: durationInSeconds ?? this.durationInSeconds,
        messageContent: messageContent ?? this.messageContent,
        messageType: messageType ?? this.messageType,
        channel: channel ?? this.channel,
        parentMessage: parentMessage ?? this.parentMessage,
        messageStatus: messageStatus ?? this.messageStatus,
        messageFiles: messageFiles ?? this.messageFiles,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        senderUserId: json["sender_user_id"],
        senderMobilePhone: json["sender_mobile_phone"],
        receiverUserId: json["receiver_user_id"],
        channelId: json["channel_id"],
        messageDescription: json["message_description"],
        extraFields: json["extra_fields"],
        parentMessageId: json["parent_message_id"],
        isForward: json["is_forward"],
        callStatus: json["call_status"] == null ? "null" : json["call_status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        durationInSeconds: json["duration_in_seconds"],
        messageContent: json["message_content"],
        messageType: json["message_type"] == null
            ? null
            : MessageType.fromJson(json["message_type"]),
        channel:
            json["channel"] == null ? null : Channel.fromJson(json["channel"]),
        parentMessage: json["parent_message"],
        messageStatus: json["message_status"] == null
            ? []
            : List<MessageStatus>.from(
                json["message_status"]!.map((x) => MessageStatus.fromJson(x))),
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
        "message_description": messageDescription,
        "extra_fields": extraFields,
        "parent_message_id": parentMessageId,
        "is_forward": isForward,
        "call_status": callStatus!,
        "created_at": createdAt?.toIso8601String(),
        "duration_in_seconds": durationInSeconds,
        "message_content": messageContent,
        "message_type": messageType?.toJson(),
        "channel": channel?.toJson(),
        "parent_message": parentMessage,
        "message_status": messageStatus == null
            ? []
            : List<dynamic>.from(messageStatus!.map((x) => x.toJson())),
        "message_files": messageFiles == null
            ? []
            : List<dynamic>.from(messageFiles!.map((x) => x)),
      };
}

//enum CallStatus { ANSWERED, REFUSE }

//final callStatusValues =
//  EnumValues({"answered": CallStatus.ANSWERED, "refuse": CallStatus.REFUSE});

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
        channelName: json["channel_name"],
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

// enum ChannelName { ANAS, MAHMOUD_FLUTTER, YASSER_OMRAN }

// final channelNameValues = EnumValues({
//   "Anas": ChannelName.ANAS,
//   "Mahmoud Flutter": ChannelName.MAHMOUD_FLUTTER,
//   "Yasser Omran": ChannelName.YASSER_OMRAN
// });

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
  final Name? name;
  final EventName? eventName;
  final DateTime? createdAt;

  MessageType({
    this.name,
    this.eventName,
    this.createdAt,
  });

  MessageType copyWith({
    Name? name,
    EventName? eventName,
    DateTime? createdAt,
  }) =>
      MessageType(
        name: name ?? this.name,
        eventName: eventName ?? this.eventName,
        createdAt: createdAt ?? this.createdAt,
      );

  factory MessageType.fromJson(Map<String, dynamic> json) => MessageType(
        name: nameValues.map[json["name"]]!,
        eventName: eventNameValues.map[json["event_name"]]!,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "name": nameValues.reverse[name],
        "event_name": eventNameValues.reverse[eventName],
        "created_at": createdAt?.toIso8601String(),
      };
}

enum EventName { VIDEO_CALL_EVENT, VOICE_CALL_EVENT }

final eventNameValues = EnumValues({
  "VideoCallEvent": EventName.VIDEO_CALL_EVENT,
  "VoiceCallEvent": EventName.VOICE_CALL_EVENT
});

enum Name { VIDEO_CALL, VOICE_CALL }

final nameValues =
    EnumValues({"VideoCall": Name.VIDEO_CALL, "VoiceCall": Name.VOICE_CALL});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
