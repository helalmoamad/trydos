import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../data/models/my_chats_response_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class LoadWidthAndHeightForImage extends ChatEvent {
  final File file;
  final int message_id;
  final int channel_id;

  LoadWidthAndHeightForImage(
      {required this.channel_id, required this.message_id, required this.file});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CreateUserEvent extends ChatEvent {
  final String? name;
  final String? mobilePhone;
  final String? password;

  const CreateUserEvent({
    this.name,
    this.mobilePhone,
    this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [name, mobilePhone, password];
}

class LoginEvent extends ChatEvent {
  final String? mobilePhone;
  final String? password;

  const LoginEvent({
    this.mobilePhone,
    this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [mobilePhone, password];
}

class GetContactsEvent extends ChatEvent {
  const GetContactsEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ReadAllMessagesEvent extends ChatEvent {
  final String channelId;

  const ReadAllMessagesEvent(this.channelId);

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class GetChatsEvent extends ChatEvent {
  final Chat? chatToNavigateFromTerminated;
  final DateTime? timeStamp;
  final int? limit;
  final int? messagesLimit;
  const GetChatsEvent(
      {this.chatToNavigateFromTerminated,
      this.timeStamp,
      this.limit,
      this.messagesLimit});
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final int? receiverUserId;
  final String? content;
  final List<Map<String, dynamic>>? mediaContent;
  final String? parentMessageId;
  final String? messageType;
  final bool? isForward;
  final Map<String, dynamic>? extraFields;
  final String messageId;
  final String? parentMessageContent;
  final String channelId;
  final File? file;
  final int? senderParentMessageId;
  final bool createNewChat;
  final double? imageWidth;
  final double? imageHeight;

  const SendMessageEvent(
      {this.receiverUserId,
      this.content,
      required this.messageId,
      this.mediaContent,
      this.parentMessageId,
      this.file,
      this.imageWidth,
      this.imageHeight,
      this.senderParentMessageId,
      this.messageType,
      this.parentMessageContent,
      this.isForward,
      this.createNewChat = false,
      this.extraFields,
      required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [
        receiverUserId,
        content,
        mediaContent,
        parentMessageId,
        file,
        messageType,
        parentMessageContent,
        isForward,
        extraFields,
        channelId,
        messageId
      ];
}

class UploadFileEvent extends ChatEvent {
  final File file;
  final String filePath;
  final String fileName;
  final String messageId;
  final int? receiverUserId;
  final String? content;
  final List<Map<String, dynamic>>? mediaContent;
  final String? parentMessageId;
  final String? messageType;
  final String? parentMessageContent;
  final bool? isForward;
  final String channelId;
  final int? senderParentMessageId;
  final Map<String, dynamic>? extraFields;
  final bool useCloudinaryToUpload;

  const UploadFileEvent({
    required this.file,
    required this.filePath,
    required this.fileName,
    required this.messageId,
    required this.channelId,
    required this.useCloudinaryToUpload,
    this.receiverUserId,
    this.content,
    this.senderParentMessageId,
    this.mediaContent,
    this.parentMessageContent,
    this.parentMessageId,
    this.messageType,
    this.isForward,
    this.extraFields,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        filePath,
        file,
        receiverUserId,
        content,
        mediaContent,
        parentMessageId,
        messageType,
        isForward,
        extraFields,
        fileName,
        parentMessageContent,
        messageId,
        channelId
      ];
}

class SaveContactsEvent extends ChatEvent {
  const SaveContactsEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ReceiveMessageEvent extends ChatEvent {
  final Message message;
  final String? prevMessageId;
  final bool increaseUnReadMessages;
  const ReceiveMessageEvent(
      {required this.message,
      this.prevMessageId,
      this.increaseUnReadMessages = true});

  @override
  // TODO: implement props
  List<Object?> get props => [message, prevMessageId, increaseUnReadMessages];
}

class ReceiveMessageFromPusherEvent extends ChatEvent {
  final String channelId;
  final int userId;
  final int lastMessageId;
  final DateTime receivedAt;

  const ReceiveMessageFromPusherEvent(
      this.channelId, this.userId, this.lastMessageId, this.receivedAt);

  @override
  // TODO: implement props
  List<Object?> get props => [channelId, userId, lastMessageId];
}

class IncreaseFileImageVideoCounterEvent extends ChatEvent {
  final String messageType;

  const IncreaseFileImageVideoCounterEvent(this.messageType);

  @override
  // TODO: implement props
  List<Object?> get props => [messageType];
}

class WatchedMessageFromPusherEvent extends ChatEvent {
  final DateTime watchedAt;

  final String channelId;
  final int userId;
  final int lastMessageId;

  const WatchedMessageFromPusherEvent(
      this.channelId, this.userId, this.lastMessageId, this.watchedAt);

  @override
  // TODO: implement props
  List<Object?> get props => [channelId, userId, lastMessageId];
}

class NotifyThatIReceivedMessageEvent extends ChatEvent {
  final String channelId;

  const NotifyThatIReceivedMessageEvent({required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class DeleteChatEvent extends ChatEvent {
  final String channelId;

  const DeleteChatEvent({required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class AddUserConntctSatuseEvent extends ChatEvent {
  final String userConnectedStatuse;
  final String chatId;
  const AddUserConntctSatuseEvent({
    required this.userConnectedStatuse,
    required this.chatId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userConnectedStatuse];
}

class ReceiveMissCallEvent extends ChatEvent {
  final String channelId;
  final bool increaseUnReadMessages;
  const ReceiveMissCallEvent(this.increaseUnReadMessages,
      {required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class ChangeChatPropertyEvent extends ChatEvent {
  final String channelId;
  final int? mute;
  final int? pin;
  final int? archive;

  const ChangeChatPropertyEvent(
      {required this.channelId, this.archive, this.mute, this.pin});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId, archive, mute, pin];
}

class GetMessagesForChatEvent extends ChatEvent {
  final int limit;
  final String channelId;

  const GetMessagesForChatEvent({required this.channelId, this.limit = 10});

  @override
  // TODO: implement props
  List<Object?> get props => [limit, channelId];
}

class GetAllMessagesBetweenEvent extends ChatEvent {
  final String channelId;
  final String firstMessageId;
  final String secondMessageId;
  final bool scrollToParentMessage;

  const GetAllMessagesBetweenEvent(
      {required this.firstMessageId,
      required this.secondMessageId,
      required this.scrollToParentMessage,
      required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [firstMessageId, secondMessageId, channelId, scrollToParentMessage];
}

class AddAMessageToAChannel extends ChatEvent {
  final Message message;
  final String localChannelId;

  const AddAMessageToAChannel({
    required this.message,
    required this.localChannelId,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [message, localChannelId];
}

class GetMediaCountEvent extends ChatEvent {
  final String channelId;

  const GetMediaCountEvent({required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class IncreaseSharedProductCountOnSocialAppEvent extends ChatEvent {
  final String productId;
  final String socialMediaName;
  final int sharedCount;

  const IncreaseSharedProductCountOnSocialAppEvent(
      {required this.socialMediaName,
      required this.productId,
      required this.sharedCount});

  @override
  // TODO: implement props
  List<Object?> get props => [sharedCount, productId, socialMediaName];
}

class GetSharedProductCountEvent extends ChatEvent {
  final String productId;

  const GetSharedProductCountEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
}

class AddMediaCountEvent extends ChatEvent {
  int images = 0;
  int videos = 0;

  int file = 0;

  AddMediaCountEvent(
      {required this.images, required this.videos, required this.file});

  @override
  // TODO: implement props
  List<Object?> get props => [images, videos, file];
}

class ChangeSlop extends ChatEvent {
  final String messageId;

  ChangeSlop({required this.messageId});
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class AddChannelToChannels extends ChatEvent {
  final Message message;
  const AddChannelToChannels({required this.message});
  @override
  // TODO: implement props
  List<Object?> get props => [message];
}

class UpdateChannelObjectFromNotificationEvent extends ChatEvent {
  final Chat chat;
  const UpdateChannelObjectFromNotificationEvent({required this.chat});
  @override
  // TODO: implement props
  List<Object?> get props => [chat];
}

class ChangeGlobalUsedVariablesInBloc extends ChatEvent {
  final String? currentOpenedChatId;
  const ChangeGlobalUsedVariablesInBloc({this.currentOpenedChatId});
  @override
  // TODO: implement props
  List<Object?> get props => [currentOpenedChatId];
}

class ResendMessageEvent extends ChatEvent {
  final String messageId;
  final String channelId;
  final String? messageType;
  ResendMessageEvent(
      {required this.messageId, required this.channelId, this.messageType});
  @override
  // TODO: implement props
  List<Object?> get props => [messageId, channelId];
}

class DeleteMessageNotificationReceivedInChatsEvent extends ChatEvent {
  final String messageId;
  final String channelId;
  final bool deleteForAll;
  final int isDelete;
  final int deletedByUserId;
  DeleteMessageNotificationReceivedInChatsEvent(
      {required this.messageId,
      required this.deletedByUserId,
      required this.channelId,
      required this.deleteForAll,
      required this.isDelete});
  @override
  // TODO: implement props
  List<Object?> get props => [messageId, channelId, deleteForAll];
}

class DeleteChatFromNotificationEvent extends ChatEvent {
  final String channelId;
  DeleteChatFromNotificationEvent({
    required this.channelId,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class GetDateTimeEvent extends ChatEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SendErrorChatToServerEvent extends ChatEvent {
  String error;
  String lastPage;
  SendErrorChatToServerEvent({required this.error, required this.lastPage});
  @override
  // TODO: implement props
  List<Object?> get props => [error, lastPage];
}

class ShareProductWithContactsOrChannelsEvent extends ChatEvent {
  final String productId;
  final String productName;
  final String productSlug;
  final String productDescription;
  final String productImageUrl;
  final String? originalImageWidth;
  final String? originalImageHeight;
  final List<String> channelIds;

  ShareProductWithContactsOrChannelsEvent({
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.productDescription,
    required this.productImageUrl,
    required this.channelIds,
    this.originalImageWidth,
    this.originalImageHeight,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        productId,
        productSlug,
        productName,
        productDescription,
        productImageUrl,
        channelIds,
    originalImageWidth,
    originalImageHeight,
      ];
}
