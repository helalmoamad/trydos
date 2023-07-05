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
  final List<Map<String , dynamic>> contacts;

  ChatState({ this.getContactsStatus = GetContactsStatus
      .init, this.saveContactsStatus = SaveContactsStatus.init,
    this.sendMessageStatus=SendMessageStatus.init,
    this.getChatsStatus=GetChatsStatus.init,
    this.contacts=const []
  });

  ChatState copyWith({
    final GetChatsStatus? getChatsStatus,
    final SendMessageStatus? sendMessageStatus,
    final SaveContactsStatus? saveContactsStatus,
    final GetContactsStatus? getContactsStatus,
    final List<Map<String , dynamic>>? contacts
}) {
    return ChatState(
      getChatsStatus: getChatsStatus ?? this.getChatsStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      getContactsStatus: getContactsStatus ?? this.getContactsStatus,
      contacts: contacts ?? this.contacts,
      saveContactsStatus: saveContactsStatus ?? this.saveContactsStatus,
    );
  }
}
