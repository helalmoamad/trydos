// To parse this JSON data, do
//
//     final videoCallRemoteResponseModel = videoCallRemoteResponseModelFromJson(jsonString);

import 'dart:convert';

VideoCallRemoteResponseModel videoCallRemoteResponseModelFromJson(String str) => VideoCallRemoteResponseModel.fromJson(json.decode(str));

String videoCallRemoteResponseModelToJson(VideoCallRemoteResponseModel data) => json.encode(data.toJson());

class VideoCallRemoteResponseModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  dynamic message;
  dynamic detailedError;
  Data? data;

  VideoCallRemoteResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  VideoCallRemoteResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      VideoCallRemoteResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory VideoCallRemoteResponseModel.fromJson(Map<String, dynamic> json) => VideoCallRemoteResponseModel(
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
  Message? message;
  String? token;

  Data({
    this.message,
    this.token,
  });

  Data copyWith({
    Message? message,
    String? token,
  }) =>
      Data(
        message: message ?? this.message,
        token: token ?? this.token,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    message: json["message"] == null ? null : Message.fromJson(json["message"]),
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "message": message?.toJson(),
    "token": token,
  };
}

class Message {
  int? senderUserId;
  int? receiverUserId;
  String? messageType;
  int? channelId;
  String? userAgent;
  DateTime? createdAt;
  int? id;
  dynamic body;
  dynamic image;
  Channel? channel;
  dynamic messageContent;

  Message({
    this.senderUserId,
    this.receiverUserId,
    this.messageType,
    this.channelId,
    this.userAgent,
    this.createdAt,
    this.id,
    this.body,
    this.image,
    this.channel,
    this.messageContent,
  });

  Message copyWith({
    int? senderUserId,
    int? receiverUserId,
    String? messageType,
    int? channelId,
    String? userAgent,
    DateTime? createdAt,
    int? id,
    dynamic body,
    dynamic image,
    Channel? channel,
    dynamic messageContent,
  }) =>
      Message(
        senderUserId: senderUserId ?? this.senderUserId,
        receiverUserId: receiverUserId ?? this.receiverUserId,
        messageType: messageType ?? this.messageType,
        channelId: channelId ?? this.channelId,
        userAgent: userAgent ?? this.userAgent,
        createdAt: createdAt ?? this.createdAt,
        id: id ?? this.id,
        body: body ?? this.body,
        image: image ?? this.image,
        channel: channel ?? this.channel,
        messageContent: messageContent ?? this.messageContent,
      );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    senderUserId: json["sender_user_id"],
    receiverUserId: json["receiver_user_id"],
    messageType: json["message_type"],
    channelId: json["channel_id"],
    userAgent: json["user_agent"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
    body: json["body"],
    image: json["image"],
    channel: json["channel"] == null ? null : Channel.fromJson(json["channel"]),
    messageContent: json["message_content"],
  );

  Map<String, dynamic> toJson() => {
    "sender_user_id": senderUserId,
    "receiver_user_id": receiverUserId,
    "message_type": messageType,
    "channel_id": channelId,
    "user_agent": userAgent,
    "created_at": createdAt?.toIso8601String(),
    "id": id,
    "body": body,
    "image": image,
    "channel": channel?.toJson(),
    "message_content": messageContent,
  };
}

class Channel {
  int? id;
  int? ownerUserId;
  dynamic isAllowedByUserId;
  dynamic isChatAllowed;
  dynamic isMaskedByCustomerService;
  dynamic photoPath;
  dynamic opensAt;
  dynamic closesAt;
  DateTime? createdAt;
  int? channelTypeId;
  dynamic ownerRoleId;
  int? isLockedByAdminForDelete;
  int? isLockedByAdminForUpdate;
  String? pusherChannelName;
  List<ChannelMember>? channelMembers;

  Channel({
    this.id,
    this.ownerUserId,
    this.isAllowedByUserId,
    this.isChatAllowed,
    this.isMaskedByCustomerService,
    this.photoPath,
    this.opensAt,
    this.closesAt,
    this.createdAt,
    this.channelTypeId,
    this.ownerRoleId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.pusherChannelName,
    this.channelMembers,
  });

