import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(AppState(
            currentIndex: 0,
            tabIndex: 0,
            tabIndexInChat: 0,
            showBars: true,
            replyOnMe: false,
            replyType: '',
            thereIsReply: false)) {
    on<AppEvent>((event, emit) {});
    on<ChangeBasePage>(_onChangeBasePage);
    on<ChangeTab>(_onChangeTab);
    on<ChangeTabInChat>(_onChangeTabInChat);
    on<ShowOrHideBars>(_onShowOrHideBars);
    on<RefreshChatInputField>(_onRefreshChatInputField);
  }

  _onChangeBasePage(
    ChangeBasePage event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  _onChangeTab(
    ChangeTab event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.index));
  }

  _onChangeTabInChat(
    ChangeTabInChat event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(tabIndexInChat: event.index));
  }

  _onShowOrHideBars(
    ShowOrHideBars event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(showBars: event.show));
  }

  FutureOr<void> _onRefreshChatInputField(
      RefreshChatInputField event, Emitter<AppState> emit) {
    emit(
      state.copyWith(
          thereIsReply: event.thereIsReply,
          replyType: event.replyType,
          replyOnMe: event.replyOnMe,
          message: event.message,
          messageId: event.messageId,
          senderParentMessageId: event.senderParentMessageId,
          time: event.time,
          imageUrl: event.imageUrl)
    );
  }
}
