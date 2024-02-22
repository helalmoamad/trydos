import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/useCase/delete_Call_reg.dart';
import 'package:trydos/features/calls/domain/useCase/get_my_calls.dart';
import 'package:trydos/main.dart';
import '../../data/models/my_calls.dart' as calls;
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/domain/useCase/get_agora_token_use_case.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../domain/useCase/answer_call_usecase.dart';
import '../../domain/useCase/reject_call_usecase.dart';
import '../../domain/useCase/make_call_usecase.dart';

part 'calls_event.dart';

part 'calls_state.dart';

@LazySingleton()
class CallsBloc extends Bloc<CallsEvent, CallsState> {
  final MakeCallUseCase makeCallUseCase;
  final AnswerCallUseCase answerCallUseCase;
  final RejectCallUseCase rejectCallUseCase;

  final GetAgoraTokenUseCase getAgoraTokenUseCase;
  final DeleteCallRegUseCase deleteCallRegUseCase;
  final GetMyCallsUseCase getMyCallsUseCase;

  CallsBloc(
      this.rejectCallUseCase,
      this.makeCallUseCase,
      this.getMyCallsUseCase,
      this.answerCallUseCase,
      this.getAgoraTokenUseCase,
      this.deleteCallRegUseCase)
      : super(CallsState()) {
    on<CallsEvent>((event, emit) {});
    on<UpdateCurrentActiveCallIdEvent>(_onUpdateCurrentActiveCallIdEvent);
    on<InitResponseRejectVideoCallEvent>(_onInitResponseRejectVideoCallEvent);
    on<RejectVideoCallEvent>(_onRejectVideoCallEvent);
    on<AnswerVideoCallEvent>(_onAnswerVideoCallEvent);
    on<EndVideoCallEvent>(_onEndVideoCallEvent);
    on<MakeCallEvent>(_onMakeCallEvent);
    on<DeleteCallRegEvent>(_onDeleteCallRegEvent);
    on<GetMyCallsEvent>(_onGetMyCalls,
        transformer: throttleDroppable(throttleDuration));
    on<UserInteractWithCall>(_onUserInteractWithCall);
    on<ResponseRejectVideoCallEvent>(_onResponseRejectVideoCallEvent);
  }

  FutureOr<void> _onResponseRejectVideoCallEvent(
      ResponseRejectVideoCallEvent event, Emitter<CallsState> emit) {
    debugPrint("createVideoCallStatusdasd");
    emit(state.copyWith(makeCallStatus: MakeCallStatus.cancel));
  }

