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
  final int? roleId;

  const GetChatsEvent({
    this.roleId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [roleId];
}

class SendMessageEvent extends ChatEvent {
  final int? receiverUserId;
  final int? receiverRoleId;
  final int? senderRoleId;
  final String? content;
  final List<Map<String, dynamic>>? mediaContent;
  final int? parentMessageId;
  final String? messageType;
  final bool? isForward;
  final Map<String, dynamic>? extraFields;

  const SendMessageEvent({
    this.receiverUserId,
    this.receiverRoleId,
    this.senderRoleId,
    this.content,
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
        receiverRoleId,
        senderRoleId,
        content,
        mediaContent,
        parentMessageId,
        messageType,
        isForward,
        extraFields
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
