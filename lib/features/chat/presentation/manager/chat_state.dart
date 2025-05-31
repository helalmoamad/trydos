import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/core/data/model/pagination_model.dart';

import '../../data/models/my_chats_response_model.dart';
import '../../data/models/my_contacts_response_model.dart';
part 'chat_state.g.dart';

enum SaveContactsStatus { init, loading, success, failure }

enum GetMediaCountStatus { init, loading, success, failure }

enum LoadImageWidthAndHeight { init, loading, success, failure }

enum GetContactsStatus { init, loading, success, failure }

enum GetOrderRecipientIdStatus { init, loading, success, failure }

enum GetChatsStatus { init, loading, success, failure }

//enum SearchTextInChatStatus { init, loading, success, failure }

enum SendMessageStatus { init, loading, success, failure }

enum GetSharedProductCountStatus { init, loading, success, failure }

enum ReceiveMessageStatus { init, loading, success, failure }

enum GetMessagesBetweenStatus { init, loading, success, failure }

enum ResetReadMessagesStatus { init, loading, success, failure }

enum NotifyThatIReceivedMessageStatus { init, loading, success, failure }

enum ChangeChatPropertyStatus { init, loading, success, failure }

enum DeleteChatStatus { init, loading, success, failure }

enum ChangeMessageStateFromPusherStatus { init, received, watched }

