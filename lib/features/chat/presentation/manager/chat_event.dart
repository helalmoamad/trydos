part of 'chat_bloc.dart';

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
  final int? parentMessageId;
  final String? messageType;
  final bool? isForward;
  final Map<String, dynamic>? extraFields;
  final int messageId;

  const SendMessageEvent({
    this.receiverUserId,
    this.content,
    required this.messageId,
    this.mediaContent,
    this.parentMessageId,
    this.messageType,
    this.isForward,
    this.extraFields,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        receiverUserId,
        content,
        mediaContent,
        parentMessageId,
        messageType,
        isForward,
        extraFields,
        messageId
      ];
}

class UploadFileEvent extends ChatEvent {
  final File file;
  final String filePath;
  final int messageId;
  final int? receiverUserId;
  final String? content;
  final List<Map<String, dynamic>>? mediaContent;
  final int? parentMessageId;
  final String? messageType;
  final bool? isForward;
  final Map<String, dynamic>? extraFields;

  const UploadFileEvent({
    required this.file,
    required this.filePath,
    required this.messageId,
    this.receiverUserId,
    this.content,
    this.mediaContent,
    this.parentMessageId,
    this.messageType,
    this.isForward,
    this.extraFields,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [filePath, file, receiverUserId,
    content,
    mediaContent,
    parentMessageId,
    messageType,
    isForward,
    extraFields,
    messageId];
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
