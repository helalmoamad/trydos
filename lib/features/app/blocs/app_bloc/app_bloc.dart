import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';

@LazySingleton()
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(AppState(
            currentIndex: 0,
            tabIndex: -1,
            tabIndexInChat: 0,
            showBars: true,
            hideBottomNavigationBar: false,
            replyOnMe: false,
            replyType: '',
            thereIsReply: false)) {
    on<AppEvent>((event, emit) {});
    on<ChangeBasePage>(_onChangeBasePage);
    on<ChangeIndexForSearch>(_onChangeIndexForSearch);
    on<ChangeTab>(_onChangeTab);
    on<ChangeTabInChat>(_onChangeTabInChat);

    on<ShowOrHideBars>(_onShowOrHideBars);
    on<HideBottomNavigationBar>(_onHideBottomNavigationBar);
    on<RefreshChatInputField>(_onRefreshChatInputField);
    on<AddUserToTypingList>(_onAddUserToTypingList);
    on<RemoveUserFromTypingList>(_onRemoveUserFromTypingList);
  }

  _onChangeBasePage(
    ChangeBasePage event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  _onChangeIndexForSearch(
    ChangeIndexForSearch event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(currentIndexForSearch: event.index));
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

  _onHideBottomNavigationBar(
    HideBottomNavigationBar event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(hideBottomNavigationBar: event.hide));
  }

  _onRefreshChatInputField(
      RefreshChatInputField event, Emitter<AppState> emit) {
    emit(state.copyWith(
        thereIsReply: event.thereIsReply,
        replyType: event.replyType,
        replyOnMe: event.replyOnMe,
        message: event.message,
        messageId: event.messageId,
        senderParentMessageId: event.senderParentMessageId,
        time: event.time,
        imageUrl: event.imageUrl));
  }

  _onAddUserToTypingList(AddUserToTypingList event, Emitter<AppState> emit) {
    if (state.pusherActivityIds.containsKey(event.chatId)) {
      return;
    }
    Map<int, dynamic> pusherActivityIds = Map.of(state.pusherActivityIds);
    Map<int, String?> pusherActivityDescription =
        Map.of(state.pusherActivityDescription);
    pusherActivityIds[event.chatId] = event.userId;
    pusherActivityDescription[event.chatId] = event.description;
    emit(state.copyWith(
      pusherActivityIds: pusherActivityIds,
      pusherActivityDescription: pusherActivityDescription,
    ));
  }

  _onRemoveUserFromTypingList(
      RemoveUserFromTypingList event, Emitter<AppState> emit) {
    if (!state.pusherActivityIds.containsKey(event.chatId)) {
      return;
    }
    Map<int, dynamic> pusherActivityIds = Map.of(state.pusherActivityIds);
    Map<int, String?> pusherActivityDescription =
        Map.of(state.pusherActivityDescription);
    pusherActivityDescription[event.chatId] = null;
    pusherActivityIds.remove(event.chatId);
    emit(state.copyWith(
      pusherActivityIds: pusherActivityIds,
      pusherActivityDescription: pusherActivityDescription,
    ));
  }
}
