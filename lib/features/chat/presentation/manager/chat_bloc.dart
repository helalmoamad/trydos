import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/features/chat/domain/use_cases/get_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/get_my_chats_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/save_contacts_usecase.dart';
import 'package:trydos/features/chat/domain/use_cases/send_message_usecase.dart';

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
  ChatBloc( this.getContactsUseCase, this.getMyChatsUseCase,
      this.saveContactsUseCase, this.sendMessageUseCase)
      : super(ChatState()) {
    on<ChatEvent>((event, emit) {});
    on<SendMessageEvent>(_onSendMessageEvent,
        transformer: throttleDroppable(throttleDuration));
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


  FutureOr<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatState> emit) {}

  FutureOr<void> _onSaveContactsEvent(
      SaveContactsEvent event, Emitter<ChatState> emit) {}

  FutureOr<void> _onGetChatsEvent(
      GetChatsEvent event, Emitter<ChatState> emit) {}

  FutureOr<void> _onGetContactsEvent(
      GetContactsEvent event, Emitter<ChatState> emit) {}
}
