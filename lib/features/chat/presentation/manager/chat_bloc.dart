import 'dart:async';
import 'dart:io';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/chat/domain/use_cases/get_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_my_chats_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/save_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/send_message_usecase.dart';

import '../../data/models/my_chats_response_model.dart';
import '../../data/models/my_contacts_response_model.dart';
import '../../domain/use_cases/upload_file_usecase.dart';

part 'chat_event.dart';

part 'chat_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this.getContactsUseCase, this.getMyChatsUseCase,
      this.saveContactsUseCase, this.sendMessageUseCase, this.uploadFileUseCase)
      : super(ChatState()) {
    on<ChatEvent>((event, emit) {});
    on<SendMessageEvent>(_onSendMessageEvent);
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


  FutureOr<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    List<String> ids = List.of(state.currentMessage);
    if (!ids.contains(event.messageId)) {
      ids.add(event.messageId);
    }
    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
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
        Map<int , List<Message>> messages=state.messages;
        messages[state.channelId]!.insert(0,r);
        emit(
          state.copyWith(
              sendMessageStatus: SendMessageStatus.success,
              messages:messages,
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
        Map<int ,List<Message>> messages={};
        for(int i=0;i<(r.data!.chats?.length ?? 0);i++){
          messages[r.data!.chats![i].id!]=List.of(r.data!.chats![i].messages ?? []);
        }
        emit(
          state.copyWith(
            getChatsStatus: GetChatsStatus.success,
            chats: r.data!.chats,
            pinnedChats: r.data!.pinnedChats,
            messages: messages
          ),
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
    if (!ids.contains(event.messageId)) {
      ids.add(event.messageId);
    }
    emit(state.copyWith(
        sendMessageStatus: SendMessageStatus.loading,
        currentMessage: ids,
        channelId: event.channelId));
    final response =
        await uploadFileUseCase(UploadFileParams(event.file, event.filePath));
    response.fold(
        (l) =>
            emit(state.copyWith(sendMessageStatus: SendMessageStatus.failure)),
        (r) {
      print(r.data!.filePath);
      add(SendMessageEvent(
          messageId: event.messageId,
          extraFields: event.extraFields,
          isForward: event.isForward,
          channelId: event.channelId,
          mediaContent: [
            {'file_path': r.data!.filePath, 'caption': 'test image'}
          ],
          messageType: event.messageType,
          parentMessageId: event.parentMessageId,
          receiverUserId: event.receiverUserId));
    });
  }
}
