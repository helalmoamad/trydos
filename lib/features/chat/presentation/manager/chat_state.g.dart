// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatState _$ChatStateFromJson(Map<String, dynamic> json) => ChatState(
      getMediaCountStatus: $enumDecodeNullable(
              _$GetMediaCountStatusEnumMap, json['getMediaCountStatus']) ??
          GetMediaCountStatus.init,
      width: json['width'] as int? ?? 0,
      slopMessageId: json['slopMessageId'] as String? ?? "",
      isSlpoing: json['isSlpoing'] as bool? ?? false,
      height: json['height'] as int? ?? 0,
      imageCountInEachChat: json['imageCountInEachChat'] as int? ?? 0,
      fileCountInEachChat: json['fileCountInEachChat'] as int? ?? 0,
      videoCountInEachChat: json['videoCountInEachChat'] as int? ?? 0,
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
          json['unReadMessagesFromAllChats'] as int? ?? 0,
      currentChannelReceivedMessage:
          json['currentChannelReceivedMessage'] as String? ?? '-1',
      messageType: json['messageType'] as String?,
      firstMessageId: json['firstMessageId'] as String?,
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
      'chats': instance.chats.map((e) => e.toJson()).toList(),
      'pinnedChats': instance.pinnedChats.map((e) => e.toJson()).toList(),
      'currentMessage': instance.currentMessage,
      'currentFailedMessage': instance.currentFailedMessage,
      'channelId': instance.channelId,
      'messageType': instance.messageType,
      'messageContent': instance.messageContent,
      'firstMessageId': instance.firstMessageId,
      'secondMessageId': instance.secondMessageId,
      'slopMessageId': instance.slopMessageId,
      'unReadMessagesFromAllChats': instance.unReadMessagesFromAllChats,
      'currentChannelReceivedMessage': instance.currentChannelReceivedMessage,
      'scrollToParentMessage': instance.scrollToParentMessage,
      'createAnewChat': instance.createAnewChat,
      'newSortedChatsByDate': instance.newSortedChatsByDate
          ?.map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
    };

const _$GetMediaCountStatusEnumMap = {
  GetMediaCountStatus.init: 'init',
  GetMediaCountStatus.loading: 'loading',
  GetMediaCountStatus.success: 'success',
  GetMediaCountStatus.failure: 'failure',
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
