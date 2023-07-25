import 'dart:async';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/chat/domain/use_cases/get_contacts_usecase.dart';
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

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(
      this.getContactsUseCase,
      this.getMyChatsUseCase,
      this.saveContactsUseCase,
      this.sendMessageUseCase,
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
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  FutureOr<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    List<String> ids = List.of(state.currentMessage);
    List<Message> messages = List.of(state.chats
            .firstWhere((element) => element.id == event.channelId)
            .messages ??
        []);
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
              mediaMessageContent:[
                MediaMessageContent(
                    filePath: event.mediaContent?[0]['file_path'],
                    caption: event.mediaContent?[0]['caption']
                )
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
    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
        chats: state.chats.map((e) {
          if (e.id == event.channelId) {
            return e.copyWith(messages: messages);
          }
          return e;
        }).toList(),
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
        PusherChatService pusherChatService =PusherChatService();
        pusherChatService.initialization();
        pusherChatService.connectPusher();
        r.data!.chats?.forEach((element) {
          pusherChatService.subscribe(element.pusherChannelName.toString());
        });
        int unReadMessagesFromAllChats = 0;
        r.data!.chats?.forEach((element) {
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
    List<Message> messages = List.of(state.chats
            .firstWhere((element) => element.id == event.channelId)
            .messages ??
        []);
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
    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
        chats: state.chats.map((e) {
          if (e.id == event.channelId) {
            return e.copyWith(messages: messages);
          }
          return e;
        }).toList(),
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
      channelId: event.message.channelId
    ));
    List<Message> messages = [];
    List<Chat> chats = List.of(state.chats);
    Chat chat = state.chats.firstWhere(
        (element) => element.id == event.message.channelId,
        orElse: () => Chat(id: -1));
    if (chat.id == -1) {
      chats.add(event.message.channel!);
    }
    messages = List.of(chat.messages ?? []);
    log(messages.length.toString());
    messages.insert(0, event.message);
    log(messages.length.toString());

    emit(state.copyWith(
      receiveMessageStatus: ReceiveMessageStatus.success,
      chats: chats.map((e) {
        if (e.id == event.message.channelId) {
          return e.copyWith(messages: messages);
        }
        return e;
      }).toList(),
    ));
  }

  FutureOr<void> _onReadAllMessagesEvent(
      ReadAllMessagesEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(readMessagesStatus: ResetReadMessagesStatus.loading));
    final response = await readAllMessagesUseCase(
        ReadAllMessagesParams(channelId: event.channelId));
    response.fold(
        (l) => emit(state.copyWith(
            readMessagesStatus: ResetReadMessagesStatus.failure)), (r) {
      emit(state.copyWith(
          readMessagesStatus: ResetReadMessagesStatus.success,
          unReadMessagesFromAllChats: state.unReadMessagesFromAllChats -
              state.chats
                  .firstWhere((element) => element.id == event.channelId)
                  .totalUnreadMessageCount!,
          chats: state.chats.map((e) {
            if (e.id == event.channelId) {
              return e.copyWith(totalUnreadMessageCount: 0);
            }
            return e;
          }).toList()));
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
}
