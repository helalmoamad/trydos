import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/use_case/use_case.dart';

import 'package:trydos/features/calls/domain/useCase/delete_Message.dart';
import 'package:trydos/features/calls/domain/useCase/get_missed_call_count.dart';
import 'package:trydos/features/calls/domain/useCase/get_my_calls.dart';
import 'package:trydos/features/calls/domain/useCase/watch_missed_call.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/main.dart';
import '../../data/models/my_calls.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/domain/useCase/get_agora_token_use_case.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../domain/useCase/answer_call_usecase.dart';
import '../../domain/useCase/delete_Message.dart';
import '../../domain/useCase/reject_call_usecase.dart';
import '../../domain/useCase/make_call_usecase.dart';

part 'calls_event.dart';

part 'calls_state.dart';

@LazySingleton()
class CallsBloc extends Bloc<CallsEvent, CallsState> {
  final MakeCallUseCase makeCallUseCase;
  final AnswerCallUseCase answerCallUseCase;
  final RejectCallUseCase rejectCallUseCase;
  final WatchMissedCallUseCase watchMissedCallUseCase;
  final GetAgoraTokenUseCase getAgoraTokenUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final GetMyCallsUseCase getMyCallsUseCase;
  final GetMissedCalCountUseCase getMissedCalCountUseCase;
  CallsBloc(
      this.rejectCallUseCase,
      this.makeCallUseCase,
      this.getMyCallsUseCase,
      this.watchMissedCallUseCase,
      this.answerCallUseCase,
      this.getMissedCalCountUseCase,
      this.getAgoraTokenUseCase,
      this.deleteMessageUseCase)
      : super(CallsState()) {
    on<CallsEvent>((event, emit) {});
    on<UpdateCurrentActiveCallIdEvent>(_onUpdateCurrentActiveCallIdEvent);
    on<IcreaseMissedCallEvent>(_onIcreaseMissedCallEvent);
    on<GetMissedCallCountEvent>(_onGetMissedCallCountEvent);
    on<ResetMissedCallEvent>(_onResetMissedCallEvent);
    on<InitResponseRejectVideoCallEvent>(_onInitResponseRejectVideoCallEvent);
    on<RejectVideoCallEvent>(_onRejectVideoCallEvent);
    on<WatchMissedCallEvent>(_onWatchMissedCallEvent);

    on<AnswerVideoCallEvent>(_onAnswerVideoCallEvent);
    on<EndVideoCallEvent>(_onEndVideoCallEvent);
    on<MakeCallEvent>(_onMakeCallEvent);
    on<DeleteMessageEvent>(_onDeleteMessageEvent);
    on<DeleteMessageNotificationReceivedInCallsEvent>(
        _onDeleteMessageNotificationReceivedInCallsEvent);
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

  FutureOr<void> _onWatchMissedCallEvent(
      WatchMissedCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(
        watchedMissedCallStatus: WatchedMissedCallStatus.loading));
    final response = await watchMissedCallUseCase(NoParams());
    response.fold(
        (l) => emit(state.copyWith(
            watchedMissedCallStatus: WatchedMissedCallStatus.failure)),
        (r) => emit(state.copyWith(
            watchedMissedCallStatus: WatchedMissedCallStatus.success)));
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

  FutureOr<void> _onGetMissedCallCountEvent(
      GetMissedCallCountEvent event, Emitter<CallsState> emit) async {
    if (state.getMissedCallCountStatus == GetMissedCallCountStatus.success)
      return;
    emit(state.copyWith(
        getMissedCallCountStatus: GetMissedCallCountStatus.loading));
    final missedCallCount = await getMissedCalCountUseCase(NoParams());
    missedCallCount.fold(
        (l) => emit(state.copyWith(
            getMissedCallCountStatus: GetMissedCallCountStatus.failure)), (r) {
      emit(state.copyWith(
          getMissedCallCountStatus: GetMissedCallCountStatus.success,
          missedCallCount: r.data!.missedCals));
    });
  }

  FutureOr<void> _onIcreaseMissedCallEvent(
      IcreaseMissedCallEvent event, Emitter<CallsState> emit) async {
    int count = state.missedCallCount + 1;

    emit(state.copyWith(missedCallCount: count));
    add(GetMyCallsEvent());
  }

  FutureOr<void> _onResetMissedCallEvent(
      ResetMissedCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(missedCallCount: 0));
    add(WatchMissedCallEvent());
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
    final response = await rejectCallUseCase(RejectCallParams(
        messageId: event.messageId,
        payload: event.payload,
        duration: event.duration));
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

  FutureOr<void> _onDeleteMessageEvent(
      DeleteMessageEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(deleteMessageStatus: DeleteMessageStatus.init));
    if (event.type == "message") {
      GetIt.I<ChatBloc>().add(DeleteMessageNotificationReceivedInChatsEvent(
          messageId: event.messageId,
          channelId: event.channelId!,
          deleteForAll: event.deleteFromBoth == 1,
          isDelete: 1,
          deletedByUserId: event.deleteFromId));
    } else {
      List<CallReg> callReg = state.callRegister!.map((e) {
        if (e.id == event.messageId) {
          return e.copyWith(
              authMessageStatus: MessagesStatus(
                  isDeleted: 1, deleteForAll: event.deleteFromBoth == 1));
        }
        return e;
      }).toList();
      emit(state.copyWith(callRegister: callReg));
    }

    final response = await deleteMessageUseCase(DeleteMessageParams(
        messageId: event.messageId, deleteFromAll: event.deleteFromBoth));
    response.fold((l) {
      if (event.type == "message") {
        GetIt.I<ChatBloc>().add(DeleteMessageNotificationReceivedInChatsEvent(
            messageId: event.messageId,
            channelId: event.channelId!,
            deleteForAll: event.deleteFromBoth == 0,
            isDelete: 0,
            deletedByUserId: event.deleteFromId));
      } else {
        List<CallReg> callReg = state.callRegister!.map((e) {
          if (e.id == event.messageId) {
            return e.copyWith(
                authMessageStatus:
                    MessagesStatus(isDeleted: 0, deleteForAll: false));
          }
          return e;
        }).toList();
        emit(state.copyWith(callRegister: callReg));
        emit((state.copyWith(
          deleteMessageStatus: DeleteMessageStatus.failure,
        )));
      }
    }, (r) {
      emit((state.copyWith(
        deleteMessageStatus: DeleteMessageStatus.success,
      )));
    });
  }

