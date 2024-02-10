import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/domain/useCase/get_agora_token_use_case.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';

import '../../../../common/constant/configuration/global.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../domain/useCase/answer_call_usecase.dart';
import '../../domain/useCase/reject_call_usecase.dart';
import '../../domain/useCase/make_call_usecase.dart';

part 'calls_event.dart';

part 'calls_state.dart';

@LazySingleton()
class CallsBloc extends Bloc<CallsEvent, CallsState> {
  PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final MakeCallUseCase makeCallUseCase;
  final AnswerCallUseCase answerCallUseCase;
  final RejectCallUseCase rejectCallUseCase;
  final GetAgoraTokenUseCase getAgoraTokenUseCase;

  CallsBloc(this.rejectCallUseCase, this.makeCallUseCase,
      this.answerCallUseCase, this.getAgoraTokenUseCase)
      : super(CallsState()) {
    on<CallsEvent>((event, emit) {});
    on<InitResponseRejectVideoCallEvent>(_onInitResponseRejectVideoCallEvent);
    on<RejectVideoCallEvent>(_onRejectVideoCallEvent);
    on<AnswerVideoCallEvent>(_onAnswerVideoCallEvent);
    on<EndVideoCallEvent>(_onEndVideoCallEvent);
    on<MakeCallEvent>(_onMakeCallEvent);
    on<UserInteractWithCall>(_onUserInteractWithCall);
    on<ResponseRejectVideoCallEvent>(_onResponseRejectVideoCallEvent);
  }

  FutureOr<void> _onResponseRejectVideoCallEvent(
      ResponseRejectVideoCallEvent event, Emitter<CallsState> emit) {
    debugPrint("createVideoCallStatusdasd");
    emit(state.copyWith(makeCallStatus: MakeCallStatus.cancel));
  }

  FutureOr<void> _onMakeCallEvent(
      MakeCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(makeCallStatus: MakeCallStatus.loading , isVideoCall: event.isVideo));

    if (event.receiverUserId != null) {
      final response = await makeCallUseCase(MakeCallParams(
          isVideo: event.isVideo,
          payload: event.payload,
          receiverUserId: event.receiverUserId!));
      response.fold((l) {
        emit(state.copyWith(
            makeCallStatus: MakeCallStatus.failure
        ));
      }, (r) {
        GetIt.I<ChatBloc>().add(AddAMessageToAChannel(message: r.data!.message!, localChannelId: event.chatId! ));
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
        emit(state.copyWith(
            makeCallStatus: MakeCallStatus.failure));
      }, (r) {
        GetIt.I<ChatBloc>().add(ReceiveMessageEvent(message: r.data!.message!, increaseUnReadMessages: false));
        emit(state.copyWith(
          messageId: r.data!.message!.id!.toString(),
          isVideoCall: event.isVideo,
          makeCallStatus: MakeCallStatus.startCall,
          currentActiveCallId: r.data!.message!.id!.toString(),
          agoraToken: r.data!.token,
          channelIdForCurrentCall: r.data!.message!.channelId.toString(),
        ));
      });
    }
  }

  FutureOr<void> _onEndVideoCallEvent(
      EndVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(makeCallStatus: MakeCallStatus.endCall));
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
    final response = await rejectCallUseCase.call(event.messageId);
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
}
