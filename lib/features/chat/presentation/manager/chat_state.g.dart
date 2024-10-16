// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatState _$ChatStateFromJson(Map<String, dynamic> json) => ChatState(
      userConnectedStatuse: json['userConnectedStatuse'] as String? ?? " ",
      currentFailedMediaMessage:
          (json['currentFailedMediaMessage'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      getMediaCountStatus: $enumDecodeNullable(
              _$GetMediaCountStatusEnumMap, json['getMediaCountStatus']) ??
          GetMediaCountStatus.init,
      resendMessageStatus: $enumDecodeNullable(
              _$ResendMessageStatusEnumMap, json['resendMessageStatus']) ??
          ResendMessageStatus.init,
      width: (json['width'] as num?)?.toInt() ?? 0,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      slopMessageId: json['slopMessageId'] as String? ?? "",
      isSlpoing: json['isSlpoing'] as bool? ?? false,
      firstRequestForGetChats: json['firstRequestForGetChats'] as bool? ?? true,
      height: (json['height'] as num?)?.toInt() ?? 0,
      imageCountInEachChat:
          (json['imageCountInEachChat'] as num?)?.toInt() ?? 0,
      getSharedProductCountStatus: $enumDecodeNullable(
          _$GetSharedProductCountStatusEnumMap,
          json['getSharedProductCountStatus']),
      fileCountInEachChat: (json['fileCountInEachChat'] as num?)?.toInt() ?? 0,
      getSharedProductCount:
          (json['getSharedProductCount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      videoCountInEachChat:
          (json['videoCountInEachChat'] as num?)?.toInt() ?? 0,
      loadImageWidthAndHeight: $enumDecodeNullable(
              _$LoadImageWidthAndHeightEnumMap,
              json['loadImageWidthAndHeight']) ??
          LoadImageWidthAndHeight.init,
      newSortedChatsByDate:
          (json['newSortedChatsByDate'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e as List<dynamic>)
                        .map((e) => Message.fromJson(e as Map<String, dynamic>))
                        .toList()),
              ) ??
              const {},
      currentOpenedChatId: json['currentOpenedChatId'] as String?,
      getContactsStatus: $enumDecodeNullable(
              _$GetContactsStatusEnumMap, json['getContactsStatus']) ??
          GetContactsStatus.init,
      changeMessageStateFromPusherStatus: $enumDecodeNullable(
              _$ChangeMessageStateFromPusherStatusEnumMap,
              json['changeMessageStateFromPusherStatus']) ??
          ChangeMessageStateFromPusherStatus.init,
      getMessagesBetweenStatus: $enumDecodeNullable(
              _$GetMessagesBetweenStatusEnumMap,
              json['getMessagesBetweenStatus']) ??
          GetMessagesBetweenStatus.init,
      changeChatPropertyStatus: $enumDecodeNullable(
              _$ChangeChatPropertyStatusEnumMap,
              json['changeChatPropertyStatus']) ??
          ChangeChatPropertyStatus.init,
      saveContactsStatus: $enumDecodeNullable(
              _$SaveContactsStatusEnumMap, json['saveContactsStatus']) ??
          SaveContactsStatus.init,
      sendMessageStatus: $enumDecodeNullable(
              _$SendMessageStatusEnumMap, json['sendMessageStatus']) ??
          SendMessageStatus.init,
      readMessagesStatus: $enumDecodeNullable(
              _$ResetReadMessagesStatusEnumMap, json['readMessagesStatus']) ??
          ResetReadMessagesStatus.init,
      deleteChatStatus: $enumDecodeNullable(
              _$DeleteChatStatusEnumMap, json['deleteChatStatus']) ??
          DeleteChatStatus.init,
      notifyThatIReceivedMessageStatus: $enumDecodeNullable(
              _$NotifyThatIReceivedMessageStatusEnumMap,
              json['notifyThatIReceivedMessageStatus']) ??
          NotifyThatIReceivedMessageStatus.init,
      receiveMessageStatus: $enumDecodeNullable(
              _$ReceiveMessageStatusEnumMap, json['receiveMessageStatus']) ??
          ReceiveMessageStatus.init,
      getChatsStatus: $enumDecodeNullable(
              _$GetChatsStatusEnumMap, json['getChatsStatus']) ??
          GetChatsStatus.init,
      channelId: json['channelId'] as String? ?? '-1',
      unReadMessagesFromAllChats:
          (json['unReadMessagesFromAllChats'] as num?)?.toInt() ?? 0,
      currentChannelReceivedMessage:
          json['currentChannelReceivedMessage'] as String? ?? '-1',
      messageType: json['messageType'] as String?,
      firstMessageId: json['firstMessageId'] as String?,
      chatToNavigateFromTerminated: json['chatToNavigateFromTerminated'] == null
          ? null
          : Chat.fromJson(
              json['chatToNavigateFromTerminated'] as Map<String, dynamic>),
      scrollToParentMessage: json['scrollToParentMessage'] as bool? ?? false,
      createAnewChat: json['createAnewChat'] as bool? ?? false,
      secondMessageId: json['secondMessageId'] as String?,
      messageContent: json['messageContent'] as String?,
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => Contact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      chats: (json['chats'] as List<dynamic>?)
              ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pinnedChats: (json['pinnedChats'] as List<dynamic>?)
              ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentMessage: (json['currentMessage'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentFailedMessage: (json['currentFailedMessage'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChatStateToJson(ChatState instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'isSlpoing': instance.isSlpoing,
      'imageCountInEachChat': instance.imageCountInEachChat,
      'fileCountInEachChat': instance.fileCountInEachChat,
      'videoCountInEachChat': instance.videoCountInEachChat,
      'getChatsStatus': _$GetChatsStatusEnumMap[instance.getChatsStatus]!,
      'sendMessageStatus':
          _$SendMessageStatusEnumMap[instance.sendMessageStatus]!,
      'receiveMessageStatus':
          _$ReceiveMessageStatusEnumMap[instance.receiveMessageStatus]!,
      'loadImageWidthAndHeight':
          _$LoadImageWidthAndHeightEnumMap[instance.loadImageWidthAndHeight]!,
      'saveContactsStatus':
          _$SaveContactsStatusEnumMap[instance.saveContactsStatus]!,
      'getContactsStatus':
          _$GetContactsStatusEnumMap[instance.getContactsStatus]!,
      'duration': instance.duration?.inMicroseconds,
      'getSharedProductCount': instance.getSharedProductCount,
      'getMediaCountStatus':
          _$GetMediaCountStatusEnumMap[instance.getMediaCountStatus]!,
      'readMessagesStatus':
          _$ResetReadMessagesStatusEnumMap[instance.readMessagesStatus]!,
      'getMessagesBetweenStatus':
          _$GetMessagesBetweenStatusEnumMap[instance.getMessagesBetweenStatus]!,
      'notifyThatIReceivedMessageStatus':
          _$NotifyThatIReceivedMessageStatusEnumMap[
              instance.notifyThatIReceivedMessageStatus]!,
      'changeMessageStateFromPusherStatus':
          _$ChangeMessageStateFromPusherStatusEnumMap[
              instance.changeMessageStateFromPusherStatus]!,
      'changeChatPropertyStatus':
          _$ChangeChatPropertyStatusEnumMap[instance.changeChatPropertyStatus]!,
      'deleteChatStatus': _$DeleteChatStatusEnumMap[instance.deleteChatStatus]!,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'currentOpenedChatId': instance.currentOpenedChatId,
      'resendMessageStatus':
          _$ResendMessageStatusEnumMap[instance.resendMessageStatus]!,
      'chats': instance.chats.map((e) => e.toJson()).toList(),
      'pinnedChats': instance.pinnedChats.map((e) => e.toJson()).toList(),
      'currentMessage': instance.currentMessage,
      'currentFailedMessage': instance.currentFailedMessage,
      'currentFailedMediaMessage': instance.currentFailedMediaMessage,
      'channelId': instance.channelId,
      'messageType': instance.messageType,
      'userConnectedStatuse': instance.userConnectedStatuse,
      'messageContent': instance.messageContent,
      'firstMessageId': instance.firstMessageId,
      'secondMessageId': instance.secondMessageId,
      'slopMessageId': instance.slopMessageId,
      'unReadMessagesFromAllChats': instance.unReadMessagesFromAllChats,
      'currentChannelReceivedMessage': instance.currentChannelReceivedMessage,
      'scrollToParentMessage': instance.scrollToParentMessage,
      'chatToNavigateFromTerminated':
          instance.chatToNavigateFromTerminated?.toJson(),
      'getSharedProductCountStatus': _$GetSharedProductCountStatusEnumMap[
          instance.getSharedProductCountStatus],
      'createAnewChat': instance.createAnewChat,
      'newSortedChatsByDate': instance.newSortedChatsByDate
          ?.map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
      'firstRequestForGetChats': instance.firstRequestForGetChats,
    };

const _$GetMediaCountStatusEnumMap = {
  GetMediaCountStatus.init: 'init',
  GetMediaCountStatus.loading: 'loading',
  GetMediaCountStatus.success: 'success',
  GetMediaCountStatus.failure: 'failure',
};

const _$ResendMessageStatusEnumMap = {
  ResendMessageStatus.init: 'init',
  ResendMessageStatus.loading: 'loading',
  ResendMessageStatus.success: 'success',
  ResendMessageStatus.failure: 'failure',
};

const _$GetSharedProductCountStatusEnumMap = {
  GetSharedProductCountStatus.init: 'init',
  GetSharedProductCountStatus.loading: 'loading',
  GetSharedProductCountStatus.success: 'success',
  GetSharedProductCountStatus.failure: 'failure',
};

const _$LoadImageWidthAndHeightEnumMap = {
  LoadImageWidthAndHeight.init: 'init',
  LoadImageWidthAndHeight.loading: 'loading',
  LoadImageWidthAndHeight.success: 'success',
  LoadImageWidthAndHeight.failure: 'failure',
};

const _$GetContactsStatusEnumMap = {
  GetContactsStatus.init: 'init',
  GetContactsStatus.loading: 'loading',
  GetContactsStatus.success: 'success',
  GetContactsStatus.failure: 'failure',
};

const _$ChangeMessageStateFromPusherStatusEnumMap = {
  ChangeMessageStateFromPusherStatus.init: 'init',
  ChangeMessageStateFromPusherStatus.received: 'received',
  ChangeMessageStateFromPusherStatus.watched: 'watched',
};

const _$GetMessagesBetweenStatusEnumMap = {
  GetMessagesBetweenStatus.init: 'init',
  GetMessagesBetweenStatus.loading: 'loading',
  GetMessagesBetweenStatus.success: 'success',
  GetMessagesBetweenStatus.failure: 'failure',
};

const _$ChangeChatPropertyStatusEnumMap = {
  ChangeChatPropertyStatus.init: 'init',
  ChangeChatPropertyStatus.loading: 'loading',
  ChangeChatPropertyStatus.success: 'success',
  ChangeChatPropertyStatus.failure: 'failure',
};

const _$SaveContactsStatusEnumMap = {
  SaveContactsStatus.init: 'init',
  SaveContactsStatus.loading: 'loading',
  SaveContactsStatus.success: 'success',
  SaveContactsStatus.failure: 'failure',
};

const _$SendMessageStatusEnumMap = {
  SendMessageStatus.init: 'init',
  SendMessageStatus.loading: 'loading',
  SendMessageStatus.success: 'success',
  SendMessageStatus.failure: 'failure',
};

const _$ResetReadMessagesStatusEnumMap = {
  ResetReadMessagesStatus.init: 'init',
  ResetReadMessagesStatus.loading: 'loading',
  ResetReadMessagesStatus.success: 'success',
  ResetReadMessagesStatus.failure: 'failure',
};

const _$DeleteChatStatusEnumMap = {
  DeleteChatStatus.init: 'init',
  DeleteChatStatus.loading: 'loading',
  DeleteChatStatus.success: 'success',
  DeleteChatStatus.failure: 'failure',
};

const _$NotifyThatIReceivedMessageStatusEnumMap = {
  NotifyThatIReceivedMessageStatus.init: 'init',
  NotifyThatIReceivedMessageStatus.loading: 'loading',
  NotifyThatIReceivedMessageStatus.success: 'success',
  NotifyThatIReceivedMessageStatus.failure: 'failure',
};

const _$ReceiveMessageStatusEnumMap = {
  ReceiveMessageStatus.init: 'init',
  ReceiveMessageStatus.loading: 'loading',
  ReceiveMessageStatus.success: 'success',
  ReceiveMessageStatus.failure: 'failure',
};

const _$GetChatsStatusEnumMap = {
  GetChatsStatus.init: 'init',
  GetChatsStatus.loading: 'loading',
  GetChatsStatus.success: 'success',
  GetChatsStatus.failure: 'failure',
};