enum ResendMessageStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
class ChatState {
  final int width;
  final int height;
  final bool isSlpoing;
  int imageCountInEachChat;
  int fileCountInEachChat;
  int videoCountInEachChat;
  final GetChatsStatus getChatsStatus;
  final SendMessageStatus sendMessageStatus;
  final ReceiveMessageStatus receiveMessageStatus;
  final LoadImageWidthAndHeight loadImageWidthAndHeight;
  final SaveContactsStatus saveContactsStatus;
  final GetContactsStatus getContactsStatus;
  final Duration? duration;
  final Map<String, String>? getSharedProductCount;
  final GetMediaCountStatus getMediaCountStatus;
  final ResetReadMessagesStatus readMessagesStatus;
  final String currentRequestIdForAvoidPreRequest;
  //final SearchTextInChatStatus? searchTextInChatStatus;
  final GetMessagesBetweenStatus getMessagesBetweenStatus;
  final NotifyThatIReceivedMessageStatus notifyThatIReceivedMessageStatus;
  final ChangeMessageStateFromPusherStatus changeMessageStateFromPusherStatus;
  final ChangeChatPropertyStatus changeChatPropertyStatus;
  final DeleteChatStatus deleteChatStatus;
  final List<Contact> contacts;
  final String? currentOpenedChatId;
  final ResendMessageStatus resendMessageStatus;
  List<Chat> chats;
  final List<Chat> pinnedChats;
  late final List<String> currentMessage;
  final List<String> currentFailedMessage;
  final List<String> currentFailedMediaMessage;
  final PaginationModel<String>? resultOfSearchTextInChat;
  final String channelId;
  final String? messageType;
  final String userConnectedStatuse;
  final String? messageContent;
  final GetOrderRecipientIdStatus getOrderRecipientIdStatus;
  final String? firstMessageId;
  final String? secondMessageId;
  final String? slopMessageId;
  final int unReadMessagesFromAllChats;
  final String? recipientUserId;
  final String currentChannelReceivedMessage;
  final bool scrollToParentMessage;
  final Chat? chatToNavigateFromTerminated;
  final GetSharedProductCountStatus? getSharedProductCountStatus;
  final bool createAnewChat;
  Map<String, List<Message>>? newSortedChatsByDate;
  final bool firstRequestForGetChats;
  ChatState({
    this.userConnectedStatuse = " ",
    this.currentFailedMediaMessage = const [],
    this.getMediaCountStatus = GetMediaCountStatus.init,
    this.resendMessageStatus = ResendMessageStatus.init,
    this.width = 0,
    this.resultOfSearchTextInChat = const PaginationModel.init(),
    this.duration,
    this.slopMessageId = "",
    this.isSlpoing = false,
    this.firstRequestForGetChats = true,
    this.height = 0,
    this.imageCountInEachChat = 0,
    this.getSharedProductCountStatus,
    this.currentRequestIdForAvoidPreRequest = "",
    this.fileCountInEachChat = 0,
    this.recipientUserId,
    this.getSharedProductCount,
    this.videoCountInEachChat = 0,
    //this.searchTextInChatStatus = SearchTextInChatStatus.init,
    this.loadImageWidthAndHeight = LoadImageWidthAndHeight.init,
    this.newSortedChatsByDate = const {},
    this.currentOpenedChatId,
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
    this.getOrderRecipientIdStatus = GetOrderRecipientIdStatus.init,
    this.receiveMessageStatus = ReceiveMessageStatus.init,
    this.getChatsStatus = GetChatsStatus.init,
    this.channelId = '-1',
    this.unReadMessagesFromAllChats = 0,
    this.currentChannelReceivedMessage = '-1',
    this.messageType,
    this.firstMessageId,
    this.chatToNavigateFromTerminated,
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
    //final SearchTextInChatStatus? searchTextInChatStatus,
    String? slopMessageId,
    bool? isSlpoing,
    final int? imageCountInEachChat,
    final GetMediaCountStatus? getMediaCountStatus,
    final int? fileCountInEachChat,
    final int? videoCountInEachChat,
    LoadImageWidthAndHeight? loadImageWidthAndHeight,
    Map<String, List<Message>>? newSortedChatsByDate,
    final GetChatsStatus? getChatsStatus,
    final Duration? duration,
    final GetOrderRecipientIdStatus? getOrderRecipientIdStatus,
    final bool? firstRequestForGetChats,
    final ResendMessageStatus? resendMessageStatus,
    final SendMessageStatus? sendMessageStatus,
    final String? recipientUserId,
    final ReceiveMessageStatus? receiveMessageStatus,
    final PaginationModel<String>? resultOfSearchTextInChat,
    final ChangeChatPropertyStatus? changeChatPropertyStatus,
    final SaveContactsStatus? saveContactsStatus,
    final GetContactsStatus? getContactsStatus,
    final GetMessagesBetweenStatus? getMessagesBetweenStatus,
    final DeleteChatStatus? deleteChatStatus,
    final List<Contact>? contacts,
    final String? channelId,
    final String? currentOpenedChatId,
    final bool? scrollToParentMessage,
    final String? firstMessageId,
    final String? secondMessageId,
    final int? currentOpenedChannelId,
    final ResetReadMessagesStatus? readMessagesStatus,
    final Chat? chatToNavigateFromTerminated,
    final NotifyThatIReceivedMessageStatus? notifyThatIReceivedMessageStatus,
    final ChangeMessageStateFromPusherStatus?
        changeMessageStateFromPusherStatus,
    final String? currentChannelReceivedMessage,
    final List<Chat>? chats,
    final bool? createAnewChat,
    final String? currentRequestIdForAvoidPreRequest,
    final List<String>? currentMessage,
    final List<String>? currentFailedMessage,
    final List<String>? currentFailedMediaMessage,
    final int? unReadMessagesFromAllChats,
    final String? messageType,
    final String? messageContent,
    final Map<String, String>? getSharedProductCount,
    final GetSharedProductCountStatus? getSharedProductCountStatus,
    String? userConnectedStatuse,
    final List<Chat>? pinnedChats,
  }) {
    return ChatState(
      duration: duration ?? this.duration,
      userConnectedStatuse: userConnectedStatuse ?? this.userConnectedStatuse,
      width: width ?? this.width,
      slopMessageId: slopMessageId ?? this.slopMessageId,
      isSlpoing: isSlpoing ?? this.isSlpoing,
      firstRequestForGetChats:
          firstRequestForGetChats ?? this.firstRequestForGetChats,
      height: height ?? this.height,
      resendMessageStatus: resendMessageStatus ?? this.resendMessageStatus,
      imageCountInEachChat: imageCountInEachChat ?? this.imageCountInEachChat,
      getMediaCountStatus: getMediaCountStatus ?? this.getMediaCountStatus,
      getSharedProductCountStatus:
          getSharedProductCountStatus ?? this.getSharedProductCountStatus,
      fileCountInEachChat: fileCountInEachChat ?? this.fileCountInEachChat,
      videoCountInEachChat: videoCountInEachChat ?? this.videoCountInEachChat,
      loadImageWidthAndHeight:
          loadImageWidthAndHeight ?? this.loadImageWidthAndHeight,
      getOrderRecipientIdStatus:
          getOrderRecipientIdStatus ?? this.getOrderRecipientIdStatus,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      resultOfSearchTextInChat:
          resultOfSearchTextInChat ?? this.resultOfSearchTextInChat,
      newSortedChatsByDate: newSortedChatsByDate ?? this.newSortedChatsByDate,
      // searchTextInChatStatus:
      //     searchTextInChatStatus ?? this.searchTextInChatStatus,
      getChatsStatus: getChatsStatus ?? this.getChatsStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      changeChatPropertyStatus:
          changeChatPropertyStatus ?? this.changeChatPropertyStatus,
      getContactsStatus: getContactsStatus ?? this.getContactsStatus,
      chatToNavigateFromTerminated:
          chatToNavigateFromTerminated ?? this.chatToNavigateFromTerminated,
      contacts: contacts ?? this.contacts,
      chats: chats ?? this.chats,
      currentRequestIdForAvoidPreRequest: currentRequestIdForAvoidPreRequest ??
          this.currentRequestIdForAvoidPreRequest,
      currentOpenedChatId: currentOpenedChatId ?? this.currentOpenedChatId,
      createAnewChat: createAnewChat ?? this.createAnewChat,
      deleteChatStatus: deleteChatStatus ?? this.deleteChatStatus,
      currentFailedMessage: currentFailedMessage ?? this.currentFailedMessage,
      currentFailedMediaMessage:
          currentFailedMediaMessage ?? this.currentFailedMediaMessage,
      changeMessageStateFromPusherStatus: changeMessageStateFromPusherStatus ??
          this.changeMessageStateFromPusherStatus,
      scrollToParentMessage:
          scrollToParentMessage ?? this.scrollToParentMessage,
      getSharedProductCount:
          getSharedProductCount ?? this.getSharedProductCount,
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

  factory ChatState.fromJson(Map<String, dynamic> data) =>
      _$ChatStateFromJson(data);

  Map<String, dynamic> toJson() => _$ChatStateToJson(this);
}
