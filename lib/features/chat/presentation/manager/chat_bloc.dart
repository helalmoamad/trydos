import 'dart:async';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/chat/domain/use_cases/change_chat_property_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/delete_chat_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_messages_for_chat_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_my_chats_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/read_all_messages_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/receive_message_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/save_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/send_message_usecase.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../data/models/my_chats_response_model.dart';
import '../../data/models/my_contacts_response_model.dart';
import '../../domain/use_cases/upload_file_usecase.dart';
import '../utils/pusher_chat.dart';
import 'chat_event.dart';

part 'chat_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(
      this.getContactsUseCase,
      this.getMyChatsUseCase,
      this.saveContactsUseCase,
      this.sendMessageUseCase,
      this.uploadFileUseCase,
      this.getMessagesForChatUseCase,
      this.deleteChatUseCase,
      this.changeChatPropertyUseCase,
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
  final UploadFileUseCase uploadFileUseCase;
  final ReadAllMessagesUseCase readAllMessagesUseCase;
  final ReceiveMessageUseCase receiveMessageUseCase;
  final DeleteChatUseCase deleteChatUseCase;
  final ChangeChatPropertyUseCase changeChatPropertyUseCase;
  final GetMessagesForChatUseCase getMessagesForChatUseCase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  FutureOr<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    List<String> ids = List.of(state.currentMessage);
    List<Message> messages;
    bool fromPinned=false;
    if (state.chats.any(
          (e) => e.id == event.channelId,
    )) {
      messages = List.of(state.chats
          .firstWhere((element) => element.id == event.channelId)
          .messages ??
          []);
    }else{
      fromPinned=true;
      messages = List.of(state.pinnedChats
          .firstWhere((element) => element.id == event.channelId)
          .messages ??
          []);
    }
    if (!ids.contains(event.messageId)) {
      messages.insert(
          0,
          Message(
              channelId: event.channelId,
              id: event.messageId,
              createdAt: DateTime.now(),
              receiverUserId: event.receiverUserId,
              messageContent: event.messageType == 'TextMessage'
                  ? MessageContent(
                      messageId: event.messageId, content: event.content)
                  : null,
              senderUserId: _prefsRepository.myId,
              messageType: MessageType(name: event.messageType),
              isForward: (event.isForward ?? false) ? 1 : 0,
              parentMessageId: event.parentMessageId,
              mediaMessageContent: [
                MediaMessageContent(
                    filePath: event.mediaContent?[0]['file_path'],
                    caption: event.mediaContent?[0]['caption'])
              ],
              parentMessage: event.parentMessageId != null
                  ? Message(
                      file: event.file,
                      senderUserId: event.senderParentMessageId,
                      messageContent:
                          MessageContent(content: event.parentMessageContent))
                  : null));
    }
    if (!ids.contains(event.messageId)) {
      ids.add(event.messageId);
    }
    List<Chat> chats;
    if(fromPinned){
      chats= sortChats(state.pinnedChats, event.channelId, messages);
    }else{
      chats= sortChats(state.chats, event.channelId, messages);
    }
    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
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
          parentMessageId: event.parentMessageId,
          receiverUserId: event.receiverUserId),
    );
    response.fold(
      (l) => emit(state.copyWith(sendMessageStatus: SendMessageStatus.failure)),
      (r) {
        ids.remove(event.messageId);

        emit(
          state.copyWith(
              sendMessageStatus: SendMessageStatus.success,
              chats: state.chats.map((e) {
                if (e.id == event.channelId) {
                  List<Message> messages = List.of(e.messages ?? []);
                  int index = messages
                      .indexWhere((element) => element.id == event.messageId);
                  messages[index] = r.copyWith(file: event.file);
                  return e.copyWith(messages: messages);
                }
                return e;
              }).toList(),
              currentMessage: ids),
        );
      },
    );
  }

  FutureOr<void> _onSaveContactsEvent(
      SaveContactsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(saveContactsStatus: SaveContactsStatus.loading));
    final response =
        await saveContactsUseCase(SaveContactsParams(contacts: event.contacts));
    response.fold(
      (l) =>
          emit(state.copyWith(saveContactsStatus: SaveContactsStatus.failure)),
      (r) {
        emit(
          state.copyWith(
            saveContactsStatus: SaveContactsStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetChatsEvent(
      GetChatsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(getChatsStatus: GetChatsStatus.loading));
    final response = await getMyChatsUseCase(NoParams());
    response.fold(
      (l) => emit(state.copyWith(getChatsStatus: GetChatsStatus.failure)),
      (r) {
        PusherChatService pusherChatService = GetIt.I<PusherChatService>();
        pusherChatService.initialization();
        r.data!.chats?.forEach((element) async {
          await pusherChatService
              .subscribe(element.pusherChannelName.toString());
          await pusherChatService.createPresenceChannel(element.id!);
        });
        r.data!.pinnedChats?.forEach((element) async {
          await pusherChatService
              .subscribe(element.pusherChannelName.toString());
          await pusherChatService.createPresenceChannel(element.id!);
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
              chats: r.data!.chats,
              pinnedChats: r.data!.pinnedChats,
              unReadMessagesFromAllChats: unReadMessagesFromAllChats),
        );
      },
    );
  }

  FutureOr<void> _onGetContactsEvent(
      GetContactsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(getContactsStatus: GetContactsStatus.loading));
    final response = await getContactsUseCase(NoParams());
    response.fold(
      (l) => emit(state.copyWith(getContactsStatus: GetContactsStatus.failure)),
      (r) {
        emit(
          state.copyWith(
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
    bool fromPinned=false;
    if (state.chats.any(
          (e) => e.id == event.channelId,
    )) {
      messages = List.of(state.chats
          .firstWhere((element) => element.id == event.channelId)
          .messages ??
          []);
    }else{
      fromPinned=true;
      messages = List.of(state.pinnedChats
          .firstWhere((element) => element.id == event.channelId)
          .messages ??
          []);
    }
    messages.insert(
        0,
        Message(
            channelId: event.channelId,
            id: event.messageId,
            file: event.file,
            createdAt: DateTime.now(),
            receiverUserId: event.receiverUserId,
            senderUserId: _prefsRepository.myId,
            messageType: MessageType(name: event.messageType),
            isForward: (event.isForward ?? false) ? 1 : 0,
            parentMessageId: event.parentMessageId,
            parentMessage: event.parentMessageId != null
                ? Message(
                    file: event.file,
                    senderUserId: event.senderParentMessageId,
                    messageContent:
                        MessageContent(content: event.parentMessageContent))
                : null));

    List<Chat> chats;
    if(fromPinned){
      chats= sortChats(state.pinnedChats, event.channelId, messages);
    }else{
      chats= sortChats(state.chats, event.channelId, messages);
    }

    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
        chats: fromPinned ? state.chats : chats,
        pinnedChats: !fromPinned ? state.pinnedChats : chats,
        channelId: event.channelId));
    final response =
        await uploadFileUseCase(UploadFileParams(event.file, event.filePath));
    response.fold(
        (l) =>
            emit(state.copyWith(sendMessageStatus: SendMessageStatus.failure)),
        (r) {
      add(SendMessageEvent(
          messageId: event.messageId,
          extraFields: event.extraFields,
          isForward: event.isForward,
          channelId: event.channelId,
          senderParentMessageId: event.senderParentMessageId,
          file: event.file,
          parentMessageContent: event.parentMessageContent,
          mediaContent: [
            {'file_path': r.data!.filePath, 'caption': 'test image'}
          ],
          messageType: event.messageType,
          parentMessageId: event.parentMessageId,
          receiverUserId: event.receiverUserId));
    });
  }

  FutureOr<void> _onReceiveMessageEvent(
      ReceiveMessageEvent event, Emitter<ChatState> emit) async {
    log('***** message received *****');
    emit(state.copyWith(
        receiveMessageStatus: ReceiveMessageStatus.loading,
        unReadMessagesFromAllChats: state.unReadMessagesFromAllChats + 1,
        currentChannelReceivedMessage: event.message.channelId,
        channelId: event.message.channelId));
    List<Message> messages = [];
    bool fromPinned=false;
    List<Chat> chats ;
    if (state.chats.any(
          (e) => e.id == event.message.channelId,
    )) {
      chats=state.chats;
    }else{
      fromPinned=true;
      chats=state.pinnedChats;

    }
    Chat chat = chats.firstWhere(
        (element) => element.id == event.message.channelId,
        orElse: () => Chat(id: -1));
    if (chat.id == -1) {
      chats.insert(
          0,
          event.message.channel!.copyWith(
            paginationStatus: PaginationStatus.initial,
            hasReachedMax: false,
          ));
    } else {
      chats.remove(chat);
      chats.insert(
          0,
          chat.copyWith(
              totalUnreadMessageCount:
                  (chat.totalUnreadMessageCount ?? 0) + 1));
    }
    messages = List.of(chat.messages ?? []);
    messages.insert(0, event.message);

    emit(state.copyWith(
      receiveMessageStatus: ReceiveMessageStatus.success,
      chats: fromPinned ? state.chats : chats.map((e) {
        if (e.id == event.message.channelId) {
          return e.copyWith(messages: messages);
        }
        return e;
      }).toList(),
      pinnedChats: !fromPinned ? state.pinnedChats : chats.map((e) {
        if (e.id == event.message.channelId) {
          return e.copyWith(messages: messages);
        }
        return e;
      }).toList(),
    ));
  }

  FutureOr<void> _onReadAllMessagesEvent(
      ReadAllMessagesEvent event, Emitter<ChatState> emit) async {
    if (state.unReadMessagesFromAllChats == 0) {
      return;
    }
    emit(state.copyWith(readMessagesStatus: ResetReadMessagesStatus.loading));
    final response = await readAllMessagesUseCase(
        ReadAllMessagesParams(channelId: event.channelId));
    response.fold(
        (l) => emit(state.copyWith(
            readMessagesStatus: ResetReadMessagesStatus.failure)), (r) {
      emit(state.copyWith(
          readMessagesStatus: ResetReadMessagesStatus.success,
          unReadMessagesFromAllChats: state.unReadMessagesFromAllChats -
              state.chats.firstWhere((element) => element.id == event.channelId , orElse: ()=> state.pinnedChats.firstWhere((element) => element.id == event.channelId))
                  .totalUnreadMessageCount!,
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
          }).toList()
      ));
    });
  }

  FutureOr<void> _onNotifyThatIReceivedMessageEvent(
      NotifyThatIReceivedMessageEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
        notifyThatIReceivedMessageStatus:
            NotifyThatIReceivedMessageStatus.loading));
    final response = await receiveMessageUseCase(
        ReceiveMessageParams(channelId: event.channelId));
    response.fold(
        (l) => emit(state.copyWith(
            notifyThatIReceivedMessageStatus:
                NotifyThatIReceivedMessageStatus.failure)), (r) {
      emit(state.copyWith(
          notifyThatIReceivedMessageStatus:
              NotifyThatIReceivedMessageStatus.success));
    });
  }

  FutureOr<void> _onDeleteChatEvent(
      DeleteChatEvent event, Emitter<ChatState> emit) async {
    bool fromPinned=false;
    List<Chat> chats ;
    if(state.chats.any((element) => element.id==event.channelId)){
      chats= List.of(state.chats);
    }else{
      fromPinned=true;
      chats= List.of(state.pinnedChats);
    }
    chats.removeWhere((element) => element.id == event.channelId);
    emit(state.copyWith(chats: fromPinned ? state.chats : chats , pinnedChats: !fromPinned ? state.pinnedChats : chats));
    final response =
        await deleteChatUseCase(DeleteChatParams(channelId: event.channelId));
    response.fold((l) {
      if(state.chats.any((element) => element.id==event.channelId)){
        chats= List.of(state.chats);
      }else{
        fromPinned=true;
        chats= List.of(state.pinnedChats);
      }
      Chat removedChat = chats.firstWhere((element) => element.id == event.channelId);
      int index = chats.indexOf(removedChat);
      chats.insert(index, removedChat);
      emit(state.copyWith(chats: fromPinned ? state.chats : chats , pinnedChats: !fromPinned ? state.pinnedChats : chats));
    }, (r) {});
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
          if (e.userId == _prefsRepository.myId) {
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
          if (e.userId == _prefsRepository.myId) {
            return e.copyWith(pin: 1);
          }
          return e;
        }).toList();
        chats.removeWhere((e) => e.id == changedChat.id);
        pinnedChats.insert(0, changedChat.copyWith(channelMembers: members));
      }
    } else {
      changedChat = chats.firstWhere((element) => element.id == event.channelId,
          orElse: () => pinnedChats
              .firstWhere((element) => element.id == event.channelId));
      members = changedChat.channelMembers!;
      members = members.map((e) {
        if (e.userId == _prefsRepository.myId) {
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
    emit(state.copyWith(chats: chats, pinnedChats: pinnedChats));
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
          if (e.userId == _prefsRepository.myId) {
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
          if (e.userId == _prefsRepository.myId) {
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
      emit(state.copyWith(chats: chats, pinnedChats: pinnedChats));
    }, (r) {});
  }

  List<Chat> sortChats(
      List<Chat> unSortedChats, int? channelId, List<Message> messages) {
    List<Chat> chats = List.of(unSortedChats);
    Chat chat = chats.firstWhere((element) => element.id == channelId);
    chats.removeWhere((e) => e.id == chat.id);
    chat = chat.copyWith(messages: messages);
    chats.insert(0, chat);
    return chats;
  }

  List<Chat> sortChatsByTime(List<Chat> unSortedChats) {
    unSortedChats.sort((a, b) {
      if ((a.messages?.isEmpty ?? true) || (b.messages?.isEmpty ?? true)) {
        return b.opensAt!.compareTo(a.opensAt!);
      }
      return b.messages!.first.createdAt!
          .compareTo(a.messages!.first.createdAt!);
    });
    return unSortedChats;
  }

  FutureOr<void> _onReceiveMessageFromPusherEvent(
      ReceiveMessageFromPusherEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      chats: getChatsAfterEditPropertyOfMessage(state.chats, 1, null,
          event.channelId, event.lastMessageId, event.userId),
      pinnedChats: getChatsAfterEditPropertyOfMessage(state.pinnedChats, 1,
          null, event.channelId, event.lastMessageId, event.userId),
    ));
  }

  FutureOr<void> _onWatchedMessageFromPusherEvent(
      WatchedMessageFromPusherEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      chats: getChatsAfterEditPropertyOfMessage(state.chats, null, true,
          event.channelId, event.lastMessageId, event.userId),
      pinnedChats: getChatsAfterEditPropertyOfMessage(state.pinnedChats, null,
          true, event.channelId, event.lastMessageId, event.userId),
    ));
  }

  List<Chat> getChatsAfterEditPropertyOfMessage(List<Chat> chats, int? received,
      bool? watched, int channelId, int lastMessageId, int userId) {
    return chats
                .firstWhere((element) => element.id == channelId,
                    orElse: () => Chat(id: -1))
                .id !=
            -1
        ? chats.map((e) {
            if (e.id == channelId) {
              return e.copyWith(
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

  _onGetMessagesForChatEvent(
      GetMessagesForChatEvent event, Emitter<ChatState> emit) async {
    bool fromPinned = false;
    Chat chat;

    chat = state.chats.firstWhere((element) => element.id == event.channelId,
        orElse: () => Chat(id: -1));
    if (chat.id == -1) {
      fromPinned = true;
      chat = state.pinnedChats
          .firstWhere((element) => element.id == event.channelId);
    }
    String lastMessageId = chat.messages!.last.id!;
    print('lastMessageId $lastMessageId');
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
                }).toList()));
    });
  }
}
