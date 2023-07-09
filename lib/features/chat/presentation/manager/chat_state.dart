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
  final List<int> currentMessage;

  ChatState({ this.getContactsStatus = GetContactsStatus
      .init, this.saveContactsStatus = SaveContactsStatus.init,
    this.sendMessageStatus=SendMessageStatus.init,
    this.getChatsStatus=GetChatsStatus.init,
    this.contacts=const [],
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
    final List<Chat>? chats,
     final List<int>? currentMessage,
    final List<Chat>? pinnedChats
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
    );
  }
}