  FutureOr<void> _onGetMyCalls(
      GetMyCallsEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(getMyCallsStatus: GetMyCallsStatus.loading));
    final response = await getMyCallsUseCase(NoParams());
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetMyCall')) {
          add(GetMyCallsEvent());
          isFailedTheFirstTime.add('GetMyCall');
        }

        emit(state.copyWith(getMyCallsStatus: GetMyCallsStatus.failure));
      },
      (r) {
        apisMustNotToRequest.add('GetMyCalls');

        isFailedTheFirstTime.remove('GetMyCalls');

        emit(state.copyWith(
            getMyCallsStatus: GetMyCallsStatus.success, callRegister: r.data));
      },
    );
  }

  FutureOr<void> _onMakeCallEvent(
      MakeCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(
        makeCallStatus: MakeCallStatus.loading,
        receiverCallName: event.receiverCallName,
        isVideoCall: event.isVideo));
    emit(state.copyWith(
        makeCallStatus: MakeCallStatus.init, isVideoCall: event.isVideo));
    if (event.receiverUserId != null) {
      final response = await makeCallUseCase(MakeCallParams(
          isVideo: event.isVideo,
          payload: event.payload,
          receiverUserId: event.receiverUserId!));
      response.fold((l) {
        emit(state.copyWith(makeCallStatus: MakeCallStatus.failure));
      }, (r) {
        GetIt.I<ChatBloc>().add(AddAMessageToAChannel(
            message: r.data!.message!, localChannelId: event.chatId!));
        emit(state.copyWith(
            makeCallStatus: MakeCallStatus.startCall,
            isVideoCall: event.isVideo,
            currentActiveCallId: r.data!.message!.id!.toString(),
            messageId: r.data!.message!.id!.toString(),
            channelIdForCurrentCall: r.data!.message!.channelId.toString(),
            agoraToken: r.data!.token));
      });
      debugPrint("the channel not exist");
    } else {
      debugPrint("the channel exist");

      final response = await makeCallUseCase(MakeCallParams(
          payload: event.payload,
          chatId: event.chatId!,
          isVideo: event.isVideo));
      response.fold((l) {
        emit(state.copyWith(makeCallStatus: MakeCallStatus.failure));
      }, (r) {
        GetIt.I<ChatBloc>().add(ReceiveMessageEvent(
            message: r.data!.message!, increaseUnReadMessages: false));
        emit(state.copyWith(
          messageId: r.data!.message!.id!.toString(),
          isVideoCall: event.isVideo,
          makeCallStatus: MakeCallStatus.startCall,
          currentActiveCallId: r.data!.message!.id!.toString(),
          agoraToken: r.data!.token,
          channelIdForCurrentCall: r.data!.message!.channelId.toString(),
        ));

        emit(state.copyWith(callRegister: state.callRegister));
      });
    }
  }

  FutureOr<void> _onEndVideoCallEvent(
      EndVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(makeCallStatus: MakeCallStatus.endCall));
    add(GetMyCallsEvent());
  }

  FutureOr<void> _onAnswerVideoCallEvent(
      AnswerVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(
      makeCallStatus: MakeCallStatus.loading,
    ));

    final tempResponse = await answerCallUseCase(event.messageId);
    tempResponse.fold((l) => null, (r) {
      debugPrint("cbvfbfta");
      debugPrint(r.toString());
    });

    final response = await getAgoraTokenUseCase(event.chatId);

    await response.fold((l) => null, (r) async {
      String agoraToken = r.data!;
      emit(state.copyWith(
          makeCallStatus: MakeCallStatus.success,
          agoraToken: agoraToken,
          channelIdForCurrentCall: event.chatId));
    });
  }

  FutureOr<void> _onRejectVideoCallEvent(
      RejectVideoCallEvent event, Emitter<CallsState> emit) async {
    debugPrint("RejectVideoCallEvent");
    final response = await rejectCallUseCase(
        RejectCallParams(messageId: event.messageId, payload: event.payload , duration: event.duration));
    response.fold((l) => null, (r) {
      emit(
          state.copyWith(rejectVideoCallStatus: RejectVideoCallStatus.success));
    });
  }

  FutureOr<void> _onInitResponseRejectVideoCallEvent(
      InitResponseRejectVideoCallEvent event, Emitter<CallsState> emit) async {
    debugPrint("asdasbcvf");
    emit(state.copyWith(makeCallStatus: MakeCallStatus.init));
  }

  FutureOr<void> _onUserInteractWithCall(
      UserInteractWithCall event, Emitter<CallsState> emit) {
    emit(state.copyWith(
        currentActiveCallId: null,
        stopRingToneReason: event.rejectIt
            ? StopRingToneReason.refuse
            : StopRingToneReason.accept));
  }

  FutureOr<void> _onDeleteCallRegEvent(
      DeleteCallRegEvent event, Emitter<CallsState> emit) async {
    /*bool fromPinned = false;
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
        pinnedChats: !fromPinned ? state.pinnedChats : chats));*/
    final response = await deleteCallRegUseCase(
        DeleteCallRegParams.DeleteCallRegParams(callId: event.callId));
    response.fold((l) {
      showMessage("لا يوجد اتصال بالانترنيت ");
    }, (r) {
      state.callRegister!.removeWhere(
        (element) => element.id == event.callId,
      );
      add(GetMyCallsEvent());
      emit((state.copyWith(
        callRegister: state.callRegister,
        deleteCallRegStatus: DeleteCallRegStatus.success,
      )));
    });
  }

  FutureOr<void> _onUpdateCurrentActiveCallIdEvent(
      UpdateCurrentActiveCallIdEvent event, Emitter<CallsState> emit) {
    emit(state.copyWith(currentActiveCallId: event.id));
  }
}
