part of 'chat_bloc.dart';

enum SaveContactsStatus { init, loading, success, failure }

enum GetContactsStatus { init, loading, success, failure }

enum GetChatsStatus { init, loading, success, failure }

enum SendMessageStatus { init, loading, success, failure }

enum ReceiveMessageStatus { init, loading, success, failure }

enum GetMessagesBetweenStatus { init, loading, success, failure }

enum ResetReadMessagesStatus { init, loading, success, failure }

enum NotifyThatIReceivedMessageStatus { init, loading, success, failure }

enum ChangeMessageStateFromPusherStatus { init, received , watched }

class ChatState {
  final GetChatsStatus getChatsStatus;
  final SendMessageStatus sendMessageStatus;
  final ReceiveMessageStatus receiveMessageStatus;
  final SaveContactsStatus saveContactsStatus;
  final GetContactsStatus getContactsStatus;
  final ResetReadMessagesStatus readMessagesStatus;
  final GetMessagesBetweenStatus getMessagesBetweenStatus;
  final NotifyThatIReceivedMessageStatus notifyThatIReceivedMessageStatus;
  final ChangeMessageStateFromPusherStatus changeMessageStateFromPusherStatus;
  final List<Contact> contacts;
  final List<Chat> chats;
  final List<Chat> pinnedChats;
  final List<String> currentMessage;
  final List<String> currentFailedMessage;
  final String channelId;
  final String? messageType;
  final String? messageContent;
  final String? firstMessageId;
  final String? secondMessageId;
  final int unReadMessagesFromAllChats;
  final String currentChannelReceivedMessage;
  final bool scrollToParentMessage;

  ChatState({
    this.getContactsStatus = GetContactsStatus.init,
    this.changeMessageStateFromPusherStatus = ChangeMessageStateFromPusherStatus.init,
    this.getMessagesBetweenStatus = GetMessagesBetweenStatus.init,
    this.saveContactsStatus = SaveContactsStatus.init,
    this.sendMessageStatus = SendMessageStatus.init,
    this.readMessagesStatus = ResetReadMessagesStatus.init,
    this.notifyThatIReceivedMessageStatus =
        NotifyThatIReceivedMessageStatus.init,
    this.receiveMessageStatus = ReceiveMessageStatus.init,
    this.getChatsStatus = GetChatsStatus.init,
    this.channelId = '-1',
    this.unReadMessagesFromAllChats = 0,
    this.currentChannelReceivedMessage = '-1',
    this.messageType,
    this.firstMessageId,
    this.scrollToParentMessage=false,
    this.secondMessageId,
    this.messageContent,
    this.contacts = const [],
    this.chats = const [],
    this.pinnedChats = const [],
    this.currentMessage = const [],
    this.currentFailedMessage = const [],
  });

  ChatState copyWith({
    final GetChatsStatus? getChatsStatus,
    final SendMessageStatus? sendMessageStatus,
    final ReceiveMessageStatus? receiveMessageStatus,
    final SaveContactsStatus? saveContactsStatus,
    final GetContactsStatus? getContactsStatus,
    final GetMessagesBetweenStatus? getMessagesBetweenStatus,
    final List<Contact>? contacts,
    final String? channelId,
    final bool? scrollToParentMessage,
    final String? firstMessageId,
    final String? secondMessageId,
    final int? currentOpenedChannelId,
    final ResetReadMessagesStatus? readMessagesStatus,
    final NotifyThatIReceivedMessageStatus? notifyThatIReceivedMessageStatus,
    final ChangeMessageStateFromPusherStatus? changeMessageStateFromPusherStatus,
    final String? currentChannelReceivedMessage,
    final List<Chat>? chats,
    final List<String>? currentMessage,
    final List<String>? currentFailedMessage,
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
      currentFailedMessage: currentFailedMessage ?? this.currentFailedMessage,
      changeMessageStateFromPusherStatus: changeMessageStateFromPusherStatus ?? this.changeMessageStateFromPusherStatus,
      scrollToParentMessage: scrollToParentMessage ?? this.scrollToParentMessage,
      notifyThatIReceivedMessageStatus: notifyThatIReceivedMessageStatus ??
          this.notifyThatIReceivedMessageStatus,
      currentMessage: currentMessage ?? this.currentMessage,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      unReadMessagesFromAllChats: unReadMessagesFromAllChats ?? this.unReadMessagesFromAllChats,
      currentChannelReceivedMessage: currentChannelReceivedMessage ?? this.currentChannelReceivedMessage,
      saveContactsStatus: saveContactsStatus ?? this.saveContactsStatus,
      channelId: channelId ?? this.channelId,
      firstMessageId: firstMessageId ?? this.firstMessageId,
      secondMessageId: secondMessageId ?? this.secondMessageId,
      messageContent: messageContent ?? this.messageContent,
      readMessagesStatus: readMessagesStatus ?? this.readMessagesStatus,
      messageType: messageType ?? this.messageType,
      receiveMessageStatus: receiveMessageStatus ?? this.receiveMessageStatus,
      getMessagesBetweenStatus: getMessagesBetweenStatus ?? this.getMessagesBetweenStatus,
    );
  }
}
