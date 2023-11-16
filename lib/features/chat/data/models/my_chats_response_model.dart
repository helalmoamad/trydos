import 'dart:convert';
import 'dart:io';

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

  Data({
    this.chats,
    this.pinnedChats,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        chats: json["channels"] == null
            ? []
            : List<Chat>.from(json["channels"]!.map((x) => Chat.fromJson(x))),
        pinnedChats: json["pinned_channels"] == null
            ? []
            : List<Chat>.from(
                json["pinned_channels"]!.map((x) => Chat.fromJson(x))),
      );

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
  //todo local variable
  final int? width;

  //todo local variable
  final int? height;

  final bool checkedExistence;
  final String? id;
  final String? localId;
  final String? localParentMessageId;
  final int? senderUserId;
  final int? receiverUserId;
  final String? channelId;
  final DateTime? createdAt;
  final MessageType? messageType;
  final dynamic predefinedEmotionId;
  final String? predefinedMessageId;
  final dynamic messageStatusId;
  final dynamic taskId;
  final List<dynamic>? extraFields;
  final dynamic productId;
  final dynamic serviceId;
  final dynamic offerId;
  final int? senderRoleId;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final String? parentMessageId;
  final int? isForward;
  final dynamic senderMobilePhone;
  final dynamic senderWhatsappContact;
  final int? isFromWhatsapp;
  final MessageContent? messageContent;
  final List<MediaMessageContent>? mediaMessageContent;
  final String? body;
  final dynamic image;
  final List<MessageStatus>? messageStatus;
  final Chat? channel;
  final Message? parentMessage;
  final SenderInfo? senderInfo;
  final File? file;
  bool isFirstMessageForThisDay;
  bool isFirstMessage;
  bool isDateMessage;
  String dateValue;

  Message({
    this.width = 0,
    this.height = 0,
    this.isFirstMessageForThisDay = false,
    this.checkedExistence = false,
    this.isDateMessage = false,
    this.dateValue = '',
    this.isFirstMessage = false,
    this.id,
    this.senderUserId,
    this.localParentMessageId,
    this.senderInfo,
    this.receiverUserId,
    this.channelId,
    this.createdAt,
    this.messageType,
    this.predefinedEmotionId,
    this.predefinedMessageId,
    this.file,
    this.messageStatusId,
    this.taskId,
    this.extraFields,
    this.productId,
    this.serviceId,
    this.offerId,
    this.localId,
    this.senderRoleId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.parentMessageId,
    this.isForward,
    this.senderMobilePhone,
    this.senderWhatsappContact,
    this.isFromWhatsapp,
    this.messageContent,
    this.body,
    this.image,
    this.messageStatus,
    this.mediaMessageContent,
    this.channel,
    this.parentMessage,
  });

  Message copyWith({
    final int? width,
    final int? height,
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
    final dynamic predefinedEmotionId,
    final bool? checkedExistence,
    final String? predefinedMessageId,
    final dynamic messageStatusId,
    final dynamic taskId,
    final List<dynamic>? extraFields,
    final dynamic productId,
    final dynamic serviceId,
    final dynamic offerId,
    final int? senderRoleId,
    final int? isLockedByAdminForDelete,
    final int? isLockedByAdminForUpdate,
    final String? parentMessageId,
    final int? isForward,
    final dynamic senderMobilePhone,
    final dynamic senderWhatsappContact,
    final int? isFromWhatsapp,
    final MessageContent? messageContent,
    final List<MediaMessageContent>? mediaMessageContent,
    final String? body,
    final dynamic image,
    final List<MessageStatus>? messageStatus,
    final Chat? channel,
    final Message? parentMessage,
    final SenderInfo? senderInfo,
    final File? file,
  }) {
    return Message(
      height: height??this.height,

width: width??this.width,
      id: id ?? this.id,
      localId: localId ?? this.localId,
      localParentMessageId: localParentMessageId ?? this.localParentMessageId,
      isLockedByAdminForDelete:
          isLockedByAdminForDelete ?? this.isLockedByAdminForDelete,
      isLockedByAdminForUpdate:
          isLockedByAdminForUpdate ?? this.isLockedByAdminForUpdate,
      senderUserId: senderUserId ?? this.senderUserId,
      senderInfo: senderInfo ?? this.senderInfo,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      checkedExistence: checkedExistence ?? this.checkedExistence,
      channelId: channelId ?? this.channelId,
      createdAt: createdAt ?? this.createdAt,
      messageType: messageType ?? this.messageType,
      predefinedEmotionId: predefinedEmotionId ?? this.predefinedEmotionId,
      predefinedMessageId: predefinedMessageId ?? this.predefinedMessageId,
      file: file ?? this.file,
      messageStatusId: messageStatusId ?? this.messageStatusId,
      taskId: taskId ?? this.taskId,
      extraFields: extraFields ?? this.extraFields,
      productId: productId ?? this.productId,
      serviceId: serviceId ?? this.serviceId,
      offerId: offerId ?? this.offerId,
      senderRoleId: senderRoleId ?? this.senderRoleId,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      isForward: isForward ?? this.isForward,
      senderMobilePhone: senderMobilePhone ?? this.senderMobilePhone,
      senderWhatsappContact:
          senderWhatsappContact ?? this.senderWhatsappContact,
      isFromWhatsapp: isFromWhatsapp ?? this.isFromWhatsapp,
      messageContent: messageContent ?? this.messageContent,
      body: body ?? this.body,
      isFirstMessageForThisDay:
          isFirstMessageForThisDay ?? this.isFirstMessageForThisDay,
      isFirstMessage: isFirstMessage ?? this.isFirstMessage,
      image: image ?? this.image,
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
        senderInfo: json['sender_user'] == null
            ? null
            : SenderInfo.fromJson(json['sender_user']),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        messageType: json["message_type"] == null
            ? null
            : MessageType.fromJson(json["message_type"]),
        predefinedEmotionId: json["predefined_emotion_id"],
        predefinedMessageId: json["predefined_message_id"],
        messageStatusId: json["message_status_id"],
        taskId: json["task_id"],
        extraFields: json["extra_fields"] == null
            ? []
            : List<dynamic>.from(json["extra_fields"]!.map((x) => x)),
        productId: json["product_id"],
        serviceId: json["service_id"],
        offerId: json["offer_id"],
        senderRoleId: json["sender_role_id"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        parentMessageId: json["parent_message_id"]?.toString(),
        isForward: (json["is_forward"] is bool)
            ? (json["is_forward"] ? 1 : 0)
            : json["is_forward"],
        senderMobilePhone: json["sender_mobile_phone"],
        senderWhatsappContact: json["sender_whatsapp_contact"],
        isFromWhatsapp: json["is_from_whatsapp"],
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
        body: json["body"],
        image: json["image"],
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
        "predefined_emotion_id": predefinedEmotionId,
        "predefined_message_id": predefinedMessageId,
        "message_status_id": messageStatusId,
        "task_id": taskId,
        "extra_fields": extraFields == null
            ? []
            : List<dynamic>.from(extraFields!.map((x) => x)),
        "product_id": productId,
        "service_id": serviceId,
        "offer_id": offerId,
        "sender_role_id": senderRoleId,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "parent_message_id": parentMessageId,
        "is_forward": isForward,
        "sender_mobile_phone": senderMobilePhone,
        "sender_whatsapp_contact": senderWhatsappContact,
        "is_from_whatsapp": isFromWhatsapp,
        "message_content": messageContent?.toJson(),
        "body": body,
        "image": image,
        "message_status": messageStatus == null
            ? []
            : List<dynamic>.from(messageStatus!.map((x) => x.toJson())),
        "channel": channel?.toJson(),
        "parent_message": parentMessage,
      };
}

enum PaginationStatus { initial, success, failure, loading }

class Chat {
  final String? id;
  final String? localId;
  final int? ownerUserId;
  final dynamic isAllowedByUserId;
  final dynamic isChatAllowed;
  final dynamic isMaskedByCustomerService;
  final dynamic photoPath;
  final DateTime? opensAt;
  final dynamic closesAt;
  final int? channelTypeId;
  final int? ownerRoleId;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final int? totalUnreadMessageCount;
  final String? pusherChannelName;
  final List<dynamic>? channelTranslations;
  final List<ChannelMember>? channelMembers;
  final ChannelType? channelType;
  final List<Message>? messages;
  final PaginationStatus paginationStatus;
  final bool hasReachedMax;

  Chat({
    this.id,
    this.localId,
    this.ownerUserId,
    this.isAllowedByUserId,
    this.isChatAllowed,
    this.isMaskedByCustomerService,
    this.photoPath,
    this.opensAt,
    this.closesAt,
    this.channelTypeId,
    this.ownerRoleId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.totalUnreadMessageCount,
    this.pusherChannelName,
    this.channelTranslations,
    this.channelMembers,
    this.channelType,
    this.messages,
    this.paginationStatus = PaginationStatus.initial,
    this.hasReachedMax = false,
  });

  Chat copyWith({
    String? id,
    String? localId,
    int? ownerUserId,
    dynamic isAllowedByUserId,
    dynamic isChatAllowed,
    dynamic isMaskedByCustomerService,
    dynamic photoPath,
    DateTime? opensAt,
    dynamic closesAt,
    int? channelTypeId,
    final PaginationStatus? paginationStatus,
    final bool? hasReachedMax,
    dynamic ownerRoleId,
    int? isLockedByAdminForDelete,
    int? isLockedByAdminForUpdate,
    int? totalUnreadMessageCount,
    String? pusherChannelName,
    List<dynamic>? channelTranslations,
    List<ChannelMember>? channelMembers,
    ChannelType? channelType,
    List<Message>? messages,
  }) =>
      Chat(
        id: id ?? this.id,
        localId: localId ?? this.localId,
        ownerUserId: ownerUserId ?? this.ownerUserId,
        isAllowedByUserId: isAllowedByUserId ?? this.isAllowedByUserId,
        isChatAllowed: isChatAllowed ?? this.isChatAllowed,
        isMaskedByCustomerService:
            isMaskedByCustomerService ?? this.isMaskedByCustomerService,
        photoPath: photoPath ?? this.photoPath,
        opensAt: opensAt ?? this.opensAt,
        closesAt: closesAt ?? this.closesAt,
        channelTypeId: channelTypeId ?? this.channelTypeId,
        ownerRoleId: ownerRoleId ?? this.ownerRoleId,
        isLockedByAdminForDelete:
            isLockedByAdminForDelete ?? this.isLockedByAdminForDelete,
        isLockedByAdminForUpdate:
            isLockedByAdminForUpdate ?? this.isLockedByAdminForUpdate,
        totalUnreadMessageCount:
            totalUnreadMessageCount ?? this.totalUnreadMessageCount,
        pusherChannelName: pusherChannelName ?? this.pusherChannelName,
        channelTranslations: channelTranslations ?? this.channelTranslations,
        channelMembers: channelMembers ?? this.channelMembers,
        channelType: channelType ?? this.channelType,
        messages: messages ?? this.messages,
        paginationStatus: paginationStatus ?? this.paginationStatus,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      );

  bool get isLoading => paginationStatus == PaginationStatus.loading;

  bool get isFailure => paginationStatus == PaginationStatus.failure;

  bool get isSuccess => paginationStatus == PaginationStatus.success;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"].toString(),
        ownerUserId: json["owner_user_id"],
        isAllowedByUserId: json["is_allowed_by_user_id"],
        isChatAllowed: json["is_chat_allowed"],
        isMaskedByCustomerService: json["is_masked_by_customer_service"],
        photoPath: json["photo_path"],
        opensAt: json["opens_at"],
        closesAt: json["closes_at"],
        channelTypeId: json["channel_type_id"],
        ownerRoleId: json["owner_role_id"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        totalUnreadMessageCount: json["total_unread_message_count"],
        pusherChannelName: json["pusher_channel_name"],
        channelTranslations: json["channel_translations"] == null
            ? []
            : List<dynamic>.from(json["channel_translations"]!.map((x) => x)),
        channelMembers: json["channel_members"] == null
            ? []
            : List<ChannelMember>.from(
                json["channel_members"]!.map((x) => ChannelMember.fromJson(x))),
        channelType: json["channel_type"] == null
            ? null
            : ChannelType.fromJson(json["channel_type"]),
        messages: json["messages"] == null
            ? []
            : List<Message>.from(
                json["messages"]!.map((x) => Message.fromJson(x))),
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
        "channel_type_id": channelTypeId,
        "owner_role_id": ownerRoleId,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "total_unread_message_count": totalUnreadMessageCount,
        "pusher_channel_name": pusherChannelName,
        "channel_translations": channelTranslations == null
            ? []
            : List<dynamic>.from(channelTranslations!.map((x) => x)),
        "channel_members": channelMembers == null
            ? []
            : List<dynamic>.from(channelMembers!.map((x) => x.toJson())),
        "channel_type": channelType?.toJson(),
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
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final String? caption;

  MediaMessageContent({
    this.id,
    this.filePath,
    this.fileName,
    this.messageId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.caption,
  });

  factory MediaMessageContent.fromJson(Map<String, dynamic> json) =>
      MediaMessageContent(
        id: json["id"],
        filePath: json["file_path"],
        fileName: json["file_name"],
        messageId: json["message_id"].toString(),
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        caption: json["caption"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_path": filePath,
        "file_name": fileName,
        "message_id": messageId,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "caption": caption,
      };
}

class MessageContent {
  final int? messageId;
  final String? content;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;

  MessageContent({
    this.messageId,
    this.content,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) => MessageContent(
        messageId: json["message_id"],
        content: json["content"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
      );

  Map<String, dynamic> toJson() => {
        "message_id": messageId,
        "content": content,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
      };
}

class MessageStatus {
  final int? id;
  final String? messageId;
  final int? userId;
  final int? isReceived;
  final bool? isWatched;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final DateTime? watchedAt;
  final DateTime? receivedAt;
  final dynamic mobilePhone;

  MessageStatus({
    this.id,
    this.messageId,
    this.userId,
    this.isReceived,
    this.isWatched,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.watchedAt,
    this.receivedAt,
    this.mobilePhone,
  });

  MessageStatus copyWith({
    final int? id,
    final String? messageId,
    final int? userId,
    final int? isReceived,
    final bool? isWatched,
    final int? isLockedByAdminForDelete,
    final int? isLockedByAdminForUpdate,
    final DateTime? watchedAt,
    final DateTime? receivedAt,
    final dynamic mobilePhone,
  }) {
    return MessageStatus(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      isReceived: isReceived ?? this.isReceived,
      isWatched: isWatched ?? this.isWatched,
      isLockedByAdminForDelete:
          isLockedByAdminForDelete ?? this.isLockedByAdminForDelete,
      isLockedByAdminForUpdate:
          isLockedByAdminForUpdate ?? this.isLockedByAdminForUpdate,
      watchedAt: watchedAt ?? this.watchedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      mobilePhone: mobilePhone ?? this.mobilePhone,
    );
  }

  factory MessageStatus.fromJson(Map<String, dynamic> json) => MessageStatus(
        id: json["id"],
        messageId: json["message_id"].toString(),
        userId: json["user_id"],
        isReceived: json["is_received"],
        isWatched: json["is_watched"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        watchedAt: json["watched_at"] == null
            ? null
            : DateTime.parse(json["watched_at"]),
        receivedAt: json["received_at"] == null
            ? null
            : DateTime.parse(json["received_at"]),
        mobilePhone: json["mobile_phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message_id": messageId,
        "user_id": userId,
        "is_received": isReceived,
        "is_watched": isWatched,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "watched_at": watchedAt?.toIso8601String(),
        "received_at": receivedAt?.toIso8601String(),
        "mobile_phone": mobilePhone,
      };
}

class MessageType {
  final String? name;
  final String? eventName;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;

  MessageType({
    this.name,
    this.eventName,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
  });

  factory MessageType.fromJson(Map<String, dynamic> json) => MessageType(
        name: json["name"],
        eventName: json["event_name"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "event_name": eventName,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
      };
}

class ChannelMember {
  final int? id;
  final String? channelId;
  final int? userId;
  final dynamic isAllowedToChat;
  final int? pin;
  final int? archived;
  final int? mute;
  final int? isAdmin;
  final int? roleId;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final dynamic userType;
  final dynamic mobilePhone;
  final User? user;

  ChannelMember({
    this.id,
    this.channelId,
    this.userId,
    this.isAllowedToChat,
    this.pin,
    this.archived,
    this.mute,
    this.isAdmin,
    this.roleId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.userType,
    this.mobilePhone,
    this.user,
  });

  ChannelMember copyWith({
    int? id,
    String? channelId,
    int? userId,
    dynamic isAllowedToChat,
    int? pin,
    int? archived,
    int? mute,
    int? isAdmin,
    dynamic roleId,
    int? isLockedByAdminForDelete,
    int? isLockedByAdminForUpdate,
    dynamic userType,
    dynamic mobilePhone,
    User? user,
  }) =>
      ChannelMember(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        userId: userId ?? this.userId,
        isAllowedToChat: isAllowedToChat ?? this.isAllowedToChat,
        pin: pin ?? this.pin,
        archived: archived ?? this.archived,
        mute: mute ?? this.mute,
        isAdmin: isAdmin ?? this.isAdmin,
        roleId: roleId ?? this.roleId,
        isLockedByAdminForDelete:
            isLockedByAdminForDelete ?? this.isLockedByAdminForDelete,
        isLockedByAdminForUpdate:
            isLockedByAdminForUpdate ?? this.isLockedByAdminForUpdate,
        userType: userType ?? this.userType,
        mobilePhone: mobilePhone ?? this.mobilePhone,
        user: user ?? this.user,
      );

  factory ChannelMember.fromJson(Map<String, dynamic> json) => ChannelMember(
        id: json["id"],
        channelId: json["channel_id"].toString(),
        userId: json["user_id"],
        isAllowedToChat: json["is_allowed_to_chat"],
        pin: json["pin"],
        archived: json["archived"],
        mute: json["mute"],
        isAdmin: json["is_admin"],
        roleId: json["role_id"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        userType: json["user_type"],
        mobilePhone: json["mobile_phone"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_id": channelId,
        "user_id": userId,
        "is_allowed_to_chat": isAllowedToChat,
        "pin": pin,
        "archived": archived,
        "mute": mute,
        "is_admin": isAdmin,
        "role_id": roleId,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "user_type": userType,
        "mobile_phone": mobilePhone,
        "user": user?.toJson(),
      };
}

class ContactUser {
  int? id;
  int? userId;
  String? name;
  String? mobilePhone;
  int? contactUserId;

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

class User {
  ContactUser? contactUser;
  final int? id;
  final String? mobilePhone;
  final dynamic photoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final String? name;
  final dynamic username;

  User({
    this.contactUser,
    this.id,
    this.mobilePhone,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.name,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        contactUser: json["contact_user"] == null
            ? null
            : ContactUser.fromJson(json["contact_user"]),
        id: json["id"],
        mobilePhone: json["mobile_phone"],
        photoPath: json["photo_path"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        name: json["name"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "contact_user": contactUser?.toJson(),
        "id": id,
        "mobile_phone": mobilePhone,
        "photo_path": photoPath,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "name": name,
        "username": username,
      };
}

class ChannelType {
  final int? id;
  final int? isDefault;
  final dynamic photoPath;
  final int? hasBot;
  final dynamic rootChatBotTopicId;
  final int? isLockedByAdminForDelete;
  final int? isLockedByAdminForUpdate;
  final dynamic roleId;
  final int? slug;
  final List<dynamic>? channelTypeTranslations;
  final dynamic channelTypeTranslation;

  ChannelType({
    this.id,
    this.isDefault,
    this.photoPath,
    this.hasBot,
    this.rootChatBotTopicId,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.roleId,
    this.slug,
    this.channelTypeTranslations,
    this.channelTypeTranslation,
  });

  factory ChannelType.fromJson(Map<String, dynamic> json) => ChannelType(
        id: json["id"],
        isDefault: json["is_default"],
        photoPath: json["photo_path"],
        hasBot: json["has_bot"],
        rootChatBotTopicId: json["root_chat_bot_topic_id"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"],
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"],
        roleId: json["role_id"],
        slug: json["slug"],
        channelTypeTranslations: json["channel_type_translations"] == null
            ? []
            : List<dynamic>.from(
                json["channel_type_translations"]!.map((x) => x)),
        channelTypeTranslation: json["channel_type_translation"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_default": isDefault,
        "photo_path": photoPath,
        "has_bot": hasBot,
        "root_chat_bot_topic_id": rootChatBotTopicId,
        "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
        "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
        "role_id": roleId,
        "slug": slug,
        "channel_type_translations": channelTypeTranslations == null
            ? []
            : List<dynamic>.from(channelTypeTranslations!.map((x) => x)),
        "channel_type_translation": channelTypeTranslation,
      };
}
