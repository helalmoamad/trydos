import 'dart:async';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/chat/domain/use_cases/change_chat_property_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/delete_chat_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_messages_between_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_messages_for_chat_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_my_chats_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/read_all_messages_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/receive_message_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/save_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/send_message_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/upload_file_usecase.dart';
import 'package:trydos/main.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/domin/usecases/upload_file_cloudinary_usecase.dart';
import '../../data/models/my_chats_response_model.dart';
import '../../data/models/my_contacts_response_model.dart';
import '../utils/pusher_chat.dart';
import 'chat_event.dart';
import 'helper_function_for_chat_bloc/group_received_message_on_days.dart';

part 'chat_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this.getContactsUseCase,
      this.getMyChatsUseCase,
      this.saveContactsUseCase,
      this.sendMessageUseCase,
      this.getMessagesBetweenUseCase,
      this.uploadFileCloudinaryUseCase,
      this.getMessagesForChatUseCase,
      this.deleteChatUseCase,
      this.changeChatPropertyUseCase,
      this.uploadFileUseCase,
      this.readAllMessagesUseCase,
      this.receiveMessageUseCase)
      : super(ChatState()) {
    on<ChatEvent>((event, emit) {});
    on<SendMessageEvent>(_onSendMessageEvent);
    on<ReadAllMessagesEvent>(_onReadAllMessagesEvent);
    on<NotifyThatIReceivedMessageEvent>(_onNotifyThatIReceivedMessageEvent);
    on<ReceiveMessageEvent>(_onReceiveMessageEvent);
    on<UploadFileEvent>(_onUploadFileEvent);
    on<DeleteChatEvent>(_onDeleteChatEvent);
    on<ReceiveMessageFromPusherEvent>(_onReceiveMessageFromPusherEvent);
    on<WatchedMessageFromPusherEvent>(_onWatchedMessageFromPusherEvent);
    on<ChangeChatPropertyEvent>(_onChangeChatPropertyEvent);
    on<GetMessagesForChatEvent>(_onGetMessagesForChatEvent);
    on<GetAllMessagesBetweenEvent>(_onGetAllMessagesBetweenEvent,
        transformer: throttleDroppable(const Duration(minutes: 2)));
    on<SaveContactsEvent>(_onSaveContactsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetChatsEvent>(_onGetChatsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetContactsEvent>(_onGetContactsEvent,
        transformer: throttleDroppable(throttleDuration));
  }

  final SendMessageUseCase sendMessageUseCase;
  final SaveContactsUseCase saveContactsUseCase;
  final GetContactsUseCase getContactsUseCase;
  final GetMyChatsUseCase getMyChatsUseCase;
  final UploadFileCloudinaryUseCase uploadFileCloudinaryUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final ReadAllMessagesUseCase readAllMessagesUseCase;
  final ReceiveMessageUseCase receiveMessageUseCase;
  final DeleteChatUseCase deleteChatUseCase;
  final ChangeChatPropertyUseCase changeChatPropertyUseCase;
  final GetMessagesForChatUseCase getMessagesForChatUseCase;
  final GetMessagesBetweenUseCase getMessagesBetweenUseCase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  FutureOr<void> _onSendMessageEvent(SendMessageEvent event,
      Emitter<ChatState> emit) async {
    //todo waiting messages and not sent yet
    List<String> ids = List.of(state.currentMessage);
    List<Message> messages;
    bool fromPinned = false;

    //todo ---if-----
    //todo check if the channel exist and get the messages of this channel
    if (state.chats.any( (e) => e.id == event.channelId,)) {
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
              mediaMessageContent: event.messageType != 'TextMessage'
                  ? [
                MediaMessageContent(
                    filePath: event.mediaContent?[0]['file_path'],
                    caption: event.mediaContent?[0]['caption'])
              ]
                  : null,
              parentMessage: parentMessageId != null
                  ? Message(
                  file: event.file,
                  senderUserId: index != -1
                      ? messages[index].senderUserId
                      : event.senderParentMessageId,
                  messageContent: MessageContent(content: event.parentMessageContent))
                  : null));
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
//        print('count  ${messages.length}');
        ids.remove(event.messageId);
        List<Chat> pinnedChats = state.pinnedChats.map((e) {
          if (e.localId == event.channelId &&
              int.tryParse(event.channelId) == null) {
            return r.channel!.copyWith(
                localId: event.channelId,
                messages: e.messages?.map((e) {
                  if (e.localId == event.messageId) {
                    return r.copyWith(localId: e.localId);
                  }
                  return e;
                }).toList());
          } else if (e.id == event.channelId) {
            List<Message> messages = List.of(e.messages ?? []);
            int index =
            messages.indexWhere((element) => element.id == event.messageId);
            messages[index] =
                r.copyWith(file: event.file, localId: event.messageId);
            return e.copyWith(messages: messages);
          }
          return e;
        }).toList();
        List<Chat> chats = state.chats.map((e) {
          if (e.localId == event.channelId &&
              int.tryParse(event.channelId) == null) {
            final PusherChatService pusherChatService =
            GetIt.I<PusherChatService>();
            pusherChatService.subscribe(r.channel!.pusherChannelName.toString());
            pusherChatService.createPresenceChannel(r.channel!.id.toString());
            return r.channel!.copyWith(
                localId: event.channelId,
                messages: e.messages?.map((e) {
                  if (e.localId == event.messageId) {
                    return r.copyWith(localId: e.localId);
                  }
                  return e;
                }).toList());
          }
          else if (e.id == event.channelId) {
            List<Message> messages = List.of(e.messages ?? []);
            int index =
            messages.indexWhere((element) => element.id == event.messageId);
            messages[index] =
                r.copyWith(file: event.file, localId: event.messageId);
            return e.copyWith(messages: messages);
          }
          return e;
        }).toList();
        emit(
          state.copyWith(
              sendMessageStatus: SendMessageStatus.success,
              chats: chats,
              createAnewChat: false,
              pinnedChats: pinnedChats,
              newSortedChatsByDate:
              groupReceivedMessageOnDays(chats: [...chats, ...pinnedChats]),
              currentMessage: ids),
        );
      },
    );
  }

  FutureOr<void> _onSaveContactsEvent(SaveContactsEvent event,
      Emitter<ChatState> emit) async {

    debugPrint('saveContact${state.saveContactsStatus}');
    if (state.saveContactsStatus != SaveContactsStatus.init) {
      return;
    }
    emit(state.copyWith(saveContactsStatus: SaveContactsStatus.loading));
    final response = await saveContactsUseCase(SaveContactsParams(contacts: event.contacts));
    response.fold(
          (l) {
        if (!isFailedTheFirstTime.contains('SaveContactsEvent')) {
          add(SaveContactsEvent());
          isFailedTheFirstTime.add('SaveContactsEvent');
        }
        emit(state.copyWith(saveContactsStatus: SaveContactsStatus.failure));
      },
          (r) {
        isFailedTheFirstTime.remove('SaveContactsEvent');
        GetIt.I<ChatBloc>().add(GetChatsEvent());
        emit(
          state.copyWith(
            // contacts: ,
            saveContactsStatus: SaveContactsStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetChatsEvent(GetChatsEvent event,
      Emitter<ChatState> emit) async {
    emit(state.copyWith(getChatsStatus: GetChatsStatus.loading));
    final response = await getMyChatsUseCase(NoParams());
    response.fold(
          (l) {
        if (!isFailedTheFirstTime.contains('GetChatsEvent')) {
          add(GetChatsEvent());
          isFailedTheFirstTime.add('GetChatsEvent');
        }

        emit(state.copyWith(getChatsStatus: GetChatsStatus.failure));
      },
          (r) {
        isFailedTheFirstTime.remove('GetChatsEvent');
        final PusherChatService pusherChatService =
        GetIt.I<PusherChatService>();
        pusherChatService.initialization();
        pusherChatService.subscribe('user-${GetIt.I<PrefsRepository>().myChatId}-messages');

        r.data!.chats?.forEach((element) async {
          await pusherChatService.createPresenceChannel(element.id.toString());
        });
        r.data!.pinnedChats?.forEach((element) async {
          await pusherChatService
              .createPresenceChannel(element.id.toString());
        });
        int unReadMessagesFromAllChats = 0;
        r.data!.chats?.forEach((element) {
          unReadMessagesFromAllChats += element.totalUnreadMessageCount!;
        });
        r.data!.pinnedChats?.forEach((element) {
          unReadMessagesFromAllChats += element.totalUnreadMessageCount!;
        });

        emit(
          state.copyWith(
              getChatsStatus: GetChatsStatus.success,
              chats: r.data!.chats!,
              newSortedChatsByDate: groupReceivedMessageOnDays(
                  chats: [...r.data!.chats!, ...r.data!.pinnedChats!]),
              pinnedChats: r.data!.pinnedChats!,
              unReadMessagesFromAllChats: unReadMessagesFromAllChats),
        );
        if (state.contacts.isEmpty) {
          add(const GetContactsEvent());
        }
      },
    );
  }

  FutureOr<void> _onGetContactsEvent(GetContactsEvent event,
      Emitter<ChatState> emit) async {
    emit(state.copyWith(getContactsStatus: GetContactsStatus.loading));
    final response = await getContactsUseCase(NoParams());
    response.fold(
          (l) {
        if (!isFailedTheFirstTime.contains('GetContactsEvent')) {
          add(GetContactsEvent());
          isFailedTheFirstTime.add('GetContactsEvent');
        }
        emit(state.copyWith(getContactsStatus: GetContactsStatus.failure));
      },
          (r) {
        isFailedTheFirstTime.remove('GetContactsEvent');
        List<Chat> newChats = List.of(state.chats);
        bool changed = false;
        List<Chat> chats = List.of(state.chats);
        chats.addAll(state.pinnedChats);
//        print('long : ${r.contacts?.length}');
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
//          print('index : $index');
          if (index == -1) {
            print('new chat');
            changed = true;
            String uuid = const Uuid().v4();
            newChats.insert(
                0,
                Chat(
                    id: uuid,
                    localId: uuid,
                    messages: [],
                    paginationStatus: PaginationStatus.initial,
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

  FutureOr<void> _onUploadFileEvent(UploadFileEvent event,
      Emitter<ChatState> emit) async {
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
//    print('index $index');
    parentMessageId = event.parentMessageId;
    if (index != -1) {
      print(messages[index].id);
      parentMessageId = messages[index].id;
    }
    messages.insert(
        0,
        Message(
            channelId: event.channelId,
            id: event.messageId,
            file: event.file,
            checkedExistence: true,
            createdAt: DateTime.now(),
            receiverUserId: event.receiverUserId,
            senderUserId: _prefsRepository.myChatId,
            messageType: MessageType(name: event.messageType),
            isForward: (event.isForward ?? false) ? 1 : 0,
            parentMessageId: parentMessageId,
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
    final response ;
    if(event.useCloudinaryToUpload) {
      response = await uploadFileCloudinaryUseCase(
          UploadFileCloudinaryParams(
              file: event.file,
              usingSendProgressFunction: false,
              usingOnUploadingFinishedFunction: false));
    }else{
      response = await uploadFileUseCase(UploadFileParams(event.file ,event.filePath ));
    }
    response.fold((l) {
      List<String> currentFailedMessage = List.of(state.currentFailedMessage);
      ids.remove(event.messageId);
      currentFailedMessage.add(event.messageId);
      emit(state.copyWith(
          sendMessageStatus: SendMessageStatus.failure,
          currentFailedMessage: currentFailedMessage));
    }, (r) {
      _prefsRepository.setAFilePathExist(event.useCloudinaryToUpload ? r.secureUrl! : r.data!.filePath!);
      add(SendMessageEvent(
          messageId: event.messageId,
          extraFields: event.extraFields,
          isForward: event.isForward,
          channelId: event.channelId,
          senderParentMessageId: event.senderParentMessageId,
          file: event.file,
          parentMessageContent: event.parentMessageContent,
          mediaContent: [
            {
              'file_path': event.useCloudinaryToUpload ? r.secureUrl! : r.data!.filePath!,
              'file_name': event.fileName,
              'caption': 'test image'
            }
          ],
          messageType: event.messageType,
          parentMessageId: event.parentMessageId,
          receiverUserId: event.receiverUserId));
    });
  }

  FutureOr<void> _onReceiveMessageEvent(ReceiveMessageEvent event,
      Emitter<ChatState> emit) async {
    log('***** message received *****');
    print('message ${event.message}');
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
    print('event.message.channelId: ${event.message.channelId}');
    print('chatId: ${chat.id}');
    if (chat.id == '-1') {
      chats.insert(
          0,
          event.message.channel!.copyWith(
            paginationStatus: PaginationStatus.initial,
            hasReachedMax: false,
          ));
    } else {
      print('totalUnreadMessageCount: ${chat.totalUnreadMessageCount}');
      chats.removeWhere((element) => element.id == chat.id);
      chats.insert(
          0,
          chat.copyWith(
              totalUnreadMessageCount: ((chat.totalUnreadMessageCount ?? 0) +
                  (event.message.senderUserId! != _prefsRepository.myChatId
                      ? 1
                      : 0))));
    }
    messages = List.of(chat.messages ?? []);
    messages.insert(0, event.message);

    int index =
    messages.indexWhere((element) => element.id == event.prevMessageId);
    chats = sortChats(chats, event.message.channelId, messages);
    emit(state.copyWith(
      receiveMessageStatus: ReceiveMessageStatus.success,
      unReadMessagesFromAllChats:
      state.unReadMessagesFromAllChats + event.message.senderUserId! !=
          _prefsRepository.myChatId
          ? 1
          : 0,
      newSortedChatsByDate: groupReceivedMessageOnDays(
          chats: [...chats, ...(fromPinned ? state.chats : state.pinnedChats)]),
      currentChannelReceivedMessage: event.message.channelId,
      channelId: event.message.channelId,
      chats: fromPinned ? state.chats : chats,
      pinnedChats: !fromPinned ? state.pinnedChats : chats,
    ));
    add(NotifyThatIReceivedMessageEvent(channelId: event.message.channelId!));
    if (index == -1) {
      add(GetAllMessagesBetweenEvent(
          firstMessageId: event.prevMessageId,
          secondMessageId: event.message.id.toString(),
          scrollToParentMessage: false,
          channelId: event.message.channelId.toString()));
    }
  }

  FutureOr<void> _onReadAllMessagesEvent(ReadAllMessagesEvent event,
      Emitter<ChatState> emit) async {
    if (int.tryParse(event.channelId) == null) {
      return;
    }
    emit(state.copyWith(readMessagesStatus: ResetReadMessagesStatus.loading));
    final response = await readAllMessagesUseCase(
        ReadAllMessagesParams(channelId: event.channelId));
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('ReadAllMessagesEvent')) {
        add(SaveContactsEvent());
        isFailedTheFirstTime.add('ReadAllMessagesEvent');
      }
      emit(state.copyWith(readMessagesStatus: ResetReadMessagesStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('ReadAllMessagesEvent');
      emit(state.copyWith(
          readMessagesStatus: ResetReadMessagesStatus.success,
          unReadMessagesFromAllChats: state.unReadMessagesFromAllChats -
              (state.chats
                  .firstWhere((element) => element.id == event.channelId,
                  orElse: () =>
                      state.pinnedChats.firstWhere(
                              (element) => element.id == event.channelId))
                  .totalUnreadMessageCount ??
                  0),
          chats: state.chats.map((e) {
            if (e.id == event.channelId) {
              return e.copyWith(totalUnreadMessageCount: 0);
            }
            return e;
          }).toList(),
          pinnedChats: state.pinnedChats.map((e) {
            if (e.id == event.channelId) {
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
        add(SaveContactsEvent());
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

  FutureOr<void> _onDeleteChatEvent(DeleteChatEvent event,
      Emitter<ChatState> emit) async {
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
    final response =
    await deleteChatUseCase(DeleteChatParams(channelId: event.channelId));
    response.fold((l) {
      if (state.chats.any((element) => element.id == event.channelId)) {
        chats = List.of(state.chats);
      } else {
        fromPinned = true;
        chats = List.of(state.pinnedChats);
      }
      Chat removedChat =
      chats.firstWhere((element) => element.id == event.channelId);
      int index = chats.indexOf(removedChat);
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
      emit((state.copyWith(
        deleteChatStatus: DeleteChatStatus.success,
      )));
    });
  }

  FutureOr<void> _onChangeChatPropertyEvent(ChangeChatPropertyEvent event,
      Emitter<ChatState> emit) async {
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
          orElse: () =>
              pinnedChats
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

  List<Chat> sortChats(List<Chat> unSortedChats, String? channelId,
      List<Message> messages) {
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
      if ((a.messages?.isEmpty ?? true) || (b.messages?.isEmpty ?? true)) {
        if (a.messages?.isEmpty ?? true) {
          return -1;
        } else if (b.messages?.isEmpty ?? true) {
          return 1;
        } else {
          return 0;
        }
      }
      return a.messages!.first.createdAt!
          .compareTo(b.messages!.first.createdAt!);
    });
    return unSortedChats.reversed.toList();
  }

  FutureOr<void> _onReceiveMessageFromPusherEvent(
      ReceiveMessageFromPusherEvent event, Emitter<ChatState> emit) {
    print('_onReceiveMessageFromPusherEventExecuted');

    emit(state.copyWith(
        changeMessageStateFromPusherStatus:
        ChangeMessageStateFromPusherStatus.init));
    List<Chat> chats = getChatsAfterEditPropertyOfMessage(state.chats, 1, null,
        event.channelId, event.lastMessageId, event.userId);
    List<Chat> pinnedChats = getChatsAfterEditPropertyOfMessage(
        state.pinnedChats,
        1,
        null,
        event.channelId,
        event.lastMessageId,
        event.userId);
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
    print('_onWatchedMessageFromPusherEventExecuted');

    emit(state.copyWith(
        changeMessageStateFromPusherStatus:
        ChangeMessageStateFromPusherStatus.init));
    List<Chat> chats = getChatsAfterEditPropertyOfMessage(state.chats, null,
        true, event.channelId, event.lastMessageId, event.userId);
    List<Chat> pinnedChats = getChatsAfterEditPropertyOfMessage(
        state.pinnedChats,
        null,
        true,
        event.channelId,
        event.lastMessageId,
        event.userId);
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

  List<Chat> getChatsAfterEditPropertyOfMessage(List<Chat> chats, int? received,
      bool? watched, String channelId, int lastMessageId, int userId) {
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
                        isReceived: received ?? s.isReceived);
                  }).toList());
            }).toList());
      }
      return e;
    }).toList()
        : chats;
  }

  _onGetMessagesForChatEvent(GetMessagesForChatEvent event,
      Emitter<ChatState> emit) async {
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

  FutureOr<void> _onGetAllMessagesBetweenEvent(GetAllMessagesBetweenEvent event,
      Emitter<ChatState> emit) async {
    if (state.getMessagesBetweenStatus == GetMessagesBetweenStatus.loading) {
      return;
    }
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
    emit(state.copyWith(
      getMessagesBetweenStatus: GetMessagesBetweenStatus.loading,
    ));
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
}
