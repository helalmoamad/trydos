part of 'chat_bloc.dart';

enum SaveContactsStatus { init, loading, success, failure }

enum GetContactsStatus { init, loading, success, failure }

enum GetChatsStatus { init, loading, success, failure }

enum SendMessageStatus { init, loading, success, failure }

enum ReceiveMessageStatus { init, loading, success, failure }

enum ResetReadMessagesStatus { init, loading, success, failure }

enum NotifyThatIReceivedMessageStatus { init, loading, success, failure }

class ChatState {
  final GetChatsStatus getChatsStatus;
  final SendMessageStatus sendMessageStatus;
  final ReceiveMessageStatus receiveMessageStatus;
  final SaveContactsStatus saveContactsStatus;
  final GetContactsStatus getContactsStatus;
  final ResetReadMessagesStatus readMessagesStatus;
  final NotifyThatIReceivedMessageStatus notifyThatIReceivedMessageStatus;
  final List<Contact> contacts;
  final List<Chat> chats;
  final List<Chat> pinnedChats;
  final List<String> currentMessage;
  final int channelId;
  final String? messageType;
  final String? messageContent;
  final int unReadMessagesFromAllChats;
  final int currentChannelReceivedMessage;
  ChatState({
    this.getContactsStatus = GetContactsStatus.init,
    this.saveContactsStatus = SaveContactsStatus.init,
    this.sendMessageStatus = SendMessageStatus.init,
    this.readMessagesStatus = ResetReadMessagesStatus.init,
    this.notifyThatIReceivedMessageStatus =
        NotifyThatIReceivedMessageStatus.init,
    this.receiveMessageStatus = ReceiveMessageStatus.init,
    this.getChatsStatus = GetChatsStatus.init,
    this.channelId = -1,
    this.unReadMessagesFromAllChats = 0,
    this.currentChannelReceivedMessage = -1,
    this.messageType,
    this.messageContent,
    this.contacts = const [],
    this.chats = const [],
    this.pinnedChats = const [],
    this.currentMessage = const [],
  });

  ChatState copyWith({
    final GetChatsStatus? getChatsStatus,
    final SendMessageStatus? sendMessageStatus,
    final ReceiveMessageStatus? receiveMessageStatus,
    final SaveContactsStatus? saveContactsStatus,
    final GetContactsStatus? getContactsStatus,
    final List<Contact>? contacts,
    final int? channelId,
    final int? currentOpenedChannelId,
    final ResetReadMessagesStatus? readMessagesStatus,
    final NotifyThatIReceivedMessageStatus? notifyThatIReceivedMessageStatus,
    final int? currentChannelReceivedMessage,
    final List<Chat>? chats,
    final List<String>? currentMessage,
    final int? unReadMessagesFromAllChats,
    final String? messageType,
    final String? messageContent,
    final List<Chat>? pinnedChats,
  }) {
    return ChatState(
      getChatsStatus: getChatsStatus ?? this.getChatsStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      getContactsStatus: getContactsStatus ?? this.getContactsStatus,
      contacts: contacts ?? this.contacts,
      chats: chats ?? this.chats,
      notifyThatIReceivedMessageStatus: notifyThatIReceivedMessageStatus ??
          this.notifyThatIReceivedMessageStatus,
      currentMessage: currentMessage ?? this.currentMessage,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      unReadMessagesFromAllChats: unReadMessagesFromAllChats ?? this.unReadMessagesFromAllChats,
      currentChannelReceivedMessage: currentChannelReceivedMessage ?? this.currentChannelReceivedMessage,
      saveContactsStatus: saveContactsStatus ?? this.saveContactsStatus,
      channelId: channelId ?? this.channelId,
      messageContent: messageContent ?? this.messageContent,
      readMessagesStatus: readMessagesStatus ?? this.readMessagesStatus,
      messageType: messageType ?? this.messageType,
      receiveMessageStatus: receiveMessageStatus ?? this.receiveMessageStatus,
    );
  }
}
