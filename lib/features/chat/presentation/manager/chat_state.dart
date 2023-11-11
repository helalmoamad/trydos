part of 'chat_bloc.dart';

enum SaveContactsStatus { init, loading, success, failure }

enum LoadImageWidthAndHeight { init, loading, success, failure }

enum GetContactsStatus { init, loading, success, failure }

enum GetChatsStatus { init, loading, success, failure }

enum SendMessageStatus { init, loading, success, failure }

enum ReceiveMessageStatus { init, loading, success, failure }

enum GetMessagesBetweenStatus { init, loading, success, failure }

enum ResetReadMessagesStatus { init, loading, success, failure }

enum NotifyThatIReceivedMessageStatus { init, loading, success, failure }

enum ChangeChatPropertyStatus { init, loading, success, failure }

enum DeleteChatStatus { init, loading, success, failure }

enum ChangeMessageStateFromPusherStatus { init, received, watched }

class ChatState {
  final int width;
  final int height;
  final GetChatsStatus getChatsStatus;
  final SendMessageStatus sendMessageStatus;
  final ReceiveMessageStatus receiveMessageStatus;
  final LoadImageWidthAndHeight loadImageWidthAndHeight;
  final SaveContactsStatus saveContactsStatus;
  final GetContactsStatus getContactsStatus;
  final ResetReadMessagesStatus readMessagesStatus;
  final GetMessagesBetweenStatus getMessagesBetweenStatus;
  final NotifyThatIReceivedMessageStatus notifyThatIReceivedMessageStatus;
  final ChangeMessageStateFromPusherStatus changeMessageStateFromPusherStatus;
  final ChangeChatPropertyStatus changeChatPropertyStatus;
  final DeleteChatStatus deleteChatStatus;
  final List<Contact> contacts;
   List<Chat> chats;
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
  final bool createAnewChat;
  Map<String, List<Message>>? newSortedChatsByDate;

  ChatState({
    this.width=0,
    this.height=0,
    this.loadImageWidthAndHeight = LoadImageWidthAndHeight.init,
    this.newSortedChatsByDate = const {},
    this.getContactsStatus = GetContactsStatus.init,
    this.changeMessageStateFromPusherStatus =
        ChangeMessageStateFromPusherStatus.init,
    this.getMessagesBetweenStatus = GetMessagesBetweenStatus.init,
    this.changeChatPropertyStatus = ChangeChatPropertyStatus.init,
    this.saveContactsStatus = SaveContactsStatus.init,
    this.sendMessageStatus = SendMessageStatus.init,
    this.readMessagesStatus = ResetReadMessagesStatus.init,
    this.deleteChatStatus = DeleteChatStatus.init,
    this.notifyThatIReceivedMessageStatus =
        NotifyThatIReceivedMessageStatus.init,
    this.receiveMessageStatus = ReceiveMessageStatus.init,
    this.getChatsStatus = GetChatsStatus.init,
    this.channelId = '-1',
    this.unReadMessagesFromAllChats = 0,
    this.currentChannelReceivedMessage = '-1',
    this.messageType,
    this.firstMessageId,
    this.scrollToParentMessage = false,
    this.createAnewChat = false,
    this.secondMessageId,
    this.messageContent,
    this.contacts = const [],
    this.chats = const [],
    this.pinnedChats = const [],
    this.currentMessage = const [],
    this.currentFailedMessage = const [],
  });

  ChatState copyWith({
    int? width,
    int? height,
    LoadImageWidthAndHeight? loadImageWidthAndHeight,
    Map<String, List<Message>>? newSortedChatsByDate,
    final GetChatsStatus? getChatsStatus,
    final SendMessageStatus? sendMessageStatus,
    final ReceiveMessageStatus? receiveMessageStatus,
    final ChangeChatPropertyStatus? changeChatPropertyStatus,
    final SaveContactsStatus? saveContactsStatus,
    final GetContactsStatus? getContactsStatus,
    final GetMessagesBetweenStatus? getMessagesBetweenStatus,
    final DeleteChatStatus? deleteChatStatus,
    final List<Contact>? contacts,
    final String? channelId,
    final bool? scrollToParentMessage,
    final String? firstMessageId,
    final String? secondMessageId,
    final int? currentOpenedChannelId,
    final ResetReadMessagesStatus? readMessagesStatus,
    final NotifyThatIReceivedMessageStatus? notifyThatIReceivedMessageStatus,
    final ChangeMessageStateFromPusherStatus?
        changeMessageStateFromPusherStatus,
    final String? currentChannelReceivedMessage,
    final List<Chat>? chats,
    final bool? createAnewChat,
    final List<String>? currentMessage,
    final List<String>? currentFailedMessage,
    final int? unReadMessagesFromAllChats,
    final String? messageType,
    final String? messageContent,
    final List<Chat>? pinnedChats,
  }) {
    return ChatState(
      width: width??this.width,
      height: height??this.height,
      loadImageWidthAndHeight:
          loadImageWidthAndHeight ?? this.loadImageWidthAndHeight,
      newSortedChatsByDate: newSortedChatsByDate ?? this.newSortedChatsByDate,
      getChatsStatus: getChatsStatus ?? this.getChatsStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      changeChatPropertyStatus:
          changeChatPropertyStatus ?? this.changeChatPropertyStatus,
      getContactsStatus: getContactsStatus ?? this.getContactsStatus,
      contacts: contacts ?? this.contacts,
      chats: chats ?? this.chats,
      createAnewChat: createAnewChat ?? this.createAnewChat,
      deleteChatStatus: deleteChatStatus ?? this.deleteChatStatus,
      currentFailedMessage: currentFailedMessage ?? this.currentFailedMessage,
      changeMessageStateFromPusherStatus: changeMessageStateFromPusherStatus ??
          this.changeMessageStateFromPusherStatus,
      scrollToParentMessage:
          scrollToParentMessage ?? this.scrollToParentMessage,
      notifyThatIReceivedMessageStatus: notifyThatIReceivedMessageStatus ??
          this.notifyThatIReceivedMessageStatus,
      currentMessage: currentMessage ?? this.currentMessage,
      pinnedChats: pinnedChats ?? this.pinnedChats,
      unReadMessagesFromAllChats:
          unReadMessagesFromAllChats ?? this.unReadMessagesFromAllChats,
      currentChannelReceivedMessage:
          currentChannelReceivedMessage ?? this.currentChannelReceivedMessage,
      saveContactsStatus: saveContactsStatus ?? this.saveContactsStatus,
      channelId: channelId ?? this.channelId,
      firstMessageId: firstMessageId ?? this.firstMessageId,
      secondMessageId: secondMessageId ?? this.secondMessageId,
      messageContent: messageContent ?? this.messageContent,
      readMessagesStatus: readMessagesStatus ?? this.readMessagesStatus,
      messageType: messageType ?? this.messageType,
      receiveMessageStatus: receiveMessageStatus ?? this.receiveMessageStatus,
      getMessagesBetweenStatus:
          getMessagesBetweenStatus ?? this.getMessagesBetweenStatus,
    );
  }
}