  Channel copyWith({
    int? id,
    int? ownerUserId,
    dynamic isAllowedByUserId,
    dynamic isChatAllowed,
    dynamic isMaskedByCustomerService,
    dynamic photoPath,
    dynamic opensAt,
    dynamic closesAt,
    DateTime? createdAt,
    int? channelTypeId,
    dynamic ownerRoleId,
    int? isLockedByAdminForDelete,
    int? isLockedByAdminForUpdate,
    String? pusherChannelName,
    List<ChannelMember>? channelMembers,
  }) =>
      Channel(
        id: id ?? this.id,
        ownerUserId: ownerUserId ?? this.ownerUserId,
        isAllowedByUserId: isAllowedByUserId ?? this.isAllowedByUserId,
        isChatAllowed: isChatAllowed ?? this.isChatAllowed,
        isMaskedByCustomerService: isMaskedByCustomerService ?? this.isMaskedByCustomerService,
        photoPath: photoPath ?? this.photoPath,
        opensAt: opensAt ?? this.opensAt,
        closesAt: closesAt ?? this.closesAt,
        createdAt: createdAt ?? this.createdAt,
        channelTypeId: channelTypeId ?? this.channelTypeId,
        ownerRoleId: ownerRoleId ?? this.ownerRoleId,
        isLockedByAdminForDelete: isLockedByAdminForDelete ?? this.isLockedByAdminForDelete,
        isLockedByAdminForUpdate: isLockedByAdminForUpdate ?? this.isLockedByAdminForUpdate,
        pusherChannelName: pusherChannelName ?? this.pusherChannelName,
        channelMembers: channelMembers ?? this.channelMembers,
      );

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json["id"],
    ownerUserId: json["owner_user_id"],
    isAllowedByUserId: json["is_allowed_by_user_id"],
    isChatAllowed: json["is_chat_allowed"],
    isMaskedByCustomerService: json["is_masked_by_customer_service"],
    photoPath: json["photo_path"],
    opensAt: json["opens_at"],
    closesAt: json["closes_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    channelTypeId: json["channel_type_id"],
    ownerRoleId: json["owner_role_id"],
    isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
    isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
    pusherChannelName: json["pusher_channel_name"],
    channelMembers: json["channel_members"] == null ? [] : List<ChannelMember>.from(json["channel_members"]!.map((x) => ChannelMember.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "owner_user_id": ownerUserId,
    "is_allowed_by_user_id": isAllowedByUserId,
    "is_chat_allowed": isChatAllowed,
    "is_masked_by_customer_service": isMaskedByCustomerService,
    "photo_path": photoPath,
    "opens_at": opensAt,
    "closes_at": closesAt,
    "created_at": createdAt?.toIso8601String(),
    "channel_type_id": channelTypeId,
    "owner_role_id": ownerRoleId,
    "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
    "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
    "pusher_channel_name": pusherChannelName,
    "channel_members": channelMembers == null ? [] : List<dynamic>.from(channelMembers!.map((x) => x.toJson())),
  };
}

class ChannelMember {
  int? id;
  int? channelId;
  int? userId;
  dynamic isAllowedToChat;
  int? pin;
  int? archived;
  int? mute;
  DateTime? createdAt;
  int? isAdmin;
  dynamic roleId;
  int? isLockedByAdminForDelete;
  int? isLockedByAdminForUpdate;
  dynamic userType;
  dynamic mobilePhone;
  int? totalUnreadMessageCount;

  ChannelMember({
    this.id,
    this.channelId,
    this.userId,
    this.isAllowedToChat,
    this.pin,
    this.archived,
    this.mute,
    this.createdAt,
    this.isAdmin,
    this.roleId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.userType,
    this.mobilePhone,
    this.totalUnreadMessageCount,
  });

  ChannelMember copyWith({
    int? id,
    int? channelId,
    int? userId,
    dynamic isAllowedToChat,
    int? pin,
    int? archived,
    int? mute,
    DateTime? createdAt,
    int? isAdmin,
    dynamic roleId,
    int? isLockedByAdminForDelete,
    int? isLockedByAdminForUpdate,
    dynamic userType,
    dynamic mobilePhone,
    int? totalUnreadMessageCount,
  }) =>
      ChannelMember(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        userId: userId ?? this.userId,
        isAllowedToChat: isAllowedToChat ?? this.isAllowedToChat,
        pin: pin ?? this.pin,
        archived: archived ?? this.archived,
        mute: mute ?? this.mute,
        createdAt: createdAt ?? this.createdAt,
        isAdmin: isAdmin ?? this.isAdmin,
        roleId: roleId ?? this.roleId,
        isLockedByAdminForDelete: isLockedByAdminForDelete ?? this.isLockedByAdminForDelete,
        isLockedByAdminForUpdate: isLockedByAdminForUpdate ?? this.isLockedByAdminForUpdate,
        userType: userType ?? this.userType,
        mobilePhone: mobilePhone ?? this.mobilePhone,
        totalUnreadMessageCount: totalUnreadMessageCount ?? this.totalUnreadMessageCount,
      );

  factory ChannelMember.fromJson(Map<String, dynamic> json) => ChannelMember(
    id: json["id"],
    channelId: json["channel_id"],
    userId: json["user_id"],
    isAllowedToChat: json["is_allowed_to_chat"],
    pin: json["pin"],
    archived: json["archived"],
    mute: json["mute"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    isAdmin: json["is_admin"],
    roleId: json["role_id"],
    isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
    isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
    userType: json["user_type"],
    mobilePhone: json["mobile_phone"],
    totalUnreadMessageCount: json["total_unread_message_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "channel_id": channelId,
    "user_id": userId,
    "is_allowed_to_chat": isAllowedToChat,
    "pin": pin,
    "archived": archived,
    "mute": mute,
    "created_at": createdAt?.toIso8601String(),
    "is_admin": isAdmin,
    "role_id": roleId,
    "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
    "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
    "user_type": userType,
    "mobile_phone": mobilePhone,
    "total_unread_message_count": totalUnreadMessageCount,
  };
}
