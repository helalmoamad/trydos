part of 'chat_bloc.dart';


enum SaveContactsStatus { init, loading, success, failure }
enum GetContactsStatus { init, loading, success, failure }
enum GetChatsStatus { init, loading, success, failure }
enum SendMessageStatus { init, loading, success, failure }


class ChatState {
  final GetChatsStatus getChatsStatus;
  final SendMessageStatus sendMessageStatus;
  final SaveContactsStatus saveContactsStatus;
  final GetContactsStatus getContactsStatus;
  final List<Contact> contacts;
  final List<Chat> chats;
  final List<Chat> pinnedChats;
  final List<String> currentMessage;
  final Map<int , List<Message>> messages;
  final int channelId;
  final String? messageType;
  final String? messageContent;
  ChatState({ this.getContactsStatus = GetContactsStatus
      .init, this.saveContactsStatus = SaveContactsStatus.init,
    this.sendMessageStatus=SendMessageStatus.init,
    this.getChatsStatus=GetChatsStatus.init,
    this.channelId=-1,
    this.messageType,
    this.messageContent,
    this.contacts=const [],
    this.messages=const {},
    this.chats=const [],
    this.pinnedChats=const [],
    this.currentMessage=const [],
  });

  ChatState copyWith({
    final GetChatsStatus? getChatsStatus,
    final SendMessageStatus? sendMessageStatus,
    final SaveContactsStatus? saveContactsStatus,
    final GetContactsStatus? getContactsStatus,
    final List<Contact>? contacts,
    final int? channelId,
    final List<Chat>? chats,
     final List<String>? currentMessage,
    final String? messageType,
    final String? messageContent,
    final List<Chat>? pinnedChats,
    final Map<int,List<Message>>? messages,
  }) {
    return ChatState(
      getChatsStatus: getChatsStatus ?? this.getChatsStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      getContactsStatus: getContactsStatus ?? this.getContactsStatus,
      contacts: contacts ?? this.contacts,
      chats: chats ?? this.chats,
       currentMessage: currentMessage ?? this.currentMessage,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      saveContactsStatus: saveContactsStatus ?? this.saveContactsStatus,
      channelId: channelId ?? this.channelId,
      messageContent: messageContent ?? this.messageContent,
      messageType: messageType ?? this.messageType,
      messages: messages ?? this.messages,
    );
  }
}
