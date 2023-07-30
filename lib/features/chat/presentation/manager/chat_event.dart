

import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../data/models/my_chats_response_model.dart';
abstract class ChatEvent extends Equatable {
  const ChatEvent();
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
  final int channelId;

  const ReadAllMessagesEvent(this.channelId);

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class GetChatsEvent extends ChatEvent {
  const GetChatsEvent();

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
  final int channelId;
  final File? file;
  final int? senderParentMessageId;
  const SendMessageEvent(
      {this.receiverUserId,
      this.content,
      required this.messageId,
      this.mediaContent,
      this.parentMessageId,
      this.file,
      this.senderParentMessageId,
      this.messageType,
      this.parentMessageContent,
      this.isForward,
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
  final String messageId;
  final int? receiverUserId;
  final String? content;
  final List<Map<String, dynamic>>? mediaContent;
  final String? parentMessageId;
  final String? messageType;
  final String? parentMessageContent;
  final bool? isForward;
  final int channelId;
  final int? senderParentMessageId;
  final Map<String, dynamic>? extraFields;

  const UploadFileEvent({
    required this.file,
    required this.filePath,
    required this.messageId,
    required this.channelId,
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
        parentMessageContent,
        messageId,
        channelId
      ];
}

class SaveContactsEvent extends ChatEvent {
  final List<Map<String, dynamic>> contacts;

  const SaveContactsEvent({
    this.contacts = const [],
  });

  @override
  // TODO: implement props
  List<Object?> get props => [contacts];
}

class ReceiveMessageEvent extends ChatEvent {
  final Message message;

  const ReceiveMessageEvent({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => [message];
}

class ReceiveMessageFromPusherEvent extends ChatEvent {
  final int channelId;
  final int userId;
  final int lastMessageId;
  const ReceiveMessageFromPusherEvent(this.channelId , this.userId , this.lastMessageId );

  @override
  // TODO: implement props
  List<Object?> get props => [channelId , userId , lastMessageId];
}

class WatchedMessageFromPusherEvent extends ChatEvent {

  final int channelId;
  final int userId;
  final int lastMessageId;
  const WatchedMessageFromPusherEvent(this.channelId , this.userId , this.lastMessageId );

  @override
  // TODO: implement props
  List<Object?> get props => [channelId , userId , lastMessageId];
}
class NotifyThatIReceivedMessageEvent extends ChatEvent {
  final int channelId;

  const NotifyThatIReceivedMessageEvent({required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}

class DeleteChatEvent extends ChatEvent {
  final int channelId;

  const DeleteChatEvent({required this.channelId});

  @override
  // TODO: implement props
  List<Object?> get props => [channelId];
}
class ChangeChatPropertyEvent extends ChatEvent {
  final int channelId;
  final int? mute;
  final int? pin;
  final int? archive;
  const ChangeChatPropertyEvent({
    required this.channelId,
    this.archive,
    this.mute,
    this.pin
  });

  @override
  // TODO: implement props
  List<Object?> get props => [channelId,archive,mute,pin];
}

class GetMessagesForChatEvent extends ChatEvent {
  final int limit;
  final int channelId;

  const GetMessagesForChatEvent({
    required this.channelId ,
    this.limit=10
  });
  @override
  // TODO: implement props
  List<Object?> get props => [limit ,channelId];
}