  FutureOr<void> _onDeleteMessageNotificationReceivedInCallsEvent(
      DeleteMessageNotificationReceivedInCallsEvent event,
      Emitter<CallsState> emit) async {
    emit(state.copyWith(deleteMessageStatus: DeleteMessageStatus.init));
    if (event.type == "message") {
      GetIt.I<ChatBloc>().add(DeleteMessageNotificationReceivedInChatsEvent(
          messageId: event.messageId,
          channelId: event.channelId!,
          deleteForAll: event.deleteFromBoth == 1,
          isDelete: 1,
          deletedByUserId: event.deleteFromId));
    } else {
      List<CallReg> callReg = state.callRegister!.map((e) {
        if (e.id == event.messageId) {
          return e.copyWith(
              authMessageStatus: MessagesStatus(
                  isDeleted: 1, deleteForAll: event.deleteFromBoth == 1));
        }
        return e;
      }).toList();
      emit(state.copyWith(
        callRegister: callReg,
        deleteMessageStatus: DeleteMessageStatus.success,
      ));
    }
  }

  FutureOr<void> _onUpdateCurrentActiveCallIdEvent(
      UpdateCurrentActiveCallIdEvent event, Emitter<CallsState> emit) {
    emit(state.copyWith(currentActiveCallId: event.id));
  }
}
