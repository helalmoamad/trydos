import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/domain/use_cases/change_chat_property_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/delete_chat_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_date_time.dart';
import 'package:trydos/features/chat/domain/use_cases/get_media_count_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_messages_between_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_messages_for_chat_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_my_chats_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_shared_product_count_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/read_all_messages_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/receive_message_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/save_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/send_error_to_server_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/send_message_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/share_product_on_social_app_count_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/upload_file_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/share_product_with_contacts_or_channels_usecase.dart';
import 'package:trydos/features/feed_back/presentation/pages/shared_preference_page.dart';
import 'package:trydos/main.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/domin/usecases/upload_file_cloudinary_usecase.dart';
import '../../../../service/notification_service/notification_service/handle_notification/notification_process.dart';
import '../../data/models/my_chats_response_model.dart';
import '../../data/models/my_contacts_response_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'helper_function_for_chat_bloc/group_received_message_on_days.dart';
import 'helper_function_for_chat_bloc/merge_chats_from_pagination.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class ChatBloc extends HydratedBloc<ChatEvent, ChatState> {
  ChatBloc(
      this.getContactsUseCase,
      this.getMyChatsUseCase,
      this.shareProductOnAppsUseCase,
      this.saveContactsUseCase,
      this.sendMessageUseCase,
      this.getSharedProductCountUseCase,
      this.getMessagesBetweenUseCase,
      this.uploadFileCloudinaryUseCase,
      this.getMessagesForChatUseCase,
      this.deleteChatUseCase,
      this.changeChatPropertyUseCase,
      this.uploadFileUseCase,
      this.readAllMessagesUseCase,
      this.receiveMessageUseCase,
      this.shareProductWithContactsOrChannelsUsecase,
      this.getMediaCountUseCase,
      this.getDateTimeUseCase,
      this.sendErrorToServerUseCase)
      : super(ChatState()) {
    on<ChatEvent>((event, emit) {});
    on<UpdateChannelObjectFromNotificationEvent>(
        _onUpdateChannelObjectFromNotificationEvent);
    on<SendErrorChatToServerEvent>(_onSendErrorChatToServerEvent);
    on<IncreaseSharedProductCountOnSocialAppEvent>(
        _onIncreaseSharedProductCountOnSocialAppEvent);
    on<DeleteChatFromNotificationEvent>(_onDeleteChatFromNotificationEvent);
    on<ChangeGlobalUsedVariablesInBloc>(_onChangeGlobalUsedVariablesInBloc);
    on<ResendMessageEvent>(_onResendMessageEvent);
    on<GetDateTimeEvent>(_onGetDateTimeEvent);
    on<AddAMessageToAChannel>(_onAddAMessageToAChannel);
    on<AddChannelToChannels>(_onAddChannelToChannels);
    on<AddUserConntctSatuseEvent>(_onAddUserConntctSatuseEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<ShareProductWithContactsOrChannelsEvent>(
        _onShareProductWithContactsOrChannelsEvent);
    on<IncreaseFileImageVideoCounterEvent>(
        _onIncreaseFileImageVideoCounterEvent);
    on<ReadAllMessagesEvent>(_onReadAllMessagesEvent);
    on<NotifyThatIReceivedMessageEvent>(_onNotifyThatIReceivedMessageEvent);
    on<ReceiveMessageEvent>(_onReceiveMessageEvent);
    on<UploadFileEvent>(_onUploadFileEvent);
    on<ChangeSlop>(_onChangeSlop);
    on<DeleteMessageNotificationReceivedInChatsEvent>(
        _onDeleteMessageNotificationReceivedInChatsEvent);
    on<DeleteChatEvent>(_onDeleteChatEvent);

    on<GetSharedProductCountEvent>(_onGetSharedProductCountEvent);
    on<ReceiveMessageFromPusherEvent>(_onReceiveMessageFromPusherEvent);
    on<WatchedMessageFromPusherEvent>(_onWatchedMessageFromPusherEvent);
    on<ChangeChatPropertyEvent>(_onChangeChatPropertyEvent);
    on<GetMessagesForChatEvent>(_onGetMessagesForChatEvent);
    on<GetAllMessagesBetweenEvent>(_onGetAllMessagesBetweenEvent,
        transformer: throttleDroppable(throttleDuration));
    on<SaveContactsEvent>(
      _onSaveContactsEvent,
    );
    on<GetChatsEvent>(_onGetChatsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<ReceiveMissCallEvent>(
      _onReceiveMissCallEvent,
    );

    on<GetContactsEvent>(_onGetContactsEvent,
        transformer: throttleDroppable(throttleDuration));

    on<AddMediaCountEvent>(
      _onAddMediaCountEvent,
    );
  }

  final SendMessageUseCase sendMessageUseCase;
  final GetMediaCountUseCase getMediaCountUseCase;
  final SaveContactsUseCase saveContactsUseCase;
  final GetContactsUseCase getContactsUseCase;
  final GetSharedProductCountUseCase getSharedProductCountUseCase;
  final GetDateTimeUseCase getDateTimeUseCase;
  final GetMyChatsUseCase getMyChatsUseCase;
  final SendErrorToServerUseCase sendErrorToServerUseCase;
  final UploadFileCloudinaryUseCase uploadFileCloudinaryUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final ShareProductOnAppsUseCase shareProductOnAppsUseCase;
  final ReadAllMessagesUseCase readAllMessagesUseCase;
  final ReceiveMessageUseCase receiveMessageUseCase;
  final DeleteChatUseCase deleteChatUseCase;
  final ChangeChatPropertyUseCase changeChatPropertyUseCase;
  final GetMessagesForChatUseCase getMessagesForChatUseCase;
  final GetMessagesBetweenUseCase getMessagesBetweenUseCase;
  final ShareProductWithContactsOrChannelsUsecase
      shareProductWithContactsOrChannelsUsecase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  String? currentOpenedChatId;
  bool enableRequestGetChats = true;

  FutureOr<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    //todo waiting messages and not sent yet

    List<String> ids = List.of(state.currentMessage);
    List<Message> messages;
    bool fromPinned = false;

    //todo ---if-----
    //todo check if the channel exist and get the messages of this channel
    if (state.chats.any(
      (e) => e.id == event.channelId,
    )) {
      messages = List.of(state.chats
              .firstWhere((element) => element.id == event.channelId)
              .messages ??
          []);
    }
    //todo the same but from the pinned channels

    else {
      fromPinned = true;
      messages = List.of(state.pinnedChats
              .firstWhere((element) => element.id == event.channelId)
              .messages ??
          []);
    }
    String? parentMessageId;

    //todo just add the message to the waiting list and give it the local info like localParentMessageId
    if (!ids.contains(event.messageId)) {
      ids.add(event.messageId);

      //todo check if the message has a parentMessage an get it
      int index = messages.indexWhere((element) =>
          element.localId == event.parentMessageId &&
          event.parentMessageId != null);
      parentMessageId = event.parentMessageId;
      //
      if (index != -1) {
        parentMessageId = messages[index].id;
      }

      //todo insert the new message in the first of the list
      messages.insert(
          0,
          Message(
              channelId: event.channelId,
              id: event.messageId,
              localId: event.messageId,
              createdAt: DateTime.now(),
              receiverUserId: event.receiverUserId,
              messageContent: event.messageType == 'TextMessage'
                  ? MessageContent(
                      messageId: int.tryParse(event.messageId),
                      content: event.content)
                  : null,
              senderUserId: _prefsRepository.myChatId,
              messageType: MessageType(name: event.messageType),
              isForward: (event.isForward ?? false) ? 1 : 0,
              parentMessageId: parentMessageId,
              localParentMessageId: event.parentMessageId,
              authMessageStatus:
                  MessageStatus(isDeleted: 0, deleteForAll: false),
              mediaMessageContent: event.messageType != 'TextMessage'
                  ? [
                      MediaMessageContent(
                          filePath: event.mediaContent?[0]['file_path'],
                          titleMedium: event.mediaContent?[0]['titleMedium'])
                    ]
                  : null,
              parentMessage: parentMessageId != null
                  ? Message(
                      file: event.file,
                      senderUserId: index != -1
                          ? messages[index].senderUserId
                          : event.senderParentMessageId,
                      messageContent:
                          MessageContent(content: event.parentMessageContent))
                  : null));
    }
    if (event.messageType != 'TextMessage') {
      int index = messages.indexWhere((element) =>
          element.localId == event.parentMessageId &&
          event.parentMessageId != null);
      parentMessageId = event.parentMessageId;
      if (index != -1) {
        parentMessageId = messages[index].id;
      }
    }

    //todo remove the chat  and reinsert it in the first of the List<Chat>
    List<Chat> chats;
    if (fromPinned) {
      chats = sortChats(state.pinnedChats, event.channelId, messages);
    } else {
      chats = sortChats(state.chats, event.channelId, messages);
    }

    //todo  createAnewChat  so if the condition true that's mean the message from the local
    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
        createAnewChat: int.tryParse(event.channelId) == null,
        newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
          ...chats,
          ...(fromPinned ? state.chats : state.pinnedChats)
        ]),
        chats: fromPinned ? state.chats : chats,
        pinnedChats: !fromPinned ? state.pinnedChats : chats,
        channelId: event.channelId));
    final response = await sendMessageUseCase(
      SendMessageParams(
          content: event.content,
          extraFields: event.extraFields,
          isForward: event.isForward,
          mediaContent: event.mediaContent,
          messageType: event.messageType,
          parentMessageId: parentMessageId,
          receiverUserId: event.receiverUserId),
    );
    response.fold(
      (l) {
        List<String> currentFailedMessage = List.of(state.currentFailedMessage);
        ids.remove(event.messageId);
        currentFailedMessage.add(event.messageId);
        emit(state.copyWith(
            sendMessageStatus: SendMessageStatus.failure,
            currentMessage: ids,
            currentFailedMessage: currentFailedMessage));
      },
      (r) {
        print("///-------------------------------------*${r.parentMessage}");

//        debugPrint('count  ${messages.length}');
        print('mediaMessageContent ${r.mediaMessageContent}');
        if (currentOpenedChatId == event.channelId) {
          currentOpenedChatId = r.channel!.id;
        }
        ids.remove(event.messageId);
        List<Chat> pinnedChats = state.pinnedChats.map((e) {
          if (e.localId == event.channelId &&
              int.tryParse(event.channelId) == null) {
            return r.channel!.copyWith(
                localId: event.channelId,
                channelMembers: state.pinnedChats
                    .firstWhere((element) => element.id == event.channelId)
                    .channelMembers,
                messages: e.messages?.map((e) {
                  if (e.localId == event.messageId) {
                    return r.copyWith(localId: e.localId);
                  }
                  return e;
                }).toList());
          } else if (e.id == event.channelId) {
            List<Message> messages = List.of(e.messages ?? []);
            int index = messages.indexWhere((element) =>
                (element.id == event.messageId ||
                    element.localId == event.messageId));
            messages[index] = r.copyWith(
              file: event.file,
              localId: event.messageId,
            );

            return e.copyWith(messages: messages);
          }
          return e;
        }).toList();
        List<Chat> chats = state.chats.map((e) {
          if (e.localId == event.channelId &&
              int.tryParse(event.channelId) == null) {
            return r.channel!.copyWith(
                localId: event.channelId,
                channelMembers: state.chats
                    .firstWhere((element) => element.id == event.channelId)
                    .channelMembers,
                messages: e.messages?.map((e) {
                  if (e.localId == event.messageId) {
                    return r.copyWith(localId: e.localId);
                  }
                  return e;
                }).toList());
          } else if (e.id == event.channelId) {
            List<Message> messages = List.of(e.messages ?? []);
            int index = messages.indexWhere((element) =>
                (element.id == event.messageId ||
                    element.localId == event.messageId));
            messages[index] =
                r.copyWith(file: event.file, localId: event.messageId);
            return e.copyWith(messages: messages);
          }
          return e;
        }).toList();
        if (event.file != null) {
          _prefsRepository.setAFilePathExist(
              event.mediaContent![0]['file_path'] + ' ' + event.file!.path,
              r.channel!.id!);
        }
        emit(
          state.copyWith(
              chats: chats,
              createAnewChat: false,
              sendMessageStatus: SendMessageStatus.success,
              pinnedChats: pinnedChats,
              newSortedChatsByDate:
                  groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
              currentMessage: ids),
        );

        //  add(IncreaseFileImageVideoCounterEvent(r.messageType!.name!));
      },
    );
  }

  FutureOr<void> _onShareProductWithContactsOrChannelsEvent(
      ShareProductWithContactsOrChannelsEvent event,
      Emitter<ChatState> emit) async {
    //todo waiting messages and not sent yet
    final String messageId = Uuid().v4();
    List<Chat> chats = List.of(state.chats);
    List<Chat> pinnedChats = List.of(state.pinnedChats);
    List<String> ids = List.of(state.currentMessage);
    Map<String, List<Message>> messagesPerChannel = {};
    Map<String, int?> receivers = {};

    // load messages of channels
    for (int i = 0; i < chats.length; i++) {
      if (event.channelIds.contains(chats[i].id)) {
        messagesPerChannel[chats[i].id!] = chats[i].messages ?? [];
        receivers[chats[i].id!] = chats[i]
            .channelMembers!
            .firstWhere((member) => member.userId != _prefsRepository.myChatId)
            .userId;
      }
    }

    for (int i = 0; i < pinnedChats.length; i++) {
      if (event.channelIds.contains(pinnedChats[i].id)) {
        messagesPerChannel[pinnedChats[i].id!] = pinnedChats[i].messages ?? [];
        receivers[chats[i].id!] = chats[i]
            .channelMembers!
            .firstWhere((member) => member.userId != _prefsRepository.myChatId)
            .userId;
      }
    }

    if (!ids.contains(messageId)) {
      ids.add(messageId);

      //todo insert the new message in the first of the list
      messagesPerChannel.forEach((key, value) {
        value.insert(
            0,
            Message(
              channelId: key,
              id: messageId,
              localId: messageId,
              createdAt: DateTime.now(),
              receiverUserId: receivers[key],
              messageContent: MessageContent(
                  messageId: int.tryParse(messageId),
                  content: event.productImageUrl),
              senderUserId: _prefsRepository.myChatId,
              messageType: MessageType(name: 'SharedProductMessage'),
              isForward: 0,
              authMessageStatus:
                  MessageStatus(isDeleted: 0, deleteForAll: false),
              // mediaMessageContent: event.messageType != 'TextMessage'
              //     ? [
              //   MediaMessageContent(
              //       filePath: event.mediaContent?[0]['file_path'],
              //       titleMedium: event.mediaContent?[0]['titleMedium'])
              // ]
              //     : null,
            ));
      });
    }

    //todo remove the chat  and reinsert it in the first of the List<Chat>
    for (int i = 0; i < chats.length; i++) {
      if (event.channelIds.contains(chats[i].id)) {
        chats =
            sortChats(chats, chats[i].id, messagesPerChannel[chats[i].id!]!);
      }
    }
    for (int i = 0; i < pinnedChats.length; i++) {
      if (event.channelIds.contains(pinnedChats[i].id)) {
        pinnedChats = sortChats(pinnedChats, pinnedChats[i].id,
            messagesPerChannel[pinnedChats[i].id!]!);
      }
    }
    //todo  createAnewChat  so if the condition true that's mean the message from the local
    emit(state.copyWith(
      sendMessageStatus: SendMessageStatus.loading,
      currentMessage: ids,
      //createAnewChat: int.tryParse(event.channelId) == null,
      newSortedChatsByDate:
          groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
      chats: chats,
      pinnedChats: pinnedChats,
      // channelId: event.channelId
    ));
    List<int?> receiverIds = [];
    receivers.forEach((key, value) {
      //if(int.tryParse(key) == null){
      receiverIds.add(value);
      //}
    });
    final response = await shareProductWithContactsOrChannelsUsecase(
      ShareProductWithContactsOrChannelsParams(
        channelIds: [], // event.channelIds,
        receiverIds: receiverIds,
        productId: event.productId,
        productDescription: event.productDescription,
        productImageUrl: event.productImageUrl,
        productName: event.productName,
        productSlug: event.productSlug,
        productImageWidth: event.originalImageWidth,
        productImageHeight: event.originalImageHeight
      ),
    );
    response.fold(
      (l) {
        List<String> currentFailedMessage = List.of(state.currentFailedMessage);
        ids.remove(messageId);
        currentFailedMessage.add(messageId);
        emit(state.copyWith(
            sendMessageStatus: SendMessageStatus.failure,
            currentMessage: ids,
            currentFailedMessage: currentFailedMessage));
      },
      (r) {
        ids.remove(messageId);
        pinnedChats = state.pinnedChats.map((e) {
          if (event.channelIds.contains(e.localId) &&
              int.tryParse(e.localId!) == null) {
            return r.channel!.copyWith(
                localId: e.localId,
                channelMembers: state.pinnedChats
                    .firstWhere((element) => element.id == e.localId)
                    .channelMembers,
                messages: e.messages?.map((e) {
                  if (e.localId == messageId) {
                    return r.copyWith(localId: e.localId);
                  }
                  return e;
                }).toList());
          } else if (event.channelIds.contains(e.id)) {
            List<Message> messages = List.of(e.messages ?? []);
            int index = messages.indexWhere((element) =>
                (element.id == messageId || element.localId == messageId));
            messages[index] = r.copyWith(
              localId: messageId,
            );

            return e.copyWith(messages: messages);
          }
          return e;
        }).toList();
        chats = state.chats.map((e) {
          if (event.channelIds.contains(e.localId) &&
              int.tryParse(e.localId!) == null) {
            return r.channel!.copyWith(
                localId: e.localId,
                channelMembers: state.pinnedChats
                    .firstWhere((element) => element.id == e.localId)
                    .channelMembers,
                messages: e.messages?.map((e) {
                  if (e.localId == messageId) {
                    return r.copyWith(localId: e.localId);
                  }
                  return e;
                }).toList());
          } else if (event.channelIds.contains(e.id)) {
            List<Message> messages = List.of(e.messages ?? []);
            int index = messages.indexWhere((element) =>
                (element.id == messageId || element.localId == messageId));
            messages[index] = r.copyWith(
              localId: messageId,
            );

            return e.copyWith(messages: messages);
          }
          return e;
        }).toList();
        emit(
          state.copyWith(
              chats: chats,
              createAnewChat: false,
              pinnedChats: pinnedChats,
              sendMessageStatus: SendMessageStatus.success,
              newSortedChatsByDate:
                  groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
              currentMessage: ids),
        );
      },
    );
  }

  FutureOr<void> _onSaveContactsEvent(
      SaveContactsEvent event, Emitter<ChatState> emit) async {
    if (apisMustNotToRequest.contains('SaveContactsEvent')) {
      return;
    }
    apisMustNotToRequest.add('SaveContactsEvent');
    emit(state.copyWith(saveContactsStatus: SaveContactsStatus.loading));
    List<Map<String, dynamic>> contacts =
        await HelperFunctions.getContactsFromDevice();
    final response =
        await saveContactsUseCase(SaveContactsParams(contacts: contacts));
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('SaveContactsEvent')) {
          add(SaveContactsEvent());
          isFailedTheFirstTime.add('SaveContactsEvent');
        }
        apisMustNotToRequest.remove('SaveContactsEvent');
        emit(state.copyWith(saveContactsStatus: SaveContactsStatus.failure));
      },
      (r) {
        isFailedTheFirstTime.remove('SaveContactsEvent');
        emit(
          state.copyWith(
            saveContactsStatus: SaveContactsStatus.success,
          ),
        );
        getContactsAfterSavingItAndGettingChannels();
      },
    );
  }

  FutureOr<void> _onGetChatsEvent(
      GetChatsEvent event, Emitter<ChatState> emit) async {
    if (state.getChatsStatus == GetChatsStatus.loading ||
        !enableRequestGetChats) {
      return;
    }
    emit(state.copyWith(getChatsStatus: GetChatsStatus.loading));
    final response = await getMyChatsUseCase(GetMyChatsParams(
        limit: event.limit,
        messagesLimit: event.messagesLimit,
        timeStamp: state.firstRequestForGetChats
            ? null
            : state.chats.isNotEmpty
                ? state.chats[state.chats.length - 1].updatedAt
                : state.pinnedChats.isNotEmpty
                    ? state.chats[state.chats.length - 1].updatedAt
                    : null));
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetChatsEvent')) {
          add(GetChatsEvent(limit: 10));
          isFailedTheFirstTime.add('GetChatsEvent');
        }

        emit(state.copyWith(getChatsStatus: GetChatsStatus.failure));
      },
      (r) {
        try {
          enableRequestGetChats = false;
          if (r.data!.missedFcmToken) {
            GetIt.I<AuthBloc>().add(StoreFcmTokenEvent(
                userId: _prefsRepository.myChatId!,
                serverName: ServerName.chat,
                fcmToken: NotificationProcess.myFcmToken!));
          }
          isFailedTheFirstTime.remove('GetChatsEvent');
          int unReadMessagesFromAllChats = 0;
          r.data!.chats!.forEach((element) {
            unReadMessagesFromAllChats += element.totalUnreadMessageCount!;
          });
          r.data!.pinnedChats!.forEach((element) {
            unReadMessagesFromAllChats += element.totalUnreadMessageCount!;
          });
          // List<Chat> newChats = List.of(state.chats.isEmpty
          //     ? r.data!.chats!
          //     : MergeOldMessageWithNew(
          //         newChats: r.data!.chats!, previousChats: state.chats));
          // List<Chat> newPinnedChats = List.of(state.pinnedChats.isEmpty
          //     ? r.data!.pinnedChats!
          //     : MergeOldMessageWithNew(
          //         newChats: r.data!.pinnedChats!,
          //         previousChats: state.pinnedChats));
          List<Chat> newChats = mergeChatsFromPagination(
              newChats: List.of(r.data!.chats!),
              previousChats: List.of(state.chats));
          List<Chat> newPinnedChats = mergeChatsFromPagination(
              newChats: List.of(r.data!.pinnedChats!),
              previousChats: List.of(state.pinnedChats));
          emit(
            state.copyWith(
                getChatsStatus: GetChatsStatus.success,
                firstRequestForGetChats: false,
                chatToNavigateFromTerminated:
                    event.chatToNavigateFromTerminated,
                chats: newChats,
                pinnedChats: newPinnedChats,
                newSortedChatsByDate: groupReceivedMessageOnDays(
                    chats: [...newChats, ...newPinnedChats]),
                unReadMessagesFromAllChats: unReadMessagesFromAllChats),
          );
        } catch (e, st) {
          print(e);
          print(st);
        }
        getContactsAfterSavingItAndGettingChannels();
      },
    );
  }

  FutureOr<void> _onGetContactsEvent(
      GetContactsEvent event, Emitter<ChatState> emit) async {
    if (apisMustNotToRequest.contains('GetContactsEvent')) return;
    apisMustNotToRequest.add('GetContactsEvent');
    emit(state.copyWith(
      getContactsStatus: GetContactsStatus.loading,
    ));
    final response = await getContactsUseCase(NoParams());
    response.fold(
      (l) {
        apisMustNotToRequest.remove('GetContactsEvent');

        if (!isFailedTheFirstTime.contains('GetContactsEvent')) {
          add(GetContactsEvent());
          isFailedTheFirstTime.add('GetContactsEvent');
        }
        emit(state.copyWith(getContactsStatus: GetContactsStatus.failure));
      },
      (r) {
        apisMustNotToRequest.add('GetContactsEvent');
        isFailedTheFirstTime.remove('GetContactsEvent');
        List<Chat> newChats = List.of(state.chats);
        bool changed = false;
        List<Chat> chats = List.of(state.chats);
        chats.addAll(state.pinnedChats);
//        debugPrint('long : ${r.contacts?.length}');
        for (int i = 0; i < (r.contacts?.length ?? 0); i++) {
          Contact contact = r.contacts![i];
          if (contact.contactUserId == null) {
            break;
          }
          int index = chats.indexWhere((element) =>
              element.channelMembers
                  ?.firstWhere(
                      (element) => element.userId == contact.contactUserId,
                      orElse: () => ChannelMember(userId: -1))
                  .userId !=
              -1);
          debugPrint('index : $index');
          if (index == -1) {
            debugPrint('new chat');
            changed = true;
            String uuid = const Uuid().v4();
            newChats.insert(
                0,
                Chat(
                    id: uuid,
                    localId: uuid,
                    messages: [],
                    paginationStatus: PaginationStatus.initial,
                    channelName: contact.name,
                    channelMembers: [
                      ChannelMember(
                          userId: contact.contactUserId,
                          user: User(
                              id: contact.contactUserId, name: contact.name)),
                      ChannelMember(
                          userId: _prefsRepository.myChatId,
                          user: User(
                              id: _prefsRepository.myChatId,
                              name: _prefsRepository.myChatName)),
                    ]));
          }
        }
        emit(
          state.copyWith(
              chats: changed ? newChats : state.chats,
              newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
                ...(changed ? newChats : state.chats),
                ...state.pinnedChats
              ]),
              getContactsStatus: GetContactsStatus.success,
              contacts: r.contacts),
        );
      },
    );
  }

  FutureOr<void> _onUploadFileEvent(
      UploadFileEvent event, Emitter<ChatState> emit) async {
    List<String> ids = List.of(state.currentMessage);
    ids.add(event.messageId);
    List<Message> messages;
    String? parentMessageId;
    bool fromPinned = false;
    if (state.chats.any(
      (e) => e.id == event.channelId,
    )) {
      messages = List.of(state.chats
              .firstWhere((element) => element.id == event.channelId)
              .messages ??
          []);
    } else {
      fromPinned = true;
      messages = List.of(state.pinnedChats
              .firstWhere((element) => element.id == event.channelId)
              .messages ??
          []);
    }
    int index = messages.indexWhere((element) =>
        element.localId == event.parentMessageId &&
        event.parentMessageId != null);
//    debugPrint('index $index');
    parentMessageId = event.parentMessageId;
    if (index != -1) {
      debugPrint(messages[index].id);
      parentMessageId = messages[index].id;
    }
    messages.insert(
        0,
        Message(
            channelId: event.channelId,
            id: event.messageId,
            localId: event.messageId,
            file: event.file,
            createdAt: DateTime.now(),
            receiverUserId: event.receiverUserId,
            senderUserId: _prefsRepository.myChatId,
            messageType: MessageType(name: event.messageType),
            isForward: (event.isForward ?? false) ? 1 : 0,
            parentMessageId: parentMessageId,
            authMessageStatus: MessageStatus(isDeleted: 0, deleteForAll: false),
            parentMessage: parentMessageId != null
                ? Message(
                    file: event.file,
                    senderUserId: index != -1
                        ? messages[index].senderUserId
                        : event.senderParentMessageId,
                    messageContent:
                        MessageContent(content: event.parentMessageContent))
                : null));

    List<Chat> chats;
    if (fromPinned) {
      chats = sortChats(state.pinnedChats, event.channelId, messages);
    } else {
      chats = sortChats(state.chats, event.channelId, messages);
    }

    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
        newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
          ...chats,
          ...(fromPinned ? state.chats : state.pinnedChats)
        ]),
        chats: fromPinned ? state.chats : chats,
        pinnedChats: !fromPinned ? state.pinnedChats : chats,
        channelId: event.channelId));
    final response;
    if (event.useCloudinaryToUpload) {
      response = await uploadFileCloudinaryUseCase(UploadFileCloudinaryParams(
          file: event.file,
          usingSendProgressFunction: false,
          usingOnUploadingFinishedFunction: false));
    } else {
      response =
          await uploadFileUseCase(UploadFileParams(event.file, event.filePath));
    }
    response.fold((l) {
      List<String> currentFailedMessage = List.of(state.currentFailedMessage);
      List<String> currentFailedMediaMessage =
          List.of(state.currentFailedMediaMessage);
      ids.remove(event.messageId);
      currentFailedMessage.add(event.messageId);
      currentFailedMediaMessage.add(event.messageId);
      emit(state.copyWith(
          sendMessageStatus: SendMessageStatus.failure,
          currentFailedMessage: currentFailedMessage,
          currentFailedMediaMessage: currentFailedMediaMessage));
    }, (r) {
      add(SendMessageEvent(
          messageId: event.messageId,
          extraFields: event.extraFields,
          isForward: event.isForward,
          channelId: event.channelId,
          senderParentMessageId: event.senderParentMessageId,
          file: event.file,
          imageWidth : event.useCloudinaryToUpload ? r.width?.toDouble() : null ,
          imageHeight : event.useCloudinaryToUpload ? r.height?.toDouble() : null ,
          parentMessageContent: event.parentMessageContent,
          mediaContent: [
            {
              'file_path': event.useCloudinaryToUpload
                  ? r.secureUrl!
                  : r.data!.filePath!,
              'file_name': event.fileName,
              'titleMedium': 'test image'
            }
          ],
          messageType: event.messageType,
          parentMessageId: event.parentMessageId,
          receiverUserId: event.receiverUserId));
    });
  }

  FutureOr<void> _onReceiveMessageEvent(
      ReceiveMessageEvent event, Emitter<ChatState> emit) async {
    print('_onReceiveMessageEvent_onReceiveMessageEvent');

    emit(state.copyWith(receiveMessageStatus: ReceiveMessageStatus.loading));
    List<Message> messages = [];
    bool fromPinned = false;
    List<Chat> chats;
    if (state.chats.any(
      (e) => e.id == event.message.channelId,
    )) {
      chats = List.of(state.chats);
    } else {
      fromPinned = true;
      chats = List.of(state.pinnedChats);
    }
    Chat chat = chats.firstWhere(
        (element) => element.id == event.message.channelId,
        orElse: () => Chat(id: '-1'));
    if (chat.messages?.any((element) => element.id == event.message.id) ??
        false) {
      return;
    }
    chats.removeWhere((element) => element.id == chat.id);
    chats.insert(
        0,
        chat.copyWith(
            totalUnreadMessageCount: event.increaseUnReadMessages
                ? ((chat.totalUnreadMessageCount ?? 0) +
                    (event.message.senderUserId! != _prefsRepository.myChatId
                        ? 1
                        : 0))
                : chat.totalUnreadMessageCount));
    messages = List.of(chat.messages ?? []);
    messages.insert(0, event.message);
    int index =
        messages.indexWhere((element) => element.id == event.prevMessageId);
    chats[0] = chats[0].copyWith(messages: messages);
    emit(state.copyWith(
      receiveMessageStatus: ReceiveMessageStatus.success,
      unReadMessagesFromAllChats: event.increaseUnReadMessages
          ? (state.unReadMessagesFromAllChats +
              ((event.message.senderUserId! != _prefsRepository.myChatId)
                  ? 1
                  : 0))
          : state.unReadMessagesFromAllChats,
      newSortedChatsByDate: groupReceivedMessageOnDays(
          chats: [...chats, ...(fromPinned ? state.chats : state.pinnedChats)]),
      currentChannelReceivedMessage: chat.localId ?? chat.id,
      channelId: event.message.channelId,
      chats: fromPinned ? state.chats : chats,
      pinnedChats: !fromPinned ? state.pinnedChats : chats,
    ));
    // add(IncreaseFileImageVideoCounterEvent(event.message.messageType!.name!));

    if (index == -1 && event.prevMessageId != null) {
      add(GetAllMessagesBetweenEvent(
          firstMessageId: event.prevMessageId!,
          secondMessageId: event.message.id.toString(),
          scrollToParentMessage: false,
          channelId: event.message.channelId.toString()));
    }
  }

  FutureOr<void> _onReceiveMissCallEvent(
      ReceiveMissCallEvent event, Emitter<ChatState> emit) async {
    bool fromPinned = false;
    List<Chat> chats;
    if (state.chats.any(
      (e) => e.id == event.channelId,
    )) {
      chats = List.of(state.chats);
    } else {
      fromPinned = true;
      chats = List.of(state.pinnedChats);
    }
    Chat chat = chats.firstWhere((element) => element.id == event.channelId,
        orElse: () => Chat(id: '-1'));

    chats.removeWhere((element) => element.id == chat.id);
    chats.insert(
        0,
        chat.copyWith(
            totalUnreadMessageCount: event.increaseUnReadMessages
                ? ((chat.totalUnreadMessageCount ?? 0) + 1)
                : chat.totalUnreadMessageCount));

    emit(state.copyWith(
      unReadMessagesFromAllChats: event.increaseUnReadMessages
          ? (state.unReadMessagesFromAllChats + 1)
          : state.unReadMessagesFromAllChats,
      newSortedChatsByDate: groupReceivedMessageOnDays(
          chats: [...chats, ...(fromPinned ? state.chats : state.pinnedChats)]),
      currentChannelReceivedMessage: chat.localId ?? chat.id,
      channelId: event.channelId,
      chats: fromPinned ? state.chats : chats,
      pinnedChats: !fromPinned ? state.pinnedChats : chats,
    ));
  }

  FutureOr<void> _onReadAllMessagesEvent(
      ReadAllMessagesEvent event, Emitter<ChatState> emit) async {
    String id = [...state.chats, ...state.pinnedChats]
        .firstWhere((element) =>
            element.localId == event.channelId || element.id == event.channelId)
        .id
        .toString();
    if (int.tryParse(id) == null) return;
    emit(state.copyWith(readMessagesStatus: ResetReadMessagesStatus.loading));
    final response =
        await readAllMessagesUseCase(ReadAllMessagesParams(channelId: id));
    response.fold((l) {
      showMessage('This Channel was deleted', showInRelease: true);
      if (!isFailedTheFirstTime.contains('ReadAllMessagesEvent')) {
        add(ReadAllMessagesEvent(event.channelId));
        isFailedTheFirstTime.add('ReadAllMessagesEvent');
      }
      emit(state.copyWith(readMessagesStatus: ResetReadMessagesStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('ReadAllMessagesEvent');
      emit(state.copyWith(
          readMessagesStatus: ResetReadMessagesStatus.success,
          unReadMessagesFromAllChats: state.unReadMessagesFromAllChats -
              (state.chats
                      .firstWhere((element) => element.id == id,
                          orElse: () => state.pinnedChats
                              .firstWhere((element) => element.id == id))
                      .totalUnreadMessageCount ??
                  0),
          chats: state.chats.map((e) {
            if (e.id == id) {
              return e.copyWith(totalUnreadMessageCount: 0);
            }
            return e;
          }).toList(),
          pinnedChats: state.pinnedChats.map((e) {
            if (e.id == id) {
              return e.copyWith(totalUnreadMessageCount: 0);
            }
            return e;
          }).toList()));
    });
  }

  FutureOr<void> _onNotifyThatIReceivedMessageEvent(
      NotifyThatIReceivedMessageEvent event, Emitter<ChatState> emit) async {
    final response = await receiveMessageUseCase(
        ReceiveMessageParams(channelId: event.channelId));
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('NotifyThatIReceivedMessageEvent')) {
        add(NotifyThatIReceivedMessageEvent(channelId: event.channelId));
        isFailedTheFirstTime.add('NotifyThatIReceivedMessageEvent');
      }
      emit(state.copyWith(
          notifyThatIReceivedMessageStatus:
              NotifyThatIReceivedMessageStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('NotifyThatIReceivedMessageEvent');
      emit(state.copyWith(
          notifyThatIReceivedMessageStatus:
              NotifyThatIReceivedMessageStatus.success));
    });
  }

  FutureOr<void> _onDeleteChatEvent(
      DeleteChatEvent event, Emitter<ChatState> emit) async {
    bool fromPinned = false;
    List<Chat> chats;
    if (state.chats.any((element) => element.id == event.channelId)) {
      chats = List.of(state.chats);
    } else {
      fromPinned = true;
      chats = List.of(state.pinnedChats);
    }
    String uuid = const Uuid().v4();
    int index = chats.indexWhere((element) => element.id == event.channelId);
    Chat removedChat = chats[index];
    chats[index] = chats[index].copyWith(id: uuid, localId: uuid, messages: []);
    emit(state.copyWith(
        chats: fromPinned ? state.chats : chats,
        deleteChatStatus: DeleteChatStatus.loading,
        newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
          ...chats,
          ...(fromPinned ? state.chats : state.pinnedChats)
        ]),
        pinnedChats: !fromPinned ? state.pinnedChats : chats));
    final response = await deleteChatUseCase(
        DeleteChatParams(channelId: removedChat.id.toString()));
    response.fold((l) {
      int index = chats.indexWhere((element) => element.id == uuid);
      chats.insert(index, removedChat);
      emit(state.copyWith(
          chats: fromPinned ? state.chats : chats,
          deleteChatStatus: DeleteChatStatus.failure,
          newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
            ...chats,
            ...(fromPinned ? state.chats : state.pinnedChats)
          ]),
          pinnedChats: !fromPinned ? state.pinnedChats : chats));
    }, (r) {
      _prefsRepository.removeAllFilePathExistInChat(event.channelId);
      emit((state.copyWith(
          deleteChatStatus: DeleteChatStatus.success,
          chats: fromPinned ? state.chats : chats,
          newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
            ...chats,
            ...(fromPinned ? state.chats : state.pinnedChats)
          ]),
          pinnedChats: !fromPinned ? state.pinnedChats : chats)));
    });
  }

  FutureOr<void> _onChangeChatPropertyEvent(
      ChangeChatPropertyEvent event, Emitter<ChatState> emit) async {
    List<Chat> chats = List.of(state.chats);
    List<Chat> pinnedChats = List.of(state.pinnedChats);
    Chat changedChat;
    List<ChannelMember> members;
    if (event.pin != null) {
      if (event.pin == 0) {
        changedChat =
            pinnedChats.firstWhere((element) => element.id == event.channelId);
        pinnedChats.removeWhere((e) => e.id == changedChat.id);
        members = changedChat.channelMembers!;
        members = members.map((e) {
          if (e.userId == _prefsRepository.myChatId) {
            return e.copyWith(pin: 0);
          }
          return e;
        }).toList();
        chats.add(changedChat.copyWith(channelMembers: members));
        chats = sortChatsByTime(chats);
      } else {
        changedChat =
            chats.firstWhere((element) => element.id == event.channelId);
        members = changedChat.channelMembers!;
        members = members.map((e) {
          if (e.userId == _prefsRepository.myChatId) {
            return e.copyWith(pin: 1);
          }
          return e;
        }).toList();
        chats.removeWhere((e) => e.id == changedChat.id);
        pinnedChats.insert(0, changedChat.copyWith(channelMembers: members));
        pinnedChats = sortChatsByTime(pinnedChats);
      }
    } else {
      changedChat = chats.firstWhere((element) => element.id == event.channelId,
          orElse: () => pinnedChats
              .firstWhere((element) => element.id == event.channelId));
      members = changedChat.channelMembers!;
      members = members.map((e) {
        if (e.userId == _prefsRepository.myChatId) {
          return e.copyWith(
            mute: event.mute ?? e.mute,
            archived: event.archive ?? e.archived,
          );
        }
        return e;
      }).toList();
      if (chats.any(
        (e) => e.id == changedChat.id,
      )) {
        chats.removeWhere((e) => e.id == changedChat.id);
        chats.insert(0, changedChat.copyWith(channelMembers: members));
      } else {
        pinnedChats.removeWhere((e) => e.id == changedChat.id);
        pinnedChats.insert(0, changedChat.copyWith(channelMembers: members));
      }
    }
    emit(state.copyWith(
        chats: chats,
        pinnedChats: pinnedChats,
        changeChatPropertyStatus: ChangeChatPropertyStatus.loading));
    final response = await changeChatPropertyUseCase(ChangeChatPropertyParams(
        channelId: event.channelId,
        mute: event.mute,
        pin: event.pin,
        archive: event.archive));
    response.fold((l) {
      chats = state.chats;
      pinnedChats = state.pinnedChats;
      if (event.pin != null) {
        members = changedChat.channelMembers!;
        members = members.map((e) {
          if (e.userId == _prefsRepository.myChatId) {
            return e.copyWith(pin: 1 - event.pin!);
          }
          return e;
        }).toList();
        if (event.pin == 1) {
          pinnedChats.removeWhere((e) => e.id == changedChat.id);
          chats.add(changedChat.copyWith(channelMembers: members));
          chats = sortChatsByTime(chats);
        } else {
          chats.removeWhere((e) => e.id == changedChat.id);
          pinnedChats.add(changedChat.copyWith(channelMembers: members));
          pinnedChats = sortChatsByTime(pinnedChats);
        }
      } else {
        members = changedChat.channelMembers!;
        members = members.map((e) {
          if (e.userId == _prefsRepository.myChatId) {
            return e.copyWith(
              mute: 1 - e.mute!,
              archived: 1 - e.archived!,
            );
          }
          return e;
        }).toList();
        int index;
        if (chats.any(
          (e) => e.id == changedChat.id,
        )) {
          index = chats.indexOf(changedChat);
          chats[index] = changedChat.copyWith(channelMembers: members);
        } else {
          index = pinnedChats.indexOf(changedChat);
          pinnedChats[index] = changedChat.copyWith(channelMembers: members);
        }
      }
      emit(state.copyWith(
          chats: chats,
          pinnedChats: pinnedChats,
          changeChatPropertyStatus: ChangeChatPropertyStatus.failure));
    }, (r) {
      emit(state.copyWith(
          changeChatPropertyStatus: ChangeChatPropertyStatus.success));
    });
  }

  List<Chat> sortChats(
      List<Chat> unSortedChats, String? channelId, List<Message> messages) {
    List<Chat> chats = List.of(unSortedChats);
    Chat chat = chats.firstWhere((element) => element.id == channelId);
    chats.removeWhere((e) => e.id == chat.id);
    chat = chat.copyWith(messages: messages);
    chats.insert(0, chat);
    return chats;
  }

  List<Chat> sortChatsByTime(List<Chat> unSortedChats) {
    if (unSortedChats.length == 1) {
      return unSortedChats;
    }
    unSortedChats.sort((a, b) {
      if ((a.messages?.isEmpty ?? true) && (b.messages?.isEmpty ?? true)) {
        return 0;
      }
      if (a.messages?.isEmpty ?? true) {
        return 1; // a < b
      }
      if (b.messages?.isEmpty ?? true) {
        return -1;
      }
      return b.messages!.first.createdAt!
          .compareTo(a.messages!.first.createdAt!);
    });
    return unSortedChats.reversed.toList();
  }

  FutureOr<void> _onReceiveMessageFromPusherEvent(
      ReceiveMessageFromPusherEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
        changeMessageStateFromPusherStatus:
            ChangeMessageStateFromPusherStatus.init));
    List<Chat> chats = getChatsAfterEditPropertyOfMessage(
        state.chats,
        1,
        null,
        event.channelId,
        event.lastMessageId,
        event.userId,
        event.receivedAt,
        null);
    List<Chat> pinnedChats = getChatsAfterEditPropertyOfMessage(
        state.pinnedChats,
        1,
        null,
        event.channelId,
        event.lastMessageId,
        event.userId,
        event.receivedAt,
        null);
    emit(state.copyWith(
      chats: chats,
      newSortedChatsByDate:
          groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
      changeMessageStateFromPusherStatus:
          ChangeMessageStateFromPusherStatus.received,
      pinnedChats: pinnedChats,
    ));
  }

  FutureOr<void> _onWatchedMessageFromPusherEvent(
      WatchedMessageFromPusherEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
        changeMessageStateFromPusherStatus:
            ChangeMessageStateFromPusherStatus.init));
    List<Chat> chats = getChatsAfterEditPropertyOfMessage(
        state.chats,
        null,
        true,
        event.channelId,
        event.lastMessageId,
        event.userId,
        null,
        event.watchedAt);
    List<Chat> pinnedChats = getChatsAfterEditPropertyOfMessage(
        state.pinnedChats,
        null,
        true,
        event.channelId,
        event.lastMessageId,
        event.userId,
        null,
        event.watchedAt);
    emit(state.copyWith(
      unReadMessagesFromAllChats: state.unReadMessagesFromAllChats - 1,
      chats: chats,
      newSortedChatsByDate:
          groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
      changeMessageStateFromPusherStatus:
          ChangeMessageStateFromPusherStatus.watched,
      pinnedChats: pinnedChats,
    ));
  }

  List<Chat> getChatsAfterEditPropertyOfMessage(
      List<Chat> chats,
      int? received,
      bool? watched,
      String channelId,
      int lastMessageId,
      int userId,
      DateTime? receivedAt,
      DateTime? watchedAt) {
    return chats
                .firstWhere((element) => element.id == channelId,
                    orElse: () => Chat(id: "-1"))
                .id !=
            "-1"
        ? chats.map((e) {
            if (e.id == channelId) {
              return e.copyWith(
                  totalUnreadMessageCount: watched != null
                      ? e.totalUnreadMessageCount! - 1
                      : e.totalUnreadMessageCount,
                  messages: e.messages?.map((m) {
                    return m.copyWith(
                        messageStatus: m.messageStatus?.map((s) {
                      return s.copyWith(
                        isWatched: watched ?? s.isWatched,
                        receivedAt: receivedAt,
                        isReceived: received,
                        watchedAt: watchedAt,
                      );
                    }).toList());
                  }).toList());
            }
            return e;
          }).toList()
        : chats;
  }

  _onGetMessagesForChatEvent(
      GetMessagesForChatEvent event, Emitter<ChatState> emit) async {
    bool fromPinned = false;
    Chat chat;
//todo check if the  chat is pinned Chat or not
    chat = state.chats.firstWhere(
        (element) => element.id.toString() == event.channelId,
        orElse: () => Chat(id: "-1"));
    if (chat.id == "-1") {
      fromPinned = true;
      chat = state.pinnedChats
          .firstWhere((element) => element.id == event.channelId);
    }

    String lastMessageId = chat.messages!.last.id!;
    if (chat.hasReachedMax || chat.isLoading) {
      return;
    }
    chat = chat.copyWith(paginationStatus: PaginationStatus.loading);
    emit(state.copyWith(
      chats: fromPinned
          ? state.chats
          : state.chats.map((e) {
              if (e.id == event.channelId) {
                return chat;
              }
              return e;
            }).toList(),
      pinnedChats: !fromPinned
          ? state.pinnedChats
          : state.pinnedChats.map((e) {
              if (e.id == event.channelId) {
                return chat;
              }
              return e;
            }).toList(),
    ));
    final response = await getMessagesForChatUseCase(GetMessagesForChatParams(
        lastMessageId: int.parse(lastMessageId),
        limit: event.limit,
        channelId: event.channelId));

    response.fold((l) {
      chat = chat.copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
        chats: fromPinned
            ? state.chats
            : state.chats.map((e) {
                if (e.id == event.channelId) {
                  return chat;
                }
                return e;
              }).toList(),
        pinnedChats: !fromPinned
            ? state.pinnedChats
            : state.pinnedChats.map((e) {
                if (e.id == event.channelId) {
                  return chat;
                }
                return e;
              }).toList(),
      ));
    }, (r) {
      List<Message> messages = List.of(chat.messages ?? []);
      messages.addAll(r);
      debugPrint('////chat messages length//// ${messages.length} //////////');
      chat = chat.copyWith(
          messages: messages,
          hasReachedMax: r.length < event.limit,
          paginationStatus: PaginationStatus.success);

      List<Chat> pinnedChat = state.pinnedChats.map((e) {
        if (e.id == event.channelId) {
          return chat;
        }
        return e;
      }).toList();
      List<Chat> chats = state.chats.map((e) {
        if (e.id == event.channelId) {
          return chat;
        }
        return e;
      }).toList();
      emit(state.copyWith(
          chats: chats,
          newSortedChatsByDate:
              groupReceivedMessageOnDays(chats: [...chats, ...pinnedChat]),
          pinnedChats: pinnedChat));
    });
  }

  FutureOr<void> _onGetAllMessagesBetweenEvent(
      GetAllMessagesBetweenEvent event, Emitter<ChatState> emit) async {
    debugPrint('ssssssssss ${state.getMessagesBetweenStatus}');
    if (state.getMessagesBetweenStatus == GetMessagesBetweenStatus.loading) {
      return;
    }
    emit(state.copyWith(
      getMessagesBetweenStatus: GetMessagesBetweenStatus.loading,
    ));
    bool fromPinned = false;
    Chat chat;
    chat = state.chats.firstWhere(
        (element) => element.id.toString() == event.channelId,
        orElse: () => Chat(id: "-1"));
    if (chat.id == "-1") {
      fromPinned = true;
      chat = state.pinnedChats
          .firstWhere((element) => element.id == event.channelId);
    }
    final response = await getMessagesBetweenUseCase(GetMessagesBetweenParams(
        firstMessageId: event.firstMessageId,
        secondMessageId: event.secondMessageId,
        channelId: event.channelId));

    response.fold((l) {
      emit(state.copyWith(
        getMessagesBetweenStatus: GetMessagesBetweenStatus.failure,
      ));
    }, (r) {
      List<Message> messages = List.of(chat.messages ?? []);
      int index =
          messages.indexWhere((element) => element.id == event.secondMessageId);
      for (int i = 0; i < r.length; i++) {
        if (index < messages.length && r[i].id == messages[index].id) {
          index++;
          continue;
        }
        messages.insert(index, r[i]);
        index++;
      }
      chat = chat.copyWith(
        messages: messages,
      );
      List<Chat> chats = fromPinned
          ? state.chats
          : state.chats.map((e) {
              if (e.id == event.channelId) {
                return chat;
              }
              return e;
            }).toList();
      List<Chat> pinnedChats = !fromPinned
          ? state.pinnedChats
          : state.pinnedChats.map((e) {
              if (e.id == event.channelId) {
                return chat;
              }
              return e;
            }).toList();
      emit(state.copyWith(
          chats: chats,
          getMessagesBetweenStatus: GetMessagesBetweenStatus.success,
          firstMessageId: event.firstMessageId,
          newSortedChatsByDate:
              groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
          secondMessageId: event.secondMessageId,
          scrollToParentMessage: event.scrollToParentMessage,
          pinnedChats: pinnedChats));
    });
  }

  getContactsAfterSavingItAndGettingChannels() {
    if (state.getChatsStatus == GetChatsStatus.success &&
        state.saveContactsStatus == SaveContactsStatus.success) {
      add(GetContactsEvent());
    }
  }

  @override
  ChatState? fromJson(Map<String, dynamic> json) {
    return ChatState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ChatState state) {
    List<String> failedMessages = List.of(state.currentFailedMessage);
    List<String> failedMediaMessages = List.of(state.currentFailedMediaMessage);
    state.chats.forEach((chat) {
      chat.messages?.forEach((message) {
        if (int.tryParse(message.id.toString()) == null) {
          if (message.mediaMessageContent.isNullOrEmpty) {
            failedMessages.add(message.id.toString());
          } else {
            failedMediaMessages.add(message.id.toString());
          }
        }
      });
    });
    // List<Chat> chats = List.of(state.chats);
    // chats.removeWhere((element) => int.tryParse(element.id.toString()) == null);
    // List<Chat> pinnedChats = List.of(state.pinnedChats);
    // pinnedChats
    //     .removeWhere((element) => int.tryParse(element.id.toString()) == null);
    return state
        .copyWith(
            currentFailedMessage: failedMessages,
            currentFailedMediaMessage: failedMediaMessages,
            // chats: chats,
            // pinnedChats: pinnedChats,
            receiveMessageStatus: ReceiveMessageStatus.init,
            readMessagesStatus: ResetReadMessagesStatus.init,
            firstRequestForGetChats: true,
            changeChatPropertyStatus: ChangeChatPropertyStatus.init,
            changeMessageStateFromPusherStatus:
                ChangeMessageStateFromPusherStatus.init,
            deleteChatStatus: DeleteChatStatus.init,
            getChatsStatus: GetChatsStatus.init,
            getContactsStatus: GetContactsStatus.init,
            getMediaCountStatus: GetMediaCountStatus.init,
            getMessagesBetweenStatus: GetMessagesBetweenStatus.init,
            notifyThatIReceivedMessageStatus:
                NotifyThatIReceivedMessageStatus.init,
            saveContactsStatus: SaveContactsStatus.init,
            sendMessageStatus: SendMessageStatus.init)
        .toJson();
  }

  FutureOr<void> _onAddAMessageToAChannel(
      AddAMessageToAChannel event, Emitter<ChatState> emit) {
    bool fromPinned = false;
    List<Chat> chats;
    int index = state.chats
        .indexWhere((element) => element.id.toString() == event.localChannelId);
    if (index != -1) {
      chats = List.of(state.chats);
    } else {
      fromPinned = true;
      chats = List.of(state.pinnedChats);
      index = state.pinnedChats.indexWhere(
          (element) => element.id.toString() == event.localChannelId);
    }
    chats[index] = event.message.channel!.copyWith(
        totalUnreadMessageCount: 0,
        localId: event.localChannelId,
        messages: [event.message]);
    emit(state.copyWith(
      chats: fromPinned ? state.chats : chats,
      createAnewChat: true,
      newSortedChatsByDate: groupReceivedMessageOnDays(
          chats: [...chats, ...(fromPinned ? state.chats : state.pinnedChats)]),
      pinnedChats: !fromPinned ? state.pinnedChats : chats,
    ));
  }

  _onAddChannelToChannels(AddChannelToChannels event, Emitter<ChatState> emit) {
    Chat chat = event.message.channel!;
    if (state.chats.isNotEmpty || state.pinnedChats.isNotEmpty) {
      if (state.chats
              .firstWhere((element) => element.id == chat.id,
                  orElse: () => state.pinnedChats.firstWhere(
                      (element) => element.id == chat.id,
                      orElse: () => Chat(id: '-1')))
              .id !=
          '-1') {
        return;
      }
      int index;
      if ((index = state.chats.indexWhere((element) =>
              element.channelMembers!
                  .firstWhere(
                      (element) => element.userId != _prefsRepository.myChatId)
                  .userId ==
              chat.channelMembers!
                  .firstWhere(
                      (element) => element.userId != _prefsRepository.myChatId)
                  .userId)) !=
          -1) {
        String localChannelId = state.chats[index].id.toString();
        emit(state.copyWith(
            chats: state.chats.map((e) {
          if (index == 0) {
            index--;
            return chat.copyWith(localId: localChannelId);
          }
          index--;
          return e;
        }).toList()));
        return;
      }
      if ((index = state.pinnedChats.indexWhere((element) =>
              element.channelMembers!
                  .firstWhere(
                      (element) => element.userId != _prefsRepository.myChatId)
                  .userId ==
              chat.channelMembers!
                  .firstWhere(
                      (element) => element.userId != _prefsRepository.myChatId)
                  .userId)) !=
          -1) {
        String localChannelId = state.chats[index].id.toString();
        emit(state.copyWith(
            pinnedChats: state.pinnedChats.map((e) {
          if (index == 0) {
            index--;
            return chat.copyWith(localId: localChannelId);
          }
          index--;
          return e;
        }).toList()));
        return;
      }
    }
    bool isPinned = chat.channelMembers!
            .firstWhere(
                (element) => element.userId == _prefsRepository.myChatId)
            .pin ==
        1;
    emit(state.copyWith(
      chats: isPinned ? state.chats : [chat, ...state.chats],
      pinnedChats: !isPinned ? state.pinnedChats : [chat, ...state.pinnedChats],
    ));
  }

  FutureOr<void> _onChangeGlobalUsedVariablesInBloc(
      ChangeGlobalUsedVariablesInBloc event, Emitter<ChatState> emit) {
    currentOpenedChatId = event.currentOpenedChatId;
  }

  _onIncreaseFileImageVideoCounterEvent(
      IncreaseFileImageVideoCounterEvent event, Emitter<ChatState> emit) {
    if (event.messageType.contains("ImageMessage")) {
      int counter = state.imageCountInEachChat + 1;
      emit(state.copyWith(imageCountInEachChat: counter));
    } else if (event.messageType.contains("FileMessage")) {
      int counter = state.fileCountInEachChat + 1;

      emit(state.copyWith(fileCountInEachChat: counter));
    } else if (event.messageType.contains("VideoMessage")) {
      int counter = state.videoCountInEachChat + 1;
      emit(state.copyWith(videoCountInEachChat: counter));
    }
  }

  _onGetSharedProductCountEvent(
      GetSharedProductCountEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
        getSharedProductCountStatus: GetSharedProductCountStatus.loading));
    final response = await getSharedProductCountUseCase(
        GetSharedProductCountParams(productId: event.productId));
    response.fold((l) {
      emit(state.copyWith(
          getSharedProductCountStatus: GetSharedProductCountStatus.failure));
    }, (r) {
      Map<String, String> getSharedProductCount =
          Map.of(state.getSharedProductCount ?? {});
      if (getSharedProductCount.containsKey(event.productId)) {
        getSharedProductCount[event.productId] =
            (r.data?.sharedCount ?? "").toString();
      } else {
        getSharedProductCount
            .addAll({event.productId: (r.data?.sharedCount ?? "").toString()});
      }
      emit(state.copyWith(
          getSharedProductCountStatus: GetSharedProductCountStatus.success,
          getSharedProductCount: getSharedProductCount));
    });
  }

  _onGetMediaCountEvent(
      GetMediaCountEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(getMediaCountStatus: GetMediaCountStatus.loading));
    final response = await getMediaCountUseCase(
        GetMediaCountParams(channelId: event.channelId));
    response.fold(
        (l) => emit(
            state.copyWith(getMediaCountStatus: GetMediaCountStatus.failure)),
        (r) => emit(state.copyWith(
            getMediaCountStatus: GetMediaCountStatus.success,
            fileCountInEachChat: r.data?.fileMessagesCount ?? 0,
            imageCountInEachChat: r.data?.imageMessagesCount ?? 0,
            videoCountInEachChat: r.data?.videoMessagesCount ?? 0)));
  }

  _onChangeSlop(ChangeSlop event, Emitter<ChatState> emit) {
    emit(state.copyWith(slopMessageId: event.messageId));
    state.isSlpoing
        ? emit(state.copyWith(isSlpoing: false))
        : emit(state.copyWith(isSlpoing: true));
  }

  _onResendMessageEvent(ResendMessageEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(resendMessageStatus: ResendMessageStatus.init));
    List<Message> messages;
    Message message;
    bool fromPinned = false;
    bool faildToUploadeToClodinary = false;
    Chat chat;
    if (state.chats.any(
      (e) => e.id == event.channelId,
    )) {
      chat = state.chats.firstWhere((element) => element.id == event.channelId);
      messages = chat.messages ?? [];
    } else {
      fromPinned = true;
      chat = state.pinnedChats
          .firstWhere((element) => element.id == event.channelId);
      messages = chat.messages ?? [];
    }
    emit(state.copyWith(resendMessageStatus: ResendMessageStatus.loading));
    List<String> failedMessagesId = List.of(state.currentFailedMessage);
    List<String> failedMediaMessagesId =
        List.of(state.currentFailedMediaMessage);
    failedMessagesId.remove(event.messageId);
    faildToUploadeToClodinary = failedMediaMessagesId.contains(event.messageId);
    if (faildToUploadeToClodinary) {
      failedMediaMessagesId.remove(event.messageId);
    }
    message = messages.firstWhere((element) => element.id == event.messageId);

    messages.removeWhere((element) => element.id == event.messageId);
    chat = chat.copyWith(messages: messages);
    List<Chat> chats = fromPinned
        ? state.chats
        : state.chats.map((e) {
            if (e.id == chat.id) return chat;
            return e;
          }).toList();
    List<Chat> pinnedChats = !fromPinned
        ? state.pinnedChats
        : state.pinnedChats.map((e) {
            if (e.id == chat.id) return chat;
            return e;
          }).toList();
    emit(state.copyWith(
      currentFailedMediaMessage: failedMediaMessagesId,
      currentFailedMessage: failedMessagesId,
      channelId: event.channelId,
      newSortedChatsByDate:
          groupReceivedMessageOnDays(chats: [...pinnedChats, ...chats]),
      chats: chats,
      pinnedChats: pinnedChats,
    ));
    String id = const Uuid().v4();

    if (faildToUploadeToClodinary) {
      String mimeStr = lookupMimeType(message.file!.absolute.path) ?? '';
      bool isMediaFile = mimeStr.split('/')[0] != 'application';

      add(UploadFileEvent(
          messageType: message.messageType!.name,
          isForward: message.isForward == 1,
          receiverUserId: message.receiverUserId,
          file: message.file!,
          filePath: event.messageType == 'image'
              ? 'images/test'
              : event.messageType == 'file'
                  ? 'files/test'
                  : event.messageType == 'video'
                      ? 'videos/test'
                      : 'voices/test',
          fileName: message.file!.path,
          messageId: id,
          parentMessageContent: message.parentMessageId != null
              ? message.parentMessage!.messageContent!.content
              : null,
          parentMessageId:
              message.parentMessageId != null ? message.parentMessageId : null,
          senderParentMessageId: message.parentMessageId != null
              ? message.parentMessage!.senderUserId
              : null,
          channelId: event.channelId,
          useCloudinaryToUpload: isMediaFile));
      emit(state.copyWith(resendMessageStatus: ResendMessageStatus.success));
    } else {
      add(SendMessageEvent(
          parentMessageContent: message.parentMessageId != null
              ? message.parentMessage!.messageContent!.content
              : null,
          parentMessageId:
              message.parentMessageId != null ? message.parentMessageId : null,
          senderParentMessageId: message.parentMessageId != null
              ? message.parentMessage!.senderUserId
              : null,
          messageId: id,
          content: message.messageContent!.content!,
          createNewChat: false,
          isForward: message.isForward == 1,
          messageType: message.messageType!.name,
          receiverUserId: message.receiverUserId,
          channelId: event.channelId));
    }
  }

  _onDeleteMessageNotificationReceivedInChatsEvent(
      DeleteMessageNotificationReceivedInChatsEvent event,
      Emitter<ChatState> emit) {
    bool fromPinned = false;

    Chat chat;

    if (state.chats.any((element) => element.id == event.channelId)) {
      chat = state.chats.firstWhere((element) => element.id == event.channelId);
    } else {
      fromPinned = true;
      chat = state.pinnedChats
          .firstWhere((element) => element.id == event.channelId);
    }
    bool isAFileMessageRemoved = false;
    bool isAimageMessageRemoved = false;
    bool isAdocumentMessageRemoved = false;

    bool isAvideoMessageRemoved = false;

    int index =
        chat.messages!.indexWhere((element) => element.id == event.messageId);
    isAimageMessageRemoved =
        chat.messages![index].messageType!.name == 'ImageMessage';
    isAdocumentMessageRemoved =
        chat.messages![index].messageType!.name == 'FileMessage';

    isAvideoMessageRemoved =
        chat.messages![index].messageType!.name == 'VideoMessage';

    isAFileMessageRemoved =
        !chat.messages![index].messageType!.name!.contains('Call') &&
            chat.messages![index].messageType!.name != 'TextMessage';
    chat.messages![index] = chat.messages![index].copyWith(
        deletedByUserId: event.deletedByUserId,
        authMessageStatus: MessageStatus(
            isDeleted: state.currentFailedMessage.contains(event.messageId)
                ? 1
                : event.isDelete,
            deleteForAll: event.deleteForAll));
    if (!event.deleteForAll) {
      chat.messages?.removeAt(index);
    }
    List<Chat> chats = !fromPinned
        ? state.chats.map((e) {
            if (e.id == event.channelId) {
              return chat;
            }
            return e;
          }).toList()
        : state.chats;
    List<Chat> pinnedChats = fromPinned
        ? state.pinnedChats.map((e) {
            if (e.id == event.channelId) {
              return chat;
            }
            return e;
          }).toList()
        : state.pinnedChats;
    if (isAFileMessageRemoved) {
      _prefsRepository.removeAFilePathExist(
          chat.messages![index].mediaMessageContent![0].filePath!,
          event.channelId);
    }
    emit(state.copyWith(
      /* videoCountInEachChat: isAvideoMessageRemoved
          ? state.videoCountInEachChat - 1
          : state.videoCountInEachChat,
      imageCountInEachChat: isAimageMessageRemoved
          ? state.imageCountInEachChat - 1
          : state.imageCountInEachChat,
      fileCountInEachChat: isAdocumentMessageRemoved
          ? state.fileCountInEachChat - 1
          : state.fileCountInEachChat,*/
      chats: chats,
      newSortedChatsByDate:
          groupReceivedMessageOnDays(chats: [...pinnedChats, ...chats]),
      pinnedChats: pinnedChats,
    ));
  }

  FutureOr<void> _onUpdateChannelObjectFromNotificationEvent(
      UpdateChannelObjectFromNotificationEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
        chats: state.chats.map((element) {
          if (element.id == event.chat.id) {
            return event.chat;
          }
          return element;
        }).toList(),
        pinnedChats: state.pinnedChats.map((element) {
          if (element.id == event.chat.id) {
            return event.chat;
          }
          return element;
        }).toList()));
  }

  FutureOr<void> _onDeleteChatFromNotificationEvent(
      DeleteChatFromNotificationEvent event, Emitter<ChatState> emit) {
    bool fromPinned = false;
    List<Chat> chats;
    if (state.chats.any((element) => element.id == event.channelId)) {
      chats = List.of(state.chats);
    } else {
      fromPinned = true;
      chats = List.of(state.pinnedChats);
    }
    String uuid = const Uuid().v4();
    int index = chats.indexWhere((element) => element.id == event.channelId);
    chats[index] = chats[index].copyWith(id: uuid, localId: uuid, messages: []);
    emit(state.copyWith(
        chats: fromPinned ? state.chats : chats,
        deleteChatStatus: DeleteChatStatus.loading,
        newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
          ...chats,
          ...(fromPinned ? state.chats : state.pinnedChats)
        ]),
        pinnedChats: !fromPinned ? state.pinnedChats : chats));
  }

  FutureOr<void> _onAddMediaCountEvent(
      AddMediaCountEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
        imageCountInEachChat: event.images,
        fileCountInEachChat: event.file,
        videoCountInEachChat: event.videos));
  }

  FutureOr<void> _onAddUserConntctSatuseEvent(
      AddUserConntctSatuseEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
        userConnectedStatuse: event.userConnectedStatuse,
        currentOpenedChatId: event.chatId));
  }

  FutureOr<void> _onGetDateTimeEvent(
      GetDateTimeEvent event, Emitter<ChatState> emit) async {
    if (_prefsRepository.chatToken == null) return;
    final response = await getDateTimeUseCase(NoParams());
    response.fold((l) => " ", (r) {
      DateTime? dateServer = DateTime.tryParse(r);
      DateTime dateDevice = DateTime.now().toUtc();

      Duration diff = dateServer!.difference(dateDevice);
      GetIt.I<PrefsRepository>().setServerTime(dateServer);
      GetIt.I<PrefsRepository>().setDuration(diff.inMinutes);
      emit(state.copyWith(duration: diff));
    });
  }

  FutureOr<void> _onSendErrorChatToServerEvent(
      SendErrorChatToServerEvent event, Emitter<ChatState> emit) async {
    final response = await sendErrorToServerUseCase(
        SendErrorParams(error: event.error, pageName: event.lastPage));
    response.fold(
        (l) => print("${event.error.toString().substring(1, 40)}" +
            "failed to send error to back end" +
            "544444444444444444444444444444444444444"), (r) {
      print("${event.error.toString().substring(1, 40)}" +
          "success to send error to back end" +
          "2222222222222222222222222222222222222222222222222222222222222222");
    });
  }

  FutureOr<void> _onIncreaseSharedProductCountOnSocialAppEvent(
      IncreaseSharedProductCountOnSocialAppEvent event,
      Emitter<ChatState> emit) async {
    final response = await shareProductOnAppsUseCase(ShareProductOnAppsParams(
        appName: event.socialMediaName,
        productId: event.productId,
        sharedCount: event.sharedCount));
    emit(state.copyWith(
        getSharedProductCountStatus: GetSharedProductCountStatus.loading));

    response.fold((l) => print("............"), (r) {
      Map<String, String>? getSharedProductCount =
          state.getSharedProductCount ?? {};
      int count =
          int.tryParse((getSharedProductCount[event.productId] ?? '0')) ?? 0;
      getSharedProductCount[event.productId] = '${count + 1}';
      emit(state.copyWith(
          getSharedProductCount: getSharedProductCount,
          getSharedProductCountStatus: GetSharedProductCountStatus.success));
      print("sharedpppppppppppppppppppppppppppppppppppppp" +
          "2222222222222222222222222222222222222222222222222222222222222222");
    });
  }
}
